-- Procedure: usp_ProdSnType_popup

-- =============================================
-- Author:		Park Jong Seob(jspark@awoo.co.kr)
-- Create date: 2016-07-10
-- Browsable : true
-- Group : 라벨정보
-- Description:	제품라벨 체번 규칙을 가져옵니다.(Popup용)
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_ProdSnType_popup]
AS
BEGIN
		SELECT
				ProdSnType
		FROM
				VW_ProdSnRule
END



GO

