-- =============================================
-- Author:		Park Jong Seob(jspark@awoo.co.kr)
-- Create date: 2018-07-24
-- Group : 공통
-- Description:	Model Basic Info
-- =============================================
CREATE PROCEDURE usp_ModelBasicInfoForBarcode_get
	@pProcessLanguage VARCHAR(20),
	@pProcessUserID VARCHAR(20),
	@pBarcode VARCHAR(20) = NULL
WITH RECOMPILE
AS
BEGIN
	SET NOCOUNT ON;
	
	DECLARE @Barcode VARCHAR(20) = @pBarcode

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
			MBI.MBISizeD,
			MBI.MBISizeH,
			MBI.MBISizeW,
			SUBSTRING(MBI.ModelName, CHARINDEX('(', MBI.ModelName, 0) + 1, 4) AS MBISize,
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
			MBI.ChangeUserID
	FROM
			VW_ModelBasicInfo MBI WITH(NOLOCK)
			LEFT OUTER JOIN STB_MaterialType MT WITH(NOLOCK)				ON MT.MaterialTypeCode = MBI.MaterialTypeCode 
			LEFT OUTER JOIN STB_ProductGroup PG WITH(NOLOCK)			ON PG.ProductGroupCode = MBI.ProductGroupCode
			LEFT OUTER JOIN STB_OqcLotCreateRule OLCR WITH(NOLOCK)		ON OLCR.OqcCreateRuleNo = MBI.OqcCreateRuleNo
	WHERE
			MBI.ModelCode = (SELECT MaterialCode FROM STB_SetInfo WHERE Barcode = @Barcode)
END