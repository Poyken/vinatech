CREATE PROC usp_VN_AddSTAMP_MODULE
--@pFromdate DATE = NULL,
--@pToDate DATE = NULL
AS
BEGIN
		--DECLARE @FromDate DATE = @pFromdate
		--DECLARE @ToDate DATE = @pToDate

	SELECT
			MaterialCode,
			MaterialName,
			Voltage,
			Farad,
			Rating,
			PartNo

	FROM 
			 STB_VN_STAMP_MODULE WITH(NOLOCK)

	--WHERE 
	--				(
	--						((@FromDate IS NULL) OR CONVERT(DATE,CreateDateTime) >= @FromDate)
	--					AND
	--						((@ToDate IS NULL) OR CONVERT(DATE,CreateDateTime) <= @ToDate)
	--				)
END
