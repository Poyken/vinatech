-- ED-VJPMTR000000013
-- =============================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Create date: 2024-11-21
-- Browsable : true
-- Group : PS부문
-- Description:	
-- Modified:
-- =============================================
CREATE PROCEDURE dbo.usp_PackingLabelHistForPS_iud
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
  DECLARE @OldPackingLabelHistNo VARCHAR(20)
  DECLARE @PackingLabelHistNo VARCHAR(20)
  DECLARE @LotNo VARCHAR(20)
  DECLARE @Voltage VARCHAR(20)
  DECLARE @Farad VARCHAR(20)
  DECLARE @Rating VARCHAR(50)
  DECLARE @PartNo VARCHAR(50)
  DECLARE @LotQty INT
  DECLARE @LabelQty INT
  DECLARE @CreateDateTime DATETIME
  DECLARE @CreateUserID VARCHAR(20)
  DECLARE @ChangeDateTime DATETIME
  DECLARE @ChangeUserID VARCHAR(20)


	DECLARE @iDoc INT

    EXEC SmartFramework.dbo.usp_GetSerialRule 
			@pTableName = 'STB_PackingLabelHistForPS',
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
									OldPackingLabelHistNo,
									PackingLabelHistNo,
									LotNo,
									Voltage,
									Farad,
									Rating,
									PartNo,
									LotQty,
									LabelQty,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID
							FROM
									OPENXML(@idoc , @InsertTableName , 2)
							        WITH  (
											 OldPackingLabelHistNo VARCHAR(20),
											 PackingLabelHistNo VARCHAR(20),
											 LotNo VARCHAR(20),
											 Voltage VARCHAR(20),
											 Farad VARCHAR(20),
											 Rating VARCHAR(50),
											 PartNo VARCHAR(50),
											 LotQty INT,
											 LabelQty INT,
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											)
							UNION ALL
							SELECT
									'UPDATE' AS IUD_FLAG,
									CASE 
										WHEN OldPackingLabelHistNo IS NULL THEN PackingLabelHistNo
										ELSE OldPackingLabelHistNo
									END AS OldPackingLabelHistNo,
									PackingLabelHistNo,
									LotNo,
									Voltage,
									Farad,
									Rating,
									PartNo,
									LotQty,
									LabelQty,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID
							FROM
									OPENXML(@idoc , @UpdateTableName , 2)
							        WITH  (
											 OldPackingLabelHistNo VARCHAR(20),
											 PackingLabelHistNo VARCHAR(20),
											 LotNo VARCHAR(20),
											 Voltage VARCHAR(20),
											 Farad VARCHAR(20),
											 Rating VARCHAR(50),
											 PartNo VARCHAR(50),
											 LotQty INT,
											 LabelQty INT,
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											)
							UNION ALL
							SELECT
									'DELETE' AS IUD_FLAG,
									CASE 
										WHEN OldPackingLabelHistNo IS NULL THEN PackingLabelHistNo
										ELSE OldPackingLabelHistNo
									END AS OldPackingLabelHistNo,
									PackingLabelHistNo,
									LotNo,
									Voltage,
									Farad,
									Rating,
									PartNo,
									LotQty,
									LabelQty,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID
							FROM
									OPENXML(@idoc , @DeleteTableName , 2)
							        WITH  (
											 OldPackingLabelHistNo VARCHAR(20),
											 PackingLabelHistNo VARCHAR(20),
											 LotNo VARCHAR(20),
											 Voltage VARCHAR(20),
											 Farad VARCHAR(20),
											 Rating VARCHAR(50),
											 PartNo VARCHAR(50),
											 LotQty INT,
											 LabelQty INT,
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											) 


            OPEN SourceData

            WHILE 1 = 1 BEGIN
                FETCH NEXT FROM SourceData INTO
								 @IUD_FLAG,
								 @OldPackingLabelHistNo,
								 @PackingLabelHistNo,
								 @LotNo,
								 @Voltage,
								 @Farad,
								 @Rating,
								 @PartNo,
								 @LotQty,
								 @LabelQty,
								 @CreateDateTime,
								 @CreateUserID,
								 @ChangeDateTime,
								 @ChangeUserID


                IF @@FETCH_STATUS <> 0 BEGIN
					BREAK
				END
                IF @IUD_FLAG = 'INSERT' BEGIN

                    IF EXISTS (SELECT 1 FROM STB_PackingLabelHistForPS WHERE PackingLabelHistNo = @PackingLabelHistNo) BEGIN
						RAISERROR('Duplicate Data : KeyField = %s', 16, 1, @PackingLabelHistNo)
					END

                    IF @IsAutoKey = 1 BEGIN
                        EXEC usp_DoCreateSerial 'STB_PackingLabelHistForPS',@PackingLabelHistNo OUTPUT
                    END

                    INSERT INTO STB_PackingLabelHistForPS
						(
						    PackingLabelHistNo,
						    LotNo,
						    Voltage,
						    Farad,
						    Rating,
						    PartNo,
						    LotQty,
						    LabelQty,
						    CreateDateTime,
						    CreateUserID,
						    ChangeDateTime,
						    ChangeUserID
						)
						VALUES
						(
						    @PackingLabelHistNo,
						    @LotNo,
						    @Voltage,
						    @Farad,
						    @Rating,
						    @PartNo,
						    @LotQty,
						    @LabelQty,
						    GETDATE(),
						    @pProcessUserID,
						    @ChangeDateTime,
						    @ChangeUserID
						)

				END ELSE IF @IUD_FLAG = 'UPDATE' BEGIN
                    UPDATE STB_PackingLabelHistForPS
						SET
						    LotNo =   ISNULL(@LotNo,LotNo),
						    Voltage =   ISNULL(@Voltage,Voltage),
						    Farad =   ISNULL(@Farad,Farad),
						    Rating =   ISNULL(@Rating,Rating),
						    PartNo =   ISNULL(@PartNo,PartNo),
						    LotQty =   ISNULL(@LotQty,LotQty),
						    LabelQty =   ISNULL(@LabelQty,LabelQty),
						    CreateDateTime =   ISNULL(@CreateDateTime,CreateDateTime),
						    CreateUserID =   ISNULL(@CreateUserID,CreateUserID),
						    ChangeDateTime = GETDATE(),
						    ChangeUserID = @pProcessUserID
						WHERE
						    PackingLabelHistNo = @OldPackingLabelHistNo
                END ELSE IF @IUD_FLAG = 'DELETE' BEGIN
                    DELETE FROM STB_PackingLabelHistForPS
						WHERE
						    PackingLabelHistNo = @OldPackingLabelHistNo
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
