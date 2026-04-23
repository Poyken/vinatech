-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[usp_GetAllDataDetailsAgingHN_BI]
	-- Add the parameters for the stored procedure here
			@pFromDate DATETIME = NULL,
			@pToDate DATETIME = NULL,
			@pMachineNumber NVARCHAR(50) = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
		DECLARE @FromDate VARCHAR(30) = CONVERT(VARCHAR(10), @pFromDate, 120) + ' 00:00:00.000'
		DECLARE @ToDate VARCHAR(30) = CONVERT(VARCHAR(10), DATEADD(day, 1, @pToDate), 120) + ' 00:00:00.000'
		DECLARE @MachineNumber NVARCHAR(50) = CASE WHEN ISNULL(@pMachineNumber,'') = '' THEN '%' ELSE @pMachineNumber END

			SELECT
				DT.ID,
				MA.SPEC AS [Spec],
				DT.LOTNO AS Lot,
				DT.NOITEMS AS [No.],
				DT.RESULT AS [Result],
				DT.CAPUF AS [CAP(uF)],
				DT.LCUA AS [LC(uA)],
				DT.DFPHANTRAM AS [DF(%)],
				DT.ESRM AS [ESR(mΩ)],
				DT.TIMEC AS [time],
				DT.LINES,
				DT.COMPUTER
			FROM stb_DetailAgaingHN DT WITH(NOLOCK)
			LEFT JOIN stb_MasterAgaingHN MA WITH(NOLOCK) ON MA.LOTNO = DT.LOTNO AND DT.COMPUTER = MA.COMPUTER AND CONVERT(VARCHAR, MA.CREATEDATE, 23) = CONVERT(VARCHAR, DT.CREATEDATE, 23)
			WHERE 1=1 AND
				CONVERT(DATETIME, LEFT(DT.TIMEC, LEN(DT.TIMEC) - 3), 103) BETWEEN @FromDate AND @ToDate AND
				DT.COMPUTER LIKE @MachineNumber

				
END

--exec usp_GetAllDataDetailsAgingHN_BI '2025-08-19', '2025-08-19', ''