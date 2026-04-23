CREATE PROCEDURE [dbo].[usp_Strategy_iud]
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
  DECLARE @OldID INT
  DECLARE @ID INT
  DECLARE @CheckSheetDaily nvarchar(50)
  DECLARE @Stage nvarchar(50)
  DECLARE @Issue nvarchar(50)
  DECLARE @Reason nvarchar(200)
  DECLARE @Strategy nvarchar(500)
  DECLARE @PersonCharge nvarchar(100) 
  DECLARE @CreateDateTime DATETIME
  DECLARE @CreateUserID VARCHAR(20)
  DECLARE @ChangeDateTime DATETIME
  DECLARE @ChangeUserID VARCHAR(20)


	DECLARE @iDoc INT
	
    EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
    BEGIN TRY
	    
		DECLARE SourceData CURSOR FOR
		
            SELECT
                    'INSERT' AS IUD_FLAG,
								XMLData.OldID,
								XMLData.ID,
								XMLData.CheckSheetDaily,
								XMLData.Stage,
								XMLData.Issue,
								XMLData.Reason,
								XMLData.Strategy,
								XMLData.PersonCharge,
								XMLData.CreateDateTime,
								XMLData.CreateUserID,
								XMLData.ChangeDateTime,
								XMLData.ChangeUserID
						FROM
								OPENXML(@idoc , @InsertTableName , 2)
							    WITH  (
										OldID int,
										ID int,
										CheckSheetDaily nvarchar(50),
										Stage nvarchar(50),
										Issue nvarchar(50),
										Reason nvarchar(200),
										Strategy nvarchar(500),
										PersonCharge nvarchar(100) ,
										CreateDateTime DATETIME,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIME,
										ChangeUserID VARCHAR(20)
										) XMLData
						UNION ALL
						SELECT
								'UPDATE' AS IUD_FLAG,
								CASE 
									WHEN XMLData.OldID IS NULL THEN XMLData.ID
									ELSE XMLData.OldID
								END AS OldID,
								XMLData.ID,
								XMLData.CheckSheetDaily,
								XMLData.Stage,
								XMLData.Issue,
								XMLData.Reason,
								XMLData.Strategy,
								XMLData.PersonCharge,
								XMLData.CreateDateTime,
								XMLData.CreateUserID,
								XMLData.ChangeDateTime,
								XMLData.ChangeUserID
						FROM
								OPENXML(@idoc , @UpdateTableName , 2)
							    WITH  (
											OldID int,
											ID int,
											CheckSheetDaily nvarchar(50),
											Stage nvarchar(50),
											Issue nvarchar(50),
											Reason nvarchar(200),
											Strategy nvarchar(500),
											PersonCharge nvarchar(100) ,
											CreateDateTime DATETIME,
											CreateUserID VARCHAR(20),
											ChangeDateTime DATETIME,
											ChangeUserID VARCHAR(20)
										) XMLData
						UNION ALL
						SELECT
								'DELETE' AS IUD_FLAG,
								CASE 
									WHEN XMLData.OldID IS NULL THEN XMLData.ID
									ELSE XMLData.OldID
								END AS OldID,
								XMLData.ID,
								XMLData.CheckSheetDaily,
								XMLData.Stage,
								XMLData.Issue,
								XMLData.Reason,
								XMLData.Strategy,
								XMLData.PersonCharge,
								XMLData.CreateDateTime,
								XMLData.CreateUserID,
								XMLData.ChangeDateTime,
								XMLData.ChangeUserID
						FROM
								OPENXML(@idoc , @DeleteTableName , 2)
							    WITH  (
										OldID int,
											ID int,
											CheckSheetDaily nvarchar(50),
											Stage nvarchar(50),
											Issue nvarchar(50),
											Reason nvarchar(200),
											Strategy nvarchar(500),
											PersonCharge nvarchar(100) ,
											CreateDateTime DATETIME,
											CreateUserID VARCHAR(20),
											ChangeDateTime DATETIME,
											ChangeUserID VARCHAR(20)
										) XMLData


        OPEN SourceData
		--RAISERROR(@pXml,16,1)
        WHILE 1 = 1 BEGIN
            FETCH NEXT FROM SourceData INTO
								@IUD_FLAG,
								@OldID,
								@ID,
								@CheckSheetDaily,
								@Stage,
								@Issue,
								@Reason,
								@Strategy,
								@PersonCharge,
								@CreateDateTime,
								@CreateUserID,
								@ChangeDateTime,
								@ChangeUserID


            IF @@FETCH_STATUS <> 0 BEGIN
				BREAK
			END
            IF @IUD_FLAG = 'INSERT' BEGIN
				PRINT 'INSERT'

			--	RAISERROR(@CheckSheetDaily,16,1)
                INSERT INTO Stb_Strategy
					(
						CheckSheetDaily,
						Stage,
						Issue,
						Reason,
						Strategy,
						PersonCharge,
						CreateDateTime,
						CreateUserID,
						ChangeDateTime,
						ChangeUserID
					)
					VALUES
					(
						@CheckSheetDaily,
						@Stage,
						@Issue,
						@Reason,
						@Strategy,
						@PersonCharge,
						GETDATE(),
						@pProcessUserID,
						@ChangeDateTime,
						@ChangeUserID
					)

			END ELSE IF @IUD_FLAG = 'UPDATE' BEGIN
				
				
                UPDATE Stb_Strategy
					SET
						Stage =   CASE
						            WHEN @Stage IS NOT NULL THEN @Stage
						            ELSE Stage
						        END,
						Issue =   CASE
						            WHEN @Issue IS NOT NULL THEN @Issue
						            ELSE Issue
						        END,
						Reason =   CASE
						            WHEN @Reason IS NOT NULL THEN @Reason
						            ELSE Reason
						        END,
						Strategy =   CASE
						            WHEN @Strategy IS NOT NULL THEN @Strategy
						            ELSE Strategy
						        END,
						PersonCharge =   CASE
						            WHEN @PersonCharge IS NOT NULL THEN @PersonCharge
						            ELSE PersonCharge
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
						ID = @OldID
            END ELSE IF @IUD_FLAG = 'DELETE' BEGIN
                DELETE FROM Stb_Strategy
					WHERE
						ID = @ID
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
