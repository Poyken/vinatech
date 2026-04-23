CREATE proc [dbo].[usp_VN_ModuleMenu]
@CodeSub NVARCHAR(50)
AS
BEGIN

		SELECT
				NameModules,
				NameForms
		FROM 
				STB_VN_SubMenu WITH (NOLOCK)
		WHERE
				CODESM = @CodeSub 
				AND
				IsUed = 'True'

END
