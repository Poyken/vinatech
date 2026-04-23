-- =============================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Create date: 2020-08-31
-- Browsable : true
-- Group : 팝업
-- Description:	부적합 보고서용 Lot정보(작업자, 설비) 팝업
--             ,속도 문제로 최근 2개월 생산 Lot만 조회합니다.
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_GetWorkerAndMachineForDefectReport_popup]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pUtcOffset INT,
	@pOccurProcessCode VARCHAR(20) = '*'
AS
BEGIN

Declare @OccurProcessCode VARCHAR(20) = @pOccurProcessCode
       ,@RouteType VARCHAR(20)

SELECT @RouteType = BC.Remark
  FROM SmartFramework.dbo.STB_BaseCode BC
 WHERE BC.CodeGroup = 'OccurProcessCode'
   AND BC.ItemCode = @OccurProcessCode

SELECT SI.Barcode
      ,dbo.fnGetLocalTime(PRI.JobDate,@pUtcOffset) AS JobDate
      ,PRI.WorkerCode
	  ,PWI.WorkerName
	  ,PRI.MachineCode
	  ,MM.MachineName
	  ,MBI.ModelCode
	  ,MBI.ModelName
	  ,MBI.MBIExtText04 + 'V-' + MBI.MBIExtText05 
			                 + 'F(' + RIGHT('0'+CONVERT(VARCHAR, CONVERT(INT, MBI.MBISizeW)), 2) 
							 + CONVERT(VARCHAR, CONVERT(INT, MBI.MBISizeH)) + ')' AS MaterialSpec
  FROM (SELECT ControlNo, RouteCode, MAX(JobDate) AS JobDate, MAX(WorkerCode) AS WorkerCode, MAX(MachineCode) AS MachineCode 
          FROM STB_ProdRouteHist 
		 GROUP BY ControlNo, RouteCode) PRI
  LEFT OUTER JOIN STB_SetInfo SI
    ON PRI.ControlNo = SI.ControlNo
   AND PRI.RouteCode IN ('E-22', 'V-22')
--   AND PRI.RouteCode IN (SELECT RouteCode FROM STB_RouteInfo WHERE RouteType = @RouteType)
  LEFT OUTER JOIN STB_ProdWorkerInfo PWI
    ON PWI.WorkerCode = PRI.WorkerCode
  LEFT OUTER JOIN STB_MachineMaster MM
    ON MM.MachineCode = PRI.MachineCode
  LEFT OUTER JOIN STB_ModelBasicInfo MBI
    ON MBI.ModelCode = SI.MaterialCode
 WHERE 1=1
   AND PRI.RouteCode IN ('E-22', 'V-22')
--   AND PRI.RouteCode IN (SELECT RouteCode FROM STB_RouteInfo WHERE RouteType = @RouteType)
   AND PRI.JobDate > DATEADD(month, -2, GETDATE())
   AND SI.Barcode IS NOT NULL
 ORDER BY SI.Barcode

END