CREATE PROCEDURE [dbo].[usp_Typesparepart_popup]

AS
BEGIN
	SET NOCOUNT ON;
    
    
	SELECT
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

END

