-- =============================================
-- Author:		Nguyễn Hải Triều
-- Create date: 2026-01-14
-- Description:	Gộp packing hàng lẻ thành một cuộn to
-- =============================================
CREATE PROCEDURE [dbo].[usp_MergePackingHN710_HN]
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
    DECLARE @TableName VARCHAR(100) = '/DataSet/' + @pProcessViewName;
    DECLARE @ERROR_MSG NVARCHAR(MAX);
    DECLARE @iDoc INT;
    
    -- Biến điều khiển Cursor
    DECLARE @PackingID VARCHAR(50);
    DECLARE @PackingIdParent VARCHAR(50);
    DECLARE @MarkingCode_Xml VARCHAR(50);
    -- Biến tạm thời cho mỗi vòng lặp
    DECLARE @Marking VARCHAR(100);
    DECLARE @CombineMaterialcodeAndQty VARCHAR(500);
    DECLARE @MergePackingId VARCHAR(50);
    DECLARE @TotalCurrentQty NUMERIC(20, 5); -- Sẽ Reset trong vòng lặp
    DECLARE @MaterialCode VARCHAR(50);
	DECLARE @PackingIdCode VARCHAR(50)
    SET @PackingIdCode ='PKTT' 
                    + RIGHT(CAST(ABS(CHECKSUM(NEWID())) AS VARCHAR(20)), 7);
    BEGIN TRY
        -- 1. Tạo Serial mới cho cuộn to
        EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_PackingHN710_HN', @MergePackingId OUTPUT;
        SET @MergePackingId = 'VE' + @MergePackingId;

        -- 2. Đọc dữ liệu XML
        EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml;

        DECLARE SourceData CURSOR FOR
            SELECT PackingID, PackingIdParent, MarkingCode
            FROM OPENXML(@iDoc, @TableName, 2)
            WITH (
                PackingID VARCHAR(50), 
                PackingIdParent VARCHAR(50),
                MarkingCode VARCHAR(50)
            );

        OPEN SourceData;
        FETCH NEXT FROM SourceData INTO @PackingID, @PackingIdParent, @MarkingCode_Xml;

        WHILE @@FETCH_STATUS = 0
        BEGIN
		    -- Thêm trường hợp nó làm tem tách
			DECLARE @IsDivided BIT = 0;
			-- Kiểm tra xem có phải là tem tách không
		    IF EXISTS (SELECT 1 FROM STB_DividePackaging WHERE PackingID = @PackingID)
                SET @IsDivided = 1;
            SET @TotalCurrentQty = 0;
            SET @MaterialCode = NULL;
			IF(@IsDivided=1)
			BEGIN
			   SELECT 
                    @TotalCurrentQty = ISNULL(SUM(Qty), 0)
                FROM STB_DividePackaging
                WHERE PackingID = @PackingID;

			    SELECT TOP 1
                    @Marking= UPPER(b.MarkingName),
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
                @TotalCurrentQty = ISNULL(m.CurrentQty, 0), 
                @Marking = UPPER(ISNULL(b.MarkingName, '')),
                @MaterialCode = m.MaterialCode,
                @CombineMaterialcodeAndQty = m.PackingID + ' ,' + UPPER(ISNULL(b.MarkingName, '')) + ' ,' + CONVERT(VARCHAR, ISNULL(m.CurrentQty, 0))
              FROM STB_MaterialLotInfo m
               LEFT JOIN STB_CreateMarkingLetterAndQtyForBarcode b ON m.MarkingCode = b.MarkingCode
               WHERE m.PackingID = @PackingID;

			END
          

            -- Chỉ xử lý nếu tìm thấy số lượng > 0
            IF @TotalCurrentQty > 0
            BEGIN
                -- 4. Nếu chưa có bản ghi cha (Lô VE...), tiến hành tạo mới
                IF NOT EXISTS (SELECT 1 FROM STB_PackingHN710_HN WHERE LotNo = @MergePackingId)
                BEGIN
                    INSERT INTO STB_PackingHN710_HN
                    (
                        LotNo, Qty, Marking, MaterialCode, 
                        CreateDateTime, CombiPackkingAndMarking, CreateUserID,PackingId
                    )
                    VALUES
                    (
                        @MergePackingId, @TotalCurrentQty, @Marking, @MaterialCode, 
                        GETDATE(), @CombineMaterialcodeAndQty, @pProcessUserID,@PackingIdCode
                    );
                END
                ELSE
                BEGIN
                    -- 5. Nếu đã tồn tại bản ghi cha, cộng dồn số lượng và chuỗi ký hiệu
                    UPDATE STB_PackingHN710_HN 
                    SET 
                        Qty = Qty + @TotalCurrentQty,
                        Marking = Marking + ',' + @Marking,
                        CombiPackkingAndMarking = CombiPackkingAndMarking + ' ;' + @CombineMaterialcodeAndQty
                    WHERE LotNo = @MergePackingId;
                END

			-- Nếu mà là tem tách thì cập nhât lại cột để đánh dấu nó
             IF @IsDivided = 1
            BEGIN
                UPDATE STB_DividePackaging
                SET MergeNilonToSmallBox = @PackingIdCode
                WHERE PackingID = @PackingID;
            END
            ELSE
            BEGIN
                UPDATE STB_MaterialLotInfo
                SET MergePackingId = @PackingIdCode, -- Đổi tên cột cho đúng logic nghiệp vụ (thường là ParentId)
                    CurrentQtyBefMerge = CurrentQty
                WHERE PackingID = @PackingID;
            END
             
            END

            FETCH NEXT FROM SourceData INTO @PackingID, @PackingIdParent, @MarkingCode_Xml;
        END

        CLOSE SourceData;
        DEALLOCATE SourceData;
        EXEC sp_xml_removedocument @iDoc;

    END TRY
    BEGIN CATCH
        IF CURSOR_STATUS('global','SourceData') >= 0
        BEGIN
            CLOSE SourceData;
            DEALLOCATE SourceData;
        END
        SET @ERROR_MSG = ERROR_MESSAGE();
        RAISERROR(@ERROR_MSG, 16, 1);
    END CATCH;
END
