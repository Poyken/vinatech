CREATE PROCEDURE [dbo].[usp_Vietnam_DoProcessMergeMaterial_VVT]
    @pProcessUserID VARCHAR(20),
    @pProcessLanguage VARCHAR(20),
    @pProcessViewName VARCHAR(50),
    @pXml NVARCHAR(MAX) = NULL,
    @pMergeQty INT = NULL,
    @pTargetParentID NVARCHAR(50) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @TableName VARCHAR(100) = '/DataSet/' + @pProcessViewName;
    DECLARE @iDoc INT;
    DECLARE @NewLotID VARCHAR(50);
    DECLARE @ERROR_MSG NVARCHAR(MAX);

    -- 1. Đọc dữ liệu từ XML
    EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml;
    
    SELECT LotID, MaterialCode, CurrentQty
    INTO #ScannedData
    FROM OPENXML(@iDoc, @TableName, 2)
    WITH (
        LotID VARCHAR(50),
        MaterialCode VARCHAR(50),
        CurrentQty NUMERIC(20,10)
    );

    BEGIN TRANSACTION;

    BEGIN TRY

        IF @pTargetParentID IS NOT NULL
        BEGIN

            IF EXISTS (
                SELECT 1 FROM #ScannedData s
                WHERE s.MaterialCode NOT IN (SELECT MaterialCode FROM STB_MaterialLevel WHERE ParentID = @pTargetParentID)
            )
            BEGIN
                RAISERROR(N'Lỗi: Có linh kiện bắn vào không nằm trong định mức của mã cấp trên đã chọn!', 16, 1);
                ROLLBACK; RETURN;
            END
        END
        ELSE
        BEGIN

            SELECT TOP 1 @pTargetParentID = ml.ParentID
            FROM STB_MaterialLevel ml
            INNER JOIN (SELECT DISTINCT MaterialCode FROM #ScannedData) s ON ml.MaterialCode = s.MaterialCode
            GROUP BY ml.ParentID
            HAVING COUNT(DISTINCT ml.MaterialCode) = (SELECT COUNT(DISTINCT MaterialCode) FROM #ScannedData)
               AND COUNT(DISTINCT ml.MaterialCode) = (SELECT COUNT(*) FROM STB_MaterialLevel WHERE ParentID = ml.ParentID);
        END

        IF @pTargetParentID IS NULL
        BEGIN
            RAISERROR(N'Không xác định được mã cấp trên cần gộp!', 16, 1);
            ROLLBACK; RETURN;
        END


        DECLARE @ChildCode NVARCHAR(50), @QtyRequired INT;
        DECLARE BOM_Cursor CURSOR FOR 
        SELECT MaterialCode, Quantity FROM STB_MaterialLevel WHERE ParentID = @pTargetParentID;

        OPEN BOM_Cursor;
        FETCH NEXT FROM BOM_Cursor INTO @ChildCode, @QtyRequired;

        WHILE @@FETCH_STATUS = 0
        BEGIN
            DECLARE @AmountNeeded NUMERIC(20,10) = @QtyRequired * @pMergeQty;
            DECLARE @LotID_Sub VARCHAR(50), @LotQty_Sub NUMERIC(20,10);

            DECLARE Lot_Cursor CURSOR FOR
            SELECT LotID, CurrentQty FROM #ScannedData 
            WHERE MaterialCode = @ChildCode
            ORDER BY CurrentQty ASC;

            OPEN Lot_Cursor;
            FETCH NEXT FROM Lot_Cursor INTO @LotID_Sub, @LotQty_Sub;

            WHILE @@FETCH_STATUS = 0 AND @AmountNeeded > 0
            BEGIN
                DECLARE @Take NUMERIC(20,10) = CASE WHEN @LotQty_Sub <= @AmountNeeded THEN @LotQty_Sub ELSE @AmountNeeded END;

                UPDATE STB_MaterialLotInfo_TEST 
                SET CurrentQtyBefMerge = CurrentQty,
                    InitialQtyBefMerge = InitialQty,
                    CurrentQty = CurrentQty - @Take,
                    MergeParentId = @pTargetParentID,
                    CreateDateSlittingTime = GETDATE()
                WHERE LotID = @LotID_Sub;

                SET @AmountNeeded = @AmountNeeded - @Take;
                FETCH NEXT FROM Lot_Cursor INTO @LotID_Sub, @LotQty_Sub;
            END

            CLOSE Lot_Cursor;
            DEALLOCATE Lot_Cursor;

            IF @AmountNeeded > 0
            BEGIN
                SET @ERROR_MSG = N'Mã ' + @ChildCode + N' không đủ số lượng để gộp mã ' + @pTargetParentID;
                RAISERROR(@ERROR_MSG, 16, 1);
                ROLLBACK; RETURN;
            END

            FETCH NEXT FROM BOM_Cursor INTO @ChildCode, @QtyRequired;
        END
        CLOSE BOM_Cursor;
        DEALLOCATE BOM_Cursor;

        EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_MaterialLotInfo_TEST', @NewLotID OUTPUT;
        SET @NewLotID = 'SM' + SUBSTRING(@NewLotID, 3, LEN(@NewLotID) - 2);

        INSERT INTO STB_MaterialLotInfo_TEST (
            MaterialLotNo, LotID, MaterialCode, CurrentQty, InitialQty, 
            MaterialWarehouseCode, CreateUserID, CreateDateTime, CompanyCode, WorkCenterCode
        )
        SELECT TOP 1 
            @NewLotID + '_NO', @NewLotID, @pTargetParentID, @pMergeQty, @pMergeQty,
            MaterialWarehouseCode, @pProcessUserID, GETDATE(), CompanyCode, WorkCenterCode
        FROM STB_MaterialLotInfo_TEST
        WHERE LotID IN (SELECT LotID FROM #ScannedData);

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        SET @ERROR_MSG = ERROR_MESSAGE();
        RAISERROR(@ERROR_MSG, 16, 1);
    END CATCH

    IF (SELECT CURSOR_STATUS('global','BOM_Cursor')) >= -1 DEALLOCATE BOM_Cursor;
    EXEC sp_xml_removedocument @iDoc;
END