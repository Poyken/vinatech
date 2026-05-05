-- Procedure: usp_GetProcedureParameters

-- =============================================
-- Author:		Kim Han Young
-- Create date: 2016-01-13
-- Browsable : false
-- Description:	Getting parameters of procedure
-- =============================================
CREATE PROCEDURE [dbo].[usp_GetProcedureParameters] 
	@pProcedureName VARCHAR(100)
WITH RECOMPILE
AS
BEGIN	
	SET NOCOUNT ON;

    SELECT 
			Parameter_name + ' ' + Data_Type + '(' + Convert(varchar,IsNull(CASE Character_Maximum_Length 
																				WHEN -1 THEN 'Max'
																				ELSE CONVERT(VARCHAR,Character_Maximum_Length)
																			END,'')) + ')' as Parameter_name,
			Parameter_name AS ParamName,
			Data_Type AS DBDataType,
			CASE UPPER(DATA_TYPE)
				WHEN 'INT' THEN 'Integer'
				WHEN 'BIGINT' THEN 'Integer'
				WHEN 'DATE' THEN 'Date'
				WHEN 'DATETIME' THEN 'DateTime'
				WHEN 'FLOAT' THEN 'Double'
				WHEN 'DECIMAL' THEN 'Double'
				WHEN 'VARBINARY' THEN 'ByteArray'
				ELSE 'String'
			END AS DataType,
			Parameter_mode AS ParamMode,
			CASE Character_Maximum_Length 
				WHEN -1 THEN 'Max'
				ELSE CONVERT(VARCHAR,Character_Maximum_Length)
			END AS DataSize,
			'' as [value]
	FROM 
			INFORMATION_SCHEMA.PARAMETERS
	WHERE 
			Specific_name = @pProcedureName
END







GO

