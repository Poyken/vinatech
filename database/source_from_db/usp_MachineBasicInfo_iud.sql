-- =============================================
-- Author: Park Jong Hoon(jhpark@awoo.co.kr)
-- Create date: 2016-05-17
-- Browsable : true
-- Group : 설비관리
-- Description:	설비기초정보 IUD
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_MachineBasicInfo_iud]
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
    DECLARE @MaxKeyField VARCHAR(20)

    -- Declare Columns Variable
	DECLARE @OldMachineCode VARCHAR(20)
	DECLARE @MachineCode VARCHAR(20)
	DECLARE @MachineManagementNo VARCHAR(30)
	DECLARE @OriginalMachineName NVARCHAR(100)
	DECLARE @MakerName NVARCHAR(100)
	DECLARE @ProductionDate DATE
	DECLARE @MachineSerialNo VARCHAR(30)
	DECLARE @BuyVendorName NVARCHAR(100)
	DECLARE @InstallDate DATE
	DECLARE @BuyPrice NVARCHAR(50)
	DECLARE @ASVendorName NVARCHAR(100)
	DECLARE @ASVendorPhone NVARCHAR(100)
	DECLARE @ASPersonName NVARCHAR(100)
	DECLARE @ASPersonPhone NVARCHAR(100)
	DECLARE @MachineExtText01 NVARCHAR(MAX)
	DECLARE @MachineExtText02 NVARCHAR(MAX)
	DECLARE @MachineExtText03 NVARCHAR(MAX)
	DECLARE @MachineExtText04 NVARCHAR(MAX)
	DECLARE @CreateDateTime DATETIME
	DECLARE @CreateUserID VARCHAR(20)
	DECLARE @ChangeDateTime DATETIME
	DECLARE @ChangeUserID VARCHAR(20)
	
	DECLARE @MachineImage BIGINT
	DECLARE @FileName NVARCHAR(255)
	DECLARE @FileSize BIGINT
	DECLARE @FileData VARBINARY(MAX)

	-- Add New Column Valiable
	DECLARE @IsIdle BIT
	DECLARE @IdleDate DATE
	DECLARE @IsDisposal BIT
	DECLARE @DisposalDate DATE
	DECLARE @IsVietnamShipment BIT
	DECLARE @VietnamShipmentDate DATE
	DECLARE @ModelSpec NVARCHAR(MAX)
	DECLARE @MachinetSize NVARCHAR(MAX)
	DECLARE @MachineWeight NVARCHAR(100)
	DECLARE @MachinePower NVARCHAR(100)
	DECLARE @VendorContact VARCHAR(50)
	DECLARE @Remark NVARCHAR(MAX)
	DECLARE @MachineStatusCode VARCHAR(20)
	DECLARE @MachineStatusChangeDate DATE
  
	
	DECLARE @iDoc INT

    EXEC SmartFramework.dbo.usp_GetSerialRule 
			@pTableName = 'STB_MachineBasicInfo',
			@pIsAutoKey = @IsAutoKey OUTPUT,
			@pIsLoopIUD = @IsLoopIUD OUTPUT,
			@pPrefixData = @PrefixString OUTPUT,
			@pSerialLen = @SerialLen OUTPUT
    
    IF @IsAutoKey = 0 AND @IsLoopIUD = 0 BEGIN
		PRINT 'Not Used MERGE'	    
    END ELSE BEGIN
        EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
        BEGIN TRY
		    DECLARE SourceData CURSOR FOR
                SELECT
                        'INSERT' AS IUD_FLAG,
									XMLData.OldMachineCode,
									XMLData.MachineCode,
									XMLData.MachineManagementNo,
									XMLData.OriginalMachineName,
									XMLData.MakerName,
									XMLData.ProductionDate,
									XMLData.MachineSerialNo,
									XMLData.BuyVendorName,
									XMLData.InstallDate,
									XMLData.BuyPrice,
									XMLData.ASVendorName,
									XMLData.ASVendorPhone,
									XMLData.ASPersonName,
									XMLData.ASPersonPhone,
									
									XMLData.[FileName],
									XMLData.FileSize,
									dbo.fnBase64ToBinary(XMLData.FileData) as FileData,
									XMLData.MachineImage,
									
									XMLData.MachineExtText01,
									XMLData.MachineExtText02,
									XMLData.MachineExtText03,
									XMLData.MachineExtText04,
									XMLData.CreateDateTime,
									XMLData.CreateUserID,
									XMLData.ChangeDateTime,
									XMLData.ChangeUserID,
									IsIdle,
									IdleDate,
									IsDisposal,
									DisposalDate,
									IsVietnamShipment,
									VietnamShipmentDate,
									MachineStatusCode,
									MachineStatusChangeDate,
									ModelSpec,
									MachinetSize,
									MachineWeight,
									MachinePower,
									VendorContact,
									Remark
							FROM
									OPENXML(@idoc , @InsertTableName , 2)
							        WITH  (
											 OldMachineCode VARCHAR(20),
											 MachineCode VARCHAR(20),
											 MachineManagementNo VARCHAR(30),
											 OriginalMachineName NVARCHAR(100),
											 MakerName NVARCHAR(100),
											 ProductionDate DATETIMEOFFSET,
											 MachineSerialNo VARCHAR(30),
											 BuyVendorName NVARCHAR(100),
											 InstallDate DATETIMEOFFSET,
											 BuyPrice NVARCHAR(50),
											 ASVendorName NVARCHAR(100),
											 ASVendorPhone NVARCHAR(100),
											 ASPersonName NVARCHAR(100),
											 ASPersonPhone NVARCHAR(100),
											 [FileName] NVARCHAR(255),
											 FileSize BIGINT,
											 FileData NVARCHAR(MAX),
											 MachineImage BIGINT,
											 MachineExtText01 NVARCHAR(MAX),
											 MachineExtText02 NVARCHAR(MAX),
											 MachineExtText03 NVARCHAR(MAX),
											 MachineExtText04 NVARCHAR(MAX),
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20),
											 IsIdle BIT,
											 IdleDate DATETIMEOFFSET,
											 IsDisposal BIT,
											 DisposalDate DATETIMEOFFSET,
											 IsVietnamShipment BIT,
											 VietnamShipmentDate DATETIMEOFFSET,
											 MachineStatusCode VARCHAR(20),
											 MachineStatusChangeDate DATE,
											 ModelSpec NVARCHAR(MAX),
											 MachinetSize NVARCHAR(MAX),
											 MachineWeight NVARCHAR(100),
											 MachinePower NVARCHAR(100),
											 VendorContact VARCHAR(50),
											 Remark NVARCHAR(MAX)
											) XMLData
							UNION ALL
							SELECT
									'UPDATE' AS IUD_FLAG,
									CASE 
										WHEN XMLData.OldMachineCode IS NULL THEN XMLData.MachineCode
										ELSE XMLData.OldMachineCode
									END AS OldMachineCode,
									XMLData.MachineCode,
									XMLData.MachineManagementNo,
									XMLData.OriginalMachineName,
									XMLData.MakerName,
									XMLData.ProductionDate,
									XMLData.MachineSerialNo,
									XMLData.BuyVendorName,
									XMLData.InstallDate,
									XMLData.BuyPrice,
									XMLData.ASVendorName,
									XMLData.ASVendorPhone,
									XMLData.ASPersonName,
									XMLData.ASPersonPhone,
									XMLData.[FileName],
									XMLData.FileSize,
									dbo.fnBase64ToBinary(XMLData.FileData) as FileData,
									XMLData.MachineImage,
									XMLData.MachineExtText01,
									XMLData.MachineExtText02,
									XMLData.MachineExtText03,
									XMLData.MachineExtText04,
									XMLData.CreateDateTime,
									XMLData.CreateUserID,
									XMLData.ChangeDateTime,
									XMLData.ChangeUserID,
									IsIdle,
									IdleDate,
									IsDisposal,
									DisposalDate,
									IsVietnamShipment,
									VietnamShipmentDate,
									MachineStatusCode,
									MachineStatusChangeDate,
									ModelSpec,
									MachinetSize,
									MachineWeight,
									MachinePower,
									VendorContact,
									Remark
							FROM
									OPENXML(@idoc , @UpdateTableName , 2)
							        WITH  (
											 OldMachineCode VARCHAR(20),
											 MachineCode VARCHAR(20),
											 MachineManagementNo VARCHAR(30),
											 OriginalMachineName NVARCHAR(100),
											 MakerName NVARCHAR(100),
											 ProductionDate DATETIMEOFFSET,
											 MachineSerialNo VARCHAR(30),
											 BuyVendorName NVARCHAR(100),
											 InstallDate DATETIMEOFFSET,
											 BuyPrice NVARCHAR(50),
											 ASVendorName NVARCHAR(100),
											 ASVendorPhone NVARCHAR(100),
											 ASPersonName NVARCHAR(100),
											 ASPersonPhone NVARCHAR(100),
											 [FileName] NVARCHAR(255),
											 FileSize BIGINT,
											 FileData NVARCHAR(MAX),
											 MachineImage BIGINT,
											 MachineExtText01 NVARCHAR(MAX),
											 MachineExtText02 NVARCHAR(MAX),
											 MachineExtText03 NVARCHAR(MAX),
											 MachineExtText04 NVARCHAR(MAX),
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20),
											 IsIdle BIT,
											 IdleDate DATETIMEOFFSET,
											 IsDisposal BIT,
											 DisposalDate DATETIMEOFFSET,
											 IsVietnamShipment BIT,
											 VietnamShipmentDate DATETIMEOFFSET,
											 MachineStatusCode VARCHAR(20),
											 MachineStatusChangeDate DATE,
											 ModelSpec NVARCHAR(MAX),
											 MachinetSize NVARCHAR(MAX),
											 MachineWeight NVARCHAR(100),
											 MachinePower NVARCHAR(100),
											 VendorContact VARCHAR(50),
											 Remark NVARCHAR(MAX)
											) XMLData
							UNION ALL
							SELECT
									'DELETE' AS IUD_FLAG,
									CASE 
										WHEN XMLData.OldMachineCode IS NULL THEN XMLData.MachineCode
										ELSE XMLData.OldMachineCode
									END AS OldMachineCode,
									XMLData.MachineCode,
									XMLData.MachineManagementNo,
									XMLData.OriginalMachineName,
									XMLData.MakerName,
									XMLData.ProductionDate,
									XMLData.MachineSerialNo,
									XMLData.BuyVendorName,
									XMLData.InstallDate,
									XMLData.BuyPrice,
									XMLData.ASVendorName,
									XMLData.ASVendorPhone,
									XMLData.ASPersonName,
									XMLData.ASPersonPhone,
									XMLData.[FileName],
									XMLData.FileSize,
									dbo.fnBase64ToBinary(XMLData.FileData) as FileData,
									XMLData.MachineImage,
									XMLData.MachineExtText01,
									XMLData.MachineExtText02,
									XMLData.MachineExtText03,
									XMLData.MachineExtText04,
									XMLData.CreateDateTime,
									XMLData.CreateUserID,
									XMLData.ChangeDateTime,
									XMLData.ChangeUserID,
									IsIdle,
									IdleDate,
									IsDisposal,
									DisposalDate,
									IsVietnamShipment,
									VietnamShipmentDate,
									MachineStatusCode,
									MachineStatusChangeDate,
									ModelSpec,
									MachinetSize,
									MachineWeight,
									MachinePower,
									VendorContact,
									Remark
							FROM
									OPENXML(@idoc , @DeleteTableName , 2)
							        WITH  (
											 OldMachineCode VARCHAR(20),
											 MachineCode VARCHAR(20),
											 MachineManagementNo VARCHAR(30),
											 OriginalMachineName NVARCHAR(100),
											 MakerName NVARCHAR(100),
											 ProductionDate DATETIMEOFFSET,
											 MachineSerialNo VARCHAR(30),
											 BuyVendorName NVARCHAR(100),
											 InstallDate DATETIMEOFFSET,
											 BuyPrice NVARCHAR(50),
											 ASVendorName NVARCHAR(100),
											 ASVendorPhone NVARCHAR(100),
											 ASPersonName NVARCHAR(100),
											 ASPersonPhone NVARCHAR(100),
											 [FileName] NVARCHAR(255),
											 FileSize BIGINT,
											 FileData NVARCHAR(MAX),
											 MachineImage BIGINT,
											 MachineExtText01 NVARCHAR(MAX),
											 MachineExtText02 NVARCHAR(MAX),
											 MachineExtText03 NVARCHAR(MAX),
											 MachineExtText04 NVARCHAR(MAX),
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20),
											 IsIdle BIT,
											 IdleDate DATETIMEOFFSET,
											 IsDisposal BIT,
											 DisposalDate DATETIMEOFFSET,
											 IsVietnamShipment BIT,
											 VietnamShipmentDate DATETIMEOFFSET,
											 MachineStatusCode VARCHAR(20),
											 MachineStatusChangeDate DATE,
											 ModelSpec NVARCHAR(MAX),
											 MachinetSize NVARCHAR(MAX),
											 MachineWeight NVARCHAR(100),
											 MachinePower NVARCHAR(100),
											 VendorContact VARCHAR(50),
											 Remark NVARCHAR(MAX)
											) XMLData


            OPEN SourceData

            WHILE 1 = 1 BEGIN
                FETCH NEXT FROM SourceData INTO
								 @IUD_FLAG,
								 @OldMachineCode,
								 @MachineCode,
								 @MachineManagementNo,
								 @OriginalMachineName,
								 @MakerName,
								 @ProductionDate,
								 @MachineSerialNo,
								 @BuyVendorName,
								 @InstallDate,
								 @BuyPrice,
								 @ASVendorName,
								 @ASVendorPhone,
								 @ASPersonName,
								 @ASPersonPhone,
								 @FileName,
								 @FileSize,
								 @FileData,
								 @MachineImage,
								 @MachineExtText01,
								 @MachineExtText02,
								 @MachineExtText03,
								 @MachineExtText04,
								 @CreateDateTime,
								 @CreateUserID,
								 @ChangeDateTime,
								 @ChangeUserID,
								 @IsIdle,
								 @IdleDate,
								 @IsDisposal,
								 @DisposalDate,
								 @IsVietnamShipment,
								 @VietnamShipmentDate,
								 @MachineStatusCode,
								 @MachineStatusChangeDate,
								 @ModelSpec,
								 @MachinetSize,
								 @MachineWeight,
								 @MachinePower,
								 @VendorContact,
								 @Remark


                IF @@FETCH_STATUS <> 0 BEGIN
					BREAK
				END
				
                IF @IUD_FLAG = 'INSERT' BEGIN

                    IF EXISTS (SELECT 1 FROM STB_MachineBasicInfo WHERE MachineCode = @MachineCode) BEGIN
						RAISERROR('Duplicate Data : KeyField = %s', 16, 1, @MachineCode)
					END
					

                    IF @IsAutoKey = 1 BEGIN
						EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_MachineBasicInfo', @MachineCode OUTPUT
                    END
                    
                    EXEC SmartFramework.dbo.usp_DoSaveFile 
							@pSystemName = 'STB_MachineBasicInfo',
							@pFileContents = @FileData,
							@pFileName = @FileName,
							@pFileSize = @FileSize,
							@pUserID = @ProcessUserID,
							@pFileID = @MachineImage OUTPUT

                    INSERT INTO STB_MachineBasicInfo
						(
						    MachineCode,
						    MachineManagementNo,
						    OriginalMachineName,
						    MakerName,
						    ProductionDate,
						    MachineSerialNo,
						    BuyVendorName,
						    InstallDate,
						    BuyPrice,
						    ASVendorName,
						    ASVendorPhone,
						    ASPersonName,
						    ASPersonPhone,
						    MachineImage,
						    MachineExtText01,
						    MachineExtText02,
						    MachineExtText03,
						    MachineExtText04,
						    CreateDateTime,
						    CreateUserID,
						    ChangeDateTime,
						    ChangeUserID,
							IsIdle,
							IdleDate,
							IsDisposal,
							DisposalDate,
							IsVietnamShipment,
							VietnamShipmentDate,
							MachineStatusCode,
							MachineStatusChangeDate,
							ModelSpec,
							MachinetSize,
							MachineWeight,
							MachinePower,
							VendorContact,
							Remark
						)
						VALUES
						(
						    @MachineCode,
						    @MachineManagementNo,
						    @OriginalMachineName,
						    @MakerName,
						    @ProductionDate,
						    @MachineSerialNo,
						    @BuyVendorName,
						    @InstallDate,
						    @BuyPrice,
						    @ASVendorName,
						    @ASVendorPhone,
						    @ASPersonName,
						    @ASPersonPhone,
						    @MachineImage,
						    @MachineExtText01,
						    @MachineExtText02,
						    @MachineExtText03,
						    @MachineExtText04,
						    GETDATE(),
						    @pProcessUserID,
						    @ChangeDateTime,
						    @ChangeUserID,
							@IsIdle,
							@IdleDate,
							@IsDisposal,
							@DisposalDate,
							@IsVietnamShipment,
							@VietnamShipmentDate,
							@MachineStatusCode,
							@MachineStatusChangeDate,
							@ModelSpec,
							@MachinetSize,
							@MachineWeight,
							@MachinePower,
							@VendorContact,
							@Remark
						)

				END 
				ELSE IF @IUD_FLAG = 'UPDATE' 
				BEGIN
					
					
					EXEC SmartFramework.dbo.usp_DoSaveFile 
							@pSystemName = 'STB_MachineBasicInfo',
							@pFileContents = @FileData,
							@pFileName = @FileName,
							@pFileSize = @FileSize,
							@pUserID = @ProcessUserID,
							@pFileID = @MachineImage OUTPUT
							
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
										STB_MachineBasicInfo MBI
								WHERE
										MBI.MachineCode = @MachineCode
							) BEGIN
							UPDATE STB_MachineBasicInfo
							SET
								MachineCode =   CASE
											WHEN @MachineCode IS NOT NULL THEN @MachineCode
											ELSE MachineCode
										END,
								MachineManagementNo =   CASE
											WHEN @MachineManagementNo IS NOT NULL THEN @MachineManagementNo
											ELSE MachineManagementNo
										END,
								OriginalMachineName =   CASE
											WHEN @OriginalMachineName IS NOT NULL THEN @OriginalMachineName
											ELSE OriginalMachineName
										END,
								MakerName =   CASE
											WHEN @MakerName IS NOT NULL THEN @MakerName
											ELSE MakerName
										END,
								ProductionDate =   CASE
											WHEN @ProductionDate IS NOT NULL THEN @ProductionDate
											ELSE NULL
										END,
								MachineSerialNo =   CASE
											WHEN @MachineSerialNo IS NOT NULL THEN @MachineSerialNo
											ELSE MachineSerialNo
										END,
								BuyVendorName =   CASE
											WHEN @BuyVendorName IS NOT NULL THEN @BuyVendorName
											ELSE BuyVendorName
										END,
								InstallDate =   CASE
											WHEN @InstallDate IS NOT NULL THEN @InstallDate
											ELSE NULL
										END,
								BuyPrice =   CASE
											WHEN @BuyPrice IS NOT NULL THEN @BuyPrice
											ELSE BuyPrice
										END,
								ASVendorName =   CASE
											WHEN @ASVendorName IS NOT NULL THEN @ASVendorName
											ELSE ASVendorName
										END,
								ASVendorPhone =   CASE
											WHEN @ASVendorPhone IS NOT NULL THEN @ASVendorPhone
											ELSE ASVendorPhone
										END,
								ASPersonName =   CASE
											WHEN @ASPersonName IS NOT NULL THEN @ASPersonName
											ELSE ASPersonName
										END,
								ASPersonPhone =   CASE
											WHEN @ASPersonPhone IS NOT NULL THEN @ASPersonPhone
											ELSE ASPersonPhone
										END,
								MachineImage = @MachineImage,
								  --CASE
										--	WHEN @MachineImage IS NOT NULL THEN @MachineImage
										--	ELSE MachineImage
										--END,
								MachineExtText01 =   CASE
											WHEN @MachineExtText01 IS NOT NULL THEN @MachineExtText01
											ELSE MachineExtText01
										END,
								MachineExtText02 =   CASE
											WHEN @MachineExtText02 IS NOT NULL THEN @MachineExtText02
											ELSE MachineExtText02
										END,
								MachineExtText03 =   CASE
											WHEN @MachineExtText03 IS NOT NULL THEN @MachineExtText03
											ELSE MachineExtText03
										END,
								MachineExtText04 =   CASE
											WHEN @MachineExtText04 IS NOT NULL THEN @MachineExtText04
											ELSE MachineExtText04
										END,
								CreateDateTime =   CASE
											WHEN @CreateDateTime IS NOT NULL THEN @CreateDateTime
											ELSE CreateDateTime
										END,
								CreateUserID =   CASE
											WHEN @CreateUserID IS NOT NULL THEN @CreateUserID
											ELSE CreateUserID
										END,
								ChangeDateTime = GETDATE(),
								ChangeUserID = @pProcessUserID,
								IsIdle = CASE WHEN @IsIdle IS NOT NULL THEN @IsIdle ELSE IsIdle END,
								IdleDate = CASE WHEN @IdleDate IS NOT NULL THEN @IdleDate ELSE NULL END,
								IsDisposal = CASE WHEN @IsDisposal IS NOT NULL THEN @IsDisposal ELSE IsDisposal END,
								DisposalDate = CASE WHEN @DisposalDate IS NOT NULL THEN @DisposalDate ELSE NULL END,
								IsVietnamShipment = CASE WHEN @IsVietnamShipment IS NOT NULL THEN @IsVietnamShipment ELSE IsVietnamShipment END,
								VietnamShipmentDate = CASE WHEN @VietnamShipmentDate IS NOT NULL THEN @VietnamShipmentDate ELSE NULL END,
								MachineStatusCode = CASE WHEN @MachineStatusCode IS NOT NULL THEN @MachineStatusCode ELSE MachineStatusCode END,
								MachineStatusChangeDate = CASE WHEN @MachineStatusChangeDate IS NOT NULL THEN @MachineStatusChangeDate ELSE NULL END,
								ModelSpec = CASE WHEN @ModelSpec IS NOT NULL THEN @ModelSpec ELSE ModelSpec END,
								MachinetSize = CASE WHEN @MachinetSize IS NOT NULL THEN @MachinetSize ELSE MachinetSize END,
								MachineWeight = CASE WHEN @MachineWeight IS NOT NULL THEN @MachineWeight ELSE MachineWeight END,
								MachinePower = CASE WHEN @MachinePower IS NOT NULL THEN @MachinePower ELSE MachinePower END,
								VendorContact = CASE WHEN VendorContact IS NOT NULL THEN @VendorContact ELSE VendorContact END,
								Remark = CASE WHEN @Remark IS NOT NULL THEN @Remark ELSE Remark END

							WHERE
								MachineCode = @OldMachineCode
					END
					ELSE BEGIN
						INSERT INTO STB_MachineBasicInfo
						(
						    MachineCode,
						    MachineManagementNo,
						    OriginalMachineName,
						    MakerName,
						    ProductionDate,
						    MachineSerialNo,
						    BuyVendorName,
						    InstallDate,
						    BuyPrice,
						    ASVendorName,
						    ASVendorPhone,
						    ASPersonName,
						    ASPersonPhone,
						    MachineImage,
						    MachineExtText01,
						    MachineExtText02,
						    MachineExtText03,
						    MachineExtText04,
						    CreateDateTime,
						    CreateUserID,
						    ChangeDateTime,
						    ChangeUserID,
							IsIdle,
							IdleDate,
							IsDisposal,
							DisposalDate,
							IsVietnamShipment,
							VietnamShipmentDate,
							MachineStatusCode,
							MachineStatusChangeDate,
							ModelSpec,
							MachinetSize,
							MachineWeight,
							MachinePower,
							VendorContact,
							Remark
						)
						VALUES
						(
						    @MachineCode,
						    @MachineManagementNo,
						    @OriginalMachineName,
						    @MakerName,
						    @ProductionDate,
						    @MachineSerialNo,
						    @BuyVendorName,
						    @InstallDate,
						    @BuyPrice,
						    @ASVendorName,
						    @ASVendorPhone,
						    @ASPersonName,
						    @ASPersonPhone,
						    @MachineImage,
						    @MachineExtText01,
						    @MachineExtText02,
						    @MachineExtText03,
						    @MachineExtText04,
						    GETDATE(),
						    @pProcessUserID,
						    @ChangeDateTime,
						    @ChangeUserID,
							@IsIdle,
							@IdleDate,
							@IsDisposal,
							@DisposalDate,
							@IsVietnamShipment,
							@VietnamShipmentDate,
							@MachineStatusCode,
							@MachineStatusChangeDate,
							@ModelSpec,
							@MachinetSize,
							@MachineWeight,
							@MachinePower,
							@VendorContact,
							@Remark
						)

					END
                END ELSE IF @IUD_FLAG = 'DELETE' BEGIN
					
					DELETE FROM SmartFramework_File.dbo.STB_AttachedFileMaster
					WHERE
							FileID = @MachineImage
					
                    DELETE FROM STB_MachineBasicInfo
						WHERE
						    MachineCode = @MachineCode
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

