
CREATE PROC [dbo].[usp_VN_finished_waiting]
@pProcessUserID VARCHAR(20)
as
BEGIN

 DECLARE @ProcessUserID VARCHAR(20) = @pProcessUserID

 IF @ProcessUserID = 'nguyentha' OR @ProcessUserID = 'nguyennha'

 BEGIN

 SELECT 
				ID,
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
				Statusout,
				Country,
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
				LevelsOut,
				INPUTFROM,
				TYPEEXPORT,
				LOCATIONS,
				LoaiHinhToKhai,
				TRANSPORT,
				CUSTOMERNAME,
				CODELOCATION,

				CASE
						WHEN STATUSISSUE IS NULL THEN N'Chưa xác nhận'

				ELSE '' 

				END AS STATUSISSUE
				
		FROM
		
			STB_VN_FINISHGOODS_WAITING WITH(NOLOCK)
		
		WHERE

			STATUSISSUE IS NULL OR  STATUSISSUE = '' AND Country = N'Bắc Giang'
 END

 ELSE IF  @ProcessUserID = 'nguyennha' OR @ProcessUserID ='Duy' OR @ProcessUserID = 'Duongba' OR @ProcessUserID = 'duonghoa'

 BEGIN

 SELECT 
				ID,
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
				Statusout,
				Country,
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
				LevelsOut,
				INPUTFROM,
				TYPEEXPORT,
				LOCATIONS,
				LoaiHinhToKhai,
				TRANSPORT,
				CUSTOMERNAME,
				CODELOCATION,

				CASE
						WHEN STATUSISSUE IS NULL THEN N'Chưa xác nhận'

				ELSE '' 

				END AS STATUSISSUE
				
		FROM
		
			STB_VN_FINISHGOODS_WAITING WITH(NOLOCK)
		
		WHERE

			STATUSISSUE IS NULL OR STATUSISSUE = '' AND Country = N'Bắc Ninh'
 END

 ELSE
 BEGIN
		PRINT N'We do not understand Fu...'
 END
		
END


--SELECT * FROM STB_VN_FINISHGOODS_WAITING