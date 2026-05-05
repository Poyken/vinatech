-- Procedure: usp_AssyCardInfoOvenDummy_iud

-- =============================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Create date: 2019-02-11
-- Browsable : true
-- Group : 생산관리
-- Description:	건조오븐 입출력 IUD
-- Modified: 건조오븐투입배출정보 화면에서 저장시
-- =============================================
CREATE PROCEDURE [dbo].[usp_AssyCardInfoOvenDummy_iud]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
    @pProcessViewName VARCHAR(50),
	@pPrcsCode VARCHAR(10),
	@pXml NVARCHAR(MAX) 
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
  DECLARE @Barcode VARCHAR(50)

  DECLARE @OvenCode VARCHAR(20)
  DECLARE @PrcsCode VARCHAR(10)

  SET @PrcsCode = @pPrcsCode




	DECLARE @iDoc INT

    EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
        BEGIN TRY
		    DECLARE SourceData CURSOR FOR
                SELECT
                        'UPDATE' AS IUD_FLAG,
									OvenCode,
									Barcode
							FROM
									OPENXML(@idoc , @UpdateTableName , 2)
							        WITH  (
											 OvenCode VARCHAR(50),
											 Barcode VARCHAR(20)
											)
							

            OPEN SourceData

            WHILE 1 = 1 BEGIN
                FETCH NEXT FROM SourceData INTO
								 @IUD_FLAG,
								 @OvenCode,
								 @Barcode

                IF @@FETCH_STATUS <> 0 BEGIN
					BREAK
				END

                IF @IUD_FLAG = 'UPDATE' AND @PrcsCode = 'INPUT' BEGIN
                    UPDATE STB_SetInfo
						SET
						    SIExtText02 =   CONVERT(VARCHAR(19), GETDATE(), 121)
						   ,SIExtText06 =   UPPER(@OvenCode)
						WHERE
						    Barcode = @Barcode
                END

				IF @IUD_FLAG = 'UPDATE' AND @PrcsCode = 'OUTPUT' BEGIN
                    UPDATE STB_SetInfo
						SET
						    SIExtText03 =   CONVERT(VARCHAR(19), GETDATE(), 121)            
						   ,SIExtText06 =   UPPER(@OvenCode)
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

GO

