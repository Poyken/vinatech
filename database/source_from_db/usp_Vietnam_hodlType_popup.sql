-- =============================================
-- Author:	    Mr.Tung
-- Create date: 2021-05-27
-- =============================================
CREATE PROCEDURE [dbo].[usp_Vietnam_hodlType_popup]
AS
BEGIN
	SET NOCOUNT ON;

	select 'None' as "Type", 'None' as "TypeName"
	union all
	select 'Hold' as "Type", 'Hold' as "TypeName"
	union all
	select 'Unhold' as "Type", 'Unhold' as "TypeName"
	union all
	select 'Pass' as "Type", 'Pass' as "TypeName"
	union all
	select 'Reject' as "Type", 'Reject' as "TypeName"
		union all
	select 'Rework' as "Type", 'Rework' as "TypeName"

END
