

-- =============================================
-- Author:		Kim Han Young
-- Create date: 2017-07-26
-- Browsable : false
-- Description:	Getting Procedure Body
-- =============================================
CREATE PROCEDURE [dbo].[usp_GetProcedureInfo]
	@pProcedureName NVARCHAR(100)
WITH RECOMPILE
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @ProcedureName NVARCHAR(100) = @pProcedureName

	;
	WITH SP AS
	(
		SELECT 
				OBJECT_ID(R.Routine_name) AS obj_id,
				R.ROUTINE_NAME
		FROM 
				INFORMATION_SCHEMA.ROUTINES R
		WHERE 
				Routine_type = 'PROCEDURE' AND
				Routine_Schema = 'dbo' AND
				ROUTINE_NAME = @ProcedureName
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

	EXEC usp_GetProcedureParameters @ProcedureName
END









