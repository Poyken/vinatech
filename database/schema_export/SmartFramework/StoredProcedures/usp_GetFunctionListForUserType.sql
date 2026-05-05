-- Procedure: usp_GetFunctionListForUserType






-- =============================================
-- Author:		Park Jong Seob (jspark@awoo.co.kr)
-- Create date: 2016-01-20
-- Browsable : true
-- Description:	Get Function List For UserType
-- =============================================
CREATE PROCEDURE [dbo].[usp_GetFunctionListForUserType]
	@pProcessLanguage VARCHAR(50) = null, -- SystemBase.Language를 가져옴
	@pUserType VARCHAR(20) = null,
	@pName VARCHAR(50) = NULL
AS
BEGIN
	DECLARE @Language VARCHAR(50) = @pProcessLanguage,
			@UserType VARCHAR(20) = @pUserType,
			@Name VARCHAR(50) = @pName

	DECLARE @Xml NVARCHAR(MAX)

	SELECT 			
			@Xml = SLI.XmlLayout
	FROM
			STB_ScreenLayoutInfo SLI WITH(NOLOCK)
	WHERE
			SLI.Name = @Name AND
			SLI.Version = ( SELECT 
									MAX(SLI2.[Version])
							FROM 
									STB_ScreenLayoutInfo SLI2 WITH(NOLOCK) 
							WHERE 
									SLI2.Name = @Name
						   )
			
      
	DECLARE @iDoc INT
   
	BEGIN TRY
		   EXEC sp_xml_preparedocument @iDoc OUTPUT, @Xml
		   
		   SELECT
				 @pUserType AS UserType,
				 @Name AS Name,
				 VL.Name AS FunctionName,
				 ISNULL(ISNULL(SR.Value,DSR.Value),VL.Caption) AS Caption,
				 VL.Description,
				 UTFP.Allow
		   FROM
				 OPENXML(@idoc , '/ScreenInfo/Actions/Action' , 2)
				 WITH  (
							  Name NVARCHAR (50),
							  Caption NVARCHAR(50),
							  Description NVARCHAR(100),
							  DisplayType VARCHAR(50)
					   ) VL
			LEFT OUTER JOIN STB_UserTypeFunctionPermission UTFP
				ON (UTFP.UserType = @UserType AND UTFP.Name = @Name AND UTFP.FunctionName = VL.Name)
			LEFT OUTER JOIN STB_StringResources DSR WITH(NOLOCK)
				ON	DSR.Language = 'Default' AND
					DSR.Type = 'AddOn' AND
					DSR.Name = VL.Caption
			LEFT OUTER JOIN STB_StringResources SR WITH(NOLOCK)
				ON	SR.Language = @Language AND
					SR.Type = 'AddOn' AND
					SR.Name = VL.Caption
			WHERE
					VL.DisplayType = 'Button'
		
	END TRY
	BEGIN CATCH
			PRINT ERROR_MESSAGE()
	END CATCH
   
	EXEC sp_xml_removedocument @iDoc
	
END







GO

