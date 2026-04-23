
-- =============================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Create date: 2019-11-12
-- Browsable : true
-- Group : 자재관리
-- Description:	
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_SalesMonthlyPlan_iud]
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
  DECLARE @OldSalesIndex BIGINT
  DECLARE @SalesIndex BIGINT
  DECLARE @Region VARCHAR(30)
  DECLARE @SizeW INT
  DECLARE @SizeH INT
  DECLARE @Volt NUMERIC(3,1)
  DECLARE @Farad NUMERIC(20,1)
  DECLARE @BaseMonth VARCHAR(7)
  DECLARE @PlanQty INT


	DECLARE @iDoc INT

    EXEC SmartFramework.dbo.usp_GetSerialRule 
			@pTableName = 'STB_SalesMonthlyPlan',
			@pIsAutoKey = @IsAutoKey OUTPUT,
			@pIsLoopIUD = @IsLoopIUD OUTPUT,
			@pPrefixData = @PrefixString OUTPUT,
			@pSerialLen = @SerialLen OUTPUT
    
    IF @IsAutoKey = 0 AND @IsLoopIUD = 0 BEGIN
   
	    EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
	
	    BEGIN TRY
			-- Process Insert Table
            MERGE STB_SalesMonthlyPlan AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldSalesIndex IS NULL THEN SalesIndex
							    ELSE OldSalesIndex
							END AS OldSalesIndex,
							SalesIndex,
							Region,
							SizeW,
							SizeH,
							Volt,
							Farad,
							BaseMonth,
							PlanQty
					FROM
							OPENXML(@idoc , @InsertTableName , 2)
							WITH  (
										OldSalesIndex BIGINT,
										SalesIndex BIGINT,
										Region VARCHAR(30),
										SizeW INT,
										SizeH INT,
										Volt NUMERIC(3,1),
										Farad NUMERIC(20,1),
										BaseMonth VARCHAR(7),
										PlanQty INT
									) 
				) AS SourceTable
			ON
				(
					TargetTable.SalesIndex = SourceTable.SalesIndex
				)

			WHEN MATCHED THEN
				UPDATE SET
					Region = ISNULL(SourceTable.Region,TargetTable.Region),
					SizeW = ISNULL(SourceTable.SizeW,TargetTable.SizeW),
					SizeH = ISNULL(SourceTable.SizeH,TargetTable.SizeH),
					Volt = ISNULL(SourceTable.Volt,TargetTable.Volt),
					Farad = ISNULL(SourceTable.Farad,TargetTable.Farad),
					BaseMonth = ISNULL(SourceTable.BaseMonth,TargetTable.BaseMonth),
					PlanQty = ISNULL(SourceTable.PlanQty,TargetTable.PlanQty)
			WHEN NOT MATCHED THEN
				INSERT
					(
						Region,
						SizeW,
						SizeH,
						Volt,
						Farad,
						BaseMonth,
						PlanQty
					)
				VALUES
					(
							SourceTable.Region,
							SourceTable.SizeW,
							SourceTable.SizeH,
							SourceTable.Volt,
							SourceTable.Farad,
							SourceTable.BaseMonth,
							SourceTable.PlanQty
					);


			-- Process Update Table
            MERGE STB_SalesMonthlyPlan AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldSalesIndex IS NULL THEN SalesIndex
							    ELSE OldSalesIndex
							END AS OldSalesIndex,
							SalesIndex,
							Region,
							SizeW,
							SizeH,
							Volt,
							Farad,
							BaseMonth,
							PlanQty
					FROM
							OPENXML(@idoc , @UpdateTableName , 2)
							WITH  (
										OldSalesIndex BIGINT,
										SalesIndex BIGINT,
										Region VARCHAR(30),
										SizeW INT,
										SizeH INT,
										Volt NUMERIC(3,1),
										Farad NUMERIC(20,1),
										BaseMonth VARCHAR(7),
										PlanQty INT
									) 
				) AS SourceTable
			ON
				(
					TargetTable.SalesIndex = SourceTable.OldSalesIndex
				)

			WHEN MATCHED THEN
				UPDATE SET
					Region = ISNULL(SourceTable.Region,TargetTable.Region),
					SizeW = ISNULL(SourceTable.SizeW,TargetTable.SizeW),
					SizeH = ISNULL(SourceTable.SizeH,TargetTable.SizeH),
					Volt = ISNULL(SourceTable.Volt,TargetTable.Volt),
					Farad = ISNULL(SourceTable.Farad,TargetTable.Farad),
					BaseMonth = ISNULL(SourceTable.BaseMonth,TargetTable.BaseMonth),
					PlanQty = ISNULL(SourceTable.PlanQty,TargetTable.PlanQty)
			WHEN NOT MATCHED THEN
				INSERT
					(
						Region,
						SizeW,
						SizeH,
						Volt,
						Farad,
						BaseMonth,
						PlanQty
					)
				VALUES
					(
							SourceTable.Region,
							SourceTable.SizeW,
							SourceTable.SizeH,
							SourceTable.Volt,
							SourceTable.Farad,
							SourceTable.BaseMonth,
							SourceTable.PlanQty
					);


			-- Process Delete Table
            MERGE STB_SalesMonthlyPlan AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldSalesIndex IS NULL THEN SalesIndex
							    ELSE OldSalesIndex
							END AS OldSalesIndex,
							SalesIndex,
							Region,
							SizeW,
							SizeH,
							Volt,
							Farad,
							BaseMonth,
							PlanQty
					FROM
							OPENXML(@idoc , @DeleteTableName , 2)
							WITH  (
										OldSalesIndex BIGINT,
										SalesIndex BIGINT,
										Region VARCHAR(30),
										SizeW INT,
										SizeH INT,
										Volt NUMERIC(3,1),
										Farad NUMERIC(20,1),
										BaseMonth VARCHAR(7),
										PlanQty INT
									) 
				) AS SourceTable
			ON
				(
					TargetTable.SalesIndex = SourceTable.SalesIndex
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
									OldSalesIndex,
									SalesIndex,
									Region,
									SizeW,
									SizeH,
									Volt,
									Farad,
									BaseMonth,
									PlanQty
							FROM
									OPENXML(@idoc , @InsertTableName , 2)
							        WITH  (
											 OldSalesIndex BIGINT,
											 SalesIndex BIGINT,
											 Region VARCHAR(30),
											 SizeW INT,
											 SizeH INT,
											 Volt NUMERIC(3,1),
											 Farad NUMERIC(20,1),
											 BaseMonth VARCHAR(7),
											 PlanQty INT
											)
							UNION ALL
							SELECT
									'UPDATE' AS IUD_FLAG,
									CASE 
										WHEN OldSalesIndex IS NULL THEN SalesIndex
										ELSE OldSalesIndex
									END AS OldSalesIndex,
									SalesIndex,
									Region,
									SizeW,
									SizeH,
									Volt,
									Farad,
									BaseMonth,
									PlanQty
							FROM
									OPENXML(@idoc , @UpdateTableName , 2)
							        WITH  (
											 OldSalesIndex BIGINT,
											 SalesIndex BIGINT,
											 Region VARCHAR(30),
											 SizeW INT,
											 SizeH INT,
											 Volt NUMERIC(3,1),
											 Farad NUMERIC(20,1),
											 BaseMonth VARCHAR(7),
											 PlanQty INT
											)
							UNION ALL
							SELECT
									'DELETE' AS IUD_FLAG,
									CASE 
										WHEN OldSalesIndex IS NULL THEN SalesIndex
										ELSE OldSalesIndex
									END AS OldSalesIndex,
									SalesIndex,
									Region,
									SizeW,
									SizeH,
									Volt,
									Farad,
									BaseMonth,
									PlanQty
							FROM
									OPENXML(@idoc , @DeleteTableName , 2)
							        WITH  (
											 OldSalesIndex BIGINT,
											 SalesIndex BIGINT,
											 Region VARCHAR(30),
											 SizeW INT,
											 SizeH INT,
											 Volt NUMERIC(3,1),
											 Farad NUMERIC(20,1),
											 BaseMonth VARCHAR(7),
											 PlanQty INT
											) 


            OPEN SourceData

            WHILE 1 = 1 BEGIN
                FETCH NEXT FROM SourceData INTO
								 @IUD_FLAG,
								 @OldSalesIndex,
								 @SalesIndex,
								 @Region,
								 @SizeW,
								 @SizeH,
								 @Volt,
								 @Farad,
								 @BaseMonth,
								 @PlanQty


                IF @@FETCH_STATUS <> 0 BEGIN
					BREAK
				END
                IF @IUD_FLAG = 'INSERT' BEGIN

                    IF EXISTS (SELECT 1 FROM STB_SalesMonthlyPlan WHERE SalesIndex = @SalesIndex) BEGIN
						RAISERROR('Duplicate Data : KeyField = %s', 16, 1, @SalesIndex)
					END

                    IF @IsAutoKey = 1 BEGIN
                        EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_SalesMonthlyPlan',@SalesIndex OUTPUT
                    END

                    INSERT INTO STB_SalesMonthlyPlan
						(
						    Region,
						    SizeW,
						    SizeH,
						    Volt,
						    Farad,
						    BaseMonth,
						    PlanQty
						)
						VALUES
						(
						    @Region,
						    @SizeW,
						    @SizeH,
						    @Volt,
						    @Farad,
						    @BaseMonth,
						    @PlanQty
						)

				END ELSE IF @IUD_FLAG = 'UPDATE' BEGIN
                    UPDATE STB_SalesMonthlyPlan
						SET
						    Region =   ISNULL(@Region,Region),
						    SizeW =   ISNULL(@SizeW,SizeW),
						    SizeH =   ISNULL(@SizeH,SizeH),
						    Volt =   ISNULL(@Volt,Volt),
						    Farad =   ISNULL(@Farad,Farad),
						    BaseMonth =   ISNULL(@BaseMonth,BaseMonth),
						    PlanQty =   ISNULL(@PlanQty,PlanQty)
						WHERE
						    SalesIndex = @OldSalesIndex
                END ELSE IF @IUD_FLAG = 'DELETE' BEGIN
                    DELETE FROM STB_SalesMonthlyPlan
						WHERE
						    SalesIndex = @OldSalesIndex
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
