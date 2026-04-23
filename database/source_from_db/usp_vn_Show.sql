CREATE PROC usp_vn_Show
	@pProcessLanguage VARCHAR(20),
	@pProcessUserID VARCHAR(20),
	@pCode VARCHAR(20) = NULL,
	@pNames NVARCHAR(50) = NULL
AS
BEGIN
		SET NOCOUNT ON;
			DECLARE @Codes VARCHAR(20) = CASE WHEN ISNULL(@pCode,'') = '' THEN '*' ELSE @pCode END,
					@Name NVARCHAR(50)= CASE WHEN ISNULL (@pNames, '') = '' THEN '*' ELSE @pNames END

					SELECT
							VN.Code AS OldCode,
							VN.Code,
							VN.Names,
							VN.Decs,
							VN.IsUsed,
							VN.CreateDateTime,
							VN.CreateUserID,
							VN.ChangeDateTime,
							VN.ChangeUserID

					FROM STB_VN_TEST VN WITH(NOLOCK)
					WHERE 
							((@Codes = '*') OR (VN.Code=@Codes)) AND
							((@Name = '*') OR (VN.Names=@Name))
END
