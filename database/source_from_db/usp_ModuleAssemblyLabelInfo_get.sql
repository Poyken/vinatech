-- =============================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Create date: 2023-05-02
-- Browsable : true
-- Group : 모듈관리
-- Description:	
-- Modified:
-- =============================================
CREATE PROC [dbo].[usp_ModuleAssemblyLabelInfo_get]
	@pProcessUserID VARCHAR(20)
   ,@pProcessLanguage VARCHAR(20)
   ,@pFromDate DATE
   ,@pToDate DATE
   ,@pModuleParentLotNo VARCHAR(20) = NULL
AS
BEGIN
	Declare @FromDate DATETIME = CONVERT(CHAR(10), @pFromDate, 121) + ' 08:30:00'
	       ,@ToDate DATETIME = CONVERT(CHAR(10), DATEADD(day, 1, @pToDate), 121) + ' 08:29:59'
		   ,@ModuleParentLotNo VARCHAR(20) = CASE WHEN ISNULL(@pModuleParentLotNo, '') = '' THEN '*' ELSE @pModuleParentLotNo END

	SELECT MALI.ModuleAssemblyLotNo
	      ,MALI.ModuleParentLotNo
          ,MALI.CreateDateTime
          ,MALI.CreateUserID
		  ,'Report' AS CommandType
		  ,MALI.RouteCode
		  ,RI.RouteName
		  ,MALI.DefectCode
		  ,DI.BasicDefectName
		  ,CASE WHEN ISNULL(SI.LotNumber, '') = '' THEN CONVERT(BIT, 0) ELSE CONVERT(BIT, 1) END AS IsLotNumber
		  ,MALI.IsPacking
		  ,MALI.PackingDateTime
		  ,MALI.IsShipment
		  ,MALI.ShipmentDateTime
	  FROM STB_ModuleAssemblyLabelInfo MALI
	  LEFT OUTER JOIN STB_RouteInfo RI
	    ON RI.RouteCode = MALI.RouteCode
	  LEFT OUTER JOIN STB_DefectInfo DI 
	    ON DI.DefectCode = MALI.DefectCode
	  LEFT OUTER JOIN STB_SetInfo SI
	    ON Barcode = MALI.ModuleAssemblyLotNo
	  LEFT OUTER JOIN STB_DayProdPlan DPP 
	    ON SI.DayPlanNo = DPP.DayPlanNo
	 WHERE DPP.PlanDate BETWEEN @FromDate AND @ToDate
	   AND (@ModuleParentLotNo = '*' OR MALI.ModuleParentLotNo = @ModuleParentLotNo)
	 ORDER BY ModuleAssemblyLotNo
END