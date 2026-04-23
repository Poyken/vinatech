-- =============================================
-- Author:		Mr.Duy	
-- Create date: 2025-03-13
-- Description:	Lấy dữ liệu đã lưu packing của sản xuất hà nam
-- =============================================
-- exec usp_Vietnam_PackPrintTime_get_HN '','','','2025-03-01','2025-03-31','','','','','VVT_F3'
CREATE PROCEDURE usp_Vietnam_PackPrintTime_get_HN
    @pProcessUserID VARCHAR(20)= NULL,
	@pProcessLanguage VARCHAR(20)= NULL,
	@pCompanyCode VARCHAR(20) = NULL,  -- 사업장 코드 용은재 추가 (2020.01.23)
	@pFromDate DATETIME = NULL,
	@pToDate DATETIME = NULL,
	@pRouteCode VARCHAR(20) = NULL,
	@pLineCode VARCHAR(20) = NULL,
	@pLotNo VARCHAR(20) = NULL,
	@pMaterialCode VARCHAR(30) = NULL,
	@pWorkCenterCode VARCHAR(20) = NULL
AS
	DECLARE @CompanyCode      VARCHAR(20) = CASE WHEN ISNULL(@pCompanyCode,'') = '' THEN '*' ELSE @pCompanyCode END
	DECLARE @FromDate   VARCHAR(19) = CONVERT(VARCHAR(10), @pFromDate, 120) + ' 10:00:00'                                                            -- SELECT  CONVERT(VARCHAR(10), '2019-09-16', 121) + ' 08:30:00' 
	DECLARE @ToDate      VARCHAR(19) = CONVERT(VARCHAR(10), DATEADD(DAY, 1, CONVERT(smalldatetime, @pToDate)), 120) + ' 10:00:00'         -- 다음날 SELECT CONVERT(VARCHAR(10), DATEADD(DAY, 1, CONVERT(smalldatetime, '2019-09-17 00:01:09')), 121) + ' 08:30:00'    

	DECLARE	@RouteCode    VARCHAR(20) = CASE WHEN ISNULL(@pRouteCode, '') = ''   THEN '*' ELSE @pRouteCode  END
	DECLARE	@LineCode      VARCHAR(20) = CASE WHEN ISNULL(@pLineCode, '') = ''     THEN '*' ELSE @pLineCode     END
	DECLARE	@LotNo          VARCHAR(15) = CASE WHEN ISNULL(@pLotNo, '') = ''         THEN '*' ELSE @pLotNo         END
	DECLARE	@MaterialCode VARCHAR(30) = CASE WHEN ISNULL(@pMaterialCode, '') = '' THEN '*' ELSE @pMaterialCode END

BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	select   SPT.LotNo,SPT.PackingID,SPT.PackQty,SPT.MaterialCode,SPT.MaterialName,SPT.EmpNo,SPT.PartNo,SI.InputLineCode,
	ISNULL(SPT.PackQty, 0) *  convert(numeric(38,15),ISNULL(max(SP.PriceVE10),0))  as Price,
	(case   
	when   (datepart(hour, max(SPT.PrintTime))>10)     or    (datepart(hour, max(SPT.PrintTime))=10 and datepart(minute, max(SPT.PrintTime))>30)     
	then     convert(varchar(10),max(SPT.PrintTime),120)    
	else 
		convert(varchar(10),dateadd(day, -1,  max(SPT.PrintTime)),120)  
	end )	 as  jobdate,

	max(PRH.ProdDateTime) as ProdDateTime,max(SPT.PrintTime) as PrintTime 
	from STB_SavePackingTime_VVT SPT
	join STB_MaterialLotInfo MLI WITH(NOLOCK) on SPT.PackingID = MLI.PackingID
	join STB_SetInfo SI WITH(NOLOCK)  on  SPT.LotNo=SI.Barcode 
	join STB_ProdRouteHist PRH  WITH(NOLOCK) on SI.ControlNo=PRH.ControlNo and  PRH.RouteCode='VE10'
	left join STB_VVT_StagePrices SP WITH(NOLOCK) on MLI.Materialcode = SP.model and 'VE10' = SP.RouteVE10
	where 
		1=1
		AND MLI.WorkCenterCode = @pWorkCenterCode
		AND SPT.PrintTime between @FromDate AND @ToDate
	--	AND SPT.LotNo='VE250218-006'
		AND SPT.isPrinted=0
		AND PackQty >0
		group by 
		SPT.LotNo,SPT.PackingID,SPT.PackQty,SPT.MaterialCode,SPT.MaterialName,SPT.EmpNo,SPT.PartNo,SI.InputLineCode

		
END
