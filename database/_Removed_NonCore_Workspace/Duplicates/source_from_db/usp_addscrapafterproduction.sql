	--ID INT IDENTITY(1,1) NOT NULL PRIMARY KEY(ID),
	--DEPARTMENTNAME NVARCHAR(100) NULL,
	--NAMEERROR NVARCHAR(100) NULL,
	--TYPEINPUT NVARCHAR(100) NULL,
	--INPUT NVARCHAR(100) NULL,
	--UNIT NVARCHAR(100) NULL,
	--LOTNO NVARCHAR(50) NULL,
	--SHITF NVARCHAR(50) NULL,
	--CreateDateTime DATETIME NULL,
	--CreateUserID NVARCHAR(50) NULL,
	--ChangeDateTime DATETIME NULL,
	--ChangeUserID NVARCHAR(50) NULL

		--DESCRIPTIONS NVARCHAR(500) NULL,
		--FILEID BIGINT NULL


	CREATE PROC [dbo].[usp_addscrapafterproduction]
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

	 -- Declare Columns Variable
	 DECLARE @OldCompanyCode INT
	 DECLARE @ID INT
	 DECLARE @DEPARTMENTNAME NVARCHAR(100)
	 DECLARE @NAMEERROR NVARCHAR(100)
	 DECLARE @TYPEINPUT NVARCHAR(100)
	 DECLARE @INPUT NVARCHAR(100)
	 DECLARE @UNIT NVARCHAR(100)
	 DECLARE @LOTNO NVARCHAR(50)
	 DECLARE @SHITF NVARCHAR(50)
	 DECLARE @QTY float
	 DECLARE @DESCRIPTIONS NVARCHAR(500) 
	 DECLARE @FILEID BIGINT 
	 DECLARE @CreateDateTime DATETIME
     DECLARE @CreateUserID NVARCHAR(20)
     DECLARE @ChangeDateTime DATETIME
     DECLARE @ChangeUserID NVARCHAR(20)
	 DECLARE @TYPES NVARCHAR(20)
	 DECLARE @CODENAME NVARCHAR(50)
	 DECLARE @CompanyCode    VARCHAR(20) 
     DECLARE @WorkCenterCode VARCHAR(20) 
	 DECLARE @iDoc INT

	DECLARE @FileName NVARCHAR(255)
	DECLARE @FileSize BIGINT
	DECLARE @FileData VARBINARY(MAX)
	

	declare @errrr NVARCHAR(500)=@pProcessUserID+N' - Bạn không được phép SỬA(XÓA) dữ liệu màn hình này.  Liên hệ  Ms.Sao  của Kế hoạch SX!';
	declare @XXMMLL NVARCHAR(MAX) = convert(NVARCHAR(MAX),@pXml);
	declare @existsUPDATE INT = charindex(@ProcessViewName +'_UPDATE',@XXMMLL);
	declare @existsDELETE INT = charindex(@ProcessViewName +'_DELETE',@XXMMLL);
	

	if(@pProcessUserID  like '%work%') begin
				
				raiserror (@errrr,16,1);								
				return;
	end

	  EXEC SmartFramework.dbo.usp_GetSerialRule 
			@pTableName = 'STB_VN_SCRAP_AFTERPRODUCTIONS',
			@pIsAutoKey = @IsAutoKey OUTPUT,
			@pIsLoopIUD = @IsLoopIUD OUTPUT,
			@pPrefixData = @PrefixString OUTPUT,
			@pSerialLen = @SerialLen OUTPUT

 BEGIN
   EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
        BEGIN TRY
				  DECLARE SourceData CURSOR FOR 
				   SELECT 
                        'INSERT' AS IUD_FLAG, 
									XMLData.OldCompanyCode, 
									XMLData.ID,
									XMLData.DEPARTMENTNAME,
									XMLData.NAMEERROR,
									XMLData.TYPEINPUT,
									XMLData.INPUT,
									XMLData.UNIT,
									XMLData.LOTNO,
									XMLData.SHITF,
									XMLData.QTY,
									XMLData.DESCRIPTIONS,
									dbo.fnBase64ToBinary(XMLData.FILEID) as FILEID,
									XMLData.TYPES,
									XMLData.CODENAME,
									XMLData.CreateDateTime,
									XMLData.CreateUserID,
									XMLData.ChangeDateTime,
									XMLData.ChangeUserID,
									XMLData.CompanyCode,
									XMLData.WorkCenterCode 
							FROM
									OPENXML(@idoc , @InsertTableName , 2)
							        WITH  (
											 OldCompanyCode INT,
											 ID INT,
											 DEPARTMENTNAME NVARCHAR(50),
											 NAMEERROR NVARCHAR(120),
											 TYPEINPUT NVARCHAR(50),
											 INPUT NVARCHAR(50),
											 UNIT NVARCHAR(50),
											 LOTNO NVARCHAR(50),
											 SHITF NVARCHAR(50),
											 QTY float,
											 DESCRIPTIONS NVARCHAR(500),
											 FILEID BIGINT,
											 TYPES NVARCHAR(50),
											 CODENAME NVARCHAR(50),
											 CreateDateTime  DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime  DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20),
											 CompanyCode    VARCHAR(20), 
											 WorkCenterCode VARCHAR(20) 
											) XMLData
									UNION ALL
