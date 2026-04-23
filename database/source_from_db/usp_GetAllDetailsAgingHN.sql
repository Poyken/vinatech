-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE usp_GetAllDetailsAgingHN
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
				DT.COMPUTER,
				DT.CREATEDATE
			FROM stb_DetailAgaingHN DT WITH(NOLOCK)
			LEFT JOIN stb_MasterAgaingHN MA WITH(NOLOCK) ON MA.LOTNO = DT.LOTNO
END
