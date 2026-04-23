
-- =============================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Create date: 2020-04-10
-- Browsable : true
-- Group : 원가관리
-- Description:	
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_ManufacturingCostByRoute_iud]
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
  DECLARE @OldApplyDate DATE
  DECLARE @OldCompanyCode VARCHAR(20)
  DECLARE @OldWorkCenterCode VARCHAR(20)
  DECLARE @OldMaterialCode VARCHAR(20)
  DECLARE @OldCostTypeCode VARCHAR(20)
  DECLARE @OldIsManual BIT
  DECLARE @OldRouteCode VARCHAR(20)
  DECLARE @ApplyDate DATE
  DECLARE @CompanyCode VARCHAR(20)
  DECLARE @WorkCenterCode VARCHAR(20)
  DECLARE @MaterialCode VARCHAR(20)
  DECLARE @CostTypeCode VARCHAR(20)
  DECLARE @IsManual BIT
  DECLARE @RouteCode VARCHAR(20)
  DECLARE @CostPrice NUMERIC(20,10)
  DECLARE @CreateDateTime DATETIME
  DECLARE @CreateUserID VARCHAR(20)
  DECLARE @ChangeDateTime DATETIME
  DECLARE @ChangeUserID VARCHAR(20)
  DECLARE @IsUsed BIT


	DECLARE @iDoc INT

    EXEC SmartFramework.dbo.usp_GetSerialRule 
			@pTableName = 'STB_ManufacturingCostByRoute',
			@pIsAutoKey = @IsAutoKey OUTPUT,
			@pIsLoopIUD = @IsLoopIUD OUTPUT,
			@pPrefixData = @PrefixString OUTPUT,
			@pSerialLen = @SerialLen OUTPUT
    
    IF @IsAutoKey = 0 AND @IsLoopIUD = 0 BEGIN
   
	    EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
	
	    BEGIN TRY
			-- Process Insert Table
            MERGE STB_ManufacturingCostByRoute AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldApplyDate IS NULL THEN ApplyDate
							    ELSE OldApplyDate
							END AS OldApplyDate,
							CASE
							    WHEN OldCompanyCode IS NULL THEN CompanyCode
							    ELSE OldCompanyCode
							END AS OldCompanyCode,
							CASE
							    WHEN OldWorkCenterCode IS NULL THEN WorkCenterCode
							    ELSE OldWorkCenterCode
							END AS OldWorkCenterCode,
							CASE
							    WHEN OldMaterialCode IS NULL THEN MaterialCode
							    ELSE OldMaterialCode
							END AS OldMaterialCode,
							CASE
							    WHEN OldCostTypeCode IS NULL THEN CostTypeCode
							    ELSE OldCostTypeCode
							END AS OldCostTypeCode,
							CASE
							    WHEN OldIsManual IS NULL THEN IsManual
							    ELSE OldIsManual
							END AS OldIsManual,
							CASE
							    WHEN OldRouteCode IS NULL THEN RouteCode
							    ELSE OldRouteCode
							END AS OldRouteCode,
							ApplyDate,
							CompanyCode,
							WorkCenterCode,
							MaterialCode,
							CostTypeCode,
							IsManual,
							RouteCode,
							CostPrice,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID, 
							IsUsed 
					FROM
							OPENXML(@idoc , @InsertTableName , 2)
							WITH  (
										OldApplyDate DATETIMEOFFSET,
										OldCompanyCode VARCHAR(20),
										OldWorkCenterCode VARCHAR(20),
										OldMaterialCode VARCHAR(20),
										OldCostTypeCode VARCHAR(20),
										OldIsManual BIT,
										OldRouteCode VARCHAR(20),
										ApplyDate DATETIMEOFFSET,
										CompanyCode VARCHAR(20),
										WorkCenterCode VARCHAR(20),
										MaterialCode VARCHAR(20),
										CostTypeCode VARCHAR(20),
										IsManual BIT,
										RouteCode VARCHAR(20),
										CostPrice NUMERIC(20,10),
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20),
										IsUsed BIT
									) 
				) AS SourceTable
			ON
				(
					TargetTable.ApplyDate = SourceTable.ApplyDate AND
					TargetTable.CompanyCode = SourceTable.CompanyCode AND
					TargetTable.WorkCenterCode = SourceTable.WorkCenterCode AND
					TargetTable.MaterialCode = SourceTable.MaterialCode AND
					TargetTable.CostTypeCode = SourceTable.CostTypeCode AND
					TargetTable.IsManual = SourceTable.IsManual AND
					TargetTable.RouteCode = SourceTable.RouteCode
				)

			WHEN MATCHED THEN
				UPDATE SET
					ApplyDate = ISNULL(SourceTable.ApplyDate,TargetTable.ApplyDate),
					CompanyCode = ISNULL(SourceTable.CompanyCode,TargetTable.CompanyCode),
					WorkCenterCode = ISNULL(SourceTable.WorkCenterCode,TargetTable.WorkCenterCode),
					MaterialCode = ISNULL(SourceTable.MaterialCode,TargetTable.MaterialCode),
					CostTypeCode = ISNULL(SourceTable.CostTypeCode,TargetTable.CostTypeCode),
					IsManual = ISNULL(SourceTable.IsManual,TargetTable.IsManual),
					RouteCode = ISNULL(SourceTable.RouteCode,TargetTable.RouteCode),
					CostPrice = ISNULL(SourceTable.CostPrice,TargetTable.CostPrice),
					ChangeDateTime = ISNULL(SourceTable.ChangeDateTime,TargetTable.ChangeDateTime),
					ChangeUserID = ISNULL(SourceTable.ChangeUserID,TargetTable.ChangeUserID),
					IsUsed = ISNULL(SourceTable.IsUsed, TargetTable.IsUsed)
			WHEN NOT MATCHED THEN
				INSERT
					(
						ApplyDate,
						CompanyCode,
						WorkCenterCode,
						MaterialCode,
						CostTypeCode,
						IsManual,
						RouteCode,
						CostPrice,
						CreateDateTime,
						CreateUserID,
						IsUsed
					)
				VALUES
					(
							SourceTable.ApplyDate,
							SourceTable.CompanyCode,
							SourceTable.WorkCenterCode,
							SourceTable.MaterialCode,
							SourceTable.CostTypeCode,
							SourceTable.IsManual,
							SourceTable.RouteCode,
							SourceTable.CostPrice,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID,
							SourceTable.IsUsed
					);


			-- Process Update Table
            MERGE STB_ManufacturingCostByRoute AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldApplyDate IS NULL THEN ApplyDate
							    ELSE OldApplyDate
							END AS OldApplyDate,
							CASE
							    WHEN OldCompanyCode IS NULL THEN CompanyCode
							    ELSE OldCompanyCode
							END AS OldCompanyCode,
							CASE
							    WHEN OldWorkCenterCode IS NULL THEN WorkCenterCode
							    ELSE OldWorkCenterCode
							END AS OldWorkCenterCode,
							CASE
							    WHEN OldMaterialCode IS NULL THEN MaterialCode
							    ELSE OldMaterialCode
							END AS OldMaterialCode,
							CASE
							    WHEN OldCostTypeCode IS NULL THEN CostTypeCode
							    ELSE OldCostTypeCode
							END AS OldCostTypeCode,
							CASE
							    WHEN OldIsManual IS NULL THEN IsManual
							    ELSE OldIsManual
							END AS OldIsManual,
							CASE
							    WHEN OldRouteCode IS NULL THEN RouteCode
							    ELSE OldRouteCode
							END AS OldRouteCode,
							ApplyDate,
							CompanyCode,
							WorkCenterCode,
							MaterialCode,
							CostTypeCode,
							IsManual,
							RouteCode,
							CostPrice,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID,
							IsUsed
					FROM
							OPENXML(@idoc , @UpdateTableName , 2)
							WITH  (
										OldApplyDate DATETIMEOFFSET,
										OldCompanyCode VARCHAR(20),
										OldWorkCenterCode VARCHAR(20),
										OldMaterialCode VARCHAR(20),
										OldCostTypeCode VARCHAR(20),
										OldIsManual BIT,
										OldRouteCode VARCHAR(20),
										ApplyDate DATETIMEOFFSET,
										CompanyCode VARCHAR(20),
										WorkCenterCode VARCHAR(20),
										MaterialCode VARCHAR(20),
										CostTypeCode VARCHAR(20),
										IsManual BIT,
										RouteCode VARCHAR(20),
										CostPrice NUMERIC(20,10),
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20),
										IsUsed BIT
									) 
				) AS SourceTable
			ON
				(
					TargetTable.ApplyDate = SourceTable.OldApplyDate AND
					TargetTable.CompanyCode = SourceTable.OldCompanyCode AND
					TargetTable.WorkCenterCode = SourceTable.OldWorkCenterCode AND
					TargetTable.MaterialCode = SourceTable.OldMaterialCode AND
					TargetTable.CostTypeCode = SourceTable.OldCostTypeCode AND
					TargetTable.IsManual = SourceTable.OldIsManual AND
					TargetTable.RouteCode = SourceTable.OldRouteCode
				)

			WHEN MATCHED THEN
				UPDATE SET
					ApplyDate = ISNULL(SourceTable.ApplyDate,TargetTable.ApplyDate),
					CompanyCode = ISNULL(SourceTable.CompanyCode,TargetTable.CompanyCode),
					WorkCenterCode = ISNULL(SourceTable.WorkCenterCode,TargetTable.WorkCenterCode),
					MaterialCode = ISNULL(SourceTable.MaterialCode,TargetTable.MaterialCode),
					CostTypeCode = ISNULL(SourceTable.CostTypeCode,TargetTable.CostTypeCode),
					IsManual = ISNULL(SourceTable.IsManual,TargetTable.IsManual),
					RouteCode = ISNULL(SourceTable.RouteCode,TargetTable.RouteCode),
					CostPrice = ISNULL(SourceTable.CostPrice,TargetTable.CostPrice),
					ChangeDateTime = ISNULL(SourceTable.ChangeDateTime,TargetTable.ChangeDateTime),
					ChangeUserID = ISNULL(SourceTable.ChangeUserID,TargetTable.ChangeUserID),
					IsUsed = ISNULL(SourceTable.IsUsed,TargetTable.IsUsed)
			WHEN NOT MATCHED THEN
				INSERT
					(
						ApplyDate,
						CompanyCode,
						WorkCenterCode,
						MaterialCode,
						CostTypeCode,
						IsManual,
						RouteCode,
						CostPrice,
						CreateDateTime,
						CreateUserID,
						IsUsed
					)
				VALUES
					(
							SourceTable.ApplyDate,
							SourceTable.CompanyCode,
							SourceTable.WorkCenterCode,
							SourceTable.MaterialCode,
							SourceTable.CostTypeCode,
							SourceTable.IsManual,
							SourceTable.RouteCode,
							SourceTable.CostPrice,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID,
							SourceTable.IsUsed
					);


			-- Process Delete Table
            MERGE STB_ManufacturingCostByRoute AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldApplyDate IS NULL THEN ApplyDate
							    ELSE OldApplyDate
							END AS OldApplyDate,
							CASE
							    WHEN OldCompanyCode IS NULL THEN CompanyCode
							    ELSE OldCompanyCode
							END AS OldCompanyCode,
							CASE
							    WHEN OldWorkCenterCode IS NULL THEN WorkCenterCode
							    ELSE OldWorkCenterCode
							END AS OldWorkCenterCode,
							CASE
							    WHEN OldMaterialCode IS NULL THEN MaterialCode
							    ELSE OldMaterialCode
							END AS OldMaterialCode,
							CASE
							    WHEN OldCostTypeCode IS NULL THEN CostTypeCode
							    ELSE OldCostTypeCode
							END AS OldCostTypeCode,
							CASE
							    WHEN OldIsManual IS NULL THEN IsManual
							    ELSE OldIsManual
							END AS OldIsManual,
							CASE
							    WHEN OldRouteCode IS NULL THEN RouteCode
							    ELSE OldRouteCode
							END AS OldRouteCode,
							ApplyDate,
							CompanyCode,
							WorkCenterCode,
							MaterialCode,
							CostTypeCode,
							IsManual,
							RouteCode,
							CostPrice,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID,
							IsUsed
					FROM
							OPENXML(@idoc , @DeleteTableName , 2)
							WITH  (
										OldApplyDate DATETIMEOFFSET,
										OldCompanyCode VARCHAR(20),
										OldWorkCenterCode VARCHAR(20),
										OldMaterialCode VARCHAR(20),
										OldCostTypeCode VARCHAR(20),
										OldIsManual BIT,
										OldRouteCode VARCHAR(20),
										ApplyDate DATETIMEOFFSET,
										CompanyCode VARCHAR(20),
										WorkCenterCode VARCHAR(20),
										MaterialCode VARCHAR(20),
										CostTypeCode VARCHAR(20),
										IsManual BIT,
										RouteCode VARCHAR(20),
										CostPrice NUMERIC(20,10),
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20),
										IsUsed BIT
									) 
				) AS SourceTable
			ON
				(
					TargetTable.ApplyDate = SourceTable.ApplyDate AND
					TargetTable.CompanyCode = SourceTable.CompanyCode AND
					TargetTable.WorkCenterCode = SourceTable.WorkCenterCode AND
					TargetTable.MaterialCode = SourceTable.MaterialCode AND
					TargetTable.CostTypeCode = SourceTable.CostTypeCode AND
					TargetTable.IsManual = SourceTable.IsManual AND
					TargetTable.RouteCode = SourceTable.RouteCode
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
									OldApplyDate,
									OldCompanyCode,
									OldWorkCenterCode,
									OldMaterialCode,
									OldCostTypeCode,
									OldIsManual,
									OldRouteCode,
									ApplyDate,
									CompanyCode,
									WorkCenterCode,
									MaterialCode,
									CostTypeCode,
									IsManual,
									RouteCode,
									CostPrice,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID,
									IsUsed
							FROM
									OPENXML(@idoc , @InsertTableName , 2)
							        WITH  (
											 OldApplyDate DATETIMEOFFSET,
											 OldCompanyCode VARCHAR(20),
											 OldWorkCenterCode VARCHAR(20),
											 OldMaterialCode VARCHAR(20),
											 OldCostTypeCode VARCHAR(20),
											 OldIsManual BIT,
											 OldRouteCode VARCHAR(20),
											 ApplyDate DATETIMEOFFSET,
											 CompanyCode VARCHAR(20),
											 WorkCenterCode VARCHAR(20),
											 MaterialCode VARCHAR(20),
											 CostTypeCode VARCHAR(20),
											 IsManual BIT,
											 RouteCode VARCHAR(20),
											 CostPrice NUMERIC(20,10),
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20),
											 IsUsed BIT
											)
							UNION ALL
							SELECT
									'UPDATE' AS IUD_FLAG,
									CASE 
										WHEN OldApplyDate IS NULL THEN ApplyDate
										ELSE OldApplyDate
									END AS OldApplyDate,
									CASE 
										WHEN OldCompanyCode IS NULL THEN CompanyCode
										ELSE OldCompanyCode
									END AS OldCompanyCode,
									CASE 
										WHEN OldWorkCenterCode IS NULL THEN WorkCenterCode
										ELSE OldWorkCenterCode
									END AS OldWorkCenterCode,
									CASE 
										WHEN OldMaterialCode IS NULL THEN MaterialCode
										ELSE OldMaterialCode
									END AS OldMaterialCode,
									CASE 
										WHEN OldCostTypeCode IS NULL THEN CostTypeCode
										ELSE OldCostTypeCode
									END AS OldCostTypeCode,
									CASE 
										WHEN OldIsManual IS NULL THEN IsManual
										ELSE OldIsManual
									END AS OldIsManual,
									CASE 
										WHEN OldRouteCode IS NULL THEN RouteCode
										ELSE OldRouteCode
									END AS OldRouteCode,
									ApplyDate,
									CompanyCode,
									WorkCenterCode,
									MaterialCode,
									CostTypeCode,
									IsManual,
									RouteCode,
									CostPrice,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID,
									IsUsed
							FROM
									OPENXML(@idoc , @UpdateTableName , 2)
							        WITH  (
											 OldApplyDate DATETIMEOFFSET,
											 OldCompanyCode VARCHAR(20),
											 OldWorkCenterCode VARCHAR(20),
											 OldMaterialCode VARCHAR(20),
											 OldCostTypeCode VARCHAR(20),
											 OldIsManual BIT,
											 OldRouteCode VARCHAR(20),
											 ApplyDate DATETIMEOFFSET,
											 CompanyCode VARCHAR(20),
											 WorkCenterCode VARCHAR(20),
											 MaterialCode VARCHAR(20),
											 CostTypeCode VARCHAR(20),
											 IsManual BIT,
											 RouteCode VARCHAR(20),
											 CostPrice NUMERIC(20,10),
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20),
											 IsUsed BIT
											)
							UNION ALL
							SELECT
									'DELETE' AS IUD_FLAG,
									CASE 
										WHEN OldApplyDate IS NULL THEN ApplyDate
										ELSE OldApplyDate
									END AS OldApplyDate,
									CASE 
										WHEN OldCompanyCode IS NULL THEN CompanyCode
										ELSE OldCompanyCode
									END AS OldCompanyCode,
									CASE 
										WHEN OldWorkCenterCode IS NULL THEN WorkCenterCode
										ELSE OldWorkCenterCode
									END AS OldWorkCenterCode,
									CASE 
										WHEN OldMaterialCode IS NULL THEN MaterialCode
										ELSE OldMaterialCode
									END AS OldMaterialCode,
									CASE 
										WHEN OldCostTypeCode IS NULL THEN CostTypeCode
										ELSE OldCostTypeCode
									END AS OldCostTypeCode,
									CASE 
										WHEN OldIsManual IS NULL THEN IsManual
										ELSE OldIsManual
									END AS OldIsManual,
									CASE 
										WHEN OldRouteCode IS NULL THEN RouteCode
										ELSE OldRouteCode
									END AS OldRouteCode,
									ApplyDate,
									CompanyCode,
									WorkCenterCode,
									MaterialCode,
									CostTypeCode,
									IsManual,
									RouteCode,
									CostPrice,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID,
									IsUsed
							FROM
									OPENXML(@idoc , @DeleteTableName , 2)
							        WITH  (
											 OldApplyDate DATETIMEOFFSET,
											 OldCompanyCode VARCHAR(20),
											 OldWorkCenterCode VARCHAR(20),
											 OldMaterialCode VARCHAR(20),
											 OldCostTypeCode VARCHAR(20),
											 OldIsManual BIT,
											 OldRouteCode VARCHAR(20),
											 ApplyDate DATETIMEOFFSET,
											 CompanyCode VARCHAR(20),
											 WorkCenterCode VARCHAR(20),
											 MaterialCode VARCHAR(20),
											 CostTypeCode VARCHAR(20),
											 IsManual BIT,
											 RouteCode VARCHAR(20),
											 CostPrice NUMERIC(20,10),
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20),
											 IsUsed BIT
											) 


            OPEN SourceData

            WHILE 1 = 1 BEGIN
                FETCH NEXT FROM SourceData INTO
								 @IUD_FLAG,
								 @OldApplyDate,
								 @OldCompanyCode,
								 @OldWorkCenterCode,
								 @OldMaterialCode,
								 @OldCostTypeCode,
								 @OldIsManual,
								 @OldRouteCode,
								 @ApplyDate,
								 @CompanyCode,
								 @WorkCenterCode,
								 @MaterialCode,
								 @CostTypeCode,
								 @IsManual,
								 @RouteCode,
								 @CostPrice,
								 @CreateDateTime,
								 @CreateUserID,
								 @ChangeDateTime,
								 @ChangeUserID,
								 @IsUsed


                IF @@FETCH_STATUS <> 0 BEGIN
					BREAK
				END
                IF @IUD_FLAG = 'INSERT' BEGIN

                    IF EXISTS (SELECT 1 FROM STB_ManufacturingCostByRoute WHERE ApplyDate = @ApplyDate AND CompanyCode = @CompanyCode AND WorkCenterCode = @WorkCenterCode AND MaterialCode = @MaterialCode AND CostTypeCode = @CostTypeCode AND IsManual = @IsManual AND RouteCode = @RouteCode) BEGIN
						--RAISERROR('Duplicate Data : KeyField = %s', 16, 1, CONVERT(VARCHAR(20), @ApplyDate, 121))
						PRINT '1111'
					END

                    IF @IsAutoKey = 1 BEGIN
                        EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_ManufacturingCostByRoute',@ApplyDate OUTPUT
                    END

                    INSERT INTO STB_ManufacturingCostByRoute
						(
						    ApplyDate,
						    CompanyCode,
						    WorkCenterCode,
						    MaterialCode,
						    CostTypeCode,
						    IsManual,
						    RouteCode,
						    CostPrice,
						    CreateDateTime,
						    CreateUserID,
						    ChangeDateTime,
						    ChangeUserID,
							IsUsed
						)
						VALUES
						(
						    @ApplyDate,
						    @CompanyCode,
						    @WorkCenterCode,
						    @MaterialCode,
						    @CostTypeCode,
						    @IsManual,
						    @RouteCode,
						    @CostPrice,
						    GETDATE(),
						    @pProcessUserID,
						    @ChangeDateTime,
						    @ChangeUserID,
							@IsUsed
						)

				END ELSE IF @IUD_FLAG = 'UPDATE' BEGIN
                    PRINT '2222'
					UPDATE STB_ManufacturingCostByRoute
						SET
						    ApplyDate =   ISNULL(@ApplyDate,ApplyDate),
						    CompanyCode =   ISNULL(@CompanyCode,CompanyCode),
						    WorkCenterCode =   ISNULL(@WorkCenterCode,WorkCenterCode),
						    MaterialCode =   ISNULL(@MaterialCode,MaterialCode),
						    CostTypeCode =   ISNULL(@CostTypeCode,CostTypeCode),
						    IsManual =   ISNULL(@IsManual,IsManual),
						    RouteCode =   ISNULL(@RouteCode,RouteCode),
						    CostPrice =   ISNULL(@CostPrice,CostPrice),
						    CreateDateTime =   ISNULL(@CreateDateTime,CreateDateTime),
						    CreateUserID =   ISNULL(@CreateUserID,CreateUserID),
						    ChangeDateTime = GETDATE(),
						    ChangeUserID = @pProcessUserID,
							IsUsed =   ISNULL(@IsUsed,IsUsed)
						WHERE
						    ApplyDate = @OldApplyDate AND
						    CompanyCode = @OldCompanyCode AND
						    WorkCenterCode = @OldWorkCenterCode AND
						    MaterialCode = @OldMaterialCode AND
						    CostTypeCode = @OldCostTypeCode AND
						    IsManual = @OldIsManual AND
						    RouteCode = @OldRouteCode
                END ELSE IF @IUD_FLAG = 'DELETE' BEGIN
                    DELETE FROM STB_ManufacturingCostByRoute
						WHERE
						    ApplyDate = @OldApplyDate AND
						    CompanyCode = @OldCompanyCode AND
						    WorkCenterCode = @OldWorkCenterCode AND
						    MaterialCode = @OldMaterialCode AND
						    CostTypeCode = @OldCostTypeCode AND
						    IsManual = @OldIsManual AND
						    RouteCode = @OldRouteCode
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
