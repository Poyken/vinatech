CREATE PROC [dbo].[usp_VN_ActionUpdateFormEletroder]
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
	DECLARE @ActuallyQtyProvider INT
	DECLARE @Statuss BIT
	DECLARE @DateApprovered DATETIME
	DECLARE @ApproverBy NVARCHAR(50)
	
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
							XMLData.ActuallyQtyProvider,
							XMLData.Statuss,
							 DATEADD(HH, -2, GETDATE()) AS DateApprovered,
							@pProcessUserID AS ApproverBy
							
							
					FROM
							OPENXML(@idoc , @InsertTableName , 2)
							WITH  (
										OldCompanyCode INT,
										ID INT,
										ActuallyQtyProvider INT,
										Statuss BIT,
										DateApprovered  DATETIMEOFFSET,
										ApproverBy VARCHAR(20)
									
										
									) XMLData
				) AS SourceTable

				ON
				(
					TargetTable.ID = SourceTable.ID
				)
			WHEN MATCHED THEN
				UPDATE SET
					ActuallyQtyProvider = SourceTable.ActuallyQtyProvider,
					Statuss = 'True',
					DateApprovered = SourceTable.DateApprovered,
					ApproverBy = SourceTable.ApproverBy

				WHEN NOT MATCHED THEN

				INSERT
					(
						ActuallyQtyProvider,
						Statuss,
						DateApprovered,
						ApproverBy
					)
				VALUES
					(
							SourceTable.ActuallyQtyProvider,
							SourceTable.Statuss,
							SourceTable.DateApprovered,
							SourceTable.ApproverBy
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
							XMLData.ActuallyQtyProvider,
							XMLData.Statuss,
							 DATEADD(HH, -2, GETDATE()) AS DateApprovered,
							@pProcessUserID AS ApproverBy
							
						
					FROM
							OPENXML(@idoc , @UpdateTableName , 2)
							WITH  (
										OldCompanyCode INT,
										ID INT,
										ActuallyQtyProvider INT,
										Statuss BIT,
										DateApprovered  DATETIMEOFFSET,
										ApproverBy VARCHAR(20)
										
									
									) XMLData
				) AS SourceTable
			ON
				(
					TargetTable.ID = SourceTable.ID
				)

		WHEN MATCHED THEN

				UPDATE SET
					ActuallyQtyProvider = SourceTable.ActuallyQtyProvider,
					Statuss = 'True',
					DateApprovered = SourceTable.DateApprovered,
					ApproverBy = SourceTable.ApproverBy
					
			WHEN NOT MATCHED THEN

		INSERT
					(
						ActuallyQtyProvider,
						Statuss,
						DateApprovered,
						ApproverBy
						
					)
				VALUES
					(
							SourceTable.ActuallyQtyProvider,
							SourceTable.Statuss,
							SourceTable.DateApprovered,
							SourceTable.ApproverBy
							
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
							XMLData.ActuallyQtyProvider,
							XMLData.Statuss,
							 DATEADD(HH, -2, GETDATE()) AS DateApprovered,
							@pProcessUserID AS ApproverBy
							
						
					FROM
							OPENXML(@idoc , @DeleteTableName , 2)
							WITH  (
										OldCompanyCode INT,
										ID INT,
										ActuallyQtyProvider INT,
										Statuss BIT,
										DateApprovered  DATETIMEOFFSET,
										ApproverBy VARCHAR(20)
										
										
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
									XMLData.ActuallyQtyProvider,
									XMLData.Statuss,
									XMLData.DateApprovered,
									XMLData.ApproverBy
								
									
							FROM
									OPENXML(@idoc , @InsertTableName , 2)
							        WITH  (
											 OldCompanyCode INT,
											 ID INT,
											 ActuallyQtyProvider INT,
											 Statuss BIT,
											 DateApprovered  DATETIMEOFFSET,
											 ApproverBy VARCHAR(20)
											
											) XMLData
									UNION ALL

SELECT
									'UPDATE' AS IUD_FLAG,
									CASE 
										WHEN XMLData.OldCompanyCode IS NULL THEN XMLData.ID
										ELSE XMLData.OldCompanyCode
									END AS OldCompanyCode,
									XMLData.ID,
									XMLData.ActuallyQtyProvider,
									XMLData.Statuss,
									XMLData.DateApprovered,
									XMLData.ApproverBy
									
								
							FROM
									OPENXML(@idoc , @UpdateTableName , 2)
							        WITH  (
											 OldCompanyCode INT,
											 ID INT,
											 ActuallyQtyProvider INT,
											 Statuss BIT,
											 DateApprovered  DATETIMEOFFSET,
											 ApproverBy VARCHAR(20)
											
											) XMLData
UNION ALL

SELECT
									'DELETE' AS IUD_FLAG,
									CASE 
										WHEN XMLData.OldCompanyCode IS NULL THEN XMLData.ID
										ELSE XMLData.OldCompanyCode
									END AS OldCompanyCode,
									XMLData.ID,
									XMLData.ActuallyQtyProvider,
									XMLData.Statuss,
									XMLData.DateApprovered,
									XMLData.ApproverBy
								
								
							FROM
									OPENXML(@idoc , @DeleteTableName , 2)
							        WITH  (
											 OldCompanyCode VARCHAR(20),
											 ID INT,
											 ActuallyQtyProvider INT,
											 Statuss BIT,
											 DateApprovered  DATETIMEOFFSET,
											 ApproverBy VARCHAR(20)
											
											
											) XMLData
					 OPEN SourceData

					 
					   WHILE 1 = 1 BEGIN
                FETCH NEXT FROM SourceData INTO
								 @IUD_FLAG,
								 @OldCompanyCode,
								 @ActuallyQtyProvider,
								 @Statuss,
								 @DateApprovered,
								 @ApproverBy
							
								

			  IF @@FETCH_STATUS <> 0 BEGIN
					BREAK
				END

		  IF @IUD_FLAG = 'INSERT' BEGIN

                    IF EXISTS (SELECT 1 FROM STB_VN_ELECTRODE_REQUESTFORM WHERE ID = @OldCompanyCode) BEGIN
						RAISERROR('Duplicate Data : KeyField = %s', 16, 1, @OldCompanyCode)
					END
			 IF @IsAutoKey = 0 BEGIN
						EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_VN_ELECTRODE_REQUESTFORM', @OldCompanyCode OUTPUT

			INSERT INTO STB_VN_ELECTRODE_REQUESTFORM
						(
						    ActuallyQtyProvider,
						    Statuss,
						    DateApprovered,
						    ApproverBy
						   
							
						)
						VALUES
						(
						    @ActuallyQtyProvider,
						    'True',
						    DATEADD(HH, -2, GETDATE()),
						    @pProcessUserID
						  
						)

END ELSE IF @IUD_FLAG = 'UPDATE' BEGIN
 UPDATE STB_VN_ELECTRODE_REQUESTFORM
						SET

							 ActuallyQtyProvider =   CASE
						                WHEN @ActuallyQtyProvider IS NOT NULL THEN @ActuallyQtyProvider
						                ELSE ActuallyQtyProvider
						            END,

							 Statuss =   CASE
						                WHEN @Statuss IS NOT NULL THEN @Statuss
						                ELSE Statuss
									END
						  
						
					
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