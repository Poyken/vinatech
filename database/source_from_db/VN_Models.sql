CREATE PROC [dbo].[VN_Models]
@pProcessUserID VARCHAR(20),
@pProcessLanguage VARCHAR(20)
AS
BEGIN
SET NOCOUNT ON;
		
		SELECT 
				DISTINCT  MaterialCode,
						  MaterialName 
			FROM 
				STB_MaterialMaster WITH(NOLOCK)

END
