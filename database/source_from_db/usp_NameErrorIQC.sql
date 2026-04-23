CREATE PROCEDURE [dbo].[usp_NameErrorIQC]
AS
BEGIN
	
	SET NOCOUNT ON;

	SELECT
			NO,
			NameError
	FROM
			stb_nameerror_iqc DR WITH(NOLOCK)
END


