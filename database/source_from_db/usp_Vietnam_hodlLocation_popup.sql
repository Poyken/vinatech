-- =============================================
-- Author:	    Mr.Tung
-- Create date: 2021-05-27
-- =============================================
CREATE PROCEDURE [dbo].[usp_Vietnam_hodlLocation_popup]
AS
BEGIN
	SET NOCOUNT ON;

	select distinct [location], [location] as locationname from stb_hodl_situationVVT with(nolock)
	where [location] is not null

END



