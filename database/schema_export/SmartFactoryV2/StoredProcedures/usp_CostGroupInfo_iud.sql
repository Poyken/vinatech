-- Procedure: usp_CostGroupInfo_iud

-- =============================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Create date: 2020-03-20
-- Browsable : true
-- Group : 생산관리
-- Description:	
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_CostGroupInfo_iud]
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
  DECLARE @OldCostGroupCode VARCHAR(20)
  DECLARE @CostGroupCode VARCHAR(20)
  DECLARE @CompanyCode VARCHAR(20)
  DECLARE @WorkCenterCode VARCHAR(20)
  DECLARE @CostGroupName VARCHAR(100)
  DECLARE @RouteCode VARCHAR(20)
  DECLARE @IsUsed BIT
  DECLARE @CreateDateTime DATETIME
  DECLARE @CreateUserID VARCHAR(20)
  DECLARE @ChangeDateTime DATETIME
  DECLARE @ChangeUserID VARCHAR(20)
  DECLARE @IsProdWorkerGroup BIT
  DECLARE @LineCode VARCHAR(20)


	DECLARE @iDoc INT

    EXEC SmartFramework.dbo.usp_GetSerialRule 
			@pTableName = 'STB_CostGroupInfo',
			@pIsAutoKey = @IsAutoKey OUTPUT,
			@pIsLoopIUD = @IsLoopIUD OUTPUT,
			@pPrefixData = @PrefixString OUTPUT,
			@pSerialLen = @SerialLen OUTPUT
    
    IF @IsAutoKey = 0 AND @IsLoopIUD = 0 BEGIN
   
	    EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
	
	    BEGIN TRY
			-- Process Insert Table
            MERGE STB_CostGroupInfo AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldCostGroupCode IS NULL THEN CostGroupCode
							    ELSE OldCostGroupCode
							END AS OldCostGroupCode,
							CostGroupCode,
							CompanyCode,
							WorkCenterCode,
							CostGroupName,
							RouteCode,
							IsUsed,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID,
							IsProdWorkerGroup,
							LineCode
					FROM
							OPENXML(@idoc , @InsertTableName , 2)
							WITH  (
										OldCostGroupCode VARCHAR(20),
										CostGroupCode VARCHAR(20),
										CompanyCode VARCHAR(20),
										WorkCenterCode VARCHAR(20),
										CostGroupName VARCHAR(100),
										RouteCode VARCHAR(20),
										IsUsed BIT,
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20),
										IsProdWorkerGroup BIT,
										LineCode VARCHAR(20)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.CostGroupCode = SourceTable.CostGroupCode
				)

			WHEN MATCHED THEN
				UPDATE SET
					CostGroupCode = ISNULL(SourceTable.CostGroupCode,TargetTable.CostGroupCode),
					CompanyCode = ISNULL(SourceTable.CompanyCode,TargetTable.CompanyCode),
					WorkCenterCode = ISNULL(SourceTable.WorkCenterCode,TargetTable.WorkCenterCode),
					CostGroupName = ISNULL(SourceTable.CostGroupName,TargetTable.CostGroupName),
					RouteCode = ISNULL(SourceTable.RouteCode,TargetTable.RouteCode),
					IsUsed = ISNULL(SourceTable.IsUsed,TargetTable.IsUsed),
					ChangeDateTime = ISNULL(SourceTable.ChangeDateTime,TargetTable.ChangeDateTime),
					ChangeUserID = ISNULL(SourceTable.ChangeUserID,TargetTable.ChangeUserID),
					IsProdWorkerGroup = ISNULL(SourceTable.IsProdWorkerGroup,TargetTable.IsProdWorkerGroup),
					LineCode = ISNULL(SourceTable.LineCode,TargetTable.LineCode)
			WHEN NOT MATCHED THEN
				INSERT
					(
						CostGroupCode,
						CompanyCode,
						WorkCenterCode,
						CostGroupName,
						RouteCode,
						IsUsed,
						CreateDateTime,
						CreateUserID,
						IsProdWorkerGroup,
						LineCode
					)
				VALUES
					(
							SourceTable.CostGroupCode,
							SourceTable.CompanyCode,
							SourceTable.WorkCenterCode,
							SourceTable.CostGroupName,
							SourceTable.RouteCode,
							SourceTable.IsUsed,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID,
							SourceTable.IsProdWorkerGroup,
							SourceTable.LineCode
					);


			-- Process Update Table
            MERGE STB_CostGroupInfo AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldCostGroupCode IS NULL THEN CostGroupCode
							    ELSE OldCostGroupCode
							END AS OldCostGroupCode,
							CostGroupCode,
							CompanyCode,
							WorkCenterCode,
							CostGroupName,
							RouteCode,
							IsUsed,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID,
							IsProdWorkerGroup,
							LineCode
					FROM
							OPENXML(@idoc , @UpdateTableName , 2)
							WITH  (
										OldCostGroupCode VARCHAR(20),
										CostGroupCode VARCHAR(20),
										CompanyCode VARCHAR(20),
										WorkCenterCode VARCHAR(20),
										CostGroupName VARCHAR(100),
										RouteCode VARCHAR(20),
										IsUsed BIT,
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20),
										IsProdWorkerGroup BIT,
										LineCode VARCHAR(20)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.CostGroupCode = SourceTable.OldCostGroupCode
				)

			WHEN MATCHED THEN
				UPDATE SET
					CostGroupCode = ISNULL(SourceTable.CostGroupCode,TargetTable.CostGroupCode),
					CompanyCode = ISNULL(SourceTable.CompanyCode,TargetTable.CompanyCode),
					WorkCenterCode = ISNULL(SourceTable.WorkCenterCode,TargetTable.WorkCenterCode),
					CostGroupName = ISNULL(SourceTable.CostGroupName,TargetTable.CostGroupName),
					RouteCode = ISNULL(SourceTable.RouteCode,TargetTable.RouteCode),
					IsUsed = ISNULL(SourceTable.IsUsed,TargetTable.IsUsed),
					ChangeDateTime = ISNULL(SourceTable.ChangeDateTime,TargetTable.ChangeDateTime),
					ChangeUserID = ISNULL(SourceTable.ChangeUserID,TargetTable.ChangeUserID),
					IsProdWorkerGroup = ISNULL(SourceTable.IsProdWorkerGroup,TargetTable.IsProdWorkerGroup),
					LineCode = ISNULL(SourceTable.LineCode,TargetTable.LineCode)
			WHEN NOT MATCHED THEN
				INSERT
					(
						CostGroupCode,
						CompanyCode,
						WorkCenterCode,
						CostGroupName,
						RouteCode,
						IsUsed,
						CreateDateTime,
						CreateUserID,
						IsProdWorkerGroup,
						LineCode
					)
				VALUES
					(
							SourceTable.CostGroupCode,
							SourceTable.CompanyCode,
							SourceTable.WorkCenterCode,
							SourceTable.CostGroupName,
							SourceTable.RouteCode,
							SourceTable.IsUsed,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID,
							SourceTable.IsProdWorkerGroup,
							SourceTable.LineCode
					);


			-- Process Delete Table
            MERGE STB_CostGroupInfo AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldCostGroupCode IS NULL THEN CostGroupCode
							    ELSE OldCostGroupCode
							END AS OldCostGroupCode,
							CostGroupCode,
							CompanyCode,
							WorkCenterCode,
							CostGroupName,
							RouteCode,
							IsUsed,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID,
							IsProdWorkerGroup,
							LineCode
					FROM
							OPENXML(@idoc , @DeleteTableName , 2)
							WITH  (
										OldCostGroupCode VARCHAR(20),
										CostGroupCode VARCHAR(20),
										CompanyCode VARCHAR(20),
										WorkCenterCode VARCHAR(20),
										CostGroupName VARCHAR(100),
										RouteCode VARCHAR(20),
										IsUsed BIT,
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20),
										IsProdWorkerGroup BIT,
										LineCode VARCHAR(20)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.CostGroupCode = SourceTable.CostGroupCode
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
									OldCostGroupCode,
									CostGroupCode,
									CompanyCode,
									WorkCenterCode,
									CostGroupName,
									RouteCode,
									IsUsed,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID,
									IsProdWorkerGroup,
									LineCode
							FROM
									OPENXML(@idoc , @InsertTableName , 2)
							        WITH  (
											 OldCostGroupCode VARCHAR(20),
											 CostGroupCode VARCHAR(20),
											 CompanyCode VARCHAR(20),
											 WorkCenterCode VARCHAR(20),
											 CostGroupName VARCHAR(100),
											 RouteCode VARCHAR(20),
											 IsUsed BIT,
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20),
											 IsProdWorkerGroup BIT,
											 LineCode VARCHAR(20)
											)
							UNION ALL
							SELECT
									'UPDATE' AS IUD_FLAG,
									CASE 
										WHEN OldCostGroupCode IS NULL THEN CostGroupCode
										ELSE OldCostGroupCode
									END AS OldCostGroupCode,
									CostGroupCode,
									CompanyCode,
									WorkCenterCode,
									CostGroupName,
									RouteCode,
									IsUsed,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID,
									IsProdWorkerGroup,
									LineCode
							FROM
									OPENXML(@idoc , @UpdateTableName , 2)
							        WITH  (
											 OldCostGroupCode VARCHAR(20),
											 CostGroupCode VARCHAR(20),
											 CompanyCode VARCHAR(20),
											 WorkCenterCode VARCHAR(20),
											 CostGroupName VARCHAR(100),
											 RouteCode VARCHAR(20),
											 IsUsed BIT,
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20),
											 IsProdWorkerGroup BIT,
											 LineCode VARCHAR(20)
											)
							UNION ALL
							SELECT
									'DELETE' AS IUD_FLAG,
									CASE 
										WHEN OldCostGroupCode IS NULL THEN CostGroupCode
										ELSE OldCostGroupCode
									END AS OldCostGroupCode,
									CostGroupCode,
									CompanyCode,
									WorkCenterCode,
									CostGroupName,
									RouteCode,
									IsUsed,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID,
									IsProdWorkerGroup,
									LineCode
							FROM
									OPENXML(@idoc , @DeleteTableName , 2)
							        WITH  (
											 OldCostGroupCode VARCHAR(20),
											 CostGroupCode VARCHAR(20),
											 CompanyCode VARCHAR(20),
											 WorkCenterCode VARCHAR(20),
											 CostGroupName VARCHAR(100),
											 RouteCode VARCHAR(20),
											 IsUsed BIT,
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20),
											 IsProdWorkerGroup BIT,
											 LineCode VARCHAR(20)
											) 


            OPEN SourceData

            WHILE 1 = 1 BEGIN
                FETCH NEXT FROM SourceData INTO
								 @IUD_FLAG,
								 @OldCostGroupCode,
								 @CostGroupCode,
								 @CompanyCode,
								 @WorkCenterCode,
								 @CostGroupName,
								 @RouteCode,
								 @IsUsed,
								 @CreateDateTime,
								 @CreateUserID,
								 @ChangeDateTime,
								 @ChangeUserID,
								 @IsProdWorkerGroup,
								 @LineCode


                IF @@FETCH_STATUS <> 0 BEGIN
					BREAK
				END
                IF @IUD_FLAG = 'INSERT' BEGIN

                    IF EXISTS (SELECT 1 FROM STB_CostGroupInfo WHERE CostGroupCode = @CostGroupCode) BEGIN
						RAISERROR('Duplicate Data : KeyField = %s', 16, 1, @CostGroupCode)
					END

                    IF @IsAutoKey = 1 BEGIN
                        EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_CostGroupInfo',@CostGroupCode OUTPUT
                    END

                    INSERT INTO STB_CostGroupInfo
						(
						    CostGroupCode,
						    CompanyCode,
						    WorkCenterCode,
						    CostGroupName,
						    RouteCode,
						    IsUsed,
						    CreateDateTime,
						    CreateUserID,
						    ChangeDateTime,
						    ChangeUserID,
						    IsProdWorkerGroup,
						    LineCode
						)
						VALUES
						(
						    @CostGroupCode,
						    @CompanyCode,
						    @WorkCenterCode,
						    @CostGroupName,
						    @RouteCode,
						    @IsUsed,
						    GETDATE(),
						    @pProcessUserID,
						    @ChangeDateTime,
						    @ChangeUserID,
						    @IsProdWorkerGroup,
						    @LineCode
						)

				END ELSE IF @IUD_FLAG = 'UPDATE' BEGIN
                    UPDATE STB_CostGroupInfo
						SET
						    CostGroupCode =   ISNULL(@CostGroupCode,CostGroupCode),
						    CompanyCode =   ISNULL(@CompanyCode,CompanyCode),
						    WorkCenterCode =   ISNULL(@WorkCenterCode,WorkCenterCode),
						    CostGroupName =   ISNULL(@CostGroupName,CostGroupName),
						    RouteCode =   ISNULL(@RouteCode,RouteCode),
						    IsUsed =   ISNULL(@IsUsed,IsUsed),
						    CreateDateTime =   ISNULL(@CreateDateTime,CreateDateTime),
						    CreateUserID =   ISNULL(@CreateUserID,CreateUserID),
						    ChangeDateTime = GETDATE(),
						    ChangeUserID = @pProcessUserID,
						    IsProdWorkerGroup =   ISNULL(@IsProdWorkerGroup,IsProdWorkerGroup),
						    LineCode =   ISNULL(@LineCode,LineCode)
						WHERE
						    CostGroupCode = @OldCostGroupCode
                END ELSE IF @IUD_FLAG = 'DELETE' BEGIN
                    DELETE FROM STB_CostGroupInfo
						WHERE
						    CostGroupCode = @OldCostGroupCode
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

