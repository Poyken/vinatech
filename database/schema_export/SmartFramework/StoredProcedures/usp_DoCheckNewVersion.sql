-- Procedure: usp_DoCheckNewVersion






-- =============================================
-- Author:		Kim Han Young(hykim@awoo.co.kr)
-- Browsable: false
-- Create date: 2016-07-07
-- Description:	Check New Version
-- =============================================
CREATE PROCEDURE [dbo].[usp_DoCheckNewVersion]
	@pProgramName NVARCHAR(50) = 'GUI',
	@pPlatform VARCHAR(10),
	@pFileListXml NVARCHAR(MAX) = NULL,
	@pTableName VARCHAR(100) = NULL,
	@pHasNewVersion BIT = 0 OUTPUT
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @ProgramName NVARCHAR(50) = @pProgramName,
			@Platform VARCHAR(10) = @pPlatform,
			@TableName VARCHAR(100) = CASE WHEN @pTableName IS NULL THEN '/ProgramInfo/Files/UpgradeFileInfo' ELSE @pTableName END

	DECLARE @OldFileList TABLE
	(
		FileName NVARCHAR(255),
		Platform VARCHAR(10),
		Version VARCHAR(20)
	)
	IF ISNULL(@pFileListXml,'') <> '' BEGIN
		DECLARE @iDoc INT	
		EXEC sp_xml_preparedocument @iDoc OUTPUT, @pFileListXml
		
		BEGIN TRY
			INSERT INTO @OldFileList
			SELECT
					FileName,
					Platform,
					Version
			FROM
					OPENXML(@idoc , @TableName , 2)
					--OPENXML(@idoc , '/ProgramInfo/Files/UpgradeFileInfo' , 2)
					--OPENXML(@idoc , '/ProgramInfo/FileList' , 2)
					WITH	(
								 FileName NVARCHAR (255),
								 Platform VARCHAR(10),
								 Version INT
							)
									
			EXEC sp_xml_removedocument @iDoc	
		END TRY
		BEGIN CATCH
			EXEC sp_xml_removedocument @iDoc
		END CATCH
	END
	-- 2017-09-08 JGH 수정
	SET @pHasNewVersion = CONVERT(BIT,
							CASE
								WHEN
										(
											SELECT
													COUNT(1)
											FROM
													(
														SELECT
																CASE 
																	WHEN OLD.FileName IS NULL THEN 1
																	ELSE 0
																END AS NewVersion
														FROM
																STB_UpgradeFiles UF WITH(NOLOCK)
																LEFT OUTER JOIN @OldFileList OLD
																	ON	UF.Platform = OLD.Platform AND
																		UF.FileName = OLD.FileName AND														
																		UF.Version = OLD.Version
														
														WHERE
																UF.ProgramName = @ProgramName AND
																(UF.Platform = 'Any' OR UF.Platform = @Platform)
													) FileList
											WHERE
													FileList.NewVersion = 1
										) > 0 THEN 1
								ELSE 0
							END)

	SELECT
			(
				SELECT
						CCI.ConstValue
				FROM
						STB_ConstCodeInfo CCI
				WHERE
						CCI.ConstName = 'ProgramTitle'
			) AS Title,
			@pHasNewVersion AS HasNewVersion

	
			
	IF ISNULL(@pFileListXml,'') = '' BEGIN
		SELECT
				UF.ProgramName,
				UF.Platform,
				UF.FileName,
				UF.Version,
				UF.TargetPath,
				UF.ExtractZip,
				-1 AS OldVersion
		FROM
				STB_UpgradeFiles UF WITH(NOLOCK)
		WHERE
				UF.ProgramName = @ProgramName AND
				(UF.Platform = 'Any' OR UF.Platform = @Platform) 
	END ELSE BEGIN
		SELECT
				UF.ProgramName,
				UF.Platform,
				UF.FileName,
				UF.Version,
				UF.TargetPath,
				UF.ExtractZip,
				ISNULL(OLD.Version,-1) AS OldVersion
		FROM
				STB_UpgradeFiles UF WITH(NOLOCK)
				LEFT OUTER JOIN @OldFileList OLD
					ON	OLD.FileName = UF.FileName AND
						OLD.Platform = UF.Platform AND
						OLD.Version = UF.Version
		WHERE
				UF.ProgramName = @ProgramName AND
				(UF.Platform = 'Any' OR UF.Platform = @Platform)
	END
END







GO

