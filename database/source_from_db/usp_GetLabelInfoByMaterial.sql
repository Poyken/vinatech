

-- =============================================
-- Author: Jeon Gyeong Ho(khjun@awoo.co.kr)
-- Create date: 2018-06-22
-- Browsable : true
-- Group : 기준 정보
-- Description:	모델별 라벨 포멧명을 가져옵니다
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_GetLabelInfoByMaterial]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pMaterialCode VARCHAR(50) = NULL
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @MaterialCode NVARCHAR(50) = @pMaterialCode

	;WITH LabelInfo AS
	(
		SELECT
				RANK() OVER (PARTITION BY LI.LabelType,LI.FormatName ORDER BY LI.FormatVersion DESC) AS RankIndex,
				LI.LabelType,
				LI.FormatName,
				LI.CommandType,
				LI.Dpi,
				LI.PrinterName
		FROM
				SmartFramework.dbo.STB_LabelInfo LI WITH(NOLOCK)
		WHERE
				LI.IsApproval = 1 AND
				LI.ApplyDate <= GETDATE()
	)
	SELECT
			LT.LabelType,
			LT.LabelTypeName,
			MLI.FormatName,
			LI.CommandType,
			LI.Dpi,
			@MaterialCode AS ModelCode
	FROM
			SmartFramework.dbo.STB_LabelTypeInfo LT WITH(NOLOCK)
			LEFT OUTER JOIN STB_ModelLabelInfo MLI WITH(NOLOCK)
				ON MLI.LabelType = LT.LabelType AND
				MLI.ModelCode = @MaterialCode
			LEFT OUTER JOIN LabelInfo LI
				ON LI.LabelType = MLI.LabelType AND
				LI.FormatName = MLI.FormatName AND
				LI.RankIndex = 1
END
