CREATE PROC usp_VN_STB_VN_HR_EQUIPMENT_MANAGEMENT
@pProcessUserID VARCHAR(20),
@pProcessLanguage VARCHAR(20),
@pProcessViewName VARCHAR(50),
@pXml NVARCHAR(MAX) = NULL
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


		DECLARE @OldCompanyCode INT
		DECLARE @IDCODEEQ nvarchar(50)
		DECLARE @LOCATIONS nvarchar(50)
		DECLARE @DEPARTMENT nvarchar(50)
		DECLARE @INSTALLATION nvarchar(50)
		DECLARE @USERUSSING nvarchar(50)
		DECLARE @DEVICECODE nvarchar(50)
		DECLARE @DEVICENAME nvarchar(50)
		DECLARE @UNIT nvarchar(50)
		DECLARE @LAPTOP nvarchar(50)
		DECLARE @CODE nvarchar(50)
		DECLARE @VENDORCOMPANY nvarchar(50)
		DECLARE @PURCHASEDATE nvarchar(50)
		DECLARE @STATUSUSSING nvarchar(50)
		DECLARE @CreateDateTime DATETIME
		DECLARE @CreateUserID NVARCHAR(20)
		DECLARE @ChangeDateTime DATETIME
		DECLARE @ChangeUserID NVARCHAR(20)
		DECLARE @iDoc INT

		
	/***---------------------------------------------------------------Start automatic ID for add recorder-----------------------------------------------------------------***/


			DECLARE @NewCode NVARCHAR(50)
			DECLARE @Prefix NVARCHAR(30) = 'VNHREQM'
			DECLARE @Id INT

			SELECT @Id = ISNULL(MAX(ID),0) + 1 FROM STB_VN_HR_EQUIPMENT_MANAGEMENT 
			SELECT @NewCode = @Prefix + RIGHT('00' + CAST(@Id AS nvarchar(30)),30)


	/***---------------------------------------------------------------End automatic ID for add recorder-------------------------------------------------------------------***/

	 	
	 EXEC SmartFramework.dbo.usp_GetSerialRule 
			@pTableName = 'STB_VN_HR_EQUIPMENT_MANAGEMENT',
			@pIsAutoKey = @IsAutoKey OUTPUT,
			@pIsLoopIUD = @IsLoopIUD OUTPUT,
			@pPrefixData = @PrefixString OUTPUT,
			@pSerialLen = @SerialLen OUTPUT

    IF @IsAutoKey = 0 AND @IsLoopIUD = 0 BEGIN
   
	    EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml

   BEGIN TRY
				-- Process Insert Table
			 MERGE STB_VN_HR_EQUIPMENT_MANAGEMENT AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN XMLData.OldCompanyCode IS NULL THEN XMLData.ID
							    ELSE XMLData.OldCompanyCode
							END AS OldCompanyCode,
							XMLData.ID,
							XMLData.IDCODEEQ,
							XMLData.LOCATIONS,
							XMLData.DEPARTMENT,
							XMLData.INSTALLATION,
							XMLData.USERUSSING,
							XMLData.DEVICECODE,
							XMLData.DEVICENAME,
							XMLData.UNIT,
							XMLData.LAPTOP,
							XMLData.CODE,
							XMLData.VENDORCOMPANY,
							XMLData.PURCHASEDATE,
							XMLData.STATUSUSSING,
							 DATEADD(HH, -2, GETDATE()) AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							 DATEADD(HH, -2, GETDATE()) AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
							
					FROM
							OPENXML(@idoc , @InsertTableName , 2)
							WITH  (
										OldCompanyCode INT,
										ID INT,
										IDCODEEQ [nvarchar](50),
										LOCATIONS [nvarchar](50),
										DEPARTMENT [nvarchar](50),
										INSTALLATION [nvarchar](50),
										USERUSSING [nvarchar](50),
										DEVICECODE [nvarchar](50),
										DEVICENAME [nvarchar](50),
										UNIT [nvarchar](50),
										LAPTOP [nvarchar](50),
										CODE [nvarchar](50),
										VENDORCOMPANY [nvarchar](50),
										PURCHASEDATE [nvarchar](50),
										STATUSUSSING [nvarchar](50),
										CreateDateTime  DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime  DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
										
									) XMLData
				) AS SourceTable

			ON
				(
					TargetTable.ID = SourceTable.ID
				)

	WHEN MATCHED THEN

				UPDATE SET
					IDCODEEQ = SourceTable.IDCODEEQ,
					LOCATIONS = SourceTable.LOCATIONS,
					DEPARTMENT = SourceTable.DEPARTMENT,
					INSTALLATION = SourceTable.INSTALLATION,
					USERUSSING = SourceTable.USERUSSING,
					DEVICECODE = SourceTable.DEVICECODE,
					DEVICENAME = SourceTable.DEVICENAME,
					UNIT =  SourceTable.UNIT,
					LAPTOP = SourceTable.LAPTOP,
					CODE = SourceTable.CODE,
					VENDORCOMPANY = SourceTable.VENDORCOMPANY,
					PURCHASEDATE = SourceTable.PURCHASEDATE,
					STATUSUSSING = SourceTable.STATUSUSSING,
					ChangeDateTime = SourceTable.ChangeDateTime,
					ChangeUserID = SourceTable.ChangeUserID
					
