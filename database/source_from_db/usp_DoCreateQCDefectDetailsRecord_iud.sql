-- =============================================
-- Author:		Mr.Manh
-- Create date: 2026-03-31
-- Description:	Create QC Defect Details
-- =============================================
CREATE PROCEDURE [dbo].[usp_DoCreateQCDefectDetailsRecord_iud]
	-- Add the parameters for the stored procedure here
						@pProcessUserID VARCHAR(20),
						@pProcessLanguage VARCHAR(20),
						@pProcessViewName VARCHAR(50),
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
	DECLARE @Barcode VARCHAR(30)
    DECLARE @ControlNo VARCHAR(30)
    DECLARE @InspectionDate DATE
    DECLARE @InspectionQty INT
    DECLARE @DefectQty INT
	DECLARE @DefectDivisionCode VARCHAR(20)
    DECLARE @DefectCode VARCHAR(20)
    DECLARE @InspWorkerCode VARCHAR(10)
    DECLARE @DefectImage VARBINARY(MAX)
    DECLARE @DefectImageUrl VARCHAR(500)
    DECLARE @ProdProcessResultFile BIGINT
	DECLARE @Cause NVARCHAR(MAX)
	DECLARE @Countermeasure NVARCHAR(MAX)
	DECLARE @FollowUp NVARCHAR(MAX)
    DECLARE @Note NVARCHAR(MAX)
    DECLARE @CreateDateTime DATETIME
    DECLARE @CreateUserID VARCHAR(20)
    DECLARE @ChangeDateTime DATETIME
    DECLARE @ChangeUserID VARCHAR(20)

      --FileUpload 관련 변수 추가 
     DECLARE @FileName NVARCHAR(255)
     DECLARE @FileSize BIGINT
     DECLARE @FileData VARBINARY(MAX)  

      DECLARE @iDoc INT

  --외관검사자코드 추가 2022.02.07 이미정 차장 요청 by Jackaroe
  Declare @VisualInspWorkerCode VARCHAR(20)

   -- EXEC SmartFramework.dbo.usp_GetSerialRule 
			--@pTableName = 'STB_QCDefectDetailsRecord',
			--@pIsAutoKey = @IsAutoKey OUTPUT,
			--@pIsLoopIUD = @IsLoopIUD OUTPUT,
			--@pPrefixData = @PrefixString OUTPUT,
			--@pSerialLen = @SerialLen OUTPUT
    

        EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
        BEGIN TRY
		    DECLARE SourceData CURSOR FOR
                SELECT
                        'INSERT' AS IUD_FLAG,
									Barcode,
									ControlNo,
									InspectionDate,
									InspectionQty,
									DefectQty,
									DefectDivisionCode,
									DefectCode,
									InspWorkerCode,
									dbo.fnBase64ToBinary(DefectImage) AS DefectImage,
									DefectImageUrl,
									--ProdProcessResultFile,
									Cause,
									Countermeasure,
									FollowUp,
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
							        WITH  (

											Barcode VARCHAR(30),
											ControlNo VARCHAR(30),
											InspectionDate DATE,
											InspectionQty INT,
											DefectQty INT,
											DefectDivisionCode VARCHAR(20),
											DefectCode VARCHAR(20),
											InspWorkerCode VARCHAR(10),
											DefectImage NVARCHAR(MAX),
											DefectImageUrl VARCHAR(500),
											--ProdProcessResultFile BIGINT,
											Cause NVARCHAR(MAX),
											Countermeasure NVARCHAR(MAX),
											FollowUp NVARCHAR(MAX),
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
									Barcode,
									ControlNo,
									InspectionDate,
									InspectionQty,
									DefectQty,
									DefectDivisionCode,
									DefectCode,
									InspWorkerCode,
									dbo.fnBase64ToBinary(DefectImage) AS DefectImage,
									DefectImageUrl,
									--ProdProcessResultFile,
									Cause,
									Countermeasure,
									FollowUp,
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
							        WITH  (
											Barcode VARCHAR(30),
											ControlNo VARCHAR(30),
											InspectionDate DATE,
											InspectionQty INT,
											DefectQty INT,
											DefectDivisionCode VARCHAR(20),
											DefectCode VARCHAR(20),
											InspWorkerCode VARCHAR(10),
											DefectImage NVARCHAR(MAX),
											DefectImageUrl VARCHAR(500),
											--ProdProcessResultFile BIGINT,
											Cause NVARCHAR(MAX),
											Countermeasure NVARCHAR(MAX),
											FollowUp NVARCHAR(MAX),
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
									Barcode,
									ControlNo,
									InspectionDate,
									InspectionQty,
									DefectQty,
									DefectDivisionCode,
									DefectCode,
									InspWorkerCode,
									dbo.fnBase64ToBinary(DefectImage) AS DefectImage,
									DefectImageUrl,
									--ProdProcessResultFile,
									Cause,
									Countermeasure,
									FollowUp,
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
							        WITH  (
											Barcode VARCHAR(30),
											ControlNo VARCHAR(30),
											InspectionDate DATE,
											InspectionQty INT,
											DefectQty INT,
											DefectDivisionCode VARCHAR(20),
											DefectCode VARCHAR(20),
											InspWorkerCode VARCHAR(10),
											DefectImage NVARCHAR(MAX),
											DefectImageUrl VARCHAR(500),
											--ProdProcessResultFile BIGINT,
											Cause NVARCHAR(MAX),
											Countermeasure NVARCHAR(MAX),
											FollowUp NVARCHAR(MAX),
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
								@Barcode,
								@ControlNo,
								@InspectionDate,
								@InspectionQty,
								@DefectQty,
								@DefectDivisionCode,
								@DefectCode,
								@InspWorkerCode,
								@DefectImage,
								@DefectImageUrl,
								--@ProdProcessResultFile,
								@Cause,
								@Countermeasure,
								@FollowUp,
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


                IF @IUD_FLAG = 'INSERT' 
					BEGIN

                    IF EXISTS (SELECT 1 FROM STB_QCDefectDetailsRecord WHERE Barcode = @Barcode) BEGIN
						RAISERROR('Duplicate Data : KeyField = %s', 16, 1, @Barcode)
					END

      --              IF @IsAutoKey = 1 
						--BEGIN
						--	EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_QCDefectDetailsRecord',@QC4MNo OUTPUT
						--	SET @QC4MNo = 'VN' + @QC4MNo
						--END
                    
					IF @InspectionQty <= 0
					BEGIN
						RAISERROR(N'Số lượng kiểm tra phải lớn hơn 0', 16, 1)
						RETURN
					END

					IF @DefectQty > @InspectionQty
					BEGIN
						RAISERROR(N'Số lượng lỗi phải nhỏ hơn hoặc bằng số lượng kiểm tra', 16, 1)
						RETURN
					END

					EXEC SmartFramework.dbo.usp_DoSaveFile 
							@pSystemName = 'STB_QCDefectDetailsRecord',
							@pFileContents = @FileData,
							@pFileName = @FileName,
							@pFileSize = @FileSize,
							@pUserID = @ProcessUserID,
							@pFileID = @ProdProcessResultFile OUTPUT

                    INSERT INTO STB_QCDefectDetailsRecord
						(
							Barcode,
							ControlNo,
							InspectionDate,
							InspectionQty,
							DefectQty,
							DefectDivisionCode,
							DefectCode,
							InspWorkerCode,
							DefectImage,
							DefectImageUrl,
							ProdProcessResultFile,
							Cause,
							Countermeasure,
							FollowUp,
							Note,
							CreateDateTime,
							CreateUserID,
							ChangeDateTime,
							ChangeUserID
						)
						VALUES
						(
						    @Barcode,
							@ControlNo,
							@InspectionDate,
							@InspectionQty,
							@DefectQty,
							@DefectDivisionCode,
							@DefectCode,
							@InspWorkerCode,
							@DefectImage,
							@DefectImageUrl,
							@ProdProcessResultFile,
							@Cause,
							@Countermeasure,
							@FollowUp,
							@Note,
						    GETDATE(),
						    @pProcessUserID,
						    @ChangeDateTime,
						    @ChangeUserID
						    
						)

				END 
				ELSE IF @IUD_FLAG = 'UPDATE' BEGIN
					

					--IF EXISTS (SELECT 1 FROM STB_QCDefectDetailsRecord WHERE Barcode = @Barcode)
					--BEGIN
					--	RAISERROR(N'Lot %s đã được tạo, vui lòng kiểm tra lại', 16, 1, @Barcode)
					--	RETURN
					--END



					IF @InspectionQty <= 0
					BEGIN
						RAISERROR(N'Số lượng kiểm tra phải lớn hơn 0', 16, 1)
						RETURN
					END

					IF @DefectQty > @InspectionQty
					BEGIN
						RAISERROR(N'Số lượng lỗi phải nhỏ hơn hoặc bằng số lượng kiểm tra', 16, 1)
						RETURN
					END

					EXEC SmartFramework.dbo.usp_DoSaveFile 
							@pSystemName = 'STB_QCDefectDetailsRecord',
							@pFileContents = @FileData,
							@pFileName = @FileName,
							@pFileSize = @FileSize,
							@pUserID = @ProcessUserID,
							@pFileID = @ProdProcessResultFile OUTPUT

					-- 보고서번호가 존재하면 UPDATE
					IF EXISTS (SELECT 1 FROM STB_QCDefectDetailsRecord WHERE Barcode = @Barcode) BEGIN


						RAISERROR(N'Lot %s đã được tạo, vui lòng kiểm tra lại', 16, 1, @Barcode)
						RETURN

						--UPDATE STB_QCDefectDetailsRecord
						--SET
						--    Barcode = ISNULL(@Barcode, Barcode),
						--	ControlNo = ISNULL(@ControlNo, ControlNo),
						--	InspectionDate = ISNULL(@InspectionDate, InspectionDate),
						--	InspectionQty = ISNULL(@InspectionQty,InspectionQty),
						--	DefectQty = ISNULL(@DefectQty, DefectQty),
						--	DefectDivisionCode = ISNULL(@DefectDivisionCode, DefectDivisionCode),
						--	DefectCode = ISNULL(@DefectCode, DefectCode),
						--	InspWorkerCode = ISNULL(@InspWorkerCode, InspWorkerCode),
						--	DefectImage = ISNULL(@DefectImage, DefectImage),
						--	DefectImageUrl = ISNULL(@DefectImageUrl,DefectImageUrl),
						--	ProdProcessResultFile = ISNULL(@ProdProcessResultFile,ProdProcessResultFile),
						--	Note = ISNULL(@Note,Note),
						--    ChangeDateTime = GETDATE(),
						--    ChangeUserID = @pProcessUserID
						    
							
						--WHERE
						--    Barcode = @Barcode



					END ELSE BEGIN -- 그렇지 않으면 Insert


						--IF @IsAutoKey = 1 
						--	BEGIN
						--		EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_QCDefectDetailsRecord',@QC4MNo OUTPUT
						--		SET @QC4MNo = 'VN' + @QC4MNo
						--	END
                        

					 IF EXISTS (SELECT 1 FROM STB_QCDefectDetailsRecord WHERE Barcode = @Barcode) 
					 BEGIN
						EXEC usp_RaiseLocalizedError @pProcessLanguage, N'Đã có LotNo này trên hệ thống. Vui lòng kiểm tra lại'
						RETURN
					 END
						
						IF @InspectionQty <= 0
					BEGIN
						RAISERROR(N'Số lượng kiểm tra phải lớn hơn 0', 16, 1)
						RETURN
					END

					IF @DefectQty > @InspectionQty
					BEGIN
						RAISERROR(N'Số lượng lỗi phải nhỏ hơn hoặc bằng số lượng kiểm tra', 16, 1)
						RETURN
					END

						INSERT INTO STB_QCDefectDetailsRecord
						(
							Barcode,
							ControlNo,
							InspectionDate,
							InspectionQty,
							DefectQty,
							DefectDivisionCode,
							DefectCode,
							InspWorkerCode,
							DefectImage,
							DefectImageUrl,
							ProdProcessResultFile,
							Cause,
							Countermeasure,
							FollowUp,
							Note,
							CreateDateTime,
							CreateUserID,
							ChangeDateTime,
							ChangeUserID
						)
						VALUES
						(
						    @Barcode,
							@ControlNo,
							@InspectionDate,
							@InspectionQty,
							@DefectQty,
							@DefectDivisionCode,
							@DefectCode,
							@InspWorkerCode,
							@DefectImage,
							@DefectImageUrl,
							@ProdProcessResultFile,
							@Cause,
							@Countermeasure,
							@FollowUp,
							@Note,
						    GETDATE(),
						    @pProcessUserID,
						    @ChangeDateTime,
						    @ChangeUserID
						    
						)

					END

                    
                END ELSE IF @IUD_FLAG = 'DELETE' BEGIN
					DELETE FROM STB_QCDefectDetailsRecord
						WHERE
						    Barcode = @Barcode
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
