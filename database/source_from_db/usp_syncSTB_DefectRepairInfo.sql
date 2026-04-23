CREATE PROCEDURE [dbo].[usp_syncSTB_DefectRepairInfo]
AS
BEGIN
    SET NOCOUNT ON;

    -- Cập nhật hoặc thêm mới các bản ghi từ bảng Employees vào Audit_Employees

	    MERGE INTO STB_ReDropping AS target
      USING (
        SELECT TOP 5000 *
        FROM STB_DefectRepairInfo
        ORDER BY CreateDateTime DESC -- Sắp xếp theo thời gian tạo để lấy dòng mới nhất
    ) AS source
    ON (target.DefectSummaryNo = source.DefectSummaryNo)
    
    WHEN MATCHED THEN
    UPDATE SET
            target.CompanyCode = source.CompanyCode,
            target.WorkCenterCode = source.WorkCenterCode,
            target.ControlNo = source.ControlNo,
            target.PONo = source.PONo,
            target.DayPlanNo = source.DayPlanNo,
            target.FindJobdate = source.FindJobdate,
            target.FindShiftCode = source.FindShiftCode,
            target.FindTimeCode = source.FindTimeCode,
            target.FindLineCode = source.FindLineCode,
            target.FindRouteCode = source.FindRouteCode,
            target.FindSubRouteCode = source.FindSubRouteCode,
            target.FindFacilityRouteCode = source.FindFacilityRouteCode,
            target.CauseJobDate = source.CauseJobDate,
            target.CauseShiftCode = source.CauseShiftCode,
            target.CauseTimeCode = source.CauseTimeCode,
            target.CauseLineCode = source.CauseLineCode,
            target.CauseFacilityRouteCode = source.CauseFacilityRouteCode,
            target.MaterialCode = source.MaterialCode,
            target.BomVersion = source.BomVersion,
            target.FindDateTime = source.FindDateTime,
            target.DefectCauseType = source.DefectCauseType,
            target.DutyCostCenterCode = source.DutyCostCenterCode,
            target.DutyVendorCode = source.DutyVendorCode,
            target.DefectCode = source.DefectCode,
            target.DefectCauseCode = source.DefectCauseCode,
            target.DefectCauseDetailCode = source.DefectCauseDetailCode,
            target.DefectExtDesc = source.DefectExtDesc,
            target.RepairType = source.RepairType,
            target.RepairUserID = source.RepairUserID,
            target.RepairDateTime = source.RepairDateTime,
            target.RepairDesc = source.RepairDesc,
            target.DefectQty = source.DefectQty,
            target.RepairQty = source.RepairQty,
            target.LossQty = source.LossQty,
            target.FileID = source.FileID,
            target.DRIExtText01 = source.DRIExtText01,
            target.DRIExtText02 = source.DRIExtText02,
            target.DRIExtText03 = source.DRIExtText03,
            target.IsDelete = source.IsDelete,
            target.CreateDateTime = source.CreateDateTime,
            target.CreateUserID = source.CreateUserID,
            target.ChangeDateTime = source.ChangeDateTime,
            target.ChangeUserID = source.ChangeUserID
    WHEN NOT MATCHED BY TARGET THEN
        INSERT (
            DefectSummaryNo, CompanyCode, WorkCenterCode, ControlNo, PONo,
            DayPlanNo, FindJobdate, FindShiftCode, FindTimeCode, FindLineCode,
            FindRouteCode, FindSubRouteCode, FindFacilityRouteCode,
            CauseJobDate, CauseShiftCode, CauseTimeCode, CauseLineCode,
            CauseFacilityRouteCode, MaterialCode, BomVersion, FindDateTime,
            DefectCauseType, DutyCostCenterCode, DutyVendorCode,
            DefectCode, DefectCauseCode, DefectCauseDetailCode,
            DefectExtDesc, RepairType, RepairUserID, RepairDateTime,
            RepairDesc, DefectQty, RepairQty, LossQty, FileID,
            DRIExtText01, DRIExtText02, DRIExtText03, IsDelete,
            CreateDateTime, CreateUserID, ChangeDateTime, ChangeUserID, IsStatus 
        )
        VALUES (
            source.DefectSummaryNo, source.CompanyCode, source.WorkCenterCode,
            source.ControlNo, source.PONo, source.DayPlanNo, source.FindJobdate,
            source.FindShiftCode, source.FindTimeCode, source.FindLineCode,
            source.FindRouteCode, source.FindSubRouteCode,
            source.FindFacilityRouteCode, source.CauseJobDate,
            source.CauseShiftCode, source.CauseTimeCode, source.CauseLineCode,
            source.CauseFacilityRouteCode, source.MaterialCode, source.BomVersion,
            source.FindDateTime, source.DefectCauseType, source.DutyCostCenterCode,
            source.DutyVendorCode, source.DefectCode, source.DefectCauseCode,
            source.DefectCauseDetailCode, source.DefectExtDesc, source.RepairType,
            source.RepairUserID, source.RepairDateTime, source.RepairDesc,
            source.DefectQty, source.RepairQty, source.LossQty, source.FileID,
            source.DRIExtText01, source.DRIExtText02, source.DRIExtText03,
            source.IsDelete, source.CreateDateTime, source.CreateUserID,
            source.ChangeDateTime, source.ChangeUserID, 1
        );

    -- Xóa các bản ghi trong Audit_Employees nếu bản ghi tương ứng trong Employees đã bị xóa
    DELETE FROM STB_ReDropping
    WHERE DefectSummaryNo NOT IN (SELECT DefectSummaryNo FROM STB_DefectRepairInfo );
END;
