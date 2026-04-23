
CREATE PROC [dbo].[usp_Vietnam_TappingBennding_popup]
AS
BEGIN
	SET NOCOUNT ON;
	select 'Tapping' as "Type", 'Tapping' as TypeName
	union all
	select 'Cutting' as "Type", 'Cutting' as TypeName
	union all
	select 'Bending' as "Type", 'Bending' as TypeName
		union all
	select 'Rework' as "Type", 'Rework' as TypeName
		union all
	select 'Sorting' as "Type", 'Sorting' as TypeName
END 