

-- =============================================
-- Author:	    Kim Han Young(hykim@awoo.co.kr)
-- Create date: 2016-07-29
-- Browsable : true
-- Group : 자재관리
-- Description:	MRP 헤더정보를 INSERT/UPDATE/DELETE 합니다.
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_MrpMaster_iud]
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
  DECLARE @OldMrpNo VARCHAR(20)
  DECLARE @MrpNo VARCHAR(20)
  DECLARE @CompanyCode VARCHAR(20)
  DECLARE @WorkCenterCode VARCHAR(20)
  DECLARE @BasicDate DATE
  DECLARE @MrpDesc NVARCHAR(200)
  DECLARE @IsUseMrpProdDate BIT
  DECLARE @MrpProdDate DATE
  DECLARE @IsRunMrp bit
  DECLARE @MrpRunDateTime DATETIME
  DECLARE @MrpRunUserID VARCHAR(20)
  DECLARE @IsFixedMRP BIT
  DECLARE @MrpFixDateTime DATETIME
  DECLARE @MrpFixUserID VARCHAR(20)
  DECLARE @CreateDateTime DATETIME
  DECLARE @CreateUserID VARCHAR(20)
  DECLARE @ChangeDateTime DATETIME
  DECLARE @ChangeUserID VARCHAR(20)

  DECLARE @BefIsFixed BIT


	DECLARE @iDoc INT

    EXEC SmartFramework.dbo.usp_GetSerialRule 
			@pTableName = 'STB_MrpMaster',
			@pIsAutoKey = @IsAutoKey OUTPUT,
			@pIsLoopIUD = @IsLoopIUD OUTPUT,
			@pPrefixData = @PrefixString OUTPUT,
			@pSerialLen = @SerialLen OUTPUT
    
    IF @IsAutoKey = 0 AND @IsLoopIUD = 0 BEGIN
   
	    EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
	
	    BEGIN TRY
			-- Process Insert Table
            MERGE STB_MrpMaster AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldMrpNo IS NULL THEN MrpNo
							    ELSE OldMrpNo
							END AS OldMrpNo,
							MrpNo,
							CompanyCode,
							WorkCenterCode,
							BasicDate,
							MrpDesc,
							IsUseMrpProdDate,
							MrpProdDate,
							IsRunMrp,
							MrpRunDateTime,
							MrpRunUserID,
							IsFixedMRP,
							MrpFixDateTime,
							MrpFixUserID,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @InsertTableName , 2)
							WITH  (
										OldMrpNo VARCHAR(20),
										MrpNo VARCHAR(20),
										CompanyCode VARCHAR(20),
										WorkCenterCode VARCHAR(20),
										BasicDate DATETIMEOFFSET,
										MrpDesc NVARCHAR(200),
										IsUseMrpProdDate BIT,
										MrpProdDate DATETIMEOFFSET,
										IsRunMrp bit,
										MrpRunDateTime DATETIMEOFFSET,
										MrpRunUserID VARCHAR(20),
										IsFixedMRP BIT,
										MrpFixDateTime DATETIMEOFFSET,
										MrpFixUserID VARCHAR(20),
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.MrpNo = SourceTable.MrpNo
				)

			WHEN MATCHED THEN
				UPDATE SET
					MrpNo = ISNULL(SourceTable.MrpNo,TargetTable.MrpNo),
					CompanyCode = ISNULL(SourceTable.CompanyCode,TargetTable.CompanyCode),
					WorkCenterCode = ISNULL(SourceTable.WorkCenterCode,TargetTable.WorkCenterCode),
					BasicDate = ISNULL(SourceTable.BasicDate,TargetTable.BasicDate),
					MrpDesc = ISNULL(SourceTable.MrpDesc,TargetTable.MrpDesc),
					IsUseMrpProdDate = ISNULL(SourceTable.IsUseMrpProdDate,TargetTable.IsUseMrpProdDate),
					MrpProdDate = ISNULL(SourceTable.MrpProdDate,TargetTable.MrpProdDate),
					IsRunMrp = ISNULL(SourceTable.IsRunMrp,TargetTable.IsRunMrp),
					MrpRunDateTime = ISNULL(SourceTable.MrpRunDateTime,TargetTable.MrpRunDateTime),
					MrpRunUserID = ISNULL(SourceTable.MrpRunUserID,TargetTable.MrpRunUserID),
					IsFixedMRP = ISNULL(SourceTable.IsFixedMRP,TargetTable.IsFixedMRP),
					MrpFixDateTime = ISNULL(SourceTable.MrpFixDateTime,TargetTable.MrpFixDateTime),
					MrpFixUserID = ISNULL(SourceTable.MrpFixUserID,TargetTable.MrpFixUserID),
					ChangeDateTime = ISNULL(SourceTable.ChangeDateTime,TargetTable.ChangeDateTime),
					ChangeUserID = ISNULL(SourceTable.ChangeUserID,TargetTable.ChangeUserID)
			WHEN NOT MATCHED THEN
				INSERT
					(
						MrpNo,
						CompanyCode,
						WorkCenterCode,
						BasicDate,
						MrpDesc,
						IsUseMrpProdDate,
						MrpProdDate,
						IsRunMrp,
						MrpRunDateTime,
						MrpRunUserID,
						IsFixedMRP,
						MrpFixDateTime,
						MrpFixUserID,
						CreateDateTime,
						CreateUserID
					)
				VALUES
					(
							SourceTable.MrpNo,
							SourceTable.CompanyCode,
							SourceTable.WorkCenterCode,
							SourceTable.BasicDate,
							SourceTable.MrpDesc,
							SourceTable.IsUseMrpProdDate,
							SourceTable.MrpProdDate,
							SourceTable.IsRunMrp,
							SourceTable.MrpRunDateTime,
							SourceTable.MrpRunUserID,
							SourceTable.IsFixedMRP,
							SourceTable.MrpFixDateTime,
							SourceTable.MrpFixUserID,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID
					);


			-- Process Update Table
            MERGE STB_MrpMaster AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldMrpNo IS NULL THEN MrpNo
							    ELSE OldMrpNo
							END AS OldMrpNo,
							MrpNo,
							CompanyCode,
							WorkCenterCode,
							BasicDate,
							MrpDesc,
							IsUseMrpProdDate,
							MrpProdDate,
							IsRunMrp,
							MrpRunDateTime,
							MrpRunUserID,
							IsFixedMRP,
							MrpFixDateTime,
							MrpFixUserID,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @UpdateTableName , 2)
							WITH  (
										OldMrpNo VARCHAR(20),
										MrpNo VARCHAR(20),
										CompanyCode VARCHAR(20),
										WorkCenterCode VARCHAR(20),
										BasicDate DATETIMEOFFSET,
										MrpDesc NVARCHAR(200),
										IsUseMrpProdDate BIT,
										MrpProdDate DATETIMEOFFSET,
										IsRunMrp bit,
										MrpRunDateTime DATETIMEOFFSET,
										MrpRunUserID VARCHAR(20),
										IsFixedMRP BIT,
										MrpFixDateTime DATETIMEOFFSET,
										MrpFixUserID VARCHAR(20),
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.MrpNo = SourceTable.OldMrpNo
				)

			WHEN MATCHED THEN
				UPDATE SET
					MrpNo = ISNULL(SourceTable.MrpNo,TargetTable.MrpNo),
					CompanyCode = ISNULL(SourceTable.CompanyCode,TargetTable.CompanyCode),
					WorkCenterCode = ISNULL(SourceTable.WorkCenterCode,TargetTable.WorkCenterCode),
					BasicDate = ISNULL(SourceTable.BasicDate,TargetTable.BasicDate),
					MrpDesc = ISNULL(SourceTable.MrpDesc,TargetTable.MrpDesc),
					IsUseMrpProdDate = ISNULL(SourceTable.IsUseMrpProdDate,TargetTable.IsUseMrpProdDate),
					MrpProdDate = ISNULL(SourceTable.MrpProdDate,TargetTable.MrpProdDate),
					IsRunMrp = ISNULL(SourceTable.IsRunMrp,TargetTable.IsRunMrp),
					MrpRunDateTime = ISNULL(SourceTable.MrpRunDateTime,TargetTable.MrpRunDateTime),
					MrpRunUserID = ISNULL(SourceTable.MrpRunUserID,TargetTable.MrpRunUserID),
					IsFixedMRP = ISNULL(SourceTable.IsFixedMRP,TargetTable.IsFixedMRP),
					MrpFixDateTime = ISNULL(SourceTable.MrpFixDateTime,TargetTable.MrpFixDateTime),
					MrpFixUserID = ISNULL(SourceTable.MrpFixUserID,TargetTable.MrpFixUserID),
					ChangeDateTime = ISNULL(SourceTable.ChangeDateTime,TargetTable.ChangeDateTime),
					ChangeUserID = ISNULL(SourceTable.ChangeUserID,TargetTable.ChangeUserID)
			WHEN NOT MATCHED THEN
				INSERT
					(
						MrpNo,
						CompanyCode,
						WorkCenterCode,
						BasicDate,
						MrpDesc,
						IsUseMrpProdDate,
						MrpProdDate,
						IsRunMrp,
						MrpRunDateTime,
						MrpRunUserID,
						IsFixedMRP,
						MrpFixDateTime,
						MrpFixUserID,
						CreateDateTime,
						CreateUserID
					)
				VALUES
					(
							SourceTable.MrpNo,
							SourceTable.CompanyCode,
							SourceTable.WorkCenterCode,
							SourceTable.BasicDate,
							SourceTable.MrpDesc,
							SourceTable.IsUseMrpProdDate,
							SourceTable.MrpProdDate,
							SourceTable.IsRunMrp,
							SourceTable.MrpRunDateTime,
							SourceTable.MrpRunUserID,
							SourceTable.IsFixedMRP,
							SourceTable.MrpFixDateTime,
							SourceTable.MrpFixUserID,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID
					);


			-- Process Delete Table
            MERGE STB_MrpMaster AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldMrpNo IS NULL THEN MrpNo
							    ELSE OldMrpNo
							END AS OldMrpNo,
							MrpNo,
							CompanyCode,
							WorkCenterCode,
							BasicDate,
							MrpDesc,
							IsUseMrpProdDate,
							MrpProdDate,
							IsRunMrp,
							MrpRunDateTime,
							MrpRunUserID,
							IsFixedMRP,
							MrpFixDateTime,
							MrpFixUserID,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @DeleteTableName , 2)
							WITH  (
										OldMrpNo VARCHAR(20),
										MrpNo VARCHAR(20),
										CompanyCode VARCHAR(20),
										WorkCenterCode VARCHAR(20),
										BasicDate DATETIMEOFFSET,
										MrpDesc NVARCHAR(200),
										IsUseMrpProdDate BIT,
										MrpProdDate DATETIMEOFFSET,
										IsRunMrp bit,
										MrpRunDateTime DATETIMEOFFSET,
										MrpRunUserID VARCHAR(20),
										IsFixedMRP BIT,
										MrpFixDateTime DATETIMEOFFSET,
										MrpFixUserID VARCHAR(20),
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.MrpNo = SourceTable.MrpNo
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
									OldMrpNo,
									MrpNo,
									CompanyCode,
									WorkCenterCode,
									BasicDate,
									MrpDesc,
									IsUseMrpProdDate,
									MrpProdDate,
									IsRunMrp,
									MrpRunDateTime,
									MrpRunUserID,
									IsFixedMRP,
									MrpFixDateTime,
									MrpFixUserID,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID
							FROM
									OPENXML(@idoc , @InsertTableName , 2)
							        WITH  (
											 OldMrpNo VARCHAR(20),
											 MrpNo VARCHAR(20),
											 CompanyCode VARCHAR(20),
											 WorkCenterCode VARCHAR(20),
											 BasicDate DATETIMEOFFSET,
											 MrpDesc NVARCHAR(200),
											 IsUseMrpProdDate BIT,
											 MrpProdDate DATETIMEOFFSET,
											 IsRunMrp bit,
											 MrpRunDateTime DATETIMEOFFSET,
											 MrpRunUserID VARCHAR(20),
											 IsFixedMRP BIT,
											 MrpFixDateTime DATETIMEOFFSET,
											 MrpFixUserID VARCHAR(20),
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											)
							UNION ALL
							SELECT
									'UPDATE' AS IUD_FLAG,
									CASE 
										WHEN OldMrpNo IS NULL THEN MrpNo
										ELSE OldMrpNo
									END AS OldMrpNo,
									MrpNo,
									CompanyCode,
									WorkCenterCode,
									BasicDate,
									MrpDesc,
									IsUseMrpProdDate,
									MrpProdDate,
									IsRunMrp,
									MrpRunDateTime,
									MrpRunUserID,
									IsFixedMRP,
									MrpFixDateTime,
									MrpFixUserID,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID
							FROM
									OPENXML(@idoc , @UpdateTableName , 2)
							        WITH  (
											 OldMrpNo VARCHAR(20),
											 MrpNo VARCHAR(20),
											 CompanyCode VARCHAR(20),
											 WorkCenterCode VARCHAR(20),
											 BasicDate DATETIMEOFFSET,
											 MrpDesc NVARCHAR(200),
											 IsUseMrpProdDate BIT,
											 MrpProdDate DATETIMEOFFSET,
											 IsRunMrp bit,
											 MrpRunDateTime DATETIMEOFFSET,
											 MrpRunUserID VARCHAR(20),
											 IsFixedMRP BIT,
											 MrpFixDateTime DATETIMEOFFSET,
											 MrpFixUserID VARCHAR(20),
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											)
							UNION ALL
							SELECT
									'DELETE' AS IUD_FLAG,
									CASE 
										WHEN OldMrpNo IS NULL THEN MrpNo
										ELSE OldMrpNo
									END AS OldMrpNo,
									MrpNo,
									CompanyCode,
									WorkCenterCode,
									BasicDate,
									MrpDesc,
									IsUseMrpProdDate,
									MrpProdDate,
									IsRunMrp,
									MrpRunDateTime,
									MrpRunUserID,
									IsFixedMRP,
									MrpFixDateTime,
									MrpFixUserID,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID
							FROM
									OPENXML(@idoc , @DeleteTableName , 2)
							        WITH  (
											 OldMrpNo VARCHAR(20),
											 MrpNo VARCHAR(20),
											 CompanyCode VARCHAR(20),
											 WorkCenterCode VARCHAR(20),
											 BasicDate DATETIMEOFFSET,
											 MrpDesc NVARCHAR(200),
											 IsUseMrpProdDate BIT,
											 MrpProdDate DATETIMEOFFSET,
											 IsRunMrp bit,
											 MrpRunDateTime DATETIMEOFFSET,
											 MrpRunUserID VARCHAR(20),
											 IsFixedMRP BIT,
											 MrpFixDateTime DATETIMEOFFSET,
											 MrpFixUserID VARCHAR(20),
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											) 


            OPEN SourceData

            WHILE 1 = 1 BEGIN
                FETCH NEXT FROM SourceData INTO
								 @IUD_FLAG,
								 @OldMrpNo,
								 @MrpNo,
								 @CompanyCode,
								 @WorkCenterCode,
								 @BasicDate,
								 @MrpDesc,
								 @IsUseMrpProdDate,
								 @MrpProdDate,
								 @IsRunMrp,
								 @MrpRunDateTime,
								 @MrpRunUserID,
								 @IsFixedMRP,
								 @MrpFixDateTime,
								 @MrpFixUserID,
								 @CreateDateTime,
								 @CreateUserID,
								 @ChangeDateTime,
								 @ChangeUserID


                IF @@FETCH_STATUS <> 0 BEGIN
					BREAK
				END


				SELECT
						@BefIsFixed = MM.IsFixedMRP
				FROM
						STB_MrpMaster MM
				WHERE
						MM.MrpNo = @MrpNo

				IF ISNULL(@BefIsFixed, CONVERT(BIT, 0)) = CONVERT(BIT, 1)
				BEGIN
						RAISERROR('확정된 문서는 수정할 수 없습니다.', 16, 1, @MrpNo)
						RETURN
				END


                IF @IUD_FLAG = 'INSERT' BEGIN

                    IF EXISTS (SELECT 1 FROM STB_MrpMaster WHERE MrpNo = @MrpNo) BEGIN
						RAISERROR('Duplicate Data : KeyField = %s', 16, 1, @MrpNo)
					END

                    IF @IsAutoKey = 1 BEGIN
						EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_MrpMaster', @MrpNo OUTPUT
                    END

                    INSERT INTO STB_MrpMaster
						(
						    MrpNo,
						    CompanyCode,
						    WorkCenterCode,
						    BasicDate,
						    MrpDesc,
						    IsUseMrpProdDate,
						    MrpProdDate,
						    IsRunMrp,
						    MrpRunDateTime,
						    MrpRunUserID,
						    IsFixedMRP,
							IsCancel,
						    MrpFixDateTime,
						    MrpFixUserID,
						    CreateDateTime,
						    CreateUserID,
						    ChangeDateTime,
						    ChangeUserID
						)
						VALUES
						(
						    @MrpNo,
						    @CompanyCode,
						    @WorkCenterCode,
						    @BasicDate,
						    @MrpDesc,
						    @IsUseMrpProdDate,
						    @MrpProdDate,
						    @IsRunMrp,
						    @MrpRunDateTime,
						    @MrpRunUserID,
						    @IsFixedMRP,
							0,
						    @MrpFixDateTime,
						    @MrpFixUserID,
						    GETDATE(),
						    @pProcessUserID,
						    @ChangeDateTime,
						    @ChangeUserID
						)

				END ELSE IF @IUD_FLAG = 'UPDATE' BEGIN




                    UPDATE STB_MrpMaster
						SET
						    MrpNo =   ISNULL(@MrpNo,MrpNo),
						    CompanyCode =   ISNULL(@CompanyCode,CompanyCode),
						    WorkCenterCode =   ISNULL(@WorkCenterCode,WorkCenterCode),
						    BasicDate =   ISNULL(@BasicDate,BasicDate),
						    MrpDesc =   ISNULL(@MrpDesc,MrpDesc),
						    IsUseMrpProdDate =   ISNULL(@IsUseMrpProdDate,IsUseMrpProdDate),
						    MrpProdDate =   ISNULL(@MrpProdDate,MrpProdDate),
						    IsRunMrp =   ISNULL(@IsRunMrp,IsRunMrp),
						    MrpRunDateTime =   ISNULL(@MrpRunDateTime,MrpRunDateTime),
						    MrpRunUserID =   ISNULL(@MrpRunUserID,MrpRunUserID),
						    IsFixedMRP =   ISNULL(@IsFixedMRP,IsFixedMRP),
						    MrpFixDateTime =   ISNULL(@MrpFixDateTime,MrpFixDateTime),
						    MrpFixUserID =   ISNULL(@MrpFixUserID,MrpFixUserID),
						    CreateDateTime =   ISNULL(@CreateDateTime,CreateDateTime),
						    CreateUserID =   ISNULL(@CreateUserID,CreateUserID),
						    ChangeDateTime = GETDATE(),
						    ChangeUserID = @pProcessUserID
						WHERE
						    MrpNo = @OldMrpNo
                END ELSE IF @IUD_FLAG = 'DELETE' BEGIN
                    DELETE FROM STB_MrpMaster
						WHERE
						    MrpNo = @MrpNo
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

