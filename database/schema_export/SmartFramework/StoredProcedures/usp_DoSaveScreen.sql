-- Procedure: usp_DoSaveScreen






-- =============================================
-- Author:		Kim Han Young
-- Create date: 2016-01-13
-- Browsable : false
-- Description:	Save Screen
-- =============================================
CREATE PROCEDURE [dbo].[usp_DoSaveScreen]
	@pProcessLanguage VARCHAR(20),
	@pProcessUserID VARCHAR(20),
	@pName VARCHAR(50),
	@pTCode VARCHAR(10) = NULL,
	@pIsFolder BIT,
	@pIsNeverClose BIT = 0,
	@pShowAfterStart BIT = 0,
	@pShowInMenu BIT = 1,
	@pParentName VARCHAR(50) = NULL,
	@pCaption NVARCHAR(100),
	@pLayout VARBINARY(MAX) = NULL,
	@pXmlLayout NVARCHAR(MAX) = NULL,
	@pSnapshot VARBINARY(MAX) = NULL,	
	@pDeveloperVersion VARCHAR(20),
	@pVersion INT,
	@pSkipVersionUp BIT = 0,
	@pDescription NVARCHAR(MAX) = NULL
AS
BEGIN
	SET NOCOUNT ON;

	IF @pIsFolder NOT IN (1,0) BEGIN
		RAISERROR('IsFolder value is invalid.',16,1)
		RETURN
	END
	DECLARE @Name VARCHAR(50) = @pName,
			@DeveloperVersion VARCHAR(20) = @pDeveloperVersion,
			@CurrentVersion INT,
			@CheckOutUserID VARCHAR(20)

	SELECT
			@CheckOutUserID = CASE 
								WHEN ISNULL(SI.CheckOutUserID,'') = '' THEN @pProcessUserID 
								ELSE SI.CheckOutUserID 
							  END
	FROM
			STB_ScreenInfo SI 
	WHERE
			SI.Name = @Name

	IF @CheckOutUserID <> @pProcessUserID BEGIN
		DECLARE @CheckOutAreadyError NVARCHAR(MAX)
		EXEC usp_GetSystemStringResource	@pProcessLanguage,
											'^%s (이)가 편집중입니다.체크아웃후에 다시 열어서 저장하세요.^',
											@CheckOutAreadyError OUTPUT		
		RAISERROR(@CheckOutAreadyError,16,1,@CheckOutUserID)
		RETURN
	END

	SELECT
			@CurrentVersion = ISNULL(MAX(SLI.Version),0)
	FROM
			STB_ScreenLayoutInfo  SLI
	WHERE
			SLI.Name = @Name --AND
			--SLI.DeveloperVersion = @DeveloperVersion
	
	
	IF @pSkipVersionUp = 1 BEGIN
		SET @CurrentVersion = @pVersion
	END
	
	IF @CurrentVersion = 0 BEGIN
		SET @pSkipVersionUp = 0
	END		
	DECLARE @a VARCHAR(10) = @pVersion,
			@B VARCHAR(10) = @pSkipVersionUp,
			@c VARCHAR(10) = @CurrentVersion,
			@D varchar(10) = @pIsFolder

	
	IF @pIsFolder = 0 BEGIN
		IF @pSkipVersionUp = 0 OR @CurrentVersion = 0 BEGIN
			
			SET @CurrentVersion = ISNULL(@CurrentVersion,0) + 1
			INSERT INTO STB_ScreenLayoutInfo
			(
				Name,
				DeveloperVersion,
				Version,
				Layout,
				XmlLayout,
				Snapshot,
				Description,
				CreateDateTime,
				CreateUserID,
				ChangeDateTime,
				ChangeUserID
			)
			VALUES
			(
				@Name,
				@DeveloperVersion,
				@CurrentVersion,
				@pLayout,
				@pXmlLayout,
				@pSnapshot,
				@pDescription,
				GETDATE(),
				@pProcessUserID,
				GETDATE(),
				@pProcessUserID
			)
		END ELSE BEGIN
			
			-- 메뉴를 이동하는 경우에는 @Layout 이 NULL
			IF @pLayout IS NOT NULL BEGIN
				UPDATE STB_ScreenLayoutInfo
				SET
						Layout = @pLayout,
						XmlLayout = @pXmlLayout,
						Snapshot = @pSnapshot,
						Description = @pDescription,
						ChangeDateTime = GETDATE(),
						ChangeUserID = @pProcessUserID
				WHERE
						Name = @Name AND
						--DeveloperVersion = @DeveloperVersion AND
						Version = @CurrentVersion		
						
				IF @@ROWCOUNT = 0 BEGIN
					RAISERROR('Save screen first',16,1)
					RETURN
				END			
			END
		END
		--IF @pProcessUserID = 'admin'
		--BEGIN
			IF NOT EXISTS (
					SELECT 
							1 
					FROM 
							STB_UserTypeBasicPermission UTBP WITH (NOLOCK)
					WHERE 
							UTBP.UserType = 'Admin' AND
							UTBP.Name = @Name
					)
			BEGIN
					INSERT INTO STB_UserTypeBasicPermission
						(UserType, Name, AllowView, AllowAdd, AllowModify, AllowDelete)
					VALUES
						('Admin', @Name, 1, 1, 1, 1)
			END
			
			
			DECLARE @iDoc INT
		   
			BEGIN TRY
					EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXmlLayout
				   
				   
					INSERT INTO STB_UserTypeViewPermission
						(UserType, Name, ViewName, AllowAdd, AllowModify, AllowDelete, AllowExcel, AllowImport)
					SELECT
							'Admin',
							@Name,
							VL.Name AS ViewName,
							1,
							1,
							1,
							1,
							1
					FROM
							OPENXML(@idoc , '/ScreenInfo/Views/ViewInfo' , 2)
							WITH  (
										Name NVARCHAR (50)
									) VL
					WHERE
							VL.Name NOT IN (
												SELECT
														UTVP.ViewName
												FROM	
														STB_UserTypeViewPermission UTVP
												WHERE 
														UTVP.UserType = 'Admin' AND
														UTVP.Name = @Name
										  )
				   
					INSERT INTO STB_UserTypeFunctionPermission
						(UserType, Name, FunctionName, Allow)
					SELECT
						 'Admin',
						 @Name AS Name,
						 VL.Name AS FunctionName,
						 1
					FROM
						 OPENXML(@idoc , '/ScreenInfo/Actions/Action' , 2)
						 WITH  (
									  Name NVARCHAR (50),
									  Caption NVARCHAR(50),
									  Description NVARCHAR(100)
							   ) VL
					WHERE
							VL.Name NOT IN (
												SELECT
														UTFP.FunctionName
												FROM
														STB_UserTypeFunctionPermission UTFP
												WHERE
														UTFP.UserType = 'Admin' AND
														UTFP.Name = @Name 
											)
			END TRY
			BEGIN CATCH
					PRINT ERROR_MESSAGE()
					--DECLARE @ERROR NVARCHAR(MAX) = ERROR_MESSAGE()
					--RAISERROR(@ERROR,16,1)
			END CATCH
		   
			EXEC sp_xml_removedocument @iDoc			
			
							
							
		--END
		
	END
	
	EXEC usp_DoAddStringResource @pProcessLanguage = @pProcessLanguage,
								 @pType = 'Addon',
								 @pName = @pCaption OUTPUT,
								 @pValue = @pCaption
	
	UPDATE STB_ScreenInfo
	SET
			CurrentVersion = @CurrentVersion,
			TCode = @pTCode,
			IsFolder = @pIsFolder,
			IsNeverClose = @pIsNeverClose,
			ShowAfterStart = @pShowAfterStart,
			ShowInMenu = @pShowInMenu,
			ParentName = @pParentName,
			Caption = @pCaption,		
			IsDelete = 0,
			ChangeDateTime = GETDATE(),
			ChangeUserID = @pProcessUserID
	WHERE
			Name = @Name
			
	IF @@ROWCOUNT = 0 BEGIN
		INSERT INTO STB_ScreenInfo
		(
			Name,
			TCode,
			IsFolder,
			IsNeverClose,
			ShowAfterStart,
			ShowInMenu,
			ParentName,
			Caption,
			IsDelete,
			AccessType,
			CurrentVersion,
			CreateDateTime,
			CreateUserID,
			ChangeDateTime,
			ChangeUserID,
			CheckOutUserID
		)
		VALUES
		(
			@Name,
			@pTCode,
			@pIsFolder,
			@pIsNeverClose,
			@pShowAfterStart,
			@pShowInMenu,
			@pParentName,
			@pCaption,
			0,
			'PC,Web',
			@CurrentVersion,
			GETDATE(),
			@pProcessUserID,
			GETDATE(),
			@pProcessUserID,
			@pProcessUserID
		)
	END
			
END







GO

