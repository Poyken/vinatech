-- Procedure: usp_DPI_get


-- =============================================
-- Author:	    Park Jong Seob(jspark@awoo.co.kr)
-- Create date: 2016-05-29
-- Browsable : true
-- Group : 라벨정보
-- Description:	DPI 정보를 가져옵니다.
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_DPI_get]
AS
BEGIN
	SET NOCOUNT ON;

    
	SELECT
			D.Dpi
	FROM
			VW_DPI D WITH(NOLOCK)

END



GO

