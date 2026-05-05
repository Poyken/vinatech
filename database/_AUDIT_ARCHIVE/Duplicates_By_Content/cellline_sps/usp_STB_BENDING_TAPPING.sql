CREATE PROC [dbo].[usp_STB_BENDING_TAPPING]
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

	
			

		DECLARE @CODEPRODUCTION NVARCHAR(50)
		DECLARE @LOTNO NVARCHAR(50)
		DECLARE @NAMEERROR NVARCHAR(50)
		DECLARE @QTYERROR INT
		DECLARE @CODEERROR NVARCHAR
		DECLARE @QTYLOTNO  INT
		DECLARE @TYPESS NVARCHAR(50)
		DECLARE @CreateDateTime DATETIME
		DECLARE @CreateUserID  NVARCHAR(50)
		DECLARE @ChangeDateTime DATETIME
		DECLARE @ChangeUserID NVARCHAR(50)
		DECLARE @MachineName VARCHAR(50)
		DECLARE @ModelCode VARCHAR(50)
		
		EXEC SmartFramework.dbo.usp_GetSerialRule 
			@pTableName = 'STB_VN_BENDING_TAPPING',
			@pIsAutoKey = @IsAutoKey OUTPUT,
			@pIsLoopIUD = @IsLoopIUD OUTPUT,
			@pPrefixData = @PrefixString OUTPUT,
			@pSerialLen = @SerialLen OUTPUT

    IF @IsAutoKey = 0 AND @IsLoopIUD = 0 BEGIN
   
	    EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml

		BEGIN TRY

	-- Process Insert Table
			 MERGE STB_VN_BENDING_TAPPING AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN XMLData.OldCompanyCode IS NULL THEN XMLData.ID
							    ELSE XMLData.OldCompanyCode
							END AS OldCompanyCode,
							XMLData.ID,
							XMLData.CODEPRODUCTION,
							XMLData.LOTNO,
							XMLData.NAMEERROR,
							XMLData.QTYERROR,
							XMLData.TYPESS,
							XMLData.QTYLOTNO,
							 DATEADD(HH, 0, GETDATE()) AS CreateDateTime,
							XMLData.CreateUserID,
							 DATEADD(HH, 0, GETDATE()) AS ChangeDateTime,
							XMLData.ChangeUserID,
							XMLData.MachineName,
							XMLData.ModelCode

							
					FROM
							OPENXML(@idoc , @InsertTableName , 2)
							WITH  (
										OldCompanyCode INT,
										ID INT,
										CODEPRODUCTION NVARCHAR(50),
										LOTNO NVARCHAR(50),
										NAMEERROR NVARCHAR(50),
										QTYERROR INT,
										TYPESS NVARCHAR(50),
										QTYLOTNO INT,
										CreateDateTime  DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime  DATETIMEOFFSET,
										ChangeUserID VARCHAR(20),
										MachineName VARCHAR(50),
										ModelCode VARCHAR(50)
									) XMLData
				) AS SourceTable

			ON
				(
					TargetTable.ID = SourceTable.ID
				)

WHEN MATCHED THEN
				UPDATE SET
					CODEPRODUCTION = SourceTable.CODEPRODUCTION,
					LOTNO = SourceTable.LOTNO,
					NAMEERROR = SourceTable.NAMEERROR,
					QTYERROR = SourceTable.QTYERROR,
					TYPESS = SourceTable.TYPESS,
					QTYLOTNO = SourceTable.QTYLOTNO,
					ChangeDateTime = SourceTable.ChangeDateTime,
					ChangeUserID = SourceTable.ChangeUserID,
					MachineName = SourceTable.MachineName,
					ModelCode = SourceTable.ModelCode