WHEN NOT MATCHED THEN

				INSERT
					(
						IDCODEEQ,
						LOCATIONS,
						DEPARTMENT,
						INSTALLATION,
						USERUSSING,
						DEVICECODE,
						DEVICENAME,
						UNIT,
						LAPTOP,
						CODE,
						VENDORCOMPANY,
						PURCHASEDATE,
						STATUSUSSING,
						CreateDateTime,
						CreateUserID
					)
				VALUES
					(
							@NewCode,
							SourceTable.LOCATIONS,
							SourceTable.DEPARTMENT,
							SourceTable.INSTALLATION,
							SourceTable.USERUSSING,
							SourceTable.DEVICECODE,
							SourceTable.DEVICENAME,
							SourceTable.UNIT,
							SourceTable.LAPTOP,
							SourceTable.CODE,
							SourceTable.VENDORCOMPANY,
							SourceTable.PURCHASEDATE,
							SourceTable.STATUSUSSING,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID
							
					);

-- Process Update Table
	 MERGE STB_VN_HR_EQUIPMENT_MANAGEMENT AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN XMLData.OldCompanyCode IS NULL THEN XMLData.ID
							    ELSE XMLData.OldCompanyCode
							END AS OldCompanyCode,
							XMLData.ID,
							XMLData.IDCODEEQ,
							XMLData.LOCATIONS,
							XMLData.DEPARTMENT,
							XMLData.INSTALLATION,
							XMLData.USERUSSING,
							XMLData.DEVICECODE,
							XMLData.DEVICENAME,
							XMLData.UNIT,
							XMLData.LAPTOP,
							XMLData.CODE,
							XMLData.VENDORCOMPANY,
							XMLData.PURCHASEDATE,
							XMLData.STATUSUSSING,
							 DATEADD(HH, -2, GETDATE()) AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							 DATEADD(HH, -2, GETDATE()) AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
							
					FROM
							OPENXML(@idoc , @UpdateTableName , 2)
							WITH  (
										OldCompanyCode INT,
										ID INT,
										IDCODEEQ nvarchar(50),
										LOCATIONS nvarchar(50),
										DEPARTMENT nvarchar(50),
										INSTALLATION nvarchar(50),
										USERUSSING nvarchar(50),
										DEVICECODE nvarchar(50),
										DEVICENAME nvarchar(50),
										UNIT nvarchar(50),
										LAPTOP nvarchar(50),
										CODE nvarchar(50),
										VENDORCOMPANY nvarchar(50),
										PURCHASEDATE nvarchar(50),
										STATUSUSSING nvarchar(50),
										CreateDateTime  DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime  DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) XMLData
				) AS SourceTable
			ON
				(
					TargetTable.ID = SourceTable.ID
				)

