-- =============================================
-- Author: Jackaroe (yjyu@vina.co.kr)
-- Create date: 2021-02-18
-- Browsable : true
-- Group : 생산관리
-- Description:	(모듈 Lot 매핑안된)단셀Lot 조회
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_SingleLotInfoForModuleBinding_get]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pCompanyCode VARCHAR(20) = NULL,
	@pWorkCenterCode VARCHAR(20) = NULL,
    @pBarcode VARCHAR(20)
AS
BEGIN
	Declare @CompanyCode VARCHAR(20) = CASE WHEN ISNULL(@pCompanyCode, '') = '' THEN '*' ELSE @pCompanyCode END
	       ,@WorkCenterCode VARCHAR(20) = CASE WHEN ISNULL(@pWorkCenterCode, '') = '' THEN '*' ELSE @pWorkCenterCode END
		   ,@Barcode VARCHAR(20) = @pBarcode

	SELECT SI.Barcode
	      ,SI.MaterialCode
		  ,SI.InputLineCode
		  ,SI.InputDateTime
		  ,PRH.ProdDateTime
		  ,PRH.ProdQty
		  ,PRH.WorkerCode
		  ,PWI.WorkerName
		  ,SI.ModuleBarcode
	  FROM STB_SetInfo SI
	  LEFT OUTER JOIN STB_ProdRouteHist PRH
	    ON SI.ControlNo = PRH.ControlNo
	   AND PRH.RouteCode IN (SELECT RouteCode 
	                           FROM STB_RouteInfo 
							  WHERE RouteType = 'Route-28')
	  LEFT OUTER JOIN STB_ProdWorkerInfo PWI
	    ON PWI.WorkerCode = PRH.WorkerCode
	 WHERE 1=1
	   --AND SI.IsProdFinish = CONVERT(BIT, 1) be comment for test
	   --AND SI.ModuleBarcode IS NULL
	   AND SI.Barcode = @Barcode
	   AND (@CompanyCode = '*' OR PRH.CompanyCode = @CompanyCode)
	   AND (@WorkCenterCode = '*' OR PRH.WorkCenterCode = @WorkCenterCode)
END