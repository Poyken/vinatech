 CREATE PROC [dbo].[usp_VN_ApproverEletrode]
 @pGROUPID NVARCHAR(50) = NULL
	 AS

	 DECLARE @GRID NVARCHAR(50) = @pGROUPID
	 BEGIN

			SELECT
					 ID,
					 GROUPID, 
					 Materialcode,
					 MaterialName ,
					 GoodQtyLength, 
					 ActuallyQtyRequest,
					 ActuallyQtyProvider,
					 Line, 
					 LEFT(CreateDateTime,12) AS CreateDate, 
					 RIGHT(CreateDateTime,8) AS Times
					 
			FROM 
					STB_VN_ELECTRODE_REQUESTFORM WITH(NOLOCK)
			
			WHERE STATUSS IS NULL AND GROUPID = @GRID

			ORDER BY GROUPID DESC

	 END