CREATE PROCEDURE [dbo].[usp_CheckSheetDailyDetail_iud]
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
  DECLARE @CategoryCheckListNo nvarchar(50)
  DECLARE @Result1 bit
  DECLARE @Result2 bit
  DECLARE @Result3 bit
  DECLARE @Result4 bit
  DECLARE @ChangeTimeResult1 datetime
  DECLARE @ChangeTimeResult2 datetime
  DECLARE @ChangeTimeResult3 datetime
  DECLARE @ChangeTimeResult4 datetime
  DECLARE @CreateDateTime DATETIME
  DECLARE @CreateUserID VARCHAR(20)
  DECLARE @ChangeDateTime DATETIME
  DECLARE @ChangeUserID VARCHAR(20)

  DECLARE @ChangeTime1 datetime = NULL
  DECLARE @ChangeTime2 datetime = NULL
  DECLARE @ChangeTime3 datetime = NULL
  DECLARE @ChangeTime4 datetime = NULL


	DECLARE @iDoc INT
	
    EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
    BEGIN TRY
	    
		DECLARE SourceData CURSOR FOR
		
            SELECT
                    'INSERT' AS IUD_FLAG,
								XMLData.OldID,
								XMLData.ID,
								XMLData.CheckSheetDaily,
								XMLData.CategoryCheckListNo,
								XMLData.Result1,
								XMLData.Result2,
								XMLData.Result3,
								XMLData.Result4,
								XMLData.ChangeTimeResult1,
								XMLData.ChangeTimeResult2,
								XMLData.ChangeTimeResult3,
								XMLData.ChangeTimeResult4,
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
										CategoryCheckListNo nvarchar(50),
										Result1 bit,
										Result2 bit,
										Result3 bit,
										Result4 bit,
										ChangeTimeResult1  datetime,
										ChangeTimeResult2  datetime,
										ChangeTimeResult3  datetime,
										ChangeTimeResult4  datetime,
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
								XMLData.CategoryCheckListNo,
								XMLData.Result1,
								XMLData.Result2,
								XMLData.Result3,
								XMLData.Result4,
								XMLData.ChangeTimeResult1,
								XMLData.ChangeTimeResult2,
								XMLData.ChangeTimeResult3,
								XMLData.ChangeTimeResult4,
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
											CategoryCheckListNo nvarchar(50),
											Result1 bit,
											Result2 bit,
											Result3 bit,
											Result4 bit,
											ChangeTimeResult1  datetime,
											ChangeTimeResult2  datetime,
											ChangeTimeResult3  datetime,
											ChangeTimeResult4  datetime,
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
								XMLData.CategoryCheckListNo,
								XMLData.Result1,
								XMLData.Result2,
								XMLData.Result3,
								XMLData.Result4,
								XMLData.ChangeTimeResult1,
								XMLData.ChangeTimeResult2,
								XMLData.ChangeTimeResult3,
								XMLData.ChangeTimeResult4,
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
											CategoryCheckListNo nvarchar(50),
											Result1 bit,
											Result2 bit,
											Result3 bit,
											Result4 bit,
											ChangeTimeResult1  datetime,
											ChangeTimeResult2  datetime,
											ChangeTimeResult3  datetime,
											ChangeTimeResult4  datetime,
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
								@CategoryCheckListNo,
								@Result1,
								@Result2,
								@Result3,
								@Result4,
								@ChangeTimeResult1,
								@ChangeTimeResult2,
								@ChangeTimeResult3,
								@ChangeTimeResult4,
								@CreateDateTime,
								@CreateUserID,
								@ChangeDateTime,
								@ChangeUserID


            IF @@FETCH_STATUS <> 0 BEGIN
				BREAK
			END
            IF @IUD_FLAG = 'INSERT' BEGIN
				PRINT 'INSERT'
			
			

				If @Result1 =1
				BEGIN
					set @ChangeTime1 = getdate();
				END

				If @Result1 =2
				BEGIN
					set @ChangeTime2 = getdate();
				END

				If @Result3 =1
				BEGIN
					set @ChangeTime3 = getdate();
				END

				If @Result4 =1
				BEGIN
					set @ChangeTime4 = getdate();
				END




                INSERT INTO stb_CheckSheetDailyDetail
					(
						CheckSheetDaily,
						CategoryCheckListNo,
						Result1,
						Result2,
						Result3,
						Result4,
						ChangeTimeResult1,
						ChangeTimeResult2,
						ChangeTimeResult3,
						ChangeTimeResult4,
						CreateDateTime,
						CreateUserID,
						ChangeDateTime,
						ChangeUserID
					)
					VALUES
					(
						@CheckSheetDaily,
						@CategoryCheckListNo,
						@Result1,
						@Result2,
						@Result3,
						@Result4,
						--@ChangeTimeResult1,
						--@ChangeTimeResult2,
						--@ChangeTimeResult3,
						--@ChangeTimeResult4,
						@ChangeTime1,
						@ChangeTime2,
						@ChangeTime3,
						@ChangeTime4,
						GETDATE(),
						@pProcessUserID,
						@ChangeDateTime,
						@ChangeUserID
					)

			END ELSE IF @IUD_FLAG = 'UPDATE' BEGIN
				
				Declare @ResultDB1 bit
				Declare @ResultDB2 bit
				Declare @ResultDB3 bit
				Declare @ResultDB4 bit

				select @ResultDB1 = result1, @ResultDB2 = result2, @ResultDB3 = Result3, @ResultDB4 = Result4 from Stb_CheckSheetDailyDetail where ID=@ID
				
				DECLARE @aa varchar(10)
				set @aa=@Result1
				--RAISERROR(@aa,16,1)
				

			
                UPDATE Stb_CheckSheetDailyDetail
					SET
						CheckSheetDaily =   CASE
						            WHEN @CheckSheetDaily IS NOT NULL THEN @CheckSheetDaily
						            ELSE CheckSheetDaily
						        END,
						CategoryCheckListNo =   CASE
						            WHEN @CategoryCheckListNo IS NOT NULL THEN @CategoryCheckListNo
						            ELSE CategoryCheckListNo
						        END,
						Result1 =   CASE
						            WHEN @Result1 IS NOT NULL THEN @Result1
						            ELSE Result1
						        END,
						Result2 =   CASE
						            WHEN @Result2 IS NOT NULL THEN @Result2
						            ELSE Result2
						        END,
						Result3 =   CASE
						            WHEN @Result3 IS NOT NULL THEN @Result3
						            ELSE Result3
						        END,
						Result4 =   CASE
						            WHEN @Result4 IS NOT NULL THEN @Result4
						            ELSE Result4
						        END,
						--ChangeTimeResult1 =   CASE
						--            WHEN @ChangeTimeResult1 IS NOT NULL THEN @ChangeTimeResult1
						--            ELSE ChangeTimeResult1
						--        END,
						--ChangeTimeResult2 =   CASE
						--            WHEN @ChangeTimeResult2 IS NOT NULL THEN @ChangeTimeResult2
						--            ELSE ChangeTimeResult2
						--        END,
						--ChangeTimeResult3 =   CASE
						--            WHEN @ChangeTimeResult3 IS NOT NULL THEN @ChangeTimeResult3
						--            ELSE ChangeTimeResult3
						--        END,
						--ChangeTimeResult4 =   CASE
						--            WHEN @ChangeTimeResult4 IS NOT NULL THEN @ChangeTimeResult4
						--            ELSE ChangeTimeResult4
						--        END,
						ChangeTimeResult1 = case 
											when coalesce(@ResultDB1,'') != @Result1 and @Result1 = 1 then GETDATE()
											when coalesce(@ResultDB1,'') != @Result1 and @Result1 = 0 then NULL
											ELSE ChangeTimeResult1
											END,
						ChangeTimeResult2 = case 
											when coalesce(@ResultDB2,'') != @Result2 and @Result2 = 1 then GETDATE()
											when coalesce(@ResultDB2,'') != @Result2 and @Result2 = 0 then NULL
											ELSE ChangeTimeResult2
											END,
						ChangeTimeResult3 = case 
											when coalesce(@ResultDB3,'') != @Result3 and @Result3 = 1 then GETDATE()
											when coalesce(@ResultDB3,'') != @Result3 and @Result3 = 0 then NULL
											ELSE ChangeTimeResult3
											END,
						ChangeTimeResult4 = case 
											when coalesce(@ResultDB4,'') != @Result4 and @Result4 = 1 then GETDATE()
											when coalesce(@ResultDB4,'') != @Result4 and @Result4 = 0 then NULL
											ELSE ChangeTimeResult4
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
                DELETE FROM stb_CheckSheetDailyDetail
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

