-- Procedure: ExportWarehouseFinshGood_uid
-- =============================================
-- Author:		Mr.Duy & Mr.Triêu thay đổi thêm các trường hợp để phù hợp với hà nam
-- Create date: 2025-05-30
-- Description:	Xuất kho với packing to cho nhà máy hà nam
-- Desc:Mr.Trieu đã thay đổi để có thể xuất được cả tem nhỏ và tem to
-- =============================================
-- exec ExportWarehouseFinshGood_uid 'haitrieu','VI','pkhnop202507300000000001',N'VIỆT NAM','VNEPD04-25080101','ENE-250801V1','307631033530','S01','LOACAL','SUNLIN VIETNAM ELECTRONICS CO.,LTD','2025-08-01'
CREATE PROCEDURE [dbo].[ExportWarehouseFinshGood_uid]
	@pProcessUserID VARCHAR(20),
    @pProcessLanguage VARCHAR(20),
	@pPackingID NVARCHAR(50),
	@pCountry  NVARCHAR(50),
	@pSoPhieuXuatKho NVARCHAR(50),
	@pSoInVoice NVARCHAR(50),
	@pSoToKhaiHaiQuan NVARCHAR(50),
	@pTYPEEXPORT NVARCHAR(50),
	@pVanchuyen NVARCHAR(50),
	@pKhachhang NVARCHAR(50),
	@pDateExport datetime
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	BEGIN TRY
        BEGIN TRANSACTION;

        DECLARE 
            @LoopPackingID VARCHAR(20),
            @LotNo VARCHAR(20),
            @Qty INT,
            @CodeExport VARCHAR(20),
            @checkMaterialLotInfo INT,
            @checkDividePackaging INT,
            @checkCreateTemFake INT,
            @checkStatusExport INT,
            @checkQty NUMERIC(20, 5),
            @QtyInWarehouse NUMERIC(20, 5),
            @Err NVARCHAR(500),
            @IsTemTo BIT = 0;

        -- Kiểm tra có phải tem to không
        IF EXISTS (SELECT 1 FROM STB_PackingOutPutFinishGoods_HN WHERE PackingOutPutFinishGoodsID = @pPackingID)
        BEGIN
            SET @IsTemTo = 1;
        END

        -- Xử lý tem to
        IF (@IsTemTo = 1)
        BEGIN
            SELECT @checkStatusExport = StatusExport 
            FROM STB_PackingOutPutFinishGoods_HN 
            WHERE PackingOutPutFinishGoodsID = @pPackingID;

            IF (@checkStatusExport = 1)
            BEGIN
                SET @Err = N'Tem thùng của bạn đã xuất kho hoặc không tồn tại: ' + @pPackingID;
                RAISERROR(@Err, 16, 1);
            END

            -- Duyệt từng tem con trong tem to
         DECLARE record_cursor CURSOR FOR
         SELECT 
             PackingID AS LoopPackingID,
             LotNo,
             CurrentQty AS Qty
         FROM STB_MaterialLotInfo
         WHERE MergeParentId = @pPackingID

         UNION ALL

        SELECT 
             PackingID AS LoopPackingID,
             LotNo,
             Qty
           FROM STB_DividePackaging
           WHERE MergeParentId = @pPackingID;

            OPEN record_cursor;
            FETCH NEXT FROM record_cursor INTO @LoopPackingID, @LotNo, @Qty;

            WHILE @@FETCH_STATUS = 0
            BEGIN
                -- Tạo mã xuất kho
                EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_VN_FINISHGOODS_HN_Export', @CodeExport OUTPUT;
                SET @CodeExport = 'EXVNHN' + @CodeExport;

                -- Kiểm tra tồn tại
                SELECT @checkMaterialLotInfo = COUNT(*) 
                FROM stb_materiallotinfo 
                WHERE PackingID = @LoopPackingID AND LotNo = @LotNo;

                SELECT @checkDividePackaging = COUNT(*) 
                FROM STB_DividePackaging 
                WHERE PackingID = @LoopPackingID;
				-- Check thêm điều kiện nếu mà chưa nhập kho thì không cho xuât kho
			    
				IF NOT EXISTS(SELECT 1 FROM STB_VN_FINISHGOODS_HN_New WHERE PackingID=@LoopPackingID and StatusImport=1)
				BEGIN
				    SET @Err = N'Packing này của bạn chưa được nhập kho: ' + @LoopPackingID;
                    RAISERROR(@Err, 16, 1);
				END
				
                SELECT 
                    @checkQty = ISNULL(packQtyOutput, 0) + @Qty,
                    @QtyInWarehouse = ISNULL(packQty, 0)
                FROM STB_VN_FINISHGOODS_HN_New 
                WHERE PackingID = @LoopPackingID AND LotNo = @LotNo;

                SELECT @checkCreateTemFake = COUNT(*) 
                FROM STB_CreateTemFakeForHaNam 
                WHERE PackingID = @LoopPackingID AND LotNo = @LotNo;

                IF (@checkDividePackaging >= 1)
                BEGIN
                    SELECT @Qty = Qty 
                    FROM STB_DividePackaging 
                    WHERE PackingID = @LoopPackingID;
                END

                IF (@checkMaterialLotInfo < 1 AND @checkDividePackaging < 1 AND @checkCreateTemFake < 1)
                BEGIN
                    SET @Err = N'Lot của bạn không có trên hệ thống: ' + @LoopPackingID;
                    RAISERROR(@Err, 16, 1);
                END

                IF (@QtyInWarehouse < @checkQty)
                BEGIN
                    SET @Err = N'Số lượng xuất kho của Packing: ' + @LoopPackingID + N' đang vượt quá tồn kho.';
                    RAISERROR(@Err, 16, 1);
                END

                -- Chèn dữ liệu xuất kho
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

                -- Cập nhật tồn kho
                UPDATE STB_VN_FINISHGOODS_HN_New
                SET packQtyOutput = ISNULL(packQtyOutput, 0) + @Qty
                WHERE PackingID = @LoopPackingID AND LotNo = @LotNo;

                FETCH NEXT FROM record_cursor INTO @LoopPackingID, @LotNo, @Qty;
            END

            CLOSE record_cursor;
            DEALLOCATE record_cursor;

            -- Đánh dấu tem to đã xuất kho
            UPDATE STB_PackingOutPutFinishGoods_HN
            SET statusExport = 1
            WHERE PackingOutPutFinishGoodsID = @pPackingID;
        END
        ELSE
        BEGIN
            -- Tem nhỏ
            SELECT @checkStatusExport = ISNULL(StatusExport, 0)
            FROM STB_VN_FINISHGOODS_HN_Export 
            WHERE PackingID = @pPackingID ;
			
			-- check điều kiện xem đã nhập kho với tem nhỏ
		   IF NOT EXISTS(SELECT 1 FROM STB_VN_FINISHGOODS_HN_New WHERE PackingID=@pPackingID and StatusImport=1)
			BEGIN
				  SET @Err = N'Packing này của bạn chưa được nhập kho: ' + @LoopPackingID;
                  RAISERROR(@Err, 16, 1);
		  END
		  
            IF @checkStatusExport = 1
            BEGIN
                SET @Err = N'Tem nhỏ đã được xuất kho: ' + @pPackingID;
                RAISERROR(@Err, 16, 1);
            END
			
			-- Trường hợp là tem chia 
			DECLARE @IsCheck BIT;
			IF EXISTS (SELECT 1 FROM STB_DividePackaging WHERE PackingID = @pPackingID)
            BEGIN
               SET @IsCheck = 1;
            END
			if(@IsCheck=1)
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
			     SELECT TOP 1 @LotNo = LotNo, @Qty = CurrentQty
                 FROM stb_materiallotinfo
                 WHERE PackingID = @pPackingID;

                  IF @LotNo IS NULL OR @Qty IS NULL
                 BEGIN
                      SET @Err = N'Tem nhỏ không có dữ liệu LotNo hoặc Qty trong bảng stb_materiallotinfo: ' + @pPackingID;
                      RAISERROR(@Err, 16, 1);
                 END

			END

            EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_VN_FINISHGOODS_HN_Export', @CodeExport OUTPUT;
            SET @CodeExport = 'EXVNHN' + @CodeExport;

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
			if( @IsCheck=1)
			BEGIN
			    DECLARE @ParentID NVARCHAR(50);
                SELECT TOP 1 @ParentID = PackingParentID
                FROM STB_DividePackaging
                WHERE PackingID = @pPackingID;

				 UPDATE STB_VN_FINISHGOODS_HN_New
                 SET packQtyOutput = ISNULL(packQtyOutput, 0) + @Qty
                 WHERE PackingID = @ParentID AND LotNo = @LotNo;
				 SELECT TOP 1 * FROM FinishGoodMESInstock_HN

				 -- Mr.Triều nếu mà là tem chia thì sẽ sẽ bắn cập nhật lại số lượng đã xuất của kho
				 -- Nếu mà không ăn thì bắt buộc phải vào bảng cập nhật tay thì số lượng tem tách mói bị trừ đi
				 UPDATE FinishGoodMESInstock_HN
				 SET QtyOutput=ISNULL(QtyOutput, 0) + @Qty
				 where PackingID=(select PackingParentID from STB_DividePackaging where PackingID=@pPackingID)
			END
			ELSE
			BEGIN
                UPDATE STB_VN_FINISHGOODS_HN_New
                SET PackQtyOutput = ISNULL(packQtyOutput, 0) + @Qty
                WHERE PackingID = @pPackingID AND LotNo = @LotNo;
			END
        END

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
         ROLLBACK TRANSACTION;

    IF CURSOR_STATUS('global', 'record_cursor') >= -1
    BEGIN
        CLOSE record_cursor;
        DEALLOCATE record_cursor;
    END

    DECLARE @ErrMsg NVARCHAR(4000) = ERROR_MESSAGE();
    RAISERROR(@ErrMsg, 16, 1);
    END CATCH

    -- Trả về dữ liệu đã xuất
    SELECT
        T2.CodeExport,
        T2.LotNo,
        T2.PackingID,
        T2.PackingID_Divide,
        T5.MergeParentID,
        T2.Qty,
        T2.Country,
        T2.SoPhieuXuatKho,
        T2.SoInVoice,
        T2.SoToKhaiHaiQuan,
        T2.TypeExport,
        T2.TRANSPORT,
        T2.CustomerName,
        T2.LevelOut,
        T2.DateRequestExport,
        T2.ChangeUserID
    FROM STB_VN_FINISHGOODS_HN_Export T2
    LEFT JOIN stb_materialLotinfo T5 WITH(NOLOCK) ON T2.PackingID = T5.PackingID
	LEFT JOIN STB_DividePackaging  T6 WITH(NOLOCK) ON T2.PackingID=T6.PackingID
    WHERE T5.MergeParentID = @pPackingID OR T2.PackingID = @pPackingID or T6.MergeParentID=@pPackingID;

END



--PKQJ2800143_02

--select * from STB_DividePackaging where PackingId='PKQJ2800143_02'

--select * from STB_VN_FINISHGOODS_HN_New where PackingId in ('PKQK1300171','PKQK1300168','PKQK1300169','PKQK1300167','PKQK1300170')

--SELECT * FROM STB_DividePackaging WHERE PackingID = 'PKQJ2800143_02'


--select * from STB_VN_FINISHGOODS_HN_New where PackingId='PKPU0900200_02'

--select * from STB_VN_FINISHGOODS_HN_Export where PackingId='PKQJ2800143_02'

GO

