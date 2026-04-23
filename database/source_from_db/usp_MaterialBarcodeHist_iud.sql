
-- =============================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Create date: 2019-04-15
-- Browsable : true
-- Group : 자재관리
-- Description:	
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_MaterialBarcodeHist_iud]
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
  DECLARE @OldMaterialBarcodeNo VARCHAR(20)
  DECLARE @MaterialBarcodeNo VARCHAR(20)
  DECLARE @MaterialDocDetailNo VARCHAR(20)
  DECLARE @BarcodeText VARCHAR(100)
  DECLARE @LotNo VARCHAR(20)
  DECLARE @LotQty NUMERIC(20,5)
  DECLARE @LotAttr01 NVARCHAR(100)
  DECLARE @LotAttr02 NVARCHAR(100)
  DECLARE @LotAttr03 NVARCHAR(100)
  DECLARE @LotAttr04 NVARCHAR(100)
  DECLARE @LotAttr05 NVARCHAR(100)
  DECLARE @CreateDateTime DATETIME
  DECLARE @CreateUserID VARCHAR(20)
  DECLARE @ChangeDateTime DATETIME
  DECLARE @ChangeUserID VARCHAR(20)


	DECLARE @iDoc INT

    EXEC SmartFramework.dbo.usp_GetSerialRule 
			@pTableName = 'STB_MaterialBarcodeHist',
			@pIsAutoKey = @IsAutoKey OUTPUT,
			@pIsLoopIUD = @IsLoopIUD OUTPUT,
			@pPrefixData = @PrefixString OUTPUT,
			@pSerialLen = @SerialLen OUTPUT
    
    
	EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml

        BEGIN TRY
		    DECLARE SourceData CURSOR FOR
                SELECT
                        'INSERT' AS IUD_FLAG,
									OldMaterialBarcodeNo,
									MaterialBarcodeNo,
									MaterialDocDetailNo,
									BarcodeText,
									LotNo,
									LotQty,
									LotAttr01,
									LotAttr02,
									LotAttr03,
									LotAttr04,
									LotAttr05,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID
							FROM
									OPENXML(@idoc , @InsertTableName , 2)
							        WITH  (
											 OldMaterialBarcodeNo VARCHAR(20),
											 MaterialBarcodeNo VARCHAR(20),
											 MaterialDocDetailNo VARCHAR(20),
											 BarcodeText VARCHAR(100),
											 LotNo VARCHAR(20),
											 LotQty NUMERIC(20,5),
											 LotAttr01 NVARCHAR(100),
											 LotAttr02 NVARCHAR(100),
											 LotAttr03 NVARCHAR(100),
											 LotAttr04 NVARCHAR(100),
											 LotAttr05 NVARCHAR(100),
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											)
							UNION ALL
							SELECT
									'UPDATE' AS IUD_FLAG,
									CASE 
										WHEN OldMaterialBarcodeNo IS NULL THEN MaterialBarcodeNo
										ELSE OldMaterialBarcodeNo
									END AS OldMaterialBarcodeNo,
									MaterialBarcodeNo,
									MaterialDocDetailNo,
									BarcodeText,
									LotNo,
									LotQty,
									LotAttr01,
									LotAttr02,
									LotAttr03,
									LotAttr04,
									LotAttr05,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID
							FROM
									OPENXML(@idoc , @UpdateTableName , 2)
							        WITH  (
											 OldMaterialBarcodeNo VARCHAR(20),
											 MaterialBarcodeNo VARCHAR(20),
											 MaterialDocDetailNo VARCHAR(20),
											 BarcodeText VARCHAR(100),
											 LotNo VARCHAR(20),
											 LotQty NUMERIC(20,5),
											 LotAttr01 NVARCHAR(100),
											 LotAttr02 NVARCHAR(100),
											 LotAttr03 NVARCHAR(100),
											 LotAttr04 NVARCHAR(100),
											 LotAttr05 NVARCHAR(100),
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											)
							UNION ALL
							SELECT
									'DELETE' AS IUD_FLAG,
									CASE 
										WHEN OldMaterialBarcodeNo IS NULL THEN MaterialBarcodeNo
										ELSE OldMaterialBarcodeNo
									END AS OldMaterialBarcodeNo,
									MaterialBarcodeNo,
									MaterialDocDetailNo,
									BarcodeText,
									LotNo,
									LotQty,
									LotAttr01,
									LotAttr02,
									LotAttr03,
									LotAttr04,
									LotAttr05,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID
							FROM
									OPENXML(@idoc , @DeleteTableName , 2)
							        WITH  (
											 OldMaterialBarcodeNo VARCHAR(20),
											 MaterialBarcodeNo VARCHAR(20),
											 MaterialDocDetailNo VARCHAR(20),
											 BarcodeText VARCHAR(100),
											 LotNo VARCHAR(20),
											 LotQty NUMERIC(20,5),
											 LotAttr01 NVARCHAR(100),
											 LotAttr02 NVARCHAR(100),
											 LotAttr03 NVARCHAR(100),
											 LotAttr04 NVARCHAR(100),
											 LotAttr05 NVARCHAR(100),
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											) 


            OPEN SourceData

            WHILE 1 = 1 BEGIN
                FETCH NEXT FROM SourceData INTO
								 @IUD_FLAG,
								 @OldMaterialBarcodeNo,
								 @MaterialBarcodeNo,
								 @MaterialDocDetailNo,
								 @BarcodeText,
								 @LotNo,
								 @LotQty,
								 @LotAttr01,
								 @LotAttr02,
								 @LotAttr03,
								 @LotAttr04,
								 @LotAttr05,
								 @CreateDateTime,
								 @CreateUserID,
								 @ChangeDateTime,
								 @ChangeUserID


                IF @@FETCH_STATUS <> 0 BEGIN
					BREAK
				END
                IF @IUD_FLAG = 'INSERT' BEGIN
					IF RTRIM(ISNULL(@BarcodeText, '')) <> '' BEGIN
						--분리막 처리
						--폭
						SET @LotAttr02 = CONVERT(VARCHAR(20), CONVERT(NUMERIC(20,5), SUBSTRING(@BarcodeText, 34, 3)) / 10.0)
						--무게
						SET @LotQty = CONVERT(NUMERIC(20,5), SUBSTRING(@BarcodeText, 39, 3)) / 10.0
						-- LotNo
						SET @LotNo = SUBSTRING(@BarcodeText, 50, 8)
					END

                    UPDATE STB_MaterialBarcodeHist
						SET
						    BarcodeText =   ISNULL(@BarcodeText,BarcodeText),
						    LotNo =   ISNULL(@LotNo,LotNo),
						    LotQty =   ISNULL(@LotQty,LotQty),
						    LotAttr01 =   ISNULL(@LotAttr01,LotAttr01),
						    LotAttr02 =   ISNULL(@LotAttr02,LotAttr02),
						    LotAttr03 =   ISNULL(@LotAttr03,LotAttr03),
						    LotAttr04 =   ISNULL(@LotAttr04,LotAttr04),
						    LotAttr05 =   ISNULL(@LotAttr05,LotAttr05),
						    ChangeDateTime = GETDATE(),
						    ChangeUserID = @pProcessUserID
						WHERE
						    MaterialBarcodeNo = @MaterialBarcodeNo

				END ELSE IF @IUD_FLAG = 'UPDATE' BEGIN
                    IF RTRIM(ISNULL(@BarcodeText, '')) <> '' BEGIN
						--분리막 처리
						--폭
						SET @LotAttr02 = CONVERT(VARCHAR(20), CONVERT(NUMERIC(20,5), SUBSTRING(@BarcodeText, 34, 3)) / 10.0)
						--무게
						SET @LotQty = CONVERT(NUMERIC(20,5), SUBSTRING(@BarcodeText, 39, 3)) / 10.0
						-- LotNo
						SET @LotNo = SUBSTRING(@BarcodeText, 50, 8)
					END
					
					UPDATE STB_MaterialBarcodeHist
						SET
						    BarcodeText =   ISNULL(@BarcodeText,BarcodeText),
						    LotNo =   ISNULL(@LotNo,LotNo),
						    LotQty =   ISNULL(@LotQty,LotQty),
						    LotAttr01 =   ISNULL(@LotAttr01,LotAttr01),
						    LotAttr02 =   ISNULL(@LotAttr02,LotAttr02),
						    LotAttr03 =   ISNULL(@LotAttr03,LotAttr03),
						    LotAttr04 =   ISNULL(@LotAttr04,LotAttr04),
						    LotAttr05 =   ISNULL(@LotAttr05,LotAttr05),
						    ChangeDateTime = GETDATE(),
						    ChangeUserID = @pProcessUserID
						WHERE
						    MaterialBarcodeNo = @MaterialBarcodeNo

                END ELSE IF @IUD_FLAG = 'DELETE' BEGIN
                    DELETE FROM STB_MaterialBarcodeHist
						WHERE
						    MaterialBarcodeNo = @MaterialBarcodeNo
                END
            END

			-- 원자재 바코드 정보 생성
			exec usp_DoFixMaterialLabelManual @ProcessLanguage, @ProcessUserID, @MaterialDocDetailNo
        END TRY
		BEGIN CATCH
			SET @ERROR_MSG = ERROR_MESSAGE()
			RAISERROR( @ERROR_MSG ,16, 1)
		END CATCH
			
		CLOSE SourceData;
		DEALLOCATE SourceData;
			
		EXEC sp_xml_removedocument @idoc	
END
