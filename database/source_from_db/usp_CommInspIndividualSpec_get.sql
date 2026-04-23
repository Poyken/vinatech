
-- =============================================
-- Author: Park Jong Hoon(jhpark@awoo.co.kr)
-- Create date: 2016-06-23
-- Browsable : true
-- Group : 품질관리 > 공용검사개별스펙
-- Description:	[C143] 공용검사개별스펙정보 화면 > 공용검사 개별스펙정보 조회
-- Modified: 
-- Procedure:  usp_CommInspIndividualSpec_get  '','','RQ_StrippingAll'
-- ======================================================================
CREATE PROCEDURE [dbo].[usp_CommInspIndividualSpec_get]
						@pProcessUserID VARCHAR(20),
						@pProcessLanguage VARCHAR(20),
						@pCommInspItemCode VARCHAR(20) = NULL
AS

BEGIN
	SET NOCOUNT ON;
	
	DECLARE @CommInspItemCode VARCHAR(20) = CASE WHEN ISNULL(@pCommInspItemCode,'') = '' THEN '' ELSE @pCommInspItemCode END

	SELECT
			CIIS.IndividualSpecNo AS OldIndividualSpecNo,
			CIIS.IndividualSpecNo,
			CIIS.CommInspItemCode AS OldCommInspItemCode,
			CIIS.CommInspItemCode,
			
			CIIS.CompanyCode,
			CI.CompanyName,
			CI.CompanyNameL,
			
			CIIS.WorkCenterCode,
			WCI.WorkCenterName,
			WCI.WorkCenterNameL,
			
			CIIS.RouteCode,
			RI.RouteName,

			CIIS.MachineCode,
			MPM.MachineName,
			
			CIIS.MoldNumber,
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
			
			CIIS.ProductGroupCode,
			PG.ProductGroupName,
			
			CIIS.MaterialCode,
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
			
			CIIS.CategoryName,
			CIIS.CommInspItemSpec,
			CIIS.CommInspItemDesc,
			CIIS.CommInspUpper,
			CIIS.CommInspLower,
			CIIS.CommInspUpperManually,
			CIIS.CommInspLowerManually,
			CIIS.ItemTargetQtyIndividual,
			CIIS.ItemImageFileID,
			AFM.[FileName],
			AFM.FileSize,
			CONVERT(VARBINARY(MAX),NULL) AS FileData,
			
			CIIS.CreateDateTime,
			CIIS.CreateUserID,
			CIIS.ChangeDateTime,
			CIIS.ChangeUserID
	FROM		                  STB_CommInspIndividualSpec CIIS WITH(NOLOCK)
			LEFT OUTER JOIN STB_WorkCenterInfo WCI WITH(NOLOCK)				ON WCI.WorkCenterCode = CIIS.WorkCenterCode
			LEFT OUTER JOIN STB_CompanyInfo CI WITH(NOLOCK)				       ON CI.CompanyCode = CIIS.CompanyCode
			LEFT OUTER JOIN STB_RouteInfo RI WITH(NOLOCK)				           ON RI.RouteCode = CIIS.RouteCode
			LEFT OUTER JOIN STB_MachineMaster MPM WITH(NOLOCK)				ON MPM.MachineCode = CIIS.MachineCode
			LEFT OUTER JOIN STB_MoldBasicInfo MBI WITH(NOLOCK)				    ON MBI.MoldNumber = CIIS.MoldNumber
			LEFT OUTER JOIN STB_MaterialMaster MM WITH(NOLOCK)				ON MM.MaterialCode = CIIS.MaterialCode
			LEFT OUTER JOIN SmartFramework_File.dbo.STB_AttachedFileMaster AFM WITH (NOLOCK)				ON (AFM.FileID = CIIS.ItemImageFileID)
			LEFT OUTER JOIN STB_ProductGroup PG WITH(NOLOCK)				ON PG.ProductGroupCode = CIIS.ProductGroupCode
			
	WHERE 1=1
	  AND 		((@CommInspItemCode = '*') OR (CIIS.CommInspItemCode = @CommInspItemCode)) 
	--AND 		((@CommInspItemCode = '*') OR (CIIS.CommInspItemCode = 'REQ_A01'))

END

