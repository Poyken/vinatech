 CREATE PROC usp_VN_CheckStatus_ApproverEletrodeDone
	 AS
	 BEGIN

			SELECT
					 GROUPID, 
					 Materialcode,
					 MaterialName ,
					 GoodQtyLength, 
					 ActuallyQtyRequest,
					 ActuallyQtyProvider,
					 Statuss,
					 Line, 
					 LEFT(CreateDateTime,12) AS CreateDate, 
					 RIGHT(CreateDateTime,8) AS Times, 
					 CreateUserID,
					 ApproverBy,
					 LEFT(DateApprovered,12) AS CreateDateApproved,
					 RIGHT(DateApprovered,8) AS TimesApprover,

					 CASE
							WHEN Statuss IS NULL OR Statuss = 'False' THEN N'Đang chờ phê duyệt từ điện cực'
							WHEN Statuss IS NOT NULL  THEN N'Đã được điện cực phê duyệt'

				   ELSE 'We dont see any your data'
				   END AS StatusApprover 
					 
			FROM 
					STB_VN_ELECTRODE_REQUESTFORM WITH(NOLOCK)
			
			ORDER BY GROUPID DESC

	 END