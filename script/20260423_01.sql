

 -- 1. Dọn dẹp dữ liệu cũ để tránh lỗi trùng khóa (Primary Key)
DELETE FROM STB_LineInfo WHERE LineCode = 'VVBG1MDL';


-- 2. Insert bản ghi mới với thời gian hiện tại
INSERT INTO STB_LineInfo (
    LineCode, CompanyCode, WorkCenterCode, LineName, LineDesc, 
    LineType, ErpCode, MonitoringGroup, MonitoringName, IsUsed, 
    TotalLossTime, CreateDateTime, CreateUserID, ChangeDateTime, 
    ChangeUserID, IsCheckScheduleMonitoring, MaterialWarehouseCode, 
    ChildLines, checkFuelCellWorkCenter
)
VALUES (
    'VVBG2MDL_2', 
    'VVT', 
    'VVT_F2', 
    N'Xuất Module Bắc Giang 2', 
    N'Xuất Module Bắc Giang 2', 
    'MDL', 
    NULL, NULL, NULL, 1, 
    NULL, 
    GETDATE(), 
    'vanduc', 
    NULL, 
    NULL, 
    1, 
    'MODULE_BG2_WH', 
    NULL, 
    NULL
);
