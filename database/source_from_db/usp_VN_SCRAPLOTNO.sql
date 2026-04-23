CREATE PROC usp_VN_SCRAPLOTNO
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

		DECLARE @OldCompanyCode NVARCHAR(100)
		DECLARE @CODESCRAPLOT NVARCHAR(100)
		DECLARE @LOTNO NVARCHAR(50)
		DECLARE @NVLTPBTP NVARCHAR(50)
		DECLARE @MODEL NVARCHAR(50)
		DECLARE @PRODUCTIONNAME NVARCHAR(100)
		DECLARE @UNIT NVARCHAR(20)
		DECLARE @QtyActual INT
		DECLARE @QtyMove INT
		DECLARE @StausWait NVARCHAR(50)
		DECLARE @StatusCancel NVARCHAR(50)
		DECLARE @ReasonCancel NVARCHAR(50)
		DECLARE @CreateDateTime DATETIME
		DECLARE @CreateUserID NVARCHAR(50)
		DECLARE @ChangeDateTime DATETIME
		DECLARE @ChangeUserID NVARCHAR(50)
		DECLARE @iDoc INT

			 EXEC SmartFramework.dbo.usp_GetSerialRule 
			@pTableName = 'STB_VN_SCRAPLOT',
			@pIsAutoKey = @IsAutoKey OUTPUT,
			@pIsLoopIUD = @IsLoopIUD OUTPUT,
			@pPrefixData = @PrefixString OUTPUT,
			@pSerialLen = @SerialLen OUTPUT

    IF @IsAutoKey = 0 AND @IsLoopIUD = 0 BEGIN
   
	    EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml

			BEGIN TRY
			-- Process Insert Table
			 MERGE STB_VN_SCRAPLOT AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN XMLData.OldCompanyCode IS NULL THEN XMLData.ID
							    ELSE XMLData.OldCompanyCode
							END AS OldCompanyCode,
							XMLData.ID,
							XMLData.CODESCRAPLOT,
							XMLData.LOTNO,
							XMLData.NVLTPBTP,
							XMLData.MODEL,
							XMLData.PRODUCTIONNAME,
							XMLData.UNIT,
							XMLData.QtyActual,
							XMLData.QtyMove,
							XMLData.StausWait,
							XMLData.StatusCancel,
							XMLData.ReasonCancel,
							 DATEADD(HH, -2, GETDATE()) AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							 DATEADD(HH, -2, GETDATE()) AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
							
					FROM
							OPENXML(@idoc , @InsertTableName , 2)
							WITH  (
										OldCompanyCode INT,
										ID INT,
										CODESCRAPLOT nvarchar(100),
										LOTNO nvarchar(50),
										NVLTPBTP nvarchar(50),
										MODEL nvarchar(50),
										PRODUCTIONNAME nvarchar(100),
										UNIT nvarchar(20),
										QtyActual int,
										QtyMove int,
										StausWait nvarchar(50),
										StatusCancel nvarchar(50),
										ReasonCancel nvarchar(500),
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

					CODESCRAPLOT = SourceTable.CODESCRAPLOT,
					LOTNO = SourceTable.LOTNO,
					NVLTPBTP = SourceTable.NVLTPBTP,
					MODEL = SourceTable.MODEL,
					PRODUCTIONNAME = SourceTable.PRODUCTIONNAME,
					UNIT = SourceTable.UNIT,
					QtyActual = SourceTable.QtyActual,
					QtyMove = SourceTable.QtyMove,
					StausWait = SourceTable.StausWait,
					StatusCancel = SourceTable.StatusCancel,
					ReasonCancel = SourceTable.ReasonCancel,
					ChangeDateTime = SourceTable.ChangeDateTime,
					ChangeUserID = SourceTable.ChangeUserID

	 	WHEN NOT MATCHED THEN

				INSERT
					(
							CODESCRAPLOT,
							LOTNO,
							NVLTPBTP,
							MODEL,
							PRODUCTIONNAME,
							UNIT,
							QtyActual,
							QtyMove,
							StausWait,
							StatusCancel,
							ReasonCancel,
							CreateDateTime,
							CreateUserID
					)
				VALUES
					(
							SourceTable.CODESCRAPLOT,
							SourceTable.LOTNO,
							SourceTable.NVLTPBTP,
							SourceTable.MODEL,
							SourceTable.PRODUCTIONNAME,
							SourceTable.UNIT,
							SourceTable.QtyActual,
							SourceTable.QtyMove,
							SourceTable.StausWait,
							SourceTable.StatusCancel,
							SourceTable.ReasonCancel,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID
					);

 MERGE STB_VN_SCRAPLOT AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN XMLData.OldCompanyCode IS NULL THEN XMLData.ID
							    ELSE XMLData.OldCompanyCode
							END AS OldCompanyCode,
							XMLData.ID,
							XMLData.CODESCRAPLOT,
							XMLData.LOTNO,
							XMLData.NVLTPBTP,
							XMLData.MODEL,
							XMLData.PRODUCTIONNAME,
							XMLData.UNIT,
							XMLData.QtyActual,
							XMLData.QtyMove,
							XMLData.StausWait,
							XMLData.StatusCancel,
							XMLData.ReasonCancel,
							 DATEADD(HH, -2, GETDATE()) AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							 DATEADD(HH, -2, GETDATE()) AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
							
					FROM
							OPENXML(@idoc , @UpdateTableName , 2)
							WITH  (
										OldCompanyCode INT,
										ID INT,
										CODESCRAPLOT nvarchar(100) ,
										LOTNO nvarchar(50),
										NVLTPBTP nvarchar(50),
										MODEL nvarchar(50),
										PRODUCTIONNAME nvarchar(100),
										UNIT nvarchar(20),
										QtyActual int,
										QtyMove int,
										StausWait nvarchar(50),
										StatusCancel nvarchar(50),
										ReasonCancel nvarchar(500),
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

					CODESCRAPLOT = SourceTable.CODESCRAPLOT,
					LOTNO = SourceTable.LOTNO,
					NVLTPBTP = SourceTable.NVLTPBTP,
					MODEL = SourceTable.MODEL,
					PRODUCTIONNAME = SourceTable.PRODUCTIONNAME,
					UNIT = SourceTable.UNIT,
					QtyActual = SourceTable.QtyActual,
					QtyMove = SourceTable.QtyMove,
					StausWait = SourceTable.StausWait,
					StatusCancel = SourceTable.StatusCancel,
					ReasonCancel = SourceTable.ReasonCancel,
					ChangeDateTime = SourceTable.ChangeDateTime,
					ChangeUserID = SourceTable.ChangeUserID


					WHEN NOT MATCHED THEN
					INSERT
					(
							CODESCRAPLOT,
							LOTNO,
							NVLTPBTP,
							MODEL,
							PRODUCTIONNAME,
							UNIT,
							QtyActual,
							QtyMove,
							StausWait,
							StatusCancel,
							ReasonCancel,
							CreateDateTime,
							CreateUserID
					)
				VALUES
					(
							SourceTable.CODESCRAPLOT,
							SourceTable.LOTNO,
							SourceTable.NVLTPBTP,
							SourceTable.MODEL,
							SourceTable.PRODUCTIONNAME,
							SourceTable.UNIT,
							SourceTable.QtyActual,
							SourceTable.QtyMove,
							SourceTable.StausWait,
							SourceTable.StatusCancel,
							SourceTable.ReasonCancel,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID
					);

						-- Process Delete Table
            MERGE STB_VN_SCRAPLOT AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN XMLData.OldCompanyCode IS NULL THEN XMLData.ID
							    ELSE XMLData.OldCompanyCode
							END AS OldCompanyCode,
							XMLData.ID,
							XMLData.CODESCRAPLOT,
							XMLData.LOTNO,
							XMLData.NVLTPBTP,
							XMLData.MODEL,
							XMLData.PRODUCTIONNAME,
							XMLData.UNIT,
							XMLData.QtyActual,
							XMLData.QtyMove,
							XMLData.StausWait,
							XMLData.StatusCancel,
							XMLData.ReasonCancel,
							 DATEADD(HH, -2, GETDATE()) AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							 DATEADD(HH, -2, GETDATE()) AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
							
					FROM
							OPENXML(@idoc , @DeleteTableName , 2)
							WITH  (
										OldCompanyCode INT,
										ID INT,
										CODESCRAPLOT nvarchar(100),
										LOTNO nvarchar(50),
										NVLTPBTP nvarchar(50),
										MODEL nvarchar(50),
										PRODUCTIONNAME nvarchar(100),
										UNIT nvarchar(20),
										QtyActual int,
										QtyMove int,
										StausWait nvarchar(50),
										StatusCancel nvarchar(50),
										ReasonCancel nvarchar(500),
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
									XMLData.CODESCRAPLOT,
									XMLData.LOTNO,
									XMLData.NVLTPBTP,
									XMLData.MODEL,
									XMLData.PRODUCTIONNAME,
									XMLData.UNIT,
									XMLData.QtyActual,
									XMLData.QtyMove,
									XMLData.StausWait,
									XMLData.StatusCancel,
									XMLData.ReasonCancel,
									XMLData.CreateDateTime,
									XMLData.CreateUserID,
									XMLData.ChangeDateTime,
									XMLData.ChangeUserID
									
							FROM
									OPENXML(@idoc , @InsertTableName , 2)
							        WITH  (
												OldCompanyCode INT,
												ID INT,
												CODESCRAPLOT nvarchar(100),
												LOTNO nvarchar(50),
												NVLTPBTP nvarchar(50),
												MODEL nvarchar(50),
												PRODUCTIONNAME nvarchar(100),
												UNIT nvarchar(20),
												QtyActual int,
												QtyMove int,
												StausWait nvarchar(50),
												StatusCancel nvarchar(50),
												ReasonCancel nvarchar(500),
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
									XMLData.CODESCRAPLOT,
									XMLData.LOTNO,
									XMLData.NVLTPBTP,
									XMLData.MODEL,
									XMLData.PRODUCTIONNAME,
									XMLData.UNIT,
									XMLData.QtyActual,
									XMLData.QtyMove,
									XMLData.StausWait,
									XMLData.StatusCancel,
									XMLData.ReasonCancel,
									XMLData.CreateDateTime,
									XMLData.CreateUserID,
									XMLData.ChangeDateTime,
									XMLData.ChangeUserID
									
							FROM
									OPENXML(@idoc , @UpdateTableName , 2)
							        WITH  (
											 OldCompanyCode INT,
											 ID INT,
											 	CODESCRAPLOT nvarchar(100),
												LOTNO nvarchar(50),
												NVLTPBTP nvarchar(50),
												MODEL nvarchar(50),
												PRODUCTIONNAME nvarchar(100),
												UNIT nvarchar(20),
												QtyActual int,
												QtyMove int,
												StausWait nvarchar(50),
												StatusCancel nvarchar(50),
												ReasonCancel nvarchar(500),
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
								    XMLData.CODESCRAPLOT,
									XMLData.LOTNO,
									XMLData.NVLTPBTP,
									XMLData.MODEL,
									XMLData.PRODUCTIONNAME,
									XMLData.UNIT,
									XMLData.QtyActual,
									XMLData.QtyMove,
									XMLData.StausWait,
									XMLData.StatusCancel,
									XMLData.ReasonCancel,
									XMLData.CreateDateTime,
									XMLData.CreateUserID,
									XMLData.ChangeDateTime,
									XMLData.ChangeUserID
								
							FROM
									OPENXML(@idoc , @DeleteTableName , 2)
							        WITH  (
												OldCompanyCode VARCHAR(20),
												ID INT,
												CODESCRAPLOT nvarchar(100),
												LOTNO nvarchar(50),
												NVLTPBTP nvarchar(50),
												MODEL nvarchar(50),
												PRODUCTIONNAME nvarchar(100),
												UNIT nvarchar(20),
												QtyActual int,
												QtyMove int,
												StausWait nvarchar(50),
												StatusCancel nvarchar(50),
												ReasonCancel nvarchar(500),
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
								 @CODESCRAPLOT,
								 @LOTNO,
								 @NVLTPBTP,
								 @MODEL,
								 @PRODUCTIONNAME,
								 @UNIT,
								 @QtyActual,
								 @QtyMove,
								 @StausWait,
								 @StatusCancel,
								 @ReasonCancel,
								 @CreateDateTime,
								 @CreateUserID,
								 @ChangeDateTime,
								 @ChangeUserID

			  IF @@FETCH_STATUS <> 0 BEGIN
					BREAK
				END

	IF @IUD_FLAG = 'INSERT' BEGIN

                    IF EXISTS (SELECT 1 FROM STB_VN_SCRAPLOT WHERE ID = @OldCompanyCode) BEGIN
						RAISERROR('Duplicate Data : KeyField = %s', 16, 1, @OldCompanyCode)
					END

			 IF @IsAutoKey = 0 BEGIN
						EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_VN_SCRAPLOT', @OldCompanyCode OUTPUT		

		INSERT INTO STB_VN_SCRAPLOT
						(
								
							CODESCRAPLOT,
							LOTNO,
							NVLTPBTP,
							MODEL,
							PRODUCTIONNAME,
							UNIT,
							QtyActual,
							QtyMove,
							StausWait,
							StatusCancel,
							ReasonCancel,
						    CreateDateTime,
						    CreateUserID,
						    ChangeDateTime,
						    ChangeUserID
						)
						VALUES
						(
							@CODESCRAPLOT,
							@LOTNO,
							@NVLTPBTP,
							@MODEL,
							@PRODUCTIONNAME,
							@UNIT,
							@QtyActual,
							@QtyMove,
							@StausWait,
							@StatusCancel,
							@ReasonCancel,
						    DATEADD(HH, -2, GETDATE()),
						    @pProcessUserID,
						    @ChangeDateTime,
						    @ChangeUserID
						)

END ELSE IF @IUD_FLAG = 'UPDATE' BEGIN

 UPDATE STB_VN_SCRAPLOT

						SET
							CODESCRAPLOT =   CASE
						                WHEN @CODESCRAPLOT IS NOT NULL THEN @CODESCRAPLOT
						                ELSE CODESCRAPLOT
						            END,
						LOTNO =   CASE
						                WHEN @LOTNO IS NOT NULL THEN @LOTNO
						                ELSE LOTNO
						            END,

							 NVLTPBTP =   CASE
						                WHEN @NVLTPBTP IS NOT NULL THEN @NVLTPBTP
						                ELSE NVLTPBTP
						            END,

							 MODEL =   CASE
						                WHEN @MODEL IS NOT NULL THEN @MODEL
						                ELSE MODEL
						            END,
							 PRODUCTIONNAME =   CASE
						                WHEN @PRODUCTIONNAME IS NOT NULL THEN @PRODUCTIONNAME
						                ELSE PRODUCTIONNAME
						            END,
						 UNIT =   CASE
						                WHEN @UNIT IS NOT NULL THEN @UNIT
						                ELSE UNIT
						            END,

						 QtyActual =   CASE
						                WHEN @QtyActual IS NOT NULL THEN @QtyActual
						                ELSE QtyActual
						            END,

						 QtyMove =   CASE
						                WHEN @QtyMove IS NOT NULL THEN @QtyMove
						                ELSE QtyMove
						            END,

						 StausWait =   CASE
						                WHEN @StausWait IS NOT NULL THEN @StausWait
						                ELSE StausWait
						            END,

										 StatusCancel =   CASE
						                WHEN @StatusCancel IS NOT NULL THEN @StatusCancel
						                ELSE StatusCancel
						            END,

										 ReasonCancel =   CASE
						                WHEN @ReasonCancel IS NOT NULL THEN @ReasonCancel
						                ELSE ReasonCancel
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