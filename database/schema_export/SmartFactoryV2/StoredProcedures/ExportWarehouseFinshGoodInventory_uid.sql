-- Procedure: ExportWarehouseFinshGoodInventory_uid
-- =============================================
-- Author:		Nguyễn Hải Triều
-- Create date: 2025-08-14
-- Description:	Xuất kho tem to thành phẩm tồn kho trước MES
-- =============================================
CREATE PROCEDURE [dbo].[ExportWarehouseFinshGoodInventory_uid] 
	-- Add the parameters for the stored procedure here
    @pProcessUserID VARCHAR(20),
    @pProcessLanguage VARCHAR(20),
	@pPackingID NVARCHAR(50)=NULL,
	@pCountry  NVARCHAR(50)=NULL,
	@pSoPhieuXuatKho NVARCHAR(50)=NULL,
	@pSoInVoice NVARCHAR(50)=NULL,
	@pSoToKhaiHaiQuan NVARCHAR(50)=NULL,
	@pTYPEEXPORT NVARCHAR(50)=NULL,
	@pVanchuyen NVARCHAR(50)=NULL,
	@pKhachhang NVARCHAR(50)=NULL,
	@pDateExport datetime
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
    -- Insert statements for procedure here
	 SET NOCOUNT ON;

    DECLARE
        @LoopPackingID NVARCHAR(50),
        @LotNo NVARCHAR(50),
        @Qty NUMERIC(20,5),
        @QtyInStock NUMERIC(20,5),
        @CodeExport NVARCHAR(50),
        @Err NVARCHAR(500),
        @checkStatusExport INT,
        @IsTemTo BIT = 0;

    BEGIN TRY
        BEGIN TRANSACTION;

        -- Kiểm tra tem to hay tem nhỏ
        IF EXISTS (SELECT 1 FROM STB_PackingOutPutFinishGoods_HN WHERE PackingOutPutFinishGoodsID = @pPackingID)
            SET @IsTemTo = 1;

        -- Xử lý TEM TO
        IF @IsTemTo = 1
        BEGIN
            -- Kiểm tra Packing cha tồn tại
            IF NOT EXISTS (SELECT 1 FROM FinishGoodMESInstock_HN WHERE MergeBoxSmallID = @pPackingID)
            BEGIN
                SET @Err = N'Không tìm thấy Packing cha: ' + @pPackingID;
                RAISERROR(@Err, 16, 1);
            END

            -- Cursor duyệt tất cả Packing con
            DECLARE record_cursor CURSOR FOR
                SELECT PackingID, LotNo, Quantity
                FROM FinishGoodMESInstock_HN
                WHERE MergeBoxSmallID = @pPackingID;

            OPEN record_cursor;
            FETCH NEXT FROM record_cursor INTO @LoopPackingID, @LotNo, @Qty;

            WHILE @@FETCH_STATUS = 0
            BEGIN
                -- Kiểm tra đã xuất chưa
                SELECT @checkStatusExport = ISNULL(StatusExport,0)
                FROM STB_VN_FINISHGOODS_HN_Export
                WHERE PackingID = @LoopPackingID;

                IF @checkStatusExport = 1
                BEGIN
                    SET @Err = N'PackingID: ' + @LoopPackingID + N' đã được xuất kho trước đó.';
                    RAISERROR(@Err,16,1);
                END

                -- Kiểm tra tồn kho
                SELECT @QtyInStock = Quantity - ISNULL(QtyOutput,0)
                FROM FinishGoodMESInstock_HN
                WHERE PackingID = @LoopPackingID;

                IF @QtyInStock IS NULL OR @QtyInStock <= 0
                BEGIN
                    SET @Err = N'Số lượng tồn kho của PackingID: ' + @LoopPackingID + N' đã hết hoặc không đủ xuất.';
                    RAISERROR(@Err,16,1);
                END

                -- Sinh mã xuất kho
                EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_VN_FINISHGOODS_HN_Export', @CodeExport OUTPUT;
                SET @CodeExport = 'EXVNHN' + @CodeExport;

                -- Insert bảng xuất kho
                INSERT INTO STB_VN_FINISHGOODS_HN_Export (
                    CodeExport, LotNo, PackingID, Qty, Country, SoPhieuXuatKho,
                    SoInVoice, SoToKhaiHaiQuan, TypeExport, TRANSPORT, CustomerName,
                    DateRequestExport, CreateDateTime, CreateUserID, StatusExport
                )
                VALUES (
                    @CodeExport, @LotNo, @LoopPackingID, @Qty, @pCountry, @pSoPhieuXuatKho,
                    @pSoInVoice, @pSoToKhaiHaiQuan, @pTYPEEXPORT, @pVanchuyen, @pKhachhang,
                    @pDateExport, GETDATE(), @pProcessUserID, 1
                );

                -- Cập nhật QtyOutput
                UPDATE FinishGoodMESInstock_HN
                SET QtyOutput = ISNULL(QtyOutput,0) + @Qty
                WHERE PackingID = @LoopPackingID;

                FETCH NEXT FROM record_cursor INTO @LoopPackingID, @LotNo, @Qty;
            END

            CLOSE record_cursor;
            DEALLOCATE record_cursor;
        END
        -- Xử lý TEM NHỎ
        ELSE
        BEGIN

		---Mr.Trieu thêm trường hợp là với tem chia

            -- Kiểm tra đã xuất chưa
            SELECT @checkStatusExport = ISNULL(StatusExport,0)
            FROM STB_VN_FINISHGOODS_HN_Export
            WHERE PackingID = @pPackingID;

            IF @checkStatusExport = 1
            BEGIN
                SET @Err = N'PackingID: ' + @pPackingID + N' đã được xuất kho trước đó.';
                RAISERROR(@Err,16,1);
            END
			-- Check tiếp tục đến trường hợp là tem chia
			DECLARE @IsDevidePacking BIT;
			IF EXISTS (SELECT 1 FROM STB_DividePackaging WHERE PackingID = @pPackingID)
            BEGIN
               SET @IsDevidePacking = 1;
            END
			if(@IsDevidePacking=1)
			BEGIN
			   SELECT TOP 1 @LotNo = LotNo, @Qty = Qty
               FROM STB_DividePackaging
               WHERE PackingID = @pPackingID;
			   IF @LotNo IS NULL OR @Qty IS NULL
               BEGIN
                  SET @Err = N'Tem nhỏ không có dữ liệu LotNo hoặc Qty trong bảng STB_DividePackaging: ' + @pPackingID;
                  RAISERROR(@Err, 16, 1);
                END
			END
			ELSE
			BEGIN
			     SELECT @LotNo = LotNo,
                   @Qty = Quantity,
                   @QtyInStock = Quantity - ISNULL(QtyOutput,0)
                  FROM FinishGoodMESInstock_HN
                  WHERE PackingID = @pPackingID;

               IF @LotNo IS NULL
               BEGIN
                   SET @Err = N'Không tìm thấy Packing nhỏ: ' + @pPackingID;
                  RAISERROR(@Err,16,1);
               END
			   -- Kiểm tra tồn kho
            IF @QtyInStock IS NULL OR @QtyInStock <= 0
            BEGIN
                SET @Err = N'Số lượng tồn kho của PackingID: ' + @pPackingID + N' đã hết hoặc không đủ xuất.';
                RAISERROR(@Err,16,1);
            END
			END

		       

            -- Sinh mã xuất kho
            EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_VN_FINISHGOODS_HN_Export', @CodeExport OUTPUT;
            SET @CodeExport = 'EXVNHN' + @CodeExport;

            -- Insert bảng xuất kho
            INSERT INTO STB_VN_FINISHGOODS_HN_Export (
                CodeExport, LotNo, PackingID, Qty, Country, SoPhieuXuatKho,
                SoInVoice, SoToKhaiHaiQuan, TypeExport, TRANSPORT, CustomerName,
                DateRequestExport, CreateDateTime, CreateUserID, StatusExport
            )
            VALUES (
                @CodeExport, @LotNo, @pPackingID, @Qty, @pCountry, @pSoPhieuXuatKho,
                @pSoInVoice, @pSoToKhaiHaiQuan, @pTYPEEXPORT, @pVanchuyen, @pKhachhang,
                @pDateExport, GETDATE(), @pProcessUserID, 1
            );
			if( @IsDevidePacking=1)
			BEGIN
			    DECLARE @ParentID NVARCHAR(50);
                SELECT TOP 1 @ParentID = PackingParentID
                FROM STB_DividePackaging
                WHERE PackingID = @pPackingID;
				 UPDATE FinishGoodMESInstock_HN
                 SET QtyOutput = ISNULL(QtyOutput, 0) + @Qty
                 WHERE PackingID = @ParentID AND LotNo = @LotNo;

			END
			ELSE
			BEGIN
                UPDATE FinishGoodMESInstock_HN
                SET QtyOutput = ISNULL(QtyOutput, 0) + @Qty
                WHERE PackingID = @pPackingID AND LotNo = @LotNo;
			END
           
        END

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        PRINT N'Lỗi: ' + ERROR_MESSAGE();
    END CATCH;

    -- Trả về thông tin đã xuất
    SELECT
        E.CodeExport,
        E.LotNo,
        E.PackingID,
        I.MergeBoxSmallID,
        E.Qty,
        E.Country,
        E.SoPhieuXuatKho,
        E.SoInVoice,
        E.SoToKhaiHaiQuan,
        E.TypeExport,
        E.TRANSPORT,
        E.CustomerName,
        E.DateRequestExport,
        E.CreateUserID
    FROM STB_VN_FINISHGOODS_HN_Export E
    LEFT JOIN FinishGoodMESInstock_HN I ON E.PackingID = I.PackingID
	LEFT JOIN STB_DividePackaging D ON D.PackingID=E.PackingID
    WHERE (E.PackingID = @pPackingID) OR (I.MergeBoxSmallID = @pPackingID);
END


GO