SELECT
									'UPDATE' AS IUD_FLAG,
									CASE 
										WHEN XMLData.OldCompanyCode IS NULL THEN XMLData.ID
										ELSE XMLData.OldCompanyCode
									END AS OldCompanyCode,
									XMLData.ID,
									XMLData.DEPARTMENTNAME,
									XMLData.NAMEERROR,
									XMLData.TYPEINPUT,
									XMLData.INPUT,
									XMLData.UNIT,
									XMLData.LOTNO,
									XMLData.SHITF,
									XMLData.QTY,
									DESCRIPTIONS,
									dbo.fnBase64ToBinary(XMLData.FILEID) as FILEID,
									XMLData.TYPES,
									XMLData.CODENAME,
									XMLData.CreateDateTime,
									XMLData.CreateUserID,
									XMLData.ChangeDateTime,
									XMLData.ChangeUserID,
									XMLData.CompanyCode,
									XMLData.WorkCenterCode 
									
							FROM
									OPENXML(@idoc , @UpdateTableName , 2)
							        WITH  (
											 OldCompanyCode INT,
											 ID INT,
											 DEPARTMENTNAME NVARCHAR(50),
											 NAMEERROR NVARCHAR(120),
											 TYPEINPUT NVARCHAR(50) ,
											 INPUT NVARCHAR(50),
											 UNIT NVARCHAR(50),
											 LOTNO NVARCHAR(50),
											 SHITF NVARCHAR(50),
											 QTY float,
											 DESCRIPTIONS NVARCHAR(500),
											 FILEID BIGINT,
											 TYPES NVARCHAR(50),
											 CODENAME NVARCHAR(50),
											 CreateDateTime  DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime  DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20),
										     CompanyCode    VARCHAR(20), 
											 WorkCenterCode VARCHAR(20) 
											)XMLData
