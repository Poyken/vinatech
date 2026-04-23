-- =============================================
-- Author: kilee@vina.co.kr
-- Create date: 2020-05-08
-- Browsable : true
-- Group : 생산관리 > 전극측정결과 > 출력여부 Action버튼
-- Description:	
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_DoUpdateRollPressBarcodePrintYn]
						@pProcessUserID VARCHAR(20),
						@pProcessLanguage VARCHAR(20),
						@pElectrodeLotNumber VARCHAR(20)

AS
BEGIN
	SET NOCOUNT ON;

	Declare @ElectrodeLotNumber VARCHAR(20) = @pElectrodeLotNumber 
	
	UPDATE STB_ElectrodeRollPressingInfo
	   SET PrintYn = 1
	 WHERE ElectrodeLotNumber = @ElectrodeLotNumber

END


-- [라벨출력부분] 확인부분 (주석처리)
--SELECT PrintYn, * FROM STB_ElectrodeRollPressingInfo 
--WHERE PrintYn = 1
--ORDER BY CreateDateTime Desc