-- =============================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Create date: 2022-09-13
-- Browsable : true
-- Group : 지지체
-- Description:	
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_SupportRawMaterialMergeHist_iud]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
    @pProcessViewName VARCHAR(50),
	@pXml NVARCHAR(MAX) = null,
	@pOriginalLotID VARCHAR(50),
	@pLotQty INT = null
AS
BEGIN
	SET NOCOUNT ON;

    DECLARE @ProcessUserID VARCHAR(20) = @pProcessUserID
    DECLARE @ProcessLanguage VARCHAR(20) = @pProcessLanguage
    DECLARE @ProcessViewName VARCHAR(50) = @pProcessViewName
    DECLARE @TableName VARCHAR(100) = '/DataSet/' + @ProcessViewName
    DECLARE @ERROR_MSG NVARCHAR(MAX)
    DECLARE @IUD_FLAG VARCHAR(10)
    DECLARE @IsAutoKey BIT
    DECLARE @IsLoopIUD BIT
    DECLARE @PrefixString VARCHAR(20)
    DECLARE @SerialLen INT

    -- Declare Columns Variable
  DECLARE @OldOriginalLotID VARCHAR(50)
  DECLARE @OldMergeLotID VARCHAR(50)
  DECLARE @OriginalLotID VARCHAR(50)
  DECLARE @MergeLotID VARCHAR(50)
  DECLARE @CreateDateTime DATETIME
  DECLARE @CreateUserID VARCHAR(20)
  DECLARE @ChangeDateTime DATETIME
  DECLARE @ChangeUserID VARCHAR(20)
  DECLARE @CurrentQty NUMERIC(20,5)
  DECLARE @TotalCurrentQty NUMERIC(20,5)
  DECLARE @LotQty INT = @pLotQty
  DECLARE @LoopCnt INT
  DECLARE @SplitLotID VARCHAR(50)

  DECLARE @DeleteLotIDs TABLE 
  (
	LotID VARCHAR(50)
  );

  DECLARE @IsFixed BIT


	DECLARE @iDoc INT

    EXEC Smartframework.dbo.usp_GetSerialRule 
			@pTableName = 'STB_SupportRawMaterialMergeHist',
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
                SELECT  LotID,
						CurrentQty,
						CreateDateTime,
						CreateUserID,
						ChangeDateTime,
						ChangeUserID
				FROM
						OPENXML(@idoc , @TableName , 2)
						WITH  (
									LotID VARCHAR(50),
									CurrentQty NUMERIC(20,5),
									CreateDateTime DATETIMEOFFSET,
									CreateUserID VARCHAR(20),
									ChangeDateTime DATETIMEOFFSET,
									ChangeUserID VARCHAR(20)
								)

            OPEN SourceData

			SET @TotalCurrentQty = 0
			SET @LoopCnt = 0

			-- Original LotID로 @DeleteLotID를 구해서 관련 데이터를 모두 삭제한다.
			INSERT INTO @DeleteLotIDs
			SELECT MergeLotID
			  FROM STB_SupportRawMaterialMergeHist
			 WHERE OriginalLotID = @pOriginalLotID

			 IF EXISTS (SELECT 1 
			              FROM STB_SupportRawMaterialSplitHist 
						 WHERE MergeLotID IN (SELECT LotID 
						                        FROM @DeleteLotIDs) 
						   AND IsFixed = CONVERT(BIT, 1)) BEGIN
				EXEC usp_RaiseLocalizedError @ProcessLanguage, '소분Lot이 확정되었습니다. 재계산할 수 없습니다.'
				RETURN
			 END

			 DELETE FROM STB_SupportRawMaterialMergeHist WHERE MergeLotID IN (SELECT LotID FROM @DeleteLotIDs)

			 DELETE FROM STB_SupportRawMaterialSplitHist WHERE MergeLotID IN (SELECT LotID FROM @DeleteLotIDs)

			EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_MaterialDocLotInfo', @MergeLotID OUTPUT

            WHILE 1 = 1 BEGIN
                FETCH NEXT FROM SourceData INTO
								 @OriginalLotID,
								 @CurrentQty,
								 @CreateDateTime,
								 @CreateUserID,
								 @ChangeDateTime,
								 @ChangeUserID


                IF @@FETCH_STATUS <> 0 BEGIN
					BREAK
				END

				SET @TotalCurrentQty = @TotalCurrentQty + @CurrentQty

                INSERT INTO STB_SupportRawMaterialMergeHist
				(
					OriginalLotID,
					MergeLotID,
					CreateDateTime,
					CreateUserID,
					ChangeDateTime,
					ChangeUserID
				)
				VALUES
				(
					@OriginalLotID,
					@MergeLotID,
					GETDATE(),
					@pProcessUserID,
					@ChangeDateTime,
					@ChangeUserID
				)
            END

			-- 입력 받은 LotQty만큼 신규 Lot을 생성하여 STB_SupportRawMaterialSplitHist 생성
			WHILE @LotQty > @LoopCnt BEGIN
				EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_MaterialDocLotInfo', @SplitLotID OUTPUT

				INSERT INTO STB_SupportRawMaterialSplitHist 
				(
					MergeLotID
                   ,SplitLotID
                   ,TotalCurrentQty
                   ,CreateDateTime
                   ,CreateUserID
                   ,ChangeDateTime
                   ,ChangeUserID
				) 
				VALUES 
				(
					@MergeLotID
                   ,@SplitLotID
                   ,@TotalCurrentQty
                   ,GETDATE()
                   ,@pProcessUserID
                   ,NULL
                   ,NULL
				)

				SET @LoopCnt = @LoopCnt + 1
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
