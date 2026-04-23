-- =============================================
-- Author:		Nguyễn Hải Triều	
-- Create date: 2025-05-23
-- Description:	Thêm hiện tượng của NG
-- =============================================
CREATE PROCEDURE [dbo].[usp_getDefectCause_Popup]

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	select Id,DefectCause from STB_DefectCauseNG
	where IsUsed=1
END
