
-- =============================================
-- Author:	    Jeon Gyeong Ho(khjun@awoo.co.kr)
-- Create date: 2018-08-30
-- Browsable : true
-- Group : 품질관리
-- Description:	
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_OqcLotCreateRule_iud]
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
  DECLARE @OldOqcCreateRuleNo VARCHAR(20)
  DECLARE @OqcCreateRuleNo VARCHAR(20)
  DECLARE @OqcCreateRuleName NVARCHAR(50)
  DECLARE @CompanyCode VARCHAR(20)
  DECLARE @WorkCenterCode VARCHAR(20)
  DECLARE @ProdStartTime VARCHAR(4)
  DECLARE @ProdEndTime VARCHAR(4)
  DECLARE @IntervalHour INT
  DECLARE @InspectionLevel VARCHAR(20)
  DECLARE @AQL NUMERIC(10,3)
  DECLARE @CreateDateTime DATETIME
  DECLARE @CreateUserID VARCHAR(20)
  DECLARE @ChangeDateTime DATETIME
  DECLARE @ChangeUserID VARCHAR(20)


	DECLARE @iDoc INT

    EXEC SmartFramework.dbo.usp_GetSerialRule 
			@pTableName = 'STB_OqcLotCreateRule',
			@pIsAutoKey = @IsAutoKey OUTPUT,
			@pIsLoopIUD = @IsLoopIUD OUTPUT,
			@pPrefixData = @PrefixString OUTPUT,
			@pSerialLen = @SerialLen OUTPUT
    
    IF @IsAutoKey = 0 AND @IsLoopIUD = 0 BEGIN
   
	    EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
	
	    BEGIN TRY
			-- Process Insert Table
            MERGE STB_OqcLotCreateRule AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldOqcCreateRuleNo IS NULL THEN OqcCreateRuleNo
							    ELSE OldOqcCreateRuleNo
							END AS OldOqcCreateRuleNo,
							OqcCreateRuleNo,
							OqcCreateRuleName,
							CompanyCode,
							WorkCenterCode,
							ProdStartTime,
							ProdEndTime,
							IntervalHour,
							InspectionLevel,
							AQL,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @InsertTableName , 2)
							WITH  (
										OldOqcCreateRuleNo VARCHAR(20),
										OqcCreateRuleNo VARCHAR(20),
										OqcCreateRuleName NVARCHAR(50),
										CompanyCode VARCHAR(20),
										WorkCenterCode VARCHAR(20),
										ProdStartTime VARCHAR(4),
										ProdEndTime VARCHAR(4),
										IntervalHour INT,
										InspectionLevel VARCHAR(20),
										AQL NUMERIC(10,3),
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.OqcCreateRuleNo = SourceTable.OqcCreateRuleNo
				)

			WHEN MATCHED THEN
				UPDATE SET
					OqcCreateRuleNo = ISNULL(SourceTable.OqcCreateRuleNo,TargetTable.OqcCreateRuleNo),
					OqcCreateRuleName = ISNULL(SourceTable.OqcCreateRuleName,TargetTable.OqcCreateRuleName),
					CompanyCode = ISNULL(SourceTable.CompanyCode,TargetTable.CompanyCode),
					WorkCenterCode = ISNULL(SourceTable.WorkCenterCode,TargetTable.WorkCenterCode),
					ProdStartTime = ISNULL(SourceTable.ProdStartTime,TargetTable.ProdStartTime),
					ProdEndTime = ISNULL(SourceTable.ProdEndTime,TargetTable.ProdEndTime),
					IntervalHour = ISNULL(SourceTable.IntervalHour,TargetTable.IntervalHour),
					InspectionLevel = ISNULL(SourceTable.InspectionLevel,TargetTable.InspectionLevel),
					AQL = ISNULL(SourceTable.AQL,TargetTable.AQL),
					ChangeDateTime = ISNULL(SourceTable.ChangeDateTime,TargetTable.ChangeDateTime),
					ChangeUserID = ISNULL(SourceTable.ChangeUserID,TargetTable.ChangeUserID)
			WHEN NOT MATCHED THEN
				INSERT
					(
						OqcCreateRuleNo,
						OqcCreateRuleName,
						CompanyCode,
						WorkCenterCode,
						ProdStartTime,
						ProdEndTime,
						IntervalHour,
						InspectionLevel,
						AQL,
						CreateDateTime,
						CreateUserID
					)
				VALUES
					(
							SourceTable.OqcCreateRuleNo,
							SourceTable.OqcCreateRuleName,
							SourceTable.CompanyCode,
							SourceTable.WorkCenterCode,
							SourceTable.ProdStartTime,
							SourceTable.ProdEndTime,
							SourceTable.IntervalHour,
							SourceTable.InspectionLevel,
							SourceTable.AQL,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID
					);


			-- Process Update Table
            MERGE STB_OqcLotCreateRule AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldOqcCreateRuleNo IS NULL THEN OqcCreateRuleNo
							    ELSE OldOqcCreateRuleNo
							END AS OldOqcCreateRuleNo,
							OqcCreateRuleNo,
							OqcCreateRuleName,
							CompanyCode,
							WorkCenterCode,
							ProdStartTime,
							ProdEndTime,
							IntervalHour,
							InspectionLevel,
							AQL,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @UpdateTableName , 2)
							WITH  (
										OldOqcCreateRuleNo VARCHAR(20),
										OqcCreateRuleNo VARCHAR(20),
										OqcCreateRuleName NVARCHAR(50),
										CompanyCode VARCHAR(20),
										WorkCenterCode VARCHAR(20),
										ProdStartTime VARCHAR(4),
										ProdEndTime VARCHAR(4),
										IntervalHour INT,
										InspectionLevel VARCHAR(20),
										AQL NUMERIC(10,3),
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.OqcCreateRuleNo = SourceTable.OldOqcCreateRuleNo
				)

			WHEN MATCHED THEN
				UPDATE SET
					OqcCreateRuleNo = ISNULL(SourceTable.OqcCreateRuleNo,TargetTable.OqcCreateRuleNo),
					OqcCreateRuleName = ISNULL(SourceTable.OqcCreateRuleName,TargetTable.OqcCreateRuleName),
					CompanyCode = ISNULL(SourceTable.CompanyCode,TargetTable.CompanyCode),
					WorkCenterCode = ISNULL(SourceTable.WorkCenterCode,TargetTable.WorkCenterCode),
					ProdStartTime = ISNULL(SourceTable.ProdStartTime,TargetTable.ProdStartTime),
					ProdEndTime = ISNULL(SourceTable.ProdEndTime,TargetTable.ProdEndTime),
					IntervalHour = ISNULL(SourceTable.IntervalHour,TargetTable.IntervalHour),
					InspectionLevel = ISNULL(SourceTable.InspectionLevel,TargetTable.InspectionLevel),
					AQL = ISNULL(SourceTable.AQL,TargetTable.AQL),
					ChangeDateTime = ISNULL(SourceTable.ChangeDateTime,TargetTable.ChangeDateTime),
					ChangeUserID = ISNULL(SourceTable.ChangeUserID,TargetTable.ChangeUserID)
			WHEN NOT MATCHED THEN
				INSERT
					(
						OqcCreateRuleNo,
						OqcCreateRuleName,
						CompanyCode,
						WorkCenterCode,
						ProdStartTime,
						ProdEndTime,
						IntervalHour,
						InspectionLevel,
						AQL,
						CreateDateTime,
						CreateUserID
					)
				VALUES
					(
							SourceTable.OqcCreateRuleNo,
							SourceTable.OqcCreateRuleName,
							SourceTable.CompanyCode,
							SourceTable.WorkCenterCode,
							SourceTable.ProdStartTime,
							SourceTable.ProdEndTime,
							SourceTable.IntervalHour,
							SourceTable.InspectionLevel,
							SourceTable.AQL,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID
					);


			-- Process Delete Table
            MERGE STB_OqcLotCreateRule AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldOqcCreateRuleNo IS NULL THEN OqcCreateRuleNo
							    ELSE OldOqcCreateRuleNo
							END AS OldOqcCreateRuleNo,
							OqcCreateRuleNo,
							OqcCreateRuleName,
							CompanyCode,
							WorkCenterCode,
							ProdStartTime,
							ProdEndTime,
							IntervalHour,
							InspectionLevel,
							AQL,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @DeleteTableName , 2)
							WITH  (
										OldOqcCreateRuleNo VARCHAR(20),
										OqcCreateRuleNo VARCHAR(20),
										OqcCreateRuleName NVARCHAR(50),
										CompanyCode VARCHAR(20),
										WorkCenterCode VARCHAR(20),
										ProdStartTime VARCHAR(4),
										ProdEndTime VARCHAR(4),
										IntervalHour INT,
										InspectionLevel VARCHAR(20),
										AQL NUMERIC(10,3),
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.OqcCreateRuleNo = SourceTable.OqcCreateRuleNo
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
									OldOqcCreateRuleNo,
									OqcCreateRuleNo,
									OqcCreateRuleName,
									CompanyCode,
									WorkCenterCode,
									ProdStartTime,
									ProdEndTime,
									IntervalHour,
									InspectionLevel,
									AQL,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID
							FROM
									OPENXML(@idoc , @InsertTableName , 2)
							        WITH  (
											 OldOqcCreateRuleNo VARCHAR(20),
											 OqcCreateRuleNo VARCHAR(20),
											 OqcCreateRuleName NVARCHAR(50),
											 CompanyCode VARCHAR(20),
											 WorkCenterCode VARCHAR(20),
											 ProdStartTime VARCHAR(4),
											 ProdEndTime VARCHAR(4),
											 IntervalHour INT,
											 InspectionLevel VARCHAR(20),
											 AQL NUMERIC(10,3),
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											)
							UNION ALL
							SELECT
									'UPDATE' AS IUD_FLAG,
									CASE 
										WHEN OldOqcCreateRuleNo IS NULL THEN OqcCreateRuleNo
										ELSE OldOqcCreateRuleNo
									END AS OldOqcCreateRuleNo,
									OqcCreateRuleNo,
									OqcCreateRuleName,
									CompanyCode,
									WorkCenterCode,
									ProdStartTime,
									ProdEndTime,
									IntervalHour,
									InspectionLevel,
									AQL,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID
							FROM
									OPENXML(@idoc , @UpdateTableName , 2)
							        WITH  (
											 OldOqcCreateRuleNo VARCHAR(20),
											 OqcCreateRuleNo VARCHAR(20),
											 OqcCreateRuleName NVARCHAR(50),
											 CompanyCode VARCHAR(20),
											 WorkCenterCode VARCHAR(20),
											 ProdStartTime VARCHAR(4),
											 ProdEndTime VARCHAR(4),
											 IntervalHour INT,
											 InspectionLevel VARCHAR(20),
											 AQL NUMERIC(10,3),
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											)
							UNION ALL
							SELECT
									'DELETE' AS IUD_FLAG,
									CASE 
										WHEN OldOqcCreateRuleNo IS NULL THEN OqcCreateRuleNo
										ELSE OldOqcCreateRuleNo
									END AS OldOqcCreateRuleNo,
									OqcCreateRuleNo,
									OqcCreateRuleName,
									CompanyCode,
									WorkCenterCode,
									ProdStartTime,
									ProdEndTime,
									IntervalHour,
									InspectionLevel,
									AQL,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID
							FROM
									OPENXML(@idoc , @DeleteTableName , 2)
							        WITH  (
											 OldOqcCreateRuleNo VARCHAR(20),
											 OqcCreateRuleNo VARCHAR(20),
											 OqcCreateRuleName NVARCHAR(50),
											 CompanyCode VARCHAR(20),
											 WorkCenterCode VARCHAR(20),
											 ProdStartTime VARCHAR(4),
											 ProdEndTime VARCHAR(4),
											 IntervalHour INT,
											 InspectionLevel VARCHAR(20),
											 AQL NUMERIC(10,3),
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											) 


            OPEN SourceData

            WHILE 1 = 1 BEGIN
                FETCH NEXT FROM SourceData INTO
								 @IUD_FLAG,
								 @OldOqcCreateRuleNo,
								 @OqcCreateRuleNo,
								 @OqcCreateRuleName,
								 @CompanyCode,
								 @WorkCenterCode,
								 @ProdStartTime,
								 @ProdEndTime,
								 @IntervalHour,
								 @InspectionLevel,
								 @AQL,
								 @CreateDateTime,
								 @CreateUserID,
								 @ChangeDateTime,
								 @ChangeUserID


                IF @@FETCH_STATUS <> 0 BEGIN
					BREAK
				END
                IF @IUD_FLAG = 'INSERT' BEGIN

                    IF EXISTS (SELECT 1 FROM STB_OqcLotCreateRule WHERE OqcCreateRuleNo = @OqcCreateRuleNo) BEGIN
						RAISERROR('Duplicate Data : KeyField = %s', 16, 1, @OqcCreateRuleNo)
					END

                    IF @IsAutoKey = 1 BEGIN
                        EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_OqcLotCreateRule',@OqcCreateRuleNo OUTPUT
                    END

                    INSERT INTO STB_OqcLotCreateRule
						(
						    OqcCreateRuleNo,
						    OqcCreateRuleName,
						    CompanyCode,
						    WorkCenterCode,
						    ProdStartTime,
						    ProdEndTime,
						    IntervalHour,
						    InspectionLevel,
						    AQL,
						    CreateDateTime,
						    CreateUserID,
						    ChangeDateTime,
						    ChangeUserID
						)
						VALUES
						(
						    @OqcCreateRuleNo,
						    @OqcCreateRuleName,
						    @CompanyCode,
						    @WorkCenterCode,
						    @ProdStartTime,
						    @ProdEndTime,
						    @IntervalHour,
						    @InspectionLevel,
						    @AQL,
						    GETDATE(),
						    @pProcessUserID,
						    @ChangeDateTime,
						    @ChangeUserID
						)

				END ELSE IF @IUD_FLAG = 'UPDATE' BEGIN
                    UPDATE STB_OqcLotCreateRule
						SET
						    OqcCreateRuleNo =   ISNULL(@OqcCreateRuleNo,OqcCreateRuleNo),
						    OqcCreateRuleName =   ISNULL(@OqcCreateRuleName,OqcCreateRuleName),
						    CompanyCode =   ISNULL(@CompanyCode,CompanyCode),
						    WorkCenterCode =   ISNULL(@WorkCenterCode,WorkCenterCode),
						    ProdStartTime =   ISNULL(@ProdStartTime,ProdStartTime),
						    ProdEndTime =   ISNULL(@ProdEndTime,ProdEndTime),
						    IntervalHour =   ISNULL(@IntervalHour,IntervalHour),
						    InspectionLevel =   ISNULL(@InspectionLevel,InspectionLevel),
						    AQL =   ISNULL(@AQL,AQL),
						    CreateDateTime =   ISNULL(@CreateDateTime,CreateDateTime),
						    CreateUserID =   ISNULL(@CreateUserID,CreateUserID),
						    ChangeDateTime = GETDATE(),
						    ChangeUserID = @pProcessUserID
						WHERE
						    OqcCreateRuleNo = @OldOqcCreateRuleNo
                END ELSE IF @IUD_FLAG = 'DELETE' BEGIN
                    DELETE FROM STB_OqcLotCreateRule
						WHERE
						    OqcCreateRuleNo = @OldOqcCreateRuleNo
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
