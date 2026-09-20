-- =============================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Create date: 2019-01-24
-- Browsable : true
-- Group : 생산관리
-- Description:	믹싱혼합단계정보
-- =============================================
CREATE PROCEDURE [dbo].[usp_ElectrodeMixStepInfo_get]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pElectrodeLotNumber VARCHAR(20) = NULL
AS
BEGIN
	DECLARE @ElectrodeLotNumber VARCHAR(20)
	SET @ElectrodeLotNumber = @pElectrodeLotNumber

	SELECT 	 ISNULL(EMSI.ElectrodeLotNumber, SI.Barcode) AS ElectrodeLotNumber
			,ISNULL(ES.ElectrodeStepCode, EMSI.ElectrodeStep) AS ElectrodeStep
			,ISNULL(ES.Seq, EMSI.Seq) AS Seq
			,ISNULL(ES.MaterialCode, EMSI.ElectrodeMaterialCode) AS ElectrodeMaterialCode
			,MM.MaterialName AS ElectrodeMaterialName
			,EMSI.InputQty1
			,EMSI.InputQty2
			,EMSI.MaterialLotNumber
			,EMSI.BinderInputTime
			,EMSI.BinderOutputTime
			,EMSI.MixingInputTime
			,EMSI.MixingOutputTime
			,EMSI.SpecInOut
			,EMSI.SpecOutQty
			,EMSI.CreateDateTime
			,EMSI.CreateUserID
			,EMSI.ChangeDateTime
			,EMSI.ChangeUserID
	  FROM STB_ElectrodeStep ES 
	 INNER JOIN STB_SetInfo SI	                               ON ES.ProdCode = SI.MaterialCode
     LEFT OUTER JOIN STB_ElectrodeMixStepInfo EMSI	   ON SI.Barcode = EMSI.ElectrodeLotNumber	   AND EMSI.ElectrodeStep = ES.ElectrodeStepCode	   AND EMSI.Seq = ES.Seq
	 LEFT OUTER JOIN STB_MaterialMaster MM	           ON MM.MaterialCode = ISNULL(ES.MaterialCode, EMSI.ElectrodeMaterialCode)
	 WHERE SI.Barcode = @ElectrodeLotNumber
	 ORDER BY CASE WHEN ES.ElectrodeStepCode = 'D'  THEN 1
	               WHEN ES.ElectrodeStepCode = 'G'  THEN 2
				   WHEN ES.ElectrodeStepCode = 'K'  THEN 3
				   WHEN ES.ElectrodeStepCode = 'P' THEN 4
				   WHEN ES.ElectrodeStepCode = 'S'  THEN 5
				   WHEN ES.ElectrodeStepCode = 'S1'  THEN 6
				   WHEN ES.ElectrodeStepCode = 'S2'  THEN 7
				   WHEN ES.ElectrodeStepCode = 'S3'  THEN 8
				   WHEN ES.ElectrodeStepCode = 'S4'  THEN 9
				   WHEN ES.ElectrodeStepCode = 'S5'  THEN 10
				   WHEN ES.ElectrodeStepCode = 'DA' THEN 11
				   ELSE 100 END
			,ES.Seq
END