CREATE PROC [dbo].[usp_VN_Models]
@pProcessUserID VARCHAR(20),
@pProcessLanguage VARCHAR(20)
AS
BEGIN
SET NOCOUNT ON;
		
		SELECT 
				DISTINCT  MaterialCode AS CodeModel,
			   MaterialName AS NameModel
			FROM 
				STB_MaterialMaster WITH(NOLOCK)

END
