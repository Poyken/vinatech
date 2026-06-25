
CREATE PROCEDURE [dbo].[usp_QcInspectionItem_HY_iud]
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
  DECLARE @OldQcInspectionItemCode VARCHAR(20)
  DECLARE @QcInspectionItemCode VARCHAR(20)
  DECLARE @QcInspectionGroupCode VARCHAR(20)
  DECLARE @QcInspectionItemName NVARCHAR(200)
  DECLARE @QcInspectionItemDesc NVARCHAR(MAX)
  DECLARE @ItemInspectionPrior INT
  DECLARE @ItemReportPrior INT
  DECLARE @IsCanSkip BIT
  DECLARE @InspectionType VARCHAR(10)
  DECLARE @IsMaterialSpec BIT
  DECLARE @IsHideOrShowHistory BIT
  DECLARE @QcSpecDesc NVARCHAR(MAX)
  DECLARE @InspectionLevel VARCHAR(20)
  DECLARE @AQL NUMERIC(10,3)
  DECLARE @SpecValue NUMERIC(20,5)
  DECLARE @USL NUMERIC(20,5)
  DECLARE @LSL NUMERIC(20,5)
  DECLARE @UCL NUMERIC(20,5)
  DECLARE @LCL NUMERIC(20,5)
  DECLARE @TextSpecValue NVARCHAR(200)
  DECLARE @CreateDateTime DATETIME
  DECLARE @CreateUserID VARCHAR(20)
  DECLARE @ChangeDateTime DATETIME
  DECLARE @ChangeUserID VARCHAR(20)


	DECLARE @iDoc INT

    EXEC SmartFramework.dbo.usp_GetSerialRule 
			@pTableName = 'STB_QcInspectionItem_HY',
			@pIsAutoKey = @IsAutoKey OUTPUT,
			@pIsLoopIUD = @IsLoopIUD OUTPUT,
			@pPrefixData = @PrefixString OUTPUT,
			@pSerialLen = @SerialLen OUTPUT
    
    IF @IsAutoKey = 0 AND @IsLoopIUD = 0 BEGIN
   
	    EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
	
	    BEGIN TRY
			-- Process Insert Table
            MERGE STB_QcInspectionItem_HY AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN XMLData.OldQcInspectionItemCode IS NULL THEN XMLData.QcInspectionItemCode
							    ELSE XMLData.OldQcInspectionItemCode
							END AS OldQcInspectionItemCode,
							XMLData.QcInspectionItemCode,
							XMLData.QcInspectionGroupCode,
							XMLData.QcInspectionItemName,
							XMLData.QcInspectionItemDesc,
							XMLData.ItemInspectionPrior,
							XMLData.ItemReportPrior,
							XMLData.IsCanSkip,
							XMLData.InspectionType,
							XMLData.IsMaterialSpec,
							XMLData.IsHideOrShowHistory,
							XMLData.QcSpecDesc,
							XMLData.InspectionLevel,
							XMLData.AQL,
							XMLData.SpecValue,
							XMLData.USL,
							XMLData.LSL,
							XMLData.UCL,
							XMLData.LCL,
							XMLData.TextSpecValue,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @InsertTableName , 2)
							WITH  (
										OldQcInspectionItemCode VARCHAR(20),
										QcInspectionItemCode VARCHAR(20),
										QcInspectionGroupCode VARCHAR(20),
										QcInspectionItemName NVARCHAR(200),
										QcInspectionItemDesc NVARCHAR(MAX),
										ItemInspectionPrior INT,
										ItemReportPrior INT,
										IsCanSkip BIT,
										InspectionType VARCHAR(10),
										IsMaterialSpec BIT,
										IsHideOrShowHistory BIT,
										QcSpecDesc NVARCHAR(MAX),
										InspectionLevel VARCHAR(20),
										AQL NUMERIC(10,3),
										SpecValue NUMERIC(20,5),
										USL NUMERIC(20,5),
										LSL NUMERIC(20,5),
										UCL NUMERIC(20,5),
										LCL NUMERIC(20,5),
										TextSpecValue NVARCHAR(200),
										CreateDateTime DATETIME,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIME,
										ChangeUserID VARCHAR(20)
									) XMLData
				) AS SourceTable
			ON
				(
					TargetTable.QcInspectionItemCode = SourceTable.QcInspectionItemCode
				)

			WHEN MATCHED THEN
				UPDATE SET
					QcInspectionItemCode = SourceTable.QcInspectionItemCode,
					QcInspectionGroupCode = SourceTable.QcInspectionGroupCode,
					QcInspectionItemName = SourceTable.QcInspectionItemName,
					QcInspectionItemDesc = SourceTable.QcInspectionItemDesc,
					ItemInspectionPrior = SourceTable.ItemInspectionPrior,
					ItemReportPrior = SourceTable.ItemReportPrior,
					IsCanSkip = SourceTable.IsCanSkip,
					InspectionType = SourceTable.InspectionType,
					IsMaterialSpec = SourceTable.IsMaterialSpec,
					IsHideOrShowHistory = SourceTable.IsHideOrShowHistory,
					QcSpecDesc = SourceTable.QcSpecDesc,
					InspectionLevel = SourceTable.InspectionLevel,
					AQL = SourceTable.AQL,
					SpecValue = SourceTable.SpecValue,
					USL = SourceTable.USL,
					LSL = SourceTable.LSL,
					UCL = SourceTable.UCL,
					LCL = SourceTable.LCL,
					TextSpecValue = SourceTable.TextSpecValue,
					ChangeDateTime = SourceTable.ChangeDateTime,
					ChangeUserID = SourceTable.ChangeUserID
			WHEN NOT MATCHED THEN
				INSERT
					(
						QcInspectionItemCode,
						QcInspectionGroupCode,
						QcInspectionItemName,
						QcInspectionItemDesc,
						ItemInspectionPrior,
						ItemReportPrior,
						IsCanSkip,
						InspectionType,
						IsMaterialSpec,
						IsHideOrShowHistory,
						QcSpecDesc,
						InspectionLevel,
						AQL,
						SpecValue,
						USL,
						LSL,
						UCL,
						LCL,
						TextSpecValue,
						CreateDateTime,
						CreateUserID
					)
				VALUES
					(
							SourceTable.QcInspectionItemCode,
							SourceTable.QcInspectionGroupCode,
							SourceTable.QcInspectionItemName,
							SourceTable.QcInspectionItemDesc,
							SourceTable.ItemInspectionPrior,
							SourceTable.ItemReportPrior,
							SourceTable.IsCanSkip,
							SourceTable.InspectionType,
							SourceTable.IsMaterialSpec,
							SourceTable.IsHideOrShowHistory,
							SourceTable.QcSpecDesc,
							SourceTable.InspectionLevel,
							SourceTable.AQL,
							SourceTable.SpecValue,
							SourceTable.USL,
							SourceTable.LSL,
							SourceTable.UCL,
							SourceTable.LCL,
							SourceTable.TextSpecValue,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID
					);


			-- Process Update Table
            MERGE STB_QcInspectionItem_HY AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN XMLData.OldQcInspectionItemCode IS NULL THEN XMLData.QcInspectionItemCode
							    ELSE XMLData.OldQcInspectionItemCode
							END AS OldQcInspectionItemCode,
							XMLData.QcInspectionItemCode,
							XMLData.QcInspectionGroupCode,
							XMLData.QcInspectionItemName,
							XMLData.QcInspectionItemDesc,
							XMLData.ItemInspectionPrior,
							XMLData.ItemReportPrior,
							XMLData.IsCanSkip,
							XMLData.InspectionType,
							XMLData.IsMaterialSpec,
							XMLData.IsHideOrShowHistory,
							XMLData.QcSpecDesc,
							XMLData.InspectionLevel,
							XMLData.AQL,
							XMLData.SpecValue,
							XMLData.USL,
							XMLData.LSL,
							XMLData.UCL,
							XMLData.LCL,
							XMLData.TextSpecValue,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @UpdateTableName , 2)
							WITH  (
										OldQcInspectionItemCode VARCHAR(20),
										QcInspectionItemCode VARCHAR(20),
										QcInspectionGroupCode VARCHAR(20),
										QcInspectionItemName NVARCHAR(200),
										QcInspectionItemDesc NVARCHAR(MAX),
										ItemInspectionPrior INT,
										ItemReportPrior INT,
										IsCanSkip BIT,
										InspectionType VARCHAR(10),
										IsMaterialSpec BIT,
										IsHideOrShowHistory BIT,
										QcSpecDesc NVARCHAR(MAX),
										InspectionLevel VARCHAR(20),
										AQL NUMERIC(10,3),
										SpecValue NUMERIC(20,5),
										USL NUMERIC(20,5),
										LSL NUMERIC(20,5),
										UCL NUMERIC(20,5),
										LCL NUMERIC(20,5),
										TextSpecValue NVARCHAR(200),
										CreateDateTime DATETIME,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIME,
										ChangeUserID VARCHAR(20)
									) XMLData
				) AS SourceTable
			ON
				(
					TargetTable.QcInspectionItemCode = SourceTable.OldQcInspectionItemCode
				)

			WHEN MATCHED THEN
				UPDATE SET
					QcInspectionItemCode = SourceTable.QcInspectionItemCode,
					QcInspectionGroupCode = SourceTable.QcInspectionGroupCode,
					QcInspectionItemName = SourceTable.QcInspectionItemName,
					QcInspectionItemDesc = SourceTable.QcInspectionItemDesc,
					ItemInspectionPrior = SourceTable.ItemInspectionPrior,
					ItemReportPrior = SourceTable.ItemReportPrior,
					IsCanSkip = SourceTable.IsCanSkip,
					InspectionType = SourceTable.InspectionType,
					IsMaterialSpec = SourceTable.IsMaterialSpec,
					IsHideOrShowHistory = SourceTable.IsHideOrShowHistory,
					QcSpecDesc = SourceTable.QcSpecDesc,
					InspectionLevel = SourceTable.InspectionLevel,
					AQL = SourceTable.AQL,
					SpecValue = SourceTable.SpecValue,
					USL = SourceTable.USL,
					LSL = SourceTable.LSL,
					UCL = SourceTable.UCL,
					LCL = SourceTable.LCL,
					TextSpecValue = SourceTable.TextSpecValue,
					ChangeDateTime = SourceTable.ChangeDateTime,
					ChangeUserID = SourceTable.ChangeUserID
			WHEN NOT MATCHED THEN
				INSERT
					(
						QcInspectionItemCode,
						QcInspectionGroupCode,
						QcInspectionItemName,
						QcInspectionItemDesc,
						ItemInspectionPrior,
						ItemReportPrior,
						IsCanSkip,
						InspectionType,
						IsMaterialSpec,
						IsHideOrShowHistory,
						QcSpecDesc,
						InspectionLevel,
						AQL,
						SpecValue,
						USL,
						LSL,
						UCL,
						LCL,
						TextSpecValue,
						CreateDateTime,
						CreateUserID
					)
				VALUES
					(
							SourceTable.QcInspectionItemCode,
							SourceTable.QcInspectionGroupCode,
							SourceTable.QcInspectionItemName,
							SourceTable.QcInspectionItemDesc,
							SourceTable.ItemInspectionPrior,
							SourceTable.ItemReportPrior,
							SourceTable.IsCanSkip,
							SourceTable.InspectionType,
							SourceTable.IsMaterialSpec,
							SourceTable.IsHideOrShowHistory,
							SourceTable.QcSpecDesc,
							SourceTable.InspectionLevel,
							SourceTable.AQL,
							SourceTable.SpecValue,
							SourceTable.USL,
							SourceTable.LSL,
							SourceTable.UCL,
							SourceTable.LCL,
							SourceTable.TextSpecValue,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID
					);


			-- Process Delete Table
            MERGE STB_QcInspectionItem_HY AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN XMLData.OldQcInspectionItemCode IS NULL THEN XMLData.QcInspectionItemCode
							    ELSE XMLData.OldQcInspectionItemCode
							END AS OldQcInspectionItemCode,
							XMLData.QcInspectionItemCode,
							XMLData.QcInspectionGroupCode,
							XMLData.QcInspectionItemName,
							XMLData.QcInspectionItemDesc,
							XMLData.ItemInspectionPrior,
							XMLData.ItemReportPrior,
							XMLData.IsCanSkip,
							XMLData.InspectionType,
							XMLData.IsMaterialSpec,
							XMLData.IsHideOrShowHistory,
							XMLData.QcSpecDesc,
							XMLData.InspectionLevel,
							XMLData.AQL,
							XMLData.SpecValue,
							XMLData.USL,
							XMLData.LSL,
							XMLData.UCL,
							XMLData.LCL,
							XMLData.TextSpecValue,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @DeleteTableName , 2)
							WITH  (
										OldQcInspectionItemCode VARCHAR(20),
										QcInspectionItemCode VARCHAR(20),
										QcInspectionGroupCode VARCHAR(20),
										QcInspectionItemName NVARCHAR(200),
										QcInspectionItemDesc NVARCHAR(MAX),
										ItemInspectionPrior INT,
										ItemReportPrior INT,
										IsCanSkip BIT,
										InspectionType VARCHAR(10),
										IsMaterialSpec BIT,
										IsHideOrShowHistory BIT,
										QcSpecDesc NVARCHAR(MAX),
										InspectionLevel VARCHAR(20),
										AQL NUMERIC(10,3),
										SpecValue NUMERIC(20,5),
										USL NUMERIC(20,5),
										LSL NUMERIC(20,5),
										UCL NUMERIC(20,5),
										LCL NUMERIC(20,5),
										TextSpecValue NVARCHAR(200),
										CreateDateTime DATETIME,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIME,
										ChangeUserID VARCHAR(20)
									) XMLData
				) AS SourceTable
			ON
				(
					TargetTable.QcInspectionItemCode = SourceTable.QcInspectionItemCode
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
									XMLData.OldQcInspectionItemCode,
									XMLData.QcInspectionItemCode,
									XMLData.QcInspectionGroupCode,
									XMLData.QcInspectionItemName,
									XMLData.QcInspectionItemDesc,
									XMLData.ItemInspectionPrior,
									XMLData.ItemReportPrior,
									XMLData.IsCanSkip,
									XMLData.InspectionType,
									XMLData.IsMaterialSpec,
									XMLData.IsHideOrShowHistory,
									XMLData.QcSpecDesc,
									XMLData.InspectionLevel,
									XMLData.AQL,
									XMLData.SpecValue,
									XMLData.USL,
									XMLData.LSL,
									XMLData.UCL,
									XMLData.LCL,
									XMLData.TextSpecValue,
									XMLData.CreateDateTime,
									XMLData.CreateUserID,
									XMLData.ChangeDateTime,
									XMLData.ChangeUserID
							FROM
									OPENXML(@idoc , @InsertTableName , 2)
							        WITH  (
											 OldQcInspectionItemCode VARCHAR(20),
											 QcInspectionItemCode VARCHAR(20),
											 QcInspectionGroupCode VARCHAR(20),
											 QcInspectionItemName NVARCHAR(200),
											 QcInspectionItemDesc NVARCHAR(MAX),
											 ItemInspectionPrior INT,
											 ItemReportPrior INT,
											 IsCanSkip BIT,
											 InspectionType VARCHAR(10),
											 IsMaterialSpec BIT,
											 IsHideOrShowHistory  BIT,
											 QcSpecDesc NVARCHAR(MAX),
											 InspectionLevel VARCHAR(20),
											 AQL NUMERIC(10,3),
											 SpecValue NUMERIC(20,5),
											 USL NUMERIC(20,5),
											 LSL NUMERIC(20,5),
											 UCL NUMERIC(20,5),
											 LCL NUMERIC(20,5),
											 TextSpecValue NVARCHAR(200),
											 CreateDateTime DATETIME,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIME,
											 ChangeUserID VARCHAR(20)
											) XMLData
							UNION ALL
							SELECT
									'UPDATE' AS IUD_FLAG,
									CASE 
										WHEN XMLData.OldQcInspectionItemCode IS NULL THEN XMLData.QcInspectionItemCode
										ELSE XMLData.OldQcInspectionItemCode
									END AS OldQcInspectionItemCode,
									XMLData.QcInspectionItemCode,
									XMLData.QcInspectionGroupCode,
									XMLData.QcInspectionItemName,
									XMLData.QcInspectionItemDesc,
									XMLData.ItemInspectionPrior,
									XMLData.ItemReportPrior,
									XMLData.IsCanSkip,
									XMLData.InspectionType,
									XMLData.IsMaterialSpec,
									XMLData.IsHideOrShowHistory,
									XMLData.QcSpecDesc,
									XMLData.InspectionLevel,
									XMLData.AQL,
									XMLData.SpecValue,
									XMLData.USL,
									XMLData.LSL,
									XMLData.UCL,
									XMLData.LCL,
									XMLData.TextSpecValue,
									XMLData.CreateDateTime,
									XMLData.CreateUserID,
									XMLData.ChangeDateTime,
									XMLData.ChangeUserID
							FROM
									OPENXML(@idoc , @UpdateTableName , 2)
							        WITH  (
											 OldQcInspectionItemCode VARCHAR(20),
											 QcInspectionItemCode VARCHAR(20),
											 QcInspectionGroupCode VARCHAR(20),
											 QcInspectionItemName NVARCHAR(200),
											 QcInspectionItemDesc NVARCHAR(MAX),
											 ItemInspectionPrior INT,
											 ItemReportPrior INT,
											 IsCanSkip BIT,
											 InspectionType VARCHAR(10),
											 IsMaterialSpec BIT,
											 IsHideOrShowHistory BIT,
											 QcSpecDesc NVARCHAR(MAX),
											 InspectionLevel VARCHAR(20),
											 AQL NUMERIC(10,3),
											 SpecValue NUMERIC(20,5),
											 USL NUMERIC(20,5),
											 LSL NUMERIC(20,5),
											 UCL NUMERIC(20,5),
											 LCL NUMERIC(20,5),
											 TextSpecValue NVARCHAR(200),
											 CreateDateTime DATETIME,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIME,
											 ChangeUserID VARCHAR(20)
											) XMLData
							UNION ALL
							SELECT
									'DELETE' AS IUD_FLAG,
									CASE 
										WHEN XMLData.OldQcInspectionItemCode IS NULL THEN XMLData.QcInspectionItemCode
										ELSE XMLData.OldQcInspectionItemCode
									END AS OldQcInspectionItemCode,
									XMLData.QcInspectionItemCode,
									XMLData.QcInspectionGroupCode,
									XMLData.QcInspectionItemName,
									XMLData.QcInspectionItemDesc,
									XMLData.ItemInspectionPrior,
									XMLData.ItemReportPrior,
									XMLData.IsCanSkip,
									XMLData.InspectionType,
									XMLData.IsMaterialSpec,
									XMLData.IsHideOrShowHistory,
									XMLData.QcSpecDesc,
									XMLData.InspectionLevel,
									XMLData.AQL,
									XMLData.SpecValue,
									XMLData.USL,
									XMLData.LSL,
									XMLData.UCL,
									XMLData.LCL,
									XMLData.TextSpecValue,
									XMLData.CreateDateTime,
									XMLData.CreateUserID,
									XMLData.ChangeDateTime,
									XMLData.ChangeUserID
							FROM
									OPENXML(@idoc , @DeleteTableName , 2)
							        WITH  (
											 OldQcInspectionItemCode VARCHAR(20),
											 QcInspectionItemCode VARCHAR(20),
											 QcInspectionGroupCode VARCHAR(20),
											 QcInspectionItemName NVARCHAR(200),
											 QcInspectionItemDesc NVARCHAR(MAX),
											 ItemInspectionPrior INT,
											 ItemReportPrior INT,
											 IsCanSkip BIT,
											 InspectionType VARCHAR(10),
											 IsMaterialSpec BIT,
											 IsHideOrShowHistory BIT,
											 QcSpecDesc NVARCHAR(MAX),
											 InspectionLevel VARCHAR(20),
											 AQL NUMERIC(10,3),
											 SpecValue NUMERIC(20,5),
											 USL NUMERIC(20,5),
											 LSL NUMERIC(20,5),
											 UCL NUMERIC(20,5),
											 LCL NUMERIC(20,5),
											 TextSpecValue NVARCHAR(200),
											 CreateDateTime DATETIME,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIME,
											 ChangeUserID VARCHAR(20)
											) XMLData


            OPEN SourceData

            WHILE 1 = 1 BEGIN
                FETCH NEXT FROM SourceData INTO
								 @IUD_FLAG,
								 @OldQcInspectionItemCode,
								 @QcInspectionItemCode,
								 @QcInspectionGroupCode,
								 @QcInspectionItemName,
								 @QcInspectionItemDesc,
								 @ItemInspectionPrior,
								 @ItemReportPrior,
								 @IsCanSkip,
								 @InspectionType,
								 @IsMaterialSpec,
								 @IsHideOrShowHistory,
								 @QcSpecDesc,
								 @InspectionLevel,
								 @AQL,
								 @SpecValue,
								 @USL,
								 @LSL,
								 @UCL,
								 @LCL,
								 @TextSpecValue,
								 @CreateDateTime,
								 @CreateUserID,
								 @ChangeDateTime,
								 @ChangeUserID


                IF @@FETCH_STATUS <> 0 BEGIN
					BREAK
				END
                IF @IUD_FLAG = 'INSERT' BEGIN

                    IF EXISTS (SELECT 1 FROM STB_QcInspectionItem_HY WHERE QcInspectionItemCode = @QcInspectionItemCode) BEGIN
						RAISERROR('Duplicate Data : KeyField = %s', 16, 1, @QcInspectionItemCode)
					END

                    IF @IsAutoKey = 1 BEGIN
						EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_QcInspectionItem_HY', @QcInspectionItemCode OUTPUT
                    END

                    INSERT INTO STB_QcInspectionItem_HY
						(
						    QcInspectionItemCode,
						    QcInspectionGroupCode,
						    QcInspectionItemName,
						    QcInspectionItemDesc,
						    ItemInspectionPrior,
						    ItemReportPrior,
						    IsCanSkip,
						    InspectionType,
						    IsMaterialSpec,
							IsHideOrShowHistory,
						    QcSpecDesc,
						    InspectionLevel,
						    AQL,
						    SpecValue,
						    USL,
						    LSL,
						    UCL,
						    LCL,
						    TextSpecValue,
						    CreateDateTime,
						    CreateUserID,
						    ChangeDateTime,
						    ChangeUserID
						)
						VALUES
						(
						    @QcInspectionItemCode,
						    @QcInspectionGroupCode,
						    @QcInspectionItemName,
						    @QcInspectionItemDesc,
						    @ItemInspectionPrior,
						    @ItemReportPrior,
						    @IsCanSkip,
						    @InspectionType,
						    @IsMaterialSpec,
							@IsHideOrShowHistory,
						    @QcSpecDesc,
						    @InspectionLevel,
						    @AQL,
						    @SpecValue,
						    @USL,
						    @LSL,
						    @UCL,
						    @LCL,
						    @TextSpecValue,
						    GETDATE(),
						    @pProcessUserID,
						    @ChangeDateTime,
						    @ChangeUserID
						)

				END ELSE IF @IUD_FLAG = 'UPDATE' BEGIN
                    UPDATE STB_QcInspectionItem_HY
						SET
						    QcInspectionItemCode =   CASE
						                WHEN @QcInspectionItemCode IS NOT NULL THEN @QcInspectionItemCode
						                ELSE QcInspectionItemCode
						            END,
						    QcInspectionGroupCode =   CASE
						                WHEN @QcInspectionGroupCode IS NOT NULL THEN @QcInspectionGroupCode
						                ELSE QcInspectionGroupCode
						            END,
						    QcInspectionItemName =   CASE
						                WHEN @QcInspectionItemName IS NOT NULL THEN @QcInspectionItemName
						                ELSE QcInspectionItemName
						            END,
						    QcInspectionItemDesc =   CASE
						                WHEN @QcInspectionItemDesc IS NOT NULL THEN @QcInspectionItemDesc
						                ELSE QcInspectionItemDesc
						            END,
						    ItemInspectionPrior =   CASE
						                WHEN @ItemInspectionPrior IS NOT NULL THEN @ItemInspectionPrior
						                ELSE ItemInspectionPrior
						            END,
						    ItemReportPrior =   CASE
						                WHEN @ItemReportPrior IS NOT NULL THEN @ItemReportPrior
						                ELSE ItemReportPrior
						            END,
						    IsCanSkip =   CASE
						                WHEN @IsCanSkip IS NOT NULL THEN @IsCanSkip
						                ELSE IsCanSkip
						            END,
						    InspectionType =   CASE
						                WHEN @InspectionType IS NOT NULL THEN @InspectionType
						                ELSE InspectionType
						            END,
						    IsMaterialSpec =   CASE
						                WHEN @IsMaterialSpec IS NOT NULL THEN @IsMaterialSpec
						                ELSE IsMaterialSpec
						            END,
							IsHideOrShowHistory =   CASE
						                WHEN @IsHideOrShowHistory IS NOT NULL THEN @IsHideOrShowHistory
						                ELSE IsHideOrShowHistory
						            END,
						    QcSpecDesc =   CASE
						                WHEN @QcSpecDesc IS NOT NULL THEN @QcSpecDesc
						                ELSE QcSpecDesc
						            END,
						    InspectionLevel =   CASE
						                WHEN @InspectionLevel IS NOT NULL THEN @InspectionLevel
						                ELSE InspectionLevel
						            END,
						    AQL =   CASE
						                WHEN @AQL IS NOT NULL THEN @AQL
						                ELSE AQL
						            END,
						    SpecValue =   CASE
						                WHEN @SpecValue IS NOT NULL THEN @SpecValue
						                ELSE SpecValue
						            END,
						    USL =   CASE
						                WHEN @USL IS NOT NULL THEN @USL
						                ELSE USL
						            END,
						    LSL =   CASE
						                WHEN @LSL IS NOT NULL THEN @LSL
						                ELSE LSL
						            END,
						    UCL =   CASE
						                WHEN @UCL IS NOT NULL THEN @UCL
						                ELSE UCL
						            END,
						    LCL =   CASE
						                WHEN @LCL IS NOT NULL THEN @LCL
						                ELSE LCL
						            END,
						    TextSpecValue =   CASE
						                WHEN @TextSpecValue IS NOT NULL THEN @TextSpecValue
						                ELSE TextSpecValue
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
						    QcInspectionItemCode = @OldQcInspectionItemCode
                END ELSE IF @IUD_FLAG = 'DELETE' BEGIN
                    DELETE FROM STB_QcInspectionItem_HY
						WHERE
						    QcInspectionItemCode = @QcInspectionItemCode
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
