CREATE PROCEDURE  [dbo].[usp_ModifyFGDetail]
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
	DECLARE @ID INT

	


	  DECLARE @OldCompanyCode INT
	  DECLARE @DocNo  VARCHAR(20)
	  DECLARE @ProductCode VARCHAR(50)
	  DECLARE @Quantity INT
	  DECLARE @Description VARCHAR(200)
	  DECLARE @CreateDateTime DATETIME
	  DECLARE @CreateUserID VARCHAR(20)
	  DECLARE @ChangeDateTime  DATETIME
	  DECLARE @ChangeUserID VARCHAR(20)
	  DECLARE @iDoc INT





	   EXEC SmartFramework.dbo.usp_GetSerialRule 
			@pTableName = 'STB_FinalProductDetail',
			@pIsAutoKey = @IsAutoKey OUTPUT,
			@pIsLoopIUD = @IsLoopIUD OUTPUT,
			@pPrefixData = @PrefixString OUTPUT,
			@pSerialLen = @SerialLen OUTPUT   





  IF @IsAutoKey = 0 AND @IsLoopIUD = 0 BEGIN
   
	    EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
   BEGIN TRY
   	-- Process Insert Table



	MERGE STB_FinalProductDetail AS TargetTable
	USING
				(
					SELECT
							CASE
							    WHEN XMLData.OldCompanyCode IS NULL THEN XMLData.DocNo
							    ELSE XMLData.OldCompanyCode
							END AS OldCompanyCode,
							XMLData.DocNo,
							XMLData.ID,
							XMLData.ProductCode,
							XMLData.Quantity,
							XMLData.Description,
							DATEADD(HH, -2, GETDATE()) AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							DATEADD(HH, -2, GETDATE()) AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID

		         	FROM
							OPENXML(@idoc , @InsertTableName , 2)
							WITH  (
										OldCompanyCode INT,
										DocNo varchar(20),
										ID INT,
										ProductCode varchar(50),
										Quantity int,
										Description VARCHAR(200),
										CreateDateTime  DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime  DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) XMLData
				) AS SourceTable
					ON
				(
					--TargetTable.DocNo = SourceTable.DocNo
					TargetTable.ID= SourceTable.ID
				)
			WHEN MATCHED THEN
				UPDATE SET
					ProductCode = SourceTable.ProductCode,
					Quantity = SourceTable.Quantity,
					Description = SourceTable.Description,
					ChangeDateTime = SourceTable.ChangeDateTime,
					ChangeUserID = SourceTable.ChangeUserID

WHEN NOT MATCHED THEN
	
	

	

				INSERT
					(
						DocNo,
						ProductCode,
						Quantity,
						Description,
						CreateDateTime,
						CreateUserID
					)
				VALUES
					(
							SourceTable.DocNo,
							SourceTable.ProductCode,
							SourceTable.Quantity,
							SourceTable.Description,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID
					);

-- Process Update Table
	 MERGE STB_FinalProductDetail AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN XMLData.OldCompanyCode IS NULL THEN XMLData.DocNo
							    ELSE XMLData.OldCompanyCode
							END AS OldCompanyCode,
							XMLData.DocNo,
							XMLData.ID,
							XMLData.ProductCode,
							XMLData.Quantity,
							XMLData.Description,
							DATEADD(HH, -2, GETDATE()) AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							DATEADD(HH, -2, GETDATE()) AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID

		         	FROM
							OPENXML(@idoc , @UpdateTableName , 2)
							WITH  (
										OldCompanyCode INT,
										DocNo varchar(20),
										ID int,
										ProductCode varchar(50),
										Quantity int,
										Description VARCHAR(200),
										CreateDateTime  DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime  DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) XMLData
				) AS SourceTable
			ON
				(
					--TargetTable.DocNo = SourceTable.DocNo
					TargetTable.ID= SourceTable.ID
				)
	WHEN MATCHED THEN
					UPDATE SET
					ProductCode = SourceTable.ProductCode,
					Quantity = SourceTable.Quantity,
					Description = SourceTable.Description,
					ChangeDateTime = SourceTable.ChangeDateTime,
					ChangeUserID = SourceTable.ChangeUserID
					
			WHEN NOT MATCHED THEN

			INSERT
					(
						DocNo,
						ProductCode,
						Quantity,
						Description,
						CreateDateTime,
						CreateUserID
					)
				VALUES
					(
							SourceTable.DocNo,
							SourceTable.ProductCode,
							SourceTable.Quantity,
							SourceTable.Description,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID
					);



