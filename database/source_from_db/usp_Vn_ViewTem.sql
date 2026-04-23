CREATE PROC [dbo].[usp_Vn_ViewTem]
@pProcessUserID VARCHAR(20),
@pProcessLanguage VARCHAR(20)
AS
BEGIN
		SELECT 
				IDCODE,
				PackingID,
				LotNo,
				MaterialCode,
				MaterialName,
				PackQty,
				PartNo,
				Statusout,
				DateExport,
				PersonExport,
				MethodActions1,
				'' AS Updates

		FROM 
				STB_VN_FINISHGOODS WITH(NOLOCK)

		WHERE
				Statusout = N'Xuất vào kho tạm, chờ xuất'

		ORDER BY DateExport DESC
END

--select * from STB_VN_FINISHGOODS where MethodActions1 = N'Xuất bằng scan barcode'