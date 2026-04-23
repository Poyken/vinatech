CREATE PROC [dbo].[VN_ViTri]
		@pProcessUserID VARCHAR(20),
		@pProcessLanguage VARCHAR(20)
		AS
		BEGIN
				SELECT IDSL,NameLocations
				FROM STB_VN_LOCATION WITH(NOLOCK)
				WHERE Actives=1
		END