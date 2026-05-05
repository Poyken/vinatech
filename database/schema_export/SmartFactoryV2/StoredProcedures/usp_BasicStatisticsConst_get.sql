-- Procedure: usp_BasicStatisticsConst_get
-- =============================================
-- Author:	    Park Jong Seob(jspark@awoo.co.kr)
-- Create date: 2018-02-23
-- Browsable : true
-- Group : Statistics
-- Description:	Sample에 따른 통계상수정보를 가져옵니다.
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_BasicStatisticsConst_get]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20)
AS
BEGIN
	SET NOCOUNT ON;

    
	SELECT
			BSC.SampleSize AS OldSampleSize,
			BSC.SampleSize,
			BSC.A2,
			BSC.A3,
			BSC.D2,
			BSC.D3,
			BSC.D4,
			BSC.B3,
			BSC.B4
	FROM
			STB_BasicStatisticsConst BSC WITH(NOLOCK)
	ORDER BY
			BSC.SampleSize
END

GO

