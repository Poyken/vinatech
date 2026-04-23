-- =============================================
-- Author: kilee@vina.co.kr
-- Create date: 2020-05-08
-- Browsable : true
-- Group : 생산관리 > [B799] 전극재고현황
-- Description:	
-- Modified:

--  usp_ElectrodeInventoryInquiry_get 'klee', 'Korean' 
-- =============================================
CREATE PROCEDURE [dbo].[usp_ElectrodeInventoryInquiry_get_BACKUP]
					@pProcessUserID VARCHAR(20),
					@pProcessLanguage VARCHAR(20)
				--	@pElectrodeLotNumber VARCHAR(20) = NULL
AS
BEGIN
	DECLARE @ElectrodeLotNumber VARCHAR(20)
	--SET @ElectrodeLotNumber = @pElectrodeLotNumber

	SELECT   ISNULL(ERPI.ElectrodeLotNumber, SI.Barcode) AS ElectrodeLotNumber
			,ERPI.MachineCode
			,MM.MachineName
			,ERPI.WorkDate
			,ERPI.WorkerCode 
			,PWI.WorkerName
			,ERPI.Temperature
			,ERPI.Humidity
			,ERPI.RollingDensityValue
			,ERPI.RollingDensityResult
			,ERPI.HeadGapInitLeft
			,ERPI.HeadGapInitRight
			,ERPI.ProdConTemp
			,ERPI.ProdConSpeed
			,ERPI.ProductionQty
			,ERPI.GoodQty
			,ERPI.BadQty
			,ERPI.VisualInspectionResult
			,ERPI.CreateDateTime
			,ERPI.CreateUserID
			,ERPI.ChangeDateTime
			,ERPI.ChangeUserID
			,SI.MaterialCode
			,MM2.MaterialName
			,MM2.MaterialThickness
			,'Report' AS CommandType
			,'O' AS IsRollPress
			, ECI.PrintYn
	  FROM STB_SetInfo SI
			  LEFT OUTER JOIN STB_MaterialMaster MM2	                 ON SI.MaterialCode = MM2.MaterialCode
			  LEFT OUTER JOIN STB_ElectrodeRollPressingInfo ERPI	    ON SI.Barcode = ERPI.ElectrodeLotNumber
			  LEFT OUTER JOIN STB_MachineMaster MM	                ON ERPI.MachineCode = MM.MachineCode
			  LEFT OUTER JOIN STB_ProdWorkerInfo PWI	                ON ERPI.WorkerCode = PWI.WorkerCode
			  LEFT OUTER JOIN STB_ElectrodeCoatingInfo ECI           ON ECI.ElectrodeLotNumber = ERPI.ElectrodeLotNumber   AND ECI.ElectrodeLotNumber = SI.Barcode 
	 WHERE  1=1
	    --AND SI.Barcode = 'VJHR1120001E03'
        AND NOT SI.Barcode IN ( SELECT ElectrodeLotNumber  FROM STB_ElectrodeSlittingInfo )
		AND NOT SI.Barcode Like '%VVK%'
        AND ERPI.CreateDateTime BetWeen '2020-05-01 00:00:00' AND '2020-05-15 23:59:59'
		AND ECI.PrintYn <> '1'   -- 프린트 출력이 안된제품 (출력하면 법인으로 이동)

					-- [프린터 여부에 따라 법인으로 이동했는지 체크]
--SELECT PrintYn, * FROM STB_ElectrodeCoatingInfo Where PrintYn is not Null
--SELECT PrintYn, * FROM STB_ElectrodeSlittingInfo  Where PrintYn is not Null



		--  슬리팅 재고

		--SELECT   ESR.ElectrodeLotNumber
		--	,ESR.Seq
		--	,ESR.ElectrodeThick
		--	,ESR.SlittingWidth
		--	,ESR.ProductionQty
		--	,ESR.GoodQtyLength
		--	,ESR.CreateDateTime
		--	,ESR.CreateUserID
		--	,ESR.ChangeDateTime
		--	,ESR.ChangeUserID
		--	,'Report' AS CommandType
		--	,ESR.Barcode
		--	,ESR.LotUniqueNumber
		--	,RIGHT(ESR.Barcode, 3) AS CutNo
		--	,MM.MaterialSource
	 -- FROM                         STB_ElectrodeSlittingResult ESR
	 --          LEFT OUTER JOIN STB_SetInfo SI	                         ON ESR.ElectrodeLotNumber = SI.Barcode
	 --          LEFT OUTER JOIN STB_MaterialMaster MM	             ON MM.MaterialCode = SI.MaterialCode
	 --WHERE 1=1
	 --   --AND ESR.ElectrodeLotNumber = 'VJKN1220001E25'
	   
	 --ORDER BY Seq

END