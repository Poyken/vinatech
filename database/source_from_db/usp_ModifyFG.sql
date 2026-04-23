CREATE PROCEDURE  [dbo].[usp_ModifyFG]
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
	DECLARE @Template  VARCHAR(20)

	


	  DECLARE @OldCompanyCode INT
	  DECLARE @DocNo  VARCHAR(20)
	  DECLARE @BasicDate Date
	  DECLARE @DocType VARCHAR(10)
	  DECLARE @DocStatus VARCHAR(20)
	  DECLARE @Description VARCHAR(200)
	  DECLARE @InvoiceNo NVARCHAR(20)
	  DECLARE @Department NVARCHAR(50)
	  DECLARE @CreateDateTime DATETIME
	  DECLARE @CreateUserID VARCHAR(20)
	  DECLARE @ChangeDateTime  DATETIME
	  DECLARE @ChangeUserID VARCHAR(20)
	  DECLARE @iDoc INT


	   EXEC SmartFramework.dbo.usp_GetSerialRule 
			@pTableName = 'STB_FinalProductInfo',
			@pIsAutoKey = @IsAutoKey OUTPUT,
			@pIsLoopIUD = @IsLoopIUD OUTPUT,
			@pPrefixData = @PrefixString OUTPUT,
			@pSerialLen = @SerialLen OUTPUT   

  IF @IsAutoKey = 0 AND @IsLoopIUD = 0 BEGIN
   
	    EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
   BEGIN TRY
   	-- Process Insert Table

	SET @Template = (
  
		select case when count(*) =0 then  convert(varchar, getdate(), 112)+'0001'
		else 
		cast(max(docno) as numeric)+1 
		END maxvalue
		FROM STB_FinalProductInfo where  DocNo like convert(varchar, getdate(), 112)+'%');

		
	MERGE STB_FinalProductInfo AS TargetTable

	USING
	
				(
					SELECT
							CASE
							    WHEN XMLData.OldCompanyCode IS NULL THEN XMLData.DocNo
							    ELSE XMLData.OldCompanyCode
							END AS OldCompanyCode,
							XMLData.DocNo,
							XMLData.BasicDate,
							XMLData.DocType,
							XMLData.DocStatus,
							XMLData.Description,
							XMLData.InvoiceNo,
							XMLData.Department,
							DATEADD(HH, -2, GETDATE()) AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							DATEADD(HH, -2, GETDATE()) AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID

		         	FROM
							OPENXML(@idoc , @InsertTableName , 2)
							WITH  (
										OldCompanyCode INT,
										DocNo varchar(20),
										BasicDate Date,
										DocType VARCHAR(10),
										DocStatus VARCHAR(20),
										Description VARCHAR(200),
										InvoiceNo NVARCHAR(20),
										Department NVARCHAR(50),
										CreateDateTime  DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime  DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) XMLData
				) AS SourceTable
					ON
				(
					TargetTable.DocNo = SourceTable.DocNo
				)
			WHEN MATCHED THEN
				UPDATE SET
					BasicDate = SourceTable.BasicDate,
					DocType = SourceTable.DocType,
					DocStatus = SourceTable.DocStatus,
					Description = SourceTable.Description,
					InvoiceNo = SourceTable.InvoiceNo,
					Department = SourceTable.Department,
					ChangeDateTime = SourceTable.ChangeDateTime,
					ChangeUserID = SourceTable.ChangeUserID

WHEN NOT MATCHED THEN

				INSERT
					(
						DocNo,
						BasicDate,
						DocType,
						DocStatus,
						Description,
						InvoiceNo,
						Department,
						CreateDateTime,
						CreateUserID
					)
				VALUES
					(
						--	SourceTable.DocNo,
							@Template,

							SourceTable.BasicDate,
							SourceTable.DocType,
							SourceTable.DocStatus,
							SourceTable.Description,
							SourceTable.InvoiceNo,
							SourceTable.Department,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID
					);

