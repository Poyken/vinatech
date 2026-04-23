CREATE PROC [dbo].[usp_View_Book]
@pProcessUserID VARCHAR(20)
AS
BEGIN
DECLARE @ProcessUserID VARCHAR(20) = @pProcessUserID
		SELECT
				ID,
				MothDate,
				Stage,
				Code,
				ProductionName,
				Unit,
				Qty,
				QtyOut,
				StatusIn,
				StatusOut,
			    SUM(Qty) - SUM(QtyOut) AS TotalInventory,
				Remark
		FROM
				STB_NOBOOK WITH(NOLOCK)

		WHERE 
				CreateUserID = @ProcessUserID

	GROUP BY 
			ID,
				MothDate,
				Stage,
				Code,
				ProductionName,
				Unit,
				Qty,
				QtyOut,
				StatusIn,
				StatusOut,
				Remark	
END