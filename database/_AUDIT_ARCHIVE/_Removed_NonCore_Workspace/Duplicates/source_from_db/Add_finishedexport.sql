create proc Add_finishedexport
@IDCODE NVARCHAR(50),
@COUNTRY NVARCHAR(50),
@SOPHIEUXUAT NVARCHAR(50),
@SOINVOICE NVARCHAR(50),
@SOTOKHAIHAIQUAN NVARCHAR(50),
@KIEUXUAT NVARCHAR(50),
@DATEEXPORT NVARCHAR(50)
as
begin
		UPDATE STB_VN_FINISHGOODS
		SET
				Country = @COUNTRY,
				SoPhieuXuatKho = @SOPHIEUXUAT,
				SoInVoice = @SOINVOICE,
				SoToKhaiHaiQuan = @SOTOKHAIHAIQUAN,
				TYPEEXPORT = @KIEUXUAT,
				DateExport = @DATEEXPORT,
				MethodActions1 = N'Xuất bằng file excel',
				Statusout = N'Xuất',
				PersonExport = 'nguyentha'
		WHERE IDCODE = @IDCODE
end