CREATE PROCEDURE [dbo].[usp_EmployeeDepartment_popup]


AS
BEGIN
	SET NOCOUNT ON;

    
	SELECT
	        SPIOTC.CodeEmp,
			SPIOTC.Name,
			SPIOTC.Department,
			SPIOTC.Sex,
			SPIOTC.Birthday,
			SPIOTC.PhoneNumber,
			SPIOTC.Address,
			SPIOTC.Description,
			SPIOTC.Attribute,
			SPIOTC.Attribute1,
			SPIOTC.Attribute2,
			SPIOTC.Attribute3,
			SPIOTC.Attribute4,
			SPIOTC.Attribute5,
			SPIOTC.PartName,
	        SPIOTC.IsUsed,
	        SPIOTC.CreateDateTime,
	        SPIOTC.CreateUserID,
	        SPIOTC.ChangeDateTime,
	        SPIOTC.ChangeUserID
	FROM
	        Stb_EmployeeDepartment SPIOTC WITH(NOLOCK)


END