WHEN NOT MATCHED THEN
				INSERT
					(
						CODEPRODUCTION,
						LOTNO,
						NAMEERROR,
						QTYERROR,
						TYPESS,
						QTYLOTNO,
						CreateDateTime,
						CreateUserID,
						MachineName,
						ModelCode						
					)
				VALUES
					(
							SourceTable.CODEPRODUCTION,
							SourceTable.LOTNO,
							SourceTable.NAMEERROR,
							SourceTable.QTYERROR,
							SourceTable.TYPESS,
							SourceTable.QTYLOTNO,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID,
							SourceTable.MachineName,
							SourceTable.ModelCode
					);

		-- Process Update Table
	 MERGE STB_VN_BENDING_TAPPING AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN XMLData.OldCompanyCode IS NULL THEN XMLData.ID
							    ELSE XMLData.OldCompanyCode
							END AS OldCompanyCode,
							XMLData.ID,
							XMLData.CODEPRODUCTION,
							XMLData.LOTNO,
							XMLData.NAMEERROR,
							XMLData.QTYERROR,
							XMLData.TYPESS,
							XMLData.QTYLOTNO,
							 DATEADD(HH, 0, GETDATE()) AS CreateDateTime,
							XMLData.CreateUserID,
							 DATEADD(HH, 0, GETDATE()) AS ChangeDateTime,
							XMLData.ChangeUserID,
							XMLData.MachineName,
							XMLData.ModelCode
							
					FROM
							OPENXML(@idoc , @UpdateTableName , 2)
							WITH  (
										OldCompanyCode INT,
										ID INT,
										CODEPRODUCTION NVARCHAR(50),
										LOTNO NVARCHAR(50),
										NAMEERROR NVARCHAR(50),
										QTYERROR INT,
										TYPESS NVARCHAR(50),
										QTYLOTNO INT,
										CreateDateTime  DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime  DATETIMEOFFSET,
										ChangeUserID VARCHAR(20),
										MachineName VARCHAR(50),
										ModelCode VARCHAR(50)
									) XMLData
				) AS SourceTable
			ON
				(
					TargetTable.ID = SourceTable.ID
				)	

WHEN MATCHED THEN
				UPDATE SET
					CODEPRODUCTION = SourceTable.CODEPRODUCTION,
					LOTNO = SourceTable.LOTNO,
					NAMEERROR = SourceTable.NAMEERROR,
					QTYERROR = SourceTable.QTYERROR,
					TYPESS = SourceTable.TYPESS,
					QTYLOTNO = SourceTable.QTYLOTNO,
					ChangeDateTime = SourceTable.ChangeDateTime,
					ChangeUserID = SourceTable.ChangeUserID,
					MachineName = SourceTable.MachineName,
					ModelCode = SourceTable.ModelCode
					
			WHEN NOT MATCHED THEN

		INSERT
					(
						CODEPRODUCTION,
						LOTNO,
						NAMEERROR,
						QTYERROR,
						TYPESS,
						QTYLOTNO,
						CreateDateTime,
						CreateUserID,
						MachineName,
						ModelCode
					)
				VALUES
					(
							SourceTable.CODEPRODUCTION,
							SourceTable.LOTNO,
							SourceTable.NAMEERROR,
							SourceTable.QTYERROR,
							SourceTable.TYPESS,
							SourceTable.QTYLOTNO,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID,
							SourceTable.MachineName,
							SourceTable.ModelCode
					);


-- Process Delete Table
            MERGE STB_VN_BENDING_TAPPING AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN XMLData.OldCompanyCode IS NULL THEN XMLData.ID
							    ELSE XMLData.OldCompanyCode
							END AS OldCompanyCode,
							XMLData.ID,
							XMLData.CODEPRODUCTION,
							XMLData.LOTNO,
							XMLData.NAMEERROR,
							XMLData.QTYERROR,
							XMLData.TYPESS,
							XMLData.QTYLOTNO,
							 DATEADD(HH, 0, GETDATE()) AS CreateDateTime,
							XMLData.CreateUserID,
							 DATEADD(HH, 0, GETDATE()) AS ChangeDateTime,
							XMLData.ChangeUserID,
							XMLData.MachineName,
							XMLData.ModelCode
							
					FROM
							OPENXML(@idoc , @DeleteTableName , 2)
							WITH  (
										OldCompanyCode INT,
										ID INT,
										CODEPRODUCTION NVARCHAR(50),
										LOTNO NVARCHAR(50),
										NAMEERROR NVARCHAR(50),
										QTYERROR INT,
										TYPESS NVARCHAR(50),
										QTYLOTNO INT,
										CreateDateTime  DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime  DATETIMEOFFSET,
										ChangeUserID VARCHAR(20),
										MachineName VARCHAR(50),
										ModelCode VARCHAR(50)
										
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
									XMLData.CODEPRODUCTION,
									XMLData.LOTNO,
									XMLData.NAMEERROR,
									XMLData.QTYERROR,
									XMLData.TYPESS,
									XMLData.QTYLOTNO,
									XMLData.CreateDateTime,
									XMLData.CreateUserID,
									XMLData.ChangeDateTime,
									XMLData.ChangeUserID,
									XMLData.MachineName,
									XMLData.ModelCode
								
							FROM
									OPENXML(@idoc , @InsertTableName , 2)
							        WITH  (
											 OldCompanyCode INT,
											 ID INT,
											 CODEPRODUCTION NVARCHAR(50),
											 LOTNO NVARCHAR(50),
											 NAMEERROR NVARCHAR(50),
											 QTYERROR INT,
											 TYPESS NVARCHAR(50),
											 QTYLOTNO INT,
											 CreateDateTime  DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime  DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20),
												MachineName VARCHAR(50),
												ModelCode VARCHAR(50)
											
											) XMLData