-- Process Delete Table
	MERGE STB_FinalProductDetail AS TargetTable
	USING
				(
					SELECT
							CASE
							    WHEN XMLData.OldCompanyCode IS NULL THEN XMLData.DocNo
							    ELSE XMLData.OldCompanyCode
							END AS OldCompanyCode,
							XMLData.DocNo,
							XMLData.ID,
							XMLData.ProductCode,
							XMLData.Quantity,
							XMLData.Description,
							DATEADD(HH, -2, GETDATE()) AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							DATEADD(HH, -2, GETDATE()) AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID

		         	FROM
							OPENXML(@idoc , @DeleteTableName , 2)
							WITH  (
										OldCompanyCode INT,
										DocNo varchar(20),
										ID INT,
										ProductCode varchar(50),
										Quantity int,
										Description VARCHAR(200),
										CreateDateTime  DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime  DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) XMLData
				) AS SourceTable
					ON
				(
					--TargetTable.DocNo = SourceTable.DocNo
					TargetTable.ID= SourceTable.ID
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
									XMLData.DocNo,
									XMLData.ID,
									XMLData.ProductCode,
									XMLData.Quantity,
									XMLData.Description,
									XMLData.CreateDateTime,
									XMLData.CreateUserID,
									XMLData.ChangeDateTime,
									XMLData.ChangeUserID
							FROM
									OPENXML(@idoc , @InsertTableName , 2)
							        WITH  (
											 OldCompanyCode INT,
											DocNo varchar(20),
											ID INT,
											ProductCode varchar(50),
											Quantity int,
											Description VARCHAR(200),
											CreateDateTime  DATETIMEOFFSET,
											CreateUserID VARCHAR(20),
											ChangeDateTime  DATETIMEOFFSET,
											ChangeUserID VARCHAR(20)
											) XMLData
							UNION ALL
SELECT
									'UPDATE' AS IUD_FLAG,
									CASE 
										WHEN XMLData.OldCompanyCode IS NULL THEN XMLData.DocNo
										ELSE XMLData.OldCompanyCode
									END AS OldCompanyCode,
									XMLData.DocNo,
									XMLData.ID,
									XMLData.ProductCode,
									XMLData.Quantity,
									XMLData.Description,
									XMLData.CreateDateTime,
									XMLData.CreateUserID,
									XMLData.ChangeDateTime,
									XMLData.ChangeUserID
							FROM
									OPENXML(@idoc , @UpdateTableName , 2)
							        WITH  (
											 OldCompanyCode INT,
											DocNo varchar(20),
											ID INT,
											ProductCode varchar(50),
											Quantity int,
											Description VARCHAR(200),
											CreateDateTime  DATETIMEOFFSET,
											CreateUserID VARCHAR(20),
											ChangeDateTime  DATETIMEOFFSET,
											ChangeUserID VARCHAR(20)
											) XMLData
UNION ALL

SELECT
									'DELETE' AS IUD_FLAG,
									CASE 
										WHEN XMLData.OldCompanyCode IS NULL THEN XMLData.DocNo
										ELSE XMLData.OldCompanyCode
									END AS OldCompanyCode,
									XMLData.DocNo,
									XMLData.ID,
									XMLData.ProductCode,
									XMLData.Quantity,
									XMLData.Description,
									XMLData.CreateDateTime,
									XMLData.CreateUserID,
									XMLData.ChangeDateTime,
									XMLData.ChangeUserID
							FROM
									OPENXML(@idoc , @DeleteTableName , 2)
							        WITH  (
											 OldCompanyCode INT,
											DocNo varchar(20),
											ID INT,
											ProductCode varchar(50),
											Quantity int,
											Description VARCHAR(200),
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
								 @ProductCode,
								 @Quantity,
								 @Description,
								 @CreateDateTime,
								 @CreateUserID,
								 @ChangeDateTime,
								 @ChangeUserID
  IF @@FETCH_STATUS <> 0 BEGIN
					BREAK
				END

				
		  IF @IUD_FLAG = 'INSERT' BEGIN

                  /*  IF EXISTS (SELECT 1 FROM STB_FinalProductDetail WHERE DocNo = @OldCompanyCode) BEGIN
						RAISERROR('Duplicate Data : KeyField = %s', 16, 1, @OldCompanyCode)
					END */
			 IF @IsAutoKey = 0 BEGIN
						EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_FinalProductDetail', @OldCompanyCode OUTPUT
            

				INSERT INTO STB_FinalProductDetail
							(
						DocNo,
						ProductCode,
						Quantity,
						Description,
						CreateDateTime,
						CreateUserID,
						ChangeDateTime,
						ChangeUserID
							)
						VALUES
							(
							@DocNo,
						    @ProductCode,
						    @Quantity,
							@Description,
						    DATEADD(HH, -2, GETDATE()),
						    @pProcessUserID,
						    @ChangeDateTime,
						    @ChangeUserID
					);

END ELSE IF @IUD_FLAG = 'UPDATE' BEGIN
 UPDATE STB_FinalProductIDetail
				SET
							@ProductCode =   CASE
						                WHEN @ProductCode IS NOT NULL THEN @ProductCode
						                ELSE ProductCode
						            END,
							@Quantity = CASE
								 WHEN @Quantity IS NOT NULL THEN @Quantity
						                ELSE Quantity
						            END,
							
							@Description = CASE
								 WHEN @Description IS NOT NULL THEN @Description
						                ELSE Description
						            END,

							ChangeDateTime = DATEADD(HH, -2, GETDATE()),
						    ChangeUserID = @pProcessUserID

WHERE
						    DocNo = @OldCompanyCode
						  END ELSE IF @IUD_FLAG = 'DELETE' BEGIN
                        DELETE FROM STB_FinalProductDetail
						WHERE
						 --   DocNo = @OldCompanyCode
						 ID = @ID
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