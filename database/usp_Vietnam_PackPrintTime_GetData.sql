Text
----
-- =============================================

-- Author:		Nguy?n H?i Tri?u

-- Create date: 2026-03-20

-- Description:	Hi?n th? s?n lu?ng trong ngày b?n dùng l?y mã di?n c?c dùng cho con hàng

-- usp_Vietnam_PackPrintTime_GetData '','','','2026-03-03','2026-03-03','','','','','VVT_F2'

-- =============================================

CREATE PROCEDURE [dbo].[usp_Vietnam_PackPrintTime_GetData]

	-- Add the parameters for the stored procedure here

    @pProcessUserID VARCHAR(20)= NULL,

	@pProcessLanguage VARCHAR(20)= NULL,

	@pCompanyCode VARCHAR(20) = NULL,  -- ??? ?? ??? ?? (2020.01.23)

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

	DECLARE @ToDate      VARCHAR(19) = CONVERT(VARCHAR(10), DATEADD(DAY, 1, CONVERT(smalldatetime, @pToDate)), 120) + ' 10:00:00'         -- ??? SELECT CONVERT(VARCHAR(10), DATEADD(DAY, 1, CONVERT(smalldatetime, '2019-09-17 00:01:09')), 121) + ' 08:30:00'   
 



	DECLARE	@RouteCode    VARCHAR(20) = CASE WHEN ISNULL(@pRouteCode, '') = ''   THEN '*' ELSE @pRouteCode  END

	DECLARE	@LineCode      VARCHAR(20) = CASE WHEN ISNULL(@pLineCode, '') = ''     THEN '*' ELSE @pLineCode     END

	DECLARE	@LotNo          VARCHAR(15) = CASE WHEN ISNULL(@pLotNo, '') = ''         THEN '*' ELSE @pLotNo         END

	DECLARE	@MaterialCode VARCHAR(30) = CASE WHEN ISNULL(@pMaterialCode, '') = '' THEN '*' ELSE @pMaterialCode END

BEGIN

	-- SET NOCOUNT ON added to prevent extra result sets from

	-- interfering with SELECT statements.



	SET NOCOUNT ON;



    UPDATE [SmartFactoryV2].[dbo].[STB_SavePackingTime_VVT]

    SET PackQty = -1 * PackQty, EmpNo = EmpNo + '.'

    WHERE PackQty > 0 

    AND PackingID IN (

        SELECT b.PackingID

        FROM [SmartFactoryV2].[dbo].[STB_SavePackingTime_VVT] a WITH(NOLOCK) 

        JOIN [SmartFactoryV2].[dbo].[STB_SavePackingTime_VVT] b WITH(NOLOCK) ON a.LotNo = LEFT(b.PackingID,14)

        WHERE a.id > 615234 AND b.id > 615234 AND a.PackQty > 0 AND b.PackQty > 0 

        AND a.LotNo <> b.LotNo AND a.isPrinted > 0 AND b.isPrinted > 0

    );

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

    ),

    RawMaterial AS (



        SELECT 

            vvt.LotNo,

            SUBSTRING(MAX(CASE WHEN RW.ProductGroupCode = 'ElectrodeM' THEN RW.RawMaterialBarcode END), 1, 14) AS ElectrodeM_Barcode_Short,

            SUBSTRING(MAX(CASE WHEN RW.ProductGroupCode = 'ElectrodeP' THEN RW.RawMaterialBarcode END), 1, 14) AS ElectrodeP_Barcode_Short

        FROM STB_SavePackingTime_VVT vvt

		LEFT JOIN STB_RawMaterialInputHist RW on vvt.LotNo=RW.Barcode

        WHERE vvt.PrintTime >= @FromDate AND vvt.PrintTime <= @ToDate  

          AND (@LotNo = '*' OR vvt.LotNo = @LotNo)

          AND RW.ProductGroupCode IN ('ElectrodeM', 'ElectrodeP') and PackQty>0

        GROUP BY vvt.LotNo

    ),

    MappedMaterials AS (

        SELECT 

            RM.*,

            SetM.MaterialCode AS ElectrodeM_Code,

            SetP.MaterialCode AS ElectrodeP_Code

        FROM RawMaterial RM

        LEFT JOIN STB_SetInfo SetM WITH(NOLOCK) ON RM.ElectrodeM_Barcode_Short = SetM.Barcode

        LEFT JOIN STB_SetInfo SetP WITH(NOLOCK) ON RM.ElectrodeP_Barcode_Short = SetP.Barcode

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

        SPQBL.SClass, SPQBL.AClass, SPQBL.BClass, SPQBL.CClass, SPQBL.DClass,

        -- L?y tên theo Alias T3, T4

		T10.ElectrodeM_Barcode_Short AS ElectrodeM_Code,

        T3.MaterialName AS ElectrodeM_Name,

		T10.ElectrodeP_Barcode_Short ASElectrodeP_Code,

        T4.MaterialName AS ElectrodeP_Name

	

	  

    FROM tung22 DRI

    LEFT OUTER JOIN STB_VVT_StagePrices vwup ON vwup.model = DRI.MaterialCode AND 'V-28' LIKE '%' + vwup.RouteV28 + '%'

    LEFT OUTER JOIN STB_SavePackingQtyByLevel_VVT SPQBL ON SPQBL.IDSPT = DRI.id

    LEFT JOIN MappedMaterials T10 ON DRI.LotNo = T10.LotNo 

    LEFT JOIN STB_MaterialMaster T3 WITH(NOLOCK) ON T10.ElectrodeM_Code = T3.MaterialCode

    LEFT JOIN STB_MaterialMaster T4 WITH(NOLOCK) ON T10.ElectrodeP_Code = T4.MaterialCode



    WHERE DRI.EmpNo NOT IN ('test_worker','assy_packing','assy_packing2','roh_worker','electrode_worker','dryroom_worker')

      AND (RowPackQty2 = 1 OR RowPackQty2 < (CASE WHEN @LotNo <> '*' THEN 50 ELSE 2 END))

    ORDER BY DRI.LotNo, DRI.PrintTime, DRI.EmpNo


END





