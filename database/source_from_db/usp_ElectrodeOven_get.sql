-- =============================================
-- Author: Jackaroe (yjyu@vina.co.kr)
-- Create date: 2019-01-20
-- Browsable : true
-- Group : 생산관리
-- Description:	전극레시피오븐정보조회
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_ElectrodeOven_get]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pProdCode VARCHAR(20) = NULL

AS
BEGIN
	SET NOCOUNT ON;
	
	DECLARE @ProdCode VARCHAR(20) = CASE WHEN ISNULL(@pProdCode,'') = '' THEN '*' ELSE @pProdCode END

    
	SELECT
			EO.ProdCode
		   ,EO.Seq
		   ,EO.DryingFurnaceName
		   ,EO.DryingFurnaceTemp
		   ,EO.DryingFurnaceAirUpperPart
		   ,EO.DryingFurnaceAirLowerPart
		   ,EO.TempLowerTolerance
		   ,EO.TempUpperTolerance
		   ,EO.AirLowerTolerance
		   ,EO.AirUpperTolerance
		   ,EO.CreateDateTime
		   ,EO.CreateUserID
		   ,EO.ChangeDateTime
		   ,EO.ChangeUserID
	FROM
			STB_ElectrodeOven EO
   WHERE ((@ProdCode = '*') OR (EO.ProdCode = @ProdCode)) 
END