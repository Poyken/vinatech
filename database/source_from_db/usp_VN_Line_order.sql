CREATE proc usp_VN_Line_order
AS
BEGIN
		SELECT
				LineCode,
				LineName
				
		FROM 
				STB_LineInfo WITH(NOLOCK)

		WHERE LineCode IS NOT NULL AND ISUSED  = 1
END