-- Procedure: usp_GetBaseCodeRemarkFilter_popup2

-- =============================================
-- Author: Park Jong Hoon(jhpark@awoo.co.kr)
-- Create date: 2016-07-23
-- Browsable : true
-- Group : 시스템관리
-- Description:	기본코드관리 조회_POPUP
-- Modified:
-- usp_GetBaseCodeRemarkFilter_popup2 '','','','2100'
-- =============================================
CREATE PROCEDURE [dbo].[usp_GetBaseCodeRemarkFilter_popup2]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pCodeGroup VARCHAR(50) = NULL,
	@pRemark VARCHAR(50) = NULL
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @CodeGroup VARCHAR(50) = CASE WHEN ISNULL(@pCodeGroup,'') = '' THEN '*' ELSE @pCodeGroup END
	       ,@Remark VARCHAR(50) = CASE WHEN ISNULL(@pRemark,'') = '' THEN '*' ELSE @pRemark END
    
	SELECT
	        --Case When Remark = @pRemark Then 'P'

			IsNull(BC.ItemCode,'') AS [ItemCode],
			--CASE WHEN @pRemark = '4000' THEN 'P'
			--         WHEN @pRemark = '9000' THEN 'N' END AS [ItemCode],
			IsNull(BC.Description,'') AS [Description],
			 BC.Remark
	FROM
			STB_BaseCode BC WITH(NOLOCK)
	WHERE 	1=1
	--AND			( @CodeGroup = '*') OR (BC.CodeGroup = @CodeGroup)
	 --AND   ( @Remark = '*') OR (BC.Remark LIKE '%' + @Remark + '%')
	   AND   BC.Remark = '2100'
	--AND 			BC.CodeGroup LIKE 'ReceiveDeptCode%'
    ORDER BY BC.DisplayIndex

END




/*
SELECT
	      --  Case When Remark = @pRemark Then ''

			IsNull(BC.ItemCode,'') ,
			IsNull(BC.Description,'') 
	FROM
			STB_BaseCode BC WITH(NOLOCK)
	WHERE 	1=1
	--AND			( @CodeGroup = '*') OR (BC.CodeGroup = @CodeGroup)
	--  AND   ( @Remark = '*') OR (BC.Remark LIKE '%' + @Remark + '%')
	AND 		BC.CodeGroup LIKE 'ReceiveDeptCode%'
    ORDER BY BC.DisplayIndex

*/
GO

