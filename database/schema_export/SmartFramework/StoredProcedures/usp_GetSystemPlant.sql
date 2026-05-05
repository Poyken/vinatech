-- Procedure: usp_GetSystemPlant




-- =============================================
-- Author:		Park Jong Seob(jspark@awoo.co.kr)
-- Create date: 2016.10.17
-- Description:	System PLANT 정보를 가져옵니다.
-- =============================================
CREATE PROCEDURE [dbo].[usp_GetSystemPlant]
AS
BEGIN
		SELECT
				BC.ItemCode AS SystemCode
		FROM
				STB_BaseCode BC WITH (NOLOCK)
		WHERE
				BC.CodeGroup = 'SYSTEMCODE'

END





GO

