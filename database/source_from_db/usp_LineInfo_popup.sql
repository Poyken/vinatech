

-- =============================================
-- Author:		Kim Han Young(hykim@awoo.co.kr)
-- Create date: 2016-03-19
-- Description:	팝업용 라인정보를 가져옵니다.
-- ============================================= exec usp_LineInfo_popup 'VVT','VVT_F3'
CREATE PROCEDURE [dbo].[usp_LineInfo_popup]
	@pCompanyCode VARCHAR(20) = NULL,	
	@pWorkCenterCode VARCHAR(20) = NULL
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @CompanyCode VARCHAR(20) = CASE WHEN ISNULL(@pCompanyCode,'') = '' THEN '*' ELSE @pCompanyCode END
    DECLARE @WorkCenterCode VARCHAR(20) = CASE WHEN ISNULL(@pWorkCenterCode,'') = '' THEN '*' ELSE @pWorkCenterCode END

	if(@WorkCenterCode <> 'VVT_F3')
		BEGIN
				SELECT
						LI.CompanyCode,
						CI.CompanyName,
						LI.WorkCenterCode,
						WCI.WorkCenterName,
						LI.LineCode,
						LI.LineDesc AS LineName,
						LI.LineType
				FROM
						STB_LineInfo LI WITH(NOLOCK)
						LEFT OUTER JOIN STB_CompanyInfo CI WITH(NOLOCK)				ON	CI.CompanyCode = LI.CompanyCode
						LEFT OUTER JOIN STB_WorkCenterInfo WCI WITH(NOLOCK)				ON	WCI.WorkCenterCode = LI.WorkCenterCode
				WHERE
						((@CompanyCode = '*') OR (LI.CompanyCode = @CompanyCode)) AND
						((@WorkCenterCode = '*') OR (LI.WorkCenterCode = @WorkCenterCode))  AND
						LI.IsUsed = 1
		 END
	 ELSE -- Mr.duy xét cho nhà máy hà nam chỉ có 1 line
		 BEGIN
		 	SELECT TOP 1
						'VVT' as CompanyCode ,
						'Vinatech' as CompanyName,
						'VVT_F3' as WorkCenterCode,
						N'Nhà máy Hà Nam' as WorkCenterName,
						'VELINE-01' as LineCode,
						'VELINE-01' AS LineName,
						'A' as LineType
				FROM
						STB_LineInfo
		 END
END

-- select * from STB_LineInfo where IsUsed = 1

-- select * from STB_CompanyInfo

-- select * from STB_WorkCenterInfo