CREATE PROC [dbo].[usp_VN_KPIMachiness]
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
	DECLARE @TYLEDATDUOCMUCTIEU FLOAT
	DECLARE @HIEUSUATTINHNANG FLOAT
	DECLARE @TYLEVANHANHTHIETBI FLOAT
	DECLARE @RUNTIME FLOAT
	DECLARE @TYLEDITHANG FLOAT
	DECLARE @QUANTITYACTUAL FLOAT
	DECLARE @QUANTITYTAGET FLOAT
	DECLARE @OPERATIONTIME FLOAT
	DECLARE @TACKTIME FLOAT
	DECLARE @PRODUCTIONOK INT
	DECLARE @PRODUCTIONNG INT
	DECLARE @RUNDOWN FLOAT
	DECLARE @DOWNTIME FLOAT
	DECLARE @LOSSTIME FLOAT
	DECLARE @CreateDateTime DATETIME
	DECLARE @CreateUserID NVARCHAR(50)
	DECLARE @ChangeDateTime DATETIME
	DECLARE @ChangeUserID NVARCHAR(50)
	DECLARE @iDoc INT

	
	 EXEC SmartFramework.dbo.usp_GetSerialRule 
			@pTableName = 'STB_VN_KPIMACHINES',
			@pIsAutoKey = @IsAutoKey OUTPUT,
			@pIsLoopIUD = @IsLoopIUD OUTPUT,
			@pPrefixData = @PrefixString OUTPUT,
			@pSerialLen = @SerialLen OUTPUT

    IF @IsAutoKey = 0 AND @IsLoopIUD = 0 BEGIN
   
	    EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml

		BEGIN TRY
	 MERGE STB_VN_KPIMACHINES AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN XMLData.OldCompanyCode IS NULL THEN XMLData.ID
							    ELSE XMLData.OldCompanyCode
							END AS OldCompanyCode,
							XMLData.ID,
							XMLData.TYLEDATDUOCMUCTIEU,
							XMLData.HIEUSUATTINHNANG,
							XMLData.TYLEVANHANHTHIETBI,
							XMLData.RUNTIME,
							XMLData.TYLEDITHANG,
							XMLData.QUANTITYACTUAL,
							XMLData.QUANTITYTAGET,
							XMLData.OPERATIONTIME,
							XMLData.TACKTIME,
							XMLData.PRODUCTIONOK,
							XMLData.PRODUCTIONNG,
							XMLData.RUNDOWN,
							XMLData.DOWNTIME,
							XMLData.LOSSTIME,
							 DATEADD(HH, -2, GETDATE()) AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							 DATEADD(HH, -2, GETDATE()) AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
							
					FROM
							OPENXML(@idoc , @InsertTableName , 2)
							WITH  (
										OldCompanyCode INT,
										ID INT,
										TYLEDATDUOCMUCTIEU FLOAT,
										HIEUSUATTINHNANG FLOAT,
										TYLEVANHANHTHIETBI FLOAT,
										RUNTIME FLOAT,
										TYLEDITHANG FLOAT,
										QUANTITYACTUAL FLOAT,
										QUANTITYTAGET FLOAT,
										OPERATIONTIME FLOAT,
										TACKTIME FLOAT,
										PRODUCTIONOK INT,
										PRODUCTIONNG INT,
										RUNDOWN FLOAT,
										DOWNTIME  FLOAT,
										LOSSTIME FLOAT,
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
					QUANTITYTAGET =  CAST((SourceTable.OPERATIONTIME * 0.8 * 60) / SourceTable.TACKTIME AS FLOAT),
					OPERATIONTIME = CAST(SourceTable.OPERATIONTIME AS FLOAT),
					PRODUCTIONOK = SourceTable.PRODUCTIONOK,
					PRODUCTIONNG = SourceTable.PRODUCTIONNG,
					RUNTIME = CAST(SourceTable.OPERATIONTIME -(SourceTable.RUNDOWN + SourceTable.DOWNTIME) AS FLOAT),
					QUANTITYACTUAL =  CAST(SourceTable.PRODUCTIONNG + SourceTable.PRODUCTIONOK AS FLOAT),
					TACKTIME = CAST(SourceTable.TACKTIME AS FLOAT),
					RUNDOWN = CAST(SourceTable.RUNDOWN AS FLOAT),
					DOWNTIME = CAST(SourceTable.DOWNTIME AS FLOAT),
					LOSSTIME =  (CAST(SourceTable.RUNDOWN + SourceTable.DOWNTIME AS FLOAT) / CAST(SourceTable.OPERATIONTIME AS FLOAT)) *100 ,
					TYLEDITHANG = case when SourceTable.PRODUCTIONNG > 0 then CAST(SourceTable.PRODUCTIONOK / SourceTable.PRODUCTIONNG AS FLOAT) else 100 end ,
					TYLEDATDUOCMUCTIEU = (CAST(SourceTable.PRODUCTIONOK AS FLOAT) / ((CAST(SourceTable.OPERATIONTIME AS FLOAT) * 0.8 * 60) / CAST(SourceTable.TACKTIME AS FLOAT))) *100,
					TYLEVANHANHTHIETBI = ((CAST(SourceTable.OPERATIONTIME AS FLOAT) - (CAST(SourceTable.RUNDOWN AS FLOAT) + CAST(SourceTable.DOWNTIME AS FLOAT)))  /  CAST(SourceTable.OPERATIONTIME as FLOAT)) *100,
					HIEUSUATTINHNANG =   ((((CAST(SourceTable.OPERATIONTIME AS FLOAT) - (CAST(SourceTable.RUNDOWN AS FLOAT) + CAST(SourceTable.DOWNTIME AS FLOAT)))  /  CAST(SourceTable.OPERATIONTIME as FLOAT)) *100)  /  (case when CAST(SourceTable.PRODUCTIONNG AS FLOAT) > 0 then (CAST (SourceTable.PRODUCTIONOK AS FLOAT) / CAST(SourceTable.PRODUCTIONNG AS FLOAT)) else 100 end))*100 ,
					ChangeDateTime = SourceTable.ChangeDateTime,
					ChangeUserID = SourceTable.ChangeUserID

					WHEN NOT MATCHED THEN
			INSERT
					(
						TYLEDATDUOCMUCTIEU,
						HIEUSUATTINHNANG,
						TYLEVANHANHTHIETBI,
						RUNTIME,
						TYLEDITHANG,
						QUANTITYACTUAL,
						QUANTITYTAGET,
						OPERATIONTIME,
						TACKTIME,
						PRODUCTIONOK,
						PRODUCTIONNG,
						RUNDOWN,
						DOWNTIME,
						LOSSTIME,
						CreateDateTime,
						CreateUserID
					)
				VALUES
					(	
							--SourceTable.TYLEDATDUOCMUCTIEU,
							(CAST(SourceTable.PRODUCTIONOK AS FLOAT) / ((CAST(SourceTable.OPERATIONTIME AS FLOAT) * 0.8 * 60) / CAST(SourceTable.TACKTIME AS FLOAT))) *100,
							--SourceTable.HIEUSUATTINHNANG,
							 ((((CAST(SourceTable.OPERATIONTIME AS FLOAT) - (CAST(SourceTable.RUNDOWN AS FLOAT) + CAST(SourceTable.DOWNTIME AS FLOAT)))  /  CAST(SourceTable.OPERATIONTIME as FLOAT)) *100)  /  (case when CAST(SourceTable.PRODUCTIONNG AS FLOAT) > 0 then (CAST (SourceTable.PRODUCTIONOK AS FLOAT) / CAST(SourceTable.PRODUCTIONNG AS FLOAT)) else 100 end))*100 ,
							--SourceTable.TYLEVANHANHTHIETBI,
							 ((CAST(SourceTable.OPERATIONTIME AS FLOAT) - (CAST(SourceTable.RUNDOWN AS FLOAT) + CAST(SourceTable.DOWNTIME AS FLOAT)))  /  CAST(SourceTable.OPERATIONTIME as FLOAT)) *100,
							--SourceTable.RUNTIME,
							--SourceTable.TYLEDITHANG,
							--SourceTable.QUANTITYACTUAL,
							--SourceTable.QUANTITYTAGET,
							--SourceTable.OPERATIONTIME,
							--SourceTable.TACKTIME,
							--SourceTable.PRODUCTIONOK,
							--SourceTable.PRODUCTIONNG,
							--SourceTable.RUNDOWN,
							--SourceTable.DOWNTIME,
							--SourceTable.LOSSTIME,
							--SourceTable.RUNTIME,
							CAST(SourceTable.OPERATIONTIME -(SourceTable.RUNDOWN + SourceTable.DOWNTIME) AS FLOAT),
							--SourceTable.TYLEDITHANG,
							case when SourceTable.PRODUCTIONNG > 0 then CAST(SourceTable.PRODUCTIONOK / SourceTable.PRODUCTIONNG AS FLOAT) else 100 end,
							--SourceTable.QUANTITYACTUAL,
							CAST(SourceTable.PRODUCTIONNG + SourceTable.PRODUCTIONOK AS FLOAT),
							--SourceTable.QUANTITYTAGET,
							CAST((SourceTable.OPERATIONTIME * 0.8 * 60) / SourceTable.TACKTIME AS FLOAT),
							--SourceTable.OPERATIONTIME,
							CAST(SourceTable.OPERATIONTIME AS FLOAT),
							--SourceTable.TACKTIME,
							CAST(SourceTable.TACKTIME AS FLOAT),
							SourceTable.PRODUCTIONOK,
							SourceTable.PRODUCTIONNG,
							--SourceTable.RUNDOWN,
							CAST(SourceTable.RUNDOWN AS FLOAT),
							--SourceTable.DOWNTIME,
							CAST(SourceTable.DOWNTIME AS FLOAT),
							--SourceTable.LOSSTIME,
							( CAST(SourceTable.RUNDOWN + SourceTable.DOWNTIME AS FLOAT) / CAST(SourceTable.OPERATIONTIME AS FLOAT)) *100,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID
					);		

	MERGE STB_VN_KPIMACHINES AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN XMLData.OldCompanyCode IS NULL THEN XMLData.ID
							    ELSE XMLData.OldCompanyCode
							END AS OldCompanyCode,
							XMLData.ID,
							XMLData.TYLEDATDUOCMUCTIEU,
							XMLData.HIEUSUATTINHNANG,
							XMLData.TYLEVANHANHTHIETBI,
							XMLData.RUNTIME,
							XMLData.TYLEDITHANG,
							XMLData.QUANTITYACTUAL,
							XMLData.QUANTITYTAGET,
							XMLData.OPERATIONTIME,
							XMLData.TACKTIME,
							XMLData.PRODUCTIONOK,
							XMLData.PRODUCTIONNG,
							XMLData.RUNDOWN,
							XMLData.DOWNTIME,
							XMLData.LOSSTIME,
							 DATEADD(HH, -2, GETDATE()) AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							 DATEADD(HH, -2, GETDATE()) AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @UpdateTableName , 2)
							WITH  (
										OldCompanyCode INT,
										ID INT,
										TYLEDATDUOCMUCTIEU FLOAT,
										HIEUSUATTINHNANG FLOAT,
										TYLEVANHANHTHIETBI FLOAT,
										RUNTIME FLOAT,
										TYLEDITHANG FLOAT,
										QUANTITYACTUAL FLOAT,
										QUANTITYTAGET FLOAT,
										OPERATIONTIME FLOAT,
										TACKTIME FLOAT,
										PRODUCTIONOK INT,
										PRODUCTIONNG INT,
										RUNDOWN FLOAT,
										DOWNTIME FLOAT,
										LOSSTIME FLOAT,
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

					QUANTITYTAGET =  CAST((SourceTable.OPERATIONTIME * 0.8 * 60) / SourceTable.TACKTIME AS FLOAT),
					OPERATIONTIME = CAST(SourceTable.OPERATIONTIME AS FLOAT),
					PRODUCTIONOK = SourceTable.PRODUCTIONOK,
					PRODUCTIONNG = SourceTable.PRODUCTIONNG,
					RUNTIME = CAST(SourceTable.OPERATIONTIME -(SourceTable.RUNDOWN + SourceTable.DOWNTIME) AS FLOAT),
					QUANTITYACTUAL =  CAST(SourceTable.PRODUCTIONNG + SourceTable.PRODUCTIONOK AS FLOAT),
					TACKTIME = CAST(SourceTable.TACKTIME AS FLOAT),
					RUNDOWN = CAST(SourceTable.RUNDOWN AS FLOAT),
					DOWNTIME = CAST(SourceTable.DOWNTIME AS FLOAT),
					LOSSTIME = (CAST(SourceTable.RUNDOWN + SourceTable.DOWNTIME AS FLOAT) /CAST(SourceTable.OPERATIONTIME AS FLOAT)) * 100,
					TYLEDITHANG = case when SourceTable.PRODUCTIONNG > 0 then CAST(SourceTable.PRODUCTIONOK / SourceTable.PRODUCTIONNG AS FLOAT) else 100 end ,
					TYLEDATDUOCMUCTIEU = (CAST(SourceTable.PRODUCTIONOK AS FLOAT) / ((CAST(SourceTable.OPERATIONTIME AS FLOAT) * 0.8 * 60) / CAST(SourceTable.TACKTIME AS FLOAT))) *100,
					TYLEVANHANHTHIETBI = ((CAST(SourceTable.OPERATIONTIME AS FLOAT) - (CAST(SourceTable.RUNDOWN AS FLOAT) + CAST(SourceTable.DOWNTIME AS FLOAT)))  /  CAST(SourceTable.OPERATIONTIME as FLOAT)) *100,
					HIEUSUATTINHNANG =   ((((CAST(SourceTable.OPERATIONTIME AS FLOAT) - (CAST(SourceTable.RUNDOWN AS FLOAT) + CAST(SourceTable.DOWNTIME AS FLOAT)))  /  CAST(SourceTable.OPERATIONTIME as FLOAT)) *100)  /  (case when CAST(SourceTable.PRODUCTIONNG AS FLOAT) > 0 then (CAST (SourceTable.PRODUCTIONOK AS FLOAT) / CAST(SourceTable.PRODUCTIONNG AS FLOAT)) else 100 end))*100 ,
					
					ChangeDateTime = SourceTable.ChangeDateTime,
					ChangeUserID = SourceTable.ChangeUserID

WHEN NOT MATCHED THEN

			INSERT
					(
						TYLEDATDUOCMUCTIEU,
						HIEUSUATTINHNANG,
						TYLEVANHANHTHIETBI,
						RUNTIME,
						TYLEDITHANG,
						QUANTITYACTUAL,
						QUANTITYTAGET,
						OPERATIONTIME,
						TACKTIME,
						PRODUCTIONOK,
						PRODUCTIONNG,
						RUNDOWN,
						DOWNTIME,
						LOSSTIME,
						CreateDateTime,
						CreateUserID
					)
				VALUES
					(
							--SourceTable.TYLEDATDUOCMUCTIEU,
							(CAST(SourceTable.PRODUCTIONOK AS FLOAT) / ((CAST(SourceTable.OPERATIONTIME AS FLOAT) * 0.8 * 60) / CAST(SourceTable.TACKTIME AS FLOAT))) *100,
							--SourceTable.HIEUSUATTINHNANG,
							 ((((CAST(SourceTable.OPERATIONTIME AS FLOAT) - (CAST(SourceTable.RUNDOWN AS FLOAT) + CAST(SourceTable.DOWNTIME AS FLOAT)))  /  CAST(SourceTable.OPERATIONTIME as FLOAT)) *100)  /  (case when CAST(SourceTable.PRODUCTIONNG AS FLOAT) > 0 then (CAST (SourceTable.PRODUCTIONOK AS FLOAT) / CAST(SourceTable.PRODUCTIONNG AS FLOAT)) else 100 end))*100 ,
							--SourceTable.TYLEVANHANHTHIETBI,
							 ((CAST(SourceTable.OPERATIONTIME AS FLOAT) - (CAST(SourceTable.RUNDOWN AS FLOAT) + CAST(SourceTable.DOWNTIME AS FLOAT)))  /  CAST(SourceTable.OPERATIONTIME as FLOAT)) *100,
							--SourceTable.RUNTIME,
							CAST(SourceTable.OPERATIONTIME -(SourceTable.RUNDOWN + SourceTable.DOWNTIME) AS FLOAT),
							--SourceTable.TYLEDITHANG,
							case when SourceTable.PRODUCTIONNG > 0 then CAST(SourceTable.PRODUCTIONOK / SourceTable.PRODUCTIONNG AS FLOAT) else 100 end,
							--SourceTable.QUANTITYACTUAL,
							CAST(SourceTable.PRODUCTIONNG + SourceTable.PRODUCTIONOK AS FLOAT),
							--SourceTable.QUANTITYTAGET,
							CAST((SourceTable.OPERATIONTIME * 0.8 * 60) / SourceTable.TACKTIME AS FLOAT),
							--SourceTable.OPERATIONTIME,
							CAST(SourceTable.OPERATIONTIME AS FLOAT),
							--SourceTable.TACKTIME,
							CAST(SourceTable.TACKTIME AS FLOAT),
							SourceTable.PRODUCTIONOK,
							SourceTable.PRODUCTIONNG,
							--SourceTable.RUNDOWN,
							CAST(SourceTable.RUNDOWN AS FLOAT),
							--SourceTable.DOWNTIME,
							CAST(SourceTable.DOWNTIME AS FLOAT),
							--SourceTable.LOSSTIME,
							 (CAST(SourceTable.RUNDOWN + SourceTable.DOWNTIME AS FLOAT) / CAST(SourceTable.OPERATIONTIME AS FLOAT))*100,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID
					);

					-- Process Delete Table
            MERGE STB_VN_KPIMACHINES AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN XMLData.OldCompanyCode IS NULL THEN XMLData.ID
							    ELSE XMLData.OldCompanyCode
							END AS OldCompanyCode,
							XMLData.ID,
							XMLData.TYLEDATDUOCMUCTIEU,
							XMLData.HIEUSUATTINHNANG,
							XMLData.TYLEVANHANHTHIETBI,
							XMLData.RUNTIME,
							XMLData.TYLEDITHANG,
							XMLData.QUANTITYACTUAL,
							XMLData.QUANTITYTAGET,
							XMLData.OPERATIONTIME,
							XMLData.TACKTIME,
							XMLData.PRODUCTIONOK,
							XMLData.PRODUCTIONNG,
							XMLData.RUNDOWN,
							XMLData.DOWNTIME,
							XMLData.LOSSTIME,
							 DATEADD(HH, -2, GETDATE()) AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							 DATEADD(HH, -2, GETDATE()) AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
							
					FROM
							OPENXML(@idoc , @DeleteTableName , 2)
							WITH  (
										OldCompanyCode INT,
										ID INT,
										TYLEDATDUOCMUCTIEU FLOAT,
										HIEUSUATTINHNANG FLOAT,
										TYLEVANHANHTHIETBI FLOAT,
										RUNTIME FLOAT,
										TYLEDITHANG FLOAT,
										QUANTITYACTUAL FLOAT,
										QUANTITYTAGET FLOAT,
										OPERATIONTIME FLOAT,
										TACKTIME FLOAT,
										PRODUCTIONOK INT,
										PRODUCTIONNG INT,
										RUNDOWN FLOAT,
										DOWNTIME FLOAT,
										LOSSTIME FLOAT,
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
									XMLData.TYLEDATDUOCMUCTIEU,
									XMLData.HIEUSUATTINHNANG,
									XMLData.TYLEVANHANHTHIETBI,
									XMLData.RUNTIME,
									XMLData.TYLEDITHANG,
									XMLData.QUANTITYACTUAL,
									XMLData.QUANTITYTAGET,
									XMLData.OPERATIONTIME,
									XMLData.TACKTIME,
									XMLData.PRODUCTIONOK,
									XMLData.PRODUCTIONNG,
									XMLData.RUNDOWN,
									XMLData.DOWNTIME,
									XMLData.LOSSTIME,
									XMLData.CreateDateTime,
									XMLData.CreateUserID,
									XMLData.ChangeDateTime,
									XMLData.ChangeUserID
									
							FROM
									OPENXML(@idoc , @InsertTableName , 2)
							        WITH  (
											 OldCompanyCode INT,
											 ID INT,
											 TYLEDATDUOCMUCTIEU FLOAT,
											 HIEUSUATTINHNANG FLOAT,
											 TYLEVANHANHTHIETBI FLOAT,
											 RUNTIME FLOAT,
											 TYLEDITHANG FLOAT,
											 QUANTITYACTUAL FLOAT,
											 QUANTITYTAGET FLOAT,
											 OPERATIONTIME FLOAT,
											 TACKTIME FLOAT,
											 PRODUCTIONOK INT,
											 PRODUCTIONNG INT,
											 RUNDOWN FLOAT,
											 DOWNTIME FLOAT,
											 LOSSTIME FLOAT,
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
									XMLData.TYLEDATDUOCMUCTIEU,
									XMLData.HIEUSUATTINHNANG,
									XMLData.TYLEVANHANHTHIETBI,
									XMLData.RUNTIME,
									XMLData.TYLEDITHANG,
									XMLData.QUANTITYACTUAL,
									XMLData.QUANTITYTAGET,
									XMLData.OPERATIONTIME,
									XMLData.TACKTIME,
									XMLData.PRODUCTIONOK,
									XMLData.PRODUCTIONNG,
									XMLData.RUNDOWN,
									XMLData.DOWNTIME,
									XMLData.LOSSTIME,
									XMLData.CreateDateTime,
									XMLData.CreateUserID,
									XMLData.ChangeDateTime,
									XMLData.ChangeUserID
							FROM
									OPENXML(@idoc , @UpdateTableName , 2)
							        WITH  (
											 OldCompanyCode INT,
											 ID INT,
											 TYLEDATDUOCMUCTIEU FLOAT,
											 HIEUSUATTINHNANG FLOAT,
											 TYLEVANHANHTHIETBI FLOAT,
											 RUNTIME FLOAT,
											 TYLEDITHANG FLOAT,
											 QUANTITYACTUAL FLOAT,
											 QUANTITYTAGET FLOAT,
											 OPERATIONTIME FLOAT,
											 TACKTIME FLOAT,
											 PRODUCTIONOK INT,
											 PRODUCTIONNG INT,
											 RUNDOWN FLOAT,
											 DOWNTIME FLOAT,
											 LOSSTIME FLOAT,
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
									XMLData.TYLEDATDUOCMUCTIEU,
									XMLData.HIEUSUATTINHNANG,
									XMLData.TYLEVANHANHTHIETBI,
									XMLData.RUNTIME,
									XMLData.TYLEDITHANG,
									XMLData.QUANTITYACTUAL,
									XMLData.QUANTITYTAGET,
									XMLData.OPERATIONTIME,
									XMLData.TACKTIME,
									XMLData.PRODUCTIONOK,
									XMLData.PRODUCTIONNG,
									XMLData.RUNDOWN,
									XMLData.DOWNTIME,
									XMLData.LOSSTIME,
									XMLData.CreateDateTime,
									XMLData.CreateUserID,
									XMLData.ChangeDateTime,
									XMLData.ChangeUserID
							FROM
									OPENXML(@idoc , @DeleteTableName , 2)
							        WITH  (
											 OldCompanyCode VARCHAR(20),
											 ID INT,
											 TYLEDATDUOCMUCTIEU FLOAT,
											 HIEUSUATTINHNANG FLOAT,
											 TYLEVANHANHTHIETBI FLOAT,
											 RUNTIME FLOAT,
											 TYLEDITHANG FLOAT,
											 QUANTITYACTUAL FLOAT,
											 QUANTITYTAGET FLOAT,
											 OPERATIONTIME FLOAT,
											 TACKTIME FLOAT,
											 PRODUCTIONOK INT,
											 PRODUCTIONNG INT,
											 RUNDOWN FLOAT,
											 DOWNTIME FLOAT,
											 LOSSTIME FLOAT,
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
								 @TYLEDATDUOCMUCTIEU,
								 @HIEUSUATTINHNANG,
								 @TYLEVANHANHTHIETBI,
								 @RUNTIME,
								 @TYLEDITHANG,
								 @QUANTITYACTUAL,
								 @QUANTITYTAGET,
								 @OPERATIONTIME,
								 @TACKTIME,
								 @PRODUCTIONOK,
								 @PRODUCTIONNG,
								 @RUNDOWN,
								 @DOWNTIME,
								 @LOSSTIME,
								 @CreateDateTime,
								 @CreateUserID,
								 @ChangeDateTime,
								 @ChangeUserID
			  IF @@FETCH_STATUS <> 0 BEGIN
					BREAK
				END

		  IF @IUD_FLAG = 'INSERT' BEGIN

                    IF EXISTS (SELECT 1 FROM STB_VN_KPIMACHINES WHERE ID = @OldCompanyCode) BEGIN
						RAISERROR('Duplicate Data : KeyField = %s', 16, 1, @OldCompanyCode)
					END
			 IF @IsAutoKey = 0 BEGIN

						EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_VN_KPIMACHINES', @OldCompanyCode OUTPUT

	INSERT INTO STB_VN_KPIMACHINES
						(
							TYLEDATDUOCMUCTIEU,
							HIEUSUATTINHNANG,
							TYLEVANHANHTHIETBI,
							RUNTIME,
							TYLEDITHANG,
							QUANTITYACTUAL,
							QUANTITYTAGET,
						    OPERATIONTIME,
						    TACKTIME,
						    PRODUCTIONOK,
						    PRODUCTIONNG,
						    RUNDOWN,
						    DOWNTIME,
							LOSSTIME,
						    CreateDateTime,
						    CreateUserID,
						    ChangeDateTime,
						    ChangeUserID
						)
						VALUES
						(
							--@TYLEDATDUOCMUCTIEU,
							(CAST(@PRODUCTIONOK AS FLOAT) / ((CAST(@OPERATIONTIME AS FLOAT) * 0.8 * 60) / CAST(@TACKTIME AS FLOAT))) *100,
							--@HIEUSUATTINHNANG,
							 ((((CAST(@OPERATIONTIME AS FLOAT) - (CAST(@RUNDOWN AS FLOAT) + CAST(@DOWNTIME AS FLOAT)))  /  CAST(@OPERATIONTIME as FLOAT)) *100)  /  (case when CAST(@PRODUCTIONNG AS FLOAT) > 0 then (CAST (@PRODUCTIONOK AS FLOAT) / CAST(@PRODUCTIONNG AS FLOAT)) else 100 end))*100 ,
							--@TYLEVANHANHTHIETBI,
							 ((CAST(@OPERATIONTIME AS FLOAT) - (CAST(@RUNDOWN AS FLOAT) + CAST(@DOWNTIME AS FLOAT)))  /  CAST(@OPERATIONTIME as FLOAT)) *100,
							--@RUNTIME,
							CAST(@OPERATIONTIME -(@RUNDOWN + @DOWNTIME) AS FLOAT),
							--@TYLEDITHANG,
							case when @PRODUCTIONNG > 0 then CAST(@PRODUCTIONOK / @PRODUCTIONNG AS FLOAT) else 100 end ,
							--@QUANTITYACTUAL,
							CAST(@PRODUCTIONNG + @PRODUCTIONOK AS FLOAT),
							--@QUANTITYTAGET,
							CAST((@OPERATIONTIME * 0.8 * 60) / @TACKTIME AS FLOAT),
						    --@OPERATIONTIME,
							CAST(@OPERATIONTIME AS FLOAT),
						    --@TACKTIME,
							CAST(@TACKTIME AS FLOAT),
						    @PRODUCTIONOK,
						    @PRODUCTIONNG,
							CAST(@OPERATIONTIME -(@RUNDOWN + @DOWNTIME) AS FLOAT),

							CAST(@DOWNTIME AS FLOAT),
							(CAST(@RUNDOWN + @DOWNTIME AS FLOAT) / CAST (@OPERATIONTIME as FLOAT)) *100,
						   -- @RUNDOWN,
						  --  @DOWNTIME,
						--	@LOSSTIME,
						    DATEADD(HH, -2, GETDATE()),
						    @pProcessUserID,
						    @ChangeDateTime,
						    @ChangeUserID
						)
END ELSE IF @IUD_FLAG = 'UPDATE' BEGIN
 UPDATE STB_VN_KPIMACHINES
						SET
							
						    RUNTIME = CASE
										WHEN @RUNTIME IS NOT NULL THEN CAST(@OPERATIONTIME - (@RUNDOWN + @DOWNTIME) AS FLOAT)
										ELSE RUNTIME
										END,

							TYLEDITHANG = CASE
										WHEN @TYLEDITHANG IS NOT NULL THEN CAST(@PRODUCTIONOK - @PRODUCTIONNG AS FLOAT)
										ELSE TYLEDITHANG
										END,

							QUANTITYACTUAL = CASE
										WHEN @QUANTITYACTUAL IS NOT NULL THEN CAST(@PRODUCTIONOK + @PRODUCTIONNG AS FLOAT)
										ELSE QUANTITYACTUAL
										END,

							QUANTITYTAGET = CASE
										WHEN @QUANTITYTAGET IS NOT NULL THEN CAST(@OPERATIONTIME * 0.8 * 60 / @TACKTIME AS FLOAT)
										ELSE QUANTITYTAGET
										END,
			
							OPERATIONTIME =   CASE
						                WHEN @OPERATIONTIME IS NOT NULL THEN CAST(@OPERATIONTIME AS FLOAT)
						                ELSE OPERATIONTIME
						            END,
						TACKTIME =   CASE
						                WHEN @TACKTIME IS NOT NULL THEN CAST(@TACKTIME AS FLOAT)
						                ELSE TACKTIME
						            END,

							 PRODUCTIONOK =   CASE
						                WHEN @PRODUCTIONOK IS NOT NULL THEN CAST(@PRODUCTIONOK AS FLOAT)
						                ELSE PRODUCTIONOK
						            END,

							 PRODUCTIONNG =   CASE
						                WHEN @PRODUCTIONNG IS NOT NULL THEN @PRODUCTIONNG
						                ELSE PRODUCTIONNG
						            END,

							 RUNDOWN =   CASE
						                WHEN @RUNDOWN IS NOT NULL THEN CAST(@RUNDOWN AS FLOAT)
						                ELSE RUNDOWN
						            END,

						  DOWNTIME =   CASE
						                WHEN @DOWNTIME IS NOT NULL THEN CAST(@DOWNTIME AS FLOAT)
						                ELSE DOWNTIME
						            END,

						   LOSSTIME = CASE
										WHEN @LOSSTIME IS NOT NULL THEN CAST(@LOSSTIME AS FLOAT)
										ELSE LOSSTIME
									END,
								TYLEDATDUOCMUCTIEU = CASE
										WHEN @TYLEDATDUOCMUCTIEU IS NOT NULL THEN (CAST(@PRODUCTIONOK AS FLOAT) / ((CAST(@OPERATIONTIME AS FLOAT) * 0.8 * 60) / CAST(@TACKTIME AS FLOAT))) *100
										ELSE TYLEDATDUOCMUCTIEU
										END,		
							TYLEVANHANHTHIETBI = CASE
										WHEN @TYLEVANHANHTHIETBI IS NOT NULL THEN  ((CAST(@OPERATIONTIME AS FLOAT) - (CAST(@RUNDOWN AS FLOAT) + CAST(@DOWNTIME AS FLOAT)))  /  CAST(@OPERATIONTIME as FLOAT)) *100
										ELSE TYLEVANHANHTHIETBI
										END,	
							HIEUSUATTINHNANG = CASE
										WHEN @HIEUSUATTINHNANG IS NOT NULL THEN  ((((CAST(@OPERATIONTIME AS FLOAT) - (CAST(@RUNDOWN AS FLOAT) + CAST(@DOWNTIME AS FLOAT)))  /  CAST(@OPERATIONTIME as FLOAT)) *100)  /  (case when CAST(@PRODUCTIONNG AS FLOAT) > 0 then (CAST (@PRODUCTIONOK AS FLOAT) / CAST(@PRODUCTIONNG AS FLOAT)) else 100 end))*100
										ELSE HIEUSUATTINHNANG
										END,
						    ChangeDateTime = DATEADD(HH, -2, GETDATE()),
						    ChangeUserID = @pProcessUserID
					
					WHERE
						    ID = @OldCompanyCode
						  END ELSE IF @IUD_FLAG = 'DELETE' BEGIN
                        DELETE FROM STB_VN_KPIMACHINES
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

