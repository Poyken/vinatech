-- =============================================
-- Author: Park Jong Hoon(jhpark@awoo.co.kr)
-- Create date: 2016-05-18
-- Browsable : true
-- Group : 설비관리
-- Description:	설비별스페어파트정보 IUD
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_MachineSparePartInfo_iud]
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
  DECLARE @OldMachineCode VARCHAR(20)
  DECLARE @OldSparePartCode VARCHAR(20)
  DECLARE @MachineCode VARCHAR(20)
  DECLARE @SparePartCode VARCHAR(20)
  DECLARE @ChangePlanType VARCHAR(20)
  DECLARE @ChangePlan BIGINT
  DECLARE @LastChangeDate DATE
  DECLARE @CreateDateTime DATETIME
  DECLARE @CreateUserID VARCHAR(20)
  DECLARE @ChangeDateTime DATETIME
  DECLARE @ChangeUserID VARCHAR(20)


	DECLARE @iDoc INT

    EXEC SmartFramework.dbo.usp_GetSerialRule 
			@pTableName = 'STB_MachineSparePartInfo',
			@pIsAutoKey = @IsAutoKey OUTPUT,
			@pIsLoopIUD = @IsLoopIUD OUTPUT,
			@pPrefixData = @PrefixString OUTPUT,
			@pSerialLen = @SerialLen OUTPUT
    
    IF @IsAutoKey = 0 AND @IsLoopIUD = 0 BEGIN
   
	    EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
	
	    BEGIN TRY
			-- Process Insert Table
            MERGE STB_MachineSparePartInfo AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN XMLData.OldMachineCode IS NULL THEN XMLData.MachineCode
							    ELSE XMLData.OldMachineCode
							END AS OldMachineCode,
							CASE
							    WHEN XMLData.OldSparePartCode IS NULL THEN XMLData.SparePartCode
							    ELSE XMLData.OldSparePartCode
							END AS OldSparePartCode,
							XMLData.MachineCode,
							XMLData.SparePartCode,
							XMLData.ChangePlanType,
							XMLData.ChangePlan,
							XMLData.LastChangeDate,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @InsertTableName , 2)
							WITH  (
										OldMachineCode VARCHAR(20),
										OldSparePartCode VARCHAR(20),
										MachineCode VARCHAR(20),
										SparePartCode VARCHAR(20),
										ChangePlanType VARCHAR(20),
										ChangePlan BIGINT,
										LastChangeDate DATETIMEOFFSET,
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) XMLData
				) AS SourceTable
			ON
				(
					TargetTable.MachineCode = SourceTable.MachineCode AND
					TargetTable.SparePartCode = SourceTable.SparePartCode
				)

			WHEN MATCHED THEN
				UPDATE SET
					MachineCode = SourceTable.MachineCode,
					SparePartCode = SourceTable.SparePartCode,
					ChangePlanType = SourceTable.ChangePlanType,
					ChangePlan = SourceTable.ChangePlan,
					LastChangeDate = SourceTable.LastChangeDate,
					ChangeDateTime = SourceTable.ChangeDateTime,
					ChangeUserID = SourceTable.ChangeUserID
			WHEN NOT MATCHED THEN
				INSERT
					(
						MachineCode,
						SparePartCode,
						ChangePlanType,
						ChangePlan,
						LastChangeDate,
						CreateDateTime,
						CreateUserID
					)
				VALUES
					(
							SourceTable.MachineCode,
							SourceTable.SparePartCode,
							SourceTable.ChangePlanType,
							SourceTable.ChangePlan,
							SourceTable.LastChangeDate,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID
					);


			-- Process Update Table
            MERGE STB_MachineSparePartInfo AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN XMLData.OldMachineCode IS NULL THEN XMLData.MachineCode
							    ELSE XMLData.OldMachineCode
							END AS OldMachineCode,
							CASE
							    WHEN XMLData.OldSparePartCode IS NULL THEN XMLData.SparePartCode
							    ELSE XMLData.OldSparePartCode
							END AS OldSparePartCode,
							XMLData.MachineCode,
							XMLData.SparePartCode,
							XMLData.ChangePlanType,
							XMLData.ChangePlan,
							XMLData.LastChangeDate,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @UpdateTableName , 2)
							WITH  (
										OldMachineCode VARCHAR(20),
										OldSparePartCode VARCHAR(20),
										MachineCode VARCHAR(20),
										SparePartCode VARCHAR(20),
										ChangePlanType VARCHAR(20),
										ChangePlan BIGINT,
										LastChangeDate DATETIMEOFFSET,
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) XMLData
				) AS SourceTable
			ON
				(
					TargetTable.MachineCode = SourceTable.OldMachineCode AND
					TargetTable.SparePartCode = SourceTable.OldSparePartCode
				)

			WHEN MATCHED THEN
				UPDATE SET
					MachineCode = SourceTable.MachineCode,
					SparePartCode = SourceTable.SparePartCode,
					ChangePlanType = SourceTable.ChangePlanType,
					ChangePlan = SourceTable.ChangePlan,
					LastChangeDate = SourceTable.LastChangeDate,
					ChangeDateTime = SourceTable.ChangeDateTime,
					ChangeUserID = SourceTable.ChangeUserID
			WHEN NOT MATCHED THEN
				INSERT
					(
						MachineCode,
						SparePartCode,
						ChangePlanType,
						ChangePlan,
						LastChangeDate,
						CreateDateTime,
						CreateUserID
					)
				VALUES
					(
							SourceTable.MachineCode,
							SourceTable.SparePartCode,
							SourceTable.ChangePlanType,
							SourceTable.ChangePlan,
							SourceTable.LastChangeDate,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID
					);


			-- Process Delete Table
            MERGE STB_MachineSparePartInfo AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN XMLData.OldMachineCode IS NULL THEN XMLData.MachineCode
							    ELSE XMLData.OldMachineCode
							END AS OldMachineCode,
							CASE
							    WHEN XMLData.OldSparePartCode IS NULL THEN XMLData.SparePartCode
							    ELSE XMLData.OldSparePartCode
							END AS OldSparePartCode,
							XMLData.MachineCode,
							XMLData.SparePartCode,
							XMLData.ChangePlanType,
							XMLData.ChangePlan,
							XMLData.LastChangeDate,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @DeleteTableName , 2)
							WITH  (
										OldMachineCode VARCHAR(20),
										OldSparePartCode VARCHAR(20),
										MachineCode VARCHAR(20),
										SparePartCode VARCHAR(20),
										ChangePlanType VARCHAR(20),
										ChangePlan BIGINT,
										LastChangeDate DATETIMEOFFSET,
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) XMLData
				) AS SourceTable
			ON
				(
					TargetTable.MachineCode = SourceTable.MachineCode AND
					TargetTable.SparePartCode = SourceTable.SparePartCode
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
									XMLData.OldMachineCode,
									XMLData.OldSparePartCode,
									XMLData.MachineCode,
									XMLData.SparePartCode,
									XMLData.ChangePlanType,
									XMLData.ChangePlan,
									XMLData.LastChangeDate,
									XMLData.CreateDateTime,
									XMLData.CreateUserID,
									XMLData.ChangeDateTime,
									XMLData.ChangeUserID
							FROM
									OPENXML(@idoc , @InsertTableName , 2)
							        WITH  (
											 OldMachineCode VARCHAR(20),
											 OldSparePartCode VARCHAR(20),
											 MachineCode VARCHAR(20),
											 SparePartCode VARCHAR(20),
											 ChangePlanType VARCHAR(20),
											 ChangePlan BIGINT,
											 LastChangeDate DATETIMEOFFSET,
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											) XMLData
							UNION ALL
							SELECT
									'UPDATE' AS IUD_FLAG,
									CASE 
										WHEN XMLData.OldMachineCode IS NULL THEN XMLData.MachineCode
										ELSE XMLData.OldMachineCode
									END AS OldMachineCode,
									CASE 
										WHEN XMLData.OldMachineCode IS NULL THEN XMLData.SparePartCode
										ELSE XMLData.OldMachineCode
									END AS OldSparePartCode,
									XMLData.MachineCode,
									XMLData.SparePartCode,
									XMLData.ChangePlanType,
									XMLData.ChangePlan,
									XMLData.LastChangeDate,
									XMLData.CreateDateTime,
									XMLData.CreateUserID,
									XMLData.ChangeDateTime,
									XMLData.ChangeUserID
							FROM
									OPENXML(@idoc , @UpdateTableName , 2)
							        WITH  (
											 OldMachineCode VARCHAR(20),
											 OldSparePartCode VARCHAR(20),
											 MachineCode VARCHAR(20),
											 SparePartCode VARCHAR(20),
											 ChangePlanType VARCHAR(20),
											 ChangePlan BIGINT,
											 LastChangeDate DATETIMEOFFSET,
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											) XMLData
							UNION ALL
							SELECT
									'DELETE' AS IUD_FLAG,
									CASE 
										WHEN XMLData.OldMachineCode IS NULL THEN XMLData.MachineCode
										ELSE XMLData.OldMachineCode
									END AS OldMachineCode,
									CASE 
										WHEN XMLData.OldMachineCode IS NULL THEN XMLData.SparePartCode
										ELSE XMLData.OldMachineCode
									END AS OldSparePartCode,
									XMLData.MachineCode,
									XMLData.SparePartCode,
									XMLData.ChangePlanType,
									XMLData.ChangePlan,
									XMLData.LastChangeDate,
									XMLData.CreateDateTime,
									XMLData.CreateUserID,
									XMLData.ChangeDateTime,
									XMLData.ChangeUserID
							FROM
									OPENXML(@idoc , @DeleteTableName , 2)
							        WITH  (
											 OldMachineCode VARCHAR(20),
											 OldSparePartCode VARCHAR(20),
											 MachineCode VARCHAR(20),
											 SparePartCode VARCHAR(20),
											 ChangePlanType VARCHAR(20),
											 ChangePlan BIGINT,
											 LastChangeDate DATETIMEOFFSET,
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											) XMLData


            OPEN SourceData

            WHILE 1 = 1 BEGIN
                FETCH NEXT FROM SourceData INTO
								 @IUD_FLAG,
								 @OldMachineCode,
								 @OldSparePartCode,
								 @MachineCode,
								 @SparePartCode,
								 @ChangePlanType,
								 @ChangePlan,
								 @LastChangeDate,
								 @CreateDateTime,
								 @CreateUserID,
								 @ChangeDateTime,
								 @ChangeUserID


                IF @@FETCH_STATUS <> 0 BEGIN
					BREAK
				END
                IF @IUD_FLAG = 'INSERT' BEGIN

                    IF EXISTS (SELECT 1 FROM STB_MachineSparePartInfo WHERE MachineCode = @MachineCode) BEGIN
						RAISERROR('Duplicate Data : KeyField = %s', 16, 1, @MachineCode)
					END

                    IF @IsAutoKey = 1 BEGIN
						EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_MachineSparePartInfo', @MachineCode OUTPUT
                    END

                    INSERT INTO STB_MachineSparePartInfo
						(
						    MachineCode,
						    SparePartCode,
						    ChangePlanType,
						    ChangePlan,
						    LastChangeDate,
						    CreateDateTime,
						    CreateUserID,
						    ChangeDateTime,
						    ChangeUserID
						)
						VALUES
						(
						    @MachineCode,
						    @SparePartCode,
						    @ChangePlanType,
						    @ChangePlan,
						    @LastChangeDate,
						    GETDATE(),
						    @pProcessUserID,
						    @ChangeDateTime,
						    @ChangeUserID
						)

				END ELSE IF @IUD_FLAG = 'UPDATE' BEGIN
                    UPDATE STB_MachineSparePartInfo
						SET
						    MachineCode =   CASE
						                WHEN @MachineCode IS NOT NULL THEN @MachineCode
						                ELSE MachineCode
						            END,
						    SparePartCode =   CASE
						                WHEN @SparePartCode IS NOT NULL THEN @SparePartCode
						                ELSE SparePartCode
						            END,
						    ChangePlanType =   CASE
						                WHEN @ChangePlanType IS NOT NULL THEN @ChangePlanType
						                ELSE ChangePlanType
						            END,
						    ChangePlan =   CASE
						                WHEN @ChangePlan IS NOT NULL THEN @ChangePlan
						                ELSE ChangePlan
						            END,
						    LastChangeDate =   CASE
						                WHEN @LastChangeDate IS NOT NULL THEN @LastChangeDate
						                ELSE LastChangeDate
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
						    MachineCode = @OldMachineCode AND
						    SparePartCode = @OldSparePartCode
                END ELSE IF @IUD_FLAG = 'DELETE' BEGIN
                    DELETE FROM STB_MachineSparePartInfo
						WHERE
						    MachineCode = @MachineCode AND
						    SparePartCode = @SparePartCode
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

