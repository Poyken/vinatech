CREATE PROC [dbo].[VN_PhanLoai]
	@pProcessLanguage VARCHAR(20),
	@pProcessUserID VARCHAR(20)
AS
BEGIN
		SET NOCOUNT ON;
		
		SELECT
				IDS,
				NameCLASSIFY

		FROM 
				STB_VN_CLASSIFY WITH (NOLOCK)
		WHERE 
				IsUsed=1
END