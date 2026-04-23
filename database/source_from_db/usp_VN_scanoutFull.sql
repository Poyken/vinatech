CREATE PROC [dbo].[usp_VN_scanoutFull] 
@pIDCODE NVARCHAR(50),
@pProcessUserID VARCHAR(20)

AS
BEGIN

		UPDATE STB_VN_FINISHGOODS
		SET
			Statusout = N'Xuất',
			MethodActions1 = N'Xuất bằng scan barcode',
			DateExport = DATEADD(HH, -2, GETDATE()),
			PersonExport =  @pProcessUserID
		WHERE
				IDCODE = @pIDCODE
			
END