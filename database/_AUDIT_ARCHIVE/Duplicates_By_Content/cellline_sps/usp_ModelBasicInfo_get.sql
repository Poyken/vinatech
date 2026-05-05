-- =============================================
-- Author:		Park Jong Seob(jspark@awoo.co.kr)
-- Create date: 2018-07-24
-- Group : 공통
-- Description:	Model Basic Info
-- =============================================
CREATE PROCEDURE [dbo].[usp_ModelBasicInfo_get]
	@pProcessLanguage VARCHAR(20),
	@pProcessUserID VARCHAR(20),
	@pModelCode VARCHAR(50) = NULL,
	@pModelName NVARCHAR(100) = NULL,
	@pMaterialTypeCode VARCHAR(20) = NULL,
	@pProductGroupCode VARCHAR(20) = NULL
WITH RECOMPILE
AS
BEGIN
	SET NOCOUNT ON;
	
	DECLARE @ModelCode VARCHAR(50) = CASE WHEN ISNULL(@pModelCode,'') = '' THEN '%' ELSE @pModelCode END,
			@ModelName NVARCHAR(100) = CASE WHEN ISNULL(@pModelName,'') = '' THEN '%' ELSE @pModelName END,
			@MaterialTypeCode VARCHAR(20) = CASE WHEN ISNULL(@pMaterialTypeCode,'') = '' THEN '%' ELSE @pMaterialTypeCode END,
			@ProductGroupCode VARCHAR(20) = CASE WHEN ISNULL(@pProductGroupCode,'') = '' THEN '%' ELSE @pProductGroupCode END

	SELECT
			MBI.ModelCode AS OldModelCode,
			MBI.ModelCode,
			MBI.ModelName,
			MBI.ModelNameL,
			MBI.MaterialTypeCode,
			MT.BasicMaterialType,
			MT.MaterialTypeName,
			MT.MaterialTypeNameL,
			MBI.ProductGroupCode,
			PG.ProductGroupName,
			PG.ProductGroupNameL,
			PG.ProductGroupDesc,
			PG.ProductGroupDescL,
			MBI.ModelPrintName,
			MBI.BasicModel,
			MBI.OemModelBarcode,
			MBI.DEFlag,
			MBI.EanCode,
			MBI.UpcCode,
			MBI.ModelColor,
			MBI.MBIWeight,
			CASE WHEN MBI.MBISizeW IS NOT NULL
			     THEN RIGHT('0'+CONVERT(VARCHAR, CONVERT(INT, MBI.MBISizeW)), 2) + CONVERT(VARCHAR, CONVERT(INT, MBI.MBISizeH))
				 ELSE CONVERT(VARCHAR(10), MBI.MBISizeD) END + CASE WHEN CHARINDEX('-L', MBI.ModelName) > 0 THEN 'L' ELSE '' END AS MBISizeD,
			MBI.MBISizeH,
			MBI.MBISizeW,
			ISNULL(MBI.IsClosed, 0) AS IsClosed,
			MBI.OqcType,
			MBI.OqcInspectionRuleType,
			MBI.OqcCreateRuleNo,
			OLCR.OqcCreateRuleName,
			MBI.InspectionType,
			MBI.InspectionLevel,
			MBI.AQL,
			MBI.MBIExtText01,
			MBI.MBIExtText02,
			MBI.MBIExtText03,
			MBI.MBIExtText04,
			MBI.MBIExtText05,
			MBI.MBIExtText06,
			MBI.MBIExtText07,
			MBI.MBIExtText08,
			MBI.MBIExtText09,
			MBI.MBIExtText10,
			MBI.MBIExtInt01,
			MBI.MBIExtInt02,
			MBI.MBIExtInt03,
			MBI.MBIExtInt04,
			MBI.MBIExtInt05,
			MBI.MBIExtReal01,
			MBI.MBIExtReal02,
			MBI.MBIExtReal03,
			MBI.MBIExtReal04,
			MBI.MBIExtReal05,
			MBI.MBIExtLongText01,
			MBI.MBIExtLongText02,
			MBI.MBIExtLongText03,
			MBI.MBIExtLongText04,
			MBI.MBIExtLongText05,
			MBI.MBIExtImage01,
			MBI.MBIExtImage02,
			MBI.MBIExtImage03,
			MBI.MBIExtImage04,
			MBI.MBIExtImage05,
			MBI.CreateDateTime,
			MBI.CreateUserID,
			MBI.ChangeDateTime,
			MBI.ChangeUserID,
			MBI.MBIExtBit01,
			MBI.AcEsr,
			MBI.DcEsr,
			MBI.MaximumCurrent,
			MBI.LeakageCurrent
	FROM
			VW_ModelBasicInfo MBI WITH(NOLOCK)
			LEFT OUTER JOIN STB_MaterialType MT WITH(NOLOCK)				ON MT.MaterialTypeCode = MBI.MaterialTypeCode 
			LEFT OUTER JOIN STB_ProductGroup PG WITH(NOLOCK)			ON PG.ProductGroupCode = MBI.ProductGroupCode
			LEFT OUTER JOIN STB_OqcLotCreateRule OLCR WITH(NOLOCK)		ON OLCR.OqcCreateRuleNo = MBI.OqcCreateRuleNo
	WHERE
			MBI.ModelCode LIKE @ModelCode AND
			MBI.ModelName LIKE @ModelName AND
			MBI.MaterialTypeCode LIKE @MaterialTypeCode AND
			MBI.ProductGroupCode LIKE @ProductGroupCode
END




-- [2019.06.03]  SELECT * FROM VW_ModelBasicInfo WHERE  MODELCODE in ( 'ECVT30-288', 'ECVT30-214')


-- select MBISizeW, * from VW_ModelBasicInfo where MBISizeW > 10     --- 이게 중대형 제품  (소형 : 8~10파이, 중형 : 13~18파이, 대형 : 22파이 이상)
-- Select MBISizeW, * from VW_ModelBasicInfo where MBISizeW < 10     --- 이게 소형 제품  