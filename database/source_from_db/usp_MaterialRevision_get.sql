-- =============================================
-- Author:		소병운
-- Create date: 2026-04-17
-- Group : 공통
-- Description:	각 자재별 리비전 관리 항목 조회
-- =============================================
CREATE PROCEDURE [dbo].[usp_MaterialRevision_get]
	@pProcessLanguage VARCHAR(20),
	@pProcessUserID VARCHAR(20),
	@pMaterialCode VARCHAR(50) = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

   SELECT 
		MaterialCode,
		Revision,
		SubClass,
		LifecyclePhase,
		RevIncorpDate,
		RevReleaseDate,
		EffectivityDate,
		MfrPartHasRedline,
		ItemThumbnail,
		Sites,
		BomThumbnail,
		BomItemRev,
		BomItemLifecycle,
		OracleTemplate,
		ComponentType,
		SubstitutionPriority,
		ProductLine,
		ModuleName,
		SubSystem,
		CommodityCode,
		BomSubclass,
		PartType,
		UlReqd,
		UlCritical,
		RohsCompliant,
		BomNotes,
		MsdsReqd,
		BomEffectiveDate,
		DrawingNumber,
		MaterialSpec,
		DocumentSaveCode,
		CreateDateTime,
		CreateUserID,
		ChangeDateTime,
		ChangeUserID
	FROM 
		STB_MaterialRevision AS MR WITH(NOLOCK)
	WHERE
		MaterialCode = @pMaterialCode
END
