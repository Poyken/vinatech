
-- =============================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Create date: 2020-01-06
-- Browsable : true
-- Group : 신뢰성관리
-- Description:	
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_ReliabilityTestRequestInfo_iud]
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
  DECLARE @OldRTRequestNo VARCHAR(50)
  DECLARE @RTRequestNo VARCHAR(50)
  DECLARE @RequestDate DATE
  DECLARE @RequestDeptCode VARCHAR(20)
  DECLARE @RequesterID VARCHAR(20)
  DECLARE @MassProductionLotNo VARCHAR(20)
  DECLARE @TestPurposeComment VARCHAR(MAX)
  DECLARE @CapacityCondition VARCHAR(1000)
  DECLARE @ACEsrCondition VARCHAR(1000)
  DECLARE @DCEsrCondition VARCHAR(1000)
  DECLARE @SDCondition VARCHAR(1000)
  DECLARE @LCCondition VARCHAR(1000)
  DECLARE @ETCCondition VARCHAR(1000)
  DECLARE @RequestRemark VARCHAR(MAX)
  DECLARE @RecipientID VARCHAR(20)
  DECLARE @ReceptionDate DATETIME
  DECLARE @ReceptionNo VARCHAR(50)
  DECLARE @CreateDateTime DATETIME
  DECLARE @CreateUserID VARCHAR(20)
  DECLARE @ChangeDateTime DATETIME
  DECLARE @ChangeUserID VARCHAR(20)
  DECLARE @TestClassCode VARCHAR(10)
  DECLARE @LengthCondition VARCHAR(MAX)
  DECLARE @WeightCondition VARCHAR(MAX)


	DECLARE @iDoc INT

    EXEC SmartFramework.dbo.usp_GetSerialRule 
			@pTableName = 'STB_ReliabilityTestRequestInfo',
			@pIsAutoKey = @IsAutoKey OUTPUT,
			@pIsLoopIUD = @IsLoopIUD OUTPUT,
			@pPrefixData = @PrefixString OUTPUT,
			@pSerialLen = @SerialLen OUTPUT
    
    IF @IsAutoKey = 0 AND @IsLoopIUD = 0 BEGIN
   
	    EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
	
	    BEGIN TRY
			-- Process Insert Table
            MERGE STB_ReliabilityTestRequestInfo AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldRTRequestNo IS NULL THEN RTRequestNo
							    ELSE OldRTRequestNo
							END AS OldRTRequestNo,
							RTRequestNo,
							RequestDate,
							RequestDeptCode,
							RequesterID,
							MassProductionLotNo,
							TestPurposeComment,
							CapacityCondition,
							ACEsrCondition,
							DCEsrCondition,
							SDCondition,
							LCCondition,
							ETCCondition,
							RequestRemark,
							RecipientID,
							ReceptionDate,
							ReceptionNo,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID,
							TestClassCode,
							LengthCondition,
							WeightCondition
					FROM
							OPENXML(@idoc , @InsertTableName , 2)
							WITH  (
										OldRTRequestNo VARCHAR(50),
										RTRequestNo VARCHAR(50),
										RequestDate DATETIMEOFFSET,
										RequestDeptCode VARCHAR(20),
										RequesterID VARCHAR(20),
										MassProductionLotNo VARCHAR(20),
										TestPurposeComment VARCHAR(MAX),
										CapacityCondition VARCHAR(1000),
										ACEsrCondition VARCHAR(1000),
										DCEsrCondition VARCHAR(1000),
										SDCondition VARCHAR(1000),
										LCCondition VARCHAR(1000),
										ETCCondition VARCHAR(1000),
										RequestRemark VARCHAR(MAX),
										RecipientID VARCHAR(20),
										ReceptionDate DATETIMEOFFSET,
										ReceptionNo VARCHAR(50),
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20),
										TestClassCode VARCHAR(10),
										LengthCondition VARCHAR(MAX),
										WeightCondition VARCHAR(MAX)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.RTRequestNo = SourceTable.RTRequestNo
				)

			WHEN MATCHED THEN
				UPDATE SET
					RequestDate = ISNULL(SourceTable.RequestDate,TargetTable.RequestDate),
					RequestDeptCode = ISNULL(SourceTable.RequestDeptCode,TargetTable.RequestDeptCode),
					RequesterID = ISNULL(SourceTable.RequesterID,TargetTable.RequesterID),
					MassProductionLotNo = ISNULL(SourceTable.MassProductionLotNo,TargetTable.MassProductionLotNo),
					TestPurposeComment = ISNULL(SourceTable.TestPurposeComment,TargetTable.TestPurposeComment),
					CapacityCondition = ISNULL(SourceTable.CapacityCondition,TargetTable.CapacityCondition),
					ACEsrCondition = ISNULL(SourceTable.ACEsrCondition,TargetTable.ACEsrCondition),
					DCEsrCondition = ISNULL(SourceTable.DCEsrCondition,TargetTable.DCEsrCondition),
					SDCondition = ISNULL(SourceTable.SDCondition,TargetTable.SDCondition),
					LCCondition = ISNULL(SourceTable.LCCondition,TargetTable.LCCondition),
					ETCCondition = ISNULL(SourceTable.ETCCondition,TargetTable.ETCCondition),
					RequestRemark = ISNULL(SourceTable.RequestRemark,TargetTable.RequestRemark),
					RecipientID = ISNULL(SourceTable.RecipientID,TargetTable.RecipientID),
					ReceptionDate = ISNULL(SourceTable.ReceptionDate,TargetTable.ReceptionDate),
					ReceptionNo = ISNULL(SourceTable.ReceptionNo,TargetTable.ReceptionNo),
					ChangeDateTime = ISNULL(SourceTable.ChangeDateTime,TargetTable.ChangeDateTime),
					ChangeUserID = ISNULL(SourceTable.ChangeUserID,TargetTable.ChangeUserID),
					TestClassCode = ISNULL(SourceTable.TestClassCode,TargetTable.TestClassCode),
					LengthCondition = ISNULL(SourceTable.LengthCondition,TargetTable.LengthCondition),
					WeightCondition = ISNULL(SourceTable.WeightCondition,TargetTable.WeightCondition)
			WHEN NOT MATCHED THEN
				INSERT
					(
						RTRequestNo,
						RequestDate,
						RequestDeptCode,
						RequesterID,
						MassProductionLotNo,
						TestPurposeComment,
						CapacityCondition,
						ACEsrCondition,
						DCEsrCondition,
						SDCondition,
						LCCondition,
						ETCCondition,
						RequestRemark,
						RecipientID,
						ReceptionDate,
						ReceptionNo,
						CreateDateTime,
						CreateUserID,
						TestClassCode,
						LengthCondition,
						WeightCondition
					)
				VALUES
					(
							SourceTable.RTRequestNo,
							SourceTable.RequestDate,
							SourceTable.RequestDeptCode,
							SourceTable.RequesterID,
							SourceTable.MassProductionLotNo,
							SourceTable.TestPurposeComment,
							SourceTable.CapacityCondition,
							SourceTable.ACEsrCondition,
							SourceTable.DCEsrCondition,
							SourceTable.SDCondition,
							SourceTable.LCCondition,
							SourceTable.ETCCondition,
							SourceTable.RequestRemark,
							SourceTable.RecipientID,
							SourceTable.ReceptionDate,
							SourceTable.ReceptionNo,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID,
							SourceTable.TestClassCode,
							SourceTable.LengthCondition,
							SourceTable.WeightCondition
					);


			-- Process Update Table
            MERGE STB_ReliabilityTestRequestInfo AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldRTRequestNo IS NULL THEN RTRequestNo
							    ELSE OldRTRequestNo
							END AS OldRTRequestNo,
							RTRequestNo,
							RequestDate,
							RequestDeptCode,
							RequesterID,
							MassProductionLotNo,
							TestPurposeComment,
							CapacityCondition,
							ACEsrCondition,
							DCEsrCondition,
							SDCondition,
							LCCondition,
							ETCCondition,
							RequestRemark,
							RecipientID,
							ReceptionDate,
							ReceptionNo,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID,
							TestClassCode,
							LengthCondition,
							WeightCondition
					FROM
							OPENXML(@idoc , @UpdateTableName , 2)
							WITH  (
										OldRTRequestNo VARCHAR(50),
										RTRequestNo VARCHAR(50),
										RequestDate DATETIMEOFFSET,
										RequestDeptCode VARCHAR(20),
										RequesterID VARCHAR(20),
										MassProductionLotNo VARCHAR(20),
										TestPurposeComment VARCHAR(MAX),
										CapacityCondition VARCHAR(1000),
										ACEsrCondition VARCHAR(1000),
										DCEsrCondition VARCHAR(1000),
										SDCondition VARCHAR(1000),
										LCCondition VARCHAR(1000),
										ETCCondition VARCHAR(1000),
										RequestRemark VARCHAR(MAX),
										RecipientID VARCHAR(20),
										ReceptionDate DATETIMEOFFSET,
										ReceptionNo VARCHAR(50),
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20),
										TestClassCode VARCHAR(10),
										LengthCondition VARCHAR(MAX),
										WeightCondition VARCHAR(MAX)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.RTRequestNo = SourceTable.OldRTRequestNo
				)

			WHEN MATCHED THEN
				UPDATE SET
					RequestDate = ISNULL(SourceTable.RequestDate,TargetTable.RequestDate),
					RequestDeptCode = ISNULL(SourceTable.RequestDeptCode,TargetTable.RequestDeptCode),
					RequesterID = ISNULL(SourceTable.RequesterID,TargetTable.RequesterID),
					MassProductionLotNo = ISNULL(SourceTable.MassProductionLotNo,TargetTable.MassProductionLotNo),
					TestPurposeComment = ISNULL(SourceTable.TestPurposeComment,TargetTable.TestPurposeComment),
					CapacityCondition = ISNULL(SourceTable.CapacityCondition,TargetTable.CapacityCondition),
					ACEsrCondition = ISNULL(SourceTable.ACEsrCondition,TargetTable.ACEsrCondition),
					DCEsrCondition = ISNULL(SourceTable.DCEsrCondition,TargetTable.DCEsrCondition),
					SDCondition = ISNULL(SourceTable.SDCondition,TargetTable.SDCondition),
					LCCondition = ISNULL(SourceTable.LCCondition,TargetTable.LCCondition),
					ETCCondition = ISNULL(SourceTable.ETCCondition,TargetTable.ETCCondition),
					RequestRemark = ISNULL(SourceTable.RequestRemark,TargetTable.RequestRemark),
					RecipientID = ISNULL(SourceTable.RecipientID,TargetTable.RecipientID),
					ReceptionDate = ISNULL(SourceTable.ReceptionDate,TargetTable.ReceptionDate),
					ReceptionNo = ISNULL(SourceTable.ReceptionNo,TargetTable.ReceptionNo),
					ChangeDateTime = ISNULL(SourceTable.ChangeDateTime,TargetTable.ChangeDateTime),
					ChangeUserID = ISNULL(SourceTable.ChangeUserID,TargetTable.ChangeUserID),
					TestClassCode = ISNULL(SourceTable.TestClassCode,TargetTable.TestClassCode),
					LengthCondition = ISNULL(SourceTable.LengthCondition,TargetTable.LengthCondition),
					WeightCondition = ISNULL(SourceTable.WeightCondition,TargetTable.WeightCondition)
			WHEN NOT MATCHED THEN
				INSERT
					(
						RTRequestNo,
						RequestDate,
						RequestDeptCode,
						RequesterID,
						MassProductionLotNo,
						TestPurposeComment,
						CapacityCondition,
						ACEsrCondition,
						DCEsrCondition,
						SDCondition,
						LCCondition,
						ETCCondition,
						RequestRemark,
						RecipientID,
						ReceptionDate,
						ReceptionNo,
						CreateDateTime,
						CreateUserID,
						TestClassCode,
						LengthCondition,
						WeightCondition
					)
				VALUES
					(
							SourceTable.RTRequestNo,
							SourceTable.RequestDate,
							SourceTable.RequestDeptCode,
							SourceTable.RequesterID,
							SourceTable.MassProductionLotNo,
							SourceTable.TestPurposeComment,
							SourceTable.CapacityCondition,
							SourceTable.ACEsrCondition,
							SourceTable.DCEsrCondition,
							SourceTable.SDCondition,
							SourceTable.LCCondition,
							SourceTable.ETCCondition,
							SourceTable.RequestRemark,
							SourceTable.RecipientID,
							SourceTable.ReceptionDate,
							SourceTable.ReceptionNo,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID,
							SourceTable.TestClassCode,
							SourceTable.LengthCondition,
							SourceTable.WeightCondition
					);


			-- Process Delete Table
            MERGE STB_ReliabilityTestRequestInfo AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldRTRequestNo IS NULL THEN RTRequestNo
							    ELSE OldRTRequestNo
							END AS OldRTRequestNo,
							RTRequestNo,
							RequestDate,
							RequestDeptCode,
							RequesterID,
							MassProductionLotNo,
							TestPurposeComment,
							CapacityCondition,
							ACEsrCondition,
							DCEsrCondition,
							SDCondition,
							LCCondition,
							ETCCondition,
							RequestRemark,
							RecipientID,
							ReceptionDate,
							ReceptionNo,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID,
							TestClassCode,
							LengthCondition,
							WeightCondition
					FROM
							OPENXML(@idoc , @DeleteTableName , 2)
							WITH  (
										OldRTRequestNo VARCHAR(50),
										RTRequestNo VARCHAR(50),
										RequestDate DATETIMEOFFSET,
										RequestDeptCode VARCHAR(20),
										RequesterID VARCHAR(20),
										MassProductionLotNo VARCHAR(20),
										TestPurposeComment VARCHAR(MAX),
										CapacityCondition VARCHAR(1000),
										ACEsrCondition VARCHAR(1000),
										DCEsrCondition VARCHAR(1000),
										SDCondition VARCHAR(1000),
										LCCondition VARCHAR(1000),
										ETCCondition VARCHAR(1000),
										RequestRemark VARCHAR(MAX),
										RecipientID VARCHAR(20),
										ReceptionDate DATETIMEOFFSET,
										ReceptionNo VARCHAR(50),
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20),
										TestClassCode VARCHAR(10),
										LengthCondition VARCHAR(MAX),
										WeightCondition VARCHAR(MAX)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.RTRequestNo = SourceTable.RTRequestNo
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
									OldRTRequestNo,
									RTRequestNo,
									RequestDate,
									RequestDeptCode,
									RequesterID,
									MassProductionLotNo,
									TestPurposeComment,
									CapacityCondition,
									ACEsrCondition,
									DCEsrCondition,
									SDCondition,
									LCCondition,
									ETCCondition,
									RequestRemark,
									RecipientID,
									ReceptionDate,
									ReceptionNo,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID,
									TestClassCode,
									LengthCondition,
									WeightCondition
							FROM
									OPENXML(@idoc , @InsertTableName , 2)
							        WITH  (
											 OldRTRequestNo VARCHAR(50),
											 RTRequestNo VARCHAR(50),
											 RequestDate DATETIMEOFFSET,
											 RequestDeptCode VARCHAR(20),
											 RequesterID VARCHAR(20),
											 MassProductionLotNo VARCHAR(20),
											 TestPurposeComment VARCHAR(MAX),
											 CapacityCondition VARCHAR(1000),
											 ACEsrCondition VARCHAR(1000),
											 DCEsrCondition VARCHAR(1000),
											 SDCondition VARCHAR(1000),
											 LCCondition VARCHAR(1000),
											 ETCCondition VARCHAR(1000),
											 RequestRemark VARCHAR(MAX),
											 RecipientID VARCHAR(20),
											 ReceptionDate DATETIMEOFFSET,
											 ReceptionNo VARCHAR(50),
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20),
											 TestClassCode VARCHAR(10),
											 LengthCondition VARCHAR(MAX),
											 WeightCondition VARCHAR(MAX)
											)
							UNION ALL
							SELECT
									'UPDATE' AS IUD_FLAG,
									CASE 
										WHEN OldRTRequestNo IS NULL THEN RTRequestNo
										ELSE OldRTRequestNo
									END AS OldRTRequestNo,
									RTRequestNo,
									RequestDate,
									RequestDeptCode,
									RequesterID,
									MassProductionLotNo,
									TestPurposeComment,
									CapacityCondition,
									ACEsrCondition,
									DCEsrCondition,
									SDCondition,
									LCCondition,
									ETCCondition,
									RequestRemark,
									RecipientID,
									ReceptionDate,
									ReceptionNo,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID,
									TestClassCode,
									LengthCondition,
									WeightCondition
							FROM
									OPENXML(@idoc , @UpdateTableName , 2)
							        WITH  (
											 OldRTRequestNo VARCHAR(50),
											 RTRequestNo VARCHAR(50),
											 RequestDate DATETIMEOFFSET,
											 RequestDeptCode VARCHAR(20),
											 RequesterID VARCHAR(20),
											 MassProductionLotNo VARCHAR(20),
											 TestPurposeComment VARCHAR(MAX),
											 CapacityCondition VARCHAR(1000),
											 ACEsrCondition VARCHAR(1000),
											 DCEsrCondition VARCHAR(1000),
											 SDCondition VARCHAR(1000),
											 LCCondition VARCHAR(1000),
											 ETCCondition VARCHAR(1000),
											 RequestRemark VARCHAR(MAX),
											 RecipientID VARCHAR(20),
											 ReceptionDate DATETIMEOFFSET,
											 ReceptionNo VARCHAR(50),
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20),
											 TestClassCode VARCHAR(10),
											 LengthCondition VARCHAR(MAX),
											 WeightCondition VARCHAR(MAX)
											)
							UNION ALL
							SELECT
									'DELETE' AS IUD_FLAG,
									CASE 
										WHEN OldRTRequestNo IS NULL THEN RTRequestNo
										ELSE OldRTRequestNo
									END AS OldRTRequestNo,
									RTRequestNo,
									RequestDate,
									RequestDeptCode,
									RequesterID,
									MassProductionLotNo,
									TestPurposeComment,
									CapacityCondition,
									ACEsrCondition,
									DCEsrCondition,
									SDCondition,
									LCCondition,
									ETCCondition,
									RequestRemark,
									RecipientID,
									ReceptionDate,
									ReceptionNo,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID,
									TestClassCode,
									LengthCondition,
									WeightCondition
							FROM
									OPENXML(@idoc , @DeleteTableName , 2)
							        WITH  (
											 OldRTRequestNo VARCHAR(50),
											 RTRequestNo VARCHAR(50),
											 RequestDate DATETIMEOFFSET,
											 RequestDeptCode VARCHAR(20),
											 RequesterID VARCHAR(20),
											 MassProductionLotNo VARCHAR(20),
											 TestPurposeComment VARCHAR(MAX),
											 CapacityCondition VARCHAR(1000),
											 ACEsrCondition VARCHAR(1000),
											 DCEsrCondition VARCHAR(1000),
											 SDCondition VARCHAR(1000),
											 LCCondition VARCHAR(1000),
											 ETCCondition VARCHAR(1000),
											 RequestRemark VARCHAR(MAX),
											 RecipientID VARCHAR(20),
											 ReceptionDate DATETIMEOFFSET,
											 ReceptionNo VARCHAR(50),
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20),
											 TestClassCode VARCHAR(10),
											 LengthCondition VARCHAR(MAX),
											 WeightCondition VARCHAR(MAX)
											) 


            OPEN SourceData

            WHILE 1 = 1 BEGIN
                FETCH NEXT FROM SourceData INTO
								 @IUD_FLAG,
								 @OldRTRequestNo,
								 @RTRequestNo,
								 @RequestDate,
								 @RequestDeptCode,
								 @RequesterID,
								 @MassProductionLotNo,
								 @TestPurposeComment,
								 @CapacityCondition,
								 @ACEsrCondition,
								 @DCEsrCondition,
								 @SDCondition,
								 @LCCondition,
								 @ETCCondition,
								 @RequestRemark,
								 @RecipientID,
								 @ReceptionDate,
								 @ReceptionNo,
								 @CreateDateTime,
								 @CreateUserID,
								 @ChangeDateTime,
								 @ChangeUserID,
								 @TestClassCode,
								 @LengthCondition,
								 @WeightCondition


                IF @@FETCH_STATUS <> 0 BEGIN
					BREAK
				END
                IF @IUD_FLAG = 'INSERT' BEGIN

                    IF EXISTS (SELECT 1 FROM STB_ReliabilityTestRequestInfo WHERE RTRequestNo = @RTRequestNo) BEGIN
						RAISERROR('Duplicate Data : KeyField = %s', 16, 1, @RTRequestNo)
					END

                    IF @IsAutoKey = 1 BEGIN
                        EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_ReliabilityTestRequestInfo',@RTRequestNo OUTPUT
                    END

                    INSERT INTO STB_ReliabilityTestRequestInfo
						(
						    RTRequestNo,
						    RequestDate,
						    RequestDeptCode,
						    RequesterID,
						    MassProductionLotNo,
						    TestPurposeComment,
						    CapacityCondition,
						    ACEsrCondition,
						    DCEsrCondition,
						    SDCondition,
						    LCCondition,
						    ETCCondition,
						    RequestRemark,
						    RecipientID,
						    ReceptionDate,
						    ReceptionNo,
						    CreateDateTime,
						    CreateUserID,
						    ChangeDateTime,
						    ChangeUserID,
						    TestClassCode,
						    LengthCondition,
						    WeightCondition
						)
						VALUES
						(
						    @RTRequestNo,
						    @RequestDate,
						    @RequestDeptCode,
						    @RequesterID,
						    @MassProductionLotNo,
						    @TestPurposeComment,
						    @CapacityCondition,
						    @ACEsrCondition,
						    @DCEsrCondition,
						    @SDCondition,
						    @LCCondition,
						    @ETCCondition,
						    @RequestRemark,
						    @RecipientID,
						    @ReceptionDate,
						    @ReceptionNo,
						    GETDATE(),
						    @pProcessUserID,
						    @ChangeDateTime,
						    @ChangeUserID,
						    @TestClassCode,
						    @LengthCondition,
						    @WeightCondition
						)

				END ELSE IF @IUD_FLAG = 'UPDATE' BEGIN
                    UPDATE STB_ReliabilityTestRequestInfo
						SET
						    RequestDate =   ISNULL(@RequestDate,RequestDate),
						    RequestDeptCode =   ISNULL(@RequestDeptCode,RequestDeptCode),
						    RequesterID =   ISNULL(@RequesterID,RequesterID),
						    MassProductionLotNo =   ISNULL(@MassProductionLotNo,MassProductionLotNo),
						    TestPurposeComment =   ISNULL(@TestPurposeComment,TestPurposeComment),
						    CapacityCondition =   ISNULL(@CapacityCondition,CapacityCondition),
						    ACEsrCondition =   ISNULL(@ACEsrCondition,ACEsrCondition),
						    DCEsrCondition =   ISNULL(@DCEsrCondition,DCEsrCondition),
						    SDCondition =   ISNULL(@SDCondition,SDCondition),
						    LCCondition =   ISNULL(@LCCondition,LCCondition),
						    ETCCondition =   ISNULL(@ETCCondition,ETCCondition),
						    RequestRemark =   ISNULL(@RequestRemark,RequestRemark),
						    RecipientID =   ISNULL(@RecipientID,RecipientID),
						    ReceptionDate =   ISNULL(@ReceptionDate,ReceptionDate),
						    ReceptionNo =   ISNULL(@ReceptionNo,ReceptionNo),
						    CreateDateTime =   ISNULL(@CreateDateTime,CreateDateTime),
						    CreateUserID =   ISNULL(@CreateUserID,CreateUserID),
						    ChangeDateTime = GETDATE(),
						    ChangeUserID = @pProcessUserID,
						    TestClassCode =   ISNULL(@TestClassCode,TestClassCode),
						    LengthCondition =   ISNULL(@LengthCondition,LengthCondition),
						    WeightCondition =   ISNULL(@WeightCondition,WeightCondition)
						WHERE
						    RTRequestNo = @OldRTRequestNo
                END ELSE IF @IUD_FLAG = 'DELETE' BEGIN
                    DELETE FROM STB_ReliabilityTestRequestInfo
						WHERE
						    RTRequestNo = @OldRTRequestNo
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
