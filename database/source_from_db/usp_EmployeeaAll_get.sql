CREATE PROCEDURE [dbo].[usp_EmployeeaAll_get]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
    @pEmpCode VARCHAR(50) = NULL,
    @pEmpName NVARCHAR(100) = NULL

AS
BEGIN
	SET NOCOUNT ON;
      DECLARE @EmpCode VARCHAR(50) = CASE WHEN ISNULL(@pEmpCode,'') = '' THEN '*' ELSE @pEmpCode END
      DECLARE @EmpName NVARCHAR(100) = CASE WHEN ISNULL(@pEmpName,'') = '' THEN '*' ELSE @pEmpName END

    
	SELECT
			SPIOTC.CodeEmp AS OldCodeEmp,
	        SPIOTC.CodeEmp,
			SPIOTC.Name,
			SPIOTC.Department,
			SPIOTC.Sex,
			convert(varchar, SPIOTC.Birthday, 111) as Birthday, 
			SPIOTC.PhoneNumber,
			SPIOTC.Address,
	        SPIOTC.IsUsed,
	        SPIOTC.CreateDateTime,
	        SPIOTC.CreateUserID,
	        SPIOTC.ChangeDateTime,
	        SPIOTC.ChangeUserID
	FROM
	        Stb_EmployeeStationery SPIOTC WITH(NOLOCK)
	WHERE
	        ((@EmpCode = '*') OR (SPIOTC.CodeEmp = @EmpCode)) AND
	        ((@EmpName = '*') OR (SPIOTC.Name = @EmpName)) 

END

