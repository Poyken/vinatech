-- =============================================
-- Author:		Mr.Duy & Mr.Trieu
-- Create date: 2025-04-24
-- Description:	Gộp mã xuất kho cho hà nam
-- =============================================
CREATE PROCEDURE [dbo].[usp_Vietnam_DoProcessBigBoxPacking_VVT_F3]
    @pProcessUserID VARCHAR(20),
    @pProcessLanguage VARCHAR(20),
    @pProcessViewName VARCHAR(50),
    @pXml NVARCHAR(MAX) = NULL,
    @pMergeQty INT = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    DECLARE @ProcessUserID VARCHAR(20) = @pProcessUserID;
    DECLARE @ProcessLanguage VARCHAR(20) = @pProcessLanguage;
    DECLARE @ProcessViewName VARCHAR(50) = @pProcessViewName;
    DECLARE @TableName VARCHAR(100) = '/DataSet/' + @ProcessViewName;
    DECLARE @ERROR_MSG NVARCHAR(MAX);
    DECLARE @iDoc INT;
    DECLARE @PackingID VARCHAR(50);

    DECLARE @Marking VARCHAR(100);
    DECLARE @CombineMaterialcodeAndQty VARCHAR(500);
    DECLARE @PackingIdParent VARCHAR(50);
    DECLARE @PackingOutPutFinishGoodsID VARCHAR(50);
    DECLARE @MarkingCode VARCHAR(50);

    DECLARE @TotalInitialQty NUMERIC(20, 5) = 0;
    DECLARE @TotalCurrentQty NUMERIC(20, 5) = 0;
    DECLARE @CurrentQty NUMERIC(20, 5) = 0;
    DECLARE @MaterialCode VARCHAR(50);

    BEGIN TRY
        EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_PackingOutPutFinishGoods_HN', @PackingOutPutFinishGoodsID OUTPUT;
        SET @PackingOutPutFinishGoodsID = 'PKHNOP' + @PackingOutPutFinishGoodsID;

        EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml;

        DECLARE @CountMarkingName INT = 0;

        SELECT @CountMarkingName = COUNT(DISTINCT b.MarkingName)
        FROM OPENXML(@iDoc, @TableName, 2) WITH (PackingID VARCHAR(50)) AS xmlData
        JOIN STB_MaterialLotInfo m ON xmlData.PackingID = m.PackingID
        JOIN STB_CreateMarkingLetterAndQtyForBarcode b ON m.MarkingCode = b.MarkingCode;

        IF @CountMarkingName > 1
        BEGIN
            EXEC sp_xml_removedocument @iDoc; 
            RAISERROR(N'Lỗi: Phát hiện %d loại Marking Name khác nhau. Chỉ được gộp các mã có cùng Marking Name.', 16, 1, @CountMarkingName);
            RETURN;
        END
            DECLARE SourceData CURSOR FOR
            SELECT 
                PackingID, 
                PackingIdParent,
                MarkingCode
            FROM OPENXML(@iDoc, @TableName, 2)
            WITH (
                PackingID VARCHAR(50), 
                PackingIdParent VARCHAR(50),
                MarkingCode VARCHAR(50)
            );OPEN SourceData;
        FETCH NEXT FROM SourceData INTO @PackingID, @PackingIdParent, @MarkingCode;

        WHILE @@FETCH_STATUS = 0

        
        BEGIN
		    
		   -- Mr.Triều chặn không cho đóng thùng néu mã packing đó chưa được nhập kho
		    IF NOT EXISTS(SELECT 1 FROM STB_VN_FINISHGOODS_HN_New WHERE PackingID=@PackingID AND StatusImport = 1)
		    BEGIN
		       RAISERROR(N'Mã %s chưa được nhập kho nên không thể gộp.', 16, 1, @PackingID);
               RETURN;
		    END
			

			--SELECT TOP 100 * FROM STB_MaterialLotInfo WHERE WorkCenterCode='VVT_F3' AND MarkingCode is not null
		    -- Mr.Triều cho phép có thể gộp với Packing đã chia
            DECLARE @IsDivided BIT = 0;
            DECLARE @MergeParentId VARCHAR(50);

            SELECT TOP 1 @MergeParentId = MergeParentId 
            FROM STB_MaterialLotInfo 
            WHERE PackingID = @PackingID

            IF (@MergeParentId IS NOT NULL)
            BEGIN
                RAISERROR(N'Mã này đã gộp rồi', 16, 1);
                RETURN;
            END

            IF EXISTS (SELECT 1 FROM STB_DividePackaging WHERE PackingID = @PackingID)
                SET @IsDivided = 1;
		  -- Mr.Trieu làm với trường hợp là tem tách
		  -- Ok mà check thấy là tem chia thì lấy số lượng chia ở màn Hn542
            IF @IsDivided = 1
            BEGIN
                SELECT 
                    @TotalCurrentQty = ISNULL(SUM(Qty), 0)
                FROM STB_DividePackaging
                WHERE PackingID = @PackingID;

                SELECT TOP 1
                    @Marking = UPPER(b.MarkingName),
                    @MaterialCode = m.MaterialCode,
                    @CombineMaterialcodeAndQty = d.PackingID + ' ,' + UPPER(b.MarkingName) + ' ,' + CONVERT(VARCHAR, d.Qty)
                FROM STB_DividePackaging d
                JOIN STB_MaterialLotInfo m ON d.PackingParentID = m.PackingID
                JOIN STB_CreateMarkingLetterAndQtyForBarcode b ON m.MarkingCode = b.MarkingCode
                WHERE d.PackingID = @PackingID;
            END
            ELSE
            BEGIN
                SELECT 
                    @TotalCurrentQty = CurrentQty,
                    @Marking = UPPER(b.MarkingName),
                    @MaterialCode = m.MaterialCode,
                    @CombineMaterialcodeAndQty = m.PackingID + ' ,' + UPPER(b.MarkingName) + ' ,' + CONVERT(VARCHAR, m.CurrentQty)
                FROM STB_MaterialLotInfo m
                JOIN STB_CreateMarkingLetterAndQtyForBarcode b ON m.MarkingCode = b.MarkingCode
                WHERE m.PackingID = @PackingID;
            END

            IF NOT EXISTS (
                SELECT 1 FROM STB_PackingOutPutFinishGoods_HN 
                WHERE PackingOutPutFinishGoodsID = @PackingOutPutFinishGoodsID)
            BEGIN
                INSERT INTO STB_PackingOutPutFinishGoods_HN
                (
                    PackingOutPutFinishGoodsID, CurrentQty, Marking, MaterialCode, 
                    CreateDateTime, CombineMaterialcodeAndQty, CreateUserID
                )
                VALUES
                (
                    @PackingOutPutFinishGoodsID, @TotalCurrentQty, @Marking, @MaterialCode, 
                    GETDATE(), @CombineMaterialcodeAndQty, @pProcessUserID
                );
            END
            ELSE
            BEGIN
                DECLARE @CheckMaterialCode VARCHAR(50);
                SELECT @CheckMaterialCode = MaterialCode 
                FROM STB_PackingOutPutFinishGoods_HN 
                WHERE PackingOutPutFinishGoodsID = @PackingOutPutFinishGoodsID;

                --IF @CheckMaterialCode != @MaterialCode
                --BEGIN
                    --RAISERROR(N'Các mã gộp phải cùng nguyên vật liệu', 16, 1);
                    --RETURN;
                --END

                UPDATE STB_PackingOutPutFinishGoods_HN 
                SET 
                    CurrentQty = CurrentQty + @TotalCurrentQty,
                    Marking = Marking + ',' + @Marking,
                    CombineMaterialcodeAndQty = CombineMaterialcodeAndQty + ' ;' + @CombineMaterialcodeAndQty
                WHERE PackingOutPutFinishGoodsID = @PackingOutPutFinishGoodsID;
            END

            IF @IsDivided = 1
            BEGIN
                UPDATE STB_DividePackaging
                SET MergeParentId = @PackingOutPutFinishGoodsID
                WHERE PackingID = @PackingID;
            END
            ELSE
            BEGIN
                UPDATE STB_MaterialLotInfo
                SET MergeParentId = @PackingOutPutFinishGoodsID, CurrentQtyBefMerge = CurrentQty
                WHERE PackingID = @PackingID;
            END

            FETCH NEXT FROM SourceData INTO @PackingID, @PackingIdParent, @MarkingCode;
        END
		--- đã mở xong là phải đóng con trỏ 
        CLOSE SourceData;
        DEALLOCATE SourceData;

    END TRY
    BEGIN CATCH
        SET @ERROR_MSG = ERROR_MESSAGE();
        RAISERROR(@ERROR_MSG, 16, 1);
        RETURN;
    END CATCH;

    EXEC sp_xml_removedocument @iDoc;
END
