
-- =============================================
-- Author:	    Kim Han Young(hykim@awoo.co.kr)
-- Create date: 2018-07-23
-- Browsable : true
-- Group : 공통
-- Description:	제품그룹 조회
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_ProductGroup_get]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pProductGroupName NVARCHAR(50) = NULL

AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @ProductGroupName NVARCHAR(50) = CASE WHEN ISNULL(@pProductGroupName,'') = '' THEN '%' ELSE @pProductGroupName END

    
	SELECT
			PG.ProductGroupCode AS OldProductGroupCode,
			PG.ProductGroupCode,
			PG.ProductGroupName,
			PG.ProductGroupNameL,
			PG.ProductGroupDesc,
			PG.ProductGroupDescL,
			PG.IsUsed,
			PG.CreateDateTime,
			PG.CreateUserID,
			PG.ChangeDateTime,
			PG.ChangeUserID
	FROM
			STB_ProductGroup PG WITH(NOLOCK)
	WHERE
			(PG.ProductGroupName LIKE @ProductGroupName) 

END

