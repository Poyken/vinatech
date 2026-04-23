
-- =============================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Create date: 2020-11-04
-- Browsable : true
-- Group : 생산관리
-- Description:	
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_MonthProdPlan_iud]
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
  DECLARE @OldCompanyCode VARCHAR(20)
  DECLARE @OldWorkCenterCode VARCHAR(20)
  DECLARE @OldPlanYearMonth DATE
  DECLARE @OldLineCode VARCHAR(20)
  DECLARE @OldMaterialCode VARCHAR(20)
  DECLARE @OldMaterialName VARCHAR(60)
  DECLARE @CompanyCode VARCHAR(20)
  DECLARE @WorkCenterCode VARCHAR(20)
  DECLARE @PlanYearMonth DATE
  DECLARE @MaterialCode VARCHAR(20)
  DECLARE @MaterialName VARCHAR(60)      ---추가사항
  --DECLARE @PlanQty NUMERIC(20,5)
  DECLARE @PlanQty INT

  DECLARE @CreateDateTime DATETIME
  DECLARE @CreateUserID VARCHAR(20)
  DECLARE @ChangeDateTime DATETIME
  DECLARE @ChangeUserID VARCHAR(20)
  DECLARE @LineCode VARCHAR(20)
  DECLARE @Batch INT
  DECLARE @iDoc INT

    EXEC SmartFramework.dbo.usp_GetSerialRule 
			@pTableName = 'STB_MonthProdPlan',
			@pIsAutoKey = @IsAutoKey OUTPUT,
			@pIsLoopIUD = @IsLoopIUD OUTPUT,
			@pPrefixData = @PrefixString OUTPUT,
			@pSerialLen = @SerialLen OUTPUT
    
    IF @IsAutoKey = 0 AND @IsLoopIUD = 0 
	
	BEGIN
        PRINT 'Batch was removed'
    END ELSE BEGIN
        
        EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
        BEGIN TRY
		    DECLARE SourceData CURSOR FOR
                SELECT
                        'INSERT' AS IUD_FLAG,
									OldCompanyCode,
									OldWorkCenterCode,
									OldPlanYearMonth,
									OldLineCode,
									OldMaterialCode,
									OldMaterialName,
									CompanyCode,
									WorkCenterCode,
									PlanYearMonth,
									LineCode,
									MaterialCode,
									MaterialName,
									PlanQty,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID,
									Batch  -- 추가사항
							FROM
									OPENXML(@idoc , @InsertTableName , 2)
							        WITH  (
											 OldCompanyCode VARCHAR(20),
											 OldWorkCenterCode VARCHAR(20),
											 OldPlanYearMonth DATETIMEOFFSET,
											 OldLineCode VARCHAR(20),
											 OldMaterialCode VARCHAR(20),
											  OldMaterialName VARCHAR(60),
											 CompanyCode VARCHAR(20),
											 WorkCenterCode VARCHAR(20),
											 PlanYearMonth DATETIMEOFFSET,
											 LineCode VARCHAR(20),
											 MaterialCode VARCHAR(20),
											 MaterialName VARCHAR(60),
											-- PlanQty NUMERIC(20,5),
											PlanQty INT, 
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20),
											 Batch INT
											)
							UNION ALL
							SELECT
									'UPDATE' AS IUD_FLAG,
									CASE 
										WHEN OldCompanyCode IS NULL THEN CompanyCode
										ELSE OldCompanyCode
									END AS OldCompanyCode,
									CASE 
										WHEN OldWorkCenterCode IS NULL THEN WorkCenterCode
										ELSE OldWorkCenterCode
									END AS OldWorkCenterCode,
									CASE 
										WHEN OldPlanYearMonth IS NULL THEN PlanYearMonth
										ELSE OldPlanYearMonth
									END AS OldPlanYearMonth,
									CASE 
										WHEN OldLineCode IS NULL THEN LineCode
										ELSE OldLineCode
									END AS OldLineCode,
									CASE 
										WHEN OldMaterialCode IS NULL THEN MaterialCode
										ELSE OldMaterialCode
									END AS OldMaterialCode,

									CASE 
										WHEN OldMaterialName IS NULL THEN MaterialName
										ELSE OldMaterialName
									END AS OldMaterialName,


									CompanyCode,
									WorkCenterCode,
									PlanYearMonth,
									LineCode,
									MaterialCode,
									MaterialName,
									PlanQty,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID,
									Batch
							FROM
									OPENXML(@idoc , @UpdateTableName , 2)
							        WITH  (
											 OldCompanyCode VARCHAR(20),
											 OldWorkCenterCode VARCHAR(20),
											 OldPlanYearMonth DATETIMEOFFSET,
											 OldLineCode VARCHAR(20),
											 OldMaterialCode VARCHAR(20),
											 OldMaterialName VARCHAR(60),
											 CompanyCode VARCHAR(20),
											 WorkCenterCode VARCHAR(20),
											 PlanYearMonth DATETIMEOFFSET,
											 LineCode VARCHAR(20),
											 MaterialCode VARCHAR(20),
											  MaterialName VARCHAR(60),
											 --PlanQty NUMERIC(20,5),
											 PlanQty INT,
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20),
											 Batch INT
											)
							UNION ALL
							SELECT
									'DELETE' AS IUD_FLAG,
									CASE 
										WHEN OldCompanyCode IS NULL THEN CompanyCode
										ELSE OldCompanyCode
									END AS OldCompanyCode,
									CASE 
										WHEN OldWorkCenterCode IS NULL THEN WorkCenterCode
										ELSE OldWorkCenterCode
									END AS OldWorkCenterCode,
									CASE 
										WHEN OldPlanYearMonth IS NULL THEN PlanYearMonth
										ELSE OldPlanYearMonth
									END AS OldPlanYearMonth,
									CASE 
										WHEN OldLineCode IS NULL THEN LineCode
										ELSE OldLineCode
									END AS OldLineCode,
									CASE 
										WHEN OldMaterialCode IS NULL THEN MaterialCode
										ELSE OldMaterialCode
									END AS OldMaterialCode,
										CASE 
										WHEN OldMaterialName IS NULL THEN MaterialName
										ELSE OldMaterialCode
									END AS OldMaterialCode,


									CompanyCode,
									WorkCenterCode,
									PlanYearMonth,
									LineCode,
									MaterialCode,
									MaterialName,
									PlanQty,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID,
									Batch
							FROM
									OPENXML(@idoc , @DeleteTableName , 2)
							        WITH  (
											 OldCompanyCode VARCHAR(20),
											 OldWorkCenterCode VARCHAR(20),
											 OldPlanYearMonth DATETIMEOFFSET,
											 OldLineCode VARCHAR(20),
											 OldMaterialCode VARCHAR(20),
											  OldMaterialName VARCHAR(60),
											 CompanyCode VARCHAR(20),
											 WorkCenterCode VARCHAR(20),
											 PlanYearMonth DATETIMEOFFSET,
											 LineCode VARCHAR(20),
											 MaterialCode VARCHAR(20),
											 MaterialName VARCHAR(20),
											 --PlanQty NUMERIC(20,5),
											  PlanQty INT,
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20),
											 Batch INT
											) 


            OPEN SourceData

            WHILE 1 = 1 BEGIN
                FETCH NEXT FROM SourceData INTO
								 @IUD_FLAG,
								 @OldCompanyCode,
								 @OldWorkCenterCode,
								 @OldPlanYearMonth,
								 @OldLineCode,
								 @OldMaterialCode,
								  @OldMaterialName,
								 @CompanyCode,
								 @WorkCenterCode,
								 @PlanYearMonth,
								 @LineCode,
								 @MaterialCode,
								 @MaterialName,
								 @PlanQty,
								 @CreateDateTime,
								 @CreateUserID,
								 @ChangeDateTime,
								 @ChangeUserID,
								 @Batch


                IF @@FETCH_STATUS <> 0 BEGIN
					BREAK
				END
                IF @IUD_FLAG = 'INSERT' BEGIN

                    IF EXISTS (SELECT 1 FROM STB_MonthProdPlan WHERE CompanyCode = @CompanyCode AND WorkCenterCode = @WorkCenterCode AND PlanYearMonth = @PlanYearMonth AND MaterialCode = @MaterialCode) BEGIN
						RAISERROR('Duplicate Data : KeyField = %s', 16, 1, @CompanyCode)
					END

                    IF @IsAutoKey = 1 BEGIN
                        EXEC usp_DoCreateSerial 'STB_MonthProdPlan',@CompanyCode OUTPUT
                    END

                    INSERT INTO STB_MonthProdPlan
						(
						    CompanyCode,
						    WorkCenterCode,
						    PlanYearMonth,
							LineCode,
						    MaterialCode,
							MaterialName,
						    PlanQty,
						    CreateDateTime,
						    CreateUserID,
						    ChangeDateTime,
						    ChangeUserID,
							Batch
						)
						VALUES
						(
						    @CompanyCode,
						    @WorkCenterCode,
						    @PlanYearMonth,
							@LineCode,
						    @MaterialCode,
							@MaterialName,
						    @PlanQty,
						    GETDATE(),
						    @pProcessUserID,
						    @ChangeDateTime,
						    @ChangeUserID,
							@Batch
						)

				END ELSE IF @IUD_FLAG = 'UPDATE' BEGIN
                    UPDATE STB_MonthProdPlan
						SET
						    CompanyCode =   ISNULL(@CompanyCode,CompanyCode),
						    WorkCenterCode =   ISNULL(@WorkCenterCode,WorkCenterCode),
						    PlanYearMonth =   ISNULL(@PlanYearMonth,PlanYearMonth),
							LineCode = ISNULL(@LineCode, LineCode),
						    MaterialCode =   ISNULL(@MaterialCode,MaterialCode),
							MaterialName =   ISNULL(@MaterialName,MaterialName),
						    PlanQty =   ISNULL(@PlanQty,PlanQty),
						    CreateDateTime =   ISNULL(@CreateDateTime,CreateDateTime),
						    CreateUserID =   ISNULL(@CreateUserID,CreateUserID),
						    ChangeDateTime = GETDATE(),
						    ChangeUserID = @pProcessUserID,
							Batch =  ISNULL(@Batch,Batch)
						WHERE
						    CompanyCode = @OldCompanyCode AND
						    WorkCenterCode = @OldWorkCenterCode AND
						    PlanYearMonth = @OldPlanYearMonth AND
							LineCode = @OldLineCode AND
						    MaterialCode = @OldMaterialCode  
							 --MaterialName = @OldMaterialName 
                END ELSE IF @IUD_FLAG = 'DELETE' BEGIN
                    DELETE FROM STB_MonthProdPlan
						WHERE
						    CompanyCode = @OldCompanyCode AND
						    WorkCenterCode = @OldWorkCenterCode AND
						    PlanYearMonth = @OldPlanYearMonth AND
							LineCode = @OldLineCode AND
						    MaterialCode = @OldMaterialCode 
							--MaterialName = @OldMaterialName 
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
