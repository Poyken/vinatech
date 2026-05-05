

-- =============================================
-- Author:		Kim Han Young
-- Create date: 2016-01-13
-- Browsable : false
-- Description:	Getting Procedure List
-- =============================================
CREATE PROCEDURE [dbo].[usp_GetProcedures]
	@pProcedureName NVARCHAR(100) = NULL
WITH RECOMPILE
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @ProcedureName NVARCHAR(100) = CASE WHEN ISNULL(@pProcedureName,'') = '' THEN '*' ELSE @pProcedureName END

	;
	WITH SP AS
	(
		SELECT 
				OBJECT_ID(R.Routine_name) AS obj_id,
				R.ROUTINE_NAME
		FROM 
				INFORMATION_SCHEMA.ROUTINES R
		WHERE 
				Routine_type = 'Procedure' AND
				Routine_Schema = 'dbo' AND
				((@ProcedureName = '*') OR (ROUTINE_NAME = @ProcedureName))
	)

    SELECT 
			SP.ROUTINE_NAME AS ProcedureName,
			OBJECT_DEFINITION(SP.obj_id) AS ROUTINE_DEFINITION
	FROM 
			SP 
			INNER JOIN sys.sysobjects S
				ON	S.id = SP.obj_id
	ORDER BY 
			SP.ROUTINE_NAME
END









