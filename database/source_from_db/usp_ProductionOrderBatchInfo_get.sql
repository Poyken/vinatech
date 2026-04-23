-- =============================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Create date: 2023-02-22
-- Browsable : true
-- Group : 지지체
-- Description:	일괄 PO등록 기준정보
-- Modified:
-- =============================================
CREATE PROCEDURE usp_ProductionOrderBatchInfo_get
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20)
AS
BEGIN
	SELECT POB.ParentMaterialCode AS OldParentMaterialCode
          ,POB.TargetMaterialCode AS OldTargetMaterialCode
		  ,POB.ParentMaterialCode
		  ,MM1.MaterialName AS ParentMaterialName
          ,POB.TargetMaterialCode
		  ,MM2.MaterialName AS TargetMaterialName
          ,POB.OrderRate
          ,POB.CreateDateTime
          ,POB.CreateUserID
          ,POB.ChangeDateTime
          ,POB.ChangeUserID
	  FROM STB_ProductionOrderBatchInfo POB
	  LEFT OUTER JOIN STB_MaterialMaster MM1
	    ON MM1.MaterialCode = POB.ParentMaterialCode
	  LEFT OUTER JOIN STB_MaterialMaster MM2
	    ON MM2.MaterialCode = POB.TargetMaterialCode
	 ORDER BY ParentMaterialCode, TargetMaterialCode
END
