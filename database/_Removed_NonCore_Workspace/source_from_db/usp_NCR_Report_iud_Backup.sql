-- =============================================
-- Author:	    Anonymous()
-- Create date: 2020-09-07
-- Browsable : true
-- Group : 품질관리 > 시료별수입검사> NCR등록
-- Description:	
-- Modified:
-- =============================================
Create PROCEDURE [dbo].[usp_NCR_Report_iud_Backup]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
    @pProcessViewName VARCHAR(50),
	@pXml NVARCHAR(MAX) = null
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

    -- Declare Columns Variable
  DECLARE @OldNCRNo VARCHAR(20)
  DECLARE @NCRNo VARCHAR(20)
  DECLARE @JobDate DATETIME
  DECLARE @CompanyCode VARCHAR(20)
  DECLARE @OccurProcessCode VARCHAR(20)
  DECLARE @MaterialName VARCHAR(80)
  DECLARE @CustomName VARCHAR(60)
  DECLARE @standardName VARCHAR(60)
  DECLARE @LotNo VARCHAR(80)
  DECLARE @Qty INT
  DECLARE @InspectionQty INT
  DECLARE @BadQty INT
  DECLARE @PPM INT
  DECLARE @InQty INT
  DECLARE @BadLotQty INT
  DECLARE @DefectiveRate NUMERIC(5,2)
  DECLARE @CreateUserID VARCHAR(20)
  DECLARE @Nonconformity NVARCHAR(4000)
  DECLARE @ImmediateAction NVARCHAR(4000)
  DECLARE @CustomImmediateAction NVARCHAR(4000)
  
  DECLARE @IsActionCode BIT
  DECLARE @EffectivenessCheck BIT
  DECLARE @DefectImage VARBINARY(MAX)
  DECLARE @DefectImage2 VARBINARY(MAX)
  DECLARE @CreateDateTime DATETIME
	
	--DECLARE @MachineImage BIGINT
	DECLARE @CustomCountermeasureImage VARBINARY(MAX)
	DECLARE @FileName NVARCHAR(255)
	DECLARE @FileSize BIGINT
	DECLARE @FileData VARBINARY(MAX)
  
	
	DECLARE @iDoc INT

    EXEC SmartFramework.dbo.usp_GetSerialRule 
			@pTableName = 'STB_NCR_Report',
			@pIsAutoKey = @IsAutoKey OUTPUT,
			@pIsLoopIUD = @IsLoopIUD OUTPUT,
			@pPrefixData = @PrefixString OUTPUT,
			@pSerialLen = @SerialLen OUTPUT
    
    IF @IsAutoKey = 0 AND @IsLoopIUD = 0 
	
	BEGIN
		PRINT 'Not Used MERGE'	    
    END ELSE BEGIN
        EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
        BEGIN TRY
		    DECLARE SourceData CURSOR FOR
                SELECT
                        'INSERT' AS IUD_FLAG,
							        CASE  WHEN XMLData.OldNCRNo IS NULL THEN XMLData.OldNCRNo 	ELSE XMLData.OldNCRNo 	END AS OldNCRNo, 
									XMLData.NCRNo,
									XMLData.JobDate,
									XMLData.CompanyCode,
									XMLData.OccurProcessCode,
									XMLData.MaterialName,
									XMLData.CustomName,
									XMLData.standardName,
									XMLData.LotNo,
									XMLData.Qty,
									XMLData.InspectionQty,
									XMLData.BadQty,
									XMLData.PPM,
									XMLData.InQty,
									XMLData.BadLotQty,
									XMLData.DefectiveRate,
									XMLData.CreateUserID AS CreateUserID,
									XMLData.Nonconformity,
									XMLData.ImmediateAction,
									XMLData.CustomImmediateAction,
									--XMLData.dbo.fnBase64ToBinary(CustomCountermeasureImage) as CustomCountermeasureImage,
									XMLData.IsActionCode,
									XMLData.EffectivenessCheck,
									dbo.fnBase64ToBinary(DefectImage) as DefectImage,
									dbo.fnBase64ToBinary(DefectImage2) as DefectImage2,
									GETDATE() AS CreateDateTime,

									--XMLData.dbo.fnBase64ToBinary(CustomCountermeasureImage) as CustomCountermeasureImage,
									XMLData.[FileName],
									XMLData.FileSize,
									dbo.fnBase64ToBinary(XMLData.FileData) as FileData,
									XMLData.CustomCountermeasureImage
							FROM
									OPENXML(@idoc , @InsertTableName , 2)
							        WITH  (
											   OldNCRNo VARCHAR(20),
												NCRNo VARCHAR(20),
												JobDate DATETIMEOFFSET,
												CompanyCode VARCHAR(20),
												OccurProcessCode VARCHAR(20),
												MaterialName VARCHAR(80),
												CustomName VARCHAR(60),
												standardName VARCHAR(60),
												LotNo VARCHAR(80),
												Qty INT,
												InspectionQty INT,
												BadQty INT,
												PPM INT,
												InQty INT,
												BadLotQty INT,
												DefectiveRate NUMERIC(5,2),
												CreateUserID VARCHAR(20),
												Nonconformity NVARCHAR(4000),
												ImmediateAction NVARCHAR(4000),
												CustomImmediateAction NVARCHAR(4000),
										
												IsActionCode BIT,
												EffectivenessCheck BIT,
												DefectImage NVARCHAR(MAX),
												DefectImage2 NVARCHAR(MAX),
												CreateDateTime DATETIMEOFFSET,

												--CustomCountermeasureImage NVARCHAR(MAX),
												 [FileName] NVARCHAR(255),
												 FileSize BIGINT,
												 FileData NVARCHAR(MAX),
												 CustomCountermeasureImage BIGINT								 
											) XMLData
							UNION ALL


							SELECT
									'UPDATE' AS IUD_FLAG,
									 CASE  WHEN XMLData.OldNCRNo IS NULL THEN XMLData.OldNCRNo 	ELSE XMLData.OldNCRNo 	END AS OldNCRNo, 
									 XMLData.NCRNo,
									XMLData.JobDate,
									XMLData.CompanyCode,
									XMLData.OccurProcessCode,
									XMLData.MaterialName,
									XMLData.CustomName,
									XMLData.standardName,
									XMLData.LotNo,
									XMLData.Qty,

									XMLData.InspectionQty,
									XMLData.BadQty,
									XMLData.PPM,
									XMLData.InQty,
									XMLData.BadLotQty,
									XMLData.DefectiveRate,
									XMLData.CreateUserID AS CreateUserID,
									XMLData.Nonconformity,
									XMLData.ImmediateAction,
									XMLData.CustomImmediateAction,									
									XMLData.IsActionCode,
									XMLData.EffectivenessCheck,
									dbo.fnBase64ToBinary(DefectImage) as DefectImage,
									dbo.fnBase64ToBinary(DefectImage2) as DefectImage2,
									GETDATE() AS CreateDateTime,

									--XMLData.dbo.fnBase64ToBinary(CustomCountermeasureImage) as CustomCountermeasureImage,
									XMLData.[FileName],
									XMLData.FileSize,
									dbo.fnBase64ToBinary(XMLData.FileData) as FileData,
									XMLData.CustomCountermeasureImage
									
							FROM
									OPENXML(@idoc , @UpdateTableName , 2)
							        WITH  (
											OldNCRNo VARCHAR(20),
												NCRNo VARCHAR(20),
												JobDate DATETIMEOFFSET,
												CompanyCode VARCHAR(20),
												OccurProcessCode VARCHAR(20),
												MaterialName VARCHAR(80),
												CustomName VARCHAR(60),
												standardName VARCHAR(60),
												LotNo VARCHAR(80),
												Qty INT,
												InspectionQty INT,
												BadQty INT,
												PPM INT,
												InQty INT,
												BadLotQty INT,
												DefectiveRate NUMERIC(5,2),
												CreateUserID VARCHAR(20),
												Nonconformity NVARCHAR(4000),
												ImmediateAction NVARCHAR(4000),
												CustomImmediateAction NVARCHAR(4000),										
												IsActionCode BIT,
												EffectivenessCheck BIT,
												DefectImage NVARCHAR(MAX),
												DefectImage2 NVARCHAR(MAX),
												CreateDateTime DATETIMEOFFSET,

												--CustomCountermeasureImage NVARCHAR(MAX),
												 [FileName] NVARCHAR(255),
												 FileSize BIGINT,
												 FileData NVARCHAR(MAX),
												 CustomCountermeasureImage BIGINT
											) XMLData
							UNION ALL
							SELECT
									'DELETE' AS IUD_FLAG,
									 CASE  WHEN XMLData.OldNCRNo IS NULL THEN XMLData.OldNCRNo 	ELSE XMLData.OldNCRNo 	END AS OldNCRNo, 
									 XMLData.NCRNo,
									XMLData.JobDate,
									XMLData.CompanyCode,
									XMLData.OccurProcessCode,
									XMLData.MaterialName,
									XMLData.CustomName,
									XMLData.standardName,
									XMLData.LotNo,
									XMLData.Qty,

									XMLData.InspectionQty,
									XMLData.BadQty,
									XMLData.PPM,
									XMLData.InQty,
									XMLData.BadLotQty,
									XMLData.DefectiveRate,
									XMLData.CreateUserID AS CreateUserID,
									XMLData.Nonconformity,
									XMLData.ImmediateAction,
									XMLData.CustomImmediateAction,									
									XMLData.IsActionCode,
									XMLData.EffectivenessCheck,
									dbo.fnBase64ToBinary(DefectImage) as DefectImage,
									dbo.fnBase64ToBinary(DefectImage2) as DefectImage2,
									GETDATE() AS CreateDateTime,

									--XMLData.dbo.fnBase64ToBinary(CustomCountermeasureImage) as CustomCountermeasureImage,
									XMLData.[FileName],
									XMLData.FileSize,
									dbo.fnBase64ToBinary(XMLData.FileData) as FileData,
									XMLData.CustomCountermeasureImage
							FROM
									OPENXML(@idoc , @DeleteTableName , 2)
							        WITH  (
											 OldNCRNo VARCHAR(20),
												NCRNo VARCHAR(20),
												JobDate DATETIMEOFFSET,
												CompanyCode VARCHAR(20),
												OccurProcessCode VARCHAR(20),
												MaterialName VARCHAR(80),
												CustomName VARCHAR(60),
												standardName VARCHAR(60),
												LotNo VARCHAR(80),
												Qty INT,
												InspectionQty INT,
												BadQty INT,
												PPM INT,
												InQty INT,
												BadLotQty INT,
												DefectiveRate NUMERIC(5,2),
												CreateUserID VARCHAR(20),
												Nonconformity NVARCHAR(4000),
												ImmediateAction NVARCHAR(4000),
												CustomImmediateAction NVARCHAR(4000),										
												IsActionCode BIT,
												EffectivenessCheck BIT,
												DefectImage NVARCHAR(MAX),
												DefectImage2 NVARCHAR(MAX),
												CreateDateTime DATETIMEOFFSET,

												--CustomCountermeasureImage NVARCHAR(MAX),
												 [FileName] NVARCHAR(255),
												 FileSize BIGINT,
												 FileData NVARCHAR(MAX),
												 CustomCountermeasureImage BIGINT
											) XMLData


            OPEN SourceData

            WHILE 1 = 1 BEGIN
                FETCH NEXT FROM SourceData INTO
									 @IUD_FLAG,
								 @OldNCRNo,
								 @NCRNo,
								 @JobDate,
								 @CompanyCode,
								 @OccurProcessCode,
								 @MaterialName,
								 @CustomName,
								 @standardName,
								 @LotNo,
								 @Qty,
								 @InspectionQty,
								 @BadQty,
								 @PPM,
								 @InQty,
								 @BadLotQty,
								 @DefectiveRate,
								 @CreateUserID,
								 @Nonconformity,
								 @ImmediateAction,
								 @CustomImmediateAction,								 
								 @IsActionCode,
								 @EffectivenessCheck,
								 @DefectImage,
								 @DefectImage2,
								 @CreateDateTime,								 
								 @FileName,
								 @FileSize,
								 @FileData,
								 @CustomCountermeasureImage
								 --@MachineImage								


                IF @@FETCH_STATUS <> 0 BEGIN
					BREAK
				END
				
                IF @IUD_FLAG = 'INSERT' BEGIN

                    IF EXISTS (SELECT 1 FROM STB_NCR_Report WHERE NCRNo = @NCRNo) 
					BEGIN
						RAISERROR('Duplicate Data : KeyField = %s', 16, 1, @NCRNo)
					END
					

                    IF @IsAutoKey = 1 BEGIN
						EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_NCR_Report', @NCRNo OUTPUT
                    END
                    
                    EXEC SmartFramework.dbo.usp_DoSaveFile 
							@pSystemName = 'STB_NCR_Report',
							@pFileContents = @FileData,
							@pFileName = @FileName,
							@pFileSize = @FileSize,
							@pUserID = @ProcessUserID,
							@pFileID = @CustomCountermeasureImage OUTPUT

                         INSERT INTO STB_NCR_Report
						(
						    NCRNo,
						    JobDate,
						    CompanyCode,
						    OccurProcessCode,
						    MaterialName,
						    CustomName,
						    standardName,
						    LotNo,
						    Qty,
						    InspectionQty,
						    BadQty,
						    PPM,
						    InQty,
						    BadLotQty,
						    DefectiveRate,
						    CreateUserID,
						    Nonconformity,
						    ImmediateAction,
						    CustomImmediateAction,
						    CustomCountermeasureImage,
						    IsActionCode,
						    EffectivenessCheck,
						    DefectImage,
						    DefectImage2,
						    CreateDateTime
						)
						VALUES
						(
						    @NCRNo,
						    @JobDate,
						    @CompanyCode,
						    @OccurProcessCode,
						    @MaterialName,
						    @CustomName,
						    @standardName,
						    @LotNo,
						    @Qty,
						    @InspectionQty,
						    @BadQty,
						    @PPM,
						    @InQty,
						    @BadLotQty,
						    @DefectiveRate,
						    @pProcessUserID,
						    @Nonconformity,
						    @ImmediateAction,
						    @CustomImmediateAction,
						    @CustomCountermeasureImage,
						    @IsActionCode,
						    @EffectivenessCheck,
						    @DefectImage,
						    @DefectImage2,
						    GETDATE()
						)

				END 
				ELSE IF @IUD_FLAG = 'UPDATE' 
				BEGIN
					
					
					EXEC SmartFramework.dbo.usp_DoSaveFile 
							@pSystemName = 'STB_NCR_Report',
							@pFileContents = @FileData,
							@pFileName = @FileName,
							@pFileSize = @FileSize,
							@pUserID = @ProcessUserID,
							@pFileID = @CustomCountermeasureImage OUTPUT
							
							--SELECT * FROM SmartFramework_File.dbo.STB_AttachedFileMaster
							--SELECT * FROM STB_MachineBasicInfo
							--UPDATE STB_MachineBasicInfo SET MachineImage = NULL
							--DECLARE @ERR VARCHAR(200) = CONVERT(VARCHAR,@MachineImage)
							--RAISERROR(@ERR ,16,1)
							--RETURN
				
                  IF EXISTS (
								SELECT
										1
								FROM
										STB_NCR_Report SNR
								WHERE
										SNR.CustomCountermeasureImage = @CustomCountermeasureImage
							) BEGIN
							
							UPDATE STB_NCR_Report
							SET
								 NCRNo =   ISNULL(@NCRNo,NCRNo),
						    JobDate =   ISNULL(@JobDate,JobDate),
						    CompanyCode =   ISNULL(@CompanyCode,CompanyCode),
						    OccurProcessCode =   ISNULL(@OccurProcessCode,OccurProcessCode),
						    MaterialName =   ISNULL(@MaterialName,MaterialName),
						    CustomName =   ISNULL(@CustomName,CustomName),
						    standardName =   ISNULL(@standardName,standardName),
						    LotNo =   ISNULL(@LotNo,LotNo),
						    Qty =   ISNULL(@Qty,Qty),
						    InspectionQty =   ISNULL(@InspectionQty,InspectionQty),
						    BadQty =   ISNULL(@BadQty,BadQty),
						    PPM =   ISNULL(@PPM,PPM),
						    InQty =   ISNULL(@InQty,InQty),
						    BadLotQty =   ISNULL(@BadLotQty,BadLotQty),
						    DefectiveRate =   ISNULL(@DefectiveRate,DefectiveRate),
						    CreateUserID =   ISNULL(@CreateUserID,CreateUserID),
						    Nonconformity =   ISNULL(@Nonconformity,Nonconformity),
						    ImmediateAction =   ISNULL(@ImmediateAction,ImmediateAction),
						    CustomImmediateAction =   ISNULL(@CustomImmediateAction,CustomImmediateAction),
						    CustomCountermeasureImage =   ISNULL(@CustomCountermeasureImage,CustomCountermeasureImage),
						    IsActionCode =   ISNULL(@IsActionCode,IsActionCode),
						    EffectivenessCheck =   ISNULL(@EffectivenessCheck,EffectivenessCheck),
						    DefectImage =   ISNULL(@DefectImage,DefectImage),
						    DefectImage2 =   ISNULL(@DefectImage2,DefectImage2),
						    CreateDateTime =   ISNULL(@CreateDateTime,CreateDateTime)
							WHERE
								 NCRNo = @OldNCRNo
					END
					ELSE BEGIN
						INSERT INTO STB_NCR_Report
						(
						     NCRNo,
						    JobDate,
						    CompanyCode,
						    OccurProcessCode,
						    MaterialName,
						    CustomName,
						    standardName,
						    LotNo,
						    Qty,
						    InspectionQty,
						    BadQty,
						    PPM,
						    InQty,
						    BadLotQty,
						    DefectiveRate,
						    CreateUserID,
						    Nonconformity,
						    ImmediateAction,
						    CustomImmediateAction,
						    CustomCountermeasureImage,
						    IsActionCode,
						    EffectivenessCheck,
						    DefectImage,
						    DefectImage2,
						    CreateDateTime
						)
						VALUES
						(
						    @NCRNo,
						    @JobDate,
						    @CompanyCode,
						    @OccurProcessCode,
						    @MaterialName,
						    @CustomName,
						    @standardName,
						    @LotNo,
						    @Qty,
						    @InspectionQty,
						    @BadQty,
						    @PPM,
						    @InQty,
						    @BadLotQty,
						    @DefectiveRate,
						    @pProcessUserID,
						    @Nonconformity,
						    @ImmediateAction,
						    @CustomImmediateAction,
						    @CustomCountermeasureImage,
						    @IsActionCode,
						    @EffectivenessCheck,
						    @DefectImage,
						    @DefectImage2,
						    GETDATE()
						)

					END
                END ELSE IF @IUD_FLAG = 'DELETE' BEGIN
					
					DELETE FROM SmartFramework_File.dbo.STB_AttachedFileMaster
					WHERE
							FileID = @CustomCountermeasureImage
					
                    DELETE FROM STB_NCR_Report
						WHERE
								 NCRNo = @OldNCRNo

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

