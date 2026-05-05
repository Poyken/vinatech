-- Function: fnGetNumbers



-- =============================================
-- Author:		Kim Han Young(hykim@awoo.co.kr)
-- Create date: 2009-08-17
-- Description: 지정된 숫자보다 작은 숫자 계열을 반환합니다.
-- =============================================
CREATE FUNCTION [dbo].[fnGetNumbers]
(	
	@Number BIGINT
)
RETURNS TABLE
AS
RETURN 
	WITH
	L0 AS (SELECT 1 AS C UNION ALL SELECT 1),
	L1 AS (SELECT 1 AS C FROM L0 AS A, L0 AS B),
	L2 AS (SELECT 1 AS C FROM L1 AS A, L1 AS B),
	L3 AS (SELECT 1 AS C FROM L2 AS A, L2 AS B),
	L4 AS (SELECT 1 AS C FROM L3 AS A, L3 AS B),
	L5 AS (SELECT 1 AS C FROM L4 AS A, L4 AS B),
	Nums AS (SELECT ROW_NUMBER() OVER(ORDER BY C) AS N FROM L5)
	SELECT N FROM Nums WHERE N <= @Number




GO

