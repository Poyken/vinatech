-- =============================================
-- Author:	Jeon Gyeong Ho(khjun@awoo.co.kr)
-- Browsable : true
-- Group : 생산관리
-- Create date: 2019-10-14
-- Description:	기종변경을 위한 일일계획를 불러옵니다
-- =============================================

--exec usp_GetSetInfoForChangeMaterial '','','2024041800017'
CREATE PROCEDURE [dbo].[usp_GetSetInfoForChangeMaterial]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pDayPlanNo VARCHAR(20) = NULL
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @DayPlanNo VARCHAR(20) = @pDayPlanNo

	SELECT
			SI.PONo,
			SI.DayPlanNo,
			SI.ControlNo,
			SI.Barcode,
			SI.MaterialCode,
			MM.MaterialName,
			SI.ProdQty,
			SI.InputLineCode,
			LI.LineName AS InputLineName,
			SI.BefDayPlanNo,
			'' AS TargetDayPlanNo,
			'' AS TargetMaterialCode,
			'' AS TargetMaterialName
	FROM
			STB_SetInfo SI WITH(NOLOCK)
			LEFT OUTER JOIN STB_LineInfo LI WITH(NOLOCK)
				ON LI.LineCode = SI.InputLineCode
			LEFT OUTER JOIN STB_MaterialMaster MM WITH(NOLOCK)
				ON MM.MaterialCode = SI.MaterialCode
	WHERE
			SI.DayPlanNo = @DayPlanNo AND
			SI.IsProdFinish = 0 AND
			SI.IsLoss = 0
END

--select * from STB_SetInfo where DayPlanNo='2024041800017' 