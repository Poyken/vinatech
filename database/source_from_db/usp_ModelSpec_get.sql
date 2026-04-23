
-- =============================================
-- Author:KimGiGeun(ggkim@awoo.co.kr)
-- Create date: 2018-08-24
-- Browsable : true
-- Group : 공통정보 > 제품정보 > 모델사양정보 > 2Grid-모델사양정보
-- Description:	모델사양정보 조회
-- Modified:
--
-- [프로시저 실행]  Exec [usp_ModelSpec_get] '','','ECVT27-372'                           -- 2020.03.12 김동규과장 요청 
-- =============================================
CREATE PROCEDURE [dbo].[usp_ModelSpec_get]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pModelCode VARCHAR(50) = NULL

AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @ModelCode VARCHAR(50) = @pModelCode

    
	SELECT
			MS.ModelCode AS OldModelCode,
			MS.SpecItemCode AS OldSpecItemCode,
			MS.ModelCode,
			MBI.ModelName,
			MBI.ProductGroupCode,
			--SI.ProductGroupCode,
			PG.ProductGroupName,
			MS.SpecItemCode,
			SI.SpecItemName,
			SI.SpecGroupCode,
			SG.SpecGroupName,
			SI.SpecItemCheckType,
			SICT.SpecItemCheckTypeName,
			MS.SpecValue,
			MS.UpperSpec,
			MS.LowerSpec,
			MS.CreateDateTime,
			MS.CreateUserID,
			MS.ChangeDateTime,
			MS.ChangeUserID,
			SI.Remark
	FROM
			STB_ModelSpec MS WITH(NOLOCK)
			LEFT OUTER JOIN VW_ModelBasicInfo MBI WITH(NOLOCK)
				ON	MS.ModelCode		= MBI.ModelCode
			LEFT OUTER JOIN STB_SpecItem SI WITH(NOLOCK)
				ON	MS.SpecItemCode		= SI.SpecItemCode
			LEFT OUTER JOIN STB_ProductGroup PG WITH(NOLOCK)
				ON	MBI.ProductGroupCode = PG.ProductGroupCode
			LEFT OUTER JOIN VW_SpecItemCheckType SICT WITH(NOLOCK)
				ON	SI.SpecItemCheckType	= SICT.SpecItemCheckType
			LEFT OUTER JOIN STB_SpecGroup SG WITH(NOLOCK)
				ON  SI.SpecGroupCode	= SG.SpecGroupCode
	WHERE
			(MS.ModelCode = @ModelCode) 

END

