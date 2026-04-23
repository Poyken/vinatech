CREATE PROC usp_VN_FinishGoodManagement
	@pFromdate DATE = NULL,
	@pToDate DATE = NULL
AS
BEGIN
SET NOCOUNT ON;
		DECLARE @FromDate DATE = @pFromdate
		DECLARE @ToDate DATE = @pToDate

		SELECT 
				T1.LotID,
				T1.LotNo,
				T1.MaterialQcNo,
				T1.MaterialCode,
				T1.DecisionResult,
				T1.CurrentQty,
				T1.INPUT,
				T1.OUTPUTS,
				CONVERT(DATE,T1.DateIn) AS DateIn,
				RIGHT(T1.DateIn,8) AS TimesIn,
				CONVERT(DATE,T1.DateOut) AS DateOut,
				RIGHT(T1.DateOut,8) AS TimeOuts
		FROM	
				STB_VN_FINISHGOOD T1 (NOLOCK)

		WHERE
				(
							((@FromDate IS NULL) OR CONVERT(DATE,DateIn) >= @FromDate)
						AND
							((@ToDate IS NULL) OR CONVERT(DATE,DateOut) <= @ToDate)
				)
END