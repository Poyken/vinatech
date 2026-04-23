-- =============================================
-- Author:		Mr.Manh
-- Create date: 2026-02-24
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[usp_getMeasurementControlListVVT_calibrate]
	-- Add the parameters for the stored procedure here
		@pProcessUserID VARCHAR(20),
		@pProcessLanguage VARCHAR(20),
		@pProcessViewName VARCHAR(50) = null,
		@pXml NVARCHAR(MAX) = null
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
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
        DECLARE @SerialNo VARCHAR(50) 
    DECLARE @MeasurementNameE NVARCHAR(100)
    DECLARE @MeasurementNameV NVARCHAR(100)
    DECLARE @ModelName NVARCHAR(100)
    DECLARE @Maker NVARCHAR(100)
    DECLARE @Specification NVARCHAR(100)
    DECLARE @ManagementNo VARCHAR(50)
	DECLARE @Status NVARCHAR(30)      
    DECLARE @SetLocation NVARCHAR(100)
    DECLARE @Department VARCHAR(50)
    DECLARE @WorkCenterCode VARCHAR(10)
    DECLARE @PIC NVARCHAR(50)
    DECLARE @DayOfCalibration DATE
    --DECLARE @ExpiredDate DATE
    DECLARE @TypeOfCalibration NVARCHAR(50)
    DECLARE @CertificateNo NVARCHAR(50)
    DECLARE @CertificationBody NVARCHAR(50)
    DECLARE @Remark NVARCHAR(100)
    DECLARE @Note NVARCHAR(MAX)
	DECLARE @CreateDateTime DATETIME
	DECLARE @CreateUserID VARCHAR(20)
	DECLARE @ChangeDateTime DATETIME
	DECLARE @ChangeUserID VARCHAR(20)

	DECLARE @ProdProcessResultFile BIGINT
	      --FileUpload 관련 변수 추가 
    DECLARE @FileName NVARCHAR(255)
    DECLARE @FileSize BIGINT
    DECLARE @FileData VARBINARY(MAX)  

	DECLARE @iDoc INT



	EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
        BEGIN TRY
		    DECLARE SourceData CURSOR FOR
				SELECT
					'INSERT' AS IUD_FLAG,
							SerialNo,
							MeasurementNameE,
							MeasurementNameV,
							ModelName,
							Maker,
							Specification,
							ManagementNo,
							[Status],
							SetLocation,
							Department,
							WorkCenterCode,
							PIC,
							DayOfCalibration,
							--ExpiredDate,
							TypeOfCalibration,
							CertificateNo,
							CertificationBody,
							Remark,
							Note,
							CreateDateTime,
							CreateUserID,
							ChangeDateTime,
							ChangeUserID,
							ProdProcessResultFile,
							[FileName],
							FileSize,
							dbo.fnBase64ToBinary(FileData)

					FROM
							OPENXML(@idoc , @InsertTableName , 2)
							WITH	(
										--ID INT,
										SerialNo VARCHAR(50), 
										MeasurementNameE NVARCHAR(100),
										MeasurementNameV NVARCHAR(100),
										ModelName NVARCHAR(100),
										Maker NVARCHAR(100),
										Specification NVARCHAR(100),
										ManagementNo VARCHAR(50),
										[Status] NVARCHAR(30),
										SetLocation NVARCHAR(100),
										Department VARCHAR(50),
										WorkCenterCode VARCHAR(10),
										PIC NVARCHAR(50),
										DayOfCalibration DATE,
										--ExpiredDate DATE,
										TypeOfCalibration NVARCHAR(50),
										CertificateNo NVARCHAR(50),
										CertificationBody NVARCHAR(50),
										Remark NVARCHAR(100),
										Note NVARCHAR(MAX),
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20),
										ProdProcessResultFile BIGINT,
										[FileName] NVARCHAR(255),
										FileSize BIGINT,
										FileData NVARCHAR(MAX)

									)
					UNION ALL
					SELECT
							'UPDATE' AS IUD_FLAG,
							SerialNo,
							MeasurementNameE,
							MeasurementNameV,
							ModelName,
							Maker,
							Specification,
							ManagementNo,
							[Status],
							SetLocation,
							Department,
							WorkCenterCode,
							PIC,
							DayOfCalibration,
							--ExpiredDate,
							TypeOfCalibration,
							CertificateNo,
							CertificationBody,
							Remark,
							Note,
							CreateDateTime,
							CreateUserID,
							ChangeDateTime,
							ChangeUserID,
							ProdProcessResultFile,
							[FileName],
							FileSize,
							dbo.fnBase64ToBinary(FileData)
					FROM
							OPENXML(@idoc , @UpdateTableName , 2)
							WITH	(
										SerialNo VARCHAR(50), 
										MeasurementNameE NVARCHAR(100),
										MeasurementNameV NVARCHAR(100),
										ModelName NVARCHAR(100),
										Maker NVARCHAR(100),
										Specification NVARCHAR(100),
										ManagementNo VARCHAR(50),
										[Status] NVARCHAR(30),
										SetLocation NVARCHAR(100),
										Department VARCHAR(50),
										WorkCenterCode VARCHAR(10),
										PIC NVARCHAR(50),
										DayOfCalibration DATE,
										--ExpiredDate DATE,
										TypeOfCalibration NVARCHAR(50),
										CertificateNo NVARCHAR(50),
										CertificationBody NVARCHAR(50),
										Remark NVARCHAR(100),
										Note NVARCHAR(MAX),
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20),
										ProdProcessResultFile BIGINT,
										[FileName] NVARCHAR(255),
										FileSize BIGINT,
										FileData NVARCHAR(MAX)
									)
					UNION ALL
					SELECT
							'DELETE' AS IUD_FLAG,
							SerialNo,
							MeasurementNameE,
							MeasurementNameV,
							ModelName,
							Maker,
							Specification,
							ManagementNo,
							[Status],
							SetLocation,
							Department,
							WorkCenterCode,
							PIC,
							DayOfCalibration,
							--ExpiredDate,
							TypeOfCalibration,
							CertificateNo,
							CertificationBody,
							Remark,
							Note,
							CreateDateTime,
							CreateUserID,
							ChangeDateTime,
							ChangeUserID,
							ProdProcessResultFile,
							[FileName],
							FileSize,
							dbo.fnBase64ToBinary(FileData)
					FROM
							OPENXML(@idoc , @DeleteTableName , 2)
							WITH	(
										SerialNo VARCHAR(50), 
										MeasurementNameE NVARCHAR(100),
										MeasurementNameV NVARCHAR(100),
										ModelName NVARCHAR(100),
										Maker NVARCHAR(100),
										Specification NVARCHAR(100),
										ManagementNo VARCHAR(50),
										[Status] NVARCHAR(30),
										SetLocation NVARCHAR(100),
										Department VARCHAR(50),
										WorkCenterCode VARCHAR(10),
										PIC NVARCHAR(50),
										DayOfCalibration DATE,
										--ExpiredDate DATE,
										TypeOfCalibration NVARCHAR(50),
										CertificateNo NVARCHAR(50),
										CertificationBody NVARCHAR(50),
										Remark NVARCHAR(100),
										Note NVARCHAR(MAX),
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20),
										ProdProcessResultFile BIGINT,
										[FileName] NVARCHAR(255),
										FileSize BIGINT,
										FileData NVARCHAR(MAX)
									)

			OPEN SourceData

			WHILE 1 = 1 BEGIN
				FETCH NEXT FROM SourceData INTO
								@IUD_FLAG,
								@SerialNo,
								@MeasurementNameE,
								@MeasurementNameV,
								@ModelName,
								@Maker,
								@Specification,
								@ManagementNo,
								@Status,
								@SetLocation,
								@Department,
								@WorkCenterCode,
								@PIC,
								@DayOfCalibration,
								--@ExpiredDate,
								@TypeOfCalibration,
								@CertificateNo,
								@CertificationBody,
								@Remark,
								@Note,
								@CreateDateTime,
								@CreateUserID,
								@ChangeDateTime,
								@ChangeUserID,
								@ProdProcessResultFile,
								@FileName,
								@FileSize,
								@FileData
			
				
				IF @@FETCH_STATUS <> 0 BEGIN
					BREAK
				END
				IF @IUD_FLAG = 'INSERT' BEGIN
					
					RAISERROR('INSERT HELLO', 16, 1)
					RETURN


				END ELSE IF @IUD_FLAG = 'UPDATE' BEGIN

					IF @pProcessUserID NOT IN ('62303001', '62505009', 'DinhManh')
						BEGIN
							RAISERROR( N'Bạn không có quyền chỉnh sửa!' ,16, 1)
							RETURN
						END



						EXEC SmartFramework.dbo.usp_DoSaveFile 
							@pSystemName = 'STB_MeasurementControlList_VVT',
							@pFileContents = @FileData,
							@pFileName = @FileName,
							@pFileSize = @FileSize,
							@pUserID = @ProcessUserID,
							@pFileID = @ProdProcessResultFile OUTPUT


							-- Lưu vào bảng lịch sử
							INSERT INTO STB_MeasurementControlCalibrateHistory_VVT
								(
									ManagementNo,
									SerialNo,
									DayOfCalibration,
									Remark,
									Note,
									CreateDateTime,
									CreateUserID
								)
								VALUES
								(
									@ManagementNo,
									@SerialNo,
									@DayOfCalibration,
									@Remark,
									@Note,
									GETDATE(),
									@pProcessUserID
								)


					-- Chỉnh ngày hiệu chỉnh và hết hạn
				UPDATE STB_MeasurementControlList_VVT
					SET
						--SerialNo = ISNULL(@SerialNo, SerialNo),
						--MeasurementNameE = ISNULL(@MeasurementNameE, MeasurementNameE),
						--MeasurementNameV = ISNULL(@MeasurementNameV, MeasurementNameV),
						--ModelName = ISNULL(@ModelName, ModelName),
						--Maker = ISNULL(@Maker, Maker),
						--Specification = ISNULL(@Specification, Specification),
						--ManagementNo = ISNULL(@ManagementNo, ManagementNo),
						--[Status] = ISNULL(@Status, [Status]),
						--SetLocation = ISNULL(@SetLocation, SetLocation),
						--Department = ISNULL(@Department, Department),
						--WorkCenterCode = ISNULL(@WorkCenterCode, WorkCenterCode),
						--PIC = ISNULL(@PIC, PIC),
						DayOfCalibration = ISNULL(@DayOfCalibration, DayOfCalibration),
						ProdProcessResultFile = ISNULL(@ProdProcessResultFile,ProdProcessResultFile),
						--TypeOfCalibration = ISNULL(@TypeOfCalibration, TypeOfCalibration),
						--CertificateNo = ISNULL(@CertificateNo, CertificateNo),
						--CertificationBody = ISNULL(@CertificationBody, CertificationBody),
						Remark = ISNULL(@Remark, Remark),
						Note = ISNULL(@Note, Note),
						--CreateDateTime = ISNULL(@CreateDateTime, CreateDateTime),
						--CreateUserID = ISNULL(@CreateUserID, CreateUserID),
						ChangeDateTime = GETDATE(),
						ChangeUserID = @pProcessUserID

					WHERE
						SerialNo = @SerialNo AND
						ManagementNo = @ManagementNo

							
				END ELSE IF @IUD_FLAG = 'DELETE' BEGIN

					RAISERROR('DELETE HELLO', 16, 1)
					RETURN

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
