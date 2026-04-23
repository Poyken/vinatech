CREATE PROC usp_VN_scanout 
@IDCODE NVARCHAR(50),
@PersonExport NVARCHAR(50)
AS
BEGIN
		UPDATE STB_VN_FINISHGOODS
		SET
			Statusout = N'Xuất vào kho tạm, chờ xuất',
			MethodActions1 = N'Xuất bằng scan barcode',
			DateExport = DATEADD(HH, -2, GETDATE()),
			PersonExport =  @PersonExport
		WHERE
				IDCODE = @IDCODE
			
END

-- SELECT * FROM STB_VN_FINISHGOODS
-- exec usp_VN_scanout 'FGVN202110230708441790054734','Nha'