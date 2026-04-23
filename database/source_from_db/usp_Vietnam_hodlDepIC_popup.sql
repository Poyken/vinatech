-- =============================================
-- Author:	    Mr.Tung
-- Create date: 2021-05-27
-- =============================================
create PROCEDURE [dbo].[usp_Vietnam_hodlDepIC_popup]
AS
BEGIN
	SET NOCOUNT ON;

	select 'QC' as "DeptIC", 'QC' as "DeptICName"
	union all
	select 'Production' as "DeptIC", 'Production' as "DeptICName"
	union all	
	select 'PE' as "DeptIC", 'PE' as "DeptICName"
	union all	
	select 'Machine' as "DeptIC", 'Machine' as "DeptICName"
	union all	
	select 'Production Plan' as "DeptIC", 'Production Plan' as "DeptICName"
	union all	
	select 'Other' as "DeptIC", 'Other' as "DeptICName"

END



