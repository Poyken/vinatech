
CREATE PROCEDURE [dbo].[usp_VVT_Show_hide_popup]

AS

BEGIN
	SET NOCOUNT ON;	

	select 'k1' as keyy,'Hien(show)' as "Status"
	union
	select 'k2',        'An(hide)' 
   
   END