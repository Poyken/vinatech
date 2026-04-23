CREATE PROC [dbo].[usp_VN_Update_tem]
	@pProcessLanguage VARCHAR(20),
	@pProcessUserID VARCHAR(20),
	@pID NVARCHAR(30),
	@pCountry NVARCHAR(30)
AS
BEGIN

SET NOCOUNT ON;


    DECLARE @ProcessLanguage VARCHAR(20) = @pProcessLanguage,
			@ProcessUserID VARCHAR(20) = @pProcessUserID,
			@ID VARCHAR(20) = @pID,
			@COUNTRY NVARCHAR(30) = @pCountry

IF @COUNTRY = N'Bắc Giang'

	BEGIN
		 
			INSERT INTO STB_VN_FINISHGOODS_BG
			(
				IDCODE,
				PackingID,
				LotNo,
				MaterialCode,
				MaterialName,
				PackQty,
				EmpNo,
				CreatDatePacked,
				PartNo,
				PublicCode,
				ProductionSize,
				TypeProduction,
				StatusSystem,
				CreateDate,
				USERID,
				CreateDateChange,
				USERIDChange,
				PersonExport,
				DateExport,
				MethodActions,
				MethodActions1,
				Flag,
				Descrption,
				SoPhieuNhapKho,
				SoPhieuXuatKho,
				SoInVoice,
				SoToKhaiHaiQuan,
				ISUSED_IMPORTS,
				ISUSED_EXPORT,
				Levels,
				INPUTFROM,
				LOCATIONS,
				LoaiHinhToKhai,
				TRANSPORT,
				CUSTOMERNAME,
				CODELOCATION
			)

			SELECT
					IDCODE,
				PackingID,
				LotNo,
				MaterialCode,
				MaterialName,
				PackQty,
				EmpNo,
				CreatDatePacked,
				PartNo,
				PublicCode,
				ProductionSize,
				TypeProduction,
				StatusSystem,
				CreateDate,
				N'Bắc Ninh',
				CreateDateChange,
				USERIDChange,
				PersonExport,
				DateExport,
				MethodActions,
				MethodActions1,
				Flag,
				Descrption,
				SoPhieuNhapKho,
				SoPhieuXuatKho,
				SoInVoice,
				SoToKhaiHaiQuan,
				ISUSED_IMPORTS,
				ISUSED_EXPORT,
				Levels,
				INPUTFROM,
				LOCATIONS,
				LoaiHinhToKhai,
				TRANSPORT,
				CUSTOMERNAME,
				CODELOCATION
			FROM
					STB_VN_FINISHGOODS_WAITING
			WHERE
					ID = @ID AND @COUNTRY = N'Bắc Giang' AND STATUSISSUE IS NULL

		UPDATE STB_VN_FINISHGOODS_WAITING

			SET	

				STATUSISSUE = 1,
				CREATETRANSFERBY = @ProcessUserID,
				CREATEDATETRANSFER = DATEADD(HH, -2, GETDATE())

			WHERE
					ID = @ID
					
	END

ELSE
	
	BEGIN
			INSERT INTO STB_VN_FINISHGOODS
			(
				IDCODE,
				PackingID,
				LotNo,
				MaterialCode,
				MaterialName,
				PackQty,
				EmpNo,
				CreatDatePacked,
				PartNo,
				PublicCode,
				ProductionSize,
				TypeProduction,
				StatusSystem,
				CreateDate,
				USERID,
				CreateDateChange,
				USERIDChange,
				PersonExport,
				DateExport,
				MethodActions,
				MethodActions1,
				Flag,
				Descrption,
				SoPhieuNhapKho,
				SoPhieuXuatKho,
				SoInVoice,
				SoToKhaiHaiQuan,
				ISUSED_IMPORTS,
				ISUSED_EXPORT,
				Levels,
				INPUTFROM,
				LOCATIONS,
				LoaiHinhToKhai,
				TRANSPORT,
				CUSTOMERNAME,
				CODELOCATION
			)

			SELECT
				IDCODE,
				PackingID,
				LotNo,
				MaterialCode,
				MaterialName,
				PackQty,
				EmpNo,
				CreatDatePacked,
				PartNo,
				PublicCode,
				ProductionSize,
				TypeProduction,
				StatusSystem,
				CreateDate,
				N'Bắc Giang',
				CreateDateChange,
				USERIDChange,
				PersonExport,
				DateExport,
				MethodActions,
				MethodActions1,
				Flag,
				Descrption,
				SoPhieuNhapKho,
				SoPhieuXuatKho,
				SoInVoice,
				SoToKhaiHaiQuan,
				ISUSED_IMPORTS,
				ISUSED_EXPORT,
				Levels,
				INPUTFROM,
				LOCATIONS,
				LoaiHinhToKhai,
				TRANSPORT,
				CUSTOMERNAME,
				CODELOCATION
			FROM
					STB_VN_FINISHGOODS_WAITING
			WHERE
					ID = @ID AND @COUNTRY = N'Bắc Ninh' AND STATUSISSUE IS NULL

		UPDATE STB_VN_FINISHGOODS_WAITING

			SET	

				STATUSISSUE = 1,
				CREATETRANSFERBY = @ProcessUserID,
				CREATEDATETRANSFER = DATEADD(HH, -2, GETDATE())

			WHERE
					ID = @ID
	END

END

--SELECT * FROM DELETE STB_VN_FINISHGOODS_WAITING

--  select TOP(1000)* from STB_VN_FINISHGOODS WHERE TYPEEXPORT IS NOT NULL


--ALTER TABLE STB_VN_FINISHGOODS_BG
--ADD
	
