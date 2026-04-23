

-- =============================================
-- Author: Park Jong Hoon(jhpark@awoo.co.kr)
-- Browsable : true
-- Group : 공용검사관리
-- Description:	공용검사유형정보 IUD
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_CommInspTypeInfo_iud]
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
    DECLARE @MaxKeyField VARCHAR(20)

    -- Declare Columns Variable
	DECLARE @OldCommInspTypeCode VARCHAR(50)
	DECLARE @CommInspTypeCode VARCHAR(50)
	DECLARE @CompanyCode VARCHAR(20)
	DECLARE @WorkCenterCode VARCHAR(20)
	DECLARE @CommInspTypeName NVARCHAR(100)
	DECLARE @CommInspTypeDesc NVARCHAR(MAX)
	DECLARE @IsRouteKey BIT
	DECLARE @IsFacilityRouteKey BIT
	DECLARE @IsMachineKey BIT
	DECLARE @IsMoldKey BIT
	DECLARE @IsMaterialKey BIT
	DECLARE @IsDocKey BIT
	DECLARE @IsShiftKey BIT
	DECLARE @IsTimeCodeKey BIT
	DECLARE @IsCategoryKey BIT
	DECLARE @IsProdKey BIT
	DECLARE @CreateDateTime DATETIME
	DECLARE @CreateUserID VARCHAR(20)
	DECLARE @ChangeDateTime DATETIME
	DECLARE @ChangeUserID VARCHAR(20)
	
	
	DECLARE @ImageFileID BIGINT
	DECLARE @FileName NVARCHAR(255)
	DECLARE @FileSize BIGINT
	DECLARE @FileData VARBINARY(MAX)
	DECLARE @IsAutoFinish BIT
	DECLARE @CITIExtText01 VARCHAR(200)
	DECLARE @CITIExtText02 VARCHAR(200)
	DECLARE @CITIExtText03 VARCHAR(200)
	DECLARE @CITIExtInt01 BIGINT
	DECLARE @CITIExtInt02 BIGINT
	DECLARE @CITIExtInt03 BIGINT
	DECLARE @CITIExtReal01 NUMERIC(20,5)
	DECLARE @CITIExtReal02 NUMERIC(20,5)
	DECLARE @CITIExtReal03 NUMERIC(20,5)

	DECLARE @iDoc INT

    EXEC SmartFramework.dbo.usp_GetSerialRule 
			@pTableName = 'STB_CommInspTypeInfo',
			@pIsAutoKey = @IsAutoKey OUTPUT,
			@pIsLoopIUD = @IsLoopIUD OUTPUT,
			@pPrefixData = @PrefixString OUTPUT,
			@pSerialLen = @SerialLen OUTPUT
    
    IF @IsAutoKey = 0 AND @IsLoopIUD = 0 BEGIN
   
	    EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
	
	    BEGIN TRY
			-- Process Insert Table
            MERGE STB_CommInspTypeInfo AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldCommInspTypeCode IS NULL THEN CommInspTypeCode
							    ELSE OldCommInspTypeCode
							END AS OldCommInspTypeCode,
							CommInspTypeCode,
							CompanyCode,
							WorkCenterCode,
							CommInspTypeName,
							CommInspTypeDesc,
							IsRouteKey,
							IsFacilityRouteKey,
							IsMachineKey,
							IsMoldKey,
							IsMaterialKey,
							IsDocKey,
							IsShiftKey,
							IsTimeCodeKey,
							IsCategoryKey,
							IsProdKey,
							ImageFileID,
							IsAutoFinish,
							CITIExtText01,
							CITIExtText02,
							CITIExtText03,
							CITIExtInt01,
							CITIExtInt02,
							CITIExtInt03,
							CITIExtReal01,
							CITIExtReal02,
							CITIExtReal03,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @InsertTableName , 2)
							WITH  (
										OldCommInspTypeCode VARCHAR(50),
										CommInspTypeCode VARCHAR(50),
										CompanyCode VARCHAR(20),
										WorkCenterCode VARCHAR(20),
										CommInspTypeName NVARCHAR(100),
										CommInspTypeDesc NVARCHAR(MAX),
										IsRouteKey BIT,
										IsFacilityRouteKey BIT,
										IsMachineKey BIT,
										IsMoldKey BIT,
										IsMaterialKey BIT,
										IsDocKey BIT,
										IsShiftKey BIT,
										IsTimeCodeKey BIT,
										IsCategoryKey BIT,
										IsProdKey BIT,
										ImageFileID BIGINT,
										IsAutoFinish BIT,
										CITIExtText01 VARCHAR(200),
										CITIExtText02 VARCHAR(200),
										CITIExtText03 VARCHAR(200),
										CITIExtInt01 BIGINT,
										CITIExtInt02 BIGINT,
										CITIExtInt03 BIGINT,
										CITIExtReal01 NUMERIC(20,5),
										CITIExtReal02 NUMERIC(20,5),
										CITIExtReal03 NUMERIC(20,5),
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.CommInspTypeCode = SourceTable.CommInspTypeCode
				)

			WHEN MATCHED THEN
				UPDATE SET
					CommInspTypeCode = SourceTable.CommInspTypeCode,
					CompanyCode = SourceTable.CompanyCode,
					WorkCenterCode = SourceTable.WorkCenterCode,
					CommInspTypeName = SourceTable.CommInspTypeName,
					CommInspTypeDesc = SourceTable.CommInspTypeDesc,
					IsRouteKey = SourceTable.IsRouteKey,
					IsFacilityRouteKey = SourceTable.IsFacilityRouteKey,
					IsMachineKey = SourceTable.IsMachineKey,
					IsMoldKey = SourceTable.IsMoldKey,
					IsMaterialKey = SourceTable.IsMaterialKey,
					IsDocKey = SourceTable.IsDocKey,
					IsShiftKey = SourceTable.IsShiftKey,
					IsTimeCodeKey = SourceTable.IsTimeCodeKey,
					IsCategoryKey = SourceTable.IsCategoryKey,
					IsProdKey = SourceTable.IsProdKey,
					ImageFileID = SourceTable.ImageFileID,
					IsAutoFinish = SourceTable.IsAutoFinish,
					CITIExtText01 = SourceTable.CITIExtText01,
					CITIExtText02 = SourceTable.CITIExtText02,
					CITIExtText03 = SourceTable.CITIExtText03,
					CITIExtInt01 = SourceTable.CITIExtInt01,
					CITIExtInt02 = SourceTable.CITIExtInt02,
					CITIExtInt03 = SourceTable.CITIExtInt03,
					CITIExtReal01 = SourceTable.CITIExtReal01,
					CITIExtReal02 = SourceTable.CITIExtReal02,
					CITIExtReal03 = SourceTable.CITIExtReal03,
					ChangeDateTime = SourceTable.ChangeDateTime,
					ChangeUserID = SourceTable.ChangeUserID
			WHEN NOT MATCHED THEN
				INSERT
					(
						CommInspTypeCode,
						CompanyCode,
						WorkCenterCode,
						CommInspTypeName,
						CommInspTypeDesc,
						IsRouteKey,
						IsFacilityRouteKey,
						IsMachineKey,
						IsMoldKey,
						IsMaterialKey,
						IsDocKey,
						IsShiftKey,
						IsTimeCodeKey,
						IsCategoryKey,
						IsProdKey,
						ImageFileID,
						IsAutoFinish,
						CITIExtText01,
						CITIExtText02,
						CITIExtText03,
						CITIExtInt01,
						CITIExtInt02,
						CITIExtInt03,
						CITIExtReal01,
						CITIExtReal02,
						CITIExtReal03,
						CreateDateTime,
						CreateUserID
					)
				VALUES
					(
							SourceTable.CommInspTypeCode,
							SourceTable.CompanyCode,
							SourceTable.WorkCenterCode,
							SourceTable.CommInspTypeName,
							SourceTable.CommInspTypeDesc,
							SourceTable.IsRouteKey,
							SourceTable.IsFacilityRouteKey,
							SourceTable.IsMachineKey,
							SourceTable.IsMoldKey,
							SourceTable.IsMaterialKey,
							SourceTable.IsDocKey,
							SourceTable.IsShiftKey,
							SourceTable.IsTimeCodeKey,
							SourceTable.IsCategoryKey,
							SourceTable.IsProdKey,
							SourceTable.ImageFileID,
							SourceTable.IsAutoFinish,
							SourceTable.CITIExtText01,
							SourceTable.CITIExtText02,
							SourceTable.CITIExtText03,
							SourceTable.CITIExtInt01,
							SourceTable.CITIExtInt02,
							SourceTable.CITIExtInt03,
							SourceTable.CITIExtReal01,
							SourceTable.CITIExtReal02,
							SourceTable.CITIExtReal03,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID
					);


			-- Process Update Table
            MERGE STB_CommInspTypeInfo AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldCommInspTypeCode IS NULL THEN CommInspTypeCode
							    ELSE OldCommInspTypeCode
							END AS OldCommInspTypeCode,
							CommInspTypeCode,
							CompanyCode,
							WorkCenterCode,
							CommInspTypeName,
							CommInspTypeDesc,
							IsRouteKey,
							IsFacilityRouteKey,
							IsMachineKey,
							IsMoldKey,
							IsMaterialKey,
							IsDocKey,
							IsShiftKey,
							IsTimeCodeKey,
							IsCategoryKey,
							IsProdKey,
							ImageFileID,
							IsAutoFinish,
							CITIExtText01,
							CITIExtText02,
							CITIExtText03,
							CITIExtInt01,
							CITIExtInt02,
							CITIExtInt03,
							CITIExtReal01,
							CITIExtReal02,
							CITIExtReal03,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @UpdateTableName , 2)
							WITH  (
										OldCommInspTypeCode VARCHAR(50),
										CommInspTypeCode VARCHAR(50),
										CompanyCode VARCHAR(20),
										WorkCenterCode VARCHAR(20),
										CommInspTypeName NVARCHAR(100),
										CommInspTypeDesc NVARCHAR(MAX),
										IsRouteKey BIT,
										IsFacilityRouteKey BIT,
										IsMachineKey BIT,
										IsMoldKey BIT,
										IsMaterialKey BIT,
										IsDocKey BIT,
										IsShiftKey BIT,
										IsTimeCodeKey BIT,
										IsCategoryKey BIT,
										IsProdKey BIT,
										ImageFileID BIGINT,
										IsAutoFinish BIT,
										CITIExtText01 VARCHAR(200),
										CITIExtText02 VARCHAR(200),
										CITIExtText03 VARCHAR(200),
										CITIExtInt01 BIGINT,
										CITIExtInt02 BIGINT,
										CITIExtInt03 BIGINT,
										CITIExtReal01 NUMERIC(20,5),
										CITIExtReal02 NUMERIC(20,5),
										CITIExtReal03 NUMERIC(20,5),
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.CommInspTypeCode = SourceTable.OldCommInspTypeCode
				)

			WHEN MATCHED THEN
				UPDATE SET
					CommInspTypeCode = SourceTable.CommInspTypeCode,
					CompanyCode = SourceTable.CompanyCode,
					WorkCenterCode = SourceTable.WorkCenterCode,
					CommInspTypeName = SourceTable.CommInspTypeName,
					CommInspTypeDesc = SourceTable.CommInspTypeDesc,
					IsRouteKey = SourceTable.IsRouteKey,
					IsFacilityRouteKey = SourceTable.IsFacilityRouteKey,
					IsMachineKey = SourceTable.IsMachineKey,
					IsMoldKey = SourceTable.IsMoldKey,
					IsMaterialKey = SourceTable.IsMaterialKey,
					IsDocKey = SourceTable.IsDocKey,
					IsShiftKey = SourceTable.IsShiftKey,
					IsTimeCodeKey = SourceTable.IsTimeCodeKey,
					IsCategoryKey = SourceTable.IsCategoryKey,
					IsProdKey = SourceTable.IsProdKey,
					ImageFileID = SourceTable.ImageFileID,
					IsAutoFinish = SourceTable.IsAutoFinish,
					CITIExtText01 = SourceTable.CITIExtText01,
					CITIExtText02 = SourceTable.CITIExtText02,
					CITIExtText03 = SourceTable.CITIExtText03,
					CITIExtInt01 = SourceTable.CITIExtInt01,
					CITIExtInt02 = SourceTable.CITIExtInt02,
					CITIExtInt03 = SourceTable.CITIExtInt03,
					CITIExtReal01 = SourceTable.CITIExtReal01,
					CITIExtReal02 = SourceTable.CITIExtReal02,
					CITIExtReal03 = SourceTable.CITIExtReal03,
					ChangeDateTime = SourceTable.ChangeDateTime,
					ChangeUserID = SourceTable.ChangeUserID
			WHEN NOT MATCHED THEN
				INSERT
					(
						CommInspTypeCode,
						CompanyCode,
						WorkCenterCode,
						CommInspTypeName,
						CommInspTypeDesc,
						IsRouteKey,
						IsFacilityRouteKey,
						IsMachineKey,
						IsMoldKey,
						IsMaterialKey,
						IsDocKey,
						IsShiftKey,
						IsTimeCodeKey,
						IsCategoryKey,
						IsProdKey,
						ImageFileID,
						IsAutoFinish,
						CITIExtText01,
						CITIExtText02,
						CITIExtText03,
						CITIExtInt01,
						CITIExtInt02,
						CITIExtInt03,
						CITIExtReal01,
						CITIExtReal02,
						CITIExtReal03,
						CreateDateTime,
						CreateUserID
					)
				VALUES
					(
							SourceTable.CommInspTypeCode,
							SourceTable.CompanyCode,
							SourceTable.WorkCenterCode,
							SourceTable.CommInspTypeName,
							SourceTable.CommInspTypeDesc,
							SourceTable.IsRouteKey,
							SourceTable.IsFacilityRouteKey,
							SourceTable.IsMachineKey,
							SourceTable.IsMoldKey,
							SourceTable.IsMaterialKey,
							SourceTable.IsDocKey,
							SourceTable.IsShiftKey,
							SourceTable.IsTimeCodeKey,
							SourceTable.IsCategoryKey,
							SourceTable.IsProdKey,
							SourceTable.ImageFileID,
							SourceTable.IsAutoFinish,
							SourceTable.CITIExtText01,
							SourceTable.CITIExtText02,
							SourceTable.CITIExtText03,
							SourceTable.CITIExtInt01,
							SourceTable.CITIExtInt02,
							SourceTable.CITIExtInt03,
							SourceTable.CITIExtReal01,
							SourceTable.CITIExtReal02,
							SourceTable.CITIExtReal03,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID
					);


			-- Process Delete Table
            MERGE STB_CommInspTypeInfo AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldCommInspTypeCode IS NULL THEN CommInspTypeCode
							    ELSE OldCommInspTypeCode
							END AS OldCommInspTypeCode,
							CommInspTypeCode,
							CompanyCode,
							WorkCenterCode,
							CommInspTypeName,
							CommInspTypeDesc,
							IsRouteKey,
							IsFacilityRouteKey,
							IsMachineKey,
							IsMoldKey,
							IsMaterialKey,
							IsDocKey,
							IsShiftKey,
							IsTimeCodeKey,
							IsCategoryKey,
							IsProdKey,
							ImageFileID,
							IsAutoFinish,
							CITIExtText01,
							CITIExtText02,
							CITIExtText03,
							CITIExtInt01,
							CITIExtInt02,
							CITIExtInt03,
							CITIExtReal01,
							CITIExtReal02,
							CITIExtReal03,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @DeleteTableName , 2)
							WITH  (
										OldCommInspTypeCode VARCHAR(50),
										CommInspTypeCode VARCHAR(50),
										CompanyCode VARCHAR(20),
										WorkCenterCode VARCHAR(20),
										CommInspTypeName NVARCHAR(100),
										CommInspTypeDesc NVARCHAR(MAX),
										IsRouteKey BIT,
										IsFacilityRouteKey BIT,
										IsMachineKey BIT,
										IsMoldKey BIT,
										IsMaterialKey BIT,
										IsDocKey BIT,
										IsShiftKey BIT,
										IsTimeCodeKey BIT,
										IsCategoryKey BIT,
										IsProdKey BIT,
										ImageFileID BIGINT,
										IsAutoFinish BIT,
										CITIExtText01 VARCHAR(200),
										CITIExtText02 VARCHAR(200),
										CITIExtText03 VARCHAR(200),
										CITIExtInt01 BIGINT,
										CITIExtInt02 BIGINT,
										CITIExtInt03 BIGINT,
										CITIExtReal01 NUMERIC(20,5),
										CITIExtReal02 NUMERIC(20,5),
										CITIExtReal03 NUMERIC(20,5),
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.CommInspTypeCode = SourceTable.CommInspTypeCode
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
        EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
        BEGIN TRY
		    DECLARE SourceData CURSOR FOR
                SELECT
                        'INSERT' AS IUD_FLAG,
									OldCommInspTypeCode,
									CommInspTypeCode,
									CompanyCode,
									WorkCenterCode,
									CommInspTypeName,
									CommInspTypeDesc,
									IsRouteKey,
									IsFacilityRouteKey,
									IsMachineKey,
									IsMoldKey,
									IsMaterialKey,
									IsDocKey,
									IsShiftKey,
									IsTimeCodeKey,
									IsCategoryKey,
									IsProdKey,
									[FileName],
									FileSize,
									dbo.fnBase64ToBinary(FileData) as FileData,
									ImageFileID,
									IsAutoFinish,
									CITIExtText01,
									CITIExtText02,
									CITIExtText03,
									CITIExtInt01,
									CITIExtInt02,
									CITIExtInt03,
									CITIExtReal01,
									CITIExtReal02,
									CITIExtReal03,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID
							FROM
									OPENXML(@idoc , @InsertTableName , 2)
							        WITH  (
											 OldCommInspTypeCode VARCHAR(50),
											 CommInspTypeCode VARCHAR(50),
											 CompanyCode VARCHAR(20),
											 WorkCenterCode VARCHAR(20),
											 CommInspTypeName NVARCHAR(100),
											 CommInspTypeDesc NVARCHAR(MAX),
											 IsRouteKey BIT,
											 IsFacilityRouteKey BIT,
											 IsMachineKey BIT,
											 IsMoldKey BIT,
											 IsMaterialKey BIT,
											 IsDocKey BIT,
											 IsShiftKey BIT,
											 IsTimeCodeKey BIT,
											 IsCategoryKey BIT,
											 IsProdKey BIT,
											 [FileName] NVARCHAR(255),
											 FileSize BIGINT,
											 FileData VARCHAR(MAX),
											 ImageFileID BIGINT,
											 IsAutoFinish BIT,
											 CITIExtText01 VARCHAR(200),
											 CITIExtText02 VARCHAR(200),
											 CITIExtText03 VARCHAR(200),
											 CITIExtInt01 BIGINT,
											 CITIExtInt02 BIGINT,
											 CITIExtInt03 BIGINT,
											 CITIExtReal01 NUMERIC(20,5),
											 CITIExtReal02 NUMERIC(20,5),
											 CITIExtReal03 NUMERIC(20,5),
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											)
							UNION ALL
							SELECT
									'UPDATE' AS IUD_FLAG,
									CASE 
										WHEN OldCommInspTypeCode IS NULL THEN CommInspTypeCode
										ELSE OldCommInspTypeCode
									END AS OldCommInspTypeCode,
									CommInspTypeCode,
									CompanyCode,
									WorkCenterCode,
									CommInspTypeName,
									CommInspTypeDesc,
									IsRouteKey,
									IsFacilityRouteKey,
									IsMachineKey,
									IsMoldKey,
									IsMaterialKey,
									IsDocKey,
									IsShiftKey,
									IsTimeCodeKey,
									IsCategoryKey,
									IsProdKey,
									[FileName],
									FileSize,
									dbo.fnBase64ToBinary(FileData) as FileData,
									ImageFileID,
									IsAutoFinish,
									CITIExtText01,
									CITIExtText02,
									CITIExtText03,
									CITIExtInt01,
									CITIExtInt02,
									CITIExtInt03,
									CITIExtReal01,
									CITIExtReal02,
									CITIExtReal03,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID
							FROM
									OPENXML(@idoc , @UpdateTableName , 2)
							        WITH  (
											 OldCommInspTypeCode VARCHAR(50),
											 CommInspTypeCode VARCHAR(50),
											 CompanyCode VARCHAR(20),
											 WorkCenterCode VARCHAR(20),
											 CommInspTypeName NVARCHAR(100),
											 CommInspTypeDesc NVARCHAR(MAX),
											 IsRouteKey BIT,
											 IsFacilityRouteKey BIT,
											 IsMachineKey BIT,
											 IsMoldKey BIT,
											 IsMaterialKey BIT,
											 IsDocKey BIT,
											 IsShiftKey BIT,
											 IsTimeCodeKey BIT,
											 IsCategoryKey BIT,
											 IsProdKey BIT,
											 [FileName] NVARCHAR(255),
											 FileSize BIGINT,
											 FileData VARCHAR(MAX),
											 ImageFileID BIGINT,
											 IsAutoFinish BIT,
											 CITIExtText01 VARCHAR(200),
											 CITIExtText02 VARCHAR(200),
											 CITIExtText03 VARCHAR(200),
											 CITIExtInt01 BIGINT,
											 CITIExtInt02 BIGINT,
											 CITIExtInt03 BIGINT,
											 CITIExtReal01 NUMERIC(20,5),
											 CITIExtReal02 NUMERIC(20,5),
											 CITIExtReal03 NUMERIC(20,5),
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											)
							UNION ALL
							SELECT
									'DELETE' AS IUD_FLAG,
									CASE 
										WHEN OldCommInspTypeCode IS NULL THEN CommInspTypeCode
										ELSE OldCommInspTypeCode
									END AS OldCommInspTypeCode,
									CommInspTypeCode,
									CompanyCode,
									WorkCenterCode,
									CommInspTypeName,
									CommInspTypeDesc,
									IsRouteKey,
									IsFacilityRouteKey,
									IsMachineKey,
									IsMoldKey,
									IsMaterialKey,
									IsDocKey,
									IsShiftKey,
									IsTimeCodeKey,
									IsCategoryKey,
									IsProdKey,
									[FileName],
									FileSize,
									dbo.fnBase64ToBinary(FileData) as FileData,
									ImageFileID,
									IsAutoFinish,
									CITIExtText01,
									CITIExtText02,
									CITIExtText03,
									CITIExtInt01,
									CITIExtInt02,
									CITIExtInt03,
									CITIExtReal01,
									CITIExtReal02,
									CITIExtReal03,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID
							FROM
									OPENXML(@idoc , @DeleteTableName , 2)
							        WITH  (
											 OldCommInspTypeCode VARCHAR(50),
											 CommInspTypeCode VARCHAR(50),
											 CompanyCode VARCHAR(20),
											 WorkCenterCode VARCHAR(20),
											 CommInspTypeName NVARCHAR(100),
											 CommInspTypeDesc NVARCHAR(MAX),
											 IsRouteKey BIT,
											 IsFacilityRouteKey BIT,
											 IsMachineKey BIT,
											 IsMoldKey BIT,
											 IsMaterialKey BIT,
											 IsDocKey BIT,
											 IsShiftKey BIT,
											 IsTimeCodeKey BIT,
											 IsCategoryKey BIT,
											 IsProdKey BIT,
											 [FileName] NVARCHAR(255),
											 FileSize BIGINT,
											 FileData VARCHAR(MAX),
											 ImageFileID BIGINT,
											 IsAutoFinish BIT,
											 CITIExtText01 VARCHAR(200),
											 CITIExtText02 VARCHAR(200),
											 CITIExtText03 VARCHAR(200),
											 CITIExtInt01 BIGINT,
											 CITIExtInt02 BIGINT,
											 CITIExtInt03 BIGINT,
											 CITIExtReal01 NUMERIC(20,5),
											 CITIExtReal02 NUMERIC(20,5),
											 CITIExtReal03 NUMERIC(20,5),
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											) 


            OPEN SourceData

            WHILE 1 = 1 BEGIN
                FETCH NEXT FROM SourceData INTO
								 @IUD_FLAG,
								 @OldCommInspTypeCode,
								 @CommInspTypeCode,
								 @CompanyCode,
								 @WorkCenterCode,
								 @CommInspTypeName,
								 @CommInspTypeDesc,
								 @IsRouteKey,
								 @IsFacilityRouteKey,
								 @IsMachineKey,
								 @IsMoldKey,
								 @IsMaterialKey,
								 @IsDocKey,
								 @IsShiftKey,
								 @IsTimeCodeKey,
								 @IsCategoryKey,
								 @IsProdKey,
								 @FileName,
								 @FileSize,
								 @FileData,
								 @ImageFileID,
								 @IsAutoFinish,
								 @CITIExtText01,
								 @CITIExtText02,
								 @CITIExtText03,
								 @CITIExtInt01,
								 @CITIExtInt02,
								 @CITIExtInt03,
								 @CITIExtReal01,
								 @CITIExtReal02,
								 @CITIExtReal03,
								 @CreateDateTime,
								 @CreateUserID,
								 @ChangeDateTime,
								 @ChangeUserID


                IF @@FETCH_STATUS <> 0 BEGIN
					BREAK
				END
                IF @IUD_FLAG = 'INSERT' BEGIN

                    IF EXISTS (SELECT 1 FROM STB_CommInspTypeInfo WHERE CommInspTypeCode = @CommInspTypeCode) BEGIN
						RAISERROR('Duplicate Data : KeyField = %s', 16, 1, @CommInspTypeCode)
					END
					
					SET @OldCommInspTypeCode = @CommInspTypeCode
					
					

                    IF @IsAutoKey = 1 BEGIN
						EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_CommInspTypeInfo', @CommInspTypeCode OUTPUT
                    END
                    
                   
                    
                    INSERT INTO #SEQUENCE_TABLE
					(
						KeyValue, 
						UID_KEY
					)
					VALUES
					(
						@CommInspTypeCode,
						@OldCommInspTypeCode
					)
					
					
					EXEC SmartFramework.dbo.usp_DoSaveFile 
						@pSystemName = 'STB_CommInspTypeInfo',
						@pFileContents = @FileData,
						@pFileName = @FileName,
						@pFileSize = @FileSize,
						@pUserID = @ProcessUserID,
						@pFileID = @ImageFileID OUTPUT
					

                    INSERT INTO STB_CommInspTypeInfo
						(
						    CommInspTypeCode,
						    CompanyCode,
						    WorkCenterCode,
						    CommInspTypeName,
						    CommInspTypeDesc,
						    IsRouteKey,
						    IsFacilityRouteKey,
						    IsMachineKey,
						    IsMoldKey,
						    IsMaterialKey,
						    IsDocKey,
						    IsShiftKey,
						    IsTimeCodeKey,
						    IsCategoryKey,
						    IsProdKey,
						    ImageFileID,
						    IsAutoFinish,
						    CITIExtText01,
							CITIExtText02,
							CITIExtText03,
							CITIExtInt01,
							CITIExtInt02,
							CITIExtInt03,
							CITIExtReal01,
							CITIExtReal02,
							CITIExtReal03,
						    CreateDateTime,
						    CreateUserID,
						    ChangeDateTime,
						    ChangeUserID
						)
						VALUES
						(
						    @CommInspTypeCode,
						    @CompanyCode,
						    @WorkCenterCode,
						    @CommInspTypeName,
						    @CommInspTypeDesc,
						    ISNULL(@IsRouteKey,0),
						    ISNULL(@IsFacilityRouteKey,0),
						    ISNULL(@IsMachineKey,0),
						    ISNULL(@IsMoldKey,0),
						    ISNULL(@IsMaterialKey,0),
						    ISNULL(@IsDocKey,0),
						    ISNULL(@IsShiftKey,0),
						    ISNULL(@IsTimeCodeKey,0),
						    ISNULL(@IsCategoryKey,0),
						    ISNULL(@IsProdKey,0),
						    @ImageFileID,
						    ISNULL(@IsAutoFinish,0),
						    @CITIExtText01,
							@CITIExtText02,
							@CITIExtText03,
							@CITIExtInt01,
							@CITIExtInt02,
							@CITIExtInt03,
							@CITIExtReal01,
							@CITIExtReal02,
							@CITIExtReal03,
						    GETDATE(),
						    @pProcessUserID,
						    @ChangeDateTime,
						    @ChangeUserID
						)

				END ELSE IF @IUD_FLAG = 'UPDATE' BEGIN
					
					EXEC SmartFramework.dbo.usp_DoSaveFile 
						@pSystemName = 'STB_CommInspTypeInfo',
						@pFileContents = @FileData,
						@pFileName = @FileName,
						@pFileSize = @FileSize,
						@pUserID = @ProcessUserID,
						@pFileID = @ImageFileID OUTPUT
					
                    UPDATE STB_CommInspTypeInfo
						SET
						    CommInspTypeCode =   CASE
						                WHEN @CommInspTypeCode IS NOT NULL THEN @CommInspTypeCode
						                ELSE CommInspTypeCode
						            END,
						    CompanyCode =   CASE
						                WHEN @CompanyCode IS NOT NULL THEN @CompanyCode
						                ELSE CompanyCode
						            END,
						    WorkCenterCode =   CASE
						                WHEN @WorkCenterCode IS NOT NULL THEN @WorkCenterCode
						                ELSE WorkCenterCode
						            END,
						    CommInspTypeName =   CASE
						                WHEN @CommInspTypeName IS NOT NULL THEN @CommInspTypeName
						                ELSE CommInspTypeName
						            END,
						    CommInspTypeDesc =   CASE
						                WHEN @CommInspTypeDesc IS NOT NULL THEN @CommInspTypeDesc
						                ELSE CommInspTypeDesc
						            END,
						    IsRouteKey =   CASE
						                WHEN @IsRouteKey IS NOT NULL THEN @IsRouteKey
						                ELSE IsRouteKey
						            END,
						    IsFacilityRouteKey = CASE
										WHEN @IsFacilityRouteKey IS NOT NULL THEN @IsFacilityRouteKey
										ELSE IsFacilityRouteKey
									END,
						    IsMachineKey =   CASE
						                WHEN @IsMachineKey IS NOT NULL THEN @IsMachineKey
						                ELSE IsMachineKey
						            END,
						    IsMoldKey =   CASE
						                WHEN @IsMoldKey IS NOT NULL THEN @IsMoldKey
						                ELSE IsMoldKey
						            END,
						    IsMaterialKey =   CASE
						                WHEN @IsMaterialKey IS NOT NULL THEN @IsMaterialKey
						                ELSE IsMaterialKey
						            END,
						    IsDocKey =   CASE
						                WHEN @IsDocKey IS NOT NULL THEN @IsDocKey
						                ELSE IsDocKey
						            END,
						    IsShiftKey =   CASE
						                WHEN @IsShiftKey IS NOT NULL THEN @IsShiftKey
						                ELSE IsShiftKey
						            END,
						    IsTimeCodeKey =   CASE
						                WHEN @IsTimeCodeKey IS NOT NULL THEN @IsTimeCodeKey
						                ELSE IsTimeCodeKey
						            END,
						    IsCategoryKey =   CASE
						                WHEN @IsCategoryKey IS NOT NULL THEN @IsCategoryKey
						                ELSE IsCategoryKey
						            END,
						    IsProdKey = CASE 
									WHEN @IsProdKey IS NOT NULL THEN @IsProdKey
									ELSE IsProdKey
								END,
						    ImageFileID =   CASE
						                WHEN @ImageFileID IS NOT NULL THEN @ImageFileID
						                ELSE ImageFileID
						            END,
						    IsAutoFinish = CASE
										WHEN @IsAutoFinish IS NOT NULL THEN @IsAutoFinish
										ELSE IsAutoFinish
									END,
						    CITIExtText01 = CASE 
										WHEN @CITIExtText01 IS NOT NULL THEN @CITIExtText01
										ELSE CITIExtText01
									END,
							CITIExtText02 = CASE 
										WHEN @CITIExtText02 IS NOT NULL THEN @CITIExtText02
										ELSE CITIExtText02
									END,
							CITIExtText03 = CASE 
										WHEN @CITIExtText03 IS NOT NULL THEN @CITIExtText03
										ELSE CITIExtText03
									END,
							CITIExtInt01 = CASE 
										WHEN @CITIExtInt01 IS NOT NULL THEN @CITIExtInt01
										ELSE CITIExtInt01
									END,
							CITIExtInt02 = CASE 
										WHEN @CITIExtInt02 IS NOT NULL THEN @CITIExtInt02
										ELSE CITIExtInt02
									END,
							CITIExtInt03 = CASE 
										WHEN @CITIExtInt03 IS NOT NULL THEN @CITIExtInt03
										ELSE CITIExtInt03
									END,
							CITIExtReal01 = CASE
										WHEN @CITIExtReal01 IS NOT NULL THEN @CITIExtReal01
										ELSE CITIExtReal01
									END,
							CITIExtReal02 = CASE
										WHEN @CITIExtReal02 IS NOT NULL THEN @CITIExtReal02
										ELSE CITIExtReal02
									END,
							CITIExtReal03 = CASE
										WHEN @CITIExtReal03 IS NOT NULL THEN @CITIExtReal03
										ELSE CITIExtReal03
									END,
						    CreateDateTime =   CASE
						                WHEN @CreateDateTime IS NOT NULL THEN @CreateDateTime
						                ELSE CreateDateTime
						            END,
						    CreateUserID =   CASE
						                WHEN @CreateUserID IS NOT NULL THEN @CreateUserID
						                ELSE CreateUserID
						            END,
						    ChangeDateTime = GETDATE(),
						    ChangeUserID = @pProcessUserID
						WHERE
						    CommInspTypeCode = @OldCommInspTypeCode
						-- 공용검사유형코드를 변경시 항목들의 유형항목코드도 같이 변경해준다
						UPDATE	STB_CommInspItem
						SET
								CommInspTypeCode = @CommInspTypeCode
						WHERE
								CommInspTypeCode = @OldCommInspTypeCode

                END ELSE IF @IUD_FLAG = 'DELETE' BEGIN
					
					DELETE FROM STB_CommInspItem
					WHERE
							CommInspTypeCode = @CommInspTypeCode
					
                    DELETE FROM STB_CommInspTypeInfo
						WHERE
						    CommInspTypeCode = @CommInspTypeCode
                END
            END
        END TRY
		BEGIN CATCH
			SET @ERROR_MSG = ERROR_MESSAGE()
			RAISERROR( @ERROR_MSG ,16, 1)
		END CATCH
			
		CLOSE SourceData;
		DEALLOCATE SourceData;
			
		EXEC sp_xml_removedocument @idoc	
    END
END


