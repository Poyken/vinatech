
-- =============================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Create date: 2020-10-15
-- Browsable : true
-- Group : 공통관리
-- Description:	
-- Modified:
-- =============================================
CREATE PROCEDURE dbo.usp_AgencyInfo_iud
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
    @pProcessViewName VARCHAR(50),
	@pXml NVARCHAR(MAX) = null
AS
BEGIN
	SET NOCOUNT ON;

    DECLARE @ProcessUserID VARCHAR(20) = @pProcessUserID
    DECLARE @ProcessLanguage VARCHAR(20) = @pProcessLanguage
    DECLARE @ProcessViewName VARCHAR(50) = @pProcessViewName
    DECLARE @InsertTableName VARCHAR(100) = '/DataSet/' + @ProcessViewName + '_INSERT'
    DECLARE @UpdateTableName VARCHAR(100) = '/DataSet/' + @ProcessViewName + '_UPDATE'
    DECLARE @DeleteTableName VARCHAR(100) = '/DataSet/' + @ProcessViewName + '_DELETE'
    DECLARE @ERROR_MSG NVARCHAR(MAX)
    DECLARE @IUD_FLAG VARCHAR(10)
    DECLARE @IsAutoKey BIT
    DECLARE @IsLoopIUD BIT
    DECLARE @PrefixString VARCHAR(20)
    DECLARE @SerialLen INT

    -- Declare Columns Variable
  DECLARE @OldAgencyCode VARCHAR(20)
  DECLARE @AgencyCode VARCHAR(20)
  DECLARE @AgencyName NVARCHAR(100)
  DECLARE @IsUsed BIT
  DECLARE @CreateDateTime DATETIME
  DECLARE @CreateUserID VARCHAR(20)
  DECLARE @ChangeDateTime DATETIME
  DECLARE @ChangeUserID VARCHAR(20)
  DECLARE @CountryName NVARCHAR(100)
  DECLARE @AgencyAbbreviationName NVARCHAR(100)
  DECLARE @Remark NVARCHAR(MAX)


	DECLARE @iDoc INT

    EXEC SmartFramework.dbo.usp_GetSerialRule 
			@pTableName = 'STB_AgencyInfo',
			@pIsAutoKey = @IsAutoKey OUTPUT,
			@pIsLoopIUD = @IsLoopIUD OUTPUT,
			@pPrefixData = @PrefixString OUTPUT,
			@pSerialLen = @SerialLen OUTPUT
    
    IF @IsAutoKey = 0 AND @IsLoopIUD = 0 BEGIN
        
        EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
	
	    BEGIN TRY
			-- Process Insert Table
            MERGE STB_AgencyInfo AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldAgencyCode IS NULL THEN AgencyCode
							    ELSE OldAgencyCode
							END AS OldAgencyCode,
							AgencyCode,
							AgencyName,
							IsUsed,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID,
							CountryName,
							AgencyAbbreviationName,
							Remark
					FROM
							OPENXML(@idoc , @InsertTableName , 2)
							WITH  (
										OldAgencyCode VARCHAR(20),
										AgencyCode VARCHAR(20),
										AgencyName NVARCHAR(100),
										IsUsed BIT,
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20),
										CountryName NVARCHAR(100),
										AgencyAbbreviationName NVARCHAR(100),
										Remark NVARCHAR(MAX)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.AgencyCode = SourceTable.AgencyCode
				)

			WHEN MATCHED THEN
				UPDATE SET
					AgencyCode = ISNULL(SourceTable.AgencyCode,TargetTable.AgencyCode),
					AgencyName = ISNULL(SourceTable.AgencyName,TargetTable.AgencyName),
					IsUsed = ISNULL(SourceTable.IsUsed,TargetTable.IsUsed),
					ChangeDateTime = ISNULL(SourceTable.ChangeDateTime,TargetTable.ChangeDateTime),
					ChangeUserID = ISNULL(SourceTable.ChangeUserID,TargetTable.ChangeUserID),
					CountryName = ISNULL(SourceTable.CountryName,TargetTable.CountryName),
					AgencyAbbreviationName = ISNULL(SourceTable.AgencyAbbreviationName,TargetTable.AgencyAbbreviationName),
					Remark = ISNULL(SourceTable.Remark,TargetTable.Remark)
			WHEN NOT MATCHED THEN
				INSERT
					(
						AgencyCode,
						AgencyName,
						IsUsed,
						CreateDateTime,
						CreateUserID,
						CountryName,
						AgencyAbbreviationName,
						Remark
					)
				VALUES
					(
							SourceTable.AgencyCode,
							SourceTable.AgencyName,
							SourceTable.IsUsed,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID,
							SourceTable.CountryName,
							SourceTable.AgencyAbbreviationName,
							SourceTable.Remark
					);


			-- Process Update Table
            MERGE STB_AgencyInfo AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldAgencyCode IS NULL THEN AgencyCode
							    ELSE OldAgencyCode
							END AS OldAgencyCode,
							AgencyCode,
							AgencyName,
							IsUsed,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID,
							CountryName,
							AgencyAbbreviationName,
							Remark
					FROM
							OPENXML(@idoc , @UpdateTableName , 2)
							WITH  (
										OldAgencyCode VARCHAR(20),
										AgencyCode VARCHAR(20),
										AgencyName NVARCHAR(100),
										IsUsed BIT,
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20),
										CountryName NVARCHAR(100),
										AgencyAbbreviationName NVARCHAR(100),
										Remark NVARCHAR(MAX)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.AgencyCode = SourceTable.OldAgencyCode
				)

			WHEN MATCHED THEN
				UPDATE SET
					AgencyCode = ISNULL(SourceTable.AgencyCode,TargetTable.AgencyCode),
					AgencyName = ISNULL(SourceTable.AgencyName,TargetTable.AgencyName),
					IsUsed = ISNULL(SourceTable.IsUsed,TargetTable.IsUsed),
					ChangeDateTime = ISNULL(SourceTable.ChangeDateTime,TargetTable.ChangeDateTime),
					ChangeUserID = ISNULL(SourceTable.ChangeUserID,TargetTable.ChangeUserID),
					CountryName = ISNULL(SourceTable.CountryName,TargetTable.CountryName),
					AgencyAbbreviationName = ISNULL(SourceTable.AgencyAbbreviationName,TargetTable.AgencyAbbreviationName),
					Remark = ISNULL(SourceTable.Remark,TargetTable.Remark)
			WHEN NOT MATCHED THEN
				INSERT
					(
						AgencyCode,
						AgencyName,
						IsUsed,
						CreateDateTime,
						CreateUserID,
						CountryName,
						AgencyAbbreviationName,
						Remark
					)
				VALUES
					(
							SourceTable.AgencyCode,
							SourceTable.AgencyName,
							SourceTable.IsUsed,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID,
							SourceTable.CountryName,
							SourceTable.AgencyAbbreviationName,
							SourceTable.Remark
					);


			-- Process Delete Table
            MERGE STB_AgencyInfo AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldAgencyCode IS NULL THEN AgencyCode
							    ELSE OldAgencyCode
							END AS OldAgencyCode,
							AgencyCode
					FROM
							OPENXML(@idoc , @DeleteTableName , 2)
							WITH  (
										OldAgencyCode VARCHAR(20),
										AgencyCode VARCHAR(20)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.AgencyCode = SourceTable.AgencyCode
				)

			WHEN MATCHED THEN
				DELETE;

        END TRY
	    BEGIN CATCH
            SET @ERROR_MSG = ERROR_MESSAGE()
			RAISERROR( @ERROR_MSG ,16, 1)
	    END CATCH
		
	    EXEC sp_xml_removedocument @idoc

    END ELSE BEGIN
        PRINT 'Loop was removed'
    END
END
