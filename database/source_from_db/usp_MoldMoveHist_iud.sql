

-- =============================================
-- Author: Park Jong Hoon(jhpark@awoo.co.kr)
-- Create date: 2016-06-15
-- Browsable : true
-- Group : 금형관리
-- Description:	금형 입출고 현황 IUD
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_MoldMoveHist_iud]
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
    DECLARE @MaxKeyField VARCHAR(20)

    -- Declare Columns Variable
  DECLARE @OldMoldMoveHistNo VARCHAR(50)
  DECLARE @MoldMoveHistNo VARCHAR(50)
  DECLARE @CompanyCode VARCHAR(20)
  DECLARE @WorkCenterCode VARCHAR(20)
  DECLARE @MoldNumber VARCHAR(20)
  DECLARE @MoveBasicDate DATE
  DECLARE @MoldMoveTypeCode VARCHAR(20)
  DECLARE @MoldLocationCode VARCHAR(20)
  DECLARE @TargetWorkCenterCode VARCHAR(20)
  DECLARE @ReturnBasicDate DATE
  DECLARE @ManagerID VARCHAR(20)
  DECLARE @MoveDesc VARCHAR(200)
  DECLARE @MoveProcessDateTime DATETIME
  DECLARE @CreateDateTime DATETIME
  DECLARE @CreateUserID VARCHAR(20)
  DECLARE @ChangeDateTime DATETIME
  DECLARE @ChangeUserID VARCHAR(20)


	DECLARE @iDoc INT

    EXEC SmartFramework.dbo.usp_GetSerialRule 
			@pTableName = 'STB_MoldMoveHist',
			@pIsAutoKey = @IsAutoKey OUTPUT,
			@pIsLoopIUD = @IsLoopIUD OUTPUT,
			@pPrefixData = @PrefixString OUTPUT,
			@pSerialLen = @SerialLen OUTPUT
    
    
	BEGIN
        EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
        BEGIN TRY
		    DECLARE SourceData CURSOR FOR
                SELECT
                        'INSERT' AS IUD_FLAG,
									OldMoldMoveHistNo,
									MoldMoveHistNo,
									CompanyCode,
									WorkCenterCode,
									MoldNumber,
									MoveBasicDate,
									MoldMoveTypeCode,
									MoldLocationCode,
									TargetWorkCenterCode,
									ReturnBasicDate,
									ManagerID,
									MoveDesc,
									MoveProcessDateTime,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID
							FROM
									OPENXML(@idoc , @InsertTableName , 2)
							        WITH  (
											 OldMoldMoveHistNo VARCHAR(50),
											 MoldMoveHistNo VARCHAR(50),
											 CompanyCode VARCHAR(20),
											 WorkCenterCode VARCHAR(20),
											 MoldNumber VARCHAR(20),
											 MoveBasicDate DATETIMEOFFSET,
											 MoldMoveTypeCode VARCHAR(20),
											 MoldLocationCode VARCHAR(20),
											 TargetWorkCenterCode VARCHAR(20),
											 ReturnBasicDate DATETIMEOFFSET,
											 ManagerID VARCHAR(20),
											 MoveDesc VARCHAR(200),
											 MoveProcessDateTime DATETIMEOFFSET,
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											)
							UNION ALL
							SELECT
									'UPDATE' AS IUD_FLAG,
									CASE 
										WHEN OldMoldMoveHistNo IS NULL THEN MoldMoveHistNo
										ELSE OldMoldMoveHistNo
									END AS OldMoldMoveHistNo,
									MoldMoveHistNo,
									CompanyCode,
									WorkCenterCode,
									MoldNumber,
									MoveBasicDate,
									MoldMoveTypeCode,
									MoldLocationCode,
									TargetWorkCenterCode,
									ReturnBasicDate,
									ManagerID,
									MoveDesc,
									MoveProcessDateTime,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID
							FROM
									OPENXML(@idoc , @UpdateTableName , 2)
							        WITH  (
											 OldMoldMoveHistNo VARCHAR(50),
											 MoldMoveHistNo VARCHAR(50),
											 CompanyCode VARCHAR(20),
											 WorkCenterCode VARCHAR(20),
											 MoldNumber VARCHAR(20),
											 MoveBasicDate DATETIMEOFFSET,
											 MoldMoveTypeCode VARCHAR(20),
											 MoldLocationCode VARCHAR(20),
											 TargetWorkCenterCode VARCHAR(20),
											 ReturnBasicDate DATETIMEOFFSET,
											 ManagerID VARCHAR(20),
											 MoveDesc VARCHAR(200),
											 MoveProcessDateTime DATETIMEOFFSET,
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											)
							UNION ALL
							SELECT
									'DELETE' AS IUD_FLAG,
									CASE 
										WHEN OldMoldMoveHistNo IS NULL THEN MoldMoveHistNo
										ELSE OldMoldMoveHistNo
									END AS OldMoldMoveHistNo,
									MoldMoveHistNo,
									CompanyCode,
									WorkCenterCode,
									MoldNumber,
									MoveBasicDate,
									MoldMoveTypeCode,
									MoldLocationCode,
									TargetWorkCenterCode,
									ReturnBasicDate,
									ManagerID,
									MoveDesc,
									MoveProcessDateTime,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID
							FROM
									OPENXML(@idoc , @DeleteTableName , 2)
							        WITH  (
											 OldMoldMoveHistNo VARCHAR(50),
											 MoldMoveHistNo VARCHAR(50),
											 CompanyCode VARCHAR(20),
											 WorkCenterCode VARCHAR(20),
											 MoldNumber VARCHAR(20),
											 MoveBasicDate DATETIMEOFFSET,
											 MoldMoveTypeCode VARCHAR(20),
											 MoldLocationCode VARCHAR(20),
											 TargetWorkCenterCode VARCHAR(20),
											 ReturnBasicDate DATETIMEOFFSET,
											 ManagerID VARCHAR(20),
											 MoveDesc VARCHAR(200),
											 MoveProcessDateTime DATETIMEOFFSET,
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											) 


            OPEN SourceData

            WHILE 1 = 1 BEGIN
                FETCH NEXT FROM SourceData INTO
								 @IUD_FLAG,
								 @OldMoldMoveHistNo,
								 @MoldMoveHistNo,
								 @CompanyCode,
								 @WorkCenterCode,
								 @MoldNumber,
								 @MoveBasicDate,
								 @MoldMoveTypeCode,
								 @MoldLocationCode,
								 @TargetWorkCenterCode,
								 @ReturnBasicDate,
								 @ManagerID,
								 @MoveDesc,
								 @MoveProcessDateTime,
								 @CreateDateTime,
								 @CreateUserID,
								 @ChangeDateTime,
								 @ChangeUserID


                IF @@FETCH_STATUS <> 0 BEGIN
					BREAK
				END
                IF @IUD_FLAG = 'INSERT' BEGIN

                    IF EXISTS (SELECT 1 FROM STB_MoldMoveHist WHERE MoldMoveHistNo = @MoldMoveHistNo) BEGIN
						RAISERROR('Duplicate Data : KeyField = %s', 16, 1, @MoldMoveHistNo)
					END

                    IF @IsAutoKey = 1 BEGIN

						EXEC SmartFramework.dbo.usp_DoCreateSerial	'STB_MoldMoveHist',
																	@MoldMoveHistNo OUTPUT
                    END
       
                    INSERT INTO STB_MoldMoveHist
						(
						    MoldMoveHistNo,
						    CompanyCode,
						    WorkCenterCode,
						    MoldNumber,
						    MoveBasicDate,
						    MoldMoveTypeCode,
						    MoldLocationCode,
						    TargetWorkCenterCode,
						    ReturnBasicDate,
						    ManagerID,
						    MoveDesc,
						    MoveProcessDateTime,
						    CreateDateTime,
						    CreateUserID,
						    ChangeDateTime,
						    ChangeUserID
						)
						VALUES
						(
						    @MoldMoveHistNo,
						    @CompanyCode,
						    @WorkCenterCode,
						    @MoldNumber,
						    @MoveBasicDate,
						    @MoldMoveTypeCode,
						    @MoldLocationCode,
						    @TargetWorkCenterCode,
						    @ReturnBasicDate,
						    @ManagerID,
						    @MoveDesc,
						    @MoveProcessDateTime,
						    GETDATE(),
						    @pProcessUserID,
						    @ChangeDateTime,
						    @ChangeUserID
						)

				END ELSE IF @IUD_FLAG = 'UPDATE' BEGIN
                    UPDATE STB_MoldMoveHist
						SET
						    MoldMoveHistNo =   CASE
						                WHEN @MoldMoveHistNo IS NOT NULL THEN @MoldMoveHistNo
						                ELSE MoldMoveHistNo
						            END,
						    CompanyCode =   CASE
						                WHEN @CompanyCode IS NOT NULL THEN @CompanyCode
						                ELSE CompanyCode
						            END,
						    WorkCenterCode =   CASE
						                WHEN @WorkCenterCode IS NOT NULL THEN @WorkCenterCode
						                ELSE WorkCenterCode
						            END,
						    MoldNumber =   CASE
						                WHEN @MoldNumber IS NOT NULL THEN @MoldNumber
						                ELSE MoldNumber
						            END,
						    MoveBasicDate =   CASE
						                WHEN @MoveBasicDate IS NOT NULL THEN @MoveBasicDate
						                ELSE MoveBasicDate
						            END,
						    MoldMoveTypeCode =   CASE
						                WHEN @MoldMoveTypeCode IS NOT NULL THEN @MoldMoveTypeCode
						                ELSE MoldMoveTypeCode
						            END,
						    MoldLocationCode =   CASE
						                WHEN @MoldLocationCode IS NOT NULL THEN @MoldLocationCode
						                ELSE MoldLocationCode
						            END,
						    TargetWorkCenterCode =   CASE
						                WHEN @TargetWorkCenterCode IS NOT NULL THEN @TargetWorkCenterCode
						                ELSE TargetWorkCenterCode
						            END,
						    ReturnBasicDate =   CASE
						                WHEN @ReturnBasicDate IS NOT NULL THEN @ReturnBasicDate
						                ELSE ReturnBasicDate
						            END,
						    ManagerID =   CASE
						                WHEN @ManagerID IS NOT NULL THEN @ManagerID
						                ELSE ManagerID
						            END,
						    MoveDesc =   CASE
						                WHEN @MoveDesc IS NOT NULL THEN @MoveDesc
						                ELSE MoveDesc
						            END,
						    MoveProcessDateTime =   CASE
						                WHEN @MoveProcessDateTime IS NOT NULL THEN @MoveProcessDateTime
						                ELSE MoveProcessDateTime
						            END,
						    CreateDateTime =   CASE
						                WHEN @CreateDateTime IS NOT NULL THEN @CreateDateTime
						                ELSE CreateDateTime
						            END,
						    CreateUserID =   CASE
						                WHEN @CreateUserID IS NOT NULL THEN @CreateUserID
						                ELSE CreateUserID
						            END,
						    ChangeDateTime = GETDATE(),
						    ChangeUserID = @pProcessUserID
						WHERE
						    MoldMoveHistNo = @OldMoldMoveHistNo
                END ELSE IF @IUD_FLAG = 'DELETE' BEGIN
                    DELETE FROM STB_MoldMoveHist
						WHERE
						    MoldMoveHistNo = @MoldMoveHistNo
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


