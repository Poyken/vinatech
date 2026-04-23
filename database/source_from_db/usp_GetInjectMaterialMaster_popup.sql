-- =============================================
-- Author: Park Jong Hoon(jhpark@awoo.co.kr)
-- Create date: 2016-05-12
-- Group : 팝업
-- Description:	사출 품목마스터(제품,반제품) 팝업
-- =============================================
CREATE PROCEDURE [dbo].[usp_GetInjectMaterialMaster_popup]
WITH RECOMPILE
AS
BEGIN
	SET NOCOUNT ON;

	SELECT	
			MM.MaterialCode,
			MM.MaterialName,
			MM.MaterialNameL,
			MM.MaterialTypecode,
			MT.MaterialTypeName,
			MM.ProductGroupCode,
			PG.ProductGroupName,
			MM.MaterialSpec,
			MM.MaterialSpecL,
			MBI.ModelPrintName,
			MBI.BasicModel,
			MBI.DEFlag,
			MBI.EanCode,
			MBI.UpcCode,
			MBI.ModelColor,
			MBI.MBIWeight,
			MBI.MBISizeD,
			MBI.MBISizeH,
			MBI.MBISizeW,
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
			MBI.MBIExtImage05
	FROM
			STB_MaterialMaster MM WITH(NOLOCK)
			LEFT OUTER JOIN STB_ModelBasicInfo MBI WITH(NOLOCK)
				ON MM.MaterialCode = MBI.ModelCode
			LEFT OUTER JOIN STB_MaterialType MT WITH(NOLOCK)
				ON MM.MaterialTypeCode = MT.MaterialTypeCode
			LEFT OUTER JOIN STB_ProductGroup PG WITH(NOLOCK)
				ON MM.ProductGroupCode = PG.ProductGroupCode
	WHERE
			--MM.MaterialTypeCode IN ('FERT','HALB')
			MT.BasicMaterialType IN ('FERT','HALB')
END
