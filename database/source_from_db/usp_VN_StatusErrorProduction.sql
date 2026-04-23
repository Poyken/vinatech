CREATE PROC [dbo].[usp_VN_StatusErrorProduction]
@pProcessLanguage VARCHAR(20),
	@pProcessUserID VARCHAR(20)
AS
BEGIN
	SET NOCOUNT ON;

		SELECT CodeStatus,
				NameStatus

			FROM 
				STB_VN_STASTUS_PROCDUCTION_ERROR WITH(NOLOCK)

			WHERE IsUsed='1'
					
END