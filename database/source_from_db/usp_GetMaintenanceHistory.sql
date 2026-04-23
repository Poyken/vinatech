-- =============================================
-- Author:		Nguyễn Hải Triều
-- Create date: 2025-07-01
-- Description:	Xem lại lịch sử bảo trì
-- =============================================
CREATE PROCEDURE usp_GetMaintenanceHistory
	-- Add the parameters for the stored procedure here
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pCellline NVARCHAR(50) = NULL,
    @pProcessStep NVARCHAR(50) = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here

	SELECT 
	   T.TaskID,
    C.CellLineName,
    S.StepName,
    T.TaskDescription,
    T.AsIs,
    T.ToBe,
    T.Cause,
    T.PerformedBy,
    T.CreatedAt

	FROM MaintenanceTasks T
	   JOIN CellLines C ON T.CellLineID = C.CellLIneID
       JOIN ProcessSteps S ON T.StepID = S.StepID
	   ORDER BY T.CreatedAt DESC;
END
