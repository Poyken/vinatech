CREATE PROC [dbo].[usp_VN_Order_Rams]
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
	DECLARE @iDoc INT
	DECLARE @ID INT
	DECLARE @MaterialCode NVARCHAR(50)
	DECLARE @MaterialName NVARCHAR(50)
	DECLARE @QTYACTUALLY NUMERIC(18,0)
	DECLARE @QTYREQUEST NUMERIC(18,0)
	DECLARE @EXPECTED_DATE_NEEDED DATETIME
	DECLARE @APPROVEREDBY NVARCHAR(50)
	DECLARE @CREATEDATE_APPROVERBY DATETIME
	DECLARE @LineCode NVARCHAR(50)
	DECLARE @LineName  NVARCHAR(50)
	DECLARE @STATUS_MATERIALS NVARCHAR(50)
	DECLARE @WorkCenterCode NVARCHAR(50)
	DECLARE @WorkCenterName NVARCHAR(50)
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
								XMLData.MaterialCode,
								XMLData.MaterialName,
								XMLData.QTYACTUALLY,
								XMLData.QTYREQUEST,
								XMLData.EXPECTED_DATE_NEEDED,
								XMLData.APPROVEREDBY,
								XMLData.CREATEDATE_APPROVERBY,
								XMLData.LineCode,
								XMLData.LineName,
								XMLData.STATUS_MATERIALS,
								XMLData.WorkCenterCode,
								XMLData.WorkCenterName,
								XMLData.CreateDateTime,
								XMLData.CreateUserID,
								XMLData.ChangeDateTime,
								XMLData.ChangeUserID
							
						FROM
								OPENXML(@idoc , @InsertTableName , 2)
							    WITH  (
										OldID int,
										ID int,
										MaterialCode NVARCHAR(50),
										MaterialName NVARCHAR(50),
										QTYACTUALLY NUMERIC(18,0),
										QTYREQUEST NUMERIC(18,0),
										EXPECTED_DATE_NEEDED DATETIME,
										APPROVEREDBY NVARCHAR(500),
										CREATEDATE_APPROVERBY DATETIME,
										LineCode  NVARCHAR(50),
										LineName NVARCHAR(50),
										STATUS_MATERIALS NVARCHAR(50),
										WorkCenterCode  NVARCHAR(50), 
										WorkCenterName NVARCHAR(50),  
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
								XMLData.MaterialCode,
								XMLData.MaterialName,
								XMLData.QTYACTUALLY,
								XMLData.QTYREQUEST,
								XMLData.EXPECTED_DATE_NEEDED,
								XMLData.APPROVEREDBY,
								XMLData.CREATEDATE_APPROVERBY,
								XMLData.LineCode,
								XMLData.LineName,
								XMLData.STATUS_MATERIALS,
								XMLData.WorkCenterCode,
								XMLData.WorkCenterName,
								XMLData.CreateDateTime,
								XMLData.CreateUserID,
								XMLData.ChangeDateTime,
								XMLData.ChangeUserID
							
						FROM
								OPENXML(@idoc , @UpdateTableName , 2)
							    WITH  (
											OldID int,
											ID int,
											MaterialCode NVARCHAR(50),
											MaterialName NVARCHAR(50),
											QTYACTUALLY NUMERIC(18,0),
											QTYREQUEST NUMERIC(18,0),
											EXPECTED_DATE_NEEDED DATETIME,
											APPROVEREDBY NVARCHAR(500),
											CREATEDATE_APPROVERBY DATETIME,
											LineCode  NVARCHAR(50),
											LineName NVARCHAR(50),
											STATUS_MATERIALS NVARCHAR(50),
											WorkCenterCode  NVARCHAR(50), 
											WorkCenterName NVARCHAR(50),  
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
								XMLData.MaterialCode,
								XMLData.MaterialName,
								XMLData.QTYACTUALLY,
								XMLData.QTYREQUEST,
								XMLData.EXPECTED_DATE_NEEDED,
								XMLData.APPROVEREDBY,
								XMLData.CREATEDATE_APPROVERBY,
								XMLData.LineCode,
								XMLData.LineName,
								XMLData.STATUS_MATERIALS,
								XMLData.WorkCenterCode,
								XMLData.WorkCenterName,
								XMLData.CreateDateTime,
								XMLData.CreateUserID,
								XMLData.ChangeDateTime,
								XMLData.ChangeUserID
							
						FROM
								OPENXML(@idoc , @DeleteTableName , 2)
							    WITH  (
										OldID int,
											ID int,
											MaterialCode NVARCHAR(50),
											MaterialName NVARCHAR(50),
											QTYACTUALLY NUMERIC(18,0),
											QTYREQUEST NUMERIC(18,0),
											EXPECTED_DATE_NEEDED DATETIME,
											APPROVEREDBY NVARCHAR(500),
											CREATEDATE_APPROVERBY DATETIME,
											LineCode  NVARCHAR(50),
											LineName NVARCHAR(50),
											STATUS_MATERIALS NVARCHAR(50),
											WorkCenterCode  NVARCHAR(50), 
											WorkCenterName NVARCHAR(50),  
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
								@MaterialCode,
								@MaterialName,
								@QTYACTUALLY,
								@QTYREQUEST,
								@EXPECTED_DATE_NEEDED,
								@APPROVEREDBY,
								@CREATEDATE_APPROVERBY,
								@LineCode,
								@LineName,
								@STATUS_MATERIALS,
								@WorkCenterCode, 
								@WorkCenterName,  
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
				--Declare @MaxNo INT
				--       ,@NextNo VARCHAR(50)

				--SELECT @MaxNo = max(cast(substring(BARCODESYSTEM,5,12) as int )) +1
				--  FROM STB_VN_DEVICEMACHINES
				
				--SET @NextNo = ISNULL('VINA','') + RIGHT(REPLICATE('0',8) + CONVERT(VARCHAR,@MaxNo),8)

				--PRINT @NextNo

				-- IF @IsAutoKey = 1 BEGIN
				--		EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_VN_DEVICEMACHINES', @BARCODESYSTEM OUTPUT		
				--END

                INSERT INTO STB_VN_ORDER_MATERIALS
					(
							MaterialCode,
							MaterialName,
							QTYACTUALLY,
							QTYREQUEST,
							EXPECTED_DATE_NEEDED,
							APPROVEREDBY,
							CREATEDATE_APPROVERBY,
							LineCode,
							LineName,
							STATUS_MATERIALS,
							WorkCenterCode, 
							WorkCenterName,  
							CreateDateTime,
							CreateUserID,
							ChangeDateTime,
							ChangeUserID
				
					)
					VALUES
					(
						@MaterialCode,
						@MaterialName,
						@QTYACTUALLY,
						@QTYREQUEST,
						@EXPECTED_DATE_NEEDED,
						@APPROVEREDBY,
						@CREATEDATE_APPROVERBY,
						@LineCode,
						@LineName,
						N'Chờ duyệt', 
						@WorkCenterCode,  
						@WorkCenterName,  
						GETDATE(),
						@pProcessUserID,
						@ChangeDateTime,
						@ChangeUserID
							
					)

			END ELSE IF @IUD_FLAG = 'UPDATE' BEGIN
				
				
                UPDATE STB_VN_ORDER_MATERIALS
					SET
							MaterialCode =   CASE
						                WHEN @MaterialCode IS NOT NULL THEN @MaterialCode
						                ELSE MaterialCode
						            END,
						MaterialName =   CASE
						                WHEN @MaterialName IS NOT NULL THEN @MaterialName
						                ELSE MaterialName
						            END,

							 QTYACTUALLY =   CASE
						                WHEN @QTYACTUALLY IS NOT NULL THEN @QTYACTUALLY
						                ELSE QTYACTUALLY
						            END,

							 QTYREQUEST =   CASE
						                WHEN @QTYREQUEST IS NOT NULL THEN @QTYREQUEST
						                ELSE QTYREQUEST
						            END,
							 EXPECTED_DATE_NEEDED =   CASE
						                WHEN @EXPECTED_DATE_NEEDED IS NOT NULL THEN @EXPECTED_DATE_NEEDED
						                ELSE EXPECTED_DATE_NEEDED
						            END,
						 APPROVEREDBY =   CASE
						                WHEN @APPROVEREDBY IS NOT NULL THEN @APPROVEREDBY
						                ELSE APPROVEREDBY
						            END,

						 CREATEDATE_APPROVERBY =   CASE
						                WHEN @CREATEDATE_APPROVERBY IS NOT NULL THEN @CREATEDATE_APPROVERBY
						                ELSE CREATEDATE_APPROVERBY
						            END,

						 LineCode =   CASE
						                WHEN @LineCode IS NOT NULL THEN @LineCode
						                ELSE LineCode
						            END,

						 LineName =   CASE
						                WHEN @LineName IS NOT NULL THEN @LineName
						                ELSE LineName
						            END,

										 STATUS_MATERIALS =   CASE
						                WHEN @STATUS_MATERIALS IS NOT NULL THEN @STATUS_MATERIALS
						                ELSE STATUS_MATERIALS
						            END,

										 WorkCenterCode =   CASE
						                WHEN @WorkCenterCode IS NOT NULL THEN @WorkCenterCode
						                ELSE WorkCenterCode
						            END,

										 WorkCenterName =   CASE
						                WHEN @WorkCenterName IS NOT NULL THEN @WorkCenterName
						                ELSE WorkCenterName
						            END,

						    ChangeDateTime = DATEADD(HH, -2, GETDATE()),
						    ChangeUserID = @pProcessUserID
							
					WHERE
						ID = @OldID
            END ELSE IF @IUD_FLAG = 'DELETE' BEGIN
                DELETE FROM STB_VN_ORDER_MATERIALS
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