

-- =============================================
-- Author:	    Jeon Gyeong Ho(khjun@awoo.co.kr)
-- Create date: 2018-09-17
-- Browsable : true
-- Group : 재고관리
-- Description:	
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_StocktakingDoc_iud]
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
  DECLARE @OldStocktakingDocNo VARCHAR(20)
  DECLARE @StocktakingDocNo VARCHAR(20)
  DECLARE @CompanyCode VARCHAR(20)
  DECLARE @WorkCenterCode VARCHAR(20)
  DECLARE @MaterialWarehouseCode VARCHAR(20)
  DECLARE @MaterialCode VARCHAR(50)
  DECLARE @BasicDate DATE
  DECLARE @StocktakingDesc NVARCHAR(200)
  DECLARE @IsFinish BIT
  DECLARE @GIDocNo VARCHAR(20)
  DECLARE @GRDocNo VARCHAR(20)
  DECLARE @CreateDateTime DATETIME
  DECLARE @CreateUserID VARCHAR(20)
  DECLARE @ChangeDateTime DATETIME
  DECLARE @ChangeUserID VARCHAR(20)
  DECLARE @MLExtText01 NVARCHAR(MAX)


	DECLARE @iDoc INT

    EXEC SmartFramework.dbo.usp_GetSerialRule 
			@pTableName = 'STB_StocktakingDoc',
			@pIsAutoKey = @IsAutoKey OUTPUT,
			@pIsLoopIUD = @IsLoopIUD OUTPUT,
			@pPrefixData = @PrefixString OUTPUT,
			@pSerialLen = @SerialLen OUTPUT
    
    IF @IsAutoKey = 0 AND @IsLoopIUD = 0 BEGIN
   
	    EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
	
	    BEGIN TRY
			-- Process Insert Table
            MERGE STB_StocktakingDoc AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldStocktakingDocNo IS NULL THEN StocktakingDocNo
							    ELSE OldStocktakingDocNo
							END AS OldStocktakingDocNo,
							StocktakingDocNo,
							CompanyCode,
							WorkCenterCode,
							MaterialWarehouseCode,
							MaterialCode,
							BasicDate,
							StocktakingDesc,
							IsFinish,
							GIDocNo,
							GRDocNo,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID,
							MLExtText01
					FROM
							OPENXML(@idoc , @InsertTableName , 2)
							WITH  (
										OldStocktakingDocNo VARCHAR(20),
										StocktakingDocNo VARCHAR(20),
										CompanyCode VARCHAR(20),
										WorkCenterCode VARCHAR(20),
										MaterialWarehouseCode VARCHAR(20),
										MaterialCode VARCHAR(50),
										BasicDate DATETIMEOFFSET,
										StocktakingDesc NVARCHAR(200),
										IsFinish BIT,
										GIDocNo VARCHAR(20),
										GRDocNo VARCHAR(20),
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20),
										MLExtText01 NVARCHAR(MAX)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.StocktakingDocNo = SourceTable.StocktakingDocNo
				)

			WHEN MATCHED THEN
				UPDATE SET
					StocktakingDocNo = ISNULL(SourceTable.StocktakingDocNo,TargetTable.StocktakingDocNo),
					CompanyCode = ISNULL(SourceTable.CompanyCode,TargetTable.CompanyCode),
					WorkCenterCode = ISNULL(SourceTable.WorkCenterCode,TargetTable.WorkCenterCode),
					MaterialWarehouseCode = ISNULL(SourceTable.MaterialWarehouseCode,TargetTable.MaterialWarehouseCode),
					MaterialCode = ISNULL(SourceTable.MaterialCode,TargetTable.MaterialCode),
					BasicDate = ISNULL(SourceTable.BasicDate,TargetTable.BasicDate),
					StocktakingDesc = ISNULL(SourceTable.StocktakingDesc,TargetTable.StocktakingDesc),
					IsFinish = ISNULL(SourceTable.IsFinish,TargetTable.IsFinish),
					GIDocNo = ISNULL(SourceTable.GIDocNo,TargetTable.GIDocNo),
					GRDocNo = ISNULL(SourceTable.GRDocNo,TargetTable.GRDocNo),
					ChangeDateTime = ISNULL(SourceTable.ChangeDateTime,TargetTable.ChangeDateTime),
					ChangeUserID = ISNULL(SourceTable.ChangeUserID,TargetTable.ChangeUserID),
					MLExtText01 = ISNULL(SourceTable.MLExtText01,TargetTable.MLExtText01)
			WHEN NOT MATCHED THEN
				INSERT
					(
						StocktakingDocNo,
						CompanyCode,
						WorkCenterCode,
						MaterialWarehouseCode,
						MaterialCode,
						BasicDate,
						StocktakingDesc,
						IsFinish,
						GIDocNo,
						GRDocNo,
						CreateDateTime,
						CreateUserID,
						MLExtText01
					)
				VALUES
					(
							SourceTable.StocktakingDocNo,
							SourceTable.CompanyCode,
							SourceTable.WorkCenterCode,
							SourceTable.MaterialWarehouseCode,
							SourceTable.MaterialCode,
							SourceTable.BasicDate,
							SourceTable.StocktakingDesc,
							SourceTable.IsFinish,
							SourceTable.GIDocNo,
							SourceTable.GRDocNo,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID,
							SourceTable.MLExtText01
					);


			-- Process Update Table
            MERGE STB_StocktakingDoc AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldStocktakingDocNo IS NULL THEN StocktakingDocNo
							    ELSE OldStocktakingDocNo
							END AS OldStocktakingDocNo,
							StocktakingDocNo,
							CompanyCode,
							WorkCenterCode,
							MaterialWarehouseCode,
							MaterialCode,
							BasicDate,
							StocktakingDesc,
							IsFinish,
							GIDocNo,
							GRDocNo,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID,
							MLExtText01
					FROM
							OPENXML(@idoc , @UpdateTableName , 2)
							WITH  (
										OldStocktakingDocNo VARCHAR(20),
										StocktakingDocNo VARCHAR(20),
										CompanyCode VARCHAR(20),
										WorkCenterCode VARCHAR(20),
										MaterialWarehouseCode VARCHAR(20),
										MaterialCode VARCHAR(50),
										BasicDate DATETIMEOFFSET,
										StocktakingDesc NVARCHAR(200),
										IsFinish BIT,
										GIDocNo VARCHAR(20),
										GRDocNo VARCHAR(20),
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20),
										MLExtText01 NVARCHAR(MAX)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.StocktakingDocNo = SourceTable.OldStocktakingDocNo
				)

			WHEN MATCHED THEN
				UPDATE SET
					StocktakingDocNo = ISNULL(SourceTable.StocktakingDocNo,TargetTable.StocktakingDocNo),
					CompanyCode = ISNULL(SourceTable.CompanyCode,TargetTable.CompanyCode),
					WorkCenterCode = ISNULL(SourceTable.WorkCenterCode,TargetTable.WorkCenterCode),
					MaterialWarehouseCode = ISNULL(SourceTable.MaterialWarehouseCode,TargetTable.MaterialWarehouseCode),
					MaterialCode = ISNULL(SourceTable.MaterialCode,TargetTable.MaterialCode),
					BasicDate = ISNULL(SourceTable.BasicDate,TargetTable.BasicDate),
					StocktakingDesc = ISNULL(SourceTable.StocktakingDesc,TargetTable.StocktakingDesc),
					IsFinish = ISNULL(SourceTable.IsFinish,TargetTable.IsFinish),
					GIDocNo = ISNULL(SourceTable.GIDocNo,TargetTable.GIDocNo),
					GRDocNo = ISNULL(SourceTable.GRDocNo,TargetTable.GRDocNo),
					ChangeDateTime = ISNULL(SourceTable.ChangeDateTime,TargetTable.ChangeDateTime),
					ChangeUserID = ISNULL(SourceTable.ChangeUserID,TargetTable.ChangeUserID),
					MLExtText01 = ISNULL(SourceTable.MLExtText01,TargetTable.MLExtText01)
			WHEN NOT MATCHED THEN
				INSERT
					(
						StocktakingDocNo,
						CompanyCode,
						WorkCenterCode,
						MaterialWarehouseCode,
						MaterialCode,
						BasicDate,
						StocktakingDesc,
						IsFinish,
						GIDocNo,
						GRDocNo,
						CreateDateTime,
						CreateUserID,
						MLExtText01
					)
				VALUES
					(
							SourceTable.StocktakingDocNo,
							SourceTable.CompanyCode,
							SourceTable.WorkCenterCode,
							SourceTable.MaterialWarehouseCode,
							SourceTable.MaterialCode,
							SourceTable.BasicDate,
							SourceTable.StocktakingDesc,
							SourceTable.IsFinish,
							SourceTable.GIDocNo,
							SourceTable.GRDocNo,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID,
							SourceTable.MLExtText01
					);


			-- Process Delete Table
            MERGE STB_StocktakingDoc AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldStocktakingDocNo IS NULL THEN StocktakingDocNo
							    ELSE OldStocktakingDocNo
							END AS OldStocktakingDocNo,
							StocktakingDocNo,
							CompanyCode,
							WorkCenterCode,
							MaterialWarehouseCode,
							MaterialCode,
							BasicDate,
							StocktakingDesc,
							IsFinish,
							GIDocNo,
							GRDocNo,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID,
							MLExtText01
					FROM
							OPENXML(@idoc , @DeleteTableName , 2)
							WITH  (
										OldStocktakingDocNo VARCHAR(20),
										StocktakingDocNo VARCHAR(20),
										CompanyCode VARCHAR(20),
										WorkCenterCode VARCHAR(20),
										MaterialWarehouseCode VARCHAR(20),
										MaterialCode VARCHAR(50),
										BasicDate DATETIMEOFFSET,
										StocktakingDesc NVARCHAR(200),
										IsFinish BIT,
										GIDocNo VARCHAR(20),
										GRDocNo VARCHAR(20),
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20),
										MLExtText01 NVARCHAR(MAX)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.StocktakingDocNo = SourceTable.StocktakingDocNo
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
									OldStocktakingDocNo,
									StocktakingDocNo,
									CompanyCode,
									WorkCenterCode,
									MaterialWarehouseCode,
									MaterialCode,
									BasicDate,
									StocktakingDesc,
									IsFinish,
									GIDocNo,
									GRDocNo,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID,
									MLExtText01
							FROM
									OPENXML(@idoc , @InsertTableName , 2)
							        WITH  (
											 OldStocktakingDocNo VARCHAR(20),
											 StocktakingDocNo VARCHAR(20),
											 CompanyCode VARCHAR(20),
											 WorkCenterCode VARCHAR(20),
											 MaterialWarehouseCode VARCHAR(20),
											 MaterialCode VARCHAR(50),
											 BasicDate DATETIMEOFFSET,
											 StocktakingDesc NVARCHAR(200),
											 IsFinish BIT,
											 GIDocNo VARCHAR(20),
											 GRDocNo VARCHAR(20),
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20),
											 MLExtText01 NVARCHAR(MAX)
											)
							UNION ALL
							SELECT
									'UPDATE' AS IUD_FLAG,
									CASE 
										WHEN OldStocktakingDocNo IS NULL THEN StocktakingDocNo
										ELSE OldStocktakingDocNo
									END AS OldStocktakingDocNo,
									StocktakingDocNo,
									CompanyCode,
									WorkCenterCode,
									MaterialWarehouseCode,
									MaterialCode,
									BasicDate,
									StocktakingDesc,
									IsFinish,
									GIDocNo,
									GRDocNo,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID,
									MLExtText01
							FROM
									OPENXML(@idoc , @UpdateTableName , 2)
							        WITH  (
											 OldStocktakingDocNo VARCHAR(20),
											 StocktakingDocNo VARCHAR(20),
											 CompanyCode VARCHAR(20),
											 WorkCenterCode VARCHAR(20),
											 MaterialWarehouseCode VARCHAR(20),
											 MaterialCode VARCHAR(50),
											 BasicDate DATETIMEOFFSET,
											 StocktakingDesc NVARCHAR(200),
											 IsFinish BIT,
											 GIDocNo VARCHAR(20),
											 GRDocNo VARCHAR(20),
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20),
											 MLExtText01 NVARCHAR(MAX)
											)
							UNION ALL
							SELECT
									'DELETE' AS IUD_FLAG,
									CASE 
										WHEN OldStocktakingDocNo IS NULL THEN StocktakingDocNo
										ELSE OldStocktakingDocNo
									END AS OldStocktakingDocNo,
									StocktakingDocNo,
									CompanyCode,
									WorkCenterCode,
									MaterialWarehouseCode,
									MaterialCode,
									BasicDate,
									StocktakingDesc,
									IsFinish,
									GIDocNo,
									GRDocNo,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID,
									MLExtText01
							FROM
									OPENXML(@idoc , @DeleteTableName , 2)
							        WITH  (
											 OldStocktakingDocNo VARCHAR(20),
											 StocktakingDocNo VARCHAR(20),
											 CompanyCode VARCHAR(20),
											 WorkCenterCode VARCHAR(20),
											 MaterialWarehouseCode VARCHAR(20),
											 MaterialCode VARCHAR(50),
											 BasicDate DATETIMEOFFSET,
											 StocktakingDesc NVARCHAR(200),
											 IsFinish BIT,
											 GIDocNo VARCHAR(20),
											 GRDocNo VARCHAR(20),
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20),
											 MLExtText01 NVARCHAR(MAX)
											) 


            OPEN SourceData

            WHILE 1 = 1 BEGIN
                FETCH NEXT FROM SourceData INTO
								 @IUD_FLAG,
								 @OldStocktakingDocNo,
								 @StocktakingDocNo,
								 @CompanyCode,
								 @WorkCenterCode,
								 @MaterialWarehouseCode,
								 @MaterialCode,
								 @BasicDate,
								 @StocktakingDesc,
								 @IsFinish,
								 @GIDocNo,
								 @GRDocNo,
								 @CreateDateTime,
								 @CreateUserID,
								 @ChangeDateTime,
								 @ChangeUserID,
								 @MLExtText01


                IF @@FETCH_STATUS <> 0 BEGIN
					BREAK
				END
                IF @IUD_FLAG = 'INSERT' BEGIN

                    IF EXISTS (SELECT 1 FROM STB_StocktakingDoc WHERE StocktakingDocNo = @StocktakingDocNo) BEGIN
						RAISERROR('Duplicate Data : KeyField = %s', 16, 1, @StocktakingDocNo)
					END

                    IF @IsAutoKey = 1 BEGIN
                        EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_StocktakingDoc',@StocktakingDocNo OUTPUT
                    END

                    INSERT INTO STB_StocktakingDoc
						(
						    StocktakingDocNo,
						    CompanyCode,
						    WorkCenterCode,
						    MaterialWarehouseCode,
						    MaterialCode,
						    BasicDate,
						    StocktakingDesc,
						    IsFinish,
						    GIDocNo,
						    GRDocNo,
						    CreateDateTime,
						    CreateUserID,
						    ChangeDateTime,
						    ChangeUserID,
						    MLExtText01
						)
						VALUES
						(
						    @StocktakingDocNo,
						    @CompanyCode,
						    @WorkCenterCode,
						    @MaterialWarehouseCode,
						    @MaterialCode,
						    @BasicDate,
						    @StocktakingDesc,
						    @IsFinish,
						    @GIDocNo,
						    @GRDocNo,
						    GETDATE(),
						    @pProcessUserID,
						    @ChangeDateTime,
						    @ChangeUserID,
						    @MLExtText01
						)

				END ELSE IF @IUD_FLAG = 'UPDATE' BEGIN
                    UPDATE STB_StocktakingDoc
						SET
						    StocktakingDocNo =   ISNULL(@StocktakingDocNo,StocktakingDocNo),
						    CompanyCode =   ISNULL(@CompanyCode,CompanyCode),
						    WorkCenterCode =   ISNULL(@WorkCenterCode,WorkCenterCode),
						    MaterialWarehouseCode =   ISNULL(@MaterialWarehouseCode,MaterialWarehouseCode),
						    MaterialCode =   ISNULL(@MaterialCode,MaterialCode),
						    BasicDate =   ISNULL(@BasicDate,BasicDate),
						    StocktakingDesc =   ISNULL(@StocktakingDesc,StocktakingDesc),
						    IsFinish =   ISNULL(@IsFinish,IsFinish),
						    GIDocNo =   ISNULL(@GIDocNo,GIDocNo),
						    GRDocNo =   ISNULL(@GRDocNo,GRDocNo),
						    CreateDateTime =   ISNULL(@CreateDateTime,CreateDateTime),
						    CreateUserID =   ISNULL(@CreateUserID,CreateUserID),
						    ChangeDateTime = GETDATE(),
						    ChangeUserID = @pProcessUserID,
						    MLExtText01 =   ISNULL(@MLExtText01,MLExtText01)
						WHERE
						    StocktakingDocNo = @OldStocktakingDocNo
                END ELSE IF @IUD_FLAG = 'DELETE' BEGIN
                    DELETE FROM STB_StocktakingDoc
						WHERE
						    StocktakingDocNo = @OldStocktakingDocNo
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

