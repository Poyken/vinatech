-- Trigger: tgScreenObjectsIUD




-- =============================================
-- Author:		Kim Han Young
-- Create date: 2016-05-03
-- Description:	메뉴가 저장될 때 화면 구조정보를 업데이트 합니다.
-- =============================================
CREATE TRIGGER [dbo].[tgScreenObjectsIUD]
   ON  [dbo].[STB_ScreenLayoutInfo]
   AFTER INSERT,DELETE,UPDATE
AS 
BEGIN
	SET NOCOUNT ON;

	DELETE FROM STB_ScreenObjects
	WHERE
			ScreenName IN ( SELECT Name FROM deleted D) 

	DECLARE @Screens TABLE
	(
		ROW INT IDENTITY(1,1),
		Name VARCHAR(50),
		Xml NVARCHAR(MAX)
	)
	INSERT INTO @Screens
	SELECT
			I.Name,
			I.XmlLayout
	FROM
			inserted I

      
	DECLARE @iDoc INT,
			@ROW INT = 1,
			@COUNT INT,
			@Name VARCHAR(50),
			@XML NVARCHAR(MAX)
			
	SELECT @COUNT = COUNT(1) FROM @Screens
   
	WHILE @ROW <= @COUNT BEGIN
		BEGIN TRY
			SELECT
					@Name = S.Name,
					@Xml = S.Xml
			FROM
					@Screens S
			WHERE
					S.ROW = @ROW
				
			EXEC sp_xml_preparedocument @iDoc OUTPUT, @Xml
		   
			INSERT INTO STB_ScreenObjects
			(
				ScreenName,
				ObjectType,
				ObjectName,
				Description
			)			
			SELECT
					@Name,
					'SearchFunction',
					SF.Name,
					SF.Description
			FROM
					OPENXML(@idoc , '/ScreenInfo/SearchFunctions/GUIFunction' , 2)
					WITH	(
								Name NVARCHAR (50),
								Description NVARCHAR(500)
							) SF
							
			INSERT INTO STB_ScreenObjects
			(
				ScreenName,
				ObjectType,
				ObjectName,
				Description
			)			
			SELECT
					@Name,
					'ExecuteFunction',
					EF.Name,
					EF.Description
			FROM
					OPENXML(@idoc , '/ScreenInfo/ExecuteFunctions/GUIFunction' , 2)
					WITH	(
								Name NVARCHAR (50),
								Description NVARCHAR(500)
							) EF
							
			INSERT INTO STB_ScreenObjects
			(
				ScreenName,
				ObjectType,
				ObjectName,
				Caption,
				Description
			)			
			SELECT
					@Name,
					'Action',
					A.Name,
					A.Caption,
					A.Description					
			FROM
					OPENXML(@idoc , '/ScreenInfo/Actions/Action' , 2)
					WITH	(
								Name NVARCHAR (50),
								Caption NVARCHAR(500),
								Description NVARCHAR(500)
							) A
							
			INSERT INTO STB_ScreenObjects
			(
				ScreenName,
				ObjectType,
				ObjectName,
				Caption,
				Description
			)			
			SELECT
					@Name,
					'View',
					VL.Name,
					VL.Caption,
					VL.Description
			FROM
					OPENXML(@idoc , '/ScreenInfo/Views/ViewInfo' , 2)
					WITH	(
								Name NVARCHAR (50),
								Caption NVARCHAR(500),
								Description NVARCHAR(500)
							) VL
	
		END TRY
		BEGIN CATCH
				PRINT ERROR_MESSAGE()
		END CATCH
   
		EXEC sp_xml_removedocument @iDoc
		
		SET @ROW = @ROW + 1
	END
END




GO

