-- CHECK ROUTING STATUS CHO 4 LOTS - DOPING & KIỂM TRA LẠI
-- Lots: VVQL143R815703, VVQK253R815701, VVQK273R815705, VVQJ153R815702
-- Vấn đề: Đã chuyển đổi ra bedding nhưng không chốt được công đoạn doping và kiểm tra lại

-- B1: Check SetInfo status cho 4 lots (simplified)
SELECT 
    ControlNo,
    MaterialCode,
    ProdQty,
    IsLineInput,
    IsProdFinish,
    LotDecisionResult,
    IsDefect,
    DefectQty,
    CreateDateTime
FROM STB_SetInfo
WHERE ControlNo IN ('VVQL143R815703', 'VVQK253R815701', 'VVQK273R815705', 'VVQJ153R815702')
ORDER BY ControlNo

-- B2: Check routing history đầy đủ cho 4 lots
SELECT 
    PRH.ControlNo,
    PRH.RouteCode,
    RI.RouteName,
    PRH.ProdQty,
    PRH.WorkerCode,
    PRH.MachineCode,
    PRH.ProdDateTime,
    PRH.CreateDateTime
FROM STB_ProdRouteHist PRH
LEFT JOIN STB_RouteInfo RI ON PRH.RouteCode = RI.RouteCode
WHERE PRH.ControlNo IN ('VVQL143R815703', 'VVQK253R815701', 'VVQK273R815705', 'VVQJ153R815702')
ORDER BY PRH.ControlNo, PRH.CreateDateTime

-- B3: Check defect info cho 4 lots (simplified)
SELECT 
    ControlNo,
    FindRouteCode,
    DefectQty,
    CreateDateTime
FROM STB_DefectRepairInfo
WHERE ControlNo IN ('VVQL143R815703', 'VVQK253R815701', 'VVQK273R815705', 'VVQJ153R815702')
ORDER BY ControlNo, CreateDateTime

-- B4: Check Procedure Log cho 4 lots (24h gần nhất)
SELECT 
    ProcedureName,
    VariableName,
    VariableValue,
    CreateDateTime
FROM STB_ProcedureLog
WHERE VariableValue LIKE '%VVQL143R815703%' 
   OR VariableValue LIKE '%VVQK253R815701%'
   OR VariableValue LIKE '%VVQK273R815705%'
   OR VariableValue LIKE '%VVQJ153R815702%'
   AND CreateDateTime >= DATEADD(HOUR, -24, GETDATE())
ORDER BY CreateDateTime DESC