-- Process Update Table
	 MERGE STB_FinalProductInfo AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN XMLData.OldCompanyCode IS NULL THEN XMLData.DocNo
							    ELSE XMLData.OldCompanyCode
							END AS OldCompanyCode,
							XMLData.DocNo,
							XMLData.BasicDate,
							XMLData.DocType,
							XMLData.DocStatus,
							XMLData.Description,
							XMLData.InvoiceNo,
							XMLData.Department,
							DATEADD(HH, -2, GETDATE()) AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							DATEADD(HH, -2, GETDATE()) AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID

		         	FROM
							OPENXML(@idoc , @UpdateTableName , 2)
							WITH  (
										OldCompanyCode INT,
										DocNo varchar(20),
										BasicDate Date,
										DocType VARCHAR(10),
										DocStatus VARCHAR(20),
										Description VARCHAR(200),
										InvoiceNo NVARCHAR(20),
										Department NVARCHAR(50),
										CreateDateTime  DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime  DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) XMLData
				) AS SourceTable
			ON
				(
					TargetTable.DocNo = SourceTable.DocNo
				)
	WHEN MATCHED THEN
					UPDATE SET
					BasicDate = SourceTable.BasicDate,
					DocType = SourceTable.DocType,
					DocStatus = SourceTable.DocStatus,
					Description = SourceTable.Description,
					InvoiceNo = SourceTable.InvoiceNo,
					Department= SourceTable.Department,
					ChangeDateTime = SourceTable.ChangeDateTime,
					ChangeUserID = SourceTable.ChangeUserID
					
			WHEN NOT MATCHED THEN

	INSERT
					(
						DocNo,
						BasicDate,
						DocType,
						DocStatus,
						Description,
						InvoiceNo,
						Department,
						CreateDateTime,
						CreateUserID
					)
				VALUES
					(
							@Template,
						--	SourceTable.DocNo,
							SourceTable.BasicDate,
							SourceTable.DocType,
							SourceTable.DocStatus,
							SourceTable.Description,
							SourceTable.InvoiceNo,
							SOurceTable.Department,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID
					);


