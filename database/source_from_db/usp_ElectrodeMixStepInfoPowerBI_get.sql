-- =============================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Create date: 2019-01-24
-- Browsable : true
-- Group : 생산관리
-- Description:	믹싱혼합단계정보
-- usp_ElectrodeMixStepInfoPowerBI_get '','','VJHR1120001E03'
-- =============================================
CREATE PROCEDURE [dbo].[usp_ElectrodeMixStepInfoPowerBI_get]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pElectrodeLotNumber VARCHAR(20) = NULL
AS
BEGIN
	DECLARE @ElectrodeLotNumber VARCHAR(20)
	SET @ElectrodeLotNumber = @pElectrodeLotNumber

	--SELECT 	 ISNULL(EMSI.ElectrodeLotNumber, SI.Barcode) AS ElectrodeLotNumber
	--		,ISNULL(EMSI.ElectrodeStep, ES.ElectrodeStepCode) AS ElectrodeStep
	--		,ISNULL(EMSI.Seq, ES.Seq) AS Seq
	--		,ISNULL(EMSI.ElectrodeMaterialCode, ES.MaterialCode) AS ElectrodeMaterialCode
	--		,MM.MaterialName AS ElectrodeMaterialName
	--		,EMSI.InputQty1
	--		,EMSI.InputQty2
	--		,EMSI.MaterialLotNumber
	--		,EMSI.BinderInputTime
	--		,EMSI.BinderOutputTime
	--		,EMSI.MixingInputTime
	--		,EMSI.MixingOutputTime
	--		,EMSI.SpecInOut
	--		,EMSI.SpecOutQty
	--		,EMSI.CreateDateTime
	--		,EMSI.CreateUserID
	--		,EMSI.ChangeDateTime
	--		,EMSI.ChangeUserID
	--  FROM STB_ElectrodeStep ES 
	-- INNER JOIN STB_SetInfo SI	                               ON ES.ProdCode = SI.MaterialCode
 --    LEFT OUTER JOIN STB_ElectrodeMixStepInfo EMSI	   ON SI.Barcode = EMSI.ElectrodeLotNumber	   AND EMSI.ElectrodeStep = ES.ElectrodeStepCode	   AND EMSI.Seq = ES.Seq
	-- LEFT OUTER JOIN STB_MaterialMaster MM	           ON MM.MaterialCode = ISNULL(EMSI.ElectrodeMaterialCode, ES.MaterialCode)
	-- WHERE SI.Barcode = @ElectrodeLotNumber
	-- ORDER BY CASE WHEN ES.ElectrodeStepCode = 'D'  THEN 1
	--               WHEN ES.ElectrodeStepCode = 'G'  THEN 2
	--			   WHEN ES.ElectrodeStepCode = 'K'  THEN 3
	--			   WHEN ES.ElectrodeStepCode = 'S'  THEN 4
	--			   WHEN ES.ElectrodeStepCode = 'DA' THEN 5
	--			   ELSE ES.ElectrodeStepCode END
	--		,ES.Seq

		SELECT 	  EM.ElectrodeLotNumber as 전극Lot번호           --  ISNULL(EMSI.ElectrodeLotNumber, SI.Barcode) AS ElectrodeLotNumber
      ,  SI.MaterialCode as 품목코드
	  , MM.MaterialName  as 품목명
	   , EM.MachineCode as 설비코드
	  , MM2.MachineName as  설비명
	   , EM.WorkDate  as 믹싱작업자코드
	   ,  PWI.WorkerName as 믹싱작업자명
	   , EM.Temperature  as 믹싱온도
	   , EM.Humidity as  믹싱습도
	   , EM.ProductionQty  as 믹싱생산량
	   , EM.TankInsideTemp  as 믹싱탱크내부온도
	   , EM.ViscosityValue as 믹싱정보측정값
	   , EM.SpecificGravityValue as 믹싱비중값
	    ,EM.MixingTemperature   as 믹싱온도
	    ,EM.SpecificComment  as 믹싱유의사항
	   , EM.CoolantTemperature as CoolantTemperature     --   믹싱냉각수온도

	   , ISNULL(EMSI.ElectrodeStep, ES.ElectrodeStepCode) AS ElectrodeStep  --믹싱1 전극혼합단계
	   ,ISNULL(EMSI.Seq, ES.Seq) AS Seq-- 믹싱순번
	   ,ISNULL(EMSI.ElectrodeMaterialCode, ES.MaterialCode) AS ElectrodeMaterialCode --믹싱전극자재명
	   ,EMSI.InputQty1 as 믹싱투입량
	   ,EMSI.InputQty2 as 믹싱투입량2
	   
	   ,EMSI.MaterialLotNumber as 믹싱자재Lot번호
	   --믹싱전극혼합단계2
	   --믹싱순번
	   --믹싱전극자재명
	   --믹싱자재Lot번호7

	   --코팅정보
	   --코팅외관검사정보
	   --롤프레싱정보
	   --롤프레싱외관검사정보		
							
	  FROM STB_ElectrodeStep ES 
				 INNER JOIN STB_SetInfo SI	                               ON ES.ProdCode = SI.MaterialCode
				 LEFT OUTER JOIN STB_ElectrodeMixStepInfo EMSI	   ON SI.Barcode = EMSI.ElectrodeLotNumber	   AND EMSI.ElectrodeStep = ES.ElectrodeStepCode	   AND EMSI.Seq = ES.Seq
				 LEFT OUTER JOIN STB_MaterialMaster MM	           ON MM.MaterialCode = ISNULL(EMSI.ElectrodeMaterialCode, ES.MaterialCode)
				
				LEFT OUTER JOIN STB_ElectrodeMixInfo EM			ON SI.Barcode = EM.ElectrodeLotNumber				
				Left Outer Join STB_MachineMaster MM2	     On EM.MachineCode = MM2.MachineCode 
				Left Outer Join STB_ProdWorkerInfo PWI	 	 On EM.WorkerCode = PWI.WorkerCode

	 WHERE SI.Barcode = 'VJHR1120001E03'
	 ORDER BY CASE WHEN ES.ElectrodeStepCode = 'D'  THEN 1
	               WHEN ES.ElectrodeStepCode = 'G'  THEN 2
				   WHEN ES.ElectrodeStepCode = 'K'  THEN 3
				   WHEN ES.ElectrodeStepCode = 'S'  THEN 4
				   WHEN ES.ElectrodeStepCode = 'S1'  THEN 4.1 --Mr.Tung add to fix error convert Varchar to INT
				   WHEN ES.ElectrodeStepCode = 'S2'  THEN 4.2 --Mr.Tung add to fix error convert Varchar to INT
				   WHEN ES.ElectrodeStepCode = 'DA' THEN 5
				   ELSE 10 END
			,ES.Seq


END


