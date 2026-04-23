CREATE proc usp_VN_order_Line
AS
BEGIN
		SELECT
				LineCode,
				LineName
				
		FROM 
				STB_LineInfo WITH(NOLOCK)

		WHERE LineCode IS NOT NULL AND ISUSED  = 1
END
