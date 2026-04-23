-- =============================================
-- Author: Yong Eun Jae(ejyong@vina.co.kr)
-- Create date: 2020.02.27
-- Browsable : true
-- Group : 
-- Description:	전극 슬리팅시 사용되는 전극 폭 기본정보를 가져옵니다.
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_ElectrodeWidthBaseInfo_get]
	@pProcessUserID [varchar](20),
	@pProcessLanguage [varchar](20)
AS
BEGIN
	SET NOCOUNT ON;

	SELECT
		   ElectrodeWidth,
		   ElectrodeCnt,
		   IsUsed
	FROM
	        STB_ElectrodeWidthInfo
END
