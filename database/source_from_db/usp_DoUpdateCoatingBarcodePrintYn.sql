-- =============================================
-- Author: kilee@vina.co.kr
-- Create date: 2020-05-08
-- Browsable : true
-- Group : 생산관리 > 전극측정결과 > 출력여부 Action버튼
-- Description:	
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_DoUpdateCoatingBarcodePrintYn]
						@pProcessUserID VARCHAR(20),
						@pProcessLanguage VARCHAR(20),
						@pElectrodeLotNumber VARCHAR(20)
AS
BEGIN
	SET NOCOUNT ON;

	Declare @ElectrodeLotNumber VARCHAR(20) = @pElectrodeLotNumber 
	
	UPDATE STB_ElectrodeCoatingInfo
	   SET PrintYn = 1
	 WHERE ElectrodeLotNumber = @ElectrodeLotNumber
END



-- TEST :   SELECT PrintYN FROM STB_ElectrodeCoatingInfo WHERE ElectrodeLotNumber = 'VJKL2320001E21'