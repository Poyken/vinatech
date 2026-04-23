CREATE PROC [dbo].[usp_VN_IssueReceipt]
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
	DECLARE @LOTNO NVARCHAR(50)
	DECLARE @MaterialCode NVARCHAR(50)
	DECLARE @MaterialName NVARCHAR(50)
	DECLARE @PublicCode NVARCHAR(100)
	DECLARE @PartNo NVARCHAR(100) 
	DECLARE @PackQty INT
	DECLARE @CreateDateTime DATETIME
    DECLARE @CreateUserID NVARCHAR(20)
    DECLARE @ChangeDateTime DATETIME
    DECLARE @ChangeUserID NVARCHAR(20)
	DECLARE @iDoc INT

		
	 EXEC SmartFramework.dbo.usp_GetSerialRule 
			@pTableName = 'STB_VN_RECEIPTVOUCHER_ISSUEVOUCHER',
			@pIsAutoKey = @IsAutoKey OUTPUT,
			@pIsLoopIUD = @IsLoopIUD OUTPUT,
			@pPrefixData = @PrefixString OUTPUT,
			@pSerialLen = @SerialLen OUTPUT

    IF @IsAutoKey = 0 AND @IsLoopIUD = 0 BEGIN
   
	    EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml

		 BEGIN TRY
			-- Process Insert Table
			 MERGE STB_VN_RECEIPTVOUCHER_ISSUEVOUCHER AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN XMLData.OldCompanyCode IS NULL THEN XMLData.ID
							    ELSE XMLData.OldCompanyCode
							END AS OldCompanyCode,
							XMLData.ID,
							XMLData.LOTNO,
							XMLData.MaterialCode,
							XMLData.MaterialName,
							XMLData.PublicCode,
							XMLData.PartNo,
							XMLData.PackQty,
							 DATEADD(HH, -2, GETDATE()) AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							 DATEADD(HH, -2, GETDATE()) AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
						
					FROM
							OPENXML(@idoc , @InsertTableName , 2)
							WITH  (
										OldCompanyCode INT,
										ID INT,
										LOTNO NVARCHAR(50),
										MaterialCode NVARCHAR(50),
										MaterialName NVARCHAR(50),
										PublicCode NVARCHAR(50),
										PartNo NVARCHAR(50),
										PackQty INT,
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
					LOTNO = SourceTable.LOTNO,
					MaterialCode = SourceTable.MaterialCode,
					MaterialName = SourceTable.MaterialName,
					PublicCode = SourceTable.PublicCode,
					PartNo = SourceTable.PartNo,
					PackQty = SourceTable.PackQty,
					ChangeDateTime = SourceTable.ChangeDateTime,
					ChangeUserID = SourceTable.ChangeUserID
					
WHEN NOT MATCHED THEN
				INSERT
					(
						LOTNO,
						MaterialCode,
						MaterialName,
						PublicCode,
						PartNo,
						PackQty,
						CreateDateTime,
						CreateUserID
						
					)
				VALUES
					(
							SourceTable.LOTNO,
							SourceTable.MaterialCode,
							SourceTable.MaterialName,
							SourceTable.PublicCode,
							SourceTable.PartNo,
							SourceTable.PackQty,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID
							
					);

	-- Process Update Table
	 MERGE STB_VN_RECEIPTVOUCHER_ISSUEVOUCHER AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN XMLData.OldCompanyCode IS NULL THEN XMLData.ID
							    ELSE XMLData.OldCompanyCode
							END AS OldCompanyCode,
							XMLData.ID,
							XMLData.LOTNO,
							XMLData.MaterialCode,
							XMLData.MaterialName,
							XMLData.PublicCode,
							XMLData.PartNo,
							XMLData.PackQty,
							 DATEADD(HH, -2, GETDATE()) AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							 DATEADD(HH, -2, GETDATE()) AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
							
					FROM
							OPENXML(@idoc , @UpdateTableName , 2)
							WITH  (
										OldCompanyCode INT,
										ID INT,
										LOTNO NVARCHAR(50),
										MaterialCode NVARCHAR(50),
										MaterialName NVARCHAR(50),
										PublicCode NVARCHAR(50),
										PartNo NVARCHAR(50),
										PackQty INT,
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
					LOTNO = SourceTable.LOTNO,
					MaterialCode = SourceTable.MaterialCode,
					MaterialName = SourceTable.MaterialName,
					PublicCode = SourceTable.PublicCode,
					PartNo = SourceTable.PartNo,
					PackQty = SourceTable.PackQty,
					ChangeDateTime = SourceTable.ChangeDateTime,
					ChangeUserID = SourceTable.ChangeUserID
					
			WHEN NOT MATCHED THEN
		INSERT
					(
						LOTNO,
						MaterialCode,
						MaterialName,
						PublicCode,
						PartNo,
						PackQty,
						CreateDateTime,
						CreateUserID
						
					)
				VALUES
					(
							SourceTable.LOTNO,
							SourceTable.MaterialCode,
							SourceTable.MaterialName,
							SourceTable.PublicCode,
							SourceTable.PartNo,
							SourceTable.PackQty,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID
							
					);

					
			-- Process Delete Table
            MERGE STB_VN_RECEIPTVOUCHER_ISSUEVOUCHER AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN XMLData.OldCompanyCode IS NULL THEN XMLData.ID
							    ELSE XMLData.OldCompanyCode
							END AS OldCompanyCode,
							XMLData.ID,
							XMLData.LOTNO,
							XMLData.MaterialCode,
							XMLData.MaterialName,
							XMLData.PublicCode,
							XMLData.PartNo,
							XMLData.PackQty,
							 DATEADD(HH, -2, GETDATE()) AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							 DATEADD(HH, -2, GETDATE()) AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
							
					FROM
							OPENXML(@idoc , @DeleteTableName , 2)
							WITH  (
										OldCompanyCode INT,
										ID INT,
										LOTNO VARCHAR(50),
										MaterialCode NVARCHAR(50),
										MaterialName NVARCHAR(50),
										PublicCode NVARCHAR(50),
										PartNo NVARCHAR(50),
										PackQty INT,
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
									XMLData.MaterialCode,
									XMLData.MaterialName,
									XMLData.PublicCode,
									XMLData.PartNo,
									XMLData.PackQty,
									XMLData.CreateDateTime,
									XMLData.CreateUserID,
									XMLData.ChangeDateTime,
									XMLData.ChangeUserID
									
							FROM
									OPENXML(@idoc , @InsertTableName , 2)
							        WITH  (
											 OldCompanyCode INT,
											 ID INT,
											 LOTNO VARCHAR(50),
											 MaterialCode NVARCHAR(50),
											 MaterialName NVARCHAR(50),
											 PublicCode NVARCHAR(50),
											 PartNo NVARCHAR(50),
											 PackQty INT,
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
									XMLData.MaterialCode,
									XMLData.MaterialName,
									XMLData.PublicCode,
									XMLData.PartNo,
									XMLData.PackQty,
									XMLData.CreateDateTime,
									XMLData.CreateUserID,
									XMLData.ChangeDateTime,
									XMLData.ChangeUserID
									
							FROM
									OPENXML(@idoc , @UpdateTableName , 2)
							        WITH  (
											 OldCompanyCode INT,
											 ID INT,
											 LOTNO VARCHAR(50),
											 MaterialCode NVARCHAR(50),
											 MaterialName NVARCHAR(50),
											 PublicCode NVARCHAR(50),
											 PartNo NVARCHAR(50),
											 PackQty INT,
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
									XMLData.MaterialCode,
									XMLData.MaterialName,
									XMLData.PublicCode,
									XMLData.PartNo,
									XMLData.PackQty,
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
											 MaterialCode NVARCHAR(50),
											 MaterialName NVARCHAR(50),
											 PublicCode NVARCHAR(50),
											 PartNo NVARCHAR(50),
											 PackQty INT,
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
								 @MaterialCode,
								 @MaterialName,
								 @PublicCode,
								 @PartNo,
								 @PackQty,
								 @CreateDateTime,
								 @CreateUserID,
								 @ChangeDateTime,
								 @ChangeUserID
								

			  IF @@FETCH_STATUS <> 0 BEGIN
					BREAK
				END

		  IF @IUD_FLAG = 'INSERT' BEGIN

                    IF EXISTS (SELECT 1 FROM STB_VN_RECEIPTVOUCHER_ISSUEVOUCHER WHERE ID = @OldCompanyCode) BEGIN
						RAISERROR('Duplicate Data : KeyField = %s', 16, 1, @OldCompanyCode)
					END
			 IF @IsAutoKey = 0 BEGIN
						EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_VN_RECEIPTVOUCHER_ISSUEVOUCHER', @OldCompanyCode OUTPUT

			
		INSERT INTO STB_VN_RECEIPTVOUCHER_ISSUEVOUCHER
						(
						    LOTNO,
						    MaterialCode,
						    MaterialName,
						    PublicCode,
							PartNo,
						    PackQty,
						    CreateDateTime,
						    CreateUserID,
						    ChangeDateTime,
						    ChangeUserID
						)
						VALUES
						(
						    @LOTNO,
						    @MaterialCode,
						    @MaterialName,
						    @PublicCode,
						    @PartNo,
						    @PackQty,
						    DATEADD(HH, -2, GETDATE()),
						    @pProcessUserID,
						    @ChangeDateTime,
						    @ChangeUserID
						
						)
END ELSE IF @IUD_FLAG = 'UPDATE' BEGIN
 UPDATE STB_VN_RECEIPTVOUCHER_ISSUEVOUCHER
						SET

						LOTNO = CASE
									WHEN @LOTNO IS NOT NULL THEN @LOTNO
									ELSE LOTNO
									END,
							MaterialCode =   CASE
						                WHEN @MaterialCode IS NOT NULL THEN @MaterialCode
						                ELSE MaterialCode
						            END,
						MaterialName =   CASE
						                WHEN @MaterialName IS NOT NULL THEN @MaterialName
						                ELSE MaterialName
						            END,

							 PublicCode =   CASE
						                WHEN @PublicCode IS NOT NULL THEN @PublicCode
						                ELSE PublicCode
						            END,

							 PartNo =   CASE
						                WHEN @PartNo IS NOT NULL THEN @PartNo
						                ELSE PartNo
						            END,
							 PackQty =   CASE
						                WHEN @PackQty IS NOT NULL THEN @PackQty
						                ELSE PackQty
						            END,
					
						           
						    ChangeDateTime = DATEADD(HH, -2, GETDATE()),
						    ChangeUserID = @pProcessUserID
						
					WHERE
						    ID = @OldCompanyCode
						  END ELSE IF @IUD_FLAG = 'DELETE' BEGIN
                        DELETE FROM STB_VN_RECEIPTVOUCHER_ISSUEVOUCHER
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