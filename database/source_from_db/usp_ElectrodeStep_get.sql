-- =============================================
-- Author: Jackaroe (yjyu@vina.co.kr)
-- Create date: 2019-01-16
-- Browsable : true
-- Group : 생산관리
-- Description:	전극레시피조회
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_ElectrodeStep_get]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pProdCode VARCHAR(20) = NULL

AS
BEGIN
	SET NOCOUNT ON;
	
	DECLARE @ProdCode VARCHAR(20) = CASE WHEN ISNULL(@pProdCode,'') = '' THEN '' ELSE @pProdCode END

    
	SELECT
			ES.ProdCode AS OldProdCode
		   ,ES.ProdCode
		   ,MM2.MaterialName AS ProdName
		   ,ES.seq
		   ,ES.seq AS OldSeq
		   ,ES.ElectrodeStepCode
		   ,ES.ElectrodeStepCode AS OldElectrodeStepCode
		   ,BC.Description AS ElectrodeStepName
		   ,ES.MaterialCode
		   ,ES.MaterialCode AS OldMaterialCode
		   ,MM.MaterialName
		   ,MM.MaterialSpec
		   ,ES.StdMinVal
		   ,ES.StdMaxVal
		   ,ES.WorkTime
		   ,ES.HighSpeedSpin
		   ,ES.LowSpeedSpin
		   ,ES.Remark
		   ,ES.CreateDateTime
		   ,ES.CreateUserID
		   ,ES.ChangeDateTime
		   ,ES.ChangeUserID
	FROM
			STB_ElectrodeStep ES
		   ,SmartFramework.dbo.STB_BaseCode BC
		   ,STB_MaterialMaster MM
		   ,STB_MaterialMaster MM2
	WHERE 1=1
	  AND BC.CodeGroup = 'ElectrodeStep'
	  AND ES.ElectrodeStepCode = BC.ItemCode
	  AND ES.MaterialCode = MM.MaterialCode
	  AND ES.ProdCode = MM2.MaterialCode
	  AND  ((@ProdCode = '*') OR (ES.ProdCode = @ProdCode)) 
	ORDER BY CASE WHEN ES.ElectrodeStepCode = 'D' THEN 1
	              WHEN ES.ElectrodeStepCode = 'G' THEN 2
				  WHEN ES.ElectrodeStepCode = 'K' THEN 3
				  WHEN ES.ElectrodeStepCode = 'P' THEN 4
				  WHEN ES.ElectrodeStepCode = 'S' THEN 5
				  WHEN ES.ElectrodeStepCode = 'S1' THEN 6
				  WHEN ES.ElectrodeStepCode = 'S2' THEN 7
				  WHEN ES.ElectrodeStepCode = 'S3' THEN 8
				  WHEN ES.ElectrodeStepCode = 'S4' THEN 9
				  WHEN ES.ElectrodeStepCode = 'S5' THEN 10
				  WHEN ES.ElectrodeStepCode = 'DA' THEN 11
				  ELSE 100 END 
				  , ES.seq
END