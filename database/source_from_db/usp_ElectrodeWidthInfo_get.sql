-- =============================================
-- Author: Yong Eun Jae(ejyong@vina.co.kr)
-- Create date: 2020.02.27
-- Browsable : true
-- Group : 
-- Description:	전극 슬리팅시 사용되는 전극 폭 정보를 가져옵니다.
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_ElectrodeWidthInfo_get]
	@pProcessUserID [varchar](20),
	@pProcessLanguage [varchar](20),
	@pElectrodeWidthLenth numeric(20,10) = 0
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @ElectrodeWidthLenth numeric(20,10) = @pElectrodeWidthLenth,
			@ElectrodeTotalWidth numeric(20,10)


	SELECT TOP 1 @ElectrodeTotalWidth = sum(ElectrodeCnt * ElectrodeWidth) FROM STB_ElectrodeWidthInfo
	where IsUsed = 1
	GROUP BY  ROLLUP ( IsUsed )

	IF @ElectrodeTotalWidth > (@ElectrodeWidthLenth + 1)
	   BEGIN
			EXEC usp_RaiseLocalizedError @pProcessLanguage, '합계길이가 총 길이를 초과하였습니다.'
			RETURN 
	  END
    
	SELECT
		   ElectrodeWidth,
		   ElectrodeCnt,
		   ElectrodeWidth*ElectrodeCnt TotalWidth
	FROM
	        STB_ElectrodeWidthInfo
	where IsUsed = 1

END
