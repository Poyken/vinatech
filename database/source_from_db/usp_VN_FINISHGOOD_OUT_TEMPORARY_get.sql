-- =============================================
-- Author:		DinhManh
-- Create date: 2025-02-13
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[usp_VN_FINISHGOOD_OUT_TEMPORARY_get]
	-- Add the parameters for the stored procedure here
						@pProcessUserID VARCHAR(20),
						@pProcessLanguage VARCHAR(20)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT
			*,
			CASE 
				WHEN STATUSPRINTER IS NULL THEN N'Chưa in tem QR to'
				WHEN STATUSPRINTER IS NOT NULL THEN N'Đã in tem QR to'
				ELSE  ''
			END AS 'STATUSPRINTER',

			CASE 
				WHEN STATUSIN = 1 THEN N'Đã nhập vào kho tạm'
				ELSE ''
			END AS 'STATUSIN',

			CASE 
				WHEN STATUSOUT IS NULL THEN N'Đang chờ bế lên công te lơ'
				WHEN STATUSOUT IS NOT NULL THEN N'Đã được bế lên công te lơ'
				ELSE ''
			END AS 'STATUSOUT'
	FROM 
		STB_VN_FINISHGOOD_OUT_TEMPORARY
	WHERE 
		STATUSIN = '1' AND 
		STATUSOUT IS NULL
END
