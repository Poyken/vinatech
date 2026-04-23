-- =============================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Create date: 2019-01-24
-- Browsable : true
-- Group : 생산관리
-- Description:	믹싱혼합단계정보
-- =============================================
CREATE PROCEDURE [dbo].[usp_ElectrodeMixStepInfoByDate_get]
	@pProcessUserID VARCHAR(20)
   ,@pProcessLanguage VARCHAR(20)
   ,@pFromDate DATE
   ,@pToDate DATE
AS
BEGIN
	DECLARE @FromDate DATETIME = CONVERT(CHAR(10), @pFromDate, 121) + ' 08:30:00'
	       ,@ToDate DATETIME = CONVERT(CHAR(10), DATEADD(day, 1, @pToDate), 121) + ' 08:30:00'

	SELECT 	 ISNULL(EMSI.ElectrodeLotNumber, SI.Barcode) AS ElectrodeLotNumber
			,ISNULL(EMSI.ElectrodeStep, ES.ElectrodeStepCode) AS ElectrodeStep
			,ISNULL(EMSI.Seq, ES.Seq) AS Seq
			,ISNULL(EMSI.ElectrodeMaterialCode, ES.MaterialCode) AS ElectrodeMaterialCode
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
	 LEFT OUTER JOIN STB_MaterialMaster MM	           ON MM.MaterialCode = ISNULL(EMSI.ElectrodeMaterialCode, ES.MaterialCode)
	 WHERE EMSI.CreateDateTime BETWEEN @FromDate AND @ToDate
	 ORDER BY ISNULL(EMSI.ElectrodeLotNumber, SI.Barcode)
	         ,CASE WHEN ES.ElectrodeStepCode = 'D'  THEN 1
	               WHEN ES.ElectrodeStepCode = 'G'  THEN 2
				   WHEN ES.ElectrodeStepCode = 'K'  THEN 3
				   WHEN ES.ElectrodeStepCode = 'S'  THEN 4
				   WHEN ES.ElectrodeStepCode = 'S1'  THEN 4.1 --Mr.Tung add to fix error convert Varchar to INT
				   WHEN ES.ElectrodeStepCode = 'S2'  THEN 4.2 --Mr.Tung add to fix error convert Varchar to INT
				   WHEN ES.ElectrodeStepCode = 'DA' THEN 5
				   ELSE 10 END
			,ES.Seq
END