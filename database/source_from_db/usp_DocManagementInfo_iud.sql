
-- =============================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Create date: 2019-10-08
-- Browsable : true
-- Group : 기록물관리
-- Description:	
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_DocManagementInfo_iud]
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
  DECLARE @OldDocManagementCode VARCHAR(20)
  DECLARE @DocManagementCode VARCHAR(20)
  DECLARE @FactoryCode VARCHAR(10)
  DECLARE @ProcessCode VARCHAR(10)
  DECLARE @ProductCode VARCHAR(10)
  DECLARE @ContentsCode VARCHAR(10)
  DECLARE @DocFileName NVARCHAR(200)
  DECLARE @DocSummaryContents NVARCHAR(4000)
  DECLARE @CreateDateTime DATETIME
  DECLARE @CreateUserID VARCHAR(20)
  DECLARE @ChangeDateTime DATETIME
  DECLARE @ChangeUserID VARCHAR(20)
  DECLARE @DocCreateWorkerCode VARCHAR(20)

  --UPDATE 제어용
  Declare @OldFactoryCode VARCHAR(20)
         ,@OldProcessCode VARCHAR(20)
		 ,@OldProductCode VARCHAR(20)
		 ,@OldContentsCode VARCHAR(20)
		 ,@ErrorMessage NVARCHAR(MAX)


	DECLARE @iDoc INT

    EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
    BEGIN TRY
		DECLARE SourceData CURSOR FOR
            SELECT
                    'INSERT' AS IUD_FLAG,
								OldDocManagementCode,
								DocManagementCode,
								FactoryCode,
								ProcessCode,
								ProductCode,
								ContentsCode,
								DocFileName,
								DocSummaryContents,
								CreateDateTime,
								CreateUserID,
								ChangeDateTime,
								ChangeUserID,
								DocCreateWorkerCode
						FROM
								OPENXML(@idoc , @InsertTableName , 2)
							    WITH  (
											OldDocManagementCode VARCHAR(20),
											DocManagementCode VARCHAR(20),
											FactoryCode VARCHAR(10),
											ProcessCode VARCHAR(10),
											ProductCode VARCHAR(10),
											ContentsCode VARCHAR(10),
											DocFileName NVARCHAR(200),
											DocSummaryContents NVARCHAR(4000),
											CreateDateTime DATETIMEOFFSET,
											CreateUserID VARCHAR(20),
											ChangeDateTime DATETIMEOFFSET,
											ChangeUserID VARCHAR(20),
											DocCreateWorkerCode VARCHAR(20)
										)
						UNION ALL
						SELECT
								'UPDATE' AS IUD_FLAG,
								CASE 
									WHEN OldDocManagementCode IS NULL THEN DocManagementCode
									ELSE OldDocManagementCode
								END AS OldDocManagementCode,
								DocManagementCode,
								FactoryCode,
								ProcessCode,
								ProductCode,
								ContentsCode,
								DocFileName,
								DocSummaryContents,
								CreateDateTime,
								CreateUserID,
								ChangeDateTime,
								ChangeUserID,
								DocCreateWorkerCode
						FROM
								OPENXML(@idoc , @UpdateTableName , 2)
							    WITH  (
											OldDocManagementCode VARCHAR(20),
											DocManagementCode VARCHAR(20),
											FactoryCode VARCHAR(10),
											ProcessCode VARCHAR(10),
											ProductCode VARCHAR(10),
											ContentsCode VARCHAR(10),
											DocFileName NVARCHAR(200),
											DocSummaryContents NVARCHAR(4000),
											CreateDateTime DATETIMEOFFSET,
											CreateUserID VARCHAR(20),
											ChangeDateTime DATETIMEOFFSET,
											ChangeUserID VARCHAR(20),
											DocCreateWorkerCode VARCHAR(20)
										)
						UNION ALL
						SELECT
								'DELETE' AS IUD_FLAG,
								CASE 
									WHEN OldDocManagementCode IS NULL THEN DocManagementCode
									ELSE OldDocManagementCode
								END AS OldDocManagementCode,
								DocManagementCode,
								FactoryCode,
								ProcessCode,
								ProductCode,
								ContentsCode,
								DocFileName,
								DocSummaryContents,
								CreateDateTime,
								CreateUserID,
								ChangeDateTime,
								ChangeUserID,
								DocCreateWorkerCode
						FROM
								OPENXML(@idoc , @DeleteTableName , 2)
							    WITH  (
											OldDocManagementCode VARCHAR(20),
											DocManagementCode VARCHAR(20),
											FactoryCode VARCHAR(10),
											ProcessCode VARCHAR(10),
											ProductCode VARCHAR(10),
											ContentsCode VARCHAR(10),
											DocFileName NVARCHAR(200),
											DocSummaryContents NVARCHAR(4000),
											CreateDateTime DATETIMEOFFSET,
											CreateUserID VARCHAR(20),
											ChangeDateTime DATETIMEOFFSET,
											ChangeUserID VARCHAR(20),
											DocCreateWorkerCode VARCHAR(20)
										) 


        OPEN SourceData

        WHILE 1 = 1 BEGIN
            FETCH NEXT FROM SourceData INTO
								@IUD_FLAG,
								@OldDocManagementCode,
								@DocManagementCode,
								@FactoryCode,
								@ProcessCode,
								@ProductCode,
								@ContentsCode,
								@DocFileName,
								@DocSummaryContents,
								@CreateDateTime,
								@CreateUserID,
								@ChangeDateTime,
								@ChangeUserID,
								@DocCreateWorkerCode


            IF @@FETCH_STATUS <> 0 BEGIN
				BREAK
			END
            IF @IUD_FLAG = 'INSERT' BEGIN
				SELECT TOP 1 @DocManagementCode = DocManagementCode
				  FROM STB_DocManagementInfo
				 WHERE FactoryCode = @FactoryCode
				   AND ProcessCode = @ProcessCode
				   AND ProductCode = @ProductCode
				   AND ContentsCode = @ContentsCode
				 ORDER BY DocManagementCode DESC

				IF @DocManagementCode IS NULL BEGIN
					SET @DocManagementCode = @FactoryCode+@ProcessCode+@ProductCode+@ContentsCode+'-001'
				END ELSE BEGIN 
					SET @DocManagementCode = @FactoryCode+@ProcessCode+@ProductCode+@ContentsCode
							+ '-' + RIGHT('000'+CONVERT(VARCHAR(10), CONVERT(INT, RIGHT(@DocManagementCode, 3)) + 1), 3)
				END
                

                INSERT INTO STB_DocManagementInfo
					(
						DocManagementCode,
						FactoryCode,
						ProcessCode,
						ProductCode,
						ContentsCode,
						DocFileName,
						DocSummaryContents,
						CreateDateTime,
						CreateUserID,
						ChangeDateTime,
						ChangeUserID,
						DocCreateWorkerCode
					)
					VALUES
					(
						@DocManagementCode,
						@FactoryCode,
						@ProcessCode,
						@ProductCode,
						@ContentsCode,
						@DocFileName,
						@DocSummaryContents,
						GETDATE(),
						@pProcessUserID,
						@ChangeDateTime,
						@ChangeUserID,
						@DocCreateWorkerCode
					)

			END ELSE IF @IUD_FLAG = 'UPDATE' BEGIN
                SELECT @OldFactoryCode = FactoryCode
				      ,@OldProcessCode = ProcessCode
					  ,@OldProductCode = ProductCode
					  ,@OldContentsCode = ContentsCode
				  FROM STB_DocManagementInfo
				 WHERE DocManagementCode = @OldDocManagementCode
				
				IF  @OldFactoryCode <> @FactoryCode
				    OR @OldProcessCode <> @ProcessCode
					OR @OldProductCode <> @ProductCode
					OR @OldContentsCode <> @ContentsCode
				BEGIN
					EXEC SmartFramework.dbo.usp_GetAddonStringResource	@pProcessLanguage,
																					'^변경될 경우 기록물번호에 영향이 있는 정보가 포함되어 있습니다. 삭제 후 재생성하세요.^',
																					@ErrorMessage OUTPUT
					SET @ErrorMessage = @ErrorMessage + ' [%s]'
					RAISERROR(@ErrorMessage,16,1,@OldDocManagementCode)

					RETURN
				END
				
				UPDATE STB_DocManagementInfo
					SET
						DocSummaryContents =   ISNULL(@DocSummaryContents,DocSummaryContents),
						CreateDateTime =   ISNULL(@CreateDateTime,CreateDateTime),
						CreateUserID =   ISNULL(@CreateUserID,CreateUserID),
						ChangeDateTime = GETDATE(),
						ChangeUserID = @pProcessUserID,
						DocCreateWorkerCode = @DocCreateWorkerCode
					WHERE
						DocManagementCode = @OldDocManagementCode
            END ELSE IF @IUD_FLAG = 'DELETE' BEGIN
                DELETE FROM STB_DocManagementInfo
					WHERE
						DocManagementCode = @OldDocManagementCode
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
