-- =============================================
-- Author: kilee@vina.co.kr
-- Create date: 2020-05-08
-- Browsable : true
-- Group : 생산관리 > [B799] 전극재고현황 > 슬리팅실적재고
-- Description:	
-- Modified:

--  usp_ElectrodeInventoryInquirySliting_get  'klee', 'Korean' 
-- =============================================
CREATE PROCEDURE [dbo].[usp_ElectrodeInventoryInquirySliting_get]
						@pProcessUserID VARCHAR(20),
						@pProcessLanguage VARCHAR(20)
					--	@pElectrodeLotNumber VARCHAR(20) = NULL
AS
BEGIN
	DECLARE @ElectrodeLotNumber VARCHAR(20)
	--SET @ElectrodeLotNumber = @pElectrodeLotNumber

-- [슬리팅 실적 체크]
SELECT   ISNULL(ESI.ElectrodeLotNumber, SI.Barcode) AS ElectrodeLotNumber
			,ESI.MachineCode
			,MM.MachineName
			,ESI.WorkDate
			,ESI.WorkerCode 
			,PWI.WorkerName
			,ESI.Temperature
			,ESI.Humidity
			,ESI.PushingYn
			,ESI.VisualInspectionResult
			,ESI.SlittingLength
			,ESI.Remark
			,ESI.CreateDateTime
			,ESI.CreateUserID
			,ESI.ChangeDateTime
			,ESI.ChangeUserID
			,SI.MaterialCode
			,MM2.MaterialName
			,MM2.MaterialThickness
			,ESI.PrintYn 
	  FROM STB_SetInfo SI
			  LEFT OUTER JOIN STB_MaterialMaster        MM2 ON SI.MaterialCode = MM2.MaterialCode
			  LEFT OUTER JOIN STB_ElectrodeSlittingInfo ESI	   ON SI.Barcode = ESI.ElectrodeLotNumber
			  LEFT OUTER JOIN STB_MachineMaster       MM	   ON ESI.MachineCode = MM.MachineCode
			  LEFT OUTER JOIN STB_ProdWorkerInfo      PWI	   ON ESI.WorkerCode = PWI.WorkerCode		  
	 WHERE 1=1
	    --AND SI.Barcode = @ElectrodeLotNumber	   
	--	AND NOT SI.Barcode Like '%VVK%'
        AND ESI.CreateDateTime BetWeen '2020-05-01 00:00:00' AND '2020-05-15 23:59:59'
		--AND ESI.PrintYn <> '1'                                                                                             -- 프린트 출력이 안된제품 (출력하면 법인으로 이동) 

-- [프린터 여부에 따라 법인으로 이동했는지 체크]
--SELECT PrintYn, * FROM STB_ElectrodeCoatingInfo Where PrintYn is not Null
--SELECT PrintYn, * FROM STB_ElectrodeSlittingInfo  Where PrintYn is not Null

END

-- SELECT * FROM STB_ElectrodeSlittingInfo WHERE CreateDateTime BetWeen '2020-01-01 00:00:00' AND '2020-05-15 23:59:59'