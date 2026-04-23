-- =============================================
-- Author:		Nguyễn Hải Triều(Mr.Dev)
-- Create date: 2026-04-23
-- Description:	Get data lot number inventory in cellLine for request Ms.Sao(Team Leader Proudction Support Team)
-- exec  usp_Vietnam_PackPrintTime_get '','','','2026-04-01','2026-04-01','','','','','VVT_F2'
-- =============================================
CREATE PROCEDURE [dbo].[usp_InventoryFinishGoodInCellLine]
	-- Add the parameters for the stored procedure here
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

    -- Insert statements for procedure here
  ;WITH tung AS (
        SELECT id,
            (SELECT TOP 1 newbarcode FROM STB_LotChangeMaterialHistory WITH(NOLOCK) WHERE oldBarcode=LotNo) AS newLotno,
            LotNo, PackingID, MaterialCode, MaterialName, EmpNo, PrintTime, PackQty, isPrinted, PartNo,
            (RANK() OVER (PARTITION BY LotNo, isPrinted ORDER BY PackQty DESC, printtime DESC)) AS RankPackQty,
            (ROW_NUMBER() OVER (PARTITION BY LotNo, isPrinted ORDER BY PackQty DESC, printtime DESC)) AS RowPackQty
        FROM [SmartFactoryV2].[dbo].[STB_SavePackingTime_VVT] DRI WITH(NOLOCK) 
        WHERE EmpNo NOT IN ('test_worker','assy_packing')
          AND PrintTime BETWEEN (CASE WHEN @LotNo <> '*' THEN '2020-08-15 10:00:00' ELSE @FromDate END) 
          AND (CASE WHEN @LotNo <> '*' THEN CONVERT(VARCHAR(19), GETDATE(), 120) ELSE @ToDate END) 
          AND PackQty > 1
          AND (isPrinted = 0 OR isPrinted = (CASE WHEN @LotNo <> '*' THEN 1 ELSE 0 END))
		  and LotNo not in (select LotNo from STB_VN_FINISHGOODS_BG UNION ALL select LotNo from STB_VN_FINISHGOODS)
		
    ),
    tung22 AS (
        SELECT a.*, b.InputLineCode, c.ProdDateTime, b.ControlNo,
            (ROW_NUMBER() OVER (PARTITION BY LotNo, isPrinted ORDER BY PackQty DESC, printtime DESC)) AS RowPackQty2
        FROM tung a WITH(NOLOCK)
        JOIN STB_SetInfo b WITH(NOLOCK) ON (a.LotNo = b.Barcode OR a.newLotno = b.Barcode)
        JOIN STB_ProdRouteHist c WITH(NOLOCK) ON b.ControlNo = c.ControlNo 
        AND c.RouteCode = CASE 
            WHEN @pWorkCenterCode = 'VVT_F1' THEN 'V-28'
            WHEN @pWorkCenterCode = 'VVT_F2' THEN 'V-28_BG'
            WHEN @pWorkCenterCode = 'VVT_F3' THEN 'VE10'
            ELSE '' END
        WHERE (@LineCode = '*' OR b.InputLineCode = @LineCode)
          AND (@LotNo = '*' OR a.LotNo = @LotNo OR a.newLotno = @LotNo)
          AND a.RowPackQty = 1
    )

	 SELECT 
        DRI.id, DRI.newLotno, DRI.LotNo, DRI.PackingID, DRI.MaterialCode,
        CASE WHEN DRI.MaterialCode = 'ECVT30-370' THEN 'HY-CAP VEC3R0387QG (3562-JIANGHAI)' ELSE DRI.MaterialName END AS MaterialName,
        DRI.EmpNo, DRI.PrintTime, DRI.PackQty,
        CASE WHEN isPrinted IS NULL OR isPrinted = 0 THEN 'Hien(show)' ELSE 'An(hide)' END AS isPrinted,
        DRI.PartNo, DRI.InputLineCode, DRI.ProdDateTime, DRI.ControlNo,
        ISNULL(DRI.PackQty, 0) * CONVERT(NUMERIC(38,15), ISNULL(vwup.PriceV28,0)) AS Price,
        (CASE  
            WHEN DRI.LotNo IN (SELECT * FROM stb_Changedate_B781_220924) THEN '2024-09-05'  
            WHEN DATEPART(HOUR, PrintTime) >= 10 THEN CONVERT(VARCHAR(10), PrintTime, 120)
            ELSE CASE WHEN DRI.LotNo IN ('VVNU212R750638') THEN CONVERT(VARCHAR(10), PrintTime, 120)
                 ELSE CONVERT(VARCHAR(10), DATEADD(DAY, -1, PrintTime), 120) END
        END) AS jobdate,
        SPQBL.SClass, SPQBL.AClass, SPQBL.BClass, SPQBL.CClass, SPQBL.DClass
	
	  
    FROM tung22 DRI
    LEFT OUTER JOIN STB_VVT_StagePrices vwup ON vwup.model = DRI.MaterialCode AND 'V-28' LIKE '%' + vwup.RouteV28 + '%'
    LEFT OUTER JOIN STB_SavePackingQtyByLevel_VVT SPQBL ON SPQBL.IDSPT = DRI.id
	 WHERE DRI.EmpNo NOT IN ('test_worker','assy_packing','assy_packing2','roh_worker','electrode_worker','dryroom_worker')
      AND (RowPackQty2 = 1 OR RowPackQty2 < (CASE WHEN @LotNo <> '*' THEN 50 ELSE 2 END))  
      --and DRI.LotNo='VVQL293R072753'
    ORDER BY DRI.LotNo, DRI.PrintTime, DRI.EmpNo
	
END
