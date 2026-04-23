CREATE PROCEDURE [dbo].[usp_VN_FinishGood_BG_ExportExcel_uid]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pProcessViewName VARCHAR(50) = null,
	@pXml NVARCHAR(MAX) = null
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @InsertTableName VARCHAR(100) = '/DataSet/' + @pProcessViewName + '_INSERT'
	DECLARE @UpdateTableName VARCHAR(100) = '/DataSet/' + @pProcessViewName + '_UPDATE'
	DECLARE @DeleteTableName VARCHAR(100) = '/DataSet/' + @pProcessViewName + '_DELETE'
	DECLARE @ERROR_MSG NVARCHAR(MAX)
	
	-- Khai báo biến
	DECLARE @IUD_FLAG VARCHAR(10), @LotNo NVARCHAR(50), @PackQty_Row INT, @Country NVARCHAR(50)
	DECLARE @SoPhieuXuatKho NVARCHAR(50), @SoInVoice NVARCHAR(50), @SoToKhaiHaiQuan NVARCHAR(50)
	DECLARE @TYPEEXPORT NVARCHAR(50), @LevelsOut NVARCHAR(50), @TRANSPORT NVARCHAR(50)
	DECLARE @CUSTOMERNAME NVARCHAR(100), @BoxQuantity int, @PalletQuantity int, @Note NVARCHAR(MAX)
    DECLARE @MethodActions1_Row NVARCHAR(50), @PO NVARCHAR(50), @HH_PN NVARCHAR(50), @Statusout NVARCHAR(50)
	
	DECLARE @iDoc INT
	EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml

	BEGIN TRY
		BEGIN TRANSACTION

		DECLARE SourceData CURSOR FOR
			SELECT 'INSERT' AS IUD_FLAG, LotNo, PackQty, Country, SoPhieuXuatKho, SoInVoice, SoToKhaiHaiQuan, TYPEEXPORT,
				   LevelsOut, TRANSPORT, CUSTOMERNAME, BoxQuantity, PalletQuantity, Note, MethodActions1, PO, HH_PN, Statusout
			FROM OPENXML(@idoc , @InsertTableName , 2) 
			WITH (LotNo NVARCHAR(50), PackQty INT, Country NVARCHAR(50), SoPhieuXuatKho NVARCHAR(50), SoInVoice NVARCHAR(50), SoToKhaiHaiQuan NVARCHAR(50), TYPEEXPORT NVARCHAR(50), LevelsOut NVARCHAR(50), TRANSPORT NVARCHAR(50), CUSTOMERNAME NVARCHAR(100), BoxQuantity int, PalletQuantity int, Note NVARCHAR(MAX), MethodActions1 NVARCHAR(50), PO NVARCHAR(50), HH_PN NVARCHAR(50), Statusout NVARCHAR(50))
			UNION ALL
			SELECT 'UPDATE' AS IUD_FLAG, LotNo, PackQty, Country, SoPhieuXuatKho, SoInVoice, SoToKhaiHaiQuan, TYPEEXPORT,
				   LevelsOut, TRANSPORT, CUSTOMERNAME, BoxQuantity, PalletQuantity, Note, MethodActions1, PO, HH_PN, Statusout
			FROM OPENXML(@idoc , @UpdateTableName , 2) 
			WITH (LotNo NVARCHAR(50), PackQty INT, Country NVARCHAR(50), SoPhieuXuatKho NVARCHAR(50), SoInVoice NVARCHAR(50), SoToKhaiHaiQuan NVARCHAR(50), TYPEEXPORT NVARCHAR(50), LevelsOut NVARCHAR(50), TRANSPORT NVARCHAR(50), CUSTOMERNAME NVARCHAR(100), BoxQuantity int, PalletQuantity int, Note NVARCHAR(MAX), MethodActions1 NVARCHAR(50), PO NVARCHAR(50), HH_PN NVARCHAR(50), Statusout NVARCHAR(50))
			UNION ALL
			SELECT 'DELETE' AS IUD_FLAG, LotNo, PackQty, Country, SoPhieuXuatKho, SoInVoice, SoToKhaiHaiQuan, TYPEEXPORT,
				   LevelsOut, TRANSPORT, CUSTOMERNAME, BoxQuantity, PalletQuantity, Note, MethodActions1, PO, HH_PN, Statusout
			FROM OPENXML(@idoc , @DeleteTableName , 2) 
			WITH (LotNo NVARCHAR(50), PackQty INT, Country NVARCHAR(50), SoPhieuXuatKho NVARCHAR(50), SoInVoice NVARCHAR(50), SoToKhaiHaiQuan NVARCHAR(50), TYPEEXPORT NVARCHAR(50), LevelsOut NVARCHAR(50), TRANSPORT NVARCHAR(50), CUSTOMERNAME NVARCHAR(100), BoxQuantity int, PalletQuantity int, Note NVARCHAR(MAX), MethodActions1 NVARCHAR(50), PO NVARCHAR(50), HH_PN NVARCHAR(50), Statusout NVARCHAR(50))

		OPEN SourceData
		FETCH NEXT FROM SourceData INTO 
    		@IUD_FLAG, @LotNo, @PackQty_Row, @Country, @SoPhieuXuatKho, @SoInVoice, @SoToKhaiHaiQuan, 
    		@TYPEEXPORT, @LevelsOut, @TRANSPORT, @CUSTOMERNAME, @BoxQuantity, @PalletQuantity, 
    		@Note, @MethodActions1_Row, @PO, @HH_PN, @Statusout

		WHILE @@FETCH_STATUS = 0 
		BEGIN
			SET @LotNo = LTRIM(RTRIM(@LotNo))

			IF @IUD_FLAG = 'INSERT' OR @IUD_FLAG = 'UPDATE'
			BEGIN
				-- Kiểm tra LotNo có tồn tại không
				IF NOT EXISTS (SELECT 1 FROM STB_VN_FINISHGOODS_BG_Test_20251225 WHERE LotNo = @LotNo)
				BEGIN
					RAISERROR(N'Lot %s chưa được nhập kho, vui lòng kiểm tra lại', 16, 1, @LotNo)
				END

				-- Kiểm tra LotNo đã xuất chưa
				--IF EXISTS (
    --            	SELECT 1 
    --               	FROM STB_VN_FINISHGOODS_BG_Test_20251225 
    --             	WHERE LotNo = @LotNo AND Statusout IS NOT NULL
    --             )
				--BEGIN
				--	RAISERROR(N'Lot %s này đã được xuất kho, vui lòng kiểm tra lại', 16, 1, @LotNo)
				--END


				UPDATE STB_VN_FINISHGOODS_BG_Test_20251225
				SET
					PackQty = ISNULL(@PackQty_Row, PackQty),
					Country = ISNULL(@Country, Country),
					SoPhieuXuatKho = ISNULL(@SoPhieuXuatKho, SoPhieuXuatKho),
					SoInVoice = ISNULL(@SoInVoice, SoInVoice),
					SoToKhaiHaiQuan = ISNULL(@SoToKhaiHaiQuan, SoToKhaiHaiQuan),
					TYPEEXPORT = ISNULL(@TYPEEXPORT, TYPEEXPORT),
					LevelsOut = ISNULL(@LevelsOut, LevelsOut),
					TRANSPORT = ISNULL(@TRANSPORT, TRANSPORT),
					CUSTOMERNAME = ISNULL(@CUSTOMERNAME, CUSTOMERNAME),
					PersonExport = @pProcessUserID,
					DateExport = GETDATE(),
					BoxQuantity = ISNULL(@BoxQuantity, BoxQuantity),
					PalletQuantity = ISNULL(@PalletQuantity, PalletQuantity),
					Note = ISNULL(@Note, Note),
					MethodActions1 = ISNULL(@MethodActions1_Row, N'Xuất bằng file excel'), 
					PO = ISNULL(@PO, PO),
					HH_PN = ISNULL(@HH_PN, HH_PN),
					Statusout = ISNULL(@Statusout, N'Xuất') 
				WHERE LotNo = @LotNo
			END 
			ELSE IF @IUD_FLAG = 'DELETE' 
			BEGIN
				DELETE FROM STB_VN_FINISHGOODS_BG_Test_20251225 WHERE LotNo = @LotNo
			END

			FETCH NEXT FROM SourceData INTO 
        	@IUD_FLAG, @LotNo, @PackQty_Row, @Country, @SoPhieuXuatKho, @SoInVoice, @SoToKhaiHaiQuan, 
        	@TYPEEXPORT, @LevelsOut, @TRANSPORT, @CUSTOMERNAME, @BoxQuantity, @PalletQuantity, 
        	@Note, @MethodActions1_Row, @PO, @HH_PN, @Statusout
		END

		CLOSE SourceData;
		DEALLOCATE SourceData;

		COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
		IF CURSOR_STATUS('global','SourceData') >= 0 BEGIN CLOSE SourceData; DEALLOCATE SourceData; END

		SET @ERROR_MSG = ERROR_MESSAGE()
		RAISERROR(@ERROR_MSG, 16, 1)
	END CATCH
		
	EXEC sp_xml_removedocument @idoc	
END