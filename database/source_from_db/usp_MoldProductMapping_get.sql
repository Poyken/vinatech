-- =============================================
-- Author: Park Jong Hoon(jhpark@awoo.co.kr)
-- Create date: 2016-05-04
-- Browsable : true
-- Group : 품목정보
-- Description:	금형생산 상세정보 조회
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_MoldProductMapping_get]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
    @pMoldNumber VARCHAR(50) = NULL,
    @pMaterialCode VARCHAR(50) = NULL
AS
BEGIN

	SET NOCOUNT ON;
    DECLARE @MoldNumber VARCHAR(50) = CASE WHEN ISNULL(@pMoldNumber,'') = '' THEN '*' ELSE @pMoldNumber END
    DECLARE @MaterialCode VARCHAR(50) = CASE WHEN ISNULL(@pMaterialCode,'') = '' THEN '*' ELSE @pMaterialCode END

    
	SELECT
	        MPM.MoldNumber AS OldMoldNumber,
	        MPM.MoldNumber,
	        MBI.MoldTypeCode,
	        MBI.MoldCategory1,
	        MBI.MoldCategory2,
	        MBI.MoldCategory3,
	        MBI.MoldCategory4,
	        MBI.RawMaterial,
	        MBI.MakeDate,
	        MBI.MakeVendor,
	        MBI.CurrentPosition,
	        
	        MPM.MaterialCode AS OldMaterialCode,
	        MPM.MaterialCode,
	        MM.MaterialName,
	        MM.MaterialNameL,
	        MM.MaterialSpec,
	        MM.MaterialSpecL,
	        MPM.Cabity,
	        
	        MI.ModelPrintName,
			MI.BasicModel,
			MI.DEFlag,
			MI.EanCode,
			MI.UpcCode,
			MI.ModelColor,
			MI.MBIWeight,
			MI.MBISizeD,
			MI.MBISizeH,
			MI.MBISizeW,
			MI.MBIExtText01,
			MI.MBIExtText02,
			MI.MBIExtText03,
			MI.MBIExtText04,
			MI.MBIExtText05,
			MI.MBIExtText06,
			MI.MBIExtText07,
			MI.MBIExtText08,
			MI.MBIExtText09,
			MI.MBIExtText10,
			MI.MBIExtInt01,
			MI.MBIExtInt02,
			MI.MBIExtInt03,
			MI.MBIExtInt04,
			MI.MBIExtInt05,
			MI.MBIExtReal01,
			MI.MBIExtReal02,
			MI.MBIExtReal03,
			MI.MBIExtReal04,
			MI.MBIExtReal05,
			MI.MBIExtLongText01,
			MI.MBIExtLongText02,
			MI.MBIExtLongText03,
			MI.MBIExtLongText04,
			MI.MBIExtLongText05,
			MI.MBIExtImage01,
			MI.MBIExtImage02,
			MI.MBIExtImage03,
			MI.MBIExtImage04,
			MI.MBIExtImage05,
	        
	        MPM.CreateDateTime,
	        MPM.CreateUserID,
	        MPM.ChangeDateTime,
	        MPM.ChangeUserID
	FROM
	        STB_MoldProductMapping MPM WITH(NOLOCK)
	        LEFT OUTER JOIN STB_MoldBasicInfo MBI WITH(NOLOCK)
				ON MPM.MoldNumber = MBI.MoldNumber
			LEFT OUTER JOIN STB_MaterialMaster MM WITH(NOLOCK)
				ON MPM.MaterialCode = MM.MaterialCode
			LEFT OUTER JOIN STB_ModelBasicInfo MI WITH(NOLOCK)
				ON MPM.MaterialCode = MI.ModelCode
	WHERE
			((@MaterialCode = '*') OR (MPM.MaterialCode = @MaterialCode))
	        AND ((@MoldNumber = '*') OR (MPM.MoldNumber = @MoldNumber))
	        

END





