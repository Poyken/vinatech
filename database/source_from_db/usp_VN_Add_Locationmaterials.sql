CREATE PROC usp_VN_Add_Locationmaterials
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
	DECLARE @OldID INT
	DECLARE @ID INT
	DECLARE @iDoc INT

	DECLARE @CODELR NVARCHAR(30)
	DECLARE @LOCATIONMATERIALS NVARCHAR(50)
	DECLARE @DESCRPTIONS NVARCHAR(500)
	DECLARE @CompanyCode NVARCHAR(20)
	DECLARE @WorkCenterCode NVARCHAR(20)
	DECLARE @Isused BIT
	DECLARE @CreateDateTime DATETIME
	DECLARE @CreateUserID NVARCHAR(50)
	DECLARE @ChangeDateTime DATETIME
	DECLARE @ChangeUserID NVARCHAR(50)

	EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
    BEGIN TRY
		DECLARE SourceData CURSOR FOR

		 SELECT
                    'INSERT' AS IUD_FLAG,
								XMLData.OldID,
								XMLData.ID,
								XMLData.CODELR,
								XMLData.LOCATIONMATERIALS,
								XMLData.DESCRPTIONS,
								XMLData.Isused,
								XMLData.CompanyCode,
								XMLData.WorkCenterCode,
								XMLData.CreateDateTime,
								XMLData.CreateUserID,
								XMLData.ChangeDateTime,
								XMLData.ChangeUserID
							
						FROM
								OPENXML(@idoc , @InsertTableName , 2)
							    WITH  (
										OldID int,
										ID int,
										CODELR NVARCHAR(30),
										LOCATIONMATERIALS NVARCHAR(50),
										DESCRPTIONS NVARCHAR(500),
										Isused BIT,
										CompanyCode NVARCHAR(20),
										WorkCenterCode NVARCHAR(20),
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
								XMLData.CODELR,
								XMLData.LOCATIONMATERIALS,
								XMLData.DESCRPTIONS,
								XMLData.Isused,
								XMLData.CompanyCode,
								XMLData.WorkCenterCode,
								XMLData.CreateDateTime,
								XMLData.CreateUserID,
								XMLData.ChangeDateTime,
								XMLData.ChangeUserID
								
						FROM
								OPENXML(@idoc , @UpdateTableName , 2)
							    WITH  (
											OldID int,
											ID int,
											CODELR NVARCHAR(30),
											LOCATIONMATERIALS NVARCHAR(50),
											DESCRPTIONS NVARCHAR(500),
											Isused BIT,
											CompanyCode NVARCHAR(20),
											WorkCenterCode NVARCHAR(20),
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
								XMLData.CODELR,
								XMLData.LOCATIONMATERIALS,
								XMLData.DESCRPTIONS,
								XMLData.Isused,
								XMLData.CompanyCode,
								XMLData.WorkCenterCode,
								XMLData.CreateDateTime,
								XMLData.CreateUserID,
								XMLData.ChangeDateTime,
								XMLData.ChangeUserID
								
						FROM
								OPENXML(@idoc , @DeleteTableName , 2)
							    WITH  (
										    OldID int,
											ID int,
											CODELR NVARCHAR(30),
											LOCATIONMATERIALS NVARCHAR(50),
											DESCRPTIONS NVARCHAR(500),
											Isused BIT,
											CompanyCode NVARCHAR(20),
											WorkCenterCode NVARCHAR(20),
											CreateDateTime DATETIME,
											CreateUserID VARCHAR(20),
											ChangeDateTime DATETIME,
											ChangeUserID VARCHAR(20)
										
										) XMLData


        OPEN SourceData

		 WHILE 1 = 1 BEGIN
            FETCH NEXT FROM SourceData INTO
								@IUD_FLAG,
								@OldID,
								@ID,
								 @CODELR,
								 @LOCATIONMATERIALS,
								 @DESCRPTIONS,
								 @Isused,
								 @CompanyCode,
								 @WorkCenterCode,
								@CreateDateTime,
								@CreateUserID,
								@ChangeDateTime,
								@ChangeUserID
            IF @@FETCH_STATUS <> 0 BEGIN
				BREAK
			END

			IF @IUD_FLAG = 'INSERT' BEGIN
				PRINT 'INSERT'
				 --Get Max No and Create Next No
				Declare @MaxNo INT
				       ,@NextNo VARCHAR(50)

				SELECT @MaxNo = max(cast(substring(CODELR,5,12) as int )) + 2
				  FROM STB_VN_LOCATIONMATERIALS
				  GROUP BY CODELR
				  ORDER BY CODELR DESC
				
				SET @NextNo = ISNULL('LR','') + RIGHT(REPLICATE('0',1) + CONVERT(VARCHAR,@MaxNo),8)

				PRINT @NextNo

			   INSERT INTO STB_VN_LOCATIONMATERIALS
					(
							CODELR,
							LOCATIONMATERIALS,
							DESCRPTIONS,
							Isused,
							CompanyCode,
							WorkCenterCode,
							CreateDateTime,
							CreateUserID,
							ChangeDateTime,
							ChangeUserID
				
					)
					VALUES
					(
						@NextNo,
						@LOCATIONMATERIALS,
						@DESCRPTIONS,
						@Isused,
						@CompanyCode,
						@WorkCenterCode,
						DATEADD(HH, -2, GETDATE()),
						@pProcessUserID,
						@ChangeDateTime,
						@ChangeUserID
					)

						END ELSE IF @IUD_FLAG = 'UPDATE' BEGIN
				
				
                UPDATE STB_VN_LOCATIONMATERIALS
					SET
							LOCATIONMATERIALS =   CASE
						                WHEN @LOCATIONMATERIALS IS NOT NULL THEN @LOCATIONMATERIALS
						                ELSE LOCATIONMATERIALS
						            END,
						DESCRPTIONS =   CASE
						                WHEN @DESCRPTIONS IS NOT NULL THEN @DESCRPTIONS
						                ELSE DESCRPTIONS
						            END,

							 Isused =   CASE
						                WHEN @Isused IS NOT NULL THEN @Isused
						                ELSE Isused
						            END,

							 CompanyCode =   CASE
						                WHEN @CompanyCode IS NOT NULL THEN @CompanyCode
						                ELSE CompanyCode
						            END,
							 WorkCenterCode =   CASE
						                WHEN @WorkCenterCode IS NOT NULL THEN @WorkCenterCode
						                ELSE WorkCenterCode
						            END,
						 
						    ChangeDateTime = DATEADD(HH, -2, GETDATE()),
						    ChangeUserID = @pProcessUserID
							
					WHERE
						ID = @OldID
            END ELSE IF @IUD_FLAG = 'DELETE' BEGIN
                DELETE FROM STB_VN_LOCATIONMATERIALS
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