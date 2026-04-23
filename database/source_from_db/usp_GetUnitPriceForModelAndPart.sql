-- =============================================
-- Author:		Nguyễn Hải Triều
-- Create date: 2026-03-17
-- Description:	Hiển thị danh sách giá tiền theo ngày
-- =============================================
CREATE PROCEDURE [dbo].[usp_GetUnitPriceForModelAndPart]
	-- Add the parameters for the stored procedure here
	@pProcessUserID VARCHAR(20)=NULL, 
	@pProcessLanguage VARCHAR(20)=NULL, 
	@pCompanyCode VARCHAR(20) = NULL,
	@pWorkCenterCode VARCHAR(20)= NULL 
AS
    DECLARE	@WorkCenterCode VARCHAR(30) = CASE WHEN ISNULL(@pWorkCenterCode, '') = '' THEN '*' ELSE @pWorkCenterCode END
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT * FROM STB_UnitPriceForCode WHERE (@WorkCenterCode = '*' OR WorkCenterCode = @WorkCenterCode) 
END
