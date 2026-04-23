CREATE PROC [dbo].[usp_GetMaterialESRSpec] 
	@pMaterialCode VARCHAR(20)
   ,@IncludeDelimiter INT
   ,@pESRLSL NUMERIC(20,5) OUTPUT
   ,@pESRUSL NUMERIC(20,5) OUTPUT
AS
BEGIN
	SELECT @pESRLSL = LowerSpec
		  ,@pESRUSL = UpperSpec
	FROM STB_ModelSpec
	WHERE SpecItemCode IN ('SM0041', 'L0042')
	AND ModelCode = @pMaterialCode
END