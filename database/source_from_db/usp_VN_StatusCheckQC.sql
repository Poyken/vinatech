
CREATE PROC usp_VN_StatusCheckQC
AS
BEGIN
	SELECT
		  DecisionResult
	FROM 
		 VW_DecisionResult WITH(NOLOCK)
END