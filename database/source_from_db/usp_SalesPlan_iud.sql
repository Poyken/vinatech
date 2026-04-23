
-- =============================================
-- Author:	    Kim Han Young(hykim@awoo.co.kr)
-- Create date: 2018-07-23
-- Browsable : true
-- Group : 영업관리
-- Description:	판매계획 IUD
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_SalesPlan_iud]
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
  DECLARE @OldSalePlanCode BIGINT
  DECLARE @SalePlanCode BIGINT
  DECLARE @CompanyCode VARCHAR(20)
  DECLARE @ProductGroupCode VARCHAR(20)
  DECLARE @ModelCode VARCHAR(50)
  DECLARE @PlanYearMonth VARCHAR(7)
  DECLARE @CustomerCode VARCHAR(20)
  DECLARE @PlanType VARCHAR(20)
  DECLARE @PlanQty NUMERIC(20,4)
  DECLARE @PlanBaiscPrice NUMERIC(20,4)
  DECLARE @CreateDateTime DATETIME
  DECLARE @CreateUserID VARCHAR(20)
  DECLARE @ChangeDateTime DATETIME
  DECLARE @ChangeUserID VARCHAR(20)


	DECLARE @iDoc INT

    EXEC SmartFramework.dbo.usp_GetSerialRule 
			@pTableName = 'STB_SalesPlan',
			@pIsAutoKey = @IsAutoKey OUTPUT,
			@pIsLoopIUD = @IsLoopIUD OUTPUT,
			@pPrefixData = @PrefixString OUTPUT,
			@pSerialLen = @SerialLen OUTPUT
    
    IF @IsAutoKey = 0 AND @IsLoopIUD = 0 BEGIN
   
	    EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
	
	    BEGIN TRY
			-- Process Insert Table
            MERGE STB_SalesPlan AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldSalePlanCode IS NULL THEN SalePlanCode
							    ELSE OldSalePlanCode
							END AS OldSalePlanCode,
							SalePlanCode,
							CompanyCode,
							ProductGroupCode,
							ModelCode,
							PlanYearMonth,
							CustomerCode,
							PlanType,
							PlanQty,
							PlanBaiscPrice,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @InsertTableName , 2)
							WITH  (
										OldSalePlanCode BIGINT,
										SalePlanCode BIGINT,
										CompanyCode VARCHAR(20),
										ProductGroupCode VARCHAR(20),
										ModelCode VARCHAR(50),
										PlanYearMonth VARCHAR(7),
										CustomerCode VARCHAR(20),
										PlanType VARCHAR(20),
										PlanQty NUMERIC(20,4),
										PlanBaiscPrice NUMERIC(20,4),
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.SalePlanCode = SourceTable.SalePlanCode
				)

			WHEN MATCHED THEN
				UPDATE SET
					CompanyCode = ISNULL(SourceTable.CompanyCode,TargetTable.CompanyCode),
					ProductGroupCode = ISNULL(SourceTable.ProductGroupCode,TargetTable.ProductGroupCode),
					ModelCode = ISNULL(SourceTable.ModelCode,TargetTable.ModelCode),
					PlanYearMonth = ISNULL(SourceTable.PlanYearMonth,TargetTable.PlanYearMonth),
					CustomerCode = ISNULL(SourceTable.CustomerCode,TargetTable.CustomerCode),
					PlanType = ISNULL(SourceTable.PlanType,TargetTable.PlanType),
					PlanQty = ISNULL(SourceTable.PlanQty,TargetTable.PlanQty),
					PlanBaiscPrice = ISNULL(SourceTable.PlanBaiscPrice,TargetTable.PlanBaiscPrice),
					ChangeDateTime = ISNULL(SourceTable.ChangeDateTime,TargetTable.ChangeDateTime),
					ChangeUserID = ISNULL(SourceTable.ChangeUserID,TargetTable.ChangeUserID)
			WHEN NOT MATCHED THEN
				INSERT
					(
						CompanyCode,
						ProductGroupCode,
						ModelCode,
						PlanYearMonth,
						CustomerCode,
						PlanType,
						PlanQty,
						PlanBaiscPrice,
						CreateDateTime,
						CreateUserID
					)
				VALUES
					(
							SourceTable.CompanyCode,
							SourceTable.ProductGroupCode,
							SourceTable.ModelCode,
							SourceTable.PlanYearMonth,
							SourceTable.CustomerCode,
							SourceTable.PlanType,
							SourceTable.PlanQty,
							SourceTable.PlanBaiscPrice,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID
					);


			-- Process Update Table
            MERGE STB_SalesPlan AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldSalePlanCode IS NULL THEN SalePlanCode
							    ELSE OldSalePlanCode
							END AS OldSalePlanCode,
							SalePlanCode,
							CompanyCode,
							ProductGroupCode,
							ModelCode,
							PlanYearMonth,
							CustomerCode,
							PlanType,
							PlanQty,
							PlanBaiscPrice,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @UpdateTableName , 2)
							WITH  (
										OldSalePlanCode BIGINT,
										SalePlanCode BIGINT,
										CompanyCode VARCHAR(20),
										ProductGroupCode VARCHAR(20),
										ModelCode VARCHAR(50),
										PlanYearMonth VARCHAR(7),
										CustomerCode VARCHAR(20),
										PlanType VARCHAR(20),
										PlanQty NUMERIC(20,4),
										PlanBaiscPrice NUMERIC(20,4),
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.SalePlanCode = SourceTable.OldSalePlanCode
				)

			WHEN MATCHED THEN
				UPDATE SET
					CompanyCode = ISNULL(SourceTable.CompanyCode,TargetTable.CompanyCode),
					ProductGroupCode = ISNULL(SourceTable.ProductGroupCode,TargetTable.ProductGroupCode),
					ModelCode = ISNULL(SourceTable.ModelCode,TargetTable.ModelCode),
					PlanYearMonth = ISNULL(SourceTable.PlanYearMonth,TargetTable.PlanYearMonth),
					CustomerCode = ISNULL(SourceTable.CustomerCode,TargetTable.CustomerCode),
					PlanType = ISNULL(SourceTable.PlanType,TargetTable.PlanType),
					PlanQty = ISNULL(SourceTable.PlanQty,TargetTable.PlanQty),
					PlanBaiscPrice = ISNULL(SourceTable.PlanBaiscPrice,TargetTable.PlanBaiscPrice),
					ChangeDateTime = ISNULL(SourceTable.ChangeDateTime,TargetTable.ChangeDateTime),
					ChangeUserID = ISNULL(SourceTable.ChangeUserID,TargetTable.ChangeUserID)
			WHEN NOT MATCHED THEN
				INSERT
					(
						CompanyCode,
						ProductGroupCode,
						ModelCode,
						PlanYearMonth,
						CustomerCode,
						PlanType,
						PlanQty,
						PlanBaiscPrice,
						CreateDateTime,
						CreateUserID
					)
				VALUES
					(
							SourceTable.CompanyCode,
							SourceTable.ProductGroupCode,
							SourceTable.ModelCode,
							SourceTable.PlanYearMonth,
							SourceTable.CustomerCode,
							SourceTable.PlanType,
							SourceTable.PlanQty,
							SourceTable.PlanBaiscPrice,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID
					);


			-- Process Delete Table
            MERGE STB_SalesPlan AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldSalePlanCode IS NULL THEN SalePlanCode
							    ELSE OldSalePlanCode
							END AS OldSalePlanCode,
							SalePlanCode,
							CompanyCode,
							ProductGroupCode,
							ModelCode,
							PlanYearMonth,
							CustomerCode,
							PlanType,
							PlanQty,
							PlanBaiscPrice,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @DeleteTableName , 2)
							WITH  (
										OldSalePlanCode BIGINT,
										SalePlanCode BIGINT,
										CompanyCode VARCHAR(20),
										ProductGroupCode VARCHAR(20),
										ModelCode VARCHAR(50),
										PlanYearMonth VARCHAR(7),
										CustomerCode VARCHAR(20),
										PlanType VARCHAR(20),
										PlanQty NUMERIC(20,4),
										PlanBaiscPrice NUMERIC(20,4),
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.SalePlanCode = SourceTable.SalePlanCode
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
									OldSalePlanCode,
									SalePlanCode,
									CompanyCode,
									ProductGroupCode,
									ModelCode,
									PlanYearMonth,
									CustomerCode,
									PlanType,
									PlanQty,
									PlanBaiscPrice,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID
							FROM
									OPENXML(@idoc , @InsertTableName , 2)
							        WITH  (
											 OldSalePlanCode BIGINT,
											 SalePlanCode BIGINT,
											 CompanyCode VARCHAR(20),
											 ProductGroupCode VARCHAR(20),
											 ModelCode VARCHAR(50),
											 PlanYearMonth VARCHAR(7),
											 CustomerCode VARCHAR(20),
											 PlanType VARCHAR(20),
											 PlanQty NUMERIC(20,4),
											 PlanBaiscPrice NUMERIC(20,4),
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											)
							UNION ALL
							SELECT
									'UPDATE' AS IUD_FLAG,
									CASE 
										WHEN OldSalePlanCode IS NULL THEN SalePlanCode
										ELSE OldSalePlanCode
									END AS OldSalePlanCode,
									SalePlanCode,
									CompanyCode,
									ProductGroupCode,
									ModelCode,
									PlanYearMonth,
									CustomerCode,
									PlanType,
									PlanQty,
									PlanBaiscPrice,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID
							FROM
									OPENXML(@idoc , @UpdateTableName , 2)
							        WITH  (
											 OldSalePlanCode BIGINT,
											 SalePlanCode BIGINT,
											 CompanyCode VARCHAR(20),
											 ProductGroupCode VARCHAR(20),
											 ModelCode VARCHAR(50),
											 PlanYearMonth VARCHAR(7),
											 CustomerCode VARCHAR(20),
											 PlanType VARCHAR(20),
											 PlanQty NUMERIC(20,4),
											 PlanBaiscPrice NUMERIC(20,4),
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											)
							UNION ALL
							SELECT
									'DELETE' AS IUD_FLAG,
									CASE 
										WHEN OldSalePlanCode IS NULL THEN SalePlanCode
										ELSE OldSalePlanCode
									END AS OldSalePlanCode,
									SalePlanCode,
									CompanyCode,
									ProductGroupCode,
									ModelCode,
									PlanYearMonth,
									CustomerCode,
									PlanType,
									PlanQty,
									PlanBaiscPrice,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID
							FROM
									OPENXML(@idoc , @DeleteTableName , 2)
							        WITH  (
											 OldSalePlanCode BIGINT,
											 SalePlanCode BIGINT,
											 CompanyCode VARCHAR(20),
											 ProductGroupCode VARCHAR(20),
											 ModelCode VARCHAR(50),
											 PlanYearMonth VARCHAR(7),
											 CustomerCode VARCHAR(20),
											 PlanType VARCHAR(20),
											 PlanQty NUMERIC(20,4),
											 PlanBaiscPrice NUMERIC(20,4),
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											) 


            OPEN SourceData

            WHILE 1 = 1 BEGIN
                FETCH NEXT FROM SourceData INTO
								 @IUD_FLAG,
								 @OldSalePlanCode,
								 @SalePlanCode,
								 @CompanyCode,
								 @ProductGroupCode,
								 @ModelCode,
								 @PlanYearMonth,
								 @CustomerCode,
								 @PlanType,
								 @PlanQty,
								 @PlanBaiscPrice,
								 @CreateDateTime,
								 @CreateUserID,
								 @ChangeDateTime,
								 @ChangeUserID


                IF @@FETCH_STATUS <> 0 BEGIN
					BREAK
				END
                IF @IUD_FLAG = 'INSERT' BEGIN

                    IF EXISTS (SELECT 1 FROM STB_SalesPlan WHERE SalePlanCode = @SalePlanCode) BEGIN
						RAISERROR('Duplicate Data : KeyField = %s', 16, 1, @SalePlanCode)
					END

                    IF @IsAutoKey = 1 BEGIN
                        EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_SalesPlan',@SalePlanCode OUTPUT
                    END

                    INSERT INTO STB_SalesPlan
						(
						    CompanyCode,
						    ProductGroupCode,
						    ModelCode,
						    PlanYearMonth,
						    CustomerCode,
						    PlanType,
						    PlanQty,
						    PlanBaiscPrice,
						    CreateDateTime,
						    CreateUserID,
						    ChangeDateTime,
						    ChangeUserID
						)
						VALUES
						(
						    @CompanyCode,
						    @ProductGroupCode,
						    @ModelCode,
						    @PlanYearMonth,
						    @CustomerCode,
						    @PlanType,
						    @PlanQty,
						    @PlanBaiscPrice,
						    GETDATE(),
						    @pProcessUserID,
						    @ChangeDateTime,
						    @ChangeUserID
						)

				END ELSE IF @IUD_FLAG = 'UPDATE' BEGIN
                    UPDATE STB_SalesPlan
						SET
						    CompanyCode =   ISNULL(@CompanyCode,CompanyCode),
						    ProductGroupCode =   ISNULL(@ProductGroupCode,ProductGroupCode),
						    ModelCode =   ISNULL(@ModelCode,ModelCode),
						    PlanYearMonth =   ISNULL(@PlanYearMonth,PlanYearMonth),
						    CustomerCode =   ISNULL(@CustomerCode,CustomerCode),
						    PlanType =   ISNULL(@PlanType,PlanType),
						    PlanQty =   ISNULL(@PlanQty,PlanQty),
						    PlanBaiscPrice =   ISNULL(@PlanBaiscPrice,PlanBaiscPrice),
						    CreateDateTime =   ISNULL(@CreateDateTime,CreateDateTime),
						    CreateUserID =   ISNULL(@CreateUserID,CreateUserID),
						    ChangeDateTime = GETDATE(),
						    ChangeUserID = @pProcessUserID
						WHERE
						    SalePlanCode = @OldSalePlanCode
                END ELSE IF @IUD_FLAG = 'DELETE' BEGIN
                    DELETE FROM STB_SalesPlan
						WHERE
						    SalePlanCode = @OldSalePlanCode
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
