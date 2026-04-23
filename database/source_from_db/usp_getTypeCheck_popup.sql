CREATE PROCEDURE usp_getTypeCheck_popup
AS
BEGIN
	select 'Manual Factory 1' as TypeCheck
	UNION
	Select 'Manual Factory 2' as TypeCheck
	UNION
	Select 'Cell line' as TypeCheck
END