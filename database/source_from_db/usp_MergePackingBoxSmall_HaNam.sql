-- =============================================
-- Author:		Mr.Duy
-- Create date: 2025-06-11
-- Description:	Gộp tem túi bóng vào thành hộp nhỏ
-- =============================================
CREATE PROCEDURE [dbo].[usp_MergePackingBoxSmall_HaNam]
    @pProcessUserID VARCHAR(20),
    @pProcessLanguage VARCHAR(20),
    @pProcessViewName VARCHAR(50),
    @pXml NVARCHAR(MAX) = NULL,
    @pMergeQty INT = NULL
	--@PackingNilonToBoxSmallID
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	--SET NOCOUNT ON;

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
    DECLARE @PackingNilonToBoxSmallID VARCHAR(50);
    DECLARE @MarkingCode VARCHAR(50);

    DECLARE @TotalInitialQty NUMERIC(20, 5) = 0;
    DECLARE @TotalCurrentQty NUMERIC(20, 5) = 0;
    DECLARE @CurrentQty NUMERIC(20, 5) = 0;
    DECLARE @MaterialCode VARCHAR(50);
	
    -- Mở giao dịch
   -- BEGIN TRANSACTION;

    BEGIN TRY
        EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_PackingNilonToBoxSmall_HN', @PackingNilonToBoxSmallID OUTPUT;
        SET @PackingNilonToBoxSmallID = 'PK' + @PackingNilonToBoxSmallID;

        EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml;

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
            );

        OPEN SourceData;
        FETCH NEXT FROM SourceData INTO @PackingID, @PackingIdParent, @MarkingCode;

        WHILE @@FETCH_STATUS = 0
        BEGIN
		    /*
		   -- Mr.Triều chặn không cho đóng thùng néu mã packing đó chưa được nhập kho
		    IF NOT EXISTS(SELECT 1 FROM STB_VN_FINISHGOODS_HN_New WHERE PackingID=@PackingID AND StatusImport = 1)
		    BEGIN
		       RAISERROR(N'Mã %s chưa được nhập kho nên không thể gộp.', 16, 1, @PackingID);
               RETURN;
		    END
			*/
			-- Mr.Triều chặn không cho gộp box nếu mã nó thuộc 2 mã marking khác nhau
			DECLARE @TotalMarkingCode INT
			select @TotalMarkingCode=COUNT(DISTINCT MarkingCode) FROM STB_MaterialLotInfo WHERE PackingID = @PackingID
			IF(@TotalMarkingCode>1)
			begin
			    RAISERROR(N'Không thể gộp do có nhiều hơn 1 MarkingCode trong Packing này.', 16, 1, @PackingID);
                RETURN;
			end

			--SELECT TOP 100 * FROM STB_MaterialLotInfo WHERE WorkCenterCode='VVT_F3' AND MarkingCode is not null
		    -- Mr.Triều cho phép có thể gộp với Packing đã chia
            DECLARE @IsDivided BIT = 0;
            DECLARE @MergeParentId VARCHAR(50),
            @MergeNilonToSmallBox VARCHAR(50);

            SELECT TOP 1 @MergeParentId = MergeParentId, @MergeNilonToSmallBox = MergeNilonToSmallBox
            FROM STB_MaterialLotInfo 
            WHERE PackingID = @PackingID

            IF (@MergeParentId IS NOT NULL or @MergeNilonToSmallBox IS NOT NULL)
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
                SELECT 1 FROM STB_PackingNilonToBoxSmall_HN 
                WHERE PackingNilonToBoxSmallID = @PackingNilonToBoxSmallID)
            BEGIN
                INSERT INTO STB_PackingNilonToBoxSmall_HN
                (
                    PackingNilonToBoxSmallID, CurrentQty, Marking, MaterialCode, 
                    CreateDateTime, CombineMaterialcodeAndQty, CreateUserID
                )
                VALUES
                (
                    @PackingNilonToBoxSmallID, @TotalCurrentQty, @Marking, @MaterialCode, 
                    GETDATE(), @CombineMaterialcodeAndQty, @pProcessUserID
                );
            END
            ELSE
            BEGIN
                DECLARE @CheckMaterialCode VARCHAR(50);
                SELECT @CheckMaterialCode = MaterialCode 
                FROM STB_PackingNilonToBoxSmall_HN 
                WHERE PackingNilonToBoxSmallID = @PackingNilonToBoxSmallID;

                --IF @CheckMaterialCode != @MaterialCode
                --BEGIN
                    --RAISERROR(N'Các mã gộp phải cùng nguyên vật liệu', 16, 1);
                    --RETURN;
                --END

                UPDATE STB_PackingNilonToBoxSmall_HN 
                SET 
                    CurrentQty = CurrentQty + @TotalCurrentQty,
                    Marking = Marking + ',' + @Marking,
                    CombineMaterialcodeAndQty = CombineMaterialcodeAndQty + ' ;' + @CombineMaterialcodeAndQty
                WHERE PackingNilonToBoxSmallID = @PackingNilonToBoxSmallID;
            END

            IF @IsDivided = 1
            BEGIN
                UPDATE STB_DividePackaging
                SET MergeNilonToSmallBox = @PackingNilonToBoxSmallID
                WHERE PackingID = @PackingID;
            END
            ELSE
            BEGIN
                UPDATE STB_MaterialLotInfo
                SET MergeNilonToSmallBox = @PackingNilonToBoxSmallID, CurrentQtyBefMerge = CurrentQty
                WHERE PackingID = @PackingID;
            END

            FETCH NEXT FROM SourceData INTO @PackingID, @PackingIdParent, @MarkingCode;
        END

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


select * from  STB_PackingNilonToBoxSmall_HN