-- Process Delete Table
	MERGE STB_FinalProductInfo AS TargetTable
	USING
				(
					SELECT
							CASE
							    WHEN XMLData.OldCompanyCode IS NULL THEN XMLData.DocNo
							    ELSE XMLData.OldCompanyCode
							END AS OldCompanyCode,
							XMLData.DocNo,
							XMLData.BasicDate,
							XMLData.DocType,
							XMLData.DocStatus,
							XMLData.Description,
							XMLData.InvoiceNo,
							XMLData.Department,
							DATEADD(HH, -2, GETDATE()) AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							DATEADD(HH, -2, GETDATE()) AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID

		         	FROM
							OPENXML(@idoc , @DeleteTableName , 2)
							WITH  (
										OldCompanyCode INT,
										DocNo varchar(20),
										BasicDate Date,
										DocType VARCHAR(10),
										DocStatus VARCHAR(20),
										Description VARCHAR(200),
										InvoiceNo NVARCHAR(20),
										Department NVARCHAR(50),
										CreateDateTime  DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime  DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) XMLData
				) AS SourceTable
					ON
				(
					TargetTable.DocNo = SourceTable.DocNo
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
									XMLData.BasicDate,
									XMLData.DocType,
									XMLData.DocStatus,
									XMLData.Description,
									XMLData.InvoiceNo,
									XMLData.Department,
									XMLData.CreateDateTime,
									XMLData.CreateUserID,
									XMLData.ChangeDateTime,
									XMLData.ChangeUserID
							FROM
									OPENXML(@idoc , @InsertTableName , 2)
							        WITH  (
											 OldCompanyCode INT,
											DocNo varchar(20),
											BasicDate Date,
											DocType VARCHAR(10),
											DocStatus VARCHAR(20),
											Description VARCHAR(200),
											InvoiceNo NVARCHAR(20),
											Department NVARCHAR(50),
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
									XMLData.BasicDate,
									XMLData.DocType,
									XMLData.DocStatus,
									XMLData.Description,
									XMLData.InvoiceNo,
									XMLDAta.Department,
									XMLData.CreateDateTime,
									XMLData.CreateUserID,
									XMLData.ChangeDateTime,
									XMLData.ChangeUserID
							FROM
									OPENXML(@idoc , @UpdateTableName , 2)
							        WITH  (
											 OldCompanyCode INT,
											 DocNo varchar(20),
											BasicDate Date,
											DocType VARCHAR(10),
											DocStatus VARCHAR(20),
											Description VARCHAR(200),
											InvoiceNo NVARCHAR(20),
											Department NVARCHAR(50),
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
									XMLData.BasicDate,
									XMLData.DocType,
									XMLData.DocStatus,
									XMLData.Description,
									XMLData.InvoiceNo,
									XMLData.Department,
									XMLData.CreateDateTime,
									XMLData.CreateUserID,
									XMLData.ChangeDateTime,
									XMLData.ChangeUserID
							FROM
									OPENXML(@idoc , @DeleteTableName , 2)
							        WITH  (
											 OldCompanyCode INT,
											 DocNo varchar(20),
											BasicDate Date,
											DocType VARCHAR(10),
											DocStatus VARCHAR(20),
											Description VARCHAR(200),
											InvoiceNo NVARCHAR(20),
											Department NVARCHAR(50),
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
								 @BasicDate,
								 @DocType,
								 @DocStatus,
								 @Description,
								 @InvoiceNo,
								 @Department,
								 @CreateDateTime,
								 @CreateUserID,
								 @ChangeDateTime,
								 @ChangeUserID
  IF @@FETCH_STATUS <> 0 BEGIN
					BREAK
				END

				
		  IF @IUD_FLAG = 'INSERT' BEGIN

                    IF EXISTS (SELECT 1 FROM STB_FinalProductInfo WHERE DocNo = @OldCompanyCode) BEGIN
						RAISERROR('Duplicate Data : KeyField = %s', 16, 1, @OldCompanyCode)
					END
			 IF @IsAutoKey = 0 BEGIN
						EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_FinalProductInfo', @OldCompanyCode OUTPUT
            

				INSERT INTO STB_FinalProductInfo
						(
							DocNo,
						    BasicDate,
						    DocType,
						    DocStatus,
						    Description,
							InvoiceNo,
							Department,
						    CreateDateTime,
						    CreateUserID,
						    ChangeDateTime,
						    ChangeUserID
						)
						VALUES
						(
							@Template,
						    @BasicDate,
						    @DocType,
							@DocStatus,
							@Description,
							@InvoiceNo,
							@Department,
						    DATEADD(HH, -2, GETDATE()),
						    @pProcessUserID,
						    @ChangeDateTime,
						    @ChangeUserID
						)
END ELSE IF @IUD_FLAG = 'UPDATE' BEGIN
 UPDATE STB_FinalProductInfo
				SET
							BasicDate =   CASE
						                WHEN @BasicDate IS NOT NULL THEN @BasicDate
						                ELSE BasicDate
						            END,
							@DocType = CASE
								 WHEN @DocType IS NOT NULL THEN @DocType
						                ELSE DocType
						            END,
							@DocStatus = CASE
								 WHEN @DocStatus IS NOT NULL THEN @DocStatus
						                ELSE DocStatus
						            END,
							
							@Description = CASE
								 WHEN @Description IS NOT NULL THEN @Description
						                ELSE Description
						            END,
							@InvoiceNo = CASE
								 WHEN @InvoiceNo IS NOT NULL THEN @InvoiceNo
						                ELSE InvoiceNo
						            END,
							@Department = CASE
								 WHEN @Department IS NOT NULL THEN @Department
						                ELSE Department
						            END,
							ChangeDateTime = DATEADD(HH, -2, GETDATE()),
						    ChangeUserID = @pProcessUserID

WHERE
						    DocNo = @OldCompanyCode
						  END ELSE IF @IUD_FLAG = 'DELETE' BEGIN
                        DELETE FROM STB_FinalProductInfo
						WHERE
						    DocNo = @OldCompanyCode
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