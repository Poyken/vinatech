CREATE PROC [dbo].[usp_VN_ActionFormEletroder]
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



	DECLARE @KeyID NVARCHAR(10)
	DECLARE @Year NVARCHAR(10)
	DECLARE @Moth NVARCHAR(5)
	DECLARE @Day NVARCHAR(5)
	DECLARE @Hour NVARCHAR(50)
	DECLARE @Minutes NVARCHAR(50)
	DECLARE @Second NVARCHAR(5)
	DECLARE @Publiccode NVARCHAR(50)
	SELECT @Hour = LEFT(GETDATE(),4)
	SELECT @Minutes = DATEPART(MINUTE,GETDATE())
	
	SET @KeyID = 'VNE'
	SET @Year= YEAR(GETDATE())
	SET @Moth = MONTH(GETDATE())
	SET @Hour = LEFT(GETDATE(),4)
	SET @Minutes = DATEPART(MINUTE,GETDATE())
	SET @Second = DATEPART(SECOND,GETDATE())
	SET @Day = DAY(GETDATE())

	

	SET @Publiccode = REPLACE(@KeyID + @Year + @Moth + @Day + @Hour + @Minutes + @Second,' ', '')



	DECLARE @OldCompanyCode INT
	DECLARE @GROUPID NVARCHAR(50)
	DECLARE @Materialcode NVARCHAR(50)
	DECLARE @MaterialName NVARCHAR(50)
	DECLARE @GoodQtyLength numeric(20,5)
	DECLARE @ActuallyQtyRequest numeric(20,5)
	DECLARE @Statuss BIT
	DECLARE @Line NVARCHAR(50)
	DECLARE @DateOutPut date
	DECLARE @SlittingWidth numeric(20,5)
	DECLARE @ElectrodeThick numeric(20,5)
	DECLARE @Description nvarchar(500)
	DECLARE @CreateDateTime DATETIME
	DECLARE @CreateUserID NVARCHAR(50)
	DECLARE @ChangeUserID NVARCHAR(50)
	DECLARE @ChangeDateTime DATETIME
	DECLARE @iDoc INT

	 EXEC SmartFramework.dbo.usp_GetSerialRule 
			@pTableName = 'STB_VN_ELECTRODE_REQUESTFORM',
			@pIsAutoKey = @IsAutoKey OUTPUT,
			@pIsLoopIUD = @IsLoopIUD OUTPUT,
			@pPrefixData = @PrefixString OUTPUT,
			@pSerialLen = @SerialLen OUTPUT

    IF @IsAutoKey = 0 AND @IsLoopIUD = 0 BEGIN
   
	    EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml

		BEGIN TRY
			-- Process Insert Table
			 MERGE STB_VN_ELECTRODE_REQUESTFORM AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN XMLData.OldCompanyCode IS NULL THEN XMLData.ID
							    ELSE XMLData.OldCompanyCode
							END AS OldCompanyCode,
							XMLData.ID,
							XMLData.GROUPID,
							XMLData.Materialcode,
							XMLData.MaterialName,
							XMLData.GoodQtyLength,
							XMLData.ActuallyQtyRequest,
							XMLData.Statuss,
							XMLData.Line,
							XMLData.DateOutPut,
							XMLData.SlittingWidth,
							XMLData.ElectrodeThick,
							XMLData.Description,
							 DATEADD(HH, -2, GETDATE()) AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							 DATEADD(HH, -2, GETDATE()) AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
							
					FROM
							OPENXML(@idoc , @InsertTableName , 2)
							WITH  (
										OldCompanyCode INT,
										ID INT,
										GROUPID NVARCHAR(50),
										Materialcode NVARCHAR(50),
										MaterialName NVARCHAR(50),
										GoodQtyLength numeric(20,5),
										ActuallyQtyRequest numeric(20,5),
										Statuss BIT,
										Line NVARCHAR(50),
										DateOutPut DATE,
										SlittingWidth NUMERIC(20,5),
										ElectrodeThick NUMERIC(20,5),
										Description nvarchar(500),
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
					Materialcode = @Publiccode,
					MaterialName = SourceTable.MaterialName,
					GoodQtyLength = SourceTable.GoodQtyLength,
					ActuallyQtyRequest = SourceTable.ActuallyQtyRequest,
					Statuss = 'False',
					Line = SourceTable.Line,
					DateOutPut = SourceTable.DateOutPut,
					SlittingWidth = SourceTable.SlittingWidth,
					ElectrodeThick = SourceTable.ElectrodeThick,
					Description = SourceTable.Description,
					ChangeDateTime = SourceTable.ChangeDateTime,
					ChangeUserID = SourceTable.ChangeUserID

				WHEN NOT MATCHED THEN

				INSERT
					(
						GROUPID,
						Materialcode,
						MaterialName,
						GoodQtyLength,
						ActuallyQtyRequest,
						Statuss,
						Line,
						DateOutPut,
						SlittingWidth,
						ElectrodeThick,
						Description,
						CreateDateTime,
						CreateUserID
						
					)
				VALUES
					(
							@Publiccode,
							SourceTable.Materialcode,
							SourceTable.MaterialName,
							SourceTable.GoodQtyLength,
							SourceTable.ActuallyQtyRequest,
							SourceTable.Statuss,
							SourceTable.Line,
							SourceTable.DateOutPut,
							SourceTable.SlittingWidth,
							SourceTable.ElectrodeThick,
							SourceTable.Description,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID
						
					);

						-- Process Update Table

	 MERGE STB_VN_ELECTRODE_REQUESTFORM AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN XMLData.OldCompanyCode IS NULL THEN XMLData.ID
							    ELSE XMLData.OldCompanyCode
							END AS OldCompanyCode,
							XMLData.ID,
							XMLData.GROUPID,
							XMLData.Materialcode,
							XMLData.MaterialName,
							XMLData.GoodQtyLength,
							XMLData.ActuallyQtyRequest,
							XMLData.Statuss,
							XMLData.Line,
							XMLData.DateOutPut,
							XMLData.SlittingWidth,
							XMLData.ElectrodeThick,
							XMLData.Description,
							 DATEADD(HH, -2, GETDATE()) AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							 DATEADD(HH, -2, GETDATE()) AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
						
					FROM
							OPENXML(@idoc , @UpdateTableName , 2)
							WITH  (
										OldCompanyCode INT,
										ID INT,
										GROUPID NVARCHAR(50),
										Materialcode NVARCHAR(50),
										MaterialName NVARCHAR(50),
										GoodQtyLength numeric(20,5),
										ActuallyQtyRequest numeric(20,5),
										Statuss BIT,
										Line NVARCHAR(50),
										DateOutPut DATE,
										SlittingWidth NUMERIC(20,5),
										ElectrodeThick NUMERIC(20,5),
										Description nvarchar(500),
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
					Materialcode = SourceTable.Materialcode,
					MaterialName = SourceTable.MaterialName,
					GoodQtyLength = SourceTable.GoodQtyLength,
					ActuallyQtyRequest = SourceTable.ActuallyQtyRequest,
					Statuss = 'False',
					Line = SourceTable.Line,
					DateOutPut = SourceTable.DateOutPut,
					SlittingWidth = SourceTable.SlittingWidth,
					ElectrodeThick = SourceTable.ElectrodeThick,
					Description = SourceTable.Description,
					ChangeDateTime = SourceTable.ChangeDateTime,
					ChangeUserID = SourceTable.ChangeUserID
					
			WHEN NOT MATCHED THEN

		INSERT
					(
						GROUPID,
						Materialcode,
						MaterialName,
						GoodQtyLength,
						ActuallyQtyRequest,
						Statuss,
						Line,
						DateOutPut,
						SlittingWidth,
						ElectrodeThick,
						Description,
						CreateDateTime,
						CreateUserID
						
					)
				VALUES
					(
							@Publiccode,
							SourceTable.Materialcode,
							SourceTable.MaterialName,
							SourceTable.GoodQtyLength,
							SourceTable.ActuallyQtyRequest,
							SourceTable.Statuss,
							SourceTable.Line,
							SourceTable.DateOutPut,
							SourceTable.SlittingWidth,
							SourceTable.ElectrodeThick,
							SourceTable.Description,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID
							
					);

							-- Process Delete Table
            MERGE STB_VN_ELECTRODE_REQUESTFORM AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN XMLData.OldCompanyCode IS NULL THEN XMLData.ID
							    ELSE XMLData.OldCompanyCode
							END AS OldCompanyCode,
							XMLData.ID,
							XMLData.GROUPID,
							XMLData.Materialcode,
							XMLData.MaterialName,
							XMLData.GoodQtyLength,
							XMLData.ActuallyQtyRequest,
							XMLData.Statuss,
							XMLData.Line,
							XMLData.DateOutPut,
							XMLData.SlittingWidth,
							XMLData.ElectrodeThick,
							XMLData.Description,
							 DATEADD(HH, -2, GETDATE()) AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							 DATEADD(HH, -2, GETDATE()) AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
						
					FROM
							OPENXML(@idoc , @DeleteTableName , 2)
							WITH  (
										OldCompanyCode INT,
										ID INT,
										GROUPID NVARCHAR(50),
										Materialcode NVARCHAR(50),
										MaterialName NVARCHAR(50),
										GoodQtyLength numeric(20,5),
										ActuallyQtyRequest numeric(20,5),
										Statuss BIT,
										Line NVARCHAR(50),
										DateOutPut DATE,
										SlittingWidth NUMERIC(20,5),
										ElectrodeThick NUMERIC(20,5),
										Description nvarchar(500),
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
									XMLData.GROUPID,
									XMLData.Materialcode,
									XMLData.MaterialName,
									XMLData.GoodQtyLength,
									XMLData.ActuallyQtyRequest,
									XMLData.Statuss,
									XMLData.Line,
									XMLData.DateOutPut,
									XMLData.SlittingWidth,
									XMLData.ElectrodeThick,
									XMLData.Description,
									XMLData.CreateDateTime,
									XMLData.CreateUserID,
									XMLData.ChangeDateTime,
									XMLData.ChangeUserID
									
							FROM
									OPENXML(@idoc , @InsertTableName , 2)
							        WITH  (
											 OldCompanyCode INT,
											 ID INT,
											 GROUPID NVARCHAR(50),
											 Materialcode NVARCHAR(50),
											 MaterialName NVARCHAR(50),
											 GoodQtyLength numeric(20,5),
											 ActuallyQtyRequest numeric(20,5),
											 Statuss BIT,
											 Line NVARCHAR(50),
											 DateOutPut DATE,
											 SlittingWidth NUMERIC(20,5),
											 ElectrodeThick NUMERIC(20,5),
											 Description NVARCHAR(500),
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
									XMLData.GROUPID,
									XMLData.Materialcode,
									XMLData.MaterialName,
									XMLData.GoodQtyLength,
									XMLData.ActuallyQtyRequest,
									XMLData.Statuss,
									XMLData.Line,
									XMLData.DateOutPut,
									XMLData.SlittingWidth,
									XMLData.ElectrodeThick,
									XMLData.Description,
									XMLData.CreateDateTime,
									XMLData.CreateUserID,
									XMLData.ChangeDateTime,
									XMLData.ChangeUserID
								
							FROM
									OPENXML(@idoc , @UpdateTableName , 2)
							        WITH  (
											 OldCompanyCode INT,
											 ID INT,
											 GROUPID NVARCHAR(50),
											 Materialcode NVARCHAR(50),
											 MaterialName NVARCHAR(50),
											 GoodQtyLength numeric(20,5),
											 ActuallyQtyRequest numeric(20,5),
											 Statuss BIT,
											 Line NVARCHAR(50),
											 DateOutPut DATE,
											 SlittingWidth NUMERIC(20,5),
											 ElectrodeThick NUMERIC(20,5),
											 Description NVARCHAR(500),
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
									XMLData.GROUPID,
									XMLData.Materialcode,
									XMLData.MaterialName,
									XMLData.GoodQtyLength,
									XMLData.ActuallyQtyRequest,
									XMLData.Statuss,
									XMLData.Line,
									XMLData.DateOutPut,
									XMLData.SlittingWidth,
									XMLData.ElectrodeThick,
									XMLData.Description,
									XMLData.CreateDateTime,
									XMLData.CreateUserID,
									XMLData.ChangeDateTime,
									XMLData.ChangeUserID
								
							FROM
									OPENXML(@idoc , @DeleteTableName , 2)
							        WITH  (
											 OldCompanyCode VARCHAR(20),
											 ID INT,
											 GROUPID NVARCHAR(50),
											 Materialcode NVARCHAR(50),
											 MaterialName NVARCHAR(50),
											 GoodQtyLength numeric(20,5),
											 ActuallyQtyRequest numeric(20,5),
											 Statuss BIT,
											 Line NVARCHAR(50),
											 DateOutPut DATE,
											 SlittingWidth NUMERIC(20,5),
											 ElectrodeThick NUMERIC(20,5),
											 Description NVARCHAR(500),
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
								 @GROUPID,
								 @Materialcode,
								 @GoodQtyLength,
								 @ActuallyQtyRequest,
								 @Statuss,
								 @Line,
								 @DateOutPut,
								 @SlittingWidth,
								 @ElectrodeThick,
								 @Description,
								 @CreateDateTime,
								 @CreateUserID,
								 @ChangeDateTime,
								 @ChangeUserID
								

			  IF @@FETCH_STATUS <> 0 BEGIN
					BREAK
				END
		RAISERROR(@IUD_FLAG, 16, 1)
		  IF @IUD_FLAG = 'INSERT' BEGIN

                    IF EXISTS (SELECT 1 FROM STB_VN_ELECTRODE_REQUESTFORM WHERE ID = @OldCompanyCode) BEGIN
						RAISERROR('Duplicate Data : KeyField = %s', 16, 1, @OldCompanyCode)
					END
			 IF @IsAutoKey = 0 BEGIN
						EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_VN_ELECTRODE_REQUESTFORM', @OldCompanyCode OUTPUT

			INSERT INTO STB_VN_ELECTRODE_REQUESTFORM
						(
						    GROUPID,
						    Materialcode,
						    GoodQtyLength,
						    ActuallyQtyRequest,
						    Statuss,
						    Line,
							DateOutPut,
							SlittingWidth,
							ElectrodeThick,
							Description,
						    CreateDateTime,
						    CreateUserID,
						    ChangeDateTime,
						    ChangeUserID
							
						)
						VALUES
						(
						    @Publiccode,
						    @Materialcode,
						    @GoodQtyLength,
						    @ActuallyQtyRequest,
						    'False',
						    @Line,
							@DateOutPut,
							@SlittingWidth,
							@ElectrodeThick,
							@Description,
						    DATEADD(HH, -2, GETDATE()),
						    @pProcessUserID,
						    @ChangeDateTime,
						    @ChangeUserID
						)

END ELSE IF @IUD_FLAG = 'UPDATE' BEGIN
 UPDATE STB_VN_ELECTRODE_REQUESTFORM
						SET

						Materialcode = CASE
									WHEN @Materialcode IS NOT NULL THEN @Materialcode
									ELSE Materialcode
									END,
							MaterialName =   CASE
						                WHEN @MaterialName IS NOT NULL THEN @MaterialName
						                ELSE MaterialName
						            END,
						GoodQtyLength =   CASE
						                WHEN @GoodQtyLength IS NOT NULL THEN @GoodQtyLength
						                ELSE GoodQtyLength
						            END,

							 ActuallyQtyRequest =   CASE
						                WHEN @ActuallyQtyRequest IS NOT NULL THEN @ActuallyQtyRequest
						                ELSE ActuallyQtyRequest
						            END,

							 Line =   CASE
						                WHEN @Line IS NOT NULL THEN @Line
						                ELSE Line
									END,
							DateOutPut =   CASE
						                WHEN @DateOutPut IS NOT NULL THEN @DateOutPut
						                ELSE DateOutPut
									END,
							SlittingWidth =   CASE
						                WHEN @SlittingWidth IS NOT NULL THEN @SlittingWidth
						                ELSE SlittingWidth
									END,
							ElectrodeThick =  CASE
						                WHEN @ElectrodeThick IS NOT NULL THEN @ElectrodeThick
						                ELSE ElectrodeThick
									END,
							Description =   CASE
						                WHEN @Description IS NOT NULL THEN @Description
						                ELSE Description
									END,
						  
						    ChangeDateTime = DATEADD(HH, -2, GETDATE()),
						    ChangeUserID = @pProcessUserID
					
					WHERE
						    ID = @OldCompanyCode
						  END ELSE IF @IUD_FLAG = 'DELETE' BEGIN
                        DELETE FROM STB_VN_ELECTRODE_REQUESTFORM
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