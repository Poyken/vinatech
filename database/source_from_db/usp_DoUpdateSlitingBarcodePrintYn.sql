-- =============================================
-- Author: kilee@vina.co.kr
-- Create date: 2020-06-17
-- Browsable : true
-- Group : 생산관리 > 전극측정결과 > 슬리팅Menu 라벨출력시 업데이트문 3번째
-- Description:	
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_DoUpdateSlitingBarcodePrintYn]
						@pProcessUserID VARCHAR(20),
						@pProcessLanguage VARCHAR(20),
						@pElectrodeLotNumber VARCHAR(20) = Null

AS
BEGIN
	SET NOCOUNT ON;

	Declare @ElectrodeLotNumber VARCHAR(20) = @pElectrodeLotNumber 
	
	UPDATE STB_ElectrodeSlittingInfo
	     SET PrintYn = 1
	 WHERE ElectrodeLotNumber = @ElectrodeLotNumber
END

/*
-- [라벨출력부분] 확인부분 (주석처리)
--SELECT * FROM STB_ElectrodeSlittingInfo
--WHERE PrintYn = 1
----ORDER BY CreateDateTime Desc

-- select * from STB_ElectrodeRollPressingInfo
*/