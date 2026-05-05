-- Procedure: sp_GetDefectSummaryByWorkCenter
CREATE PROCEDURE sp_GetDefectSummaryByWorkCenter
    @WorkCenterCode NVARCHAR(50),
    @FromDate DATETIME,
    @ToDate DATETIME
AS
BEGIN
    SET NOCOUNT ON;

    ;WITH ViewBarcode AS (
        SELECT c.Barcode
        FROM STB_SetInfo c WITH (NOLOCK)
        LEFT OUTER JOIN STB_ProdRouteHist b WITH (NOLOCK)
            ON c.ControlNo = b.ControlNo
        WHERE b.CompanyCode = 'VVT'
            AND b.WorkCenterCode = @WorkCenterCode
            AND b.ProdDateTime >= @FromDate
            AND b.ProdDateTime < @ToDate
            AND b.CreateUserID NOT IN (
                'test_worker', 'assy_packing', 'assy_packing2',
                'roh_worker', 'electrode_worker', 'dryroom_worker'
            )
    ),
    RawView0 AS (
        SELECT  
            b.CreateUserID,
            c.Barcode,
            b.RouteCode,
            b.RouteCode AS FindRouteCode,
            c.ControlNo,
            c.MaterialCode,
            InputLineCode,
            b.MachineCode,
            b.WorkerCode,
            SIExtText07,
            SIExtInt01,
            MAX(b.ProdQty) AS ProdQty,
            CASE 
                WHEN a.DefectCode NOT IN (
                    SELECT defectcode FROM [dbo].[fn_VVT_QCPARTCODE]()
                )
                AND a.DefectCode NOT LIKE 'V-29_XX1'
                AND a.DefectCode NOT LIKE 'V-29_XX2'
                AND a.DefectCode NOT LIKE 'V-29_XX3'
                AND b.RouteCode NOT LIKE 'V-34_BG'
                AND POI.DefectSummaryNoBeforeDroping IS NULL
                THEN SUM(a.DefectQty) - SUM(a.RepairQty)
                ELSE 0 
            END AS DefectQty,
            CASE 
                WHEN a.DefectCode IN (
                    SELECT defectcode FROM [dbo].[fn_VVT_QCPARTCODE]() WHERE work = 'pqc'
                ) THEN SUM(a.DefectQty) - SUM(a.RepairQty)
                ELSE 0 
            END AS PQC,
            CASE 
                WHEN a.DefectCode IN (
                    SELECT defectcode FROM [dbo].[fn_VVT_QCPARTCODE]() WHERE work = 'qcpart'
                ) THEN SUM(a.DefectQty) - SUM(a.RepairQty)
                ELSE 0 
            END AS QcPart,
            CASE 
                WHEN a.DefectCode IN (
                    SELECT defectcode FROM [dbo].[fn_VVT_QCPARTCODE]() WHERE work = 'rely'
                ) THEN SUM(a.DefectQty) - SUM(a.RepairQty)
                ELSE 0 
            END AS DoTinCay,
            CASE 
                WHEN a.DefectCode IN (
                    SELECT defectcode FROM [dbo].[fn_VVT_QCPARTCODE]() WHERE work = 'sxdestroy'
                ) THEN SUM(a.DefectQty) - SUM(a.RepairQty)
                ELSE 0 
            END AS QcSx,
            CASE 
                WHEN a.DefectCode IN (
                    SELECT defectcode FROM [dbo].[fn_VVT_QCPARTCODE]() WHERE work = 'thietbi'
                ) THEN SUM(a.DefectQty) - SUM(a.RepairQty)
                ELSE 0 
            END AS SuaMay,
            MAX(b.ProdDateTime) AS ProdDateTime,
            MAX(b.CreateDateTime) AS CreateDateTime
        FROM STB_SetInfo c WITH (NOLOCK)
        LEFT OUTER JOIN STB_ProdRouteHist b WITH (NOLOCK)
            ON c.ControlNo = b.ControlNo
        LEFT OUTER JOIN STB_DefectRepairInfo a WITH (NOLOCK)
            ON a.ControlNo = c.ControlNo AND a.FindRouteCode = b.RouteCode
        LEFT OUTER JOIN STB_ProductionOrderInfo POI WITH (NOLOCK)
            ON c.PoNo = POI.PoNo
        WHERE c.Barcode IN (
            SELECT Barcode FROM ViewBarcode WITH (NOLOCK)
        )
            AND b.ProdDateTime >= @FromDate
            AND b.ProdDateTime < @ToDate
            AND b.CreateUserID NOT IN (
                'test_worker', 'assy_packing', 'assy_packing2',
                'roh_worker', 'electrode_worker', 'dryroom_worker'
            )
        GROUP BY 
            b.CreateUserID, c.Barcode, b.RouteCode, c.ControlNo,
            c.MaterialCode, InputLineCode, b.MachineCode, b.WorkerCode,
            SIExtText07, SIExtInt01, a.DefectCode, POI.DefectSummaryNoBeforeDroping
    ),
    RawView AS (
        SELECT  
            CreateUserID,
            Barcode,
            RouteCode,
            FindRouteCode,
            ControlNo,
            MaterialCode,
            InputLineCode,
            MachineCode,
            WorkerCode,
            SIExtText07,
            SIExtInt01,
            MAX(ProdQty) AS ProdQty,
            SUM(DefectQty) + SUM(PQC) + SUM(QcPart) + SUM(DoTinCay) + SUM(QcSx) + SUM(SuaMay) AS DefectQty,
            SUM(PQC) AS PQC,
            SUM(QcPart) AS QcPart,
            SUM(DoTinCay) AS DoTinCay,
            SUM(QcSx) AS QcSx,
            SUM(SuaMay) AS SuaMay,
            MAX(ProdDateTime) AS ProdDateTime,
            MAX(CreateDateTime) AS CreateDateTime
        FROM RawView0
        GROUP BY 
            CreateUserID, Barcode, RouteCode, FindRouteCode,
            ControlNo, MaterialCode, InputLineCode,
            MachineCode, WorkerCode, SIExtText07, SIExtInt01
    )
    SELECT * FROM RawView;
END;
GO

