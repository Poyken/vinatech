

-- =============================================
-- Author:	    Kim Han Young(hykim@awoo.co.kr)
-- Create date: 2016-07-29
-- Browsable : true
-- Group : 자재관리
-- Description:	MRP 대상자재정보를 가져옵니다.
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_MrpSourceMaterial_get]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pMrpNo VARCHAR(20) = NULL

AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @MrpNo VARCHAR(20) = CASE WHEN ISNULL(@pMrpNo,'') = '' THEN '' ELSE @pMrpNo END

    
	SELECT
			MSM.MrpSourceNo AS OldMrpSourceNo,
			MSM.MrpSourceNo,
			MSM.MrpNo,
			MSM.MaterialCode,
			MM.MaterialName,
			MM.MaterialSpec,
			MSM.BomVersion,
			MSM.ProdPlanDate,
			MSM.PlanQty,
			MSM.AdjustQty,
			MSM.FixedQty,
			MSM.IsNotInclude,
			MSM.CreateDateTime,
			MSM.CreateUserID,
			MSM.ChangeDateTime,
			MSM.ChangeUserID
	FROM
			STB_MrpSourceMaterial MSM WITH(NOLOCK)
			LEFT OUTER JOIN STB_MaterialMaster MM WITH(NOLOCK)
				ON	MM.MaterialCode = MSM.MaterialCode
	WHERE
			((@MrpNo = '*') OR (MSM.MrpNo = @MrpNo)) 

END


