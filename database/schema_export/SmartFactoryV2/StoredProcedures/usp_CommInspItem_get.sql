-- Procedure: usp_CommInspItem_get



-- =============================================
-- Author: Park Jong Hoon(jhpark@awoo.co.kr)
-- Create date: 2016-06-01
-- Browsable : true
-- Group : 공용검사관리
-- Description:	공용검사항목정보 조회
-- Modified:
-- 프로시저명 :  usp_CommInspItem_get '','','ROUTE_QUALITY'
-- =============================================
CREATE PROCEDURE [dbo].[usp_CommInspItem_get]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pCommInspTypeCode VARCHAR(50) = NULL

AS
BEGIN
	SET NOCOUNT ON;
	
	DECLARE @CommInspTypeCode VARCHAR(50) = CASE WHEN ISNULL(@pCommInspTypeCode,'') = '' THEN '' ELSE @pCommInspTypeCode END

    
	SELECT
			CII.CommInspItemCode AS OldCommInspItemCode,
			CII.CommInspItemCode,
			
			CII.CommInspTypeCode AS OldCommInspTypeCode,
			CII.CommInspTypeCode,
			
			CII.CompanyCode,
			CI.CompanyName,
			CI.CompanyNameL,
			
			CII.WorkCenterCode,
			WCI.WorkCenterName,
			WCI.WorkCenterNameL,
			
			CII.RouteCode,
			RI.RouteType,
			RI.RouteName,
			
			--CII.FacilityRouteCode,
			--FR.FacilityRouteName,
			--FR.FacilityRouteNameL,
			
			CII.MachineCode,
			--MPM.MachineName,
			--MPM.DisplayIndex,
			--MPM.InjectType,
			--MPM.Capa,
			--MPM.MachineDesc1,
			--MPM.MonitoringGroup,
			--MPM.ErpMachineCode,
			--MPM.MachineDesc2,
			--MPM.MachineDesc3,
			--MPM.MachineDesc4,
			--MPM.MachineDesc5,
			--MPM.MoldProdNo,
			MPM.MachineName,
			
			
			CII.MoldNumber,
			MBI.MoldCategory1,
			MBI.MoldCategory2,
			MBI.MoldCategory3,
			MBI.MoldCategory4,
			MBI.MoldTypeCode,
			MBI.RawMaterial,
			MBI.MakeDate,
			MBI.MakeVendor,
			MBI.CurrentPosition,
			MBI.MoldGrade,
			MBI.GuaranteeQty,
			MBI.AccumulateQty,
			MBI.CurrentQty,
			MBI.AlarmStatus,
			
			CII.MaterialCode,
			MM.MaterialName,
			MM.MaterialNameL,
			MM.MaterialTypeCode,
			--MM.ProductGroupCode,
			MM.MaterialUnit,
			MM.BasicGrQty,
			MM.MaterialSpec,
			MM.MaterialSpecL,
			MM.MaterialSource,
			MM.MaterialThickness,
			
			CII.ProductGroupCode,
			PG.ProductGroupName,
			
			CII.CategoryName,
			CII.DisplayIndex AS CommInspItemDisplayIndex,
			CII.CommInspItemGroup1,
			CII.CommInspItemGroup2,
			CII.CommInspItemGroup3,
			CII.CommInspItemName,
			CII.CommInspUnit,
			CII.CommInspItemDesc,
		
			
			CII.CommInspInputType,
			CIIT.CommInspInputTypeName,
			
			CII.CommInspSelectGroupCode,
			CISG.CommInspSelectGroupName,
			
			CISG.CommInspSelectGroupDesc,
			CII.CommInspItemSpec,
			CII.CommInspUpper,
			CII.CommInspLower,
			
			AFM.[FileName],
			AFM.FileSize,
			CONVERT(VARBINARY(MAX),NULL) AS FileData,
			CII.ItemImageFileID,
			
			CII.ItemTargetQty,
			
			ISNULL(CII.IsIndividualSpec,0) AS IsIndividualSpec,
			
			CII.CreateDateTime,
			CII.CreateUserID,
			CII.ChangeDateTime,
			CII.ChangeUserID
	FROM
			STB_CommInspItem CII WITH(NOLOCK)
			LEFT OUTER JOIN STB_WorkCenterInfo WCI WITH(NOLOCK)				ON WCI.WorkCenterCode = CII.WorkCenterCode
			LEFT OUTER JOIN STB_CompanyInfo CI WITH(NOLOCK)				ON CI.CompanyCode = CII.CompanyCode
			LEFT OUTER JOIN STB_RouteInfo RI WITH(NOLOCK)				ON RI.RouteCode = CII.RouteCode
			--LEFT OUTER JOIN STB_FacilityRoute FR WITH(NOLOCK)
			--	ON FR.FacilityRouteCode = CII.FacilityRouteCode
			--LEFT OUTER JOIN STB_MoldProductMachine MPM WITH(NOLOCK)
			--	ON MPM.MachineCode = CII.MachineCode
			LEFT OUTER JOIN STB_MachineMaster MPM WITH(NOLOCK)				ON MPM.MachineCode = CII.MachineCode
			LEFT OUTER JOIN STB_MoldBasicInfo MBI WITH(NOLOCK)				ON MBI.MoldNumber = CII.MoldNumber
			LEFT OUTER JOIN STB_MaterialMaster MM WITH(NOLOCK)				ON MM.MaterialCode = CII.MaterialCode
			LEFT OUTER JOIN STB_CommInspSelectGroup CISG WITH(NOLOCK)				ON CII.CommInspSelectGroupCode = CISG.CommInspSelectGroupCode
			LEFT OUTER JOIN SmartFramework_File.dbo.STB_AttachedFileMaster AFM WITH (NOLOCK)				ON (AFM.FileID = CII.ItemImageFileID)
			LEFT OUTER JOIN VW_CommInspInputType CIIT WITH(NOLOCK)				ON CIIT.CommInspInputType = CII.CommInspInputType
			LEFT OUTER JOIN STB_ProductGroup PG WITH(NOLOCK)				ON PG.ProductGroupCode = CII.ProductGroupCode
	WHERE
			((@CommInspTypeCode = '*') OR (CII.CommInspTypeCode = @CommInspTypeCode)) 
	ORDER BY
			CII.DisplayIndex

END





GO

