-- Procedure: ImportWarehouseFinshGood_uid
-- =============================================
-- Author:		Nguyễn Hải Triều
-- Create date: 2025-06-25
-- Description:	Nhập kho với tem nhỏ kho thành phẩm và với tem túi bóng
-- Test chay exec ImportWarehouseFinshGood_uid 'HaiTrieu','vi','pkpo1200278','P01','GH79623654','S01','','2025-06-27'
-- =============================================
CREATE PROCEDURE [dbo].[ImportWarehouseFinshGood_uid]
	-- Add the parameters for the stored procedure here
	@pProcessUserID VARCHAR(20),
    @pProcessLanguage VARCHAR(20),
	@pPackingID NVARCHAR(50)=NULL, -- PackingID của tem nhỏ
	@pTYPEINPUT NVARCHAR(50)=NULL, -- Kiểu nhập kho 
	@pPublicCode NVARCHAR(50)=NULL, -- Mã kế toán
	@pSoPhieuNhapKho NVARCHAR(50)=NULL, --
	@pLocations NVARCHAR(50)=NULL,
	@pDateImport datetime
AS
BEGIN

	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	BEGIN TRY
		BEGIN TRANSACTION;

		DECLARE 
			@IDCODE VARCHAR(50),
			@LotNo VARCHAR(50),
			@Qty INT,
			@Error_Message NVARCHAR(200),
			@CheckMaterialInfo INT,
			@CheckStatusImport INT,
			@vPackingID NVARCHAR(50),
			@vTypeInput NVARCHAR(50),
			@vPublicCode NVARCHAR(50),
			@vSoPhieuNhapKho NVARCHAR(50),
			@vLocations NVARCHAR(50),
			@vDateImport DATETIME,
			@IsTuiBong INT = 0;
			-- thêm điều kiện kiểm tra nếu chưa được qc pass thì sẽ k chó nhập kho

		SET @vPackingID      = @pPackingID;
		SET @vTypeInput      = @pTYPEINPUT;
		SET @vPublicCode     = @pPublicCode;
		SET @vSoPhieuNhapKho = @pSoPhieuNhapKho;
		SET @vLocations      = @pLocations;
		SET @vDateImport     = @pDateImport;

		-- Kiểm tra nếu là túi bóng (tức là mã được gộp)
		IF EXISTS (SELECT 1 FROM stb_materiallotinfo WHERE MergeNilonToSmallBox = @vPackingID or MergePackingId=@vPackingID)
		BEGIN
			SET @IsTuiBong = 1;
		END
		-- Xử lý nếu là túi bóng
		IF @IsTuiBong = 1
		BEGIN
			DECLARE @PackingID_Temp NVARCHAR(50);

			DECLARE packing_cursor CURSOR FOR
			SELECT PackingID FROM stb_materiallotinfo WHERE MergeNilonToSmallBox = @vPackingID OR MergePackingId=@vPackingID
			union all
			SELECT PackingID FROM STB_DividePackaging WHERE MergeNilonToSmallBox = @vPackingID
			OPEN packing_cursor;


			FETCH NEXT FROM packing_cursor INTO @PackingID_Temp;

			WHILE @@FETCH_STATUS = 0
			BEGIN
				-- Kiểm tra đã nhập chưa
				SELECT @CheckStatusImport = StatusImport 
				FROM STB_VN_FINISHGOODS_HN_New 
				WHERE PackingID = @PackingID_Temp;

				IF @CheckStatusImport = 1
				BEGIN
					SET @Error_Message = N'Tem nhỏ đã được nhập kho (thuộc túi bóng): ' + @PackingID_Temp;
					RAISERROR(@Error_Message, 16, 1);
					RETURN;
				END
				DECLARE @IsDivided1 BIT;
				IF EXISTS (SELECT 1 FROM STB_DividePackaging WHERE PackingID = @PackingID_Temp)
                BEGIN
                  SET @IsDivided1 = 1; -- Đánh dấu là Tem tách
                END

		       IF @IsDivided1 = 1
               BEGIN
            -- Lấy từ bảng Tem Tách
                   SELECT TOP 1 @LotNo = LotNo, @Qty = Qty -- Nhớ check lại tên cột Qty/Quantity ở bảng này
                   FROM STB_DividePackaging
                WHERE PackingID = @PackingID_Temp;
               END
               ELSE
               BEGIN
                  -- Lấy từ bảng Tem Thường (stb_materiallotinfo)
                    SELECT TOP 1 @LotNo = LotNo, @Qty = CurrentQty
                    FROM stb_materiallotinfo
                    WHERE PackingID = @PackingID_Temp;
               END


				
				-- Tạo ID mới
				EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_VN_FINISHGOODS_HN_New', @IDCODE OUTPUT;
				SET @IDCODE = 'FGVN_HN' + @IDCODE;

				-- Insert
				INSERT INTO STB_VN_FINISHGOODS_HN_New(
					IDCODE, PackingID, PackingNilonToBoxSmallID, Lotno, PackQty, PublicCode,
					SoPhieuNhapKho, Locations, TypeInput,
					CreateDateTime, CreateUserID, StatusImport
				)
				VALUES (
					@IDCODE, @PackingID_Temp, @vPackingID, @LotNo, @Qty, @vPublicCode,
					@vSoPhieuNhapKho, @vLocations, @vTypeInput,
					GETDATE(), @pProcessUserID, 1
				);

				FETCH NEXT FROM packing_cursor INTO @PackingID_Temp;
			END

			CLOSE packing_cursor;
			DEALLOCATE packing_cursor;
		END
		ELSE
		BEGIN

			DECLARE @IsDivided BIT;
			 IF EXISTS (SELECT 1 FROM STB_DividePackaging WHERE PackingID = @vPackingID)
                SET @IsDivided = 1;
            IF(@IsDivided=1)
			BEGIN
			      SELECT @CheckStatusImport = StatusImport 
			      FROM STB_VN_FINISHGOODS_HN_New 
			      WHERE PackingID = @vPackingID;

			      IF @CheckStatusImport = 1
			   BEGIN
				  SET @Error_Message = N'Tem nhỏ đã được nhập kho: ' + @vPackingID;
				  RAISERROR(@Error_Message, 16, 1);
				  RETURN;
			   END
			   -- Mr.Triều thêm trường hợp là tem tách nhưng mà không gộp
			    SELECT TOP 1 @LotNo = LotNo, @Qty = Qty
			    FROM STB_DividePackaging
			    WHERE PackingID = @vPackingID or MergeNilonToSmallBox=@vPackingID;
			
			    EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_VN_FINISHGOODS_HN_New', @IDCODE OUTPUT;
			    SET @IDCODE = 'FGVN_HN' + @IDCODE;

			    INSERT INTO STB_VN_FINISHGOODS_HN_New(
				   IDCODE, PackingID, Lotno, PackQty, PublicCode,
				   SoPhieuNhapKho, Locations, TypeInput,
				   CreateDateTime, CreateUserID, StatusImport
			   )
			   VALUES (
				  @IDCODE, @vPackingID, @LotNo, @Qty, @vPublicCode,
				  @vSoPhieuNhapKho, @vLocations, @vTypeInput,
				  GETDATE(), @pProcessUserID, 1
			  );
			 
			   END
			ELSE
			BEGIN

			   SELECT @CheckStatusImport = StatusImport 
			   FROM STB_VN_FINISHGOODS_HN_New 
			   WHERE PackingID = @vPackingID;

			   IF @CheckStatusImport = 1
			   BEGIN
				  SET @Error_Message = N'Tem nhỏ đã được nhập kho: ' + @vPackingID;
				  RAISERROR(@Error_Message, 16, 1);
				  RETURN;
			   END
			  

			   SELECT TOP 1 @LotNo = LotNo, @Qty = CurrentQty
			   FROM stb_materiallotinfo
			   WHERE PackingID = @vPackingID;
			/*
			SELECT @CheckMaterialInfo = COUNT(1)
			FROM stb_materiallotinfo
			WHERE PackingID = @vPackingID;

			IF @CheckMaterialInfo < 1
			BEGIN
				SET @Error_Message = N'Tem nhỏ không tồn tại: ' + ISNULL(@vPackingID, '(null)');
				RAISERROR(@Error_Message, 16, 1);
				RETURN;
			END
			*/
			EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_VN_FINISHGOODS_HN_New', @IDCODE OUTPUT;
			SET @IDCODE = 'FGVN_HN' + @IDCODE;

			INSERT INTO STB_VN_FINISHGOODS_HN_New(
				IDCODE, PackingID, Lotno, PackQty, PublicCode,
				SoPhieuNhapKho, Locations, TypeInput,
				CreateDateTime, CreateUserID, StatusImport
			)
			VALUES (
				@IDCODE, @vPackingID, @LotNo, @Qty, @vPublicCode,
				@vSoPhieuNhapKho, @vLocations, @vTypeInput,
				GETDATE(), @pProcessUserID, 1
			);
		  END
		END
		COMMIT TRANSACTION;
	END TRY
	BEGIN CATCH
		DECLARE @ErrMsg NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrMsg, 16, 1);
	END CATCH;

	-- Trả kết quả nhập thành công
	SELECT DISTINCT
		T3.IDCODE,
		T3.PackingID,
		T3.PackingNilonToBoxSmallID,
		T3.LotNo,
		T5.MaterialCode,
		T6.MaterialName,
		b.MarkingName,
		T3.PackQty,
		T3.PublicCode, 
		T3.SoPhieuNhapKho,
		T3.WorkCenterCode,
		T3.CreateDateTime AS CreateDateIn,
		T3.Locations,
		T3.TypeInput,
		T3.CreateUserID,
		T3.CreateDateTime
	FROM STB_VN_FINISHGOODS_HN_New T3 WITH(NOLOCK)
	LEFT JOIN stb_materialLotinfo T5 WITH(NOLOCK) ON LEFT(T3.PackingID, CHARINDEX('_', T3.PackingID + '_') - 1)  = T5.PackingID
	LEFT JOIN STB_CreateMarkingLetterAndQtyForBarcode b WITH(NOLOCK) ON  b.MarkingCode = T5.MarkingCode
	LEFT JOIN STB_MaterialMaster T6 WITH(NOLOCK) ON T5.MaterialCode = T6.MaterialCode
	LEFT JOIN STB_DividePackaging  T7 WITH(NOLOCK) ON T3.PackingID=T7.PackingID
    WHERE T3.PackingID = @vPackingID OR T3.PackingNilonToBoxSmallID = @vPackingID or T7.MergeNilonToSmallBox=@pPackingID;
	
END



GO

