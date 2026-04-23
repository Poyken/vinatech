-- =============================================
-- Author:		Nguyễn Hải Triều
-- Create date: 2025-12-19
-- Description:	Lấy ra thông tin cellLine
-- =============================================
CREATE PROCEDURE [dbo].[usp_LineInfo_get_VVT_F4]
	-- Add the parameters for the stored procedure here
     
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT LineCode,LineName from STB_LineInfo where WorkCenterCode in('VVT_F1','VVT_F2') and LineName IS NOT NULL
END
