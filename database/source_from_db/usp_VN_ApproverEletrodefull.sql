CREATE PROC usp_VN_ApproverEletrodefull
AS
BEGIN
	 

			SELECT
					
					 GROUPID, 
					 SUM(ActuallyQtyRequest) AS Qtyrequest
			FROM 
					STB_VN_ELECTRODE_REQUESTFORM WITH(NOLOCK)
			
			WHERE STATUSS IS NULL
			
			GROUP BY  GROUPID
END