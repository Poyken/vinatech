CREATE PROC [dbo].[VN_UNIT]
		@pProcessUserID VARCHAR(20),
		@pProcessLanguage VARCHAR(20)
		AS
		BEGIN
				SELECT IDU, NameUnit
				FROM STB_VN_UNIT WITH(NOLOCK)
				WHERE Actives=1
		END