-- Procedure: usp_GetViewListForUserType






-- =============================================
-- Author:		Park Jong Seob (jspark@awoo.co.kr)
-- Create date: 2016-01-20
-- Browsable : true
-- Description:	Get View List For UserType
-- =============================================
CREATE PROCEDURE [dbo].[usp_GetViewListForUserType]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(50),
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
			STB_ScreenInfo SI WITH(NOLOCK)
			INNER JOIN STB_ScreenLayoutInfo SLI WITH(NOLOCK)
				ON	SLI.Name = SI.Name AND
					SLI.Version = SI.CurrentVersion
	WHERE
			SLI.Name = @Name
      
	DECLARE @iDoc INT
   
	BEGIN TRY
		   EXEC sp_xml_preparedocument @iDoc OUTPUT, @Xml
		   
		   SELECT
				 @UserType AS UserType,
				 @Name AS Name,
				 VL.Name AS ViewName,
				 ISNULL(ISNULL(SR.Value,DSR.Value),VL.Caption) AS Caption,
				 ISNULL(UTVP.AllowAdd,0) AS AllowAdd,
				 ISNULL(UTVP.AllowModify,0) AS AllowModify,
				 ISNULL(UTVP.AllowDelete,0) AS AllowDelete,
				 ISNULL(UTVP.AllowExcel,0) AS AllowExcel,
				 ISNULL(UTVP.AllowImport,0) AS AllowImport
		   FROM
				 OPENXML(@idoc , '/ScreenInfo/Views/ViewInfo' , 2)
				 WITH  (
							Name NVARCHAR (50),
							Caption NVARCHAR(50)
					   ) VL
			LEFT OUTER JOIN STB_UserTypeViewPermission UTVP					   
				ON (UTVP.UserType = @UserType AND UTVP.Name = @Name AND UTVP.ViewName = VL.Name)
			LEFT OUTER JOIN STB_StringResources DSR WITH(NOLOCK)
				ON	DSR.Language = 'Default' AND
					DSR.Type = 'AddOn' AND
					DSR.Name = VL.Caption
			LEFT OUTER JOIN STB_StringResources SR WITH(NOLOCK)
				ON	SR.Language = @Language AND
					SR.Type = 'AddOn' AND
					SR.Name = VL.Caption
		
	END TRY
	BEGIN CATCH
			PRINT ERROR_MESSAGE()
	END CATCH
   
	EXEC sp_xml_removedocument @iDoc
	
END







GO

