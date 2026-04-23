-- =============================================
-- Author:		Joo Su Hong
-- Create date: 2016-01-13
-- Group : 공통
-- Description:	품목마스터 자재를(ROH, HIBE, HALB) 팝업으로 조회합니다.
-- =============================================
CREATE PROCEDURE [dbo].[usp_GetBOMMaterialMasterSub_Popup]
	@pProcessLanguage VARCHAR(20),
	@pProcessUserID VARCHAR(20)
WITH RECOMPILE
AS
BEGIN
	SET NOCOUNT ON;

	SELECT
			MM.MaterialCode AS OldMaterialCode,
			MM.MaterialCode,
			MM.MaterialName,
			MM.MaterialNameL,
			MM.MaterialTypeCode,
			MT.BasicMaterialType,
			MT.MaterialTypeName,
			MT.MaterialTypeNameL,
			MM.ProductGroupCode,
			PG.ProductGroupName,
			PG.ProductGroupNameL,
			PG.ProductGroupDesc,
			PG.ProductGroupDescL,
			MM.MaterialUnit,
			MM.MaterialUnit AS BomUnit,
			MM.BasicGrQty,
			MM.MaterialSpec,
			MM.MaterialSpecL,
			MM.MaterialSource,
			MM.AvgGrDay,
			MM.IsPurchase,
			MM.IsOrder,
			MM.IsClosed,
			MM.BeforeMaterialCode,
			
			MM.MMExtText01,
			MM.MMExtText02,
			MM.MMExtText03,
			MM.MMExtText04,
			MM.MMExtText05,
			MM.MMExtText06,
			MM.MMExtText07,
			MM.MMExtText08,
			MM.MMExtText09,
			MM.MMExtText10,
			MM.MMExtInt01,
			MM.MMExtInt02,
			MM.MMExtInt03,
			MM.MMExtInt04,
			MM.MMExtInt05,
			MM.MMExtReal01,
			MM.MMExtReal02,
			MM.MMExtReal03,
			MM.MMExtReal04,
			MM.MMExtReal05,
			MM.MMExtLongText01,
			MM.MMExtLongText02,
			MM.MMExtLongText03,
			MM.MMExtLongText04,
			MM.MMExtLongText05,
			MM.MMExtImage01,
			MM.MMExtImage02,
			MM.MMExtImage03,
			MM.MMExtImage04,
			MM.MMExtImage05,
			
			MM.CreateDateTime,
			MM.CreateUserID,
			MM.ChangeDateTime,
			MM.ChangeUserID
	FROM
			STB_MaterialMaster MM WITH(NOLOCK)
			LEFT OUTER JOIN STB_MaterialType MT WITH(NOLOCK)
				ON MM.MaterialTypeCode = MT.MaterialTypeCode
			LEFT OUTER JOIN STB_ProductGroup PG WITH(NOLOCK)
				ON MM.ProductGroupCode = PG.ProductGroupCode
	WHERE
			(MT.BasicMaterialType = 'ROH' OR MT.BasicMaterialType = 'HALB' OR MT.BasicMaterialType = 'HIBE') --AND -- BasicMaterialType이 기준 
			--(MT.BasicMaterialType = 'ROH' OR MT.BasicMaterialType = 'HIBE') AND -- BasicMaterialType이 기준 			
			--(MM.IsInternalProd = 0) AND
			--(MM.IsDelegate = 0)
END
