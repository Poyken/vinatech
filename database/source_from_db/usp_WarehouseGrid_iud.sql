
-- =============================================
-- Author:	    Anonymous()
-- Create date: 2020-07-29
-- Browsable : true
-- Group : 제품관리 > [G660] 입고대기창고이동처리 > 대기상태로 변경 Button
-- Description:	
--                   2020.09.02 컬럼2개 추가
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_WarehouseGrid_iud]
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
  DECLARE @OldPackingID VARCHAR(20)
  DECLARE @OldUniqueNumber VARCHAR(20)   --추가

  DECLARE @PackingID VARCHAR(20)
  DECLARE @MaterialCode VARCHAR(30)
  DECLARE @LotID VARCHAR(20)
  DECLARE @Qty NUMERIC(20,5)
  DECLARE @IsCheck BIT
  DECLARE @CreateDateTime DateTime   --추가
  DECLARE @UniqueNumber INT            --추가
  

	DECLARE @iDoc INT

    EXEC usp_GetSerialRule 
			@pTableName = 'STB_WarehouseTemp',
			@pIsAutoKey = @IsAutoKey OUTPUT,
			@pIsLoopIUD = @IsLoopIUD OUTPUT,
			@pPrefixData = @PrefixString OUTPUT,
			@pSerialLen = @SerialLen OUTPUT
    
    IF @IsAutoKey = 0 AND @IsLoopIUD = 0 BEGIN
        
        EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
	
	    BEGIN TRY


			-- Process Insert Table
            MERGE STB_WarehouseTemp AS TargetTable
			USING
				(
					SELECT
							CASE WHEN OldPackingID      IS NULL  THEN PackingID         ELSE OldPackingID        END AS OldPackingID,
							CASE WHEN OldUniqueNumber IS NULL THEN UniqueNumber ELSE OldUniqueNumber END AS OldUniqueNumber,
							PackingID,
							MaterialCode,
							LotID,
							Qty,
							IsCheck,
							UniqueNumber
					FROM
							OPENXML(@idoc , @InsertTableName , 2)
							WITH  (
										OldPackingID VARCHAR(20),
										OldUniqueNumber INT,       --추가
										PackingID VARCHAR(20),
										MaterialCode VARCHAR(30),
										LotID VARCHAR(20),
										Qty NUMERIC(20,5),
										IsCheck BIT,
										UniqueNumber INT             --추가
									) 
				) AS SourceTable
			ON
				(
					TargetTable.PackingID = SourceTable.PackingID
					AND TargetTable.UniqueNumber = SourceTable.UniqueNumber
				)

			WHEN MATCHED THEN
				UPDATE SET
					PackingID = ISNULL(SourceTable.PackingID,TargetTable.PackingID),
					MaterialCode = ISNULL(SourceTable.MaterialCode,TargetTable.MaterialCode),
					LotID = ISNULL(SourceTable.LotID,TargetTable.LotID),
					Qty = ISNULL(SourceTable.Qty,TargetTable.Qty),
					IsCheck = ISNULL(SourceTable.IsCheck,TargetTable.IsCheck)
					--UniqueNumber = ISNULL(SourceTable.UniqueNumber,TargetTable.UniqueNumber)
			WHEN NOT MATCHED THEN
				INSERT
					(
						PackingID,
						MaterialCode,
						LotID,
						Qty,
						IsCheck
						--CreateDateTime,        --추가
						--UniqueNumber
					)
				VALUES
					(
							SourceTable.PackingID,
							SourceTable.MaterialCode,
							SourceTable.LotID,
							SourceTable.Qty,
							SourceTable.IsCheck
							--SourceTable.CreateDateTime,
							--SourceTable.UniqueNumber
					);


			-- Process Update Table
            MERGE STB_WarehouseTemp AS TargetTable
			USING
				(
					SELECT
							CASE WHEN OldPackingID IS NULL         THEN PackingID       ELSE OldPackingID        END AS OldPackingID,
							CASE WHEN OldUniqueNumber IS NULL THEN UniqueNumber ELSE OldUniqueNumber END AS OldUniqueNumber,
							PackingID,
							MaterialCode,
							LotID,
							Qty,
							IsCheck,
							UniqueNumber
					FROM
							OPENXML(@idoc , @UpdateTableName , 2)
							WITH  (
										OldPackingID VARCHAR(20),
										PackingID VARCHAR(20),
										MaterialCode VARCHAR(30),
										LotID VARCHAR(20),
										Qty NUMERIC(20,5),
										IsCheck BIT,
										OldUniqueNumber INT,
										UniqueNumber INT
									) 
				) AS SourceTable
			ON
				(
					       TargetTable.PackingID = SourceTable.OldPackingID 
					AND TargetTable.UniqueNumber = SourceTable.OldUniqueNumber
				)

			WHEN MATCHED THEN

				UPDATE SET
					PackingID = ISNULL(SourceTable.PackingID,TargetTable.PackingID),
					MaterialCode = ISNULL(SourceTable.MaterialCode,TargetTable.MaterialCode),
					LotID = ISNULL(SourceTable.LotID,TargetTable.LotID),
					Qty = ISNULL(SourceTable.Qty,TargetTable.Qty),
					IsCheck = ISNULL(SourceTable.IsCheck,TargetTable.IsCheck)
					--UniqueNumber  = ISNULL(SourceTable.UniqueNumber,TargetTable.UniqueNumber)
			WHEN NOT MATCHED THEN
				INSERT
					(
						PackingID,
						MaterialCode,
						LotID,
						Qty,
						IsCheck
						--UniqueNumber
					)
				VALUES
					(
							SourceTable.PackingID,
							SourceTable.MaterialCode,
							SourceTable.LotID,
							SourceTable.Qty,
							SourceTable.IsCheck
							--SourceTable.UniqueNumber  --추가
					);


			-- Process Delete Table
            MERGE STB_WarehouseTemp AS TargetTable
			USING
				(
					SELECT
							CASE WHEN OldPackingID IS NULL THEN PackingID ELSE OldPackingID END AS OldPackingID,
							PackingID,
							UniqueNumber
					FROM
							OPENXML(@idoc , @DeleteTableName , 2)
							WITH  (
										OldPackingID VARCHAR(20),
										PackingID VARCHAR(20),
										UniqueNumber INT             --추가
									) 
				) AS SourceTable
			ON
				(
					       TargetTable.PackingID = SourceTable.PackingID
					AND TargetTable.UniqueNumber = SourceTable.UniqueNumber
				)

			WHEN MATCHED THEN
				DELETE;

        END TRY
	    BEGIN CATCH
            SET @ERROR_MSG = ERROR_MESSAGE()
			RAISERROR( @ERROR_MSG ,16, 1)
	    END CATCH
		
	    EXEC sp_xml_removedocument @idoc

    END ELSE BEGIN
        
        EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
        BEGIN TRY
		    DECLARE SourceData CURSOR FOR
                SELECT
                        'INSERT' AS IUD_FLAG,
									OldPackingID,
									PackingID,
									MaterialCode,
									LotID,
									Qty,
									IsCheck,
									CreateDateTime,                                          --추가
									UniqueNumber
							FROM
									OPENXML(@idoc , @InsertTableName , 2)
							        WITH  (
											 OldPackingID VARCHAR(20),
											 PackingID VARCHAR(20),
											 MaterialCode VARCHAR(30),
											 LotID VARCHAR(20),
											 Qty NUMERIC(20,5),
											 IsCheck BIT,
											 CreateDateTime  DateTime,   --추가
											 UniqueNumber INT
											)
							UNION ALL

							SELECT
									'UPDATE' AS IUD_FLAG,
									CASE  WHEN OldPackingID IS NULL THEN PackingID ELSE OldPackingID END AS OldPackingID,
									PackingID,
									MaterialCode,
									LotID,
									Qty,
									IsCheck,
									CreateDateTime,                                         --추가
									UniqueNumber
							FROM
									OPENXML(@idoc , @UpdateTableName , 2)
							        WITH  (
											 OldPackingID VARCHAR(20),
											 PackingID VARCHAR(20),
											 MaterialCode VARCHAR(30),
											 LotID VARCHAR(20),
											 Qty NUMERIC(20,5),
											 IsCheck BIT,
											 CreateDateTime DateTime,                       --추가
											 UniqueNumber INT
											)
							UNION ALL

							SELECT
									'DELETE' AS IUD_FLAG,
									CASE WHEN OldPackingID IS NULL THEN PackingID ELSE OldPackingID END AS OldPackingID,
									PackingID,
									MaterialCode,
									LotID,
									Qty,
									IsCheck,
									CreateDateTime,                                        --추가
									UniqueNumber
							FROM
									OPENXML(@idoc , @DeleteTableName , 2)
							        WITH  (
											 OldPackingID VARCHAR(20),
											 PackingID VARCHAR(20),
											 MaterialCode VARCHAR(30),
											 LotID VARCHAR(20),
											 Qty NUMERIC(20,5),
											 IsCheck BIT,
											 CreateDateTime  DateTime,   --추가
											 UniqueNumber INT          --추가
											) 


            OPEN SourceData

            WHILE 1 = 1 
			
			BEGIN
                FETCH NEXT FROM SourceData INTO
								 @IUD_FLAG,
								 @OldPackingID,
								 @PackingID,
								 @MaterialCode,
								 @LotID,
								 @Qty,
								 @IsCheck,
								 @CreateDateTime,
								 @UniqueNumber

                IF @@FETCH_STATUS <> 0 BEGIN
					BREAK
				END
                IF @IUD_FLAG = 'INSERT' 
				
				 BEGIN

                    IF EXISTS (SELECT 1 FROM STB_WarehouseTemp WHERE PackingID = @PackingID) BEGIN
						RAISERROR('Duplicate Data : KeyField = %s', 16, 1, @PackingID)
					END

                    IF @IsAutoKey = 1 BEGIN
                        EXEC usp_DoCreateSerial 'STB_WarehouseTemp',@PackingID OUTPUT
                    END

                    INSERT INTO STB_WarehouseTemp
						(
						    PackingID,
						    MaterialCode,
						    LotID,
						    Qty,
						    IsCheck,
							CreateDateTime      -- 추가
							--UniqueNumber        -- 추가
						)
						VALUES
						(
						    @PackingID,
						    @MaterialCode,
						    @LotID,
						    @Qty,
						    @IsCheck,
							@CreateDateTime
							--Getdate()      --추가
						--	@UniqueNumber + 1
						)

				END ELSE IF @IUD_FLAG = 'UPDATE' 
				
				BEGIN
                    UPDATE STB_WarehouseTemp
						SET
						    PackingID =   ISNULL(@PackingID,PackingID),
						    MaterialCode =   ISNULL(@MaterialCode,MaterialCode),
						    LotID =   ISNULL(@LotID,LotID),
						    Qty =   ISNULL(@Qty,Qty),
						    IsCheck =   ISNULL(@IsCheck,IsCheck)
						WHERE 1=1
						    AND PackingID = @OldPackingID
                            AND UniqueNumber = @OldUniqueNumber

				END ELSE IF @IUD_FLAG = 'DELETE'
				
				 BEGIN

                    DELETE FROM STB_WarehouseTemp
						WHERE 1=1
						    AND PackingID = @OldPackingID
							AND UniqueNumber = @OldUniqueNumber
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
