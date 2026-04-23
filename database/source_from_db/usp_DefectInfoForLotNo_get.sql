-- =============================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Create date: 2020-04-10
-- Browsable : true
-- Group : 품질관리
-- Description:	불량정보(최우석 대리 요청)
-- =============================================

CREATE PROCEDURE [dbo].[usp_DefectInfoForLotNo_get]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pFromDate DATE,
	@pToDate DATE,
	@pCompanyCode VARCHAR(20) = NULL
AS
BEGIN
	Declare @FromDate DATETIME = CONVERT(VARCHAR(10), @pFromDate, 121) + ' 08:30:00'
	       ,@ToDate DATETIME = CONVERT(VARCHAR(10), DATEADD(day, 1, @pToDate), 121) + ' 08:30:00'
		   ,@CompanyCode VARCHAR(20) = CASE WHEN ISNULL(@pCompanyCode, '') = '' THEN '*' ELSE @pCompanyCode END


SELECT DRI.CompanyCode AS 사업장코드
      ,CI.CompanyName AS 사업장명
      ,SI.Barcode AS [Lot No.]
	  ,DRI.FindDateTime AS 일자
	  ,SI.MaterialCode AS 품목코드
	  ,MM.MaterialName AS 품목명
	  ,DI.DefectGroupCode AS 기준불량증상분류코드
	  ,RI.RouteName AS 기준불량증상분류명
	  ,PRH.MachineCode AS 설비코드
	  ,MM2.MachineName AS 설비명
	  ,DRI.DefectCode AS 불량증상코드
	  ,DI.BasicDefectName AS 기준불량명
	  ,PRH.ProdQty AS 투입수량
	  ,(DRI.DefectQty - DRI.RepairQty) AS 불량수량
	  ,SI.InputLineCode as LineCode
  FROM STB_SetInfo SI
  LEFT OUTER JOIN STB_DefectRepairInfo DRI
    ON SI.ControlNo = DRI.ControlNo
  LEFT OUTER JOIN STB_DefectInfo DI
    ON DRI.DefectCode = DI.DefectCode
  LEFT OUTER JOIN STB_ProdRouteHist PRH
    ON PRH.ControlNo = SI.ControlNo
   AND PRH.RouteCode = DRI.FindRouteCode
  LEFT OUTER JOIN STB_CompanyInfo CI
    ON DRI.CompanyCode = CI.CompanyCode
  LEFT OUTER JOIN STB_MaterialMaster MM
    ON SI.MaterialCode = MM.MaterialCode
  LEFT OUTER JOIN STB_MachineMaster MM2
    ON MM2.MachineCode = PRH.MachineCode
  LEFT OUTER JOIN STB_RouteInfo RI
    ON DI.DefectGroupCode = RI.RouteCode
  WHERE DRI.FindJobdate BETWEEN @FromDate AND @ToDate
    AND (@CompanyCode = '*' OR DRI.CompanyCode = @CompanyCode)
END