-- =============================================
-- Author : Jeon Gyeong Ho(khjun@awoo.co.kr)
-- Group :  팝업
-- Browsable : true
-- Create date : 2018-08-27
-- Description : 수불유형 팝업
-- Modified :
-- =============================================
CREATE PROCEDURE [dbo].[usp_DocType_popup]
AS
BEGIN
	SET NOCOUNT ON;

	SELECT
			DT.DocType,
			DT.DocTypeName
	FROM
			VW_DocType DT
END
