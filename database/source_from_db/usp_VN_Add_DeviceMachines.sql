CREATE PROC [dbo].[usp_VN_Add_DeviceMachines]
@pProcessUserID VARCHAR(20),
@pProcessLanguage VARCHAR(20),
@pProcessViewName VARCHAR(50),
@pXml NVARCHAR(MAX) = NULL
AS
BEGIN
		SET NOCOUNT ON;
		RAISERROR( @pXml ,16, 1)


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

	/***---------------------------------------------------------------Start automatic ID for add recorder-----------------------------------------------------------------***/

			DECLARE @NewCode NVARCHAR(50)
			DECLARE @Prefix NVARCHAR(30) = 'VINA'
			DECLARE @Id INT

			SELECT @Id = ISNULL(MAX(ID),0) + 1 FROM STB_VN_DEVICEMACHINES 
			SELECT @NewCode = @Prefix + RIGHT('0000' + CAST(@Id AS nvarchar(30)),30)

	/***---------------------------------------------------------------End automatic ID for add recorder-------------------------------------------------------------------***/

	DECLARE @OldCompanyCode NVARCHAR(100)
	DECLARE @BARCODESYSTEM NVARCHAR(100)
	DECLARE @CODEDEVICEMACHINES NVARCHAR(100)
	DECLARE @CODEEXPENSE NVARCHAR(100)
	DECLARE @CODESTOREMACHINES NVARCHAR(100)
	DECLARE @CODESTATUSMACHINES NVARCHAR(100)
	DECLARE @CODELOCATIONMACHINES NVARCHAR(100)
	DECLARE @Classifications NVARCHAR(50)
	DECLARE @BPSDPM  NVARCHAR(50)
	DECLARE @BPDETAIL NVARCHAR(50)
	DECLARE @Seller NVARCHAR(50)
	DECLARE @English  NVARCHAR(50)
	DECLARE @Vietnamese NVARCHAR(50)
	DECLARE @Model NVARCHAR(50)
	DECLARE @Specifications NVARCHAR(50)
	DECLARE @Korean NVARCHAR(50)
	DECLARE @DocumentNo NVARCHAR(100)
	DECLARE @Quantiy INT
	DECLARE @PurchaseDate DATETIME
	DECLARE @CODE NVARCHAR(50)
	DECLARE @IsUsed BIT
	DECLARE @CreateDateTime DATETIME
	DECLARE @CreateUserID NVARCHAR(50)
	DECLARE @ChangeDateTime DATETIME
	DECLARE @ChangeUserID NVARCHAR(50)
	DECLARE @iDoc INT
	
	if(@ProcessUserID<>'MrHuy' or @pProcessUserID<>'MrHuy') begin
		raiserror(N'Chỉ có Mr.Huy được phép sửa dữ liệu này!',16,1)
		return;
	end

	 EXEC SmartFramework.dbo.usp_GetSerialRule 
			@pTableName = 'STB_VN_DEVICEMACHINES',
			@pIsAutoKey = @IsAutoKey OUTPUT,
			@pIsLoopIUD = @IsLoopIUD OUTPUT,
			@pPrefixData = @PrefixString OUTPUT,
			@pSerialLen = @SerialLen OUTPUT


    IF @IsAutoKey = 0 AND @IsLoopIUD = 0 BEGIN
   
	    EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml

		BEGIN TRY
			-- Process Insert Table
			 MERGE STB_VN_DEVICEMACHINES AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN XMLData.OldCompanyCode IS NULL THEN XMLData.ID
							    ELSE XMLData.OldCompanyCode
							END AS OldCompanyCode,
							XMLData.ID,
							XMLData.BARCODESYSTEM,
							XMLData.CODEDEVICEMACHINES,
							XMLData.CODEEXPENSE,
							XMLData.CODESTOREMACHINES,
							XMLData.CODESTATUSMACHINES,
							XMLData.CODELOCATIONMACHINES,
							XMLData.Classifications,
							XMLData.BPSDPM,
							XMLData.BPDETAIL,
							XMLData.Seller,
							XMLData.English,
							XMLData.Vietnamese,
							XMLData.Model,
							XMLData.Specifications,
							XMLData.Korean,
							XMLData.DocumentNo,
							XMLData.Quantiy,
							XMLData.PurchaseDate,
							XMLData.CODE,
							XMLData.IsUsed,
							 DATEADD(HH, -2, GETDATE()) AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							 DATEADD(HH, -2, GETDATE()) AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID,
							XMLData.UNIT
					FROM
							OPENXML(@idoc , @InsertTableName , 2)
							WITH  (
										OldCompanyCode INT,
										ID INT,
										BARCODESYSTEM NVARCHAR(100),
										CODEDEVICEMACHINES NVARCHAR(100),
										CODEEXPENSE NVARCHAR(100),
										CODESTOREMACHINES NVARCHAR(100),
										CODESTATUSMACHINES NVARCHAR(100),
										CODELOCATIONMACHINES NVARCHAR(100),
										Classifications NVARCHAR(50),
										BPSDPM  NVARCHAR(50),
										BPDETAIL NVARCHAR(50),
										Seller NVARCHAR(50),
										English  NVARCHAR(50), 
										Vietnamese NVARCHAR(50),
										Model NVARCHAR(50),
										Specifications NVARCHAR(50),
										Korean NVARCHAR(50),  
										DocumentNo NVARCHAR(100),   
										Quantiy INT,
										PurchaseDate DATETIME,
										CODE NVARCHAR(50),
										IsUsed BIT,
										CreateDateTime  DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime  DATETIMEOFFSET,
										ChangeUserID VARCHAR(20),
										UNIT NVARCHAR(20)
									) XMLData
				) AS SourceTable

			ON
				(
					TargetTable.ID = SourceTable.ID
				)
	 
	 	WHEN MATCHED THEN

				UPDATE SET

					BARCODESYSTEM = SourceTable.BARCODESYSTEM,
					CODEDEVICEMACHINES = SourceTable.CODEDEVICEMACHINES,
					CODEEXPENSE = SourceTable.CODEEXPENSE,
					CODESTOREMACHINES = SourceTable.CODESTOREMACHINES,
					CODESTATUSMACHINES = SourceTable.CODESTATUSMACHINES,
					CODELOCATIONMACHINES = SourceTable.CODELOCATIONMACHINES,
					Classifications = SourceTable.Classifications,
					BPSDPM = SourceTable.BPSDPM,
					BPDETAIL = SourceTable.BPDETAIL,
					Seller = SourceTable.Seller,
					English = SourceTable.English,
					Vietnamese = SourceTable.Vietnamese,
					Model = SourceTable.Model,
					Specifications = SourceTable.Specifications,
					Korean = SourceTable.Korean,
					DocumentNo = SourceTable.DocumentNo,
					Quantiy = SourceTable.Quantiy,
					PurchaseDate = SourceTable.PurchaseDate,
					CODE = SourceTable.CODE,
					IsUsed = SourceTable.IsUsed,
					ChangeDateTime = SourceTable.ChangeDateTime,
					ChangeUserID = SourceTable.ChangeUserID
		
		WHEN NOT MATCHED THEN

				INSERT
					(
					BARCODESYSTEM,
					CODEDEVICEMACHINES,
					CODEEXPENSE,
					CODESTOREMACHINES,
					CODESTATUSMACHINES,
					CODELOCATIONMACHINES,
					Classifications,
					BPSDPM,
					BPDETAIL,
					Seller,
					English, 
					Vietnamese,  
					Model,
					Specifications,
					Korean,  
					DocumentNo,   
					Quantiy,
					PurchaseDate,
					CODE,
					IsUsed,
					CreateDateTime,
					CreateUserID
					)
				VALUES
					(
							@NewCode,
							SourceTable.CODEDEVICEMACHINES,
							SourceTable.CODEEXPENSE,
							SourceTable.CODESTOREMACHINES,
							SourceTable.CODESTATUSMACHINES,
							SourceTable.CODELOCATIONMACHINES,
							SourceTable.Classifications,
							SourceTable.BPSDPM,
							SourceTable.BPDETAIL,
							SourceTable.Seller,
							SourceTable.English,
							SourceTable.Vietnamese,
							SourceTable.Model,
							SourceTable.Specifications,
							SourceTable.Korean,
							SourceTable.DocumentNo,
							SourceTable.Quantiy,
							SourceTable.PurchaseDate,
							SourceTable.CODE,
							SourceTable.IsUsed,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID
							
					);

	-- Process Update Table
	 MERGE STB_VN_DEVICEMACHINES AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN XMLData.OldCompanyCode IS NULL THEN XMLData.ID
							    ELSE XMLData.OldCompanyCode
							END AS OldCompanyCode,
							XMLData.ID,
							XMLData.BARCODESYSTEM,
							XMLData.CODEDEVICEMACHINES,
							XMLData.CODEEXPENSE,
							XMLData.CODESTOREMACHINES,
							XMLData.CODESTATUSMACHINES,
							XMLData.CODELOCATIONMACHINES,
							XMLData.Classifications,
							XMLData.BPSDPM,
							XMLData.BPDETAIL,
							XMLData.Seller,
							XMLData.English,
							XMLData.Vietnamese,
							XMLData.Model,
							XMLData.Specifications,
							XMLData.Korean,
							XMLData.DocumentNo,
							XMLData.Quantiy,
							XMLData.PurchaseDate,
							XMLData.CODE,
							XMLData.IsUsed,
							 DATEADD(HH, -2, GETDATE()) AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							 DATEADD(HH, -2, GETDATE()) AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
							
					FROM
							OPENXML(@idoc , @UpdateTableName , 2)
							WITH  (
										OldCompanyCode INT,
										ID INT,
										BARCODESYSTEM NVARCHAR(100),
										CODEDEVICEMACHINES NVARCHAR(100),
										CODEEXPENSE NVARCHAR(100),
										CODESTOREMACHINES NVARCHAR(100),
										CODESTATUSMACHINES NVARCHAR(100),
										CODELOCATIONMACHINES NVARCHAR(100),
										Classifications NVARCHAR(50),
										BPSDPM  NVARCHAR(50),
										BPDETAIL NVARCHAR(50),
										Seller NVARCHAR(50),
										English  NVARCHAR(50), 
										Vietnamese NVARCHAR(50),  
										Model NVARCHAR(50),
										Specifications NVARCHAR(50),
										Korean NVARCHAR(50),  
										DocumentNo NVARCHAR(100),   
										Quantiy INT,
										PurchaseDate DATETIME,
										CODE NVARCHAR(50),
										IsUsed BIT,
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

					BARCODESYSTEM = SourceTable.BARCODESYSTEM,
					CODEDEVICEMACHINES = SourceTable.CODEDEVICEMACHINES,
					CODEEXPENSE = SourceTable.CODEEXPENSE,
					CODESTOREMACHINES = SourceTable.CODESTOREMACHINES,
					CODESTATUSMACHINES = SourceTable.CODESTATUSMACHINES,
					CODELOCATIONMACHINES = SourceTable.CODELOCATIONMACHINES,
					Classifications = SourceTable.Classifications,
					BPSDPM = SourceTable.BPSDPM,
					BPDETAIL = SourceTable.BPDETAIL,
					Seller = SourceTable.Seller,
					English = SourceTable.English,
					Vietnamese = SourceTable.Vietnamese,
					Model = SourceTable.Model,
					Specifications = SourceTable.Model,
					Korean = SourceTable.Korean,
					DocumentNo = SourceTable.DocumentNo,
					Quantiy = SourceTable.Quantiy,
					PurchaseDate = SourceTable.PurchaseDate,
					CODE = SourceTable.CODE,
					IsUsed = SourceTable.IsUsed,
					ChangeDateTime = SourceTable.ChangeDateTime,
					ChangeUserID = SourceTable.ChangeUserID

WHEN NOT MATCHED THEN

				INSERT
					(
					BARCODESYSTEM,
					CODEDEVICEMACHINES,
					CODEEXPENSE,
					CODESTOREMACHINES,
					CODESTATUSMACHINES,
					CODELOCATIONMACHINES,
					Classifications,
					BPSDPM,
					BPDETAIL,
					Seller,
					English, 
					Vietnamese,  
					Model,
					Specifications,
					Korean,  
					DocumentNo,   
					Quantiy,
					PurchaseDate,
					CODE,
					IsUsed,
					CreateDateTime,
					CreateUserID
					)
				VALUES
					(
							@NewCode,
							SourceTable.CODEDEVICEMACHINES,
							SourceTable.CODEEXPENSE,
							SourceTable.CODESTOREMACHINES,
							SourceTable.CODESTATUSMACHINES,
							SourceTable.CODELOCATIONMACHINES,
							SourceTable.Classifications,
							SourceTable.BPSDPM,
							SourceTable.BPDETAIL,
							SourceTable.Seller,
							SourceTable.English,
							SourceTable.Vietnamese,
							SourceTable.Model,
							SourceTable.Specifications,
							SourceTable.Korean,
							SourceTable.DocumentNo,
							SourceTable.Quantiy,
							SourceTable.PurchaseDate,
							SourceTable.CODE,
							SourceTable.IsUsed,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID
							
					);


	-- Process Delete Table
            MERGE STB_VN_DEVICEMACHINES AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN XMLData.OldCompanyCode IS NULL THEN XMLData.ID
							    ELSE XMLData.OldCompanyCode
							END AS OldCompanyCode,
							XMLData.ID,
							XMLData.BARCODESYSTEM,
							XMLData.CODEDEVICEMACHINES,
							XMLData.CODEEXPENSE,
							XMLData.CODESTOREMACHINES,
							XMLData.CODESTATUSMACHINES,
							XMLData.CODELOCATIONMACHINES,
							XMLData.Classifications,
							XMLData.BPSDPM,
							XMLData.BPDETAIL,
							XMLData.Seller,
							XMLData.English,
							XMLData.Vietnamese,
							XMLData.Model,
							XMLData.Specifications,
							XMLData.Korean,
							XMLData.DocumentNo,
							XMLData.Quantiy,
							XMLData.PurchaseDate,
							XMLData.CODE,
							XMLData.IsUsed,
							 DATEADD(HH, -2, GETDATE()) AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							 DATEADD(HH, -2, GETDATE()) AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
							
					FROM
							OPENXML(@idoc , @DeleteTableName , 2)
							WITH  (
										OldCompanyCode INT,
										ID INT,
										BARCODESYSTEM NVARCHAR(100),
										CODEDEVICEMACHINES NVARCHAR(100),
										CODEEXPENSE NVARCHAR(100),
										CODESTOREMACHINES NVARCHAR(100),
										CODESTATUSMACHINES NVARCHAR(100),
										CODELOCATIONMACHINES NVARCHAR(100),
										Classifications NVARCHAR(50),
										BPSDPM  NVARCHAR(50),
										BPDETAIL NVARCHAR(50),
										Seller NVARCHAR(50),
										English  NVARCHAR(50), 
										Vietnamese NVARCHAR(50),  
										Model NVARCHAR(50),
										Specifications NVARCHAR(50),
										Korean NVARCHAR(50),  
										DocumentNo NVARCHAR(100),   
										Quantiy INT,
										PurchaseDate DATETIME,
										CODE NVARCHAR(50),
										IsUsed BIT,
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
									XMLData.BARCODESYSTEM,
									XMLData.CODEDEVICEMACHINES,
									XMLData.CODEEXPENSE,
									XMLData.CODESTOREMACHINES,
									XMLData.CODESTATUSMACHINES,
									XMLData.CODELOCATIONMACHINES,
									XMLData.Classifications,
									XMLData.BPSDPM,
									XMLData.BPDETAIL,
									XMLData.Seller,
									XMLData.English,
									XMLData.Vietnamese,
									XMLData.Model,
									XMLData.Specifications,
									XMLData.Korean,
									XMLData.DocumentNo,
									XMLData.Quantiy,
									XMLData.PurchaseDate,
									XMLData.CODE,
									XMLData.IsUsed,
									XMLData.CreateDateTime,
									XMLData.CreateUserID,
									XMLData.ChangeDateTime,
									XMLData.ChangeUserID
									
							FROM
									OPENXML(@idoc , @InsertTableName , 2)
							        WITH  (
											 OldCompanyCode INT,
											 ID INT,
											BARCODESYSTEM NVARCHAR(100),
											CODEDEVICEMACHINES NVARCHAR(100),
											CODEEXPENSE NVARCHAR(100),
											CODESTOREMACHINES NVARCHAR(100),
											CODESTATUSMACHINES NVARCHAR(100),
											CODELOCATIONMACHINES NVARCHAR(100),
											Classifications NVARCHAR(50),
											BPSDPM  NVARCHAR(50),
											BPDETAIL NVARCHAR(50),
											Seller NVARCHAR(50),
											English  NVARCHAR(50), 
											Vietnamese NVARCHAR(50),  
											Model NVARCHAR(50),
											Specifications NVARCHAR(50),
											Korean NVARCHAR(50),  
											DocumentNo NVARCHAR(100),   
											Quantiy INT,
											PurchaseDate DATETIME,
											CODE NVARCHAR(50),
											IsUsed BIT,
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
									XMLData.BARCODESYSTEM,
									XMLData.CODEDEVICEMACHINES,
									XMLData.CODEEXPENSE,
									XMLData.CODESTOREMACHINES,
									XMLData.CODESTATUSMACHINES,
									XMLData.CODELOCATIONMACHINES,
									XMLData.Classifications,
									XMLData.BPSDPM,
									XMLData.BPDETAIL,
									XMLData.Seller,
									XMLData.English,
									XMLData.Vietnamese,
									XMLData.Model,
									XMLData.Specifications,
									XMLData.Korean,
									XMLData.DocumentNo,
									XMLData.Quantiy,
									XMLData.PurchaseDate,
									XMLData.CODE,
									XMLData.IsUsed,
									XMLData.CreateDateTime,
									XMLData.CreateUserID,
									XMLData.ChangeDateTime,
									XMLData.ChangeUserID
									
							FROM
									OPENXML(@idoc , @UpdateTableName , 2)
							        WITH  (
											 OldCompanyCode INT,
											 ID INT,
											BARCODESYSTEM NVARCHAR(100),
											CODEDEVICEMACHINES NVARCHAR(100),
											CODEEXPENSE NVARCHAR(100),
											CODESTOREMACHINES NVARCHAR(100),
											CODESTATUSMACHINES NVARCHAR(100),
											CODELOCATIONMACHINES NVARCHAR(100),
											Classifications NVARCHAR(50),
											BPSDPM  NVARCHAR(50),
											BPDETAIL NVARCHAR(50),
											Seller NVARCHAR(50),
											English  NVARCHAR(50), 
											Vietnamese NVARCHAR(50),  
											Model NVARCHAR(50),
											Specifications NVARCHAR(50),
											Korean NVARCHAR(50),  
											DocumentNo NVARCHAR(100),   
											Quantiy INT,
											PurchaseDate DATETIME,
											CODE NVARCHAR(50),
											IsUsed BIT,
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
								    XMLData.BARCODESYSTEM,
									XMLData.CODEDEVICEMACHINES,
									XMLData.CODEEXPENSE,
									XMLData.CODESTOREMACHINES,
									XMLData.CODESTATUSMACHINES,
									XMLData.CODELOCATIONMACHINES,
									XMLData.Classifications,
									XMLData.BPSDPM,
									XMLData.BPDETAIL,
									XMLData.Seller,
									XMLData.English,
									XMLData.Vietnamese,
									XMLData.Model,
									XMLData.Specifications,
									XMLData.Korean,
									XMLData.DocumentNo,
									XMLData.Quantiy,
									XMLData.PurchaseDate,
									XMLData.CODE,
									XMLData.IsUsed,
									XMLData.CreateDateTime,
									XMLData.CreateUserID,
									XMLData.ChangeDateTime,
									XMLData.ChangeUserID
								
							FROM
									OPENXML(@idoc , @DeleteTableName , 2)
							        WITH  (
											 OldCompanyCode VARCHAR(20),
											 ID INT,
											 BARCODESYSTEM NVARCHAR(100),
											CODEDEVICEMACHINES NVARCHAR(100),
											CODEEXPENSE NVARCHAR(100),
											CODESTOREMACHINES NVARCHAR(100),
											CODESTATUSMACHINES NVARCHAR(100),
											CODELOCATIONMACHINES NVARCHAR(100),
											Classifications NVARCHAR(50),
											BPSDPM  NVARCHAR(50),
											BPDETAIL NVARCHAR(50),
											Seller NVARCHAR(50),
											English  NVARCHAR(50), 
											Vietnamese NVARCHAR(50),  
											Model NVARCHAR(50),
											Specifications NVARCHAR(50),
											Korean NVARCHAR(50),  
											DocumentNo NVARCHAR(100),   
											Quantiy INT,
											PurchaseDate DATETIME,
											CODE NVARCHAR(50),
											IsUsed BIT,
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
								 @BARCODESYSTEM,
								 @CODEDEVICEMACHINES,
								 @CODEEXPENSE,
								 @CODESTOREMACHINES,
								 @CODESTATUSMACHINES,
								 @CODELOCATIONMACHINES,
								 @Classifications,
								 @BPSDPM,
								 @BPDETAIL,
								 @Seller,
								 @English, 
								 @Vietnamese,  
								 @Model,
								 @Specifications,
								 @Korean,  
							 	 @DocumentNo,   
								 @Quantiy,
								 @PurchaseDate,
								 @CODE,
								 @IsUsed,
								 @CreateDateTime,
								 @CreateUserID,
								 @ChangeDateTime,
								 @ChangeUserID

			  IF @@FETCH_STATUS <> 0 BEGIN
					BREAK
				END

		IF @IUD_FLAG = 'INSERT' BEGIN

                    IF EXISTS (SELECT 1 FROM STB_VN_DEVICEMACHINES WHERE ID = @OldCompanyCode) BEGIN
						RAISERROR('Duplicate Data : KeyField = %s', 16, 1, @OldCompanyCode)
					END
			 IF @IsAutoKey = 0 BEGIN
						EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_VN_DEVICEMACHINES', @OldCompanyCode OUTPUT		
						

		INSERT INTO STB_VN_DEVICEMACHINES
						(
						   	BARCODESYSTEM,
							CODEDEVICEMACHINES,
							CODEEXPENSE,
							CODESTOREMACHINES,
							CODESTATUSMACHINES,
							CODELOCATIONMACHINES,
							Classifications,
							BPSDPM,
							BPDETAIL,
							Seller,
							English, 
							Vietnamese,  
							Model,
							Specifications,
							Korean,  
							DocumentNo,   
							Quantiy,
							PurchaseDate,
							CODE,
							IsUsed,
						    CreateDateTime,
						    CreateUserID,
						    ChangeDateTime,
						    ChangeUserID
							
						)
						VALUES
						(
						@NewCode,
						@CODEDEVICEMACHINES,
						@CODEEXPENSE,
						@CODESTOREMACHINES,
						@CODESTATUSMACHINES,
						@CODELOCATIONMACHINES,
						@Classifications,
						@BPSDPM,
						@BPDETAIL,
						@Seller,
						@English, 
						@Vietnamese,  
						@Model,
						@Specifications,
						@Korean,  
						@DocumentNo,   
						@Quantiy,
						@PurchaseDate,
						@CODE,
						'1',
						    DATEADD(HH, -2, GETDATE()),
						    @pProcessUserID,
						    @ChangeDateTime,
						    @ChangeUserID
							
						)

END ELSE IF @IUD_FLAG = 'UPDATE' BEGIN

 UPDATE STB_VN_DEVICEMACHINES

						SET
							BARCODESYSTEM =   CASE
						                WHEN @BARCODESYSTEM IS NOT NULL THEN @BARCODESYSTEM
						                ELSE BARCODESYSTEM
						            END,
						CODEDEVICEMACHINES =   CASE
						                WHEN @CODEDEVICEMACHINES IS NOT NULL THEN @CODEDEVICEMACHINES
						                ELSE CODEDEVICEMACHINES
						            END,

							 CODEEXPENSE =   CASE
						                WHEN @CODEEXPENSE IS NOT NULL THEN @CODEEXPENSE
						                ELSE CODEEXPENSE
						            END,

							 CODESTOREMACHINES =   CASE
						                WHEN @CODESTOREMACHINES IS NOT NULL THEN @CODESTOREMACHINES
						                ELSE CODESTOREMACHINES
						            END,
							 CODELOCATIONMACHINES =   CASE
						                WHEN @CODELOCATIONMACHINES IS NOT NULL THEN @CODELOCATIONMACHINES
						                ELSE CODELOCATIONMACHINES
						            END,
						 CODESTATUSMACHINES =   CASE
						                WHEN @CODESTATUSMACHINES IS NOT NULL THEN @CODESTATUSMACHINES
						                ELSE CODESTATUSMACHINES
						            END,

						 Classifications =   CASE
						                WHEN @Classifications IS NOT NULL THEN @Classifications
						                ELSE Classifications
						            END,

						 BPSDPM =   CASE
						                WHEN @BPSDPM IS NOT NULL THEN @BPSDPM
						                ELSE BPSDPM
						            END,

						 BPDETAIL =   CASE
						                WHEN @BPDETAIL IS NOT NULL THEN @BPDETAIL
						                ELSE BPDETAIL
						            END,

										 Seller =   CASE
						                WHEN @Seller IS NOT NULL THEN @Seller
						                ELSE Seller
						            END,

										 Vietnamese =   CASE
						                WHEN @Vietnamese IS NOT NULL THEN @Vietnamese
						                ELSE Vietnamese
						            END,

										Model = CASE
										WHEN @Model IS NOT NULL then @Model
										ELSE Model
										END,

									Specifications = CASE
										WHEN @Specifications IS NOT NULL then @Specifications
										ELSE Specifications
										END,
									

										 English =   CASE
						                WHEN @English IS NOT NULL THEN @English
						                ELSE English
						            END,

										 Korean =   CASE
						                WHEN @Korean IS NOT NULL THEN @Korean
						                ELSE Korean
						            END,

									 DocumentNo =   CASE
						                WHEN @DocumentNo IS NOT NULL THEN @DocumentNo
						                ELSE DocumentNo
						            END,


									 Quantiy =   CASE
						                WHEN @Quantiy IS NOT NULL THEN @Quantiy
						                ELSE Quantiy
						            END,

									 PurchaseDate =   CASE
						                WHEN @PurchaseDate IS NOT NULL THEN @PurchaseDate
						                ELSE PurchaseDate
						            END,

									CODE =   CASE
						                WHEN @CODE IS NOT NULL THEN @CODE
						                ELSE CODE
						            END,

										IsUsed =   CASE
						                WHEN @IsUsed IS NOT NULL THEN @IsUsed
						                ELSE IsUsed
						            END,

						    ChangeDateTime = DATEADD(HH, -2, GETDATE()),
						    ChangeUserID = @pProcessUserID
						
					
					WHERE
						    ID = @OldCompanyCode


			  END ELSE IF @IUD_FLAG = 'DELETE' BEGIN
                        DELETE FROM STB_VN_DEVICEMACHINES
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

