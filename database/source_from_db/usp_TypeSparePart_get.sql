CREATE PROCEDURE [dbo].[usp_TypeSparePart_get]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
    @pTypeCode VARCHAR(50) = NULL,
    @pTypeName NVARCHAR(100) = NULL

AS
BEGIN
	SET NOCOUNT ON;
      DECLARE @TypeCode VARCHAR(50) = CASE WHEN ISNULL(@pTypeCode,'') = '' THEN '*' ELSE @pTypeCode END
      DECLARE @TypeName NVARCHAR(100) = CASE WHEN ISNULL(@pTypeName,'') = '' THEN '*' ELSE @pTypeName END

    
	SELECT
			SPIOTC.TypeCode AS OldTypeCode,
	        SPIOTC.TypeCode,
			SPIOTC.TypeName,
			SPIOTC.Description,
			SPIOTC.Attribute,
			SPIOTC.Attribute1,
			SPIOTC.Attribute2,
			SPIOTC.Attribute3,
			SPIOTC.Attribute4,
			SPIOTC.Attribute5,
	        SPIOTC.IsUsed,
	        SPIOTC.CreateDateTime,
	        SPIOTC.CreateUserID,
	        SPIOTC.ChangeDateTime,
	        SPIOTC.ChangeUserID
	FROM
	        STB_typesparepart SPIOTC WITH(NOLOCK)
	WHERE
	        ((@TypeCode = '*') OR (SPIOTC.TypeCode = @TypeCode)) AND
	        ((@TypeName = '*') OR (SPIOTC.TypeName = @TypeName)) 

END

