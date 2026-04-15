-- ============================================================
-- PATCH: Lưu nhiều mã barcode NVL trên cùng 1 lot sản phẩm
-- Author : Mr.Duc (EA Team) - 2026-04-14
-- Tiền lệ: Mr.Tung - line 208-209 (ghép chuỗi vào @RawMaterialBarcode trước UPDATE)
-- ============================================================
-- CÁCH SỬA: Mở SP [usp_Vietnam_RawMaterialInputHist_uid] trong SSMS
--           Tìm đoạn "END -- END BG@" (gần cuối SP)
--           Thêm 6 dòng bên dưới VÀO GIỮA dòng "END -- END BG@" và dòng "UPDATE STB_RawMaterialInputHist"
-- ============================================================

-- ====== TÌM ĐOẠN NÀY TRONG SP (khoảng dòng 2940-2943): ======

/*  <-- XÓA DẤU COMMENT NÀY KHI ĐỌC
END		-- END BG@
			                         <-- THÊM CODE MỚI VÀO ĐÂY
		UPDATE STB_RawMaterialInputHist
*/  <-- XÓA DẤU COMMENT NÀY KHI ĐỌC


-- ====== CODE CẦN THÊM VÀO (6 dòng): ======

		-- Mr.Duc EA 2026-04-14 - Lưu nhiều mã barcode NVL trên cùng 1 lot sản phẩm
		-- Tiền lệ: Mr.Tung dùng cùng pattern tại line 208-209: set @RawMaterialBarcode = <cũ> +' ; '+ <mới>
		DECLARE @existingRawBarcode NVARCHAR(200) = ''
		SELECT @existingRawBarcode = ISNULL(RawMaterialBarcode, '') FROM STB_RawMaterialInputHist WITH(NOLOCK) WHERE RawMaterialInputHistNo = @pRawMaterialInputHistNo
		IF @existingRawBarcode <> '' AND CHARINDEX(ISNULL(@RawMaterialBarcode, ''), @existingRawBarcode) = 0
			SET @RawMaterialBarcode = @existingRawBarcode + ' ; ' + ISNULL(@RawMaterialBarcode, '')
		-- End Mr.Duc


-- ====== SAU ĐÓ UPDATE GIỮ NGUYÊN HOÀN TOÀN (không sửa gì): ======
/*
		UPDATE STB_RawMaterialInputHist
			SET
				RawMaterialInputHistNo =   ISNULL(@pRawMaterialInputHistNo,RawMaterialInputHistNo),
				Barcode =   ISNULL(@pBarcode,@pBarcode),
				ProductGroupCode =   ISNULL(@pProductGroupCode,ProductGroupCode),
				RawMaterialBarcode =   ISNULL(@RawMaterialBarcode,RawMaterialBarcode),
				LotMaterialCode =  ISNULL(@LotMaterialBarcode,@LotMaterialBarcode),
				CreateDateTime =   ISNULL(CreateDateTime,@pCreateDateTime),
				CreateUserID =   ISNULL(CreateUserID,@pProcessUserID),
				ChangeDateTime = GETDATE(),
				ChangeUserID = @pProcessUserID
		WHERE   RawMaterialInputHistNo = @pRawMaterialInputHistNo
*/
