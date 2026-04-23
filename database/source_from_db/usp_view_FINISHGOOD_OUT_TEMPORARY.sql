CREATE PROC  [dbo].[usp_view_FINISHGOOD_OUT_TEMPORARY]
@CREATEUSERID NVARCHAR(50)
AS
BEGIN
		SELECT 
												IDFG,
											    PACKINGID,
												LOTNO,
												MATERIALCODE,
												MATERIALNAME,
												PACKQTY,
												PARTNO,
												PUBLICCODE,
												TYPEPRODUCTION,
												PRODUCTIONSIZE,
												CREATEUSERID,
												
											CASE 
											WHEN STATUSPRINTER IS NULL THEN N'Chưa in tem QR to'
											WHEN STATUSPRINTER IS NOT NULL THEN N'Đã in tem QR to'
											ELSE  ''
											END 'STATUSPRINTER',

											CASE 
											WHEN STATUSIN = 1 THEN N'Đã nhập vào kho tạm'
											ELSE ''
											END  'STATUSIN',

											CASE 
											WHEN STATUSOUT IS NULL THEN N'Đang chờ bế lên công te lơ'
											WHEN STATUSOUT IS NOT NULL THEN N'Đã được bế lên công te lơ'
											ELSE ''
											END 'STATUSOUT'
										
		FROM  STB_VN_FINISHGOOD_OUT_TEMPORARY WITH(NOLOCK)
		WHERE STATUSOUT IS NULL AND  GROUPID IS  NULL AND CREATEUSERID = @CREATEUSERID
END