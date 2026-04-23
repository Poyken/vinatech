-- =============================================
-- Author : Jeon Gyeong Ho(khjun@awoo.co.kr)
-- Group :  팝업
-- Browsable : true
-- Create date : 2018-08-27
-- Description : 문서 진행상태 팝업
-- Modified :
-- =============================================
CREATE PROCEDURE [dbo].[usp_DocStatus_popup]
	@pDocType VARCHAR(20) = NULL
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @DocType VARCHAR(20) = @pDocType

	SELECT
			DS.DocStatus,
			DS.DocStatusName
	FROM
			VW_DocStatus DS
	WHERE
			DS.DocType = @DocType
	ORDER BY
			DS.DisplayIndex
END
