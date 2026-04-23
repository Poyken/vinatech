
-- =============================================
-- Author:	    Park Jong Seob(jspark@awoo.co.kr)
-- Create date: 2016-05-31
-- Browsable : true
-- Group : 모델별라벨사양정보
-- Description:	모델별라벨사양정보를 가져옵니다.
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_ModelLabelSpec_get]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pModelCode VARCHAR(50) = NULL
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @ModelCode VARCHAR(50) = CASE WHEN ISNULL(@pModelCode,'') = '' THEN '*' ELSE @pModelCode END

    
	SELECT
			@ModelCode AS OldModelCode,
			LSI.LabelType AS OldLabelType,
			LSI.LabelSpecCode AS OldLabelSpecCode,
			@ModelCode AS ModelCode,
			LSI.LabelType,
			LTI.LabelTypeName,
			LSI.LabelSpecCode,
			LSI.LabelSpecName,
			LSI.LabelSpecDesc,
			MLS.LabelSpecValue,
			MLS.CreateDateTime,
			MLS.CreateUserID,
			MLS.ChangeDateTime,
			MLS.ChangeUserID
	FROM
			SmartFramework.dbo.STB_LabelSpecInfo LSI WITH (NOLOCK)
			LEFT OUTER JOIN SmartFramework.dbo.STB_LabelTypeInfo LTI WITH (NOLOCK)
				ON (LTI.LabelType = LSI.LabelType)
			LEFT OUTER JOIN STB_ModelLabelSpec MLS WITH(NOLOCK)
				ON ((MLS.LabelType = LSI.LabelType) AND (MLS.LabelSpecCode = LSI.LabelSpecCode) AND (MLS.ModelCode = @ModelCode))
	WHERE
			LSI.LabelType IN ( SELECT LabelType FROM STB_ModelLabelInfo WHERE ModelCode = @ModelCode)
	ORDER BY
			LSI.LabelType,
			LSI.LabelSpecCode


END
