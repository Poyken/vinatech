CREATE PROC [dbo].[VN_MaHang]
@pProcessUserID VARCHAR(20),
@pProcessLanguage VARCHAR(20)
AS
BEGIN
SET NOCOUNT ON;
		--DECLARE @Name NVARCHAR(20)='HY-CAP'
		SELECT DISTINCT  MaterialCode AS CodeModel,
			   MaterialName AS NameModel
			FROM STB_MaterialMaster
		--WHERE MaterialName LIKE '%' + @Name + '%'
			--WHERE IsUsed='1'
END