WHEN MATCHED THEN

				UPDATE SET
					IDCODEEQ = SourceTable.IDCODEEQ,
					LOCATIONS = SourceTable.LOCATIONS,
					DEPARTMENT = SourceTable.DEPARTMENT,
					INSTALLATION = SourceTable.INSTALLATION,
					USERUSSING = SourceTable.USERUSSING,
					DEVICECODE = SourceTable.DEVICECODE,
					DEVICENAME = SourceTable.DEVICENAME,
					UNIT =SourceTable.UNIT,
					LAPTOP = SourceTable.LAPTOP,
					CODE = SourceTable.CODE,
					VENDORCOMPANY = SourceTable.VENDORCOMPANY,
					PURCHASEDATE = SourceTable.PURCHASEDATE,
					STATUSUSSING = SourceTable.STATUSUSSING,
					ChangeDateTime = SourceTable.ChangeDateTime,
					ChangeUserID = SourceTable.ChangeUserID


	WHEN NOT MATCHED THEN

		INSERT
					(
					
						IDCODEEQ,
						LOCATIONS,
						DEPARTMENT,
						INSTALLATION,
						USERUSSING,
						DEVICECODE,
						DEVICENAME,
						UNIT,
						LAPTOP,
						CODE,
						VENDORCOMPANY,
						PURCHASEDATE,
						STATUSUSSING,
						CreateDateTime,
						CreateUserID
					)

				VALUES
					(
							@NewCode,
							SourceTable.LOCATIONS,
							SourceTable.DEPARTMENT,
							SourceTable.INSTALLATION,
							SourceTable.USERUSSING,
							SourceTable.DEVICECODE,
							SourceTable.DEVICENAME,
							SourceTable.UNIT,
							SourceTable.LAPTOP,
							SourceTable.CODE,
							SourceTable.VENDORCOMPANY,
							SourceTable.PURCHASEDATE,
							SourceTable.STATUSUSSING,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID
					);

		-- Process Delete Table
            MERGE STB_VN_HR_EQUIPMENT_MANAGEMENT AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN XMLData.OldCompanyCode IS NULL THEN XMLData.ID
							    ELSE XMLData.OldCompanyCode
							END AS OldCompanyCode,
							XMLData.ID,
							XMLData.IDCODEEQ,
							XMLData.LOCATIONS,
							XMLData.DEPARTMENT,
							XMLData.INSTALLATION,
							XMLData.USERUSSING,
							XMLData.DEVICECODE,
							XMLData.DEVICENAME,
							XMLData.UNIT,
							XMLData.LAPTOP,
							XMLData.CODE,
							XMLData.VENDORCOMPANY,
							XMLData.PURCHASEDATE,
							XMLData.STATUSUSSING,
							 DATEADD(HH, -2, GETDATE()) AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							 DATEADD(HH, -2, GETDATE()) AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID

					FROM
							OPENXML(@idoc , @DeleteTableName , 2)
							WITH  (
										OldCompanyCode INT,
										ID INT,
										IDCODEEQ nvarchar(50),
										LOCATIONS nvarchar(50),
										DEPARTMENT nvarchar(50),
										INSTALLATION nvarchar(50),
										USERUSSING nvarchar(50),
										DEVICECODE nvarchar(50),
										DEVICENAME nvarchar(50),
										UNIT nvarchar(50),
										LAPTOP nvarchar(50),
										CODE nvarchar(50),
										VENDORCOMPANY nvarchar(50),
										PURCHASEDATE nvarchar(50),
										STATUSUSSING nvarchar(50),
										CreateDateTime  DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime  DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
										
									) XMLData
				) AS SourceTable
	ON
				(
					TargetTable.ID = SourceTable.ID
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
									XMLData.OldCompanyCode,
									XMLData.ID,
									XMLData.IDCODEEQ,
									XMLData.LOCATIONS,
									XMLData.DEPARTMENT,
									XMLData.INSTALLATION,
									XMLData.USERUSSING,
									XMLData.DEVICECODE,
									XMLData.DEVICENAME,
									XMLData.UNIT,
									XMLData.LAPTOP,
									XMLData.CODE,
									XMLData.VENDORCOMPANY,
									XMLData.PURCHASEDATE,
									XMLData.STATUSUSSING,
									XMLData.CreateDateTime,
									XMLData.CreateUserID,
									XMLData.ChangeDateTime,
									XMLData.ChangeUserID
									
							FROM
									OPENXML(@idoc , @InsertTableName , 2)
							        WITH  (
												OldCompanyCode INT,
												ID INT,
												IDCODEEQ nvarchar(50),
												LOCATIONS nvarchar(50),
												DEPARTMENT nvarchar(50),
												INSTALLATION nvarchar(50),
												USERUSSING nvarchar(50),
												DEVICECODE nvarchar(50),
												DEVICENAME nvarchar(50),
												UNIT nvarchar(50),
												LAPTOP nvarchar(50),
												CODE nvarchar(50),
												VENDORCOMPANY nvarchar(50),
												PURCHASEDATE nvarchar(50),
												STATUSUSSING nvarchar(50),
												CreateDateTime  DATETIMEOFFSET,
												CreateUserID VARCHAR(20),
												ChangeDateTime  DATETIMEOFFSET,
												ChangeUserID VARCHAR(20)
											) XMLData
									UNION ALL
SELECT
									'UPDATE' AS IUD_FLAG,
									CASE 
										WHEN XMLData.OldCompanyCode IS NULL THEN XMLData.ID
										ELSE XMLData.OldCompanyCode
									END AS OldCompanyCode,
									XMLData.ID,
									XMLData.IDCODEEQ,
									XMLData.LOCATIONS,
									XMLData.DEPARTMENT,
									XMLData.INSTALLATION,
									XMLData.USERUSSING,
									XMLData.DEVICECODE,
									XMLData.DEVICENAME,
									XMLData.UNIT,
									XMLData.LAPTOP,
									XMLData.CODE,
									XMLData.VENDORCOMPANY,
									XMLData.PURCHASEDATE,
									XMLData.STATUSUSSING,
									XMLData.CreateDateTime,
									XMLData.CreateUserID,
									XMLData.ChangeDateTime,
									XMLData.ChangeUserID
							FROM
									OPENXML(@idoc , @UpdateTableName , 2)
							        WITH  (

											OldCompanyCode INT,
											ID INT,
											IDCODEEQ nvarchar(50),
											LOCATIONS nvarchar(50),
											DEPARTMENT nvarchar(50),
											INSTALLATION nvarchar(50),
											USERUSSING nvarchar(50),
											DEVICECODE nvarchar(50),
											DEVICENAME nvarchar(50),
											UNIT nvarchar(50),
											LAPTOP nvarchar(50),
											CODE nvarchar(50),
											VENDORCOMPANY nvarchar(50),
											PURCHASEDATE nvarchar(50),
											STATUSUSSING nvarchar(50),
											CreateDateTime  DATETIMEOFFSET,
											CreateUserID VARCHAR(20),
											ChangeDateTime  DATETIMEOFFSET,
											ChangeUserID VARCHAR(20)
											) XMLData
UNION ALL
SELECT
									'DELETE' AS IUD_FLAG,
									CASE 
										WHEN XMLData.OldCompanyCode IS NULL THEN XMLData.ID
										ELSE XMLData.OldCompanyCode
									END AS OldCompanyCode,
									XMLData.ID,
									XMLData.IDCODEEQ,
									XMLData.LOCATIONS,
									XMLData.DEPARTMENT,
									XMLData.INSTALLATION,
									XMLData.USERUSSING,
									XMLData.DEVICECODE,
									XMLData.DEVICENAME,
									XMLData.UNIT,
									XMLData.LAPTOP,
									XMLData.CODE,
									XMLData.VENDORCOMPANY,
									XMLData.PURCHASEDATE,
									XMLData.STATUSUSSING,	
									XMLData.CreateDateTime,
									XMLData.CreateUserID,
									XMLData.ChangeDateTime,
									XMLData.ChangeUserID
									
							FROM
									OPENXML(@idoc , @DeleteTableName , 2)
							        WITH  (

											OldCompanyCode VARCHAR(20),
											ID INT,
											IDCODEEQ nvarchar(50),
											LOCATIONS nvarchar(50),
											DEPARTMENT nvarchar(50),
											INSTALLATION nvarchar(50),
											USERUSSING nvarchar(50),
											DEVICECODE nvarchar(50),
											DEVICENAME nvarchar(50),
											UNIT nvarchar(50),
											LAPTOP nvarchar(50),
											CODE nvarchar(50),
											VENDORCOMPANY nvarchar(50),
											PURCHASEDATE nvarchar(50),
											STATUSUSSING nvarchar(50),
											CreateDateTime  DATETIMEOFFSET,
											CreateUserID VARCHAR(20),
											ChangeDateTime  DATETIMEOFFSET,
											ChangeUserID VARCHAR(20)
											) XMLData
 OPEN SourceData

					   WHILE 1 = 1 BEGIN
                FETCH NEXT FROM SourceData INTO
								 @IUD_FLAG,
								 @OldCompanyCode,
								 @IDCODEEQ,
								 @LOCATIONS,
								 @DEPARTMENT,
								 @INSTALLATION,
								 @USERUSSING,
								 @DEVICECODE,
								 @DEVICENAME,
								 @UNIT,
								 @LAPTOP,
								 @CODE,
								 @VENDORCOMPANY,
								 @PURCHASEDATE,
								 @STATUSUSSING,
								 @CreateDateTime,
								 @CreateUserID,
								 @ChangeDateTime,
								 @ChangeUserID
								

			  IF @@FETCH_STATUS <> 0 BEGIN
					BREAK
				END

		  IF @IUD_FLAG = 'INSERT' BEGIN

                    IF EXISTS (SELECT 1 FROM STB_VN_HR_EQUIPMENT_MANAGEMENT WHERE ID = @OldCompanyCode) BEGIN
						RAISERROR('Duplicate Data : KeyField = %s', 16, 1, @OldCompanyCode)
					END
			 IF @IsAutoKey = 0 BEGIN
						EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_VN_HR_EQUIPMENT_MANAGEMENT', @OldCompanyCode OUTPUT

INSERT INTO STB_VN_HR_EQUIPMENT_MANAGEMENT
						(
						  	
							IDCODEEQ,
							LOCATIONS,
							DEPARTMENT,
							INSTALLATION,
							USERUSSING,
							DEVICECODE,
							DEVICENAME,
							UNIT,
							LAPTOP,
							CODE,
							VENDORCOMPANY,
							PURCHASEDATE,
							STATUSUSSING,
						    CreateDateTime,
						    CreateUserID,
						    ChangeDateTime,
						    ChangeUserID
						)
						VALUES
						(
							@NewCode,
							@LOCATIONS,
							@DEPARTMENT,
							@INSTALLATION,
							@USERUSSING,
							@DEVICECODE,
							@DEVICENAME,
							@UNIT,
							@LAPTOP,
							@CODE,
							@VENDORCOMPANY,
							@PURCHASEDATE,
							@STATUSUSSING,
						    DATEADD(HH, -2, GETDATE()),
						    @pProcessUserID,
						    @ChangeDateTime,
						    @ChangeUserID
						)
END ELSE IF @IUD_FLAG = 'UPDATE' BEGIN
 UPDATE STB_VN_HR_EQUIPMENT_MANAGEMENT
						SET
						

						IDCODEEQ =   CASE
						                WHEN @IDCODEEQ IS NOT NULL THEN @IDCODEEQ
						                ELSE IDCODEEQ
						            END,

							LOCATIONS =   CASE
						                WHEN @LOCATIONS IS NOT NULL THEN @LOCATIONS
						                ELSE LOCATIONS
						            END,
						DEPARTMENT =   CASE
						                WHEN @DEPARTMENT IS NOT NULL THEN @DEPARTMENT
						                ELSE DEPARTMENT
						            END,

							 INSTALLATION =   CASE
						                WHEN @INSTALLATION IS NOT NULL THEN @INSTALLATION
						                ELSE INSTALLATION
						            END,

							 USERUSSING =   CASE
						                WHEN @USERUSSING IS NOT NULL THEN @USERUSSING
						                ELSE USERUSSING
						            END,
							 DEVICECODE =   CASE
						                WHEN @DEVICECODE IS NOT NULL THEN @DEVICECODE
						                ELSE DEVICECODE
						            END,
						 DEVICENAME =   CASE
						                WHEN @DEVICENAME IS NOT NULL THEN @DEVICENAME
						                ELSE DEVICENAME
						            END,
						 UNIT =   CASE
						                WHEN @UNIT IS NOT NULL THEN @UNIT
						                ELSE UNIT
						            END,
						 LAPTOP =   CASE
						                WHEN @LAPTOP IS NOT NULL THEN @LAPTOP
						                ELSE LAPTOP
						            END,
						 CODE =   CASE
						                WHEN @CODE IS NOT NULL THEN @CODE
						                ELSE CODE
						            END,
						 VENDORCOMPANY =   CASE
						                WHEN @VENDORCOMPANY IS NOT NULL THEN @VENDORCOMPANY
						                ELSE VENDORCOMPANY
						            END,
						 PURCHASEDATE =   CASE
						                WHEN @PURCHASEDATE IS NOT NULL THEN @PURCHASEDATE
						                ELSE PURCHASEDATE
						            END,
						 STATUSUSSING =   CASE
						                WHEN @STATUSUSSING IS NOT NULL THEN @STATUSUSSING
						                ELSE STATUSUSSING
						            END,
						    ChangeDateTime = DATEADD(HH, -2, GETDATE()),
						    ChangeUserID = @pProcessUserID
						
					
					WHERE
						    ID = @OldCompanyCode
						  END ELSE IF @IUD_FLAG = 'DELETE' BEGIN
                        DELETE FROM STB_VN_HR_EQUIPMENT_MANAGEMENT
						WHERE
						    ID = @OldCompanyCode
                    END
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