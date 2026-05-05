-- Procedure: usp_GetProgramInfo






-- =============================================
-- Author:		Kim Han Young(hykim@awoo.co.kr)
-- Browsable: false
-- Create date: 2016-02-03
-- Description:	Get Program Information
-- =============================================
CREATE PROCEDURE [dbo].[usp_GetProgramInfo]
	@pProgramName NVARCHAR(50) = 'GUI',
	@pPlatform VARCHAR(10),
	@pFileListXml NVARCHAR(MAX) = NULL
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @ProgramName NVARCHAR(50) = CASE WHEN ISNULL(@pProgramName,'') = '' THEN 'GUI' ELSE @pProgramName END,
			@Platform VARCHAR(10) = @pPlatform

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
					OPENXML(@idoc , '/ProgramInfo/FileList' , 2)
					WITH	(
								 FileName NVARCHAR (255),
								 Platform VARCHAR(10),
								 Version VARCHAR (20)
							)
									
			EXEC sp_xml_removedocument @iDoc	
		END TRY
		BEGIN CATCH
			EXEC sp_xml_removedocument @iDoc
		END CATCH
	END
	
	SELECT
			(
				SELECT
						CCI.ConstValue
				FROM
						STB_ConstCodeInfo CCI
				WHERE
						CCI.ConstName = 'ProgramTitle'
			) AS Title,
			CONVERT(BIT,
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
			END) AS HasNewVersion
			
	IF ISNULL(@pFileListXml,'') = '' BEGIN
		SELECT
				UF.ProgramName,
				UF.Platform,	-- 2017-09-08 JGH 추가
				UF.FileName,
				UF.Version,	-- 2016-08-26 JGH 추가
				UF.FileData,
				UF.TargetPath,
				UF.CreateDateTime,
				UF.CreateUserID,
				UF.ChangeDateTime,
				UF.ChangeUserID
		FROM
				STB_UpgradeFiles UF WITH(NOLOCK)
		WHERE
				UF.ProgramName = @ProgramName AND
				(UF.Platform = 'Any' OR UF.Platform = @Platform)
	END ELSE BEGIN
		SELECT
				UF.FileName,
				UF.Platform,	-- 2017-09-08 JGH 추가
				UF.Version,
				UF.TargetPath,
				CASE 
					WHEN OLD.FileName IS NULL THEN UF.FileData
					ELSE NULL
				END AS FileData,
				UF.CreateDateTime,
				UF.CreateUserID,
				UF.ChangeDateTime,
				UF.ChangeUserID
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

