-- =============================================
-- Author:		DinhManh
-- Create date: 2025-02-26
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[usp_CheckStatusFinishGoodsB752_Exported_get]
	-- Add the parameters for the stored procedure here
		@pProcessUserID VARCHAR(20),
		@pProcessLanguage VARCHAR(20)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
				SELECT 
					 T1.GROUPID,
					 COUNT(T1.GROUPID) AS TOTALBOX,
					 SUM(CAST(T1.PACKQTY AS INT)) AS QTY,
					 T1.CUSTOMERS,
					 T1.SOINVOICES,
					 N'Đã xuất' AS Status
				--INTO #Tbl_SumTotal
				FROM STB_VN_FINISHGOOD_OUT_TEMPORARY T1
				WHERE 
						T1.GROUPID IS NOT NULL 
					AND (
						T1.STATUSIN IS NOT NULL
						AND T1.STATUSOUT IS NOT NULL
					)
				GROUP BY t1.GROUPID, T1.CUSTOMERS,T1.SOINVOICES
END
