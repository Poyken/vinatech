CREATE PROCEDURE [dbo].[usp_EmployeeDepartment_get] -- exec usp_EmployeeDepartment_get 'nguyennha','','','','VVT','VVT_F2'
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
    @pEmpCode VARCHAR(50) = NULL,
    @pEmpName NVARCHAR(100) = NULL,
	@pCOMPANYCODE NVARCHAR(100) = NULL,
	@pWORKCENTERCODE NVARCHAR(100) = NULL

AS
BEGIN
	SET NOCOUNT ON;
      DECLARE @EmpCode VARCHAR(50) = CASE WHEN ISNULL(@pEmpCode,'') = '' THEN '*' ELSE @pEmpCode END
      DECLARE @EmpName NVARCHAR(100) = CASE WHEN ISNULL(@pEmpName,'') = '' THEN '*' ELSE @pEmpName END
	   DECLARE @WORKCENTERCODE NVARCHAR(100) = CASE WHEN ISNULL(@pWORKCENTERCODE,'') = '' THEN '*' ELSE @pWORKCENTERCODE END

    
	SELECT
			SPIOTC.CodeEmp AS OldCodeEmp,
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
	        SPIOTC.ChangeUserID,
			CASE
					WHEN WORKCENTERCODE = 'VVT_F1' THEN N'Nhà máy bắc ninh'
					WHEN WORKCENTERCODE = 'VVT_F2' THEN N'Nhà máy bắc giang'
					WHEN WORKCENTERCODE = 'VVT_F3' THEN N'Nhà máy Hà Nam'
			END AS 'WORKCENTERCODE'
	FROM
	        Stb_EmployeeDepartment SPIOTC WITH(NOLOCK)
	WHERE
	        ((@WORKCENTERCODE = '*') OR (SPIOTC.WORKCENTERCODE = @WORKCENTERCODE)) --AND
	        --((@EmpName = '*') OR (SPIOTC.Name = @EmpName))  AND 

END




--ALTER TABLE Stb_EmployeeDepartment
--ADD
--		COMPANYCODE NVARCHAR(50) NULL,
--		WORKCENTERCODE NVARCHAR(50) NULL


-- SELECT * FROM Stb_EmployeeDepartment