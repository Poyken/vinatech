CREATE PROC [dbo].[usp_VN_LocationMaterials]
@pProcessUserID VARCHAR(20),
@pProcessLanguage VARCHAR(20),
@pCompanyCode VARCHAR(20) = NULL,
@pWorkCenterCode VARCHAR(20) = NULL
AS
BEGIN

SELECT
	ID,
	CODELR,
	LOCATIONMATERIALS,
	DESCRPTIONS,
	Isused,
	CompanyCode,
	WorkCenterCode,
	CreateDateTime,
	CreateUserID,
	ChangeDateTime,
	ChangeUserID

FROM
		STB_VN_LOCATIONMATERIALS WITH(NOLOCK)

WHERE

		CompanyCode = @pCompanyCode

END
