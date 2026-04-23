-- =============================================
-- Author:		Nguyễn Hải Triều
-- Create date: 2025-08-14
-- Description:	Gộp đóng thùng to với các hàng tồn trước khi sử dụng MES
-- =============================================
CREATE PROCEDURE [dbo].[usp_Vietnam_DoProcessBigBoxPackingInventory_VVT_F3]
	-- Add the parameters for the stored procedure here
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

    -- Insert statements for procedure here
	DECLARE @ProcessUserID VARCHAR(20) = @pProcessUserID;
    DECLARE @ProcessLanguage VARCHAR(20) = @pProcessLanguage;
    DECLARE @ProcessViewName VARCHAR(50) = @pProcessViewName;
    DECLARE @TableName VARCHAR(100) = '/DataSet/' + @ProcessViewName;
    DECLARE @ERROR_MSG NVARCHAR(MAX);
    DECLARE @iDoc INT;
    DECLARE @PackingID VARCHAR(50);

    DECLARE @Marking VARCHAR(100);
    DECLARE @CombineMaterialcodeAndQty VARCHAR(500);
    DECLARE @PackingOutPutFinishGoodsID VARCHAR(50);
    DECLARE @MarkingCode VARCHAR(50);

    DECLARE @TotalCurrentQty NUMERIC(20, 5) = 0;
    DECLARE @MaterialCode VARCHAR(50);
    DECLARE @MergeParentId VARCHAR(50);
	BEGIN TRY
        -- 1. Tạo mã Big Box mới
        EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_PackingOutPutFinishGoods_HN', @PackingOutPutFinishGoodsID OUTPUT;
        SET @PackingOutPutFinishGoodsID = 'PKHNOP' + @PackingOutPutFinishGoodsID;

        -- 2. Đọc XML input
        EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml;

        DECLARE SourceData CURSOR FOR
            SELECT PackingID
            FROM OPENXML(@iDoc, @TableName, 2)
            WITH (PackingID VARCHAR(50));

        OPEN SourceData;
        FETCH NEXT FROM SourceData INTO @PackingID;

        WHILE @@FETCH_STATUS = 0
        BEGIN
            -- 3. Check đã gộp chưa
            IF EXISTS (
                SELECT 1 FROM FinishGoodMESInstock_HN
                WHERE PackingID = @PackingID AND MergeBoxSmallID IS NOT NULL
            )
            BEGIN
                RAISERROR(N'Mã %s đã được gộp trước đó.', 16, 1, @PackingID);
                RETURN;
            END

            -- 4. Lấy thông tin tồn kho MES
            SELECT 
                @TotalCurrentQty = Quantity,
                @Marking = Marking,
                @MaterialCode = MaterialCode,
                @CombineMaterialcodeAndQty = PackingID + ' ,' + Marking + ' ,' + CONVERT(VARCHAR, Quantity)
            FROM FinishGoodMESInstock_HN
            WHERE PackingID = @PackingID;

            -- 5. Ghi dữ liệu gộp vào bảng Big Box
            IF NOT EXISTS (
                SELECT 1 FROM STB_PackingOutPutFinishGoods_HN
                WHERE PackingOutPutFinishGoodsID = @PackingOutPutFinishGoodsID
            )
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
                UPDATE STB_PackingOutPutFinishGoods_HN
                SET 
                    CurrentQty = CurrentQty + @TotalCurrentQty,
                    Marking = Marking + ',' + @Marking,
                    CombineMaterialcodeAndQty = CombineMaterialcodeAndQty + ' ;' + @CombineMaterialcodeAndQty
                WHERE PackingOutPutFinishGoodsID = @PackingOutPutFinishGoodsID;
            END

            -- 6. Update MergeBoxSmallID trong MES instock
            UPDATE FinishGoodMESInstock_HN
            SET MergeBoxSmallID = @PackingOutPutFinishGoodsID
            WHERE PackingID = @PackingID;

            FETCH NEXT FROM SourceData INTO @PackingID;
        END

        CLOSE SourceData;
        DEALLOCATE SourceData;

        EXEC sp_xml_removedocument @iDoc;
    END TRY
    BEGIN CATCH
        SET @ERROR_MSG = ERROR_MESSAGE();
        RAISERROR(@ERROR_MSG, 16, 1);
        RETURN;
    END CATCH;
END
