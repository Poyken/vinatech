-- Procedure: usp_CommandType_get


-- =============================================
-- Author:	    Park Jong Seob(jspark@awoo.co.kr)
-- Create date: 2016-05-29
-- Browsable : true
-- Group : 라벨정보
-- Description:	CommandType 정보를 가져옵니다.
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_CommandType_get]
AS
BEGIN
	SET NOCOUNT ON;

    
	SELECT
			CT.CommandType
	FROM
			VW_CommandType CT WITH(NOLOCK)

END



GO

