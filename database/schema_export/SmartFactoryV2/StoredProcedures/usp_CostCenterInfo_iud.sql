-- Procedure: usp_CostCenterInfo_iud

-- =============================================
-- Author:	    Park Jong Seob(jspark@awoo.co.kr)
-- Create date: 2018-08-06
-- Browsable : true
-- Group : 품질관리
-- Description:	비용처리부서정보를 저장합니다.
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_CostCenterInfo_iud]
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
  DECLARE @OldCompanyCode VARCHAR(20)
  DECLARE @OldWorkCenterCode VARCHAR(20)
  DECLARE @OldCostCenterCode VARCHAR(20)
  DECLARE @CompanyCode VARCHAR(20)
  DECLARE @WorkCenterCode VARCHAR(20)
  DECLARE @CostCenterCode VARCHAR(20)
  DECLARE @CostCenterName NVARCHAR(100)
  DECLARE @IsUsed BIT
  DECLARE @CreateDateTime DATETIME
  DECLARE @CreateUserID VARCHAR(20)
  DECLARE @ChangeDateTime DATETIME
  DECLARE @ChangeUserID VARCHAR(20)


	DECLARE @iDoc INT

    EXEC SmartFramework.dbo.usp_GetSerialRule 
			@pTableName = 'STB_CostCenterInfo',
			@pIsAutoKey = @IsAutoKey OUTPUT,
			@pIsLoopIUD = @IsLoopIUD OUTPUT,
			@pPrefixData = @PrefixString OUTPUT,
			@pSerialLen = @SerialLen OUTPUT
    
    IF @IsAutoKey = 0 AND @IsLoopIUD = 0 BEGIN
   
	    EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
	
	    BEGIN TRY
			-- Process Insert Table
            MERGE STB_CostCenterInfo AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldCompanyCode IS NULL THEN CompanyCode
							    ELSE OldCompanyCode
							END AS OldCompanyCode,
							CASE
							    WHEN OldWorkCenterCode IS NULL THEN WorkCenterCode
							    ELSE OldWorkCenterCode
							END AS OldWorkCenterCode,
							CASE
							    WHEN OldCostCenterCode IS NULL THEN CostCenterCode
							    ELSE OldCostCenterCode
							END AS OldCostCenterCode,
							CompanyCode,
							WorkCenterCode,
							CostCenterCode,
							CostCenterName,
							IsUsed,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @InsertTableName , 2)
							WITH  (
										OldCompanyCode VARCHAR(20),
										OldWorkCenterCode VARCHAR(20),
										OldCostCenterCode VARCHAR(20),
										CompanyCode VARCHAR(20),
										WorkCenterCode VARCHAR(20),
										CostCenterCode VARCHAR(20),
										CostCenterName NVARCHAR(100),
										IsUsed BIT,
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.CompanyCode = SourceTable.CompanyCode AND
					TargetTable.WorkCenterCode = SourceTable.WorkCenterCode AND
					TargetTable.CostCenterCode = SourceTable.CostCenterCode
				)

			WHEN MATCHED THEN
				UPDATE SET
					CompanyCode = ISNULL(SourceTable.CompanyCode,TargetTable.CompanyCode),
					WorkCenterCode = ISNULL(SourceTable.WorkCenterCode,TargetTable.WorkCenterCode),
					CostCenterCode = ISNULL(SourceTable.CostCenterCode,TargetTable.CostCenterCode),
					CostCenterName = ISNULL(SourceTable.CostCenterName,TargetTable.CostCenterName),
					IsUsed = ISNULL(SourceTable.IsUsed,TargetTable.IsUsed),
					ChangeDateTime = ISNULL(SourceTable.ChangeDateTime,TargetTable.ChangeDateTime),
					ChangeUserID = ISNULL(SourceTable.ChangeUserID,TargetTable.ChangeUserID)
			WHEN NOT MATCHED THEN
				INSERT
					(
						CompanyCode,
						WorkCenterCode,
						CostCenterCode,
						CostCenterName,
						IsUsed,
						CreateDateTime,
						CreateUserID
					)
				VALUES
					(
							SourceTable.CompanyCode,
							SourceTable.WorkCenterCode,
							SourceTable.CostCenterCode,
							SourceTable.CostCenterName,
							SourceTable.IsUsed,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID
					);


			-- Process Update Table
            MERGE STB_CostCenterInfo AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldCompanyCode IS NULL THEN CompanyCode
							    ELSE OldCompanyCode
							END AS OldCompanyCode,
							CASE
							    WHEN OldWorkCenterCode IS NULL THEN WorkCenterCode
							    ELSE OldWorkCenterCode
							END AS OldWorkCenterCode,
							CASE
							    WHEN OldCostCenterCode IS NULL THEN CostCenterCode
							    ELSE OldCostCenterCode
							END AS OldCostCenterCode,
							CompanyCode,
							WorkCenterCode,
							CostCenterCode,
							CostCenterName,
							IsUsed,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @UpdateTableName , 2)
							WITH  (
										OldCompanyCode VARCHAR(20),
										OldWorkCenterCode VARCHAR(20),
										OldCostCenterCode VARCHAR(20),
										CompanyCode VARCHAR(20),
										WorkCenterCode VARCHAR(20),
										CostCenterCode VARCHAR(20),
										CostCenterName NVARCHAR(100),
										IsUsed BIT,
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.CompanyCode = SourceTable.OldCompanyCode AND
					TargetTable.WorkCenterCode = SourceTable.OldWorkCenterCode AND
					TargetTable.CostCenterCode = SourceTable.OldCostCenterCode
				)

			WHEN MATCHED THEN
				UPDATE SET
					CompanyCode = ISNULL(SourceTable.CompanyCode,TargetTable.CompanyCode),
					WorkCenterCode = ISNULL(SourceTable.WorkCenterCode,TargetTable.WorkCenterCode),
					CostCenterCode = ISNULL(SourceTable.CostCenterCode,TargetTable.CostCenterCode),
					CostCenterName = ISNULL(SourceTable.CostCenterName,TargetTable.CostCenterName),
					IsUsed = ISNULL(SourceTable.IsUsed,TargetTable.IsUsed),
					ChangeDateTime = ISNULL(SourceTable.ChangeDateTime,TargetTable.ChangeDateTime),
					ChangeUserID = ISNULL(SourceTable.ChangeUserID,TargetTable.ChangeUserID)
			WHEN NOT MATCHED THEN
				INSERT
					(
						CompanyCode,
						WorkCenterCode,
						CostCenterCode,
						CostCenterName,
						IsUsed,
						CreateDateTime,
						CreateUserID
					)
				VALUES
					(
							SourceTable.CompanyCode,
							SourceTable.WorkCenterCode,
							SourceTable.CostCenterCode,
							SourceTable.CostCenterName,
							SourceTable.IsUsed,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID
					);


			-- Process Delete Table
            MERGE STB_CostCenterInfo AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldCompanyCode IS NULL THEN CompanyCode
							    ELSE OldCompanyCode
							END AS OldCompanyCode,
							CASE
							    WHEN OldWorkCenterCode IS NULL THEN WorkCenterCode
							    ELSE OldWorkCenterCode
							END AS OldWorkCenterCode,
							CASE
							    WHEN OldCostCenterCode IS NULL THEN CostCenterCode
							    ELSE OldCostCenterCode
							END AS OldCostCenterCode,
							CompanyCode,
							WorkCenterCode,
							CostCenterCode,
							CostCenterName,
							IsUsed,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @DeleteTableName , 2)
							WITH  (
										OldCompanyCode VARCHAR(20),
										OldWorkCenterCode VARCHAR(20),
										OldCostCenterCode VARCHAR(20),
										CompanyCode VARCHAR(20),
										WorkCenterCode VARCHAR(20),
										CostCenterCode VARCHAR(20),
										CostCenterName NVARCHAR(100),
										IsUsed BIT,
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.CompanyCode = SourceTable.CompanyCode AND
					TargetTable.WorkCenterCode = SourceTable.WorkCenterCode AND
					TargetTable.CostCenterCode = SourceTable.CostCenterCode
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
									OldCompanyCode,
									OldWorkCenterCode,
									OldCostCenterCode,
									CompanyCode,
									WorkCenterCode,
									CostCenterCode,
									CostCenterName,
									IsUsed,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID
							FROM
									OPENXML(@idoc , @InsertTableName , 2)
							        WITH  (
											 OldCompanyCode VARCHAR(20),
											 OldWorkCenterCode VARCHAR(20),
											 OldCostCenterCode VARCHAR(20),
											 CompanyCode VARCHAR(20),
											 WorkCenterCode VARCHAR(20),
											 CostCenterCode VARCHAR(20),
											 CostCenterName NVARCHAR(100),
											 IsUsed BIT,
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											)
							UNION ALL
							SELECT
									'UPDATE' AS IUD_FLAG,
									CASE 
										WHEN OldCompanyCode IS NULL THEN CompanyCode
										ELSE OldCompanyCode
									END AS OldCompanyCode,
									CASE 
										WHEN OldWorkCenterCode IS NULL THEN WorkCenterCode
										ELSE OldWorkCenterCode
									END AS OldWorkCenterCode,
									CASE 
										WHEN OldCostCenterCode IS NULL THEN CostCenterCode
										ELSE OldCostCenterCode
									END AS OldCostCenterCode,
									CompanyCode,
									WorkCenterCode,
									CostCenterCode,
									CostCenterName,
									IsUsed,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID
							FROM
									OPENXML(@idoc , @UpdateTableName , 2)
							        WITH  (
											 OldCompanyCode VARCHAR(20),
											 OldWorkCenterCode VARCHAR(20),
											 OldCostCenterCode VARCHAR(20),
											 CompanyCode VARCHAR(20),
											 WorkCenterCode VARCHAR(20),
											 CostCenterCode VARCHAR(20),
											 CostCenterName NVARCHAR(100),
											 IsUsed BIT,
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											)
							UNION ALL
							SELECT
									'DELETE' AS IUD_FLAG,
									CASE 
										WHEN OldCompanyCode IS NULL THEN CompanyCode
										ELSE OldCompanyCode
									END AS OldCompanyCode,
									CASE 
										WHEN OldWorkCenterCode IS NULL THEN WorkCenterCode
										ELSE OldWorkCenterCode
									END AS OldWorkCenterCode,
									CASE 
										WHEN OldCostCenterCode IS NULL THEN CostCenterCode
										ELSE OldCostCenterCode
									END AS OldCostCenterCode,
									CompanyCode,
									WorkCenterCode,
									CostCenterCode,
									CostCenterName,
									IsUsed,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID
							FROM
									OPENXML(@idoc , @DeleteTableName , 2)
							        WITH  (
											 OldCompanyCode VARCHAR(20),
											 OldWorkCenterCode VARCHAR(20),
											 OldCostCenterCode VARCHAR(20),
											 CompanyCode VARCHAR(20),
											 WorkCenterCode VARCHAR(20),
											 CostCenterCode VARCHAR(20),
											 CostCenterName NVARCHAR(100),
											 IsUsed BIT,
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											) 


            OPEN SourceData

            WHILE 1 = 1 BEGIN
                FETCH NEXT FROM SourceData INTO
								 @IUD_FLAG,
								 @OldCompanyCode,
								 @OldWorkCenterCode,
								 @OldCostCenterCode,
								 @CompanyCode,
								 @WorkCenterCode,
								 @CostCenterCode,
								 @CostCenterName,
								 @IsUsed,
								 @CreateDateTime,
								 @CreateUserID,
								 @ChangeDateTime,
								 @ChangeUserID


                IF @@FETCH_STATUS <> 0 BEGIN
					BREAK
				END
                IF @IUD_FLAG = 'INSERT' BEGIN

                    IF EXISTS (SELECT 1 FROM STB_CostCenterInfo WHERE CompanyCode = @CompanyCode AND WorkCenterCode = @WorkCenterCode AND CostCenterCode = @CostCenterCode) BEGIN
						RAISERROR('Duplicate Data : KeyField = %s', 16, 1, @CompanyCode)
					END

                    IF @IsAutoKey = 1 BEGIN
                        EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_CostCenterInfo',@CompanyCode OUTPUT
                    END

                    INSERT INTO STB_CostCenterInfo
						(
						    CompanyCode,
						    WorkCenterCode,
						    CostCenterCode,
						    CostCenterName,
						    IsUsed,
						    CreateDateTime,
						    CreateUserID,
						    ChangeDateTime,
						    ChangeUserID
						)
						VALUES
						(
						    @CompanyCode,
						    @WorkCenterCode,
						    @CostCenterCode,
						    @CostCenterName,
						    @IsUsed,
						    GETDATE(),
						    @pProcessUserID,
						    @ChangeDateTime,
						    @ChangeUserID
						)

				END ELSE IF @IUD_FLAG = 'UPDATE' BEGIN
                    UPDATE STB_CostCenterInfo
						SET
						    CompanyCode =   ISNULL(@CompanyCode,CompanyCode),
						    WorkCenterCode =   ISNULL(@WorkCenterCode,WorkCenterCode),
						    CostCenterCode =   ISNULL(@CostCenterCode,CostCenterCode),
						    CostCenterName =   ISNULL(@CostCenterName,CostCenterName),
						    IsUsed =   ISNULL(@IsUsed,IsUsed),
						    CreateDateTime =   ISNULL(@CreateDateTime,CreateDateTime),
						    CreateUserID =   ISNULL(@CreateUserID,CreateUserID),
						    ChangeDateTime = GETDATE(),
						    ChangeUserID = @pProcessUserID
						WHERE
						    CompanyCode = @OldCompanyCode AND
						    WorkCenterCode = @OldWorkCenterCode AND
						    CostCenterCode = @OldCostCenterCode
                END ELSE IF @IUD_FLAG = 'DELETE' BEGIN
                    DELETE FROM STB_CostCenterInfo
						WHERE
						    CompanyCode = @OldCompanyCode AND
						    WorkCenterCode = @OldWorkCenterCode AND
						    CostCenterCode = @OldCostCenterCode
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

GO

