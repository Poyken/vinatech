
CREATE PROCEDURE [dbo].[usp_LotTrackingInfo_VVT2_get_Accounting] 
    @pProcessUserID VARCHAR(20),
    @pProcessLanguage VARCHAR(20),
    @pCompanyCode VARCHAR(20) = NULL,
    @pFromDate DATETIME = NULL,
    @pToDate DATETIME = NULL,
    @pRouteCode VARCHAR(20) = NULL,
    @pLineCode VARCHAR(20) = NULL,
    @pLotNo VARCHAR(20) = NULL,
    @pMaterialCode VARCHAR(30) = NULL,
    @pMarkingLetter VARCHAR(30) = NULL,
    @pWorkCenterCode VARCHAR(30) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @CompanyCode VARCHAR(20) = CASE WHEN ISNULL(@pCompanyCode,'') = '' THEN '*' ELSE @pCompanyCode END
    DECLARE @FromDate VARCHAR(19) = CONVERT(VARCHAR(10), @pFromDate, 120) + ' 10:00:00'
    DECLARE @ToDate VARCHAR(19) = CONVERT(VARCHAR(10), DATEADD(DAY, 1, CONVERT(smalldatetime, @pToDate)), 120) + ' 10:00:00'

    DECLARE @RouteCode VARCHAR(20) = CASE WHEN ISNULL(@pRouteCode, '') = '' THEN '*' ELSE @pRouteCode END
    DECLARE @LineCode VARCHAR(20) = CASE WHEN ISNULL(@pLineCode, '') = '' THEN '*' ELSE @pLineCode END
    DECLARE @LotNo VARCHAR(15) = CASE WHEN ISNULL(@pLotNo, '') = '' THEN '*' ELSE @pLotNo END
    DECLARE @MaterialCode VARCHAR(30) = CASE WHEN ISNULL(@pMaterialCode, '') = '' THEN '*' ELSE @pMaterialCode END
    DECLARE @MarkingLetter VARCHAR(30) = CASE WHEN ISNULL(@pMarkingLetter, '') = '' THEN '*' ELSE @pMarkingLetter END
    DECLARE @WorkCenterCode VARCHAR(30) = CASE WHEN ISNULL(@pWorkCenterCode, '') = '' THEN '*' ELSE @pWorkCenterCode END

    IF(@pWorkCenterCode <> 'tonghainhamay')
    BEGIN
        ;WITH ViewBarcode AS (
             SELECT c.Barcode
             FROM STB_SetInfo c WITH(NOLOCK) 
             LEFT OUTER JOIN STB_ProdRouteHist b WITH(NOLOCK) ON c.ControlNo=b.ControlNo   
             WHERE b.CompanyCode='VVT' AND b.WorkCenterCode = @WorkCenterCode AND b.ProdDateTime>=@FromDate AND b.ProdDateTime<@ToDate
             AND b.CreateUserID NOT IN ('test_worker','assy_packing','assy_packing2','roh_worker','electrode_worker','dryroom_worker' )
        ),
        RawView0 AS (
            SELECT b.CreateUserID, c.Barcode, b.RouteCode, b.RouteCode AS FindRouteCode, c.ControlNo, c.MaterialCode, InputLineCode, b.MachineCode, b.WorkerCode, SIExtText07, SIExtInt01,
            MAX(b.ProdQty) AS ProdQty, 
            SUM(CASE WHEN Y.TypeErrorCode IS NULL THEN ISNULL(a.DefectQty, 0) - ISNULL(a.RepairQty, 0) ELSE 0 END) AS DefectQty,
            CASE WHEN DI.DirectlyUnder IN (SELECT TypeErrorCode FROM STB_TypeErrorGroupOfFactory WHERE Y.TypeErrorCode='PQC') THEN SUM(a.DefectQty) - SUM(a.RepairQty) ELSE 0 END AS PQC,
            CASE WHEN DI.DirectlyUnder IN (SELECT TypeErrorCode FROM STB_TypeErrorGroupOfFactory WHERE Y.TypeErrorCode='Production_Defect') THEN SUM(a.DefectQty) - SUM(a.RepairQty) ELSE 0 END AS SX_NG,
            CASE WHEN DI.DirectlyUnder IN (SELECT TypeErrorCode FROM STB_TypeErrorGroupOfFactory WHERE Y.TypeErrorCode='Machine_Repair') THEN SUM(a.DefectQty) - SUM(a.RepairQty) ELSE 0 END AS SuaMay,
            CASE WHEN DI.DirectlyUnder IN (SELECT TypeErrorCode FROM STB_TypeErrorGroupOfFactory WHERE Y.TypeErrorCode='Regular_Production_Checks') THEN SUM(a.DefectQty) - SUM(a.RepairQty) ELSE 0 END AS Ktra_ThuongxuyenSX,
            CASE WHEN DI.DirectlyUnder IN (SELECT TypeErrorCode FROM STB_TypeErrorGroupOfFactory WHERE Y.TypeErrorCode='Fixed_Production_Inspection') THEN SUM(a.DefectQty) - SUM(a.RepairQty) ELSE 0 END AS Ktra_CoDinhSX,      
            CASE WHEN DI.DirectlyUnder IN (SELECT TypeErrorCode FROM STB_TypeErrorGroupOfFactory WHERE Y.TypeErrorCode='NG_Setup_Machine') THEN SUM(a.DefectQty) - SUM(a.RepairQty) ELSE 0 END AS SetupMay,
            MAX(b.ProdDateTime) AS ProdDateTime, MAX(b.CreateDateTime) AS CreateDateTime
            FROM STB_SetInfo c WITH(NOLOCK) 
            LEFT OUTER JOIN STB_ProdRouteHist b WITH(NOLOCK) ON c.ControlNo=b.ControlNo  
            LEFT OUTER JOIN STB_DefectRepairInfo a WITH(NOLOCK) ON a.ControlNo=c.ControlNo AND a.FindRouteCode = b.RouteCode
            LEFT OUTER JOIN STB_ProductionOrderInfo POI WITH(NOLOCK) ON c.PoNo = POI.PoNo
            LEFT OUTER JOIN STB_DefectInfo di WITH(NOLOCK) ON a.DefectCode = di.DefectCode
            LEFT OUTER JOIN STB_TypeErrorGroupOfFactory Y WITH(NOLOCK) ON Y.TypeErrorCode = di.DirectlyUnder
            WHERE c.Barcode IN (SELECT Barcode FROM ViewBarcode WITH(NOLOCK))
            AND b.ProdDateTime>@FromDate AND b.ProdDateTime<@ToDate
            AND b.CreateUserID NOT IN ('test_worker','assy_packing','assy_packing2','roh_worker','electrode_worker','dryroom_worker' )
            GROUP BY b.CreateUserID,c.Barcode,b.RouteCode,c.ControlNo,c.MaterialCode,InputLineCode,b.MachineCode,b.WorkerCode,SIExtText07,SIExtInt01,a.DefectCode,POI.DefectSummaryNoBeforeDroping,di.DirectlyUnder,di.DefectCode,Y.TypeErrorCode
        ),
        RawView AS (
            SELECT CreateUserID, Barcode, RouteCode, FindRouteCode, ControlNo, MaterialCode, InputLineCode, MachineCode, WorkerCode, SIExtText07, SIExtInt01,
            MAX(ProdQty) AS ProdQty, 
            SUM(DefectQty)+SUM(SX_NG)+SUM(SuaMay)+SUM(Ktra_ThuongxuyenSX)+SUM(Ktra_CoDinhSX)+SUM(SetupMay)+SUM(PQC) AS DefectQty,
            SUM(DefectQty)+SUM(SX_NG)+SUM(SuaMay)+SUM(Ktra_ThuongxuyenSX)+SUM(Ktra_CoDinhSX)+SUM(SetupMay) AS DefectQty1,
            SUM(SuaMay)+SUM(SetupMay) AS DefectMachine,
            SUM(DefectQty)+SUM(SX_NG)+SUM(Ktra_ThuongxuyenSX)+SUM(Ktra_CoDinhSX)+SUM(PQC) AS DefectNornal,
            SUM(PQC) AS PQC,
            SUM(SetupMay) AS SetupMay,
            SUM(SX_NG) AS SX_NG,
            SUM(SuaMay) AS SuaMay,
            SUM(Ktra_ThuongxuyenSX) AS Ktra_ThuongxuyenSX,
            SUM(Ktra_CoDinhSX) AS Ktra_CoDinhSX,
            MAX(ProdDateTime) AS ProdDateTime, MAX(CreateDateTime) AS CreateDateTime
            FROM RawView0       
            GROUP BY CreateUserID,Barcode,RouteCode,FindRouteCode,ControlNo,MaterialCode,InputLineCode,MachineCode,WorkerCode,SIExtText07,SIExtInt01
        ),
        DRI AS (
            SELECT DISTINCT RV.Barcode, RV.RouteCode, RV.RouteCode AS FindRouteCode, ControlNo, RV.MaterialCode,
            CASE 
                WHEN RV.MaterialCode ='ECVT30-336' THEN 'VVVEC30-059'
                WHEN RV.MaterialCode='ECVT30-344' then 'VVWEC30-054'
                WHEN RV.MaterialCode='ECVT30-356' then 'VVWECT30-054'
                WHEN RV.MaterialCode='ECVT27-322' then 'VVVEC27-001'
                WHEN RV.MaterialCode='ECVT30-219' then 'VVVEC30-001'
                WHEN RV.MaterialCode='ECVT30-371' then 'VVWEC30-078'
                WHEN RV.MaterialCode='RE3000-100' then 'VVWEC30-056'
                WHEN RV.MaterialCode='ECVT27-323' then 'VVWEC27-001'
                WHEN RV.MaterialCode='ECVT30-220' then 'VVWEC30-001'
                WHEN RV.MaterialCode='ECVT30-313' then 'VVWECT30-001'
                WHEN RV.MaterialCode='ECVT30-331' then 'VVWEC30-044'
                WHEN RV.MaterialCode='RE3000-131' then 'VVWEC30-075'
                WHEN RV.MaterialCode='ECVT27-372' then 'VVVEC27-003'
                WHEN RV.MaterialCode='ECVT30-278' then 'VVVEC30-004'
                WHEN RV.MaterialCode='ECVT27-373' THEN 'VVWEC27-003'
                WHEN RV.MaterialCode='ECVT30-276' THEN 'VVWEC30-004'
                WHEN RV.MaterialCode='ECVT30-285' THEN 'VVWECT30-004'
                WHEN RV.MaterialCode='ECVT30-268' THEN 'VVWEC30-005'
                WHEN RV.MaterialCode='ECVT30-360' THEN 'VVWEC30-072'
                WHEN RV.MaterialCode='ECVT30-229' THEN 'VNWEC30-032'
                WHEN RV.MaterialCode='RE2700-089' THEN 'VVVET27-008'
                WHEN RV.MaterialCode='LIVT38-018' THEN 'VNVEL38-001'
                WHEN RV.MaterialCode='LIVT38-030' THEN 'VNVEL38-011'
                WHEN RV.MaterialCode='LIVT38-019' THEN 'VNVEL38-002'
                WHEN RV.MaterialCode='ECVT27-374' THEN 'VVVEC27-035'
                WHEN RV.MaterialCode='ECVT30-279' THEN 'VVVEC30-006'
                WHEN RV.MaterialCode='ECVT30-353' THEN 'VVWECT30-006'
                WHEN RV.MaterialCode='LIVT38-026' THEN 'VNVEL38-006'
                WHEN RV.MaterialCode='ECVT30-275' THEN 'VVWEC30-006'
                WHEN RV.MaterialCode='ECVT30-281' THEN 'VVWEC30-007'
                WHEN RV.MaterialCode='ECVT30-305' THEN 'VVWECT30-007'
                WHEN RV.MaterialCode='RE2700-083' THEN 'VVVET27-001'
                WHEN RV.MaterialCode='ECVT30-347' THEN 'VVWEC30-062'
                WHEN RV.MaterialCode='ECVT27-334' THEN 'VVVEC27-005'
                WHEN RV.MaterialCode='ECVT30-234' THEN 'VVVEC30-008'
                WHEN RV.MaterialCode='ECVT30-335' THEN 'VVWECT30-008'
                WHEN RV.MaterialCode='ECVT30-235' THEN 'VVWEC30-008'
                WHEN RV.MaterialCode='ECVT30-283' THEN 'VVWEC30-012'
                WHEN RV.MaterialCode='ECVT30-318' THEN 'VVWECT30-012'
                WHEN RV.MaterialCode='ECVT27-367' THEN 'VVVEC27-011'
                WHEN RV.MaterialCode='ECVT30-269' THEN 'VVVEC30-013'
                WHEN RV.MaterialCode='ECVT27-368' THEN 'VVWEC27-011'
                WHEN RV.MaterialCode='ECVT30-292' THEN 'VVWEC30-033'
                WHEN RV.MaterialCode='ECVT30-270' THEN 'VVWEC30-013'
                WHEN RV.MaterialCode='RDMD00-V01' THEN 'VVWEC30-048'
                WHEN RV.MaterialCode='ECVT30-295' THEN 'VVWEC30-035'
                WHEN RV.MaterialCode='ECVT27-399' THEN 'VVVET27-003'
                WHEN RV.MaterialCode='ECVT27-343' THEN 'VVVEC27-012'
                WHEN RV.MaterialCode='ECVT30-246' THEN 'VVVEC30-014'
                WHEN RV.MaterialCode='ECVT30-345' THEN 'VVWEC30-055'
                WHEN RV.MaterialCode='ECVT28-001' THEN 'VVVEC28-001'
                WHEN RV.MaterialCode='ECVT25-116' THEN 'VVVEC30-047'
                WHEN RV.MaterialCode='ECVT27-344' THEN 'VVWEC27-012'
                WHEN RV.MaterialCode='ECVT27-370' THEN 'VVWEC27-015'
                WHEN RV.MaterialCode='ECVT30-247' THEN 'VVWEC30-014'
                WHEN RV.MaterialCode='ECVT30-307' THEN 'VVWECT30-014'
                WHEN RV.MaterialCode='RE3000-119' THEN 'VVWEC30-074'
                WHEN RV.MaterialCode='ECVT30-334' THEN 'VVWEC30-039'
                WHEN RV.MaterialCode='RE3000-129' THEN 'VVWEC30-073'
                WHEN RV.MaterialCode='RE3000-134' THEN 'VVWEC30-076'
                WHEN RV.MaterialCode='ECVT30-346' THEN 'VVWEC30-065'
                WHEN RV.MaterialCode='ECVT27-386' THEN 'VVVEC27-014'
                WHEN RV.MaterialCode='RE3000-105' THEN 'VVWEC30-059'
                WHEN RV.MaterialCode='ECVT30-301' THEN 'VVWECT30-037'
                WHEN RV.MaterialCode='ECVT27-388' THEN 'VVVET27-004'
                WHEN RV.MaterialCode='LIVT38-007' THEN 'VNVEL38-004'
                WHEN RV.MaterialCode='RE3800-019' THEN 'VNVEL38-014'
                WHEN RV.MaterialCode='RE3000-109' THEN 'VVWEC30-067'
                WHEN RV.MaterialCode='ECVT30-367' THEN 'VVWEC30-024'
                WHEN RV.MaterialCode='ECVT30-369' THEN 'VVWECT30-024'
                WHEN RV.MaterialCode='ECVT30-309' THEN 'VVWEC30-038'
                WHEN RV.MaterialCode='RE2700-090' THEN 'VVVET27-011'
                WHEN RV.MaterialCode='LIVT38-032' THEN 'VNVEL38-012'
                WHEN RV.MaterialCode='LIVT38-016' THEN 'VNVEL38-020'
                WHEN RV.MaterialCode='LIVT38-035' THEN 'VNVEL38-019'
                WHEN RV.MaterialCode='ECVT30-250' THEN 'VVWEC30-017'
                WHEN RV.MaterialCode='ECVT30-341' THEN 'VVWECT30-017'
                WHEN RV.MaterialCode='RE3000-098' THEN 'VVWEC30-052'
                WHEN RV.MaterialCode='ECVT30-352' THEN 'VVWEC30-060'
                WHEN RV.MaterialCode='RE3000-123' THEN 'VVWEC30-068'
                WHEN RV.MaterialCode='ECVT30-251' THEN 'VVVEC30-022'
                WHEN RV.MaterialCode='ECVT27-350' THEN 'VVWEC27-018'
                WHEN RV.MaterialCode='ECVT30-359' THEN 'VVWEC30-071'
                WHEN RV.MaterialCode='ECVT30-262' THEN 'VVWEC30-018'
                WHEN RV.MaterialCode='ECVT30-350' THEN 'VVWECT30-018'
                WHEN RV.MaterialCode='ECVT27-383' THEN 'VVVEC27-017'
                WHEN RV.MaterialCode='ECVT30-134' THEN 'VVVEC30-044'
                WHEN RV.MaterialCode='ECVT30-312' THEN 'VVWECT30-022'
                WHEN RV.MaterialCode='ECVT30-288' THEN 'VVVEC30-045'
                WHEN RV.MaterialCode='ECVT30-289' THEN 'VVVEC30-050'
                WHEN RV.MaterialCode='ECVT27-405' THEN 'VVVET27-010'
                WHEN RV.MaterialCode='RE2700-088' THEN 'VVVET27-005'
                WHEN RV.MaterialCode='ECVT30-354' THEN 'VVWEC30-066'
                WHEN RV.MaterialCode='LIVT38-008' THEN 'VNVEL38-008'
                WHEN RV.MaterialCode='LIVT30-022'  THEN 'VNVEL38-005'
                WHEN RV.MaterialCode='RE3800-026'  THEN 'VNVEL38-016'
                WHEN RV.MaterialCode='LIVT38-031'  THEN 'VNVEL38-013'
                WHEN RV.MaterialCode='LIVT38-033'  THEN 'VNVEL38-017'
                WHEN RV.MaterialCode='LIVT38-034'  THEN 'VNVEL38-018'
                WHEN RV.MaterialCode='LIVT38-027'  THEN 'VNVEL38-003'
                WHEN RV.MaterialCode='LIVT38-015'  THEN 'VNVEL38-015'
                WHEN RV.MaterialCode='ECVT30-333'  THEN 'VVVEC30-057'
                WHEN RV.MaterialCode='ECVT27-382'  THEN 'VVVEC27-032'
                WHEN RV.MaterialCode='ECVT27-403'  THEN 'VVVEC27-040'
                WHEN RV.MaterialCode='ECVT30-310'  THEN 'VVWEC30-045'
                WHEN RV.MaterialCode='ECVT27-352'  THEN 'VVVEC27-020'
                WHEN RV.MaterialCode='ECVT30-254'  THEN 'VVVEC30-023'
                WHEN RV.MaterialCode='ECVT30-120'  THEN 'VVVEC30-024'
                WHEN RV.MaterialCode='ECVT27-353'  THEN 'VVWEC27-020'
                WHEN RV.MaterialCode='ECVT30-297'  THEN 'YSECVT30-317'
                WHEN RV.MaterialCode='ECVT30-317'  THEN 'VVWEC30-040'
                WHEN RV.MaterialCode='ECVT30-348'  THEN 'VVWEC30-063'
                WHEN RV.MaterialCode='ECVT30-273'  THEN 'VVWEC30-026'
                WHEN RV.MaterialCode='RE3000-122'  THEN 'VVWEC30-069'
                WHEN RV.MaterialCode='HCVT23-061'  THEN 'VVVHC23-007'
                WHEN RV.MaterialCode='ECVT27-401'  THEN 'VVVET27-007'
                WHEN RV.MaterialCode='ECVT30-284'  THEN 'VVWEC30-028'
                WHEN RV.MaterialCode='ECVT27-356'  THEN 'VVWEC27-022'
                WHEN RV.MaterialCode='ECVT27-397'  THEN 'VVWECT27-022'
                WHEN RV.MaterialCode='ECVT27-355'  THEN 'VVVEC27-022'
                WHEN RV.MaterialCode='ECVT27-358'  THEN 'VVVEC27-023'
                WHEN RV.MaterialCode='ECVT30-343'  THEN 'VVWEC30-053'
                WHEN RV.MaterialCode='ECVT30-261'  THEN 'VVWEC30-030'
                WHEN RV.MaterialCode='ECVT27-400'  THEN 'VVVET27-006'
                WHEN RV.MaterialCode='ECVT30-258'  THEN 'VVWEC30-029'
                WHEN RV.MaterialCode='ECVT30-257'  THEN 'VVVEC30-029'
                WHEN RV.MaterialCode='ECVT30-260'  THEN 'VVVEC30-030'
                WHEN RV.MaterialCode='RE3000-120'  THEN 'VVVEC30-061'
                WHEN RV.MaterialCode='ECVT30-271'  THEN 'VVVEC30-031'
                WHEN RV.MaterialCode='ECVT30-287'  THEN 'VVWEC30-036'
                WHEN RV.MaterialCode='ECVT27-247'  THEN 'VVVEC27-025'
                WHEN RV.MaterialCode='ECVT30-115'  THEN 'VVVEC30-033'
                WHEN RV.MaterialCode='ECVT30-316'  THEN 'VVVEC30-054'
                WHEN RV.MaterialCode='ECVT30-113'  THEN 'VVVEC30-032'
                WHEN RV.MaterialCode='ECVT30-372'  THEN 'VVVEC30-056'
                WHEN RV.MaterialCode='RE3000-125'  THEN 'VVVEC30-063'
                WHEN RV.MaterialCode='RE3000-136'  THEN 'VVVEC30-041'
                WHEN RV.MaterialCode='ECVT30-215'  THEN 'VVVEC30-052'
                WHEN RV.MaterialCode='RE3000-116'  THEN 'VVVES-001'
                WHEN RV.MaterialCode='RE3000-096'  THEN 'VVVEC30-S01'
                WHEN RV.MaterialCode='ECVT30-342'  THEN 'VVVEC30-058'
                WHEN RV.MaterialCode='ECVT30-104'  THEN 'VNVEC30-039'
                WHEN RV.MaterialCode='ECVT27-213'  THEN 'VVVEC27-028'
                WHEN RV.MaterialCode='ECVT30-204'  THEN 'VVVEC30-035'
                WHEN RV.MaterialCode='ECVT30-370'  THEN 'SGSJHSC-001'
                WHEN RV.MaterialCode='RE3000-118'  THEN 'VVVES-002'
                WHEN RV.MaterialCode='ECVT30-116'  THEN 'VVVEC30-038'
                WHEN RV.MaterialCode='RE3000-071'  THEN 'VVVEC30-S56'
                WHEN RV.MaterialCode='ECVT30-076'  THEN 'VVVEC30-043'
                WHEN RV.MaterialCode='ECVT30-358'  THEN 'VVVEC30-062'
                WHEN RV.MaterialCode='ECVT30-117'  THEN 'VVVEC30-046'
                WHEN RV.MaterialCode='RDMD00-287'  THEN 'MVCE60-096'
                WHEN RV.MaterialCode='RDMD00-307'  THEN 'MVCE60-103'
                WHEN RV.MaterialCode='RDMD00-345'  THEN 'MVCE60-119'
                WHEN RV.MaterialCode='RDMD00-301'  THEN 'MVCE60-100'
                WHEN RV.MaterialCode='RDMD00-330'  THEN 'MVCE60-109'
                WHEN RV.MaterialCode='ECVT54-055'  THEN 'MVCE54-001'
                WHEN RV.MaterialCode='EDVTMD-153'  THEN 'MVCE54-003'
                WHEN RV.MaterialCode='EDVTMD-142'  THEN 'MVCE54-024'
                WHEN RV.MaterialCode='EDVTMD-206'  THEN 'MVCE54-026'
                WHEN RV.MaterialCode='EDVTMD-161'  THEN 'MVCE60-001'
                WHEN RV.MaterialCode='EDVTMD-151'  THEN 'MVCE60-002'
                WHEN RV.MaterialCode='EDVTMD-203'  THEN 'MVCE60-087'
                WHEN RV.MaterialCode='EDVTMD-152'  THEN 'MVCE60-003'
                WHEN RV.MaterialCode='RDMD00-349'  THEN 'MVCE60-123'
                WHEN RV.MaterialCode='RDMD00-350'  THEN 'MVCE60-122'
                WHEN RV.MaterialCode='EDVTMD-237'  THEN 'MVCE60-137'
                WHEN RV.MaterialCode='EDVTMD-205'  THEN 'MVCE60-086'
                WHEN RV.MaterialCode='EDVTMD-146'  THEN 'MVCE54-004'
                WHEN RV.MaterialCode='RDMD00-369'  THEN 'MVCE54-131'
                WHEN RV.MaterialCode='ECVT54-060'  THEN 'MVCE54-005'
                WHEN RV.MaterialCode='EDVTMD-190'  THEN 'MVCE60-019'
                WHEN RV.MaterialCode='EDVTMD-187'  THEN 'MVCE60-007'
                WHEN RV.MaterialCode='EDVTMD-095'  THEN 'MVCE60-018'
                WHEN RV.MaterialCode='EDVTMD-217'  THEN 'MVCE90-002'
                WHEN RV.MaterialCode='EDVTMD-174'  THEN 'MVCE60-027'
                WHEN RV.MaterialCode='RDMD00-238'  THEN 'MVCE60-076'
                WHEN RV.MaterialCode='EDVTMD-230'  THEN 'MVCE60-128'
                WHEN RV.MaterialCode='RDMD00-378'  THEN 'MVCE60-138'
                WHEN RV.MaterialCode='EDVTMD-188'  THEN 'MVCE60-075'
                WHEN RV.MaterialCode='RDMD00-313'  THEN 'MVCE60-101'
                WHEN RV.MaterialCode='EDVTMD-199'  THEN 'MVCE60-085'
                WHEN RV.MaterialCode='EDVTMD-197'  THEN 'MVCE60-079'
                WHEN RV.MaterialCode='EDVTMD-201'  THEN 'MVCE60-084'
                WHEN RV.MaterialCode='EDVTMD-235'  THEN 'RVVCE60-136'
                WHEN RV.MaterialCode='RDMD00-292'  THEN 'MVCE60-117'
                WHEN RV.MaterialCode='RDMD00-203'  THEN 'MVCE60-088'
                WHEN RV.MaterialCode='EDVTMD-204'  THEN 'MVCE60-089'
                WHEN RV.MaterialCode='EDVTMD-169'  THEN 'MVCE90-001'
                WHEN RV.MaterialCode='EDVTMD-182'  THEN 'MVCE60-020'
                WHEN RV.MaterialCode='RDMD00-353'  THEN 'MVCE60-124'
                WHEN RV.MaterialCode='EDVTMD-207'  THEN 'MVCE60-080'
                WHEN RV.MaterialCode='RDMD00-285'  THEN 'MVCE54-056'
                WHEN RV.MaterialCode='ECVT54-054'  THEN 'MVCE54-050'
                WHEN RV.MaterialCode='EDVTMD-193'  THEN 'MVCE60-063'
                WHEN RV.MaterialCode='RDMD00-347'  THEN 'MVCE60-121'
                WHEN RV.MaterialCode='EDVTMD-234'  THEN 'MVCE60-129'
                WHEN RV.MaterialCode='EDVTMD-S01'  THEN 'MVCE60-104'
                WHEN RV.MaterialCode='RDMD00-339'  THEN 'MVCE60-114'
                WHEN RV.MaterialCode='EDVTMD-221'  THEN 'MVCE60-016'
                WHEN RV.MaterialCode='RDMD00-319'  THEN 'MVCE60-105'
                WHEN RV.MaterialCode='EDVTMD-191'  THEN 'MVCE60-070'
                WHEN RV.MaterialCode='EDVTMD-232'  THEN 'MVCE60-132'
                WHEN RV.MaterialCode='ECVT54-009'  THEN 'MVCE54-009'
                WHEN RV.MaterialCode='ECVT54-056'  THEN 'MVCE54-010'
                WHEN RV.MaterialCode='ECVT60-013'  THEN 'MVCE60-008'
                WHEN RV.MaterialCode='EDVTMD-210'  THEN 'MVCE60-095'
                WHEN RV.MaterialCode='ECVT60-011'  THEN 'MVCE60-009'
                WHEN RV.MaterialCode='RDMD00-217'  THEN 'MVCE60-036'
                WHEN RV.MaterialCode='EDVTMD-181'  THEN 'MVCE60-034'
                WHEN RV.MaterialCode='EDVTMD-179'  THEN 'MVCE60-064'
                WHEN RV.MaterialCode='EDVTMD-184'  THEN 'MVCE60-066'
                WHEN RV.MaterialCode='RDMD00-329'  THEN 'MVCE60-108'
                WHEN RV.MaterialCode='EDVTMD-231'  THEN 'MVCE60-134'
                WHEN RV.MaterialCode='EDVTMD-149'  THEN 'MVCE54-015'
                WHEN RV.MaterialCode='EDVTMD-127'  THEN 'MVCE54-128'
                WHEN RV.MaterialCode='ECVT60-020'  THEN 'MVCE60-067'
                WHEN RV.MaterialCode='RDMD00-V02'  THEN 'MVCE60-091'
                WHEN RV.MaterialCode='RDMD00-332'  THEN 'MVCE60-112'
                WHEN RV.MaterialCode='RDMD00-228'  THEN 'MVCE60-073'
                WHEN RV.MaterialCode='EDVTMD-200'  THEN 'MVCE60-072'
                WHEN RV.MaterialCode='RDMD00-282'  THEN 'MVCE60-097'
                WHEN RV.MaterialCode='EDVTMD-158'  THEN 'MVCE54-031'
                WHEN RV.MaterialCode='RDMD00-230'  THEN 'MVCE54-129'
                WHEN RV.MaterialCode='EDVTMD-163'  THEN 'MVCC60-071'
                WHEN RV.MaterialCode='RDMD00-380'  THEN 'MVCE54-132'
                WHEN RV.MaterialCode='EDVTMD-139'  THEN 'MVCR01-006'
                WHEN RV.MaterialCode='EDVTMD-148'  THEN 'MVCE54-016'
                WHEN RV.MaterialCode='EDVTMD-167'  THEN 'MVCE54-017'
                WHEN RV.MaterialCode='EDVTMD-202'  THEN 'MVCE54-055'
                WHEN RV.MaterialCode='RDMD00-364'  THEN 'MVCE54-130'
                WHEN RV.MaterialCode='ECVT60-009'  THEN 'MVCC60-011'
                WHEN RV.MaterialCode='EDVTMD-194'  THEN 'MVCE60-012'
                WHEN RV.MaterialCode='EDVTMD-192'  THEN 'MVCE60-025'
                WHEN RV.MaterialCode='RDMD00-123'  THEN 'MVCE60-026'
                WHEN RV.MaterialCode='ECVT60-010'  THEN 'MVCE60-030'
                WHEN RV.MaterialCode='RDMD00-261'  THEN 'MVCC60-098'
                WHEN RV.MaterialCode='EDVTMD-226'  THEN 'MVCE60-113'
                WHEN RV.MaterialCode='RDMD00-136'  THEN 'MVCC120-002'
                WHEN RV.MaterialCode='EDVTMD-164'  THEN 'MVCE54-019'
                WHEN RV.MaterialCode='ECVT54-061'  THEN 'MVCE54-020'
                WHEN RV.MaterialCode='ECVT60-012'  THEN 'MVCC60-013'
                WHEN RV.MaterialCode='EDVTMD-222'  THEN 'MVCE60-094'
                WHEN RV.MaterialCode='RDMD00-322'  THEN 'MVCE60-102'
                WHEN RV.MaterialCode='EDVTMD-220'  THEN 'MVCE60-107'
                WHEN RV.MaterialCode='RDMD00-272'  THEN 'MVCE60-069'
                WHEN RV.MaterialCode='EDVTMD-198'  THEN 'MVCE60-078'
                WHEN RV.MaterialCode='EDVTMD-156'  THEN 'MVCE60-015'
                WHEN RV.MaterialCode='RDMD00-346'  THEN 'MVCE60-120'
                WHEN RV.MaterialCode='RDMD00-356'  THEN 'MVCE60-126'
                WHEN RV.MaterialCode='RDMD00-366'  THEN 'MVCE60-135'
                WHEN RV.MaterialCode='RDMD00-360'  THEN 'MVCE60-130'
                WHEN RV.MaterialCode='RDMD00-355'  THEN 'MVCE60-127'
                WHEN RV.MaterialCode='EDVTMD-118'  THEN 'MVCC60-062'
                WHEN RV.MaterialCode='RDMD00-289'  THEN 'MVCE60-082'
                WHEN RV.MaterialCode='RDMD00-250'  THEN 'MVCE60-083'
                WHEN RV.MaterialCode='RDMD00-276'  THEN 'MVCE60-092'
                WHEN RV.MaterialCode='RDMD00-359'  THEN 'MVCE60-131'
                WHEN RV.MaterialCode='RDMD00-266'  THEN 'MVCE60-090'
                WHEN RV.MaterialCode='EDVTMD-183'  THEN 'MVCE90-065'
                WHEN RV.MaterialCode='RDMD00-368'  THEN 'MVCE90-066'
                WHEN RV.MaterialCode='ECVT54-033'  THEN 'MVCE54-039'
                WHEN RV.MaterialCode='EDVTMD-160'  THEN 'MVCE120-001'
                WHEN RV.MaterialCode='EDVTMD-216'  THEN 'MVCE120-003'
                WHEN RV.MaterialCode='EDVTMD-144'  THEN 'MVCE60-017'
                ELSE ''
            END AS MaterialCodeVN,
            RV.InputLineCode, RV.MachineCode, RV.WorkerCode, RV.SIExtText07, RV.SIExtInt01,
            RI.RouteName, MM2.MaterialName, LI.LineName, PWI.WorkerName, MM.MachineName, RV.ProdDateTime, RV.CreateUserID,
            (CASE 
                WHEN RV.Barcode IN (SELECT * FROM stb_Changedate220924) THEN '2024-07-19'
                WHEN (DATEPART(HOUR, ProdDateTime)>10) OR (DATEPART(HOUR, ProdDateTime)=10 AND DATEPART(MINUTE, ProdDateTime)>0)
                THEN CONVERT(VARCHAR(10), ProdDateTime, 120)
                ELSE CONVERT(VARCHAR(10), DATEADD(DAY, -1, ProdDateTime), 120)
            END) AS JobDate,
            MAX(RV.ProdQty) AS ProdQty, SUM(RV.DefectQty) AS DefectQty, SUM(RV.DefectQty1) AS DefectQty1,
            SUM(DefectMachine) AS DefectMachine, SUM(DefectNornal) AS DefectNornal, SUM(PQC) AS PQC,
            SUM(SetupMay) AS SetupMay, SUM(SX_NG) AS SX_NG, SUM(SuaMay) AS SuaMay, SUM(Ktra_ThuongxuyenSX) AS Ktra_ThuongxuyenSX, SUM(Ktra_CoDinhSX) AS Ktra_CoDinhSX
            FROM RawView RV WITH(NOLOCK)
            OUTER APPLY (SELECT TOP 1 * FROM STB_RouteInfo RI WITH(NOLOCK) WHERE RV.RouteCode = RI.RouteCode) RI
            OUTER APPLY (SELECT TOP 1 * FROM STB_MaterialMaster MM2 WITH(NOLOCK) WHERE MM2.MaterialCode = RV.MaterialCode) MM2
            OUTER APPLY (SELECT TOP 1 * FROM STB_LineInfo LI WITH(NOLOCK) WHERE RV.InputLineCode = LI.LineCode) LI
            OUTER APPLY (SELECT TOP 1 * FROM STB_MachineMaster MM WITH(NOLOCK) WHERE RV.MachineCode = MM.MachineCode) MM
            OUTER APPLY (SELECT TOP 1 * FROM STB_ProdWorkerInfo PWI WITH(NOLOCK) WHERE RV.WorkerCode = PWI.WorkerCode) PWI
            GROUP BY RV.CreateUserID,RV.Barcode,RV.RouteCode,ControlNo,RV.MaterialCode,RV.InputLineCode,RV.MachineCode,RV.WorkerCode,RV.SIExtText07,RV.SIExtInt01,RI.RouteName,MM2.MaterialName,LI.LineName,PWI.WorkerName,MM.MachineName,RV.ProdDateTime
        )
        SELECT DISTINCT 'VVT' AS 사업장, DRI.ControlNo, DRI.Barcode, DRI.MaterialCode, DRI.MaterialCodeVN, MM2.MaterialName, DRI.InputLineCode, LI.LineName, DRI.RouteCode, RI.RouteName, CONVERT(DATETIME, DRI.ProdDateTime, 120) AS ProdDateTime, DRI.JobDate, DRI.MachineCode, MM.MachineName, MM.MachineNumber, DRI.WorkerCode, PWI.WorkerName,
        CASE WHEN DRI.SIExtInt01 IS NULL THEN '' WHEN DRI.SIExtInt01 = 1 THEN '검사불합격' WHEN DRI.SIExtInt01 = 0 THEN '검사불합격이력' END AS RouteInspectionResult,
        DRI.ProdQty AS InputProdQty, ISNULL(DRI.DefectQty, 0) AS DefectQty, ISNULL(DRI.DefectQty1, 0) AS DefectQty1, weightLast.valweight AS WeightUnit, ISNULL(DRI.DefectQty, 0) * weightLast.valweight/1000 AS WasteWeight,
        (DRI.ProdQty - ISNULL(DRI.DefectQty, 0) - ISNULL(PQC, 0) - ISNULL(SX_NG, 0) - ISNULL(SuaMay, 0) - ISNULL(Ktra_ThuongxuyenSX, 0) - ISNULL(Ktra_CoDinhSX, 0)) - ISNULL(SetupMay, 0) AS ProdQty,
        SIExtText07 AS MarkingLetter,
        ISNULL(DRI.DefectQty, 0) * CASE WHEN ProdDateTime<'2023-10-01' THEN ISNULL(vwup.ProcessUnitPriceEA, 0) WHEN ProdDateTime>='2023-10-01' THEN ISNULL(vwupNEW.ProcessUnitPriceEA, vwupNEW1.ProcessUnitPriceEA) ELSE 0 END AS DefectPrice,
        ISNULL(DRI.DefectQty1, 0) * CASE WHEN ProdDateTime<'2023-10-01' THEN ISNULL(vwup.ProcessUnitPriceEA, 0) WHEN ProdDateTime>='2023-10-01' THEN ISNULL(vwupNEW.ProcessUnitPriceEA, vwupNEW1.ProcessUnitPriceEA) ELSE 0 END AS DefectPriceSX,
        ISNULL(DRI.ProdQty, 0) * CASE WHEN ProdDateTime<'2023-10-01' THEN ISNULL(vwup.ProcessUnitPriceEA, 0) WHEN ProdDateTime>='2023-10-01' THEN ISNULL(vwupNEW.ProcessUnitPriceEA, vwupNEW1.ProcessUnitPriceEA) ELSE 0 END AS BeginPrice,
        ISNULL(DRI.DefectMachine, 0) * CASE WHEN ProdDateTime<'2023-10-01' THEN ISNULL(vwup.ProcessUnitPriceEA, 0) WHEN ProdDateTime>='2023-10-01' THEN ISNULL(vwupNEW.ProcessUnitPriceEA, vwupNEW1.ProcessUnitPriceEA) ELSE 0 END AS DefectMachine,
        ISNULL(DRI.DefectNornal, 0) * CASE WHEN ProdDateTime<'2023-10-01' THEN ISNULL(vwup.ProcessUnitPriceEA, 0) WHEN ProdDateTime>='2023-10-01' THEN ISNULL(vwupNEW.ProcessUnitPriceEA, vwupNEW1.ProcessUnitPriceEA) ELSE 0 END AS DefectNornal,
        PQC, SetupMay, SX_NG, SuaMay, Ktra_ThuongxuyenSX, Ktra_CoDinhSX,
        ISNULL(vwupINCREMENTAL.ProcessUnitPriceEA, vwupINCREMENTAL1.ProcessUnitPriceEA) * (DRI.ProdQty - ISNULL(DRI.DefectQty, 0) - ISNULL(PQC, 0) - ISNULL(SX_NG, 0) - ISNULL(SuaMay, 0) - ISNULL(Ktra_ThuongxuyenSX, 0) - ISNULL(Ktra_CoDinhSX, 0) - ISNULL(SetupMay, 0)) AS PriceINCREMENTAL
        FROM DRI WITH(NOLOCK)
        OUTER APPLY (SELECT TOP 1 * FROM STB_RouteInfo RI WITH(NOLOCK) WHERE DRI.FindRouteCode = RI.RouteCode) RI
        OUTER APPLY (SELECT TOP 1 * FROM STB_MaterialMaster MM2 WITH(NOLOCK) WHERE DRI.MaterialCode = MM2.MaterialCode) MM2
        OUTER APPLY (SELECT TOP 1 * FROM STB_LineInfo LI WITH(NOLOCK) WHERE DRI.InputLineCode = LI.LineCode) LI
        OUTER APPLY (SELECT TOP 1 * FROM STB_MachineMaster MM WITH(NOLOCK) WHERE DRI.MachineCode = MM.MachineCode) MM
        OUTER APPLY (SELECT TOP 1 * FROM STB_ProdWorkerInfo PWI WITH(NOLOCK) WHERE DRI.WorkerCode = PWI.WorkerCode) PWI
        OUTER APPLY (SELECT TOP 1 * FROM [dbo].[fn_VVT_Stage2Weight]('') weight3 JOIN STB_ModelBasicInfo modelInfo WITH(NOLOCK) ON SUBSTRING(modelInfo.ModelName, CHARINDEX('(', modelInfo.ModelName, 0) + 1, 4) = weight3.model AND modelInfo.MBIExtText05+'F' = weight3.farad WHERE SUBSTRING(MM2.MaterialName, CHARINDEX('(', MM2.MaterialName, 0) + 1, 4) = weight3.model AND weight3.routecode=DRI.RouteCode) weightLast 
        LEFT OUTER JOIN [dbo].[fn_VVT_StagePrices]() vwup ON vwup.model = DRI.MaterialCode AND vwup.routecode=DRI.RouteCode
        LEFT OUTER JOIN [dbo].[fn_VVT_StagePricesNEW]() vwupNEW ON vwupNEW.model = DRI.MaterialCode AND vwupNEW.routecode=DRI.RouteCode
        OUTER APPLY (SELECT TOP 1 * FROM [dbo].[fn_VVT_StagePricesNEW]() vwupNEW1 WHERE MM2.MaterialName LIKE '%'+vwupNEW1.partno+'%' AND vwupNEW1.routecode=DRI.RouteCode) vwupNEW1
        LEFT OUTER JOIN [dbo].[fn_VVT_StagePricesINCREMENTAL]() vwupINCREMENTAL ON vwupINCREMENTAL.model = DRI.MaterialCode AND vwupINCREMENTAL.routecode=DRI.RouteCode
        OUTER APPLY (SELECT TOP 1 * FROM [dbo].[fn_VVT_StagePricesINCREMENTAL]() vwupINCREMENTAL1 WHERE MM2.MaterialName LIKE '%'+vwupINCREMENTAL1.partno+'%' AND vwupINCREMENTAL1.routecode=DRI.RouteCode) vwupINCREMENTAL1
        WHERE DRI.CreateUserID NOT IN ('test_worker','assy_packing','assy_packing2','roh_worker','electrode_worker','dryroom_worker' )
        AND (@RouteCode = '*' OR DRI.FindRouteCode = @RouteCode)
        AND (@LineCode = '*' OR DRI.InputLineCode = @LineCode)
        AND (@LotNo = '*' OR DRI.Barcode = @LotNo)
        AND (@MarkingLetter='*' OR SIExtText07= @MarkingLetter)
        AND SUBSTRING(DRI.Barcode, 1, 1) !='M'
    END
    ELSE
    BEGIN
        -- PHẦN ELSE DÀNH CHO BI (Tương tự logic trên)
        -- Chèn đoạn CASE MaterialCodeVN vào DRI trong khối ELSE này.
        ;WITH ViewBarcode AS (
             SELECT c.Barcode FROM STB_SetInfo c WITH(NOLOCK) 
             LEFT OUTER JOIN STB_ProdRouteHist b WITH(NOLOCK) ON c.ControlNo=b.ControlNo   
             WHERE b.CompanyCode='VVT' AND b.WorkCenterCode IN ('VVT_F1','VVT_F2') AND b.ProdDateTime>@FromDate AND b.ProdDateTime<@ToDate
             AND b.CreateUserID NOT IN ('test_worker','assy_packing','assy_packing2','roh_worker','electrode_worker','dryroom_worker' )
        ),
        RawView0 AS (
            -- ... (Tương tự như RawView0 ở trên)
            SELECT b.CreateUserID, c.Barcode, b.RouteCode, b.RouteCode AS FindRouteCode, c.ControlNo, c.MaterialCode, InputLineCode, b.MachineCode, b.WorkerCode, SIExtText07, SIExtInt01,
            MAX(b.ProdQty) AS ProdQty, 
            SUM(CASE WHEN Y.TypeErrorCode IS NULL THEN ISNULL(a.DefectQty, 0) - ISNULL(a.RepairQty, 0) ELSE 0 END) AS DefectQty,
            CASE WHEN DI.DirectlyUnder IN (SELECT TypeErrorCode FROM STB_TypeErrorGroupOfFactory WHERE Y.TypeErrorCode='PQC') THEN SUM(a.DefectQty) - SUM(a.RepairQty) ELSE 0 END AS PQC,
            CASE WHEN DI.DirectlyUnder IN (SELECT TypeErrorCode FROM STB_TypeErrorGroupOfFactory WHERE Y.TypeErrorCode='Production_Defect') THEN SUM(a.DefectQty) - SUM(a.RepairQty) ELSE 0 END AS SX_NG,
            CASE WHEN DI.DirectlyUnder IN (SELECT TypeErrorCode FROM STB_TypeErrorGroupOfFactory WHERE Y.TypeErrorCode='Machine_Repair') THEN SUM(a.DefectQty) - SUM(a.RepairQty) ELSE 0 END AS SuaMay,
            CASE WHEN DI.DirectlyUnder IN (SELECT TypeErrorCode FROM STB_TypeErrorGroupOfFactory WHERE Y.TypeErrorCode='Regular_Production_Checks') THEN SUM(a.DefectQty) - SUM(a.RepairQty) ELSE 0 END AS Ktra_ThuongxuyenSX,
            CASE WHEN DI.DirectlyUnder IN (SELECT TypeErrorCode FROM STB_TypeErrorGroupOfFactory WHERE Y.TypeErrorCode='Fixed_Production_Inspection') THEN SUM(a.DefectQty) - SUM(a.RepairQty) ELSE 0 END AS Ktra_CoDinhSX,      
            CASE WHEN DI.DirectlyUnder IN (SELECT TypeErrorCode FROM STB_TypeErrorGroupOfFactory WHERE Y.TypeErrorCode='NG_Setup_Machine') THEN SUM(a.DefectQty) - SUM(a.RepairQty) ELSE 0 END AS SetupMay,
            MAX(b.ProdDateTime) AS ProdDateTime, MAX(b.CreateDateTime) AS CreateDateTime
            FROM STB_SetInfo c WITH(NOLOCK) 
            LEFT OUTER JOIN STB_ProdRouteHist b WITH(NOLOCK) ON c.ControlNo=b.ControlNo  
            LEFT OUTER JOIN STB_DefectRepairInfo a WITH(NOLOCK) ON a.ControlNo=c.ControlNo AND a.FindRouteCode = b.RouteCode
            LEFT OUTER JOIN STB_ProductionOrderInfo POI WITH(NOLOCK) ON c.PoNo = POI.PoNo
            LEFT OUTER JOIN STB_DefectInfo di WITH(NOLOCK) ON a.DefectCode = di.DefectCode
            LEFT OUTER JOIN STB_TypeErrorGroupOfFactory Y WITH(NOLOCK) ON Y.TypeErrorCode = di.DirectlyUnder
            WHERE c.Barcode IN (SELECT Barcode FROM ViewBarcode WITH(NOLOCK))
            AND b.ProdDateTime>@FromDate AND b.ProdDateTime<@ToDate
            AND b.CreateUserID NOT IN ('test_worker','assy_packing','assy_packing2','roh_worker','electrode_worker','dryroom_worker' )
            GROUP BY b.CreateUserID,c.Barcode,b.RouteCode,c.ControlNo,c.MaterialCode,InputLineCode,b.MachineCode,b.WorkerCode,SIExtText07,SIExtInt01,a.DefectCode,POI.DefectSummaryNoBeforeDroping,di.DirectlyUnder,di.DefectCode,Y.TypeErrorCode
        ),
        RawView AS (
            SELECT CreateUserID, Barcode, RouteCode, FindRouteCode, ControlNo, MaterialCode, InputLineCode, MachineCode, WorkerCode, SIExtText07, SIExtInt01,
            MAX(ProdQty) AS ProdQty, 
            SUM(DefectQty)+SUM(SX_NG)+SUM(SuaMay)+SUM(Ktra_ThuongxuyenSX)+SUM(Ktra_CoDinhSX)+SUM(SetupMay)+SUM(PQC) AS DefectQty,
            SUM(DefectQty)+SUM(SX_NG)+SUM(SuaMay)+SUM(Ktra_ThuongxuyenSX)+SUM(Ktra_CoDinhSX)+SUM(SetupMay) AS DefectQty1,
            SUM(SuaMay)+SUM(SetupMay) AS DefectMachine,
            SUM(DefectQty)+SUM(SX_NG)+SUM(Ktra_ThuongxuyenSX)+SUM(Ktra_CoDinhSX)+SUM(PQC) AS DefectNornal,
            SUM(PQC) AS PQC, SUM(SetupMay) AS SetupMay, SUM(SX_NG) AS SX_NG, SUM(SuaMay) AS SuaMay, SUM(Ktra_ThuongxuyenSX) AS Ktra_ThuongxuyenSX, SUM(Ktra_CoDinhSX) AS Ktra_CoDinhSX,
            MAX(ProdDateTime) AS ProdDateTime, MAX(CreateDateTime) AS CreateDateTime
            FROM RawView0 GROUP BY CreateUserID,Barcode,RouteCode,FindRouteCode,ControlNo,MaterialCode,InputLineCode,MachineCode,WorkerCode,SIExtText07,SIExtInt01
        ),
        DRI AS (
            SELECT DISTINCT RV.Barcode, RV.RouteCode, RV.RouteCode AS FindRouteCode, ControlNo, RV.MaterialCode,
            CASE 
                WHEN RV.MaterialCode ='ECVT30-336' THEN 'VVVEC30-059'
                WHEN RV.MaterialCode='ECVT30-344' then 'VVWEC30-054'
                WHEN RV.MaterialCode='ECVT30-356' then 'VVWECT30-054'
                WHEN RV.MaterialCode='ECVT27-322' then 'VVVEC27-001'
                WHEN RV.MaterialCode='ECVT30-219' then 'VVVEC30-001'
                WHEN RV.MaterialCode='ECVT30-371' then 'VVWEC30-078'
                WHEN RV.MaterialCode='RE3000-100' then 'VVWEC30-056'
                WHEN RV.MaterialCode='ECVT27-323' then 'VVWEC27-001'
                WHEN RV.MaterialCode='ECVT30-220' then 'VVWEC30-001'
                WHEN RV.MaterialCode='ECVT30-313' then 'VVWECT30-001'
                WHEN RV.MaterialCode='ECVT30-331' then 'VVWEC30-044'
                WHEN RV.MaterialCode='RE3000-131' then 'VVWEC30-075'
                WHEN RV.MaterialCode='ECVT27-372' then 'VVVEC27-003'
                WHEN RV.MaterialCode='ECVT30-278' then 'VVVEC30-004'
                WHEN RV.MaterialCode='ECVT27-373' THEN 'VVWEC27-003'
                WHEN RV.MaterialCode='ECVT30-276' THEN 'VVWEC30-004'
                WHEN RV.MaterialCode='ECVT30-285' THEN 'VVWECT30-004'
                WHEN RV.MaterialCode='ECVT30-268' THEN 'VVWEC30-005'
                WHEN RV.MaterialCode='ECVT30-360' THEN 'VVWEC30-072'
                WHEN RV.MaterialCode='ECVT30-229' THEN 'VNWEC30-032'
                WHEN RV.MaterialCode='RE2700-089' THEN 'VVVET27-008'
                WHEN RV.MaterialCode='LIVT38-018' THEN 'VNVEL38-001'
                WHEN RV.MaterialCode='LIVT38-030' THEN 'VNVEL38-011'
                WHEN RV.MaterialCode='LIVT38-019' THEN 'VNVEL38-002'
                WHEN RV.MaterialCode='ECVT27-374' THEN 'VVVEC27-035'
                WHEN RV.MaterialCode='ECVT30-279' THEN 'VVVEC30-006'
                WHEN RV.MaterialCode='ECVT30-353' THEN 'VVWECT30-006'
                WHEN RV.MaterialCode='LIVT38-026' THEN 'VNVEL38-006'
                WHEN RV.MaterialCode='ECVT30-275' THEN 'VVWEC30-006'
                WHEN RV.MaterialCode='ECVT30-281' THEN 'VVWEC30-007'
                WHEN RV.MaterialCode='ECVT30-305' THEN 'VVWECT30-007'
                WHEN RV.MaterialCode='RE2700-083' THEN 'VVVET27-001'
                WHEN RV.MaterialCode='ECVT30-347' THEN 'VVWEC30-062'
                WHEN RV.MaterialCode='ECVT27-334' THEN 'VVVEC27-005'
                WHEN RV.MaterialCode='ECVT30-234' THEN 'VVVEC30-008'
                WHEN RV.MaterialCode='ECVT30-335' THEN 'VVWECT30-008'
                WHEN RV.MaterialCode='ECVT30-235' THEN 'VVWEC30-008'
                WHEN RV.MaterialCode='ECVT30-283' THEN 'VVWEC30-012'
                WHEN RV.MaterialCode='ECVT30-318' THEN 'VVWECT30-012'
                WHEN RV.MaterialCode='ECVT27-367' THEN 'VVVEC27-011'
                WHEN RV.MaterialCode='ECVT30-269' THEN 'VVVEC30-013'
                WHEN RV.MaterialCode='ECVT27-368' THEN 'VVWEC27-011'
                WHEN RV.MaterialCode='ECVT30-292' THEN 'VVWEC30-033'
                WHEN RV.MaterialCode='ECVT30-270' THEN 'VVWEC30-013'
                WHEN RV.MaterialCode='RDMD00-V01' THEN 'VVWEC30-048'
                WHEN RV.MaterialCode='ECVT30-295' THEN 'VVWEC30-035'
                WHEN RV.MaterialCode='ECVT27-399' THEN 'VVVET27-003'
                WHEN RV.MaterialCode='ECVT27-343' THEN 'VVVEC27-012'
                WHEN RV.MaterialCode='ECVT30-246' THEN 'VVVEC30-014'
                WHEN RV.MaterialCode='ECVT30-345' THEN 'VVWEC30-055'
                WHEN RV.MaterialCode='ECVT28-001' THEN 'VVVEC28-001'
                WHEN RV.MaterialCode='ECVT25-116' THEN 'VVVEC30-047'
                WHEN RV.MaterialCode='ECVT27-344' THEN 'VVWEC27-012'
                WHEN RV.MaterialCode='ECVT27-370' THEN 'VVWEC27-015'
                WHEN RV.MaterialCode='ECVT30-247' THEN 'VVWEC30-014'
                WHEN RV.MaterialCode='ECVT30-307' THEN 'VVWECT30-014'
                WHEN RV.MaterialCode='RE3000-119' THEN 'VVWEC30-074'
                WHEN RV.MaterialCode='ECVT30-334' THEN 'VVWEC30-039'
                WHEN RV.MaterialCode='RE3000-129' THEN 'VVWEC30-073'
                WHEN RV.MaterialCode='RE3000-134' THEN 'VVWEC30-076'
                WHEN RV.MaterialCode='ECVT30-346' THEN 'VVWEC30-065'
                WHEN RV.MaterialCode='ECVT27-386' THEN 'VVVEC27-014'
                WHEN RV.MaterialCode='RE3000-105' THEN 'VVWEC30-059'
                WHEN RV.MaterialCode='ECVT30-301' THEN 'VVWECT30-037'
                WHEN RV.MaterialCode='ECVT27-388' THEN 'VVVET27-004'
                WHEN RV.MaterialCode='LIVT38-007' THEN 'VNVEL38-004'
                WHEN RV.MaterialCode='RE3800-019' THEN 'VNVEL38-014'
                WHEN RV.MaterialCode='RE3000-109' THEN 'VVWEC30-067'
                WHEN RV.MaterialCode='ECVT30-367' THEN 'VVWEC30-024'
                WHEN RV.MaterialCode='ECVT30-369' THEN 'VVWECT30-024'
                WHEN RV.MaterialCode='ECVT30-309' THEN 'VVWEC30-038'
                WHEN RV.MaterialCode='RE2700-090' THEN 'VVVET27-011'
                WHEN RV.MaterialCode='LIVT38-032' THEN 'VNVEL38-012'
                WHEN RV.MaterialCode='LIVT38-016' THEN 'VNVEL38-020'
                WHEN RV.MaterialCode='LIVT38-035' THEN 'VNVEL38-019'
                WHEN RV.MaterialCode='ECVT30-250' THEN 'VVWEC30-017'
                WHEN RV.MaterialCode='ECVT30-341' THEN 'VVWECT30-017'
                WHEN RV.MaterialCode='RE3000-098' THEN 'VVWEC30-052'
                WHEN RV.MaterialCode='ECVT30-352' THEN 'VVWEC30-060'
                WHEN RV.MaterialCode='RE3000-123' THEN 'VVWEC30-068'
                WHEN RV.MaterialCode='ECVT30-251' THEN 'VVVEC30-022'
                WHEN RV.MaterialCode='ECVT27-350' THEN 'VVWEC27-018'
                WHEN RV.MaterialCode='ECVT30-359' THEN 'VVWEC30-071'
                WHEN RV.MaterialCode='ECVT30-262' THEN 'VVWEC30-018'
                WHEN RV.MaterialCode='ECVT30-350' THEN 'VVWECT30-018'
                WHEN RV.MaterialCode='ECVT27-383' THEN 'VVVEC27-017'
                WHEN RV.MaterialCode='ECVT30-134' THEN 'VVVEC30-044'
                WHEN RV.MaterialCode='ECVT30-312' THEN 'VVWECT30-022'
                WHEN RV.MaterialCode='ECVT30-288' THEN 'VVVEC30-045'
                WHEN RV.MaterialCode='ECVT30-289' THEN 'VVVEC30-050'
                WHEN RV.MaterialCode='ECVT27-405' THEN 'VVVET27-010'
                WHEN RV.MaterialCode='RE2700-088' THEN 'VVVET27-005'
                WHEN RV.MaterialCode='ECVT30-354' THEN 'VVWEC30-066'
                WHEN RV.MaterialCode='LIVT38-008' THEN 'VNVEL38-008'
                WHEN RV.MaterialCode='LIVT30-022'  THEN 'VNVEL38-005'
                WHEN RV.MaterialCode='RE3800-026'  THEN 'VNVEL38-016'
                WHEN RV.MaterialCode='LIVT38-031'  THEN 'VNVEL38-013'
                WHEN RV.MaterialCode='LIVT38-033'  THEN 'VNVEL38-017'
                WHEN RV.MaterialCode='LIVT38-034'  THEN 'VNVEL38-018'
                WHEN RV.MaterialCode='LIVT38-027'  THEN 'VNVEL38-003'
                WHEN RV.MaterialCode='LIVT38-015'  THEN 'VNVEL38-015'
                WHEN RV.MaterialCode='ECVT30-333'  THEN 'VVVEC30-057'
                WHEN RV.MaterialCode='ECVT27-382'  THEN 'VVVEC27-032'
                WHEN RV.MaterialCode='ECVT27-403'  THEN 'VVVEC27-040'
                WHEN RV.MaterialCode='ECVT30-310'  THEN 'VVWEC30-045'
                WHEN RV.MaterialCode='ECVT27-352'  THEN 'VVVEC27-020'
                WHEN RV.MaterialCode='ECVT30-254'  THEN 'VVVEC30-023'
                WHEN RV.MaterialCode='ECVT30-120'  THEN 'VVVEC30-024'
                WHEN RV.MaterialCode='ECVT27-353'  THEN 'VVWEC27-020'
                WHEN RV.MaterialCode='ECVT30-297'  THEN 'YSECVT30-317'
                WHEN RV.MaterialCode='ECVT30-317'  THEN 'VVWEC30-040'
                WHEN RV.MaterialCode='ECVT30-348'  THEN 'VVWEC30-063'
                WHEN RV.MaterialCode='ECVT30-273'  THEN 'VVWEC30-026'
                WHEN RV.MaterialCode='RE3000-122'  THEN 'VVWEC30-069'
                WHEN RV.MaterialCode='HCVT23-061'  THEN 'VVVHC23-007'
                WHEN RV.MaterialCode='ECVT27-401'  THEN 'VVVET27-007'
                WHEN RV.MaterialCode='ECVT30-284'  THEN 'VVWEC30-028'
                WHEN RV.MaterialCode='ECVT27-356'  THEN 'VVWEC27-022'
                WHEN RV.MaterialCode='ECVT27-397'  THEN 'VVWECT27-022'
                WHEN RV.MaterialCode='ECVT27-355'  THEN 'VVVEC27-022'
                WHEN RV.MaterialCode='ECVT27-358'  THEN 'VVVEC27-023'
                WHEN RV.MaterialCode='ECVT30-343'  THEN 'VVWEC30-053'
                WHEN RV.MaterialCode='ECVT30-261'  THEN 'VVWEC30-030'
                WHEN RV.MaterialCode='ECVT27-400'  THEN 'VVVET27-006'
                WHEN RV.MaterialCode='ECVT30-258'  THEN 'VVWEC30-029'
                WHEN RV.MaterialCode='ECVT30-257'  THEN 'VVVEC30-029'
                WHEN RV.MaterialCode='ECVT30-260'  THEN 'VVVEC30-030'
                WHEN RV.MaterialCode='RE3000-120'  THEN 'VVVEC30-061'
                WHEN RV.MaterialCode='ECVT30-271'  THEN 'VVVEC30-031'
                WHEN RV.MaterialCode='ECVT30-287'  THEN 'VVWEC30-036'
                WHEN RV.MaterialCode='ECVT27-247'  THEN 'VVVEC27-025'
                WHEN RV.MaterialCode='ECVT30-115'  THEN 'VVVEC30-033'
                WHEN RV.MaterialCode='ECVT30-316'  THEN 'VVVEC30-054'
                WHEN RV.MaterialCode='ECVT30-113'  THEN 'VVVEC30-032'
                WHEN RV.MaterialCode='ECVT30-372'  THEN 'VVVEC30-056'
                WHEN RV.MaterialCode='RE3000-125'  THEN 'VVVEC30-063'
                WHEN RV.MaterialCode='RE3000-136'  THEN 'VVVEC30-041'
                WHEN RV.MaterialCode='ECVT30-215'  THEN 'VVVEC30-052'
                WHEN RV.MaterialCode='RE3000-116'  THEN 'VVVES-001'
                WHEN RV.MaterialCode='RE3000-096'  THEN 'VVVEC30-S01'
                WHEN RV.MaterialCode='ECVT30-342'  THEN 'VVVEC30-058'
                WHEN RV.MaterialCode='ECVT30-104'  THEN 'VNVEC30-039'
                WHEN RV.MaterialCode='ECVT27-213'  THEN 'VVVEC27-028'
                WHEN RV.MaterialCode='ECVT30-204'  THEN 'VVVEC30-035'
                WHEN RV.MaterialCode='ECVT30-370'  THEN 'SGSJHSC-001'
                WHEN RV.MaterialCode='RE3000-118'  THEN 'VVVES-002'
                WHEN RV.MaterialCode='ECVT30-116'  THEN 'VVVEC30-038'
                WHEN RV.MaterialCode='RE3000-071'  THEN 'VVVEC30-S56'
                WHEN RV.MaterialCode='ECVT30-076'  THEN 'VVVEC30-043'
                WHEN RV.MaterialCode='ECVT30-358'  THEN 'VVVEC30-062'
                WHEN RV.MaterialCode='ECVT30-117'  THEN 'VVVEC30-046'
                WHEN RV.MaterialCode='RDMD00-287'  THEN 'MVCE60-096'
                WHEN RV.MaterialCode='RDMD00-307'  THEN 'MVCE60-103'
                WHEN RV.MaterialCode='RDMD00-345'  THEN 'MVCE60-119'
                WHEN RV.MaterialCode='RDMD00-301'  THEN 'MVCE60-100'
                WHEN RV.MaterialCode='RDMD00-330'  THEN 'MVCE60-109'
                WHEN RV.MaterialCode='ECVT54-055'  THEN 'MVCE54-001'
                WHEN RV.MaterialCode='EDVTMD-153'  THEN 'MVCE54-003'
                WHEN RV.MaterialCode='EDVTMD-142'  THEN 'MVCE54-024'
                WHEN RV.MaterialCode='EDVTMD-206'  THEN 'MVCE54-026'
                WHEN RV.MaterialCode='EDVTMD-161'  THEN 'MVCE60-001'
                WHEN RV.MaterialCode='EDVTMD-151'  THEN 'MVCE60-002'
                WHEN RV.MaterialCode='EDVTMD-203'  THEN 'MVCE60-087'
                WHEN RV.MaterialCode='EDVTMD-152'  THEN 'MVCE60-003'
                WHEN RV.MaterialCode='RDMD00-349'  THEN 'MVCE60-123'
                WHEN RV.MaterialCode='RDMD00-350'  THEN 'MVCE60-122'
                WHEN RV.MaterialCode='EDVTMD-237'  THEN 'MVCE60-137'
                WHEN RV.MaterialCode='EDVTMD-205'  THEN 'MVCE60-086'
                WHEN RV.MaterialCode='EDVTMD-146'  THEN 'MVCE54-004'
                WHEN RV.MaterialCode='RDMD00-369'  THEN 'MVCE54-131'
                WHEN RV.MaterialCode='ECVT54-060'  THEN 'MVCE54-005'
                WHEN RV.MaterialCode='EDVTMD-190'  THEN 'MVCE60-019'
                WHEN RV.MaterialCode='EDVTMD-187'  THEN 'MVCE60-007'
                WHEN RV.MaterialCode='EDVTMD-095'  THEN 'MVCE60-018'
                WHEN RV.MaterialCode='EDVTMD-217'  THEN 'MVCE90-002'
                WHEN RV.MaterialCode='EDVTMD-174'  THEN 'MVCE60-027'
                WHEN RV.MaterialCode='RDMD00-238'  THEN 'MVCE60-076'
                WHEN RV.MaterialCode='EDVTMD-230'  THEN 'MVCE60-128'
                WHEN RV.MaterialCode='RDMD00-378'  THEN 'MVCE60-138'
                WHEN RV.MaterialCode='EDVTMD-188'  THEN 'MVCE60-075'
                WHEN RV.MaterialCode='RDMD00-313'  THEN 'MVCE60-101'
                WHEN RV.MaterialCode='EDVTMD-199'  THEN 'MVCE60-085'
                WHEN RV.MaterialCode='EDVTMD-197'  THEN 'MVCE60-079'
                WHEN RV.MaterialCode='EDVTMD-201'  THEN 'MVCE60-084'
                WHEN RV.MaterialCode='EDVTMD-235'  THEN 'RVVCE60-136'
                WHEN RV.MaterialCode='RDMD00-292'  THEN 'MVCE60-117'
                WHEN RV.MaterialCode='RDMD00-203'  THEN 'MVCE60-088'
                WHEN RV.MaterialCode='EDVTMD-204'  THEN 'MVCE60-089'
                WHEN RV.MaterialCode='EDVTMD-169'  THEN 'MVCE90-001'
                WHEN RV.MaterialCode='EDVTMD-182'  THEN 'MVCE60-020'
                WHEN RV.MaterialCode='RDMD00-353'  THEN 'MVCE60-124'
                WHEN RV.MaterialCode='EDVTMD-207'  THEN 'MVCE60-080'
                WHEN RV.MaterialCode='RDMD00-285'  THEN 'MVCE54-056'
                WHEN RV.MaterialCode='ECVT54-054'  THEN 'MVCE54-050'
                WHEN RV.MaterialCode='EDVTMD-193'  THEN 'MVCE60-063'
                WHEN RV.MaterialCode='RDMD00-347'  THEN 'MVCE60-121'
                WHEN RV.MaterialCode='EDVTMD-234'  THEN 'MVCE60-129'
                WHEN RV.MaterialCode='EDVTMD-S01'  THEN 'MVCE60-104'
                WHEN RV.MaterialCode='RDMD00-339'  THEN 'MVCE60-114'
                WHEN RV.MaterialCode='EDVTMD-221'  THEN 'MVCE60-016'
                WHEN RV.MaterialCode='RDMD00-319'  THEN 'MVCE60-105'
                WHEN RV.MaterialCode='EDVTMD-191'  THEN 'MVCE60-070'
                WHEN RV.MaterialCode='EDVTMD-232'  THEN 'MVCE60-132'
                WHEN RV.MaterialCode='ECVT54-009'  THEN 'MVCE54-009'
                WHEN RV.MaterialCode='ECVT54-056'  THEN 'MVCE54-010'
                WHEN RV.MaterialCode='ECVT60-013'  THEN 'MVCE60-008'
                WHEN RV.MaterialCode='EDVTMD-210'  THEN 'MVCE60-095'
                WHEN RV.MaterialCode='ECVT60-011'  THEN 'MVCE60-009'
                WHEN RV.MaterialCode='RDMD00-217'  THEN 'MVCE60-036'
                WHEN RV.MaterialCode='EDVTMD-181'  THEN 'MVCE60-034'
                WHEN RV.MaterialCode='EDVTMD-179'  THEN 'MVCE60-064'
                WHEN RV.MaterialCode='EDVTMD-184'  THEN 'MVCE60-066'
                WHEN RV.MaterialCode='RDMD00-329'  THEN 'MVCE60-108'
                WHEN RV.MaterialCode='EDVTMD-231'  THEN 'MVCE60-134'
                WHEN RV.MaterialCode='EDVTMD-149'  THEN 'MVCE54-015'
                WHEN RV.MaterialCode='EDVTMD-127'  THEN 'MVCE54-128'
                WHEN RV.MaterialCode='ECVT60-020'  THEN 'MVCE60-067'
                WHEN RV.MaterialCode='RDMD00-V02'  THEN 'MVCE60-091'
                WHEN RV.MaterialCode='RDMD00-332'  THEN 'MVCE60-112'
                WHEN RV.MaterialCode='RDMD00-228'  THEN 'MVCE60-073'
                WHEN RV.MaterialCode='EDVTMD-200'  THEN 'MVCE60-072'
                WHEN RV.MaterialCode='RDMD00-282'  THEN 'MVCE60-097'
                WHEN RV.MaterialCode='EDVTMD-158'  THEN 'MVCE54-031'
                WHEN RV.MaterialCode='RDMD00-230'  THEN 'MVCE54-129'
                WHEN RV.MaterialCode='EDVTMD-163'  THEN 'MVCC60-071'
                WHEN RV.MaterialCode='RDMD00-380'  THEN 'MVCE54-132'
                WHEN RV.MaterialCode='EDVTMD-139'  THEN 'MVCR01-006'
                WHEN RV.MaterialCode='EDVTMD-148'  THEN 'MVCE54-016'
                WHEN RV.MaterialCode='EDVTMD-167'  THEN 'MVCE54-017'
                WHEN RV.MaterialCode='EDVTMD-202'  THEN 'MVCE54-055'
                WHEN RV.MaterialCode='RDMD00-364'  THEN 'MVCE54-130'
                WHEN RV.MaterialCode='ECVT60-009'  THEN 'MVCC60-011'
                WHEN RV.MaterialCode='EDVTMD-194'  THEN 'MVCE60-012'
                WHEN RV.MaterialCode='EDVTMD-192'  THEN 'MVCE60-025'
                WHEN RV.MaterialCode='RDMD00-123'  THEN 'MVCE60-026'
                WHEN RV.MaterialCode='ECVT60-010'  THEN 'MVCE60-030'
                WHEN RV.MaterialCode='RDMD00-261'  THEN 'MVCC60-098'
                WHEN RV.MaterialCode='EDVTMD-226'  THEN 'MVCE60-113'
                WHEN RV.MaterialCode='RDMD00-136'  THEN 'MVCC120-002'
                WHEN RV.MaterialCode='EDVTMD-164'  THEN 'MVCE54-019'
                WHEN RV.MaterialCode='ECVT54-061'  THEN 'MVCE54-020'
                WHEN RV.MaterialCode='ECVT60-012'  THEN 'MVCC60-013'
                WHEN RV.MaterialCode='EDVTMD-222'  THEN 'MVCE60-094'
                WHEN RV.MaterialCode='RDMD00-322'  THEN 'MVCE60-102'
                WHEN RV.MaterialCode='EDVTMD-220'  THEN 'MVCE60-107'
                WHEN RV.MaterialCode='RDMD00-272'  THEN 'MVCE60-069'
                WHEN RV.MaterialCode='EDVTMD-198'  THEN 'MVCE60-078'
                WHEN RV.MaterialCode='EDVTMD-156'  THEN 'MVCE60-015'
                WHEN RV.MaterialCode='RDMD00-346'  THEN 'MVCE60-120'
                WHEN RV.MaterialCode='RDMD00-356'  THEN 'MVCE60-126'
                WHEN RV.MaterialCode='RDMD00-366'  THEN 'MVCE60-135'
                WHEN RV.MaterialCode='RDMD00-360'  THEN 'MVCE60-130'
                WHEN RV.MaterialCode='RDMD00-355'  THEN 'MVCE60-127'
                WHEN RV.MaterialCode='EDVTMD-118'  THEN 'MVCC60-062'
                WHEN RV.MaterialCode='RDMD00-289'  THEN 'MVCE60-082'
                WHEN RV.MaterialCode='RDMD00-250'  THEN 'MVCE60-083'
                WHEN RV.MaterialCode='RDMD00-276'  THEN 'MVCE60-092'
                WHEN RV.MaterialCode='RDMD00-359'  THEN 'MVCE60-131'
                WHEN RV.MaterialCode='RDMD00-266'  THEN 'MVCE60-090'
                WHEN RV.MaterialCode='EDVTMD-183'  THEN 'MVCE90-065'
                WHEN RV.MaterialCode='RDMD00-368'  THEN 'MVCE90-066'
                WHEN RV.MaterialCode='ECVT54-033'  THEN 'MVCE54-039'
                WHEN RV.MaterialCode='EDVTMD-160'  THEN 'MVCE120-001'
                WHEN RV.MaterialCode='EDVTMD-216'  THEN 'MVCE120-003'
                WHEN RV.MaterialCode='EDVTMD-144'  THEN 'MVCE60-017'
                ELSE ''
            END AS MaterialCodeVN,
            RV.InputLineCode, RV.MachineCode, RV.WorkerCode, RV.SIExtText07, RV.SIExtInt01, RI.RouteName, MM2.MaterialName, LI.LineName, PWI.WorkerName, MM.MachineName, RV.ProdDateTime, RV.CreateUserID,
            (CASE WHEN RV.Barcode IN (SELECT * FROM stb_Changedate220924) THEN '2024-07-19' WHEN (DATEPART(HOUR, ProdDateTime)>10) OR (DATEPART(HOUR, ProdDateTime)=10 AND DATEPART(MINUTE, ProdDateTime)>0) THEN CONVERT(VARCHAR(10), ProdDateTime, 120) ELSE CONVERT(VARCHAR(10), DATEADD(DAY, -1, ProdDateTime), 120) END) AS JobDate,
            MAX(RV.ProdQty) AS ProdQty, SUM(RV.DefectQty) AS DefectQty, SUM(RV.DefectQty1) AS DefectQty1, SUM(DefectMachine) AS DefectMachine, SUM(DefectNornal) AS DefectNornal, SUM(PQC) AS PQC, SUM(SetupMay) AS SetupMay, SUM(SX_NG) AS SX_NG, SUM(SuaMay) AS SuaMay, SUM(Ktra_ThuongxuyenSX) AS Ktra_ThuongxuyenSX, SUM(Ktra_CoDinhSX) AS Ktra_CoDinhSX
            FROM RawView RV WITH(NOLOCK)
            OUTER APPLY (SELECT TOP 1 * FROM STB_RouteInfo RI WITH(NOLOCK) WHERE RV.RouteCode = RI.RouteCode) RI
            OUTER APPLY (SELECT TOP 1 * FROM STB_MaterialMaster MM2 WITH(NOLOCK) WHERE MM2.MaterialCode = RV.MaterialCode) MM2
            OUTER APPLY (SELECT TOP 1 * FROM STB_LineInfo LI WITH(NOLOCK) WHERE RV.InputLineCode = LI.LineCode) LI
            OUTER APPLY (SELECT TOP 1 * FROM STB_MachineMaster MM WITH(NOLOCK) WHERE RV.MachineCode = MM.MachineCode) MM
            OUTER APPLY (SELECT TOP 1 * FROM STB_ProdWorkerInfo PWI WITH(NOLOCK) WHERE RV.WorkerCode = PWI.WorkerCode) PWI
            GROUP BY RV.CreateUserID,RV.Barcode,RV.RouteCode,ControlNo,RV.MaterialCode,RV.InputLineCode,RV.MachineCode,RV.WorkerCode,RV.SIExtText07,RV.SIExtInt01,RI.RouteName,MM2.MaterialName,LI.LineName,PWI.WorkerName,MM.MachineName,RV.ProdDateTime
        )
        SELECT DISTINCT 'VVT' AS 사업장, DRI.ControlNo, DRI.Barcode, DRI.MaterialCode, DRI.MaterialCodeVN, MM2.MaterialName, DRI.InputLineCode, LI.LineName, DRI.RouteCode, RI.RouteName, CONVERT(DATETIME, DRI.ProdDateTime, 120) AS ProdDateTime, DRI.JobDate, DRI.MachineCode, MM.MachineName, MM.MachineNumber, DRI.WorkerCode, PWI.WorkerName,
        CASE WHEN DRI.SIExtInt01 IS NULL THEN '' WHEN DRI.SIExtInt01 = 1 THEN '검사불합격' WHEN DRI.SIExtInt01 = 0 THEN '검사불합격이력' END AS RouteInspectionResult,
        DRI.ProdQty AS InputProdQty, ISNULL(DRI.DefectQty, 0) AS DefectQty, ISNULL(DRI.DefectQty1, 0) AS DefectQty1, weightLast.valweight AS WeightUnit, ISNULL(DRI.DefectQty, 0) * weightLast.valweight/1000 AS WasteWeight,
        (DRI.ProdQty - ISNULL(DRI.DefectQty, 0) - ISNULL(PQC, 0) - ISNULL(SX_NG, 0) - ISNULL(SuaMay, 0) - ISNULL(Ktra_ThuongxuyenSX, 0) - ISNULL(Ktra_CoDinhSX, 0)) - ISNULL(SetupMay, 0) AS ProdQty,
        SIExtText07 AS MarkingLetter,
        ISNULL(DRI.DefectQty, 0) * CASE WHEN ProdDateTime<'2023-10-01' THEN ISNULL(vwup.ProcessUnitPriceEA, 0) WHEN ProdDateTime>='2023-10-01' THEN ISNULL(vwupNEW.ProcessUnitPriceEA, vwupNEW1.ProcessUnitPriceEA) ELSE 0 END AS DefectPrice,
        ISNULL(DRI.DefectQty1, 0) * CASE WHEN ProdDateTime<'2023-10-01' THEN ISNULL(vwup.ProcessUnitPriceEA, 0) WHEN ProdDateTime>='2023-10-01' THEN ISNULL(vwupNEW.ProcessUnitPriceEA, vwupNEW1.ProcessUnitPriceEA) ELSE 0 END AS DefectPriceSX,
        ISNULL(DRI.ProdQty, 0) * CASE WHEN ProdDateTime<'2023-10-01' THEN ISNULL(vwup.ProcessUnitPriceEA, 0) WHEN ProdDateTime>='2023-10-01' THEN ISNULL(vwupNEW.ProcessUnitPriceEA, vwupNEW1.ProcessUnitPriceEA) ELSE 0 END AS BeginPrice,
        ISNULL(DRI.DefectMachine, 0) * CASE WHEN ProdDateTime<'2023-10-01' THEN ISNULL(vwup.ProcessUnitPriceEA, 0) WHEN ProdDateTime>='2023-10-01' THEN ISNULL(vwupNEW.ProcessUnitPriceEA, vwupNEW1.ProcessUnitPriceEA) ELSE 0 END AS DefectMachine,
        ISNULL(DRI.DefectNornal, 0) * CASE WHEN ProdDateTime<'2023-10-01' THEN ISNULL(vwup.ProcessUnitPriceEA, 0) WHEN ProdDateTime>='2023-10-01' THEN ISNULL(vwupNEW.ProcessUnitPriceEA, vwupNEW1.ProcessUnitPriceEA) ELSE 0 END AS DefectNornal,
        PQC, SetupMay, SX_NG, SuaMay, Ktra_ThuongxuyenSX, Ktra_CoDinhSX,
        ISNULL(vwupINCREMENTAL.ProcessUnitPriceEA, vwupINCREMENTAL1.ProcessUnitPriceEA) * (DRI.ProdQty - ISNULL(DRI.DefectQty, 0) - ISNULL(PQC, 0) - ISNULL(SX_NG, 0) - ISNULL(SuaMay, 0) - ISNULL(Ktra_ThuongxuyenSX, 0) - ISNULL(Ktra_CoDinhSX, 0) - ISNULL(SetupMay, 0)) AS PriceINCREMENTAL
        FROM DRI WITH(NOLOCK)
        OUTER APPLY (SELECT TOP 1 * FROM STB_RouteInfo RI WITH(NOLOCK) WHERE DRI.FindRouteCode = RI.RouteCode) RI
        OUTER APPLY (SELECT TOP 1 * FROM STB_MaterialMaster MM2 WITH(NOLOCK) WHERE DRI.MaterialCode = MM2.MaterialCode) MM2
        OUTER APPLY (SELECT TOP 1 * FROM STB_LineInfo LI WITH(NOLOCK) WHERE DRI.InputLineCode = LI.LineCode) LI
        OUTER APPLY (SELECT TOP 1 * FROM STB_MachineMaster MM WITH(NOLOCK) WHERE DRI.MachineCode = MM.MachineCode) MM
        OUTER APPLY (SELECT TOP 1 * FROM STB_ProdWorkerInfo PWI WITH(NOLOCK) WHERE DRI.WorkerCode = PWI.WorkerCode) PWI
        OUTER APPLY (SELECT TOP 1 * FROM [dbo].[fn_VVT_Stage2Weight]('') weight3 JOIN STB_ModelBasicInfo modelInfo WITH(NOLOCK) ON SUBSTRING(modelInfo.ModelName, CHARINDEX('(', modelInfo.ModelName, 0) + 1, 4) = weight3.model AND modelInfo.MBIExtText05+'F' = weight3.farad WHERE SUBSTRING(MM2.MaterialName, CHARINDEX('(', MM2.MaterialName, 0) + 1, 4) = weight3.model AND weight3.routecode=DRI.RouteCode) weightLast 
        LEFT OUTER JOIN [dbo].[fn_VVT_StagePrices]() vwup ON vwup.model = DRI.MaterialCode AND vwup.routecode=DRI.RouteCode
        LEFT OUTER JOIN [dbo].[fn_VVT_StagePricesNEW]() vwupNEW ON vwupNEW.model = DRI.MaterialCode AND vwupNEW.routecode=DRI.RouteCode
        OUTER APPLY (SELECT TOP 1 * FROM [dbo].[fn_VVT_StagePricesNEW]() vwupNEW1 WHERE MM2.MaterialName LIKE '%'+vwupNEW1.partno+'%' AND vwupNEW1.routecode=DRI.RouteCode) vwupNEW1
        LEFT OUTER JOIN [dbo].[fn_VVT_StagePricesINCREMENTAL]() vwupINCREMENTAL ON vwupINCREMENTAL.model = DRI.MaterialCode AND vwupINCREMENTAL.routecode=DRI.RouteCode
        OUTER APPLY (SELECT TOP 1 * FROM [dbo].[fn_VVT_StagePricesINCREMENTAL]() vwupINCREMENTAL1 WHERE MM2.MaterialName LIKE '%'+vwupINCREMENTAL1.partno+'%' AND vwupINCREMENTAL1.routecode=DRI.RouteCode) vwupINCREMENTAL1
        WHERE DRI.CreateUserID NOT IN ('test_worker','assy_packing','assy_packing2','roh_worker','electrode_worker','dryroom_worker' )
        AND (@RouteCode = '*' OR DRI.FindRouteCode = @RouteCode)
        AND (@LineCode = '*' OR DRI.InputLineCode = @LineCode)
        AND (@LotNo = '*' OR DRI.Barcode = @LotNo)
        AND (@MarkingLetter='*' OR SIExtText07= @MarkingLetter)
        AND SUBSTRING(DRI.Barcode, 1, 1) !='M'
    END
END