UNION ALL
SELECT
									'UPDATE' AS IUD_FLAG,
									CASE 
										WHEN XMLData.OldCompanyCode IS NULL THEN XMLData.ID
										ELSE XMLData.OldCompanyCode
									END AS OldCompanyCode,
									XMLData.ID,
									XMLData.CODEPRODUCTION,
									XMLData.LOTNO,
									XMLData.NAMEERROR,
									XMLData.QTYERROR,
									XMLData.TYPESS,
									XMLData.QTYLOTNO,
									XMLData.CreateDateTime,
									XMLData.CreateUserID,
									XMLData.ChangeDateTime,
									XMLData.ChangeUserID,
									XMLData.MachineName,
									XMLData.ModelCode

									
							FROM
									OPENXML(@idoc , @UpdateTableName , 2)
							        WITH  (
											 OldCompanyCode INT,
											 ID INT,
											 CODEPRODUCTION NVARCHAR(50),
											 LOTNO NVARCHAR(50),
											 NAMEERROR NVARCHAR(50),
											 QTYERROR INT,
											 TYPESS NVARCHAR(50),
											 QTYLOTNO INT,
											CreateDateTime  DATETIMEOFFSET,
											CreateUserID VARCHAR(20),
											ChangeDateTime  DATETIMEOFFSET,
											ChangeUserID VARCHAR(20),
											MachineName VARCHAR(50),
											ModelCode VARCHAR(50)
											) XMLData
