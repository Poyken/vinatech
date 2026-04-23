-- =============================================
-- Author:		Nguyên Hải Triều
-- Create date: 2025-06-12
-- Description:	Lấy ra danh sách các Spepart đang sử dụng trên Line
-- =============================================
CREATE PROCEDURE [dbo].[usp_VN_InformationSpepaPartInLine_get] 
	-- Add the parameters for the stored procedure here
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pWorkCenterCode VARCHAR(20) = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	DECLARE @WorkCenterCode VARCHAR(20) = CASE WHEN ISNULL(@pWorkCenterCode,'') = '' THEN '%' ELSE @pWorkCenterCode END

	SELECT
	SPLU.SparePartCode,
	SPLU.SparePartLotID,
	SPLU.LineCode,
	SPLU.MachineCode,
	SPLU.IsUsing,
	SPLU.CreateDateTime,
	SPLU.CreateUserID,
	(SELECT COUNT(LotID) FROM STB_VN_SpecialSparePartLotInfo SSPLI WHERE SPLU.SparePartLotID = SSPLI.SparePartLotID) AS UsedLotQty,
	FLOOR(SSPLI.CycleReplace / SSPLI.LotQty)  AS StandardLotQty
	FROM STB_VN_SparePartLineUsage SPLU WITH(NOLOCK)
	left join STB_VN_SpecialSparePartInfo SSPLI WITH(NOLOCK) on SSPLI.SparePartCode=SPLU.SparePartCode
	WHERE SPLU.WorkCenterCode=@WorkCenterCode AND SPLU.IsUsing=1
END
