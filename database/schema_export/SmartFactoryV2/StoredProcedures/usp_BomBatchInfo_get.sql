-- Procedure: usp_BomBatchInfo_get
-- =============================================
-- Author:	    Park Jong Seob(jspark@awoo.co.kr)
-- Create date: 2016-08-21
-- Browsable : true
-- Group : 공통
-- Description:	BOM Batch 입력정보를 가져옵니다.
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_BomBatchInfo_get]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pMaterialCode VARCHAR(50) = NULL

AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @MaterialCode VARCHAR(50) = CASE WHEN ISNULL(@pMaterialCode,'') = '' THEN '*' ELSE @pMaterialCode END

    
	SELECT
			BBI.MaterialCode AS OldMaterialCode,
			BBI.BomVersion AS OldBomVersion,
			BBI.ChildMaterialCode AS OldChildMaterialCode,
			BBI.ChildBomVersion AS OldChildBomVersion,
			BBI.MaterialCode,
			BBI.BomVersion,
			MM_P.MaterialName,
			BBI.ChildMaterialCode,
			BBI.ChildBomVersion,
			MM_C.MaterialCode AS ChildMaterialName,
			BBI.BomUnit,
			BBI.ChildBomUnit,
			BBI.UsedQty,
			BBI.RouteCode,
			RI.RouteName,
			BBI.CreateDateTime,
			BBI.CreateUserID,
			BBI.ChangeDateTime,
			BBI.ChangeUserID
	FROM
			STB_BomBatchInfo BBI WITH(NOLOCK)
			LEFT OUTER JOIN STB_MaterialMaster MM_P WITH (NOLOCK)
				ON (MM_P.MaterialCode = BBI.MaterialCode)
			LEFT OUTER JOIN STB_MaterialMaster MM_C WITH (NOLOCK)
				ON (MM_C.MaterialCode = BBI.ChildMaterialCode)
			LEFT OUTER JOIN STB_RouteInfo RI WITH (NOLOCK)
				ON (RI.RouteCode = BBI.RouteCode)
	WHERE
			((@MaterialCode = '*') OR (BBI.MaterialCode = @MaterialCode)) 

END

GO