UNION ALL
SELECT
									'DELETE' AS IUD_FLAG,
									CASE 
										WHEN XMLData.OldCompanyCode IS NULL THEN XMLData.ID
										ELSE XMLData.OldCompanyCode
									END AS OldCompanyCode,
									XMLData.ID,
									XMLData.CODEPRODUCTION,
									XMLData.LOTNO,
									XMLData.NAMEERROR,
									XMLData.QTYERROR,
									XMLData.TYPESS,
									XMLData.QTYLOTNO,
									XMLData.CreateDateTime,
									XMLData.CreateUserID,
									XMLData.ChangeDateTime,
									XMLData.ChangeUserID,
									XMLData.MachineName,
									XMLData.ModelCode
									
							FROM
									OPENXML(@idoc , @DeleteTableName , 2)
							        WITH  (
											 OldCompanyCode VARCHAR(20),
											 ID INT,
											 CODEPRODUCTION NVARCHAR(50),
											 LOTNO NVARCHAR(50),
											 NAMEERROR NVARCHAR(50),
											 QTYERROR INT,
											 TYPESS NVARCHAR(50),
											 QTYLOTNO INT,
											 CreateDateTime  DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime  DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20),
												MachineName VARCHAR(50),
												ModelCode VARCHAR(50)
											) XMLData
					 OPEN SourceData

					 
					   WHILE 1 = 1 BEGIN
                FETCH NEXT FROM SourceData INTO
								 @IUD_FLAG,
								 @OldCompanyCode,
								 @CODEPRODUCTION,
								 @LOTNO,
								 @NAMEERROR,
								 @QTYERROR,
								 @TYPESS,
								 @QTYLOTNO,
								 @CreateDateTime,
								 @CreateUserID,
								 @ChangeDateTime,
								 @ChangeUserID  ,
								@MachineName,
								@ModelCode
			  IF @@FETCH_STATUS <> 0 BEGIN
					BREAK
				END
  IF @IUD_FLAG = 'INSERT' BEGIN

					--	DECLARE @ccount INT = 0
					--	DECLARE @LotNonew1 VARCHAR(20) = ''
					--	DECLARE @LotNonew2 VARCHAR(20) = ''
					--	DECLARE @LotNonew3 VARCHAR(20) = ''
					--	DECLARE @LotNonew4 VARCHAR(20) = ''
					--	DECLARE @LotNonew5 VARCHAR(20) = ''
					--	DECLARE @LotNonew6 VARCHAR(20) = ''

					--		select @LotNonew1 = NewBarcode
					--		from STB_LotChangeMaterialHistory  WITH(NOLOCK)
					--		where OldBarcode=@LOTNO 
	
					--		select @LotNonew2 = NewBarcode
					--		from STB_LotChangeMaterialHistory  WITH(NOLOCK)
					--		where OldBarcode=@LotNonew1 

					--		select @LotNonew3 = NewBarcode
					--		from STB_LotChangeMaterialHistory  WITH(NOLOCK)
					--		where OldBarcode=@LotNonew2 

					--		select @LotNonew4 = NewBarcode
					--		from STB_LotChangeMaterialHistory  WITH(NOLOCK)
					--		where OldBarcode=@LotNonew3 

					--		select @LotNonew5 = NewBarcode
					--		from STB_LotChangeMaterialHistory  WITH(NOLOCK)
					--		where OldBarcode=@LotNonew4 

					--		select @LotNonew6 = NewBarcode
					--		from STB_LotChangeMaterialHistory  WITH(NOLOCK)
					--		where OldBarcode=@LotNonew5 

					--select @ccount = count(*)
					--from STB_SetInfo WITH(NOLOCK)
					--where Barcode in (@LOTNO,@LotNonew1,@LotNonew2,@LotNonew3,@LotNonew4,@LotNonew5,@LotNonew6)

					----Khong cho insert ma Lot ko co tren he thong
					--if(@ccount<=0)
					--begin
					--	declare @errr VARCHAR(100) = 'Ma Lot khong ton tai tren he thong, hoac ma Lot sai!'
					--	RAISERROR(@errr, 16, 1)
					--	break
					--	return
					--end

					----lay ma Lot moi
					--select @LOTNO = barcode
					--from STB_SetInfo WITH(NOLOCK)
					--where Barcode in (@LOTNO,@LotNonew1,@LotNonew2,@LotNonew3,@LotNonew4,@LotNonew5,@LotNonew6)


                    IF EXISTS (SELECT 1 FROM STB_VN_BENDING_TAPPING WHERE ID = @OldCompanyCode) BEGIN
						RAISERROR('Duplicate Data : KeyField = %s', 16, 1, @OldCompanyCode)
					END
			 IF @IsAutoKey = 0 BEGIN
						EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_VN_BENDING_TAPPING', @OldCompanyCode OUTPUT


						INSERT INTO STB_VN_BENDING_TAPPING
						(
							CODEPRODUCTION,
							LOTNO,
							NAMEERROR,
							QTYERROR,
							TYPESS,
							QTYLOTNO,
						    CreateDateTime,
						    CreateUserID,
						    ChangeDateTime,
						    ChangeUserID,
							MachineName,
							ModelCode
						)
						VALUES
						(
							@CODEPRODUCTION,
							@LOTNO,
							@NAMEERROR,
							@QTYERROR,
							@TYPESS,
							@QTYLOTNO,
						    DATEADD(HH, 0, GETDATE()),
						     @CreateUserID,
						    @ChangeDateTime,
						    @ChangeUserID,
							@MachineName,
							@ModelCode
						)

END ELSE IF @IUD_FLAG = 'UPDATE' BEGIN 
 UPDATE STB_VN_BENDING_TAPPING 
						SET 
						
						 CODEPRODUCTION =   CASE 
						                WHEN @CODEPRODUCTION IS NOT NULL THEN @CODEPRODUCTION 
						                ELSE CODEPRODUCTION 
								 END,

						 LOTNO =   CASE
						                WHEN @LOTNO IS NOT NULL THEN @LOTNO
						                ELSE LOTNO
								 END,

								  NAMEERROR =   CASE
						                WHEN @NAMEERROR IS NOT NULL THEN @NAMEERROR
						                ELSE NAMEERROR
								 END,

								  QTYERROR =   CASE
						                WHEN @QTYERROR IS NOT NULL THEN @QTYERROR
						                ELSE QTYERROR
								 END,

								  TYPESS =   CASE
						                WHEN @TYPESS IS NOT NULL THEN @TYPESS
						                ELSE TYPESS
								 END,

								 QTYLOTNO = CASE 
										WHEN @QTYLOTNO IS NOT NULL THEN @QTYLOTNO
										ELSE QTYLOTNO
										END,

								 MachineName = CASE 
										WHEN @MachineName IS NOT NULL THEN @MachineName
										ELSE MachineName
										END,

								 ModelCode = CASE 
										WHEN @ModelCode IS NOT NULL THEN @ModelCode
										ELSE ModelCode
										END,

						    ChangeDateTime = DATEADD(HH, 0, GETDATE()),
						    ChangeUserID = @CreateUserID
						
					WHERE
						    ID = @OldCompanyCode

						  END ELSE IF @IUD_FLAG = 'DELETE' BEGIN
                        DELETE FROM STB_VN_BENDING_TAPPING
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