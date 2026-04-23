create proc usp_VN_Pass
AS
BEGIN
SET NOCOUNT ON;

	SELECT
			
			DR.DecisionResult
	FROM
			VW_DecisionResult DR WITH(NOLOCK)
END
