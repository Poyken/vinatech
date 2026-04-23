-- =============================================
-- Author:	    Mr.Tung
-- Create date: 2021-05-27
-- =============================================
CREATE PROCEDURE [dbo].[usp_Vietnam_hodlPIC_popup]
AS
BEGIN
	SET NOCOUNT ON;

	select distinct pic, pic as personincharge from stb_hodl_situationVVT with(nolock)
		where pic is not null

END



