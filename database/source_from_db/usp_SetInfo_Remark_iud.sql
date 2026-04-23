
-- =============================================
-- Author:	   Kangs (kilee@vina.co.kr)
-- Create date: 2020-09-11
-- Browsable : true
-- Group : 생산관리 > 재공현황
-- Description:	
-- Modified:

-- Select Remark, IsLoss, isProdFinish, * from stb_setinfo where barcode = 'VJJO033R036740'
 --update stb_setinfo
 --set isProdFinish = 0
 --where barcode = 'VJJO033R036740'
-- =============================================
CREATE PROCEDURE [dbo].[usp_SetInfo_Remark_iud]
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
  DECLARE @OldControlNo VARCHAR(20)
  DECLARE @ControlNo VARCHAR(20)
  DECLARE @IsLoss BIT
  DECLARE @OutSetNoSeq INT
  DECLARE @Barcode VARCHAR(50)
  DECLARE @IsProdFinish BIT
  DECLARE @ChangeDateTime DATETIME
  DECLARE @ChangeUserID VARCHAR(20)
  DECLARE @Remark NVARCHAR(MAX)
  DECLARE @SIExtInt01 INT


	DECLARE @iDoc INT

    EXEC usp_GetSerialRule 
			@pTableName = 'STB_SetInfo',
			@pIsAutoKey = @IsAutoKey OUTPUT,
			@pIsLoopIUD = @IsLoopIUD OUTPUT,
			@pPrefixData = @PrefixString OUTPUT,
			@pSerialLen = @SerialLen OUTPUT
    
    IF @IsAutoKey = 0 AND @IsLoopIUD = 0 BEGIN
        PRINT 'Batch was removed'
    END ELSE BEGIN
        
        EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
        BEGIN TRY
		    DECLARE SourceData CURSOR FOR
                SELECT
                        'INSERT' AS IUD_FLAG,
									OldControlNo,
									ControlNo,
									IsLoss,
									OutSetNoSeq,
									Barcode,
									IsProdFinish,
									ChangeDateTime,
									ChangeUserID,
									Remark
							FROM
									OPENXML(@idoc , @InsertTableName , 2)
							        WITH  (
											 OldControlNo VARCHAR(20),
											 ControlNo VARCHAR(20),
											 IsLoss BIT,
											 OutSetNoSeq INT,
											 Barcode VARCHAR(50),
											 IsProdFinish BIT,
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20),
											 Remark NVARCHAR(MAX)
											)
							UNION ALL
							SELECT
									'UPDATE' AS IUD_FLAG,
									CASE 
										WHEN OldControlNo IS NULL THEN ControlNo
										ELSE OldControlNo
									END AS OldControlNo,
									ControlNo,
									IsLoss,
									OutSetNoSeq,
									Barcode,
									IsProdFinish,
									ChangeDateTime,
									ChangeUserID,
									Remark
							FROM
									OPENXML(@idoc , @UpdateTableName , 2)
							        WITH  (
											 OldControlNo VARCHAR(20),
											 ControlNo VARCHAR(20),
											 IsLoss BIT,
											 OutSetNoSeq INT,
											 Barcode VARCHAR(50),
											 IsProdFinish BIT,
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20),
											 Remark NVARCHAR(MAX)
											)
							UNION ALL
							SELECT
									'DELETE' AS IUD_FLAG,
									CASE 
										WHEN OldControlNo IS NULL THEN ControlNo
										ELSE OldControlNo
									END AS OldControlNo,
									ControlNo,
									IsLoss,
									OutSetNoSeq,
									Barcode,
									IsProdFinish,
									ChangeDateTime,
									ChangeUserID,
									Remark
							FROM
									OPENXML(@idoc , @DeleteTableName , 2)
							        WITH  (
											 OldControlNo VARCHAR(20),
											 ControlNo VARCHAR(20),
											 IsLoss BIT,
											 OutSetNoSeq INT,
											 Barcode VARCHAR(50),
											 IsProdFinish BIT,
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20),
											 Remark NVARCHAR(MAX)
											) 


            OPEN SourceData

            WHILE 1 = 1 BEGIN
                FETCH NEXT FROM SourceData INTO
								 @IUD_FLAG,
								 @OldControlNo,
								 @ControlNo,
								 @IsLoss,
								 @OutSetNoSeq,
								 @Barcode,
								 @IsProdFinish,
								 @ChangeDateTime,
								 @ChangeUserID,
								 @Remark


                IF @@FETCH_STATUS <> 0 BEGIN
					BREAK
				END
                IF @IUD_FLAG = 'INSERT' BEGIN

                    IF EXISTS (SELECT 1 FROM STB_SetInfo WHERE ControlNo = @ControlNo) BEGIN
						RAISERROR('Duplicate Data : KeyField = %s', 16, 1, @ControlNo)
					END

                    IF @IsAutoKey = 1 BEGIN
                        EXEC usp_DoCreateSerial 'STB_SetInfo',@ControlNo OUTPUT
                    END

                    INSERT INTO STB_SetInfo
						(
						    OutSetNoSeq
						)
						VALUES
						(
						    @OutSetNoSeq
						)

				END ELSE IF @IUD_FLAG = 'UPDATE' BEGIN
                    -- 공정부적합 상태인지 확인 후 불가 처리 #210625 by Jackaroe
					SELECT @SIExtInt01 = SIExtInt01
					  FROM STB_SetInfo
					 WHERE BarCode = @BarCode

				   IF @SIExtInt01 = CONVERT(BIT, 1) AND @IsProdFinish = CONVERT(BIT, 1) BEGIN 
						RAISERROR('공정부적합 상태의 Lot입니다. 생산완료처리 할 수 없습니다.', 16, 1)
				   END
					
					UPDATE STB_SetInfo
						SET
						    ControlNo =   ISNULL(@ControlNo,ControlNo),
						    IsLoss =   ISNULL(@IsLoss,IsLoss),
						    Barcode =   ISNULL(@Barcode,Barcode),
						    IsProdFinish =   ISNULL(@IsProdFinish,IsProdFinish),
						    ChangeDateTime = GETDATE(),
						    ChangeUserID = @pProcessUserID,
						    Remark =   ISNULL(@Remark,Remark),
							IsNotWip = CONVERT(BIT, 1)
						WHERE
						    BarCode = @BarCode
                END ELSE IF @IUD_FLAG = 'DELETE' BEGIN
                    DELETE FROM STB_SetInfo
						WHERE
						    BarCode = @BarCode
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
