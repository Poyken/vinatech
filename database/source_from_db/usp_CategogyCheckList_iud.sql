CREATE PROCEDURE [dbo].[usp_CategogyCheckList_iud]
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
  DECLARE @TypeCheck nvarchar(100)
  DECLARE @Stage nvarchar(50)
  DECLARE @TypeTest nvarchar(100) 
  DECLARE @ItemCheck nvarchar(500)
  DECLARE @TestMethod nvarchar(100)
  DECLARE @NoChecks nvarchar(100)
  DECLARE @IsUsed bit
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
								XMLData.TypeCheck,
								XMLData.Stage,
								XMLData.TypeTest,
								XMLData.ItemCheck,
								XMLData.TestMethod,
								XMLData.NoChecks,
								XMLData.IsUsed,
								XMLData.CreateDateTime,
								XMLData.CreateUserID,
								XMLData.ChangeDateTime,
								XMLData.ChangeUserID
						FROM
								OPENXML(@idoc , @InsertTableName , 2)
							    WITH  (
										OldID int,
										ID int,
										TypeCheck nvarchar(100),
								        Stage nvarchar(50),
								        TypeTest nvarchar(100) ,
								        ItemCheck nvarchar(500),
								        TestMethod nvarchar(100),
								        NoChecks nvarchar(100),
										IsUsed bit,
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
								XMLData.TypeCheck,
								XMLData.Stage,
								XMLData.TypeTest,
								XMLData.ItemCheck,
								XMLData.TestMethod,
								XMLData.NoChecks,
								XMLData.IsUsed,
								XMLData.CreateDateTime,
								XMLData.CreateUserID,
								XMLData.ChangeDateTime,
								XMLData.ChangeUserID
						FROM
								OPENXML(@idoc , @UpdateTableName , 2)
							    WITH  (
											OldID int,
											ID int,
											TypeCheck nvarchar(100),
											Stage nvarchar(50),
											TypeTest nvarchar(100) ,
											ItemCheck nvarchar(500),
											TestMethod nvarchar(100),
											NoChecks nvarchar(100),
											IsUsed bit,
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
								XMLData.TypeCheck,
								XMLData.Stage,
								XMLData.TypeTest,
								XMLData.ItemCheck,
								XMLData.TestMethod,
								XMLData.NoChecks,
								XMLData.IsUsed,
								XMLData.CreateDateTime,
								XMLData.CreateUserID,
								XMLData.ChangeDateTime,
								XMLData.ChangeUserID
						FROM
								OPENXML(@idoc , @DeleteTableName , 2)
							    WITH  (
										OldID int,
											ID int,
											TypeCheck nvarchar(100),
											Stage nvarchar(50),
											TypeTest nvarchar(100) ,
											ItemCheck nvarchar(500),
											TestMethod nvarchar(100),
											NoChecks nvarchar(100),
											IsUsed bit,
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
								@TypeCheck,
								@Stage,
								@TypeTest, 
								@ItemCheck,
								@TestMethod,
								@NoChecks,
								@IsUsed,
								@CreateDateTime,
								@CreateUserID,
								@ChangeDateTime,
								@ChangeUserID


            IF @@FETCH_STATUS <> 0 BEGIN
				BREAK
			END
            IF @IUD_FLAG = 'INSERT' BEGIN
				PRINT 'INSERT'


                INSERT INTO Stb_CategogyCheckList
					(
						TypeCheck,
						Stage,
						TypeTest,
						ItemCheck,
						TestMethod,
						NoChecks,
						IsUsed,
						CreateDateTime,
						CreateUserID,
						ChangeDateTime,
						ChangeUserID
					)
					VALUES
					(
						@TypeCheck,
						@Stage,
						@TypeTest,
						@ItemCheck,
						@TestMethod,
						@NoChecks,
						@IsUsed,
						GETDATE(),
						@pProcessUserID,
						@ChangeDateTime,
						@ChangeUserID
					)

			END ELSE IF @IUD_FLAG = 'UPDATE' BEGIN
				
				
                UPDATE Stb_CategogyCheckList
					SET
						TypeCheck =   CASE
						            WHEN @TypeCheck IS NOT NULL THEN @TypeCheck
						            ELSE TypeCheck
						        END,
						Stage =   CASE
						            WHEN @Stage IS NOT NULL THEN @Stage
						            ELSE Stage
						        END,
						TypeTest =   CASE
						            WHEN @TypeTest IS NOT NULL THEN @TypeTest
						            ELSE TypeTest
						        END,
						ItemCheck =   CASE
						            WHEN @ItemCheck IS NOT NULL THEN @ItemCheck
						            ELSE ItemCheck
						        END,
						TestMethod =   CASE
						            WHEN @TestMethod IS NOT NULL THEN @TestMethod
						            ELSE TestMethod
						        END,
					    NoChecks =   CASE
						            WHEN @NoChecks IS NOT NULL THEN @NoChecks
						            ELSE NoChecks
						        END,
						IsUsed =   CASE
						            WHEN @IsUsed IS NOT NULL THEN @IsUsed
						            ELSE IsUsed
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
                DELETE FROM Stb_CategogyCheckList
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
