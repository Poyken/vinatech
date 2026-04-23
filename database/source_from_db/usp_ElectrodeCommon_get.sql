-- =============================================
-- Author: Jackaroe (yjyu@vina.co.kr)
-- Create date: 2019-01-20
-- Browsable : true
-- Group : 생산관리
-- Description:	전극레시피공통정보조회
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_ElectrodeCommon_get]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pProdCode VARCHAR(20) = NULL

AS
BEGIN
	SET NOCOUNT ON;
	
	DECLARE @ProdCode VARCHAR(20) = CASE WHEN ISNULL(@pProdCode,'') = '' THEN '*' ELSE @pProdCode END

    
	SELECT
			 EC.ProdCode
			,MM.MaterialName AS ProdName
			,EC.LivingSubstance
			,EC.MixRatio
			,EC.TankVolume
			,EC.ElectrodeType
			,EC.MeasureViscosity
			,EC.Remark
			,EC.OneSide
			,EC.OneSideLowerTolerance
			,EC.OneSideUpperTolerance
			,EC.BothSide
			,EC.BothSideLowerTolerance
			,EC.BothSideUpperTolerance
			,EC.RollingDensityMin
			,EC.RollingDensityMax
			,EC.ViscosityMin
			,EC.ViscosityMax
			,EC.UnwndngStdMin
			,EC.UnwndngStdMax
			,EC.UnwndngMeasureValue
			,EC.RwndngStdMin
			,EC.RwndngStdMax
			,EC.RwndngMeasureValue
			,EC.ProdConLinePressure
			,EC.ProdConTemp
			,EC.ProdConTempLowerTolerance
			,EC.ProdConTempUpperTolerance
			,EC.ProdConSpeed
			,EC.ProdConSpeedLowerTolerance
			,EC.ProdConSpeedUpperTolerance
			,EC.ProdConThickStdMin
			,EC.ProdConThickStdMax
			,EC.CoolingWaterStdMin
			,EC.CoolingWaterStdMax
			,EC.LeftHeadGap
			,EC.RightHeadGap
			,EC.AlFoilWidth
			,EC.CoatingWidth
			,EC.OneSideSpeed
			,EC.BothSideSpeed
			,EC.CreateDateTime
			,EC.CreateUserID
			,EC.ChangeDateTime
			,EC.ChangeUserID
			,EC.Batches 
	FROM
			STB_ElectrodeCommon EC
		   ,STB_MaterialMaster MM

   WHERE EC.ProdCode = MM.MaterialCode
     AND ((@ProdCode = '*') OR (EC.ProdCode = @ProdCode)) 
END

-- 컬럼추가 (2020.10.07)  :  ALTER TABLE STB_ElectrodeCommon ADD Batches INT