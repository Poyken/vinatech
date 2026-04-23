-- =============================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Create date: 2022-09-14
-- Browsable : true
-- Group : 지지체
-- Description:	
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_SupportRawMaterialSplitHist_iud]
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
    DECLARE @TableName VARCHAR(100) = '/DataSet/' + @ProcessViewName
    DECLARE @ERROR_MSG NVARCHAR(MAX)
    DECLARE @IUD_FLAG VARCHAR(10)
    DECLARE @IsAutoKey BIT
    DECLARE @IsLoopIUD BIT
    DECLARE @PrefixString VARCHAR(20)
    DECLARE @SerialLen INT

    -- Declare Columns Variable
  DECLARE @OldMergeLotID VARCHAR(50)
  DECLARE @OldSplitLotID VARCHAR(50)
  DECLARE @MergeLotID VARCHAR(50)
  DECLARE @SplitLotID VARCHAR(50)
  DECLARE @TotalCurrentQty NUMERIC(20,5)
  DECLARE @CreateDateTime DATETIME
  DECLARE @CreateUserID VARCHAR(20)
  DECLARE @ChangeDateTime DATETIME
  DECLARE @ChangeUserID VARCHAR(20)
  DECLARE @SplitQty NUMERIC(20,5)
  DECLARE @IsFixed BIT
  DECLARE @TotalSplitQty NUMERIC(20,5)


	DECLARE @iDoc INT

    EXEC SmartFramework.dbo.usp_GetSerialRule 
			@pTableName = 'STB_SupportRawMaterialSplitHist',
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
					CASE 
						WHEN OldMergeLotID IS NULL THEN MergeLotID
						ELSE OldMergeLotID
					END AS OldMergeLotID,
					CASE 
						WHEN OldSplitLotID IS NULL THEN SplitLotID
						ELSE OldSplitLotID
					END AS OldSplitLotID,
					MergeLotID,
					SplitLotID,
					TotalCurrentQty,
					CreateDateTime,
					CreateUserID,
					ChangeDateTime,
					ChangeUserID,
					SplitQty,
					IsFixed
			FROM
					OPENXML(@idoc , @TableName , 2)
					WITH  (
								OldMergeLotID VARCHAR(50),
								OldSplitLotID VARCHAR(50),
								MergeLotID VARCHAR(50),
								SplitLotID VARCHAR(50),
								TotalCurrentQty NUMERIC(20,5),
								CreateDateTime DATETIMEOFFSET,
								CreateUserID VARCHAR(20),
								ChangeDateTime DATETIMEOFFSET,
								ChangeUserID VARCHAR(20),
								SplitQty NUMERIC(20,5),
								IsFixed BIT
							)

            OPEN SourceData

			-- 분할수량 총합 변수 초기화
			SET @TotalSplitQty = 0

            WHILE 1 = 1 BEGIN
                FETCH NEXT FROM SourceData INTO
								 @OldMergeLotID,
								 @OldSplitLotID,
								 @MergeLotID,
								 @SplitLotID,
								 @TotalCurrentQty,
								 @CreateDateTime,
								 @CreateUserID,
								 @ChangeDateTime,
								 @ChangeUserID,
								 @SplitQty,
								 @IsFixed


                IF @@FETCH_STATUS <> 0 BEGIN
					BREAK
				END
                
				SET @TotalSplitQty = @TotalSplitQty + @SplitQty
					
				UPDATE STB_SupportRawMaterialSplitHist
					SET
						SplitQty =   ISNULL(@SplitQty,SplitQty)
					WHERE
						MergeLotID = @OldMergeLotID AND
						SplitLotID = @OldSplitLotID
            END

			IF @TotalCurrentQty < @TotalSplitQty BEGIN
				EXEC usp_RaiseLocalizedError @pProcessLanguage, '신규Lot 수량의 총합이 원Lot 수량의 총합보다 큽니다'
				RETURN
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