UNION ALL
SELECT
									'DELETE' AS IUD_FLAG,
									CASE 
										WHEN XMLData.OldCompanyCode IS NULL THEN XMLData.ID
										ELSE XMLData.OldCompanyCode
									END AS OldCompanyCode,
									XMLData.ID,
									XMLData.DEPARTMENTNAME,
									XMLData.NAMEERROR,
									XMLData.TYPEINPUT ,
									XMLData.INPUT  ,
									XMLData.UNIT,
									XMLData.LOTNO,
									XMLData.SHITF,
									XMLData.QTY,
									XMLData.DESCRIPTIONS,
									dbo.fnBase64ToBinary(XMLData.FILEID) as FILEID,
									XMLData.TYPES,
									XMLData.CODENAME,
									XMLData.CreateDateTime,
									XMLData.CreateUserID,
									XMLData.ChangeDateTime,
									XMLData.ChangeUserID,
									XMLData.CompanyCode,
									XMLData.WorkCenterCode 
							FROM
									OPENXML(@idoc , @DeleteTableName , 2)
							        WITH  (
											 OldCompanyCode int,
											 ID INT,
											 DEPARTMENTNAME NVARCHAR(50),
											 NAMEERROR NVARCHAR(120),
											 TYPEINPUT NVARCHAR(50),
											 INPUT NVARCHAR(50),
											 UNIT NVARCHAR(50),
											 LOTNO NVARCHAR(50),
											 SHITF NVARCHAR(50),
											 QTY float,
											 DESCRIPTIONS NVARCHAR(500),
											 FILEID BIGINT,
											 TYPES NVARCHAR(50),
											 CODENAME NVARCHAR(50),
											 CreateDateTime  DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime  DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20),
											 CompanyCode    VARCHAR(20), 
											 WorkCenterCode VARCHAR(20) 
											
											) XMLData
					 OPEN SourceData

					   WHILE 1 = 1 BEGIN
                FETCH NEXT FROM SourceData INTO
								 @IUD_FLAG,
								 @OldCompanyCode,
								 @ID,
								 @DEPARTMENTNAME,
								 @NAMEERROR,
								 @TYPEINPUT,
								 @INPUT,
								 @UNIT,
								 @LOTNO,
								 @SHITF,
								 @QTY,
								 @DESCRIPTIONS,
								 @FILEID,
								 @TYPES,
								 @CODENAME,
								 @CreateDateTime,
								 @CreateUserID,
								 @ChangeDateTime,
								 @ChangeUserID,
								 @CompanyCode,
								 @WorkCenterCode
								
			  IF @@FETCH_STATUS <> 0 BEGIN
					BREAK
				END
									

		  IF @IUD_FLAG = 'INSERT' BEGIN

                    IF EXISTS (SELECT 1 FROM STB_VN_SCRAP_AFTERPRODUCTIONS WHERE ID = isnull(@ID,0)) BEGIN
						RAISERROR('Duplicate Data : KeyField = %s', 16, 1, @ID)
						break;
						return;
					END
						
						  EXEC SmartFramework.dbo.usp_DoSaveFile 
							@pSystemName = 'STB_VN_SCRAP_AFTERPRODUCTIONS',
							@pFileContents = @FileData,
							@pFileName = @FileName,
							@pFileSize = @FileSize,
							@pUserID = @ProcessUserID,
							@pFileID = @FILEID OUTPUT

		INSERT INTO STB_VN_SCRAP_AFTERPRODUCTIONS
						(
						    DEPARTMENTNAME,
						    NAMEERROR,
						    TYPEINPUT,
						    INPUT,
						    UNIT,
							LOTNO,
							SHITF,
							QTY,
							DESCRIPTIONS,
							FILEID,
							TYPES,
							CODENAME,
						    CreateDateTime,
						    CreateUserID,
						    ChangeDateTime,
						    ChangeUserID,
							CompanyCode,
							WorkCenterCode
							
						)
						VALUES
						(
						     @DEPARTMENTNAME,
						     @NAMEERROR,
						     @TYPEINPUT,
						     @INPUT,
						     @UNIT,
							 @LOTNO,
							 @SHITF,
							 @QTY,
							 @DESCRIPTIONS,
							 @FILEID,
							 @TYPES,
							 @CODENAME,
						    DATEADD(HH, -2, GETDATE()),
						    @pProcessUserID,
						    @ChangeDateTime,
						    @ChangeUserID,
							@CompanyCode,
							@WorkCenterCode
						)

 end  else  IF @IUD_FLAG = 'UPDATE' BEGIN
 				
						  	if(@pProcessUserID  not in ('sieusao','transao','nguyennha','anhduy157')) begin
								break;
								raiserror (@errrr,16,1);
								
								return;
							end

 EXEC SmartFramework.dbo.usp_DoSaveFile 
	@pSystemName = 'STB_VN_SCRAP_AFTERPRODUCTIONS',
							@pFileContents = @FileData,
							@pFileName = @FileName,
							@pFileSize = @FileSize,
							@pUserID = @ProcessUserID,
							@pFileID = @FILEID OUTPUT

 UPDATE STB_VN_SCRAP_AFTERPRODUCTIONS
						SET

							CompanyCode = CASE
									WHEN @CompanyCode IS NOT NULL THEN @CompanyCode
									ELSE CompanyCode
									END,

										WorkCenterCode = CASE
									WHEN @WorkCenterCode IS NOT NULL THEN @WorkCenterCode
									ELSE WorkCenterCode
									END,

						DEPARTMENTNAME = CASE
									WHEN @DEPARTMENTNAME IS NOT NULL THEN @DEPARTMENTNAME
									ELSE DEPARTMENTNAME
									END,
						
						NAMEERROR =   CASE
						                WHEN @NAMEERROR IS NOT NULL THEN @NAMEERROR
						                ELSE NAMEERROR
						            END,

							 TYPEINPUT =   CASE
						                WHEN @TYPEINPUT IS NOT NULL THEN @TYPEINPUT
						                ELSE TYPEINPUT
						            END,

							 INPUT =   CASE
						                WHEN @INPUT IS NOT NULL THEN @INPUT
						                ELSE INPUT
						            END,
							 UNIT =   CASE
						                WHEN @UNIT IS NOT NULL THEN @UNIT
						                ELSE UNIT
						            END,
						 LOTNO =   CASE
						                WHEN @LOTNO IS NOT NULL THEN @LOTNO
						                ELSE LOTNO
						            END,
						 SHITF =   CASE
						                WHEN @SHITF IS NOT NULL THEN @SHITF
						                ELSE SHITF
						            END,

						 QTY =   CASE
						                WHEN @QTY IS NOT NULL THEN @QTY
						                ELSE QTY
						            END,

						DESCRIPTIONS = CASE
										WHEN @DESCRIPTIONS IS NOT NULL THEN @DESCRIPTIONS
										ELSE DESCRIPTIONS
										END,

						FILEID = CASE
										WHEN @FILEID IS NOT NULL THEN @FILEID
										ELSE FILEID
								END,

										TYPES = CASE
										WHEN @TYPES IS NOT NULL THEN @TYPES
										ELSE TYPES
								END,

										CODENAME = CASE
										WHEN @CODENAME IS NOT NULL THEN @CODENAME
										ELSE CODENAME
								END,
					
						    ChangeDateTime = DATEADD(HH, -2, GETDATE()),
						    ChangeUserID = @pProcessUserID
						
					
					WHERE  ID = @OldCompanyCode

	end else  IF @IUD_FLAG = 'DELETE' BEGIN 

						  	if(@pProcessUserID  not in ('sieusao','transao','nguyennha','anhduy157')) begin
								break;
								raiserror (@errrr,16,1);								
								return;
							end

                     DELETE FROM STB_VN_SCRAP_AFTERPRODUCTIONS
						WHERE
						    ID = @OldCompanyCode
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

