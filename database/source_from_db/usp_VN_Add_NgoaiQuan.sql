CREATE PROC [dbo].[usp_VN_Add_NgoaiQuan]
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
		DECLARE @iDoc INT
		DECLARE @OldCompanyCode INT

		DECLARE @INPUTQTY INT
		DECLARE @OK INT
		DECLARE @NGUOC INT
		DECLARE @HUHONG INT
		DECLARE @XUOC INT
		DECLARE @BIENSAC INT
		DECLARE @THUYCHAN INT
		DECLARE @LOICHAN INT
		DECLARE @BEPTHAN INT
		DECLARE @BEPDAY INT
		DECLARE @NHIEMBAN INT
		DECLARE @BOCNGUOC INT
		DECLARE @NHANBOCNG INT
		DECLARE @VITRILO NVARCHAR(50)
		DECLARE @VITRICURLING NVARCHAR(50)
		DECLARE @DIVAT NVARCHAR(50)
		DECLARE @TOTALNG INT
		DECLARE @CreateDateTime DATETIME
		DECLARE @CreateUserID  NVARCHAR(50)
		DECLARE @ChangeDateTime DATETIME
		DECLARE @ChangeUserID NVARCHAR(50)
		DECLARE @NAMEERROR NVARCHAR(50)
		DECLARE @QTYERROR INT
		DECLARE @LOTNO NVARCHAR(50)

		EXEC SmartFramework.dbo.usp_GetSerialRule 
			@pTableName = 'STB_NgoaiQuan',
			@pIsAutoKey = @IsAutoKey OUTPUT,
			@pIsLoopIUD = @IsLoopIUD OUTPUT,
			@pPrefixData = @PrefixString OUTPUT,
			@pSerialLen = @SerialLen OUTPUT

    IF @IsAutoKey = 0 AND @IsLoopIUD = 0 BEGIN
   
	    EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml

	BEGIN TRY

	-- Process Insert Table
			 MERGE STB_NgoaiQuan AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN XMLData.OldCompanyCode IS NULL THEN XMLData.ID
							    ELSE XMLData.OldCompanyCode
							END AS OldCompanyCode,
							XMLData.ID,
							--XMLData.INPUTQTY,
							--XMLData.OK,
							XMLData.LOTNO,
							--XMLData.NGUOC,
							--XMLData.HUHONG,
							--XMLData.XUOC,
							--XMLData.BIENSAC,
							--XMLData.THUYCHAN,
							--XMLData.LOICHAN,
							--XMLData.BEPTHAN,
							--XMLData.BEPDAY,
							--XMLData.NHIEMBAN,
							--XMLData.BOCNGUOC,
							--XMLData.NHANBOCNG,
							XMLData.VITRILO,
							XMLData.VITRICURLING,
							XMLData.NAMEERROR,
							XMLData.QTYERROR,
							--XMLData.DIVAT,
							--XMLData.TOTALNG,
							 DATEADD(HH, -2, GETDATE()) AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							 DATEADD(HH, -2, GETDATE()) AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
							
					FROM
							OPENXML(@idoc , @InsertTableName , 2)
							WITH  (
										OldCompanyCode INT,
										ID INT,
										--INPUTQTY int,
										--OK int,
										LOTNO NVARCHAR(50),
										--NGUOC int,
										--HUHONG int,
										--XUOC int,
										--BIENSAC int,
										--THUYCHAN int,
										--LOICHAN int,
										--BEPTHAN int,
										--BEPDAY int,
										--NHIEMBAN int ,
										--BOCNGUOC int,
										--NHANBOCNG int,
										VITRILO nvarchar(50),
										VITRICURLING nvarchar(50),
										NAMEERROR NVARCHAR(50),
										QTYERROR INT,
										--DIVAT nvarchar(50),
										--TOTALNG int,
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
					--INPUTQTY = SourceTable.INPUTQTY,
					--OK = SourceTable.OK,
					--NGUOC = SourceTable.NGUOC,
					--HUHONG = SourceTable.HUHONG,
					--XUOC = SourceTable.XUOC,
					--BIENSAC = SourceTable.BIENSAC,
					--THUYCHAN = SourceTable.THUYCHAN,
					--LOICHAN = SourceTable.LOICHAN,
					--BEPTHAN = SourceTable.BEPTHAN,
					--BEPDAY = SourceTable.BEPDAY,
					--NHIEMBAN = SourceTable.NHIEMBAN,
					--BOCNGUOC = SourceTable.BOCNGUOC,
					--NHANBOCNG = SourceTable.NHANBOCNG,
					VITRILO = SourceTable.VITRILO,
					VITRICURLING = SourceTable.VITRICURLING,
					NAMEERROR = SourceTable.NAMEERROR,
					QTYERROR = SourceTable.QTYERROR,
					--DIVAT = SourceTable.DIVAT,
					--TOTALNG = SourceTable.NGUOC + SourceTable.HUHONG + SourceTable.XUOC + SourceTable.BIENSAC + SourceTable.THUYCHAN + SourceTable.LOICHAN + SourceTable.BEPTHAN + SourceTable.BEPDAY +  SourceTable.NHIEMBAN + SourceTable.BOCNGUOC + SourceTable.NHANBOCNG,
					ChangeDateTime = SourceTable.ChangeDateTime,
					ChangeUserID = SourceTable.ChangeUserID
WHEN NOT MATCHED THEN
				INSERT
					(
						--INPUTQTY,
						--OK,
						LOTNO,
						--NGUOC,
						--HUHONG,
						--XUOC,
						--BIENSAC,
						--THUYCHAN,
						--LOICHAN,
						--BEPTHAN,
						--BEPDAY,
						--NHIEMBAN,
						--BOCNGUOC,
						--NHANBOCNG,
						VITRILO,
						VITRICURLING,
						NAMEERROR,
						QTYERROR,
						--DIVAT,
						--TOTALNG,
						CreateDateTime,
						CreateUserID
						
					)
				VALUES
					(
							--SourceTable.INPUTQTY,
							--SourceTable.OK,
							SourceTable.LOTNO,
							--SourceTable.NGUOC,
							--SourceTable.HUHONG,
							--SourceTable.XUOC,
							--SourceTable.BIENSAC,
							--SourceTable.THUYCHAN,
							--SourceTable.LOICHAN,
							--SourceTable.BEPTHAN,
							--SourceTable.BEPDAY,
							--SourceTable.NHIEMBAN,
							--SourceTable.BOCNGUOC,
							--SourceTable.NHANBOCNG,
							SourceTable.VITRILO,
							SourceTable.VITRICURLING,
							SourceTable.NAMEERROR,
							SourceTable.QTYERROR,
							--SourceTable.DIVAT,
							--SourceTable.TOTALNG,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID
					);

		-- Process Update Table
	 MERGE STB_NgoaiQuan AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN XMLData.OldCompanyCode IS NULL THEN XMLData.ID
							    ELSE XMLData.OldCompanyCode
							END AS OldCompanyCode,
							XMLData.ID,
							--XMLData.INPUTQTY,
							--XMLData.OK,
							XMLData.LOTNO,
							--XMLData.NGUOC,
							--XMLData.HUHONG,
							--XMLData.XUOC,
							--XMLData.BIENSAC,
							--XMLData.THUYCHAN,
							--XMLData.LOICHAN,
							--XMLData.BEPTHAN,
							--XMLData.BEPDAY,
							--XMLData.NHIEMBAN,
							--XMLData.BOCNGUOC,
							--XMLData.NHANBOCNG,
							XMLData.VITRILO,
							XMLData.VITRICURLING,
							XMLData.NAMEERROR,
							XMLData.QTYERROR,

							--XMLData.DIVAT,
							--XMLData.TOTALNG,
							 DATEADD(HH, -2, GETDATE()) AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							 DATEADD(HH, -2, GETDATE()) AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
							
					FROM
							OPENXML(@idoc , @UpdateTableName , 2)
							WITH  (
										OldCompanyCode INT,
										ID INT,
										--INPUTQTY int,
										--OK int,
										LOTNO NVARCHAR(50),
										--NGUOC int,
										--HUHONG int,
										--XUOC int,
										--BIENSAC int,
										--THUYCHAN int,
										--LOICHAN int,
										--BEPTHAN int,
										--BEPDAY int,
										--NHIEMBAN int ,
										--BOCNGUOC int,
										--NHANBOCNG int,
										VITRILO nvarchar(50),
										VITRICURLING nvarchar(50),
										NAMEERROR NVARCHAR(50),
										QTYERROR INT,

										--DIVAT nvarchar(50),
										--TOTALNG int,
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
					--INPUTQTY = SourceTable.INPUTQTY,
					--OK = SourceTable.OK,
					--NGUOC = SourceTable.NGUOC,
					--HUHONG = SourceTable.HUHONG,
					--XUOC = SourceTable.XUOC,
					--BIENSAC = SourceTable.BIENSAC,
					--THUYCHAN = SourceTable.THUYCHAN,
					--LOICHAN =SourceTable.LOICHAN,
					--BEPTHAN = SourceTable.BEPTHAN,
					--BEPDAY = SourceTable.BEPDAY,
					--NHIEMBAN = SourceTable.NHIEMBAN,
					--BOCNGUOC = SourceTable.BOCNGUOC,
					--NHANBOCNG = SourceTable.NHANBOCNG,
					VITRILO = SourceTable.VITRILO,
					VITRICURLING = SourceTable.VITRICURLING,
					NAMEERROR = SourceTable.NAMEERROR,
					QTYERROR = SourceTable.QTYERROR,
					--DIVAT = SourceTable.DIVAT,
					--TOTALNG = SourceTable.TOTALNG,
					ChangeDateTime = SourceTable.ChangeDateTime,
					ChangeUserID = SourceTable.ChangeUserID
					
			WHEN NOT MATCHED THEN

		INSERT
					(
						--INPUTQTY,
						--OK,
						LOTNO,
						--NGUOC,
						--HUHONG,
						--XUOC,
						--BIENSAC,
						--THUYCHAN,
						--LOICHAN,
						--BEPTHAN,
						--BEPDAY,
						--NHIEMBAN,
						--BOCNGUOC,
						--NHANBOCNG,
						VITRILO,
						VITRICURLING,
						NAMEERROR,
						QTYERROR,
						--DIVAT,
						--TOTALNG,
						CreateDateTime,
						CreateUserID
					)
				VALUES
					(
							--SourceTable.INPUTQTY,
							--SourceTable.OK,
							SourceTable.LOTNO,
							--SourceTable.NGUOC,
							--SourceTable.HUHONG,
							--SourceTable.XUOC,
							--SourceTable.BIENSAC,
							--SourceTable.THUYCHAN,
							--SourceTable.LOICHAN,
							--SourceTable.BEPTHAN,
							--SourceTable.BEPDAY,
							--SourceTable.NHIEMBAN,
							--SourceTable.BOCNGUOC,
							--SourceTable.NHANBOCNG,
							SourceTable.VITRILO,
							SourceTable.VITRICURLING,
							SourceTable.NAMEERROR,
							SourceTable.QTYERROR,
							--SourceTable.DIVAT,
							--SourceTable.TOTALNG,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID
							
					);

-- Process Delete Table
            MERGE STB_NgoaiQuan AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN XMLData.OldCompanyCode IS NULL THEN XMLData.ID
							    ELSE XMLData.OldCompanyCode
							END AS OldCompanyCode,
							XMLData.ID,
							XMLData.LOTNO,
							--XMLData.INPUTQTY,
							--XMLData.OK,
							--XMLData.NGUOC,
							--XMLData.HUHONG,
							--XMLData.XUOC,
							--XMLData.BIENSAC,
							--XMLData.THUYCHAN,
							--XMLData.LOICHAN,
							--XMLData.BEPTHAN,
							--XMLData.BEPDAY,
							--XMLData.NHIEMBAN,
							--XMLData.BOCNGUOC,
							--XMLData.NHANBOCNG,
							XMLData.VITRILO,
							XMLData.VITRICURLING,
							XMLData.NAMEERROR,
							XMLData.QTYERROR,
							--XMLData.DIVAT,
							--XMLData.TOTALNG,
							 DATEADD(HH, -2, GETDATE()) AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							 DATEADD(HH, -2, GETDATE()) AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
							
					FROM
							OPENXML(@idoc , @DeleteTableName , 2)
							WITH  (
										OldCompanyCode INT,
										ID INT,
										LOTNO NVARCHAR(50),
										--INPUTQTY int,
										--OK int,
										--NGUOC int,
										--HUHONG int,
										--XUOC int,
										--BIENSAC int,
										--THUYCHAN int,
										--LOICHAN int,
										--BEPTHAN int,
										--BEPDAY int,
										--NHIEMBAN int ,
										--BOCNGUOC int,
										--NHANBOCNG int,
										VITRILO nvarchar(50),
										VITRICURLING nvarchar(50),
										NAMEERROR NVARCHAR(50),
										QTYERROR INT,
										--DIVAT nvarchar(50),
										--TOTALNG int,
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
									XMLData.LOTNO,
									--XMLData.INPUTQTY,
									--XMLData.OK,
									--XMLData.NGUOC,
									--XMLData.HUHONG,
									--XMLData.XUOC,
									--XMLData.BIENSAC,
									--XMLData.THUYCHAN,
									--XMLData.LOICHAN,
									--XMLData.BEPTHAN,
									--XMLData.BEPDAY,
									--XMLData.NHIEMBAN,
									--XMLData.BOCNGUOC,
									--XMLData.NHANBOCNG,
									XMLData.VITRILO,
									XMLData.VITRICURLING,
									XMLData.NAMEERROR,
									XMLData.QTYERROR,
									--XMLData.DIVAT,
									--XMLData.TOTALNG,
									XMLData.CreateDateTime,
									XMLData.CreateUserID,
									XMLData.ChangeDateTime,
									XMLData.ChangeUserID
								
							FROM
									OPENXML(@idoc , @InsertTableName , 2)
							        WITH  (
											 OldCompanyCode INT,
											 ID INT,
											 LOTNO NVARCHAR(50),
											-- INPUTQTY int,
											--OK int,
											--NGUOC int,
											--HUHONG int,
											--XUOC int,
											--BIENSAC int,
											--THUYCHAN int,
											--LOICHAN int,
											--BEPTHAN int,
											--BEPDAY int,
											--NHIEMBAN int ,
											--BOCNGUOC int,
											--NHANBOCNG int,
											VITRILO nvarchar(50),
											VITRICURLING nvarchar(50),
											NAMEERROR NVARCHAR(50),
											QTYERROR INT,
											--DIVAT nvarchar(50),
											--TOTALNG int,
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
									XMLData.LOTNO,
									--XMLData.INPUTQTY,
									--XMLData.OK,
									--XMLData.NGUOC,
									--XMLData.HUHONG,
									--XMLData.XUOC,
									--XMLData.BIENSAC,
									--XMLData.THUYCHAN,
									--XMLData.LOICHAN,
									--XMLData.BEPTHAN,
									--XMLData.BEPDAY,
									--XMLData.NHIEMBAN,
									--XMLData.BOCNGUOC,
									--XMLData.NHANBOCNG,
									XMLData.VITRILO,
									XMLData.VITRICURLING,
									XMLData.NAMEERROR,
									XMLData.QTYERROR,

									--XMLData.DIVAT,
									--XMLData.TOTALNG,
									XMLData.CreateDateTime,
									XMLData.CreateUserID,
									XMLData.ChangeDateTime,
									XMLData.ChangeUserID
									
							FROM
									OPENXML(@idoc , @UpdateTableName , 2)
							        WITH  (
											 OldCompanyCode INT,
											 ID INT,
											 LOTNO NVARCHAR(50),
											--INPUTQTY int,
											--OK int,
											--NGUOC int,
											--HUHONG int,
											--XUOC int,
											--BIENSAC int,
											--THUYCHAN int,
											--LOICHAN int,
											--BEPTHAN int,
											--BEPDAY int,
											--NHIEMBAN int ,
											--BOCNGUOC int,
											--NHANBOCNG int,
											VITRILO nvarchar(50),
											VITRICURLING nvarchar(50),
											NAMEERROR NVARCHAR(50),
											QTYERROR INT,
											--DIVAT nvarchar(50),
											--TOTALNG int,
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
									XMLData.LOTNO,
									--XMLData.INPUTQTY,
									--XMLData.OK,
									--XMLData.NGUOC,
									--XMLData.HUHONG,
									--XMLData.XUOC,
									--XMLData.BIENSAC,
									--XMLData.THUYCHAN,
									--XMLData.LOICHAN,
									--XMLData.BEPTHAN,
									--XMLData.BEPDAY,
									--XMLData.NHIEMBAN,
									--XMLData.BOCNGUOC,
									--XMLData.NHANBOCNG,
									XMLData.VITRILO,
									XMLData.VITRICURLING,
									XMLData.NAMEERROR,
									XMLData.QTYERROR,
									--XMLData.DIVAT,
									--XMLData.TOTALNG,
									XMLData.CreateDateTime,
									XMLData.CreateUserID,
									XMLData.ChangeDateTime,
									XMLData.ChangeUserID
									
							FROM
									OPENXML(@idoc , @DeleteTableName , 2)
							        WITH  (
											 OldCompanyCode VARCHAR(20),
											 ID INT,
											 LOTNO NVARCHAR(50),
											--INPUTQTY int,
											--OK int,
											--NGUOC int,
											--HUHONG int,
											--XUOC int,
											--BIENSAC int,
											--THUYCHAN int,
											--LOICHAN int,
											--BEPTHAN int,
											--BEPDAY int,
											--NHIEMBAN int ,
											--BOCNGUOC int,
											--NHANBOCNG int,
											VITRILO nvarchar(50),
											VITRICURLING nvarchar(50),
											NAMEERROR NVARCHAR(50),
											QTYERROR INT,

											--DIVAT nvarchar(50),
											--TOTALNG int,	
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
								 @LOTNO,
								 --@INPUTQTY,
								 --@OK,
								 --@NGUOC,
								 --@HUHONG,
								 --@XUOC,
								 --@BIENSAC,
								 --@THUYCHAN,
								 --@LOICHAN,
								 --@BEPTHAN,
								 --@BEPDAY,
								 --@NHIEMBAN,
								 --@BOCNGUOC,
								 --@NHANBOCNG,
								 @VITRILO,
								 @VITRICURLING,
								 
									@NAMEERROR,
									@QTYERROR,
																	 --@DIVAT,
								 --@TOTALNG,
								 @CreateDateTime,
								 @CreateUserID,
								 @ChangeDateTime,
								 @ChangeUserID
								

			  IF @@FETCH_STATUS <> 0 BEGIN
					BREAK
				END

		  IF @IUD_FLAG = 'INSERT' BEGIN

                    IF EXISTS (SELECT 1 FROM STB_NgoaiQuan WHERE ID = @OldCompanyCode) BEGIN
						RAISERROR('Duplicate Data : KeyField = %s', 16, 1, @OldCompanyCode)
					END
			 IF @IsAutoKey = 0 BEGIN
						EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_NgoaiQuan', @OldCompanyCode OUTPUT

						INSERT INTO STB_NgoaiQuan
						(
								LOTNO,
						 --   INPUTQTY,
							--OK,
							--NGUOC,
							--HUHONG,
							--XUOC,
							--BIENSAC,
							--THUYCHAN,
							--LOICHAN,
							--BEPTHAN,
							--BEPDAY,
							--NHIEMBAN,
							--BOCNGUOC,
							--NHANBOCNG,
							VITRILO,
							VITRICURLING,
							NAMEERROR,
						QTYERROR,
							--DIVAT,
							--TOTALNG,
						    CreateDateTime,
						    CreateUserID,
						    ChangeDateTime,
						    ChangeUserID
							
						)
						VALUES
						(
								@LOTNO,
								 --@INPUTQTY,
								 --@OK,
								 --@NGUOC,
								 --@HUHONG,
								 --@XUOC,
								 --@BIENSAC,
								 --@THUYCHAN,
								 --@LOICHAN,
								 --@BEPTHAN,
								 --@BEPDAY,
								 --@NHIEMBAN,
								 --@BOCNGUOC,
								 --@NHANBOCNG,
								 @VITRILO,
								 @VITRICURLING,
								 
								@NAMEERROR,
								@QTYERROR,
								 --@DIVAT,
								 --@TOTALNG,
						    DATEADD(HH, -2, GETDATE()),
						    @pProcessUserID,
						    @ChangeDateTime,
						    @ChangeUserID
						)

	END ELSE IF @IUD_FLAG = 'UPDATE' BEGIN
 UPDATE STB_NgoaiQuan
						SET
						--	INPUTQTY =   CASE
						--                WHEN @INPUTQTY IS NOT NULL THEN @INPUTQTY
						--                ELSE INPUTQTY
						--            END,
						--OK =   CASE
						--                WHEN @OK IS NOT NULL THEN @OK
						--                ELSE OK
						--            END,

							-- NGUOC =   CASE
						 --               WHEN @NGUOC IS NOT NULL THEN @NGUOC
						 --               ELSE NGUOC
						 --           END,

							-- HUHONG =   CASE
						 --               WHEN @HUHONG IS NOT NULL THEN @HUHONG
						 --               ELSE HUHONG
						 --           END,
							-- XUOC =   CASE
						 --               WHEN @XUOC IS NOT NULL THEN @XUOC
						 --               ELSE XUOC
						 --           END,
						 --BIENSAC =   CASE
						 --               WHEN @BIENSAC IS NOT NULL THEN @BIENSAC
						 --               ELSE BIENSAC
						 --           END,
						 --THUYCHAN =   CASE
						 --               WHEN @THUYCHAN IS NOT NULL THEN @THUYCHAN
						 --               ELSE THUYCHAN
						 --           END,
						 --LOICHAN =   CASE
						 --               WHEN @LOICHAN IS NOT NULL THEN @LOICHAN
						 --               ELSE LOICHAN
						 --           END,
						 --BEPTHAN =   CASE
						 --               WHEN @BEPTHAN IS NOT NULL THEN @BEPTHAN
						 --               ELSE BEPTHAN
						 --           END,
						 --BEPDAY =   CASE
						 --               WHEN @BEPDAY IS NOT NULL THEN @BEPDAY
						 --               ELSE BEPDAY
							--		 END,
						 --NHIEMBAN =   CASE
						 --               WHEN @NHIEMBAN IS NOT NULL THEN @NHIEMBAN
						 --               ELSE NHIEMBAN
							--		 END,

						 --BOCNGUOC =   CASE
						 --               WHEN @BOCNGUOC IS NOT NULL THEN @BOCNGUOC
						 --               ELSE BOCNGUOC
							--	 END,

						 --NHANBOCNG =   CASE
						 --               WHEN @NHANBOCNG IS NOT NULL THEN @NHANBOCNG
						 --               ELSE NHANBOCNG
							--	 END,

						 VITRILO =   CASE
						                WHEN @VITRILO IS NOT NULL THEN @VITRILO
						                ELSE VITRILO
								 END,

						 VITRICURLING =   CASE
						                WHEN @VITRICURLING IS NOT NULL THEN @VITRICURLING
						                ELSE VITRICURLING
								 END,

								  NAMEERROR =   CASE
						                WHEN @NAMEERROR IS NOT NULL THEN @NAMEERROR
						                ELSE NAMEERROR
								 END,

								  QTYERROR =   CASE
						                WHEN @QTYERROR IS NOT NULL THEN @QTYERROR
						                ELSE QTYERROR
								 END,

						 --DIVAT =   CASE
						 --               WHEN @DIVAT IS NOT NULL THEN @DIVAT
						 --               ELSE DIVAT
							--	 END,

						 --TOTALNG =   CASE
						 --               WHEN @TOTALNG IS NOT NULL THEN @NHANBOCNG + @BOCNGUOC + @NHIEMBAN + @BEPDAY + @BEPTHAN + @LOICHAN + @THUYCHAN + @BIENSAC + @XUOC + @HUHONG + @NGUOC
						 --               ELSE TOTALNG
							--	 END,

						    ChangeDateTime = DATEADD(HH, -2, GETDATE()),
						    ChangeUserID = @pProcessUserID
						
					WHERE
						    ID = @OldCompanyCode

						  END ELSE IF @IUD_FLAG = 'DELETE' BEGIN
                        DELETE FROM STB_NgoaiQuan
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