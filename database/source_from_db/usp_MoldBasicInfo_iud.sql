-- =============================================
-- Author: Park Jong Hoon(jhpark@awoo.co.kr)
-- Create date: 2016-02-02
-- Browsable : true
-- Group : 금형관리
-- Description:	금형마스터정보 IUD
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_MoldBasicInfo_iud]
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
  DECLARE @OldMoldNumber VARCHAR(20)
  DECLARE @MoldNumber VARCHAR(20)
  DECLARE @CompanyCode VARCHAR(20)
  DECLARE @WorkCenterCode VARCHAR(20)
  DECLARE @MoldTypeCode VARCHAR(20)
  
  DECLARE @MoldTypeName NVARCHAR(100)
  
  DECLARE @MoldCategory1 VARCHAR(100)
  DECLARE @MoldCategory2 VARCHAR(100)
  DECLARE @MoldCategory3 VARCHAR(100)
  DECLARE @MoldCategory4 VARCHAR(100)
  DECLARE @RawMaterial VARCHAR(50)
  DECLARE @MakeDate DATE
  DECLARE @MakeVendor VARCHAR(50)
  DECLARE @CurrentPosition VARCHAR(20)
  DECLARE @MoldGrade VARCHAR(1)
  DECLARE @GuaranteeQty BIGINT
  DECLARE @AccumulateQty BIGINT
  DECLARE @CurrentQty BIGINT
  DECLARE @AlarmStatus INT
  DECLARE @MBIExtText01 VARCHAR(MAX)
  DECLARE @MBIExtText02 VARCHAR(MAX)
  DECLARE @MBIExtText03 VARCHAR(MAX)
  DECLARE @MBIExtText04 VARCHAR(MAX)
  DECLARE @MBIExtText05 VARCHAR(MAX)
  DECLARE @MBIExtImage01 VARBINARY(MAX)
  DECLARE @MBIExtImage02 VARBINARY(MAX)
  DECLARE @MBIExtImage03 VARBINARY(MAX)
  DECLARE @MBIExtImage04 VARBINARY(MAX)
  DECLARE @MBIExtImage05 VARBINARY(MAX)
  DECLARE @MoldLocationCode VARCHAR(20)
  DECLARE @RFTagID VARCHAR(30)
  DECLARE @CheckTerm1 INT
  DECLARE @CheckTerm2 INT
  DECLARE @CheckTerm3 INT
  DECLARE @MoldGradeTypeCode VARCHAR(20)
  DECLARE @CheckSheetType1 VARCHAR(20)
  DECLARE @CheckSheetType2 VARCHAR(20)
  DECLARE @CheckSheetType3 VARCHAR(20)
  DECLARE @CheckSheetType4 VARCHAR(20)
  DECLARE @CreateDateTime DATETIME
  DECLARE @CreateUserID VARCHAR(20)
  DECLARE @ChangeDateTime DATETIME
  DECLARE @ChangeUserID VARCHAR(20)


	DECLARE @iDoc INT

    EXEC SmartFramework.dbo.usp_GetSerialRule 
			@pTableName = 'STB_MoldBasicInfo',
			@pIsAutoKey = @IsAutoKey OUTPUT,
			@pIsLoopIUD = @IsLoopIUD OUTPUT,
			@pPrefixData = @PrefixString OUTPUT,
			@pSerialLen = @SerialLen OUTPUT
    
    IF @IsAutoKey = 0 AND @IsLoopIUD = 0 BEGIN
   
	    EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
	
	    BEGIN TRY
			-- Process Insert Table
            MERGE STB_MoldBasicInfo AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN XMLData.OldMoldNumber IS NULL THEN XMLData.MoldNumber
							    ELSE XMLData.OldMoldNumber
							END AS OldMoldNumber,
							XMLData.MoldNumber,
							XMLData.CompanyCode,
							XMLData.WorkCenterCode,
							XMLData.MoldTypeCode,
							
							XMLData.MOldTypeName,
							
							XMLData.MoldCategory1,
							XMLData.MoldCategory2,
							XMLData.MoldCategory3,
							XMLData.MoldCategory4,
							XMLData.RawMaterial,
							XMLData.MakeDate,
							XMLData.MakeVendor,
							XMLData.CurrentPosition,
							XMLData.MoldGrade,
							XMLData.GuaranteeQty,
							XMLData.AccumulateQty,
							XMLData.CurrentQty,
							XMLData.AlarmStatus,
							XMLData.MBIExtText01,
							XMLData.MBIExtText02,
							XMLData.MBIExtText03,
							XMLData.MBIExtText04,
							XMLData.MBIExtText05,
							dbo.fnBase64ToBinary(XMLData.MBIExtImage01) as MBIExtImage01,
							dbo.fnBase64ToBinary(XMLData.MBIExtImage02) as MBIExtImage02,
							dbo.fnBase64ToBinary(XMLData.MBIExtImage03) as MBIExtImage03,
							dbo.fnBase64ToBinary(XMLData.MBIExtImage04) as MBIExtImage04,
							dbo.fnBase64ToBinary(XMLData.MBIExtImage05) as MBIExtImage05,
							XMLData.MoldLocationCode,
							XMLData.RFTagID,
							XMLData.CheckTerm1,
							XMLData.CheckTerm2,
							XMLData.CheckTerm3,
							XMLData.MoldGradeTypeCode,
							XMLData.CheckSheetType1,
							XMLData.CheckSheetType2,
							XMLData.CheckSheetType3,
							XMLData.CheckSheetType4,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @InsertTableName , 2)
							WITH  (
										OldMoldNumber VARCHAR(20),
										MoldNumber VARCHAR(20),
										CompanyCode VARCHAR(20),
										WorkCenterCode VARCHAR(20),
										MoldTypeCode VARCHAR(20),
										
										MoldTypeName NVARCHAR(100),
										
										MoldCategory1 VARCHAR(100),
										MoldCategory2 VARCHAR(100),
										MoldCategory3 VARCHAR(100),
										MoldCategory4 VARCHAR(100),
										RawMaterial VARCHAR(50),
										MakeDate  DATETIMEOFFSET,
										MakeVendor VARCHAR(50),
										CurrentPosition VARCHAR(20),
										MoldGrade VARCHAR(1),
										GuaranteeQty BIGINT,
										AccumulateQty BIGINT,
										CurrentQty BIGINT,
										AlarmStatus INT,
										MBIExtText01 VARCHAR(MAX),
										MBIExtText02 VARCHAR(MAX),
										MBIExtText03 VARCHAR(MAX),
										MBIExtText04 VARCHAR(MAX),
										MBIExtText05 VARCHAR(MAX),
										MBIExtImage01 NVARCHAR(MAX),
										MBIExtImage02 NVARCHAR(MAX),
										MBIExtImage03 NVARCHAR(MAX),
										MBIExtImage04 NVARCHAR(MAX),
										MBIExtImage05 NVARCHAR(MAX),
										MoldLocationCode VARCHAR(20),
										RFTagID VARCHAR(30),
										CheckTerm1 INT,
										CheckTerm2 INT,
										CheckTerm3 INT,
										MoldGradeTypeCode VARCHAR(20),
										CheckSheetType1 VARCHAR(20),
										CheckSheetType2 VARCHAR(20),
										CheckSheetType3 VARCHAR(20),
										CheckSheetType4 VARCHAR(20),
										CreateDateTime  DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime  DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) XMLData
				) AS SourceTable
			ON
				(
					TargetTable.MoldNumber = SourceTable.MoldNumber
				)

			WHEN MATCHED THEN
				UPDATE SET
					MoldNumber = SourceTable.MoldNumber,
					CompanyCode = SourceTable.CompanyCode,
					WorkCenterCode = SourceTable.WorkCenterCode,
					MoldTypeCode = SourceTable.MoldTypeCode,
					MoldCategory1 = SourceTable.MoldCategory1,
					MoldCategory2 = SourceTable.MoldCategory2,
					MoldCategory3 = SourceTable.MoldCategory3,
					MoldCategory4 = SourceTable.MoldCategory4,
					RawMaterial = SourceTable.RawMaterial,
					MakeDate = SourceTable.MakeDate,
					MakeVendor = SourceTable.MakeVendor,
					CurrentPosition = SourceTable.CurrentPosition,
					MoldGrade = SourceTable.MoldGrade,
					GuaranteeQty = SourceTable.GuaranteeQty,
					AccumulateQty = SourceTable.AccumulateQty,
					CurrentQty = SourceTable.CurrentQty,
					AlarmStatus = SourceTable.AlarmStatus,
					MBIExtText01 = SourceTable.MBIExtText01,
					MBIExtText02 = SourceTable.MBIExtText02,
					MBIExtText03 = SourceTable.MBIExtText03,
					MBIExtText04 = SourceTable.MBIExtText04,
					MBIExtText05 = SourceTable.MBIExtText05,
					MBIExtImage01 = SourceTable.MBIExtImage01,
					MBIExtImage02 = SourceTable.MBIExtImage02,
					MBIExtImage03 = SourceTable.MBIExtImage03,
					MBIExtImage04 = SourceTable.MBIExtImage04,
					MBIExtImage05 = SourceTable.MBIExtImage05,
					MoldLocationCode = SourceTable.MoldLocationCode,
					RFTagID = SourceTable.RFTagID,
					CheckTerm1 = SourceTable.CheckTerm1,
					CheckTerm2 = SourceTable.CheckTerm2,
					CheckTerm3 = SourceTable.CheckTerm3,
					MoldGradeTypeCode = SourceTable.MoldGradeTypeCode,
					CheckSheetType1 = SourceTable.CheckSheetType1,
					CheckSheetType2 = SourceTable.CheckSheetType2,
					CheckSheetType3 = SourceTable.CheckSheetType3,
					CheckSheetType4 = SourceTable.CheckSheetType4,
					ChangeDateTime = SourceTable.ChangeDateTime,
					ChangeUserID = SourceTable.ChangeUserID
			WHEN NOT MATCHED THEN
				INSERT
					(
						MoldNumber,
						CompanyCode,
						WorkCenterCode,
						MoldTypeCode,
						MoldCategory1,
						MoldCategory2,
						MoldCategory3,
						MoldCategory4,
						RawMaterial,
						MakeDate,
						MakeVendor,
						CurrentPosition,
						MoldGrade,
						GuaranteeQty,
						AccumulateQty,
						CurrentQty,
						AlarmStatus,
						MBIExtText01,
						MBIExtText02,
						MBIExtText03,
						MBIExtText04,
						MBIExtText05,
						MBIExtImage01,
						MBIExtImage02,
						MBIExtImage03,
						MBIExtImage04,
						MBIExtImage05,
						MoldLocationCode,
						RFTagID,
						CheckTerm1,
						CheckTerm2,
						CheckTerm3,
						MoldGradeTypeCode,
						CheckSheetType1,
						CheckSheetType2,
						CheckSheetType3,
						CheckSheetType4,
						CreateDateTime,
						CreateUserID
					)
				VALUES
					(
							SourceTable.MoldNumber,
							SourceTable.CompanyCode,
							SourceTable.WorkCenterCode,
							SourceTable.MoldTypeCode,
							SourceTable.MoldCategory1,
							SourceTable.MoldCategory2,
							SourceTable.MoldCategory3,
							SourceTable.MoldCategory4,
							SourceTable.RawMaterial,
							SourceTable.MakeDate,
							SourceTable.MakeVendor,
							SourceTable.CurrentPosition,
							SourceTable.MoldGrade,
							SourceTable.GuaranteeQty,
							SourceTable.AccumulateQty,
							SourceTable.CurrentQty,
							SourceTable.AlarmStatus,
							SourceTable.MBIExtText01,
							SourceTable.MBIExtText02,
							SourceTable.MBIExtText03,
							SourceTable.MBIExtText04,
							SourceTable.MBIExtText05,
							SourceTable.MBIExtImage01,
							SourceTable.MBIExtImage02,
							SourceTable.MBIExtImage03,
							SourceTable.MBIExtImage04,
							SourceTable.MBIExtImage05,
							SourceTable.MoldLocationCode,
							SourceTable.RFTagID,
							SourceTable.CheckTerm1,
							SourceTable.CheckTerm2,
							SourceTable.CheckTerm3,
							SourceTable.MoldGradeTypeCode,
							SourceTable.CheckSheetType1,
							SourceTable.CheckSheetType2,
							SourceTable.CheckSheetType3,
							SourceTable.CheckSheetType4,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID
					);


			-- Process Update Table
            MERGE STB_MoldBasicInfo AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN XMLData.OldMoldNumber IS NULL THEN XMLData.MoldNumber
							    ELSE XMLData.OldMoldNumber
							END AS OldMoldNumber,
							XMLData.MoldNumber,
							XMLData.CompanyCode,
							XMLData.WorkCenterCode,
							XMLData.MoldTypeCode,
							XMLData.MoldCategory1,
							XMLData.MoldCategory2,
							XMLData.MoldCategory3,
							XMLData.MoldCategory4,
							XMLData.RawMaterial,
							XMLData.MakeDate,
							XMLData.MakeVendor,
							XMLData.CurrentPosition,
							XMLData.MoldGrade,
							XMLData.GuaranteeQty,
							XMLData.AccumulateQty,
							XMLData.CurrentQty,
							XMLData.AlarmStatus,
							XMLData.MBIExtText01,
							XMLData.MBIExtText02,
							XMLData.MBIExtText03,
							XMLData.MBIExtText04,
							XMLData.MBIExtText05,
							dbo.fnBase64ToBinary(XMLData.MBIExtImage01) as MBIExtImage01,
							dbo.fnBase64ToBinary(XMLData.MBIExtImage02) as MBIExtImage02,
							dbo.fnBase64ToBinary(XMLData.MBIExtImage03) as MBIExtImage03,
							dbo.fnBase64ToBinary(XMLData.MBIExtImage04) as MBIExtImage04,
							dbo.fnBase64ToBinary(XMLData.MBIExtImage05) as MBIExtImage05,
							XMLData.MoldLocationCode,
							XMLData.RFTagID,
							XMLData.CheckTerm1,
							XMLData.CheckTerm2,
							XMLData.CheckTerm3,
							XMLData.MoldGradeTypeCode,
							XMLData.CheckSheetType1,
							XMLData.CheckSheetType2,
							XMLData.CheckSheetType3,
							XMLData.CheckSheetType4,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @UpdateTableName , 2)
							WITH  (
										OldMoldNumber VARCHAR(20),
										MoldNumber VARCHAR(20),
										CompanyCode VARCHAR(20),
										WorkCenterCode VARCHAR(20),
										MoldTypeCode VARCHAR(20),
										MoldCategory1 VARCHAR(100),
										MoldCategory2 VARCHAR(100),
										MoldCategory3 VARCHAR(100),
										MoldCategory4 VARCHAR(100),
										RawMaterial VARCHAR(50),
										MakeDate  DATETIMEOFFSET,
										MakeVendor VARCHAR(50),
										CurrentPosition VARCHAR(20),
										MoldGrade VARCHAR(1),
										GuaranteeQty BIGINT,
										AccumulateQty BIGINT,
										CurrentQty BIGINT,
										AlarmStatus INT,
										MBIExtText01 VARCHAR(MAX),
										MBIExtText02 VARCHAR(MAX),
										MBIExtText03 VARCHAR(MAX),
										MBIExtText04 VARCHAR(MAX),
										MBIExtText05 VARCHAR(MAX),
										MBIExtImage01 NVARCHAR(MAX),
										MBIExtImage02 NVARCHAR(MAX),
										MBIExtImage03 NVARCHAR(MAX),
										MBIExtImage04 NVARCHAR(MAX),
										MBIExtImage05 NVARCHAR(MAX),
										MoldLocationCode VARCHAR(20),
										RFTagID VARCHAR(30),
										CheckTerm1 INT,
										CheckTerm2 INT,
										CheckTerm3 INT,
										MoldGradeTypeCode VARCHAR(20),
										CheckSheetType1 VARCHAR(20),
										CheckSheetType2 VARCHAR(20),
										CheckSheetType3 VARCHAR(20),
										CheckSheetType4 VARCHAR(20),
										CreateDateTime  DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime  DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) XMLData
				) AS SourceTable
			ON
				(
					TargetTable.MoldNumber = SourceTable.OldMoldNumber
				)

			WHEN MATCHED THEN
				UPDATE SET
					MoldNumber = SourceTable.MoldNumber,
					CompanyCode = SourceTable.CompanyCode,
					WorkCenterCode = SourceTable.WorkCenterCode,
					MoldTypeCode = SourceTable.MoldTypeCode,
					MoldCategory1 = SourceTable.MoldCategory1,
					MoldCategory2 = SourceTable.MoldCategory2,
					MoldCategory3 = SourceTable.MoldCategory3,
					MoldCategory4 = SourceTable.MoldCategory4,
					RawMaterial = SourceTable.RawMaterial,
					MakeDate = SourceTable.MakeDate,
					MakeVendor = SourceTable.MakeVendor,
					CurrentPosition = SourceTable.CurrentPosition,
					MoldGrade = SourceTable.MoldGrade,
					GuaranteeQty = SourceTable.GuaranteeQty,
					AccumulateQty = SourceTable.AccumulateQty,
					CurrentQty = SourceTable.CurrentQty,
					AlarmStatus = SourceTable.AlarmStatus,
					MBIExtText01 = SourceTable.MBIExtText01,
					MBIExtText02 = SourceTable.MBIExtText02,
					MBIExtText03 = SourceTable.MBIExtText03,
					MBIExtText04 = SourceTable.MBIExtText04,
					MBIExtText05 = SourceTable.MBIExtText05,
					MBIExtImage01 = SourceTable.MBIExtImage01,
					MBIExtImage02 = SourceTable.MBIExtImage02,
					MBIExtImage03 = SourceTable.MBIExtImage03,
					MBIExtImage04 = SourceTable.MBIExtImage04,
					MBIExtImage05 = SourceTable.MBIExtImage05,
					MoldLocationCode = SourceTable.MoldLocationCode,
					RFTagID = SourceTable.RFTagID,
					CheckTerm1 = SourceTable.CheckTerm1,
					CheckTerm2 = SourceTable.CheckTerm2,
					CheckTerm3 = SourceTable.CheckTerm3,
					MoldGradeTypeCode = SourceTable.MoldGradeTypeCode,
					CheckSheetType1 = SourceTable.CheckSheetType1,
					CheckSheetType2 = SourceTable.CheckSheetType2,
					CheckSheetType3 = SourceTable.CheckSheetType3,
					CheckSheetType4 = SourceTable.CheckSheetType4,
					ChangeDateTime = SourceTable.ChangeDateTime,
					ChangeUserID = SourceTable.ChangeUserID
			WHEN NOT MATCHED THEN
				INSERT
					(
						MoldNumber,
						CompanyCode,
						WorkCenterCode,
						MoldTypeCode,
						MoldCategory1,
						MoldCategory2,
						MoldCategory3,
						MoldCategory4,
						RawMaterial,
						MakeDate,
						MakeVendor,
						CurrentPosition,
						MoldGrade,
						GuaranteeQty,
						AccumulateQty,
						CurrentQty,
						AlarmStatus,
						MBIExtText01,
						MBIExtText02,
						MBIExtText03,
						MBIExtText04,
						MBIExtText05,
						MBIExtImage01,
						MBIExtImage02,
						MBIExtImage03,
						MBIExtImage04,
						MBIExtImage05,
						MoldLocationCode,
						RFTagID,
						CheckTerm1,
						CheckTerm2,
						CheckTerm3,
						MoldGradeTypeCode,
						CheckSheetType1,
						CheckSheetType2,
						CheckSheetType3,
						CheckSheetType4,
						CreateDateTime,
						CreateUserID
					)
				VALUES
					(
							SourceTable.MoldNumber,
							SourceTable.CompanyCode,
							SourceTable.WorkCenterCode,
							SourceTable.MoldTypeCode,
							SourceTable.MoldCategory1,
							SourceTable.MoldCategory2,
							SourceTable.MoldCategory3,
							SourceTable.MoldCategory4,
							SourceTable.RawMaterial,
							SourceTable.MakeDate,
							SourceTable.MakeVendor,
							SourceTable.CurrentPosition,
							SourceTable.MoldGrade,
							SourceTable.GuaranteeQty,
							SourceTable.AccumulateQty,
							SourceTable.CurrentQty,
							SourceTable.AlarmStatus,
							SourceTable.MBIExtText01,
							SourceTable.MBIExtText02,
							SourceTable.MBIExtText03,
							SourceTable.MBIExtText04,
							SourceTable.MBIExtText05,
							SourceTable.MBIExtImage01,
							SourceTable.MBIExtImage02,
							SourceTable.MBIExtImage03,
							SourceTable.MBIExtImage04,
							SourceTable.MBIExtImage05,
							SourceTable.MoldLocationCode,
							SourceTable.RFTagID,
							SourceTable.CheckTerm1,
							SourceTable.CheckTerm2,
							SourceTable.CheckTerm3,
							SourceTable.MoldGradeTypeCode,
							SourceTable.CheckSheetType1,
							SourceTable.CheckSheetType2,
							SourceTable.CheckSheetType3,
							SourceTable.CheckSheetType4,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID
					);


			-- Process Delete Table
            MERGE STB_MoldBasicInfo AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN XMLData.OldMoldNumber IS NULL THEN XMLData.MoldNumber
							    ELSE XMLData.OldMoldNumber
							END AS OldMoldNumber,
							XMLData.MoldNumber,
							XMLData.CompanyCode,
							XMLData.WorkCenterCode,
							XMLData.MoldTypeCode,
							XMLData.MoldCategory1,
							XMLData.MoldCategory2,
							XMLData.MoldCategory3,
							XMLData.MoldCategory4,
							XMLData.RawMaterial,
							XMLData.MakeDate,
							XMLData.MakeVendor,
							XMLData.CurrentPosition,
							XMLData.MoldGrade,
							XMLData.GuaranteeQty,
							XMLData.AccumulateQty,
							XMLData.CurrentQty,
							XMLData.AlarmStatus,
							XMLData.MBIExtText01,
							XMLData.MBIExtText02,
							XMLData.MBIExtText03,
							XMLData.MBIExtText04,
							XMLData.MBIExtText05,
							dbo.fnBase64ToBinary(XMLData.MBIExtImage01) as MBIExtImage01,
							dbo.fnBase64ToBinary(XMLData.MBIExtImage02) as MBIExtImage02,
							dbo.fnBase64ToBinary(XMLData.MBIExtImage03) as MBIExtImage03,
							dbo.fnBase64ToBinary(XMLData.MBIExtImage04) as MBIExtImage04,
							dbo.fnBase64ToBinary(XMLData.MBIExtImage05) as MBIExtImage05,
							XMLData.MoldLocationCode,
							XMLData.RFTagID,
							XMLData.CheckTerm1,
							XMLData.CheckTerm2,
							XMLData.CheckTerm3,
							XMLData.MoldGradeTypeCode,
							XMLData.CheckSheetType1,
							XMLData.CheckSheetType2,
							XMLData.CheckSheetType3,
							XMLData.CheckSheetType4,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @DeleteTableName , 2)
							WITH  (
										OldMoldNumber VARCHAR(20),
										MoldNumber VARCHAR(20),
										CompanyCode VARCHAR(20),
										WorkCenterCode VARCHAR(20),
										MoldTypeCode VARCHAR(20),
										MoldCategory1 VARCHAR(100),
										MoldCategory2 VARCHAR(100),
										MoldCategory3 VARCHAR(100),
										MoldCategory4 VARCHAR(100),
										RawMaterial VARCHAR(50),
										MakeDate  DATETIMEOFFSET,
										MakeVendor VARCHAR(50),
										CurrentPosition VARCHAR(20),
										MoldGrade VARCHAR(1),
										GuaranteeQty BIGINT,
										AccumulateQty BIGINT,
										CurrentQty BIGINT,
										AlarmStatus INT,
										MBIExtText01 VARCHAR(MAX),
										MBIExtText02 VARCHAR(MAX),
										MBIExtText03 VARCHAR(MAX),
										MBIExtText04 VARCHAR(MAX),
										MBIExtText05 VARCHAR(MAX),
										MBIExtImage01 NVARCHAR(MAX),
										MBIExtImage02 NVARCHAR(MAX),
										MBIExtImage03 NVARCHAR(MAX),
										MBIExtImage04 NVARCHAR(MAX),
										MBIExtImage05 NVARCHAR(MAX),
										MoldLocationCode VARCHAR(20),
										RFTagID VARCHAR(30),
										CheckTerm1 INT,
										CheckTerm2 INT,
										CheckTerm3 INT,
										MoldGradeTypeCode VARCHAR(20),
										CheckSheetType1 VARCHAR(20),
										CheckSheetType2 VARCHAR(20),
										CheckSheetType3 VARCHAR(20),
										CheckSheetType4 VARCHAR(20),
										CreateDateTime  DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime  DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) XMLData
				) AS SourceTable
			ON
				(
					TargetTable.MoldNumber = SourceTable.MoldNumber
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
									XMLData.OldMoldNumber,
									XMLData.MoldNumber,
									XMLData.CompanyCode,
									XMLData.WorkCenterCode,
									XMLData.MoldTypeCode,
									XMLData.MoldCategory1,
									XMLData.MoldCategory2,
									XMLData.MoldCategory3,
									XMLData.MoldCategory4,
									XMLData.RawMaterial,
									XMLData.MakeDate,
									XMLData.MakeVendor,
									XMLData.CurrentPosition,
									XMLData.MoldGrade,
									XMLData.GuaranteeQty,
									XMLData.AccumulateQty,
									XMLData.CurrentQty,
									XMLData.AlarmStatus,
									XMLData.MBIExtText01,
									XMLData.MBIExtText02,
									XMLData.MBIExtText03,
									XMLData.MBIExtText04,
									XMLData.MBIExtText05,
									dbo.fnBase64ToBinary(XMLData.MBIExtImage01) as MBIExtImage01,
									dbo.fnBase64ToBinary(XMLData.MBIExtImage02) as MBIExtImage02,
									dbo.fnBase64ToBinary(XMLData.MBIExtImage03) as MBIExtImage03,
									dbo.fnBase64ToBinary(XMLData.MBIExtImage04) as MBIExtImage04,
									dbo.fnBase64ToBinary(XMLData.MBIExtImage05) as MBIExtImage05,
									XMLData.MoldLocationCode,
									XMLData.RFTagID,
									XMLData.CheckTerm1,
									XMLData.CheckTerm2,
									XMLData.CheckTerm3,
									XMLData.MoldGradeTypeCode,
									XMLData.CheckSheetType1,
									XMLData.CheckSheetType2,
									XMLData.CheckSheetType3,
									XMLData.CheckSheetType4,
									XMLData.CreateDateTime,
									XMLData.CreateUserID,
									XMLData.ChangeDateTime,
									XMLData.ChangeUserID
							FROM
									OPENXML(@idoc , @InsertTableName , 2)
							        WITH  (
											 OldMoldNumber VARCHAR(20),
											 MoldNumber VARCHAR(20),
											 CompanyCode VARCHAR(20),
											 WorkCenterCode VARCHAR(20),
											 MoldTypeCode VARCHAR(20),
											 MoldCategory1 VARCHAR(100),
											 MoldCategory2 VARCHAR(100),
											 MoldCategory3 VARCHAR(100),
											 MoldCategory4 VARCHAR(100),
											 RawMaterial VARCHAR(50),
											 MakeDate  DATETIMEOFFSET,
											 MakeVendor VARCHAR(50),
											 CurrentPosition VARCHAR(20),
											 MoldGrade VARCHAR(1),
											 GuaranteeQty BIGINT,
											 AccumulateQty BIGINT,
											 CurrentQty BIGINT,
											 AlarmStatus INT,
											 MBIExtText01 VARCHAR(MAX),
											 MBIExtText02 VARCHAR(MAX),
											 MBIExtText03 VARCHAR(MAX),
											 MBIExtText04 VARCHAR(MAX),
											 MBIExtText05 VARCHAR(MAX),
											 MBIExtImage01 NVARCHAR(MAX),
											 MBIExtImage02 NVARCHAR(MAX),
											 MBIExtImage03 NVARCHAR(MAX),
											 MBIExtImage04 NVARCHAR(MAX),
											 MBIExtImage05 NVARCHAR(MAX),
											 MoldLocationCode VARCHAR(20),
											 RFTagID VARCHAR(30),
											 CheckTerm1 INT,
											 CheckTerm2 INT,
											 CheckTerm3 INT,
											 MoldGradeTypeCode VARCHAR(20),
											 CheckSheetType1 VARCHAR(20),
											 CheckSheetType2 VARCHAR(20),
											 CheckSheetType3 VARCHAR(20),
											 CheckSheetType4 VARCHAR(20),
											 CreateDateTime  DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime  DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											) XMLData
							UNION ALL
							SELECT
									'UPDATE' AS IUD_FLAG,
									CASE 
										WHEN XMLData.OldMoldNumber IS NULL THEN XMLData.MoldNumber
										ELSE XMLData.OldMoldNumber
									END AS OldMoldNumber,
									XMLData.MoldNumber,
									XMLData.CompanyCode,
									XMLData.WorkCenterCode,
									XMLData.MoldTypeCode,
									XMLData.MoldCategory1,
									XMLData.MoldCategory2,
									XMLData.MoldCategory3,
									XMLData.MoldCategory4,
									XMLData.RawMaterial,
									XMLData.MakeDate,
									XMLData.MakeVendor,
									XMLData.CurrentPosition,
									XMLData.MoldGrade,
									XMLData.GuaranteeQty,
									XMLData.AccumulateQty,
									XMLData.CurrentQty,
									XMLData.AlarmStatus,
									XMLData.MBIExtText01,
									XMLData.MBIExtText02,
									XMLData.MBIExtText03,
									XMLData.MBIExtText04,
									XMLData.MBIExtText05,
									dbo.fnBase64ToBinary(XMLData.MBIExtImage01) as MBIExtImage01,
									dbo.fnBase64ToBinary(XMLData.MBIExtImage02) as MBIExtImage02,
									dbo.fnBase64ToBinary(XMLData.MBIExtImage03) as MBIExtImage03,
									dbo.fnBase64ToBinary(XMLData.MBIExtImage04) as MBIExtImage04,
									dbo.fnBase64ToBinary(XMLData.MBIExtImage05) as MBIExtImage05,
									XMLData.MoldLocationCode,
									XMLData.RFTagID,
									XMLData.CheckTerm1,
									XMLData.CheckTerm2,
									XMLData.CheckTerm3,
									XMLData.MoldGradeTypeCode,
									XMLData.CheckSheetType1,
									XMLData.CheckSheetType2,
									XMLData.CheckSheetType3,
									XMLData.CheckSheetType4,
									XMLData.CreateDateTime,
									XMLData.CreateUserID,
									XMLData.ChangeDateTime,
									XMLData.ChangeUserID
							FROM
									OPENXML(@idoc , @UpdateTableName , 2)
							        WITH  (
											 OldMoldNumber VARCHAR(20),
											 MoldNumber VARCHAR(20),
											 CompanyCode VARCHAR(20),
											 WorkCenterCode VARCHAR(20),
											 MoldTypeCode VARCHAR(20),
											 MoldCategory1 VARCHAR(100),
											 MoldCategory2 VARCHAR(100),
											 MoldCategory3 VARCHAR(100),
											 MoldCategory4 VARCHAR(100),
											 RawMaterial VARCHAR(50),
											 MakeDate  DATETIMEOFFSET,
											 MakeVendor VARCHAR(50),
											 CurrentPosition VARCHAR(20),
											 MoldGrade VARCHAR(1),
											 GuaranteeQty BIGINT,
											 AccumulateQty BIGINT,
											 CurrentQty BIGINT,
											 AlarmStatus INT,
											 MBIExtText01 VARCHAR(MAX),
											 MBIExtText02 VARCHAR(MAX),
											 MBIExtText03 VARCHAR(MAX),
											 MBIExtText04 VARCHAR(MAX),
											 MBIExtText05 VARCHAR(MAX),
											 MBIExtImage01 NVARCHAR(MAX),
											 MBIExtImage02 NVARCHAR(MAX),
											 MBIExtImage03 NVARCHAR(MAX),
											 MBIExtImage04 NVARCHAR(MAX),
											 MBIExtImage05 NVARCHAR(MAX),
											 MoldLocationCode VARCHAR(20),
											 RFTagID VARCHAR(30),
											 CheckTerm1 INT,
											 CheckTerm2 INT,
											 CheckTerm3 INT,
											 MoldGradeTypeCode VARCHAR(20),
											 CheckSheetType1 VARCHAR(20),
											 CheckSheetType2 VARCHAR(20),
											 CheckSheetType3 VARCHAR(20),
											 CheckSheetType4 VARCHAR(20),
											 CreateDateTime  DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime  DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											) XMLData
							UNION ALL
							SELECT
									'DELETE' AS IUD_FLAG,
									CASE 
										WHEN XMLData.OldMoldNumber IS NULL THEN XMLData.MoldNumber
										ELSE XMLData.OldMoldNumber
									END AS OldMoldNumber,
									XMLData.MoldNumber,
									XMLData.CompanyCode,
									XMLData.WorkCenterCode,
									XMLData.MoldTypeCode,
									XMLData.MoldCategory1,
									XMLData.MoldCategory2,
									XMLData.MoldCategory3,
									XMLData.MoldCategory4,
									XMLData.RawMaterial,
									XMLData.MakeDate,
									XMLData.MakeVendor,
									XMLData.CurrentPosition,
									XMLData.MoldGrade,
									XMLData.GuaranteeQty,
									XMLData.AccumulateQty,
									XMLData.CurrentQty,
									XMLData.AlarmStatus,
									XMLData.MBIExtText01,
									XMLData.MBIExtText02,
									XMLData.MBIExtText03,
									XMLData.MBIExtText04,
									XMLData.MBIExtText05,
									dbo.fnBase64ToBinary(XMLData.MBIExtImage01) as MBIExtImage01,
									dbo.fnBase64ToBinary(XMLData.MBIExtImage02) as MBIExtImage02,
									dbo.fnBase64ToBinary(XMLData.MBIExtImage03) as MBIExtImage03,
									dbo.fnBase64ToBinary(XMLData.MBIExtImage04) as MBIExtImage04,
									dbo.fnBase64ToBinary(XMLData.MBIExtImage05) as MBIExtImage05,
									XMLData.MoldLocationCode,
									XMLData.RFTagID,
									XMLData.CheckTerm1,
									XMLData.CheckTerm2,
									XMLData.CheckTerm3,
									XMLData.MoldGradeTypeCode,
									XMLData.CheckSheetType1,
									XMLData.CheckSheetType2,
									XMLData.CheckSheetType3,
									XMLData.CheckSheetType4,
									XMLData.CreateDateTime,
									XMLData.CreateUserID,
									XMLData.ChangeDateTime,
									XMLData.ChangeUserID
							FROM
									OPENXML(@idoc , @DeleteTableName , 2)
							        WITH  (
											 OldMoldNumber VARCHAR(20),
											 MoldNumber VARCHAR(20),
											 CompanyCode VARCHAR(20),
											 WorkCenterCode VARCHAR(20),
											 MoldTypeCode VARCHAR(20),
											 MoldCategory1 VARCHAR(100),
											 MoldCategory2 VARCHAR(100),
											 MoldCategory3 VARCHAR(100),
											 MoldCategory4 VARCHAR(100),
											 RawMaterial VARCHAR(50),
											 MakeDate  DATETIMEOFFSET,
											 MakeVendor VARCHAR(50),
											 CurrentPosition VARCHAR(20),
											 MoldGrade VARCHAR(1),
											 GuaranteeQty BIGINT,
											 AccumulateQty BIGINT,
											 CurrentQty BIGINT,
											 AlarmStatus INT,
											 MBIExtText01 VARCHAR(MAX),
											 MBIExtText02 VARCHAR(MAX),
											 MBIExtText03 VARCHAR(MAX),
											 MBIExtText04 VARCHAR(MAX),
											 MBIExtText05 VARCHAR(MAX),
											 MBIExtImage01 NVARCHAR(MAX),
											 MBIExtImage02 NVARCHAR(MAX),
											 MBIExtImage03 NVARCHAR(MAX),
											 MBIExtImage04 NVARCHAR(MAX),
											 MBIExtImage05 NVARCHAR(MAX),
											 MoldLocationCode VARCHAR(20),
											 RFTagID VARCHAR(30),
											 CheckTerm1 INT,
											 CheckTerm2 INT,
											 CheckTerm3 INT,
											 MoldGradeTypeCode VARCHAR(20),
											 CheckSheetType1 VARCHAR(20),
											 CheckSheetType2 VARCHAR(20),
											 CheckSheetType3 VARCHAR(20),
											 CheckSheetType4 VARCHAR(20),
											 CreateDateTime  DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime  DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											) XMLData


            OPEN SourceData

            WHILE 1 = 1 BEGIN
                FETCH NEXT FROM SourceData INTO
								 @IUD_FLAG,
								 @OldMoldNumber,
								 @MoldNumber,
								 @CompanyCode,
								 @WorkCenterCode,
								 @MoldTypeCode,
								 @MoldCategory1,
								 @MoldCategory2,
								 @MoldCategory3,
								 @MoldCategory4,
								 @RawMaterial,
								 @MakeDate,
								 @MakeVendor,
								 @CurrentPosition,
								 @MoldGrade,
								 @GuaranteeQty,
								 @AccumulateQty,
								 @CurrentQty,
								 @AlarmStatus,
								 @MBIExtText01,
								 @MBIExtText02,
								 @MBIExtText03,
								 @MBIExtText04,
								 @MBIExtText05,
								 @MBIExtImage01,
								 @MBIExtImage02,
								 @MBIExtImage03,
								 @MBIExtImage04,
								 @MBIExtImage05,
								 @MoldLocationCode,
								 @RFTagID,
								 @CheckTerm1,
								 @CheckTerm2,
								 @CheckTerm3,
								 @MoldGradeTypeCode,
								 @CheckSheetType1,
								 @CheckSheetType2,
								 @CheckSheetType3,
								 @CheckSheetType4,
								 @CreateDateTime,
								 @CreateUserID,
								 @ChangeDateTime,
								 @ChangeUserID


                IF @@FETCH_STATUS <> 0 BEGIN
					BREAK
				END
                IF @IUD_FLAG = 'INSERT' BEGIN

                    IF EXISTS (SELECT 1 FROM STB_MoldBasicInfo WHERE MoldNumber = @MoldNumber) BEGIN
						RAISERROR('Duplicate Data : KeyField = %s', 16, 1, @MoldNumber)
					END

                    IF @IsAutoKey = 1 BEGIN
						EXEC SmartFramework.dbo.usp_DoCreateSerial	'STB_MoldBasicInfo',
																	@MoldNumber OUTPUT
                    END

                    INSERT INTO STB_MoldBasicInfo
						(
						    MoldNumber,
						    CompanyCode,
						    WorkCenterCode,
						    MoldTypeCode,
						    MoldCategory1,
						    MoldCategory2,
						    MoldCategory3,
						    MoldCategory4,
						    RawMaterial,
						    MakeDate,
						    MakeVendor,
						    CurrentPosition,
						    MoldGrade,
						    GuaranteeQty,
						    AccumulateQty,
						    CurrentQty,
						    AlarmStatus,
						    MBIExtText01,
						    MBIExtText02,
						    MBIExtText03,
						    MBIExtText04,
						    MBIExtText05,
						    MBIExtImage01,
						    MBIExtImage02,
						    MBIExtImage03,
						    MBIExtImage04,
						    MBIExtImage05,
						    MoldLocationCode,
						    RFTagID,
						    CheckTerm1,
						    CheckTerm2,
						    CheckTerm3,
						    MoldGradeTypeCode,
						    CheckSheetType1,
						    CheckSheetType2,
						    CheckSheetType3,
						    CheckSheetType4,
						    CreateDateTime,
						    CreateUserID,
						    ChangeDateTime,
						    ChangeUserID
						)
						VALUES
						(
						    @MoldNumber,
						    @CompanyCode,
						    @WorkCenterCode,
						    @MoldTypeCode,
						    @MoldCategory1,
						    @MoldCategory2,
						    @MoldCategory3,
						    @MoldCategory4,
						    @RawMaterial,
						    @MakeDate,
						    @MakeVendor,
						    @CurrentPosition,
						    @MoldGrade,
						    @GuaranteeQty,
						    @AccumulateQty,
						    @CurrentQty,
						    @AlarmStatus,
						    @MBIExtText01,
						    @MBIExtText02,
						    @MBIExtText03,
						    @MBIExtText04,
						    @MBIExtText05,
						    @MBIExtImage01,
						    @MBIExtImage02,
						    @MBIExtImage03,
						    @MBIExtImage04,
						    @MBIExtImage05,
						    @MoldLocationCode,
						    @RFTagID,
						    @CheckTerm1,
						    @CheckTerm2,
						    @CheckTerm3,
						    @MoldGradeTypeCode,
						    @CheckSheetType1,
						    @CheckSheetType2,
						    @CheckSheetType3,
						    @CheckSheetType4,
						    GETDATE(),
						    @pProcessUserID,
						    @ChangeDateTime,
						    @ChangeUserID
						)

				END ELSE IF @IUD_FLAG = 'UPDATE' BEGIN
                    UPDATE STB_MoldBasicInfo
						SET
						    MoldNumber =   CASE
						                WHEN @MoldNumber IS NOT NULL THEN @MoldNumber
						                ELSE MoldNumber
						            END,
						    CompanyCode =   CASE
						                WHEN @CompanyCode IS NOT NULL THEN @CompanyCode
						                ELSE CompanyCode
						            END,
						    WorkCenterCode =   CASE
						                WHEN @WorkCenterCode IS NOT NULL THEN @WorkCenterCode
						                ELSE WorkCenterCode
						            END,
						    MoldTypeCode =   CASE
						                WHEN @MoldTypeCode IS NOT NULL THEN @MoldTypeCode
						                ELSE MoldTypeCode
						            END,
						    MoldCategory1 =   CASE
						                WHEN @MoldCategory1 IS NOT NULL THEN @MoldCategory1
						                ELSE MoldCategory1
						            END,
						    MoldCategory2 =   CASE
						                WHEN @MoldCategory2 IS NOT NULL THEN @MoldCategory2
						                ELSE MoldCategory2
						            END,
						    MoldCategory3 =   CASE
						                WHEN @MoldCategory3 IS NOT NULL THEN @MoldCategory3
						                ELSE MoldCategory3
						            END,
						    MoldCategory4 =   CASE
						                WHEN @MoldCategory4 IS NOT NULL THEN @MoldCategory4
						                ELSE MoldCategory4
						            END,
						    RawMaterial =   CASE
						                WHEN @RawMaterial IS NOT NULL THEN @RawMaterial
						                ELSE RawMaterial
						            END,
						    MakeDate =   CASE
						                WHEN @MakeDate IS NOT NULL THEN @MakeDate
						                ELSE MakeDate
						            END,
						    MakeVendor =   CASE
						                WHEN @MakeVendor IS NOT NULL THEN @MakeVendor
						                ELSE MakeVendor
						            END,
						    CurrentPosition =   CASE
						                WHEN @CurrentPosition IS NOT NULL THEN @CurrentPosition
						                ELSE CurrentPosition
						            END,
						    MoldGrade =   CASE
						                WHEN @MoldGrade IS NOT NULL THEN @MoldGrade
						                ELSE MoldGrade
						            END,
						    GuaranteeQty =   CASE
						                WHEN @GuaranteeQty IS NOT NULL THEN @GuaranteeQty
						                ELSE GuaranteeQty
						            END,
						    AccumulateQty =   CASE
						                WHEN @AccumulateQty IS NOT NULL THEN @AccumulateQty
						                ELSE AccumulateQty
						            END,
						    CurrentQty =   CASE
						                WHEN @CurrentQty IS NOT NULL THEN @CurrentQty
						                ELSE CurrentQty
						            END,
						    AlarmStatus =   CASE
						                WHEN @AlarmStatus IS NOT NULL THEN @AlarmStatus
						                ELSE AlarmStatus
						            END,
						    MBIExtText01 =   CASE
						                WHEN @MBIExtText01 IS NOT NULL THEN @MBIExtText01
						                ELSE MBIExtText01
						            END,
						    MBIExtText02 =   CASE
						                WHEN @MBIExtText02 IS NOT NULL THEN @MBIExtText02
						                ELSE MBIExtText02
						            END,
						    MBIExtText03 =   CASE
						                WHEN @MBIExtText03 IS NOT NULL THEN @MBIExtText03
						                ELSE MBIExtText03
						            END,
						    MBIExtText04 =   CASE
						                WHEN @MBIExtText04 IS NOT NULL THEN @MBIExtText04
						                ELSE MBIExtText04
						            END,
						    MBIExtText05 =   CASE
						                WHEN @MBIExtText05 IS NOT NULL THEN @MBIExtText05
						                ELSE MBIExtText05
						            END,
						    MBIExtImage01 =   CASE
						                WHEN @MBIExtImage01 IS NOT NULL THEN @MBIExtImage01
						                ELSE MBIExtImage01
						            END,
						    MBIExtImage02 =   CASE
						                WHEN @MBIExtImage02 IS NOT NULL THEN @MBIExtImage02
						                ELSE MBIExtImage02
						            END,
						    MBIExtImage03 =   CASE
						                WHEN @MBIExtImage03 IS NOT NULL THEN @MBIExtImage03
						                ELSE MBIExtImage03
						            END,
						    MBIExtImage04 =   CASE
						                WHEN @MBIExtImage04 IS NOT NULL THEN @MBIExtImage04
						                ELSE MBIExtImage04
						            END,
						    MBIExtImage05 =   CASE
						                WHEN @MBIExtImage05 IS NOT NULL THEN @MBIExtImage05
						                ELSE MBIExtImage05
						            END,
						    MoldLocationCode =   CASE
						                WHEN @MoldLocationCode IS NOT NULL THEN @MoldLocationCode
						                ELSE MoldLocationCode
						            END,
						    RFTagID =   CASE
						                WHEN @RFTagID IS NOT NULL THEN @RFTagID
						                ELSE RFTagID
						            END,
						    CheckTerm1 =   CASE
						                WHEN @CheckTerm1 IS NOT NULL THEN @CheckTerm1
						                ELSE CheckTerm1
						            END,
						    CheckTerm2 =   CASE
						                WHEN @CheckTerm2 IS NOT NULL THEN @CheckTerm2
						                ELSE CheckTerm2
						            END,
						    CheckTerm3 =   CASE
						                WHEN @CheckTerm3 IS NOT NULL THEN @CheckTerm3
						                ELSE CheckTerm3
						            END,
						    MoldGradeTypeCode =   CASE
						                WHEN @MoldGradeTypeCode IS NOT NULL THEN @MoldGradeTypeCode
						                ELSE MoldGradeTypeCode
						            END,
						    CheckSheetType1 =   CASE
						                WHEN @CheckSheetType1 IS NOT NULL THEN @CheckSheetType1
						                ELSE CheckSheetType1
						            END,
						    CheckSheetType2 =   CASE
						                WHEN @CheckSheetType2 IS NOT NULL THEN @CheckSheetType2
						                ELSE CheckSheetType2
						            END,
						    CheckSheetType3 =   CASE
						                WHEN @CheckSheetType3 IS NOT NULL THEN @CheckSheetType3
						                ELSE CheckSheetType3
						            END,
						    CheckSheetType4 =   CASE
						                WHEN @CheckSheetType4 IS NOT NULL THEN @CheckSheetType4
						                ELSE CheckSheetType4
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
						    MoldNumber = @OldMoldNumber
                END ELSE IF @IUD_FLAG = 'DELETE' BEGIN
                    DELETE FROM STB_MoldBasicInfo
						WHERE
						    MoldNumber = @MoldNumber
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
