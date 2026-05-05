CREATE PROC [dbo].[usp_Add_StoreBook]
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
	 DECLARE @MothDate NVARCHAR(50)
	 DECLARE @Stage NVARCHAR(50)
	 DECLARE @Code  NVARCHAR(50)
	 DECLARE @ProductionName NVARCHAR(50)
	 DECLARE @Unit NVARCHAR(50)
	 DECLARE @Qty INT
	 DECLARE @QtyOut INT
	 DECLARE @StatusIn NVARCHAR(10)
	 DECLARE @StatusOut NVARCHAR(10)
	 DECLARE @TotalInventory INT
	 DECLARE @DATEOUT DATETIME
	 DECLARE @Remark NVARCHAR(500)
	 DECLARE @CreateDateTime DATETIME
     DECLARE @CreateUserID NVARCHAR(20)
     DECLARE @ChangeDateTime DATETIME
     DECLARE @ChangeUserID NVARCHAR(20)
	 DECLARE @iDoc INT

	 EXEC SmartFramework.dbo.usp_GetSerialRule 
			@pTableName = 'STB_NOBOOK',
			@pIsAutoKey = @IsAutoKey OUTPUT,
			@pIsLoopIUD = @IsLoopIUD OUTPUT,
			@pPrefixData = @PrefixString OUTPUT,
			@pSerialLen = @SerialLen OUTPUT

    IF @IsAutoKey = 0 AND @IsLoopIUD = 0 BEGIN
   
	    EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml


		 BEGIN TRY
			-- Process Insert Table
			 MERGE STB_NOBOOK AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN XMLData.OldCompanyCode IS NULL THEN XMLData.ID
							    ELSE XMLData.OldCompanyCode
							END AS OldCompanyCode,
							XMLData.ID,
							XMLData.MothDate,
							XMLData.Stage,
							XMLData.Code,
							XMLData.ProductionName,
							XMLData.Unit,
							XMLData.Qty,
							XMLData.QtyOut,
							XMLData.StatusIn,
							XMLData.StatusOut,
							XMLData.TotalInventory,
							DATEADD(HH, -2, GETDATE()) AS DATEOUT,
							XMLData.Remark,
							DATEADD(HH, -2, GETDATE()) AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							DATEADD(HH, -2, GETDATE()) AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
							
					FROM
							OPENXML(@idoc , @InsertTableName , 2)
							WITH  (
										OldCompanyCode INT,
										ID INT,
										MothDate NVARCHAR(50),
										Stage NVARCHAR(50),
										Code NVARCHAR(50),
										ProductionName NVARCHAR(100),
										Unit NVARCHAR(10),
										Qty INT,
										QtyOut INT,
										StatusIn NVARCHAR(10),
										StatusOut NVARCHAR(10),
										TotalInventory INT,
										DATEOUT  DATETIMEOFFSET,
										Remark NVARCHAR(500),
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
					MothDate = SourceTable.MothDate,
					Stage = SourceTable.Stage,
					Code = SourceTable.Code,
					ProductionName = SourceTable.ProductionName,
					Unit = SourceTable.Unit,
					Qty = SourceTable.Qty,
					QtyOut = SourceTable.QtyOut,
					TotalInventory =  SourceTable.TotalInventory,
					StatusIn = SourceTable.StatusIn,
					StatusOut = SourceTable.StatusOut,
					Remark = SourceTable.Remark,
					ChangeDateTime = SourceTable.ChangeDateTime,
					ChangeUserID = SourceTable.ChangeUserID

					WHEN NOT MATCHED THEN
				INSERT
					(
						MothDate,
						Stage,
						Code,
						ProductionName,
						Unit,
						Qty,
						StatusIn,
						StatusOut,
						Remark,
						CreateDateTime,
						CreateUserID
						
					)
				VALUES
					(
							SourceTable.MothDate,
							SourceTable.Stage,
							SourceTable.Code,
							SourceTable.ProductionName,
							SourceTable.Unit,
							SourceTable.Qty,
							N'Nhập',
							SourceTable.StatusOut,
							SourceTable.Remark,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID
							
					);

-- Process Update Table
	 MERGE STB_NOBOOK AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN XMLData.OldCompanyCode IS NULL THEN XMLData.ID
							    ELSE XMLData.OldCompanyCode
							END AS OldCompanyCode,
							XMLData.ID,
							XMLData.MothDate,
							XMLData.Stage,
							XMLData.Code,
							XMLData.ProductionName,
							XMLData.Unit,
							XMLData.Qty,
							XMLData.QtyOut,
							XMLData.StatusIn,
							XMLData.StatusOut,
							XMLData.TotalInventory,
							 DATEADD(HH, -2, GETDATE()) AS DATEOUT,
							XMLData.Remark,
							 DATEADD(HH, -2, GETDATE()) AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							 DATEADD(HH, -2, GETDATE()) AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
							
					FROM
							OPENXML(@idoc , @UpdateTableName , 2)
							WITH  (
										OldCompanyCode INT,
										ID INT,
										MothDate NVARCHAR(50),
										Stage NVARCHAR(50),
										Code NVARCHAR(50),
										ProductionName NVARCHAR(100),
										Unit NVARCHAR(10),
										Qty INT,
										QtyOut INT,
										StatusIn NVARCHAR(10),
										StatusOut NVARCHAR(10),
										TotalInventory INT,
										DATEOUT DATETIMEOFFSET,
										Remark NVARCHAR(500),
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
					MothDate = SourceTable.MothDate,
					Stage = SourceTable.Stage,
					Code = SourceTable.Code,
					ProductionName = SourceTable.ProductionName,
					Unit = SourceTable.Unit,
					Qty = SourceTable.Qty,
					QtyOut = SourceTable.QtyOut,
					StatusIn = SourceTable.StatusIn,
					StatusOut = SourceTable.StatusOut,
					TotalInventory = SourceTable.TotalInventory,
					DATEOUT = SourceTable.DATEOUT,
					Remark = SourceTable.Remark,
					ChangeDateTime = SourceTable.ChangeDateTime,
					ChangeUserID = SourceTable.ChangeUserID
	
	WHEN NOT MATCHED THEN
		INSERT
					(
						MothDate,
						Stage,
						Code,
						ProductionName,
						Unit,
						Qty,
						StatusIn,
						StatusOut,
						Remark,
						CreateDateTime,
						CreateUserID
						
					)
				VALUES
					(
							SourceTable.MothDate,
							SourceTable.Stage,
							SourceTable.Code,
							SourceTable.ProductionName,
							SourceTable.Unit,
							SourceTable.Qty,
							N'Nhập',
							SourceTable.StatusOut,
							SourceTable.Remark,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID
							
					);

	-- Process Delete Table
            MERGE STB_NOBOOK AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN XMLData.OldCompanyCode IS NULL THEN XMLData.ID
							    ELSE XMLData.OldCompanyCode
							END AS OldCompanyCode,
							XMLData.ID,
							XMLData.MothDate,
							XMLData.Stage,
							XMLData.Code,
							XMLData.ProductionName,
							XMLData.Unit,
							XMLData.Qty,
							XMLData.QtyOut,
							XMLData.StatusIn,
							XMLData.StatusOut,
							XMLData.TotalInventory,
							 DATEADD(HH, -2, GETDATE()) AS  DATEOUT,
							XMLData.Remark,
							 DATEADD(HH, -2, GETDATE()) AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							 DATEADD(HH, -2, GETDATE()) AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
							
					FROM
							OPENXML(@idoc , @DeleteTableName , 2)
							WITH  (
										OldCompanyCode INT,
										ID INT,
										MothDate NVARCHAR(50) ,
										Stage NVARCHAR(50) ,
										Code NVARCHAR(50) ,
										ProductionName NVARCHAR(100) ,
										Unit NVARCHAR(10) ,
										Qty INT ,
										QtyOut INT,
										StatusIn NVARCHAR(10) ,
										StatusOut NVARCHAR(10) ,
										TotalInventory INT,
										DATEOUT DATETIMEOFFSET,
										Remark NVARCHAR(500) ,
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
									XMLData.MothDate,
									XMLData.Stage,
									XMLData.Code,
									XMLData.ProductionName,
									XMLData.Unit,
									XMLData.Qty,
									XMLData.QtyOut,
									XMLData.StatusIn,
									XMLData.StatusOut,
									XMLData.TotalInventory,
									XMLData.DATEOUT,
									XMLData.Remark,
									XMLData.CreateDateTime,
									XMLData.CreateUserID,
									XMLData.ChangeDateTime,
									XMLData.ChangeUserID
									
							FROM
									OPENXML(@idoc , @InsertTableName , 2)
							        WITH  (
											 OldCompanyCode INT,
											ID INT,
											MothDate NVARCHAR(50),
											Stage NVARCHAR(50),
											Code NVARCHAR(50),
											ProductionName NVARCHAR(100),
											Unit NVARCHAR(10),
											Qty INT,
											QtyOut INT,
											StatusIn NVARCHAR(10),
											StatusOut NVARCHAR(10),
											TotalInventory INT,
											DATEOUT DATETIMEOFFSET,
											Remark NVARCHAR(500),
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
									XMLData.MothDate,
									XMLData.Stage,
									XMLData.Code,
									XMLData.ProductionName,
									XMLData.Unit,
									XMLData.Qty,
									XMLData.QtyOut,
									XMLData.StatusIn,
									XMLData.StatusOut,
									XMLData.TotalInventory,
									XMLData.DATEOUT,
									XMLData.Remark,
									XMLData.CreateDateTime,
									XMLData.CreateUserID,
									XMLData.ChangeDateTime,
									XMLData.ChangeUserID
									
							FROM
									OPENXML(@idoc , @UpdateTableName , 2)
							        WITH  (
											OldCompanyCode INT,
											ID INT,
											MothDate NVARCHAR(50),
											Stage NVARCHAR(50),
											Code NVARCHAR(50),
											ProductionName NVARCHAR(100),
											Unit NVARCHAR(10),
											Qty INT,
											QtyOut INT,
											StatusIn NVARCHAR(10),
											StatusOut NVARCHAR(10),
											TotalInventory INT,
											DATEOUT DATETIMEOFFSET,
											Remark NVARCHAR(500),
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
									XMLData.MothDate,
									XMLData.Stage,
									XMLData.Code,
									XMLData.ProductionName,
									XMLData.Unit,
									XMLData.Qty,
									XMLData.QtyOut,
									XMLData.StatusIn,
									XMLData.StatusOut,
									XMLData.TotalInventory,
									XMLData.DATEOUT,
									XMLData.Remark,
									XMLData.CreateDateTime,
									XMLData.CreateUserID,
									XMLData.ChangeDateTime,
									XMLData.ChangeUserID
									
							FROM
									OPENXML(@idoc , @DeleteTableName , 2)
							        WITH  (
											OldCompanyCode VARCHAR(20),
											ID INT,
											MothDate NVARCHAR(50),
											Stage NVARCHAR(50),
											Code NVARCHAR(50),
											ProductionName NVARCHAR(100),
											Unit NVARCHAR(10),
											Qty INT,
											QtyOut INT,
											StatusIn NVARCHAR(10),
											StatusOut NVARCHAR(10),
											TotalInventory INT,
											DATEOUT  DATETIMEOFFSET,
											Remark NVARCHAR(500),
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
								 @MothDate,
								 @Stage,
								 @Code,
								 @ProductionName,
								 @Unit,
								 @Qty,
								 @QtyOut,
								 @StatusIn,
								 @StatusOut,
								 @TotalInventory,
								 @DATEOUT,
								 @Remark,
								 @CreateDateTime,
								 @CreateUserID,
								 @ChangeDateTime,
								 @ChangeUserID
								 

			  IF @@FETCH_STATUS <> 0 BEGIN
					BREAK
				END

				  IF @IUD_FLAG = 'INSERT' BEGIN

                    IF EXISTS (SELECT 1 FROM STB_NOBOOK WHERE ID = @OldCompanyCode) BEGIN
						RAISERROR('Duplicate Data : KeyField = %s', 16, 1, @OldCompanyCode)
					END
			 IF @IsAutoKey = 0 BEGIN
						EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_NOBOOK', @OldCompanyCode OUTPUT

						INSERT INTO STB_NOBOOK
						(
						    MothDate,
						    Stage,
						    Code,
						    ProductionName,
						    Unit,
						    Qty,
							StatusIn,
							StatusOut,
							Remark,
						    CreateDateTime,
						    CreateUserID,
						    ChangeDateTime,
						    ChangeUserID
						)

						VALUES
						(
						    @MothDate,
						    @Stage,
						    @Code,
						    @ProductionName,
						    @Unit,
						    @Qty,
							@StatusIn,
							N'Nhập',
							@Remark,
						    DATEADD(HH, -2, GETDATE()),
						    @ProcessUserID,
						    @ChangeDateTime,
						    @ChangeUserID
						)

END ELSE IF @IUD_FLAG = 'UPDATE' BEGIN
 UPDATE STB_NOBOOK
						SET
							MothDate =   CASE
						                WHEN @MothDate IS NOT NULL THEN @MothDate
						                ELSE MothDate
						            END,
						Stage =   CASE
						                WHEN @Stage IS NOT NULL THEN @Stage
						                ELSE Stage
						            END,

							 Code =   CASE
						                WHEN @Code IS NOT NULL THEN @Code
						                ELSE Code
						            END,

							 ProductionName =   CASE
						                WHEN @ProductionName IS NOT NULL THEN @ProductionName
						                ELSE ProductionName
						            END,
							 Unit =   CASE
						                WHEN @Unit IS NOT NULL THEN @Unit
						                ELSE Unit
						            END,
						 Qty =   CASE
						                WHEN @Qty IS NOT NULL THEN @Qty
						                ELSE Qty
						            END,
						 StatusIn =   CASE
						                WHEN @StatusIn IS NOT NULL THEN @StatusIn
						                ELSE StatusIn
						            END,
						 StatusOut =   CASE
						                WHEN @StatusOut IS NOT NULL THEN @StatusOut
						                ELSE StatusOut
						            END,

							           
						 QtyOut =   CASE
						                WHEN @QtyOut IS NOT NULL THEN @QtyOut
						                ELSE QtyOut
						            END,

						 TotalInventory =   CASE
						                WHEN @TotalInventory IS NOT NULL THEN @TotalInventory
						                ELSE TotalInventory
						            END,

						
						 DATEOUT =   CASE
						                WHEN @DATEOUT IS NOT NULL THEN @DATEOUT
						                ELSE DATEOUT
						            END,

						 Remark =   CASE
						                WHEN @Remark IS NOT NULL THEN @Remark
						                ELSE Remark
						            END,
						    ChangeDateTime = DATEADD(HH, -2, GETDATE()),
						    ChangeUserID = @pProcessUserID
						
						
					WHERE
						    ID = @OldCompanyCode
						  END ELSE IF @IUD_FLAG = 'DELETE' BEGIN
                        DELETE FROM STB_NOBOOK
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