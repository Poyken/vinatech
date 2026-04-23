
-- =============================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Create date: 2021-11-24
-- Browsable : true
-- Group : 생산관리
-- Description:	
-- Modified:
-- =============================================
CREATE PROCEDURE dbo.usp_ElectrodeWastePriceInfo_iud
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
  DECLARE @OldRouteCode VARCHAR(20)
  DECLARE @OldElectrodeClassCode VARCHAR(20)
  DECLARE @OldElectrodeThickness INT
  DECLARE @OldCurrentCollectorClassCode VARCHAR(20)
  DECLARE @OldDefectCode VARCHAR(20)
  DECLARE @OldCompanyCode VARCHAR(20)
  DECLARE @OldWorkCenterCode VARCHAR(20)
  DECLARE @RouteCode VARCHAR(20)
  DECLARE @ElectrodeClassCode VARCHAR(20)
  DECLARE @ElectrodeThickness INT
  DECLARE @CurrentCollectorClassCode VARCHAR(20)
  DECLARE @DefectCode VARCHAR(20)
  DECLARE @DefectUnitPrice NUMERIC(20,10)
  DECLARE @CreateDateTime DATETIME
  DECLARE @CreateUserID VARCHAR(20)
  DECLARE @ChangeDateTime DATETIME
  DECLARE @ChangeUserID VARCHAR(20)
  DECLARE @CompanyCode VARCHAR(20)
  DECLARE @WorkCenterCode VARCHAR(20)


	DECLARE @iDoc INT

    EXEC usp_GetSerialRule 
			@pTableName = 'STB_ElectrodeWastePriceNew',
			@pIsAutoKey = @IsAutoKey OUTPUT,
			@pIsLoopIUD = @IsLoopIUD OUTPUT,
			@pPrefixData = @PrefixString OUTPUT,
			@pSerialLen = @SerialLen OUTPUT
    
    IF @IsAutoKey = 0 AND @IsLoopIUD = 0 BEGIN
        
        EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
	
	    BEGIN TRY
			-- Process Insert Table
            MERGE STB_ElectrodeWastePriceNew AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldRouteCode IS NULL THEN RouteCode
							    ELSE OldRouteCode
							END AS OldRouteCode,
							CASE
							    WHEN OldElectrodeClassCode IS NULL THEN ElectrodeClassCode
							    ELSE OldElectrodeClassCode
							END AS OldElectrodeClassCode,
							CASE
							    WHEN OldElectrodeThickness IS NULL THEN ElectrodeThickness
							    ELSE OldElectrodeThickness
							END AS OldElectrodeThickness,
							CASE
							    WHEN OldCurrentCollectorClassCode IS NULL THEN CurrentCollectorClassCode
							    ELSE OldCurrentCollectorClassCode
							END AS OldCurrentCollectorClassCode,
							CASE
							    WHEN OldDefectCode IS NULL THEN DefectCode
							    ELSE OldDefectCode
							END AS OldDefectCode,
							CASE
							    WHEN OldCompanyCode IS NULL THEN CompanyCode
							    ELSE OldCompanyCode
							END AS OldCompanyCode,
							CASE
							    WHEN OldWorkCenterCode IS NULL THEN WorkCenterCode
							    ELSE OldWorkCenterCode
							END AS OldWorkCenterCode,
							RouteCode,
							ElectrodeClassCode,
							ElectrodeThickness,
							CurrentCollectorClassCode,
							DefectCode,
							DefectUnitPrice,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID,
							CompanyCode,
							WorkCenterCode
					FROM
							OPENXML(@idoc , @InsertTableName , 2)
							WITH  (
										OldRouteCode VARCHAR(20),
										OldElectrodeClassCode VARCHAR(20),
										OldElectrodeThickness INT,
										OldCurrentCollectorClassCode VARCHAR(20),
										OldDefectCode VARCHAR(20),
										OldCompanyCode VARCHAR(20),
										OldWorkCenterCode VARCHAR(20),
										RouteCode VARCHAR(20),
										ElectrodeClassCode VARCHAR(20),
										ElectrodeThickness INT,
										CurrentCollectorClassCode VARCHAR(20),
										DefectCode VARCHAR(20),
										DefectUnitPrice NUMERIC(20,10),
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20),
										CompanyCode VARCHAR(20),
										WorkCenterCode VARCHAR(20)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.RouteCode = SourceTable.RouteCode AND
					TargetTable.ElectrodeClassCode = SourceTable.ElectrodeClassCode AND
					TargetTable.ElectrodeThickness = SourceTable.ElectrodeThickness AND
					TargetTable.CurrentCollectorClassCode = SourceTable.CurrentCollectorClassCode AND
					TargetTable.DefectCode = SourceTable.DefectCode AND
					TargetTable.CompanyCode = SourceTable.CompanyCode AND
					TargetTable.WorkCenterCode = SourceTable.WorkCenterCode
				)

			WHEN MATCHED THEN
				UPDATE SET
					RouteCode = ISNULL(SourceTable.RouteCode,TargetTable.RouteCode),
					ElectrodeClassCode = ISNULL(SourceTable.ElectrodeClassCode,TargetTable.ElectrodeClassCode),
					ElectrodeThickness = ISNULL(SourceTable.ElectrodeThickness,TargetTable.ElectrodeThickness),
					CurrentCollectorClassCode = ISNULL(SourceTable.CurrentCollectorClassCode,TargetTable.CurrentCollectorClassCode),
					DefectCode = ISNULL(SourceTable.DefectCode,TargetTable.DefectCode),
					DefectUnitPrice = ISNULL(SourceTable.DefectUnitPrice,TargetTable.DefectUnitPrice),
					ChangeDateTime = ISNULL(SourceTable.ChangeDateTime,TargetTable.ChangeDateTime),
					ChangeUserID = ISNULL(SourceTable.ChangeUserID,TargetTable.ChangeUserID),
					CompanyCode = ISNULL(SourceTable.CompanyCode,TargetTable.CompanyCode),
					WorkCenterCode = ISNULL(SourceTable.WorkCenterCode,TargetTable.WorkCenterCode)
			WHEN NOT MATCHED THEN
				INSERT
					(
						RouteCode,
						ElectrodeClassCode,
						ElectrodeThickness,
						CurrentCollectorClassCode,
						DefectCode,
						DefectUnitPrice,
						CreateDateTime,
						CreateUserID,
						CompanyCode,
						WorkCenterCode
					)
				VALUES
					(
							SourceTable.RouteCode,
							SourceTable.ElectrodeClassCode,
							SourceTable.ElectrodeThickness,
							SourceTable.CurrentCollectorClassCode,
							SourceTable.DefectCode,
							SourceTable.DefectUnitPrice,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID,
							SourceTable.CompanyCode,
							SourceTable.WorkCenterCode
					);


			-- Process Update Table
            MERGE STB_ElectrodeWastePriceNew AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldRouteCode IS NULL THEN RouteCode
							    ELSE OldRouteCode
							END AS OldRouteCode,
							CASE
							    WHEN OldElectrodeClassCode IS NULL THEN ElectrodeClassCode
							    ELSE OldElectrodeClassCode
							END AS OldElectrodeClassCode,
							CASE
							    WHEN OldElectrodeThickness IS NULL THEN ElectrodeThickness
							    ELSE OldElectrodeThickness
							END AS OldElectrodeThickness,
							CASE
							    WHEN OldCurrentCollectorClassCode IS NULL THEN CurrentCollectorClassCode
							    ELSE OldCurrentCollectorClassCode
							END AS OldCurrentCollectorClassCode,
							CASE
							    WHEN OldDefectCode IS NULL THEN DefectCode
							    ELSE OldDefectCode
							END AS OldDefectCode,
							CASE
							    WHEN OldCompanyCode IS NULL THEN CompanyCode
							    ELSE OldCompanyCode
							END AS OldCompanyCode,
							CASE
							    WHEN OldWorkCenterCode IS NULL THEN WorkCenterCode
							    ELSE OldWorkCenterCode
							END AS OldWorkCenterCode,
							RouteCode,
							ElectrodeClassCode,
							ElectrodeThickness,
							CurrentCollectorClassCode,
							DefectCode,
							DefectUnitPrice,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID,
							CompanyCode,
							WorkCenterCode
					FROM
							OPENXML(@idoc , @UpdateTableName , 2)
							WITH  (
										OldRouteCode VARCHAR(20),
										OldElectrodeClassCode VARCHAR(20),
										OldElectrodeThickness INT,
										OldCurrentCollectorClassCode VARCHAR(20),
										OldDefectCode VARCHAR(20),
										OldCompanyCode VARCHAR(20),
										OldWorkCenterCode VARCHAR(20),
										RouteCode VARCHAR(20),
										ElectrodeClassCode VARCHAR(20),
										ElectrodeThickness INT,
										CurrentCollectorClassCode VARCHAR(20),
										DefectCode VARCHAR(20),
										DefectUnitPrice NUMERIC(20,10),
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20),
										CompanyCode VARCHAR(20),
										WorkCenterCode VARCHAR(20)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.RouteCode = SourceTable.OldRouteCode AND
					TargetTable.ElectrodeClassCode = SourceTable.OldElectrodeClassCode AND
					TargetTable.ElectrodeThickness = SourceTable.OldElectrodeThickness AND
					TargetTable.CurrentCollectorClassCode = SourceTable.OldCurrentCollectorClassCode AND
					TargetTable.DefectCode = SourceTable.OldDefectCode AND
					TargetTable.CompanyCode = SourceTable.OldCompanyCode AND
					TargetTable.WorkCenterCode = SourceTable.OldWorkCenterCode
				)

			WHEN MATCHED THEN
				UPDATE SET
					RouteCode = ISNULL(SourceTable.RouteCode,TargetTable.RouteCode),
					ElectrodeClassCode = ISNULL(SourceTable.ElectrodeClassCode,TargetTable.ElectrodeClassCode),
					ElectrodeThickness = ISNULL(SourceTable.ElectrodeThickness,TargetTable.ElectrodeThickness),
					CurrentCollectorClassCode = ISNULL(SourceTable.CurrentCollectorClassCode,TargetTable.CurrentCollectorClassCode),
					DefectCode = ISNULL(SourceTable.DefectCode,TargetTable.DefectCode),
					DefectUnitPrice = ISNULL(SourceTable.DefectUnitPrice,TargetTable.DefectUnitPrice),
					ChangeDateTime = ISNULL(SourceTable.ChangeDateTime,TargetTable.ChangeDateTime),
					ChangeUserID = ISNULL(SourceTable.ChangeUserID,TargetTable.ChangeUserID),
					CompanyCode = ISNULL(SourceTable.CompanyCode,TargetTable.CompanyCode),
					WorkCenterCode = ISNULL(SourceTable.WorkCenterCode,TargetTable.WorkCenterCode)
			WHEN NOT MATCHED THEN
				INSERT
					(
						RouteCode,
						ElectrodeClassCode,
						ElectrodeThickness,
						CurrentCollectorClassCode,
						DefectCode,
						DefectUnitPrice,
						CreateDateTime,
						CreateUserID,
						CompanyCode,
						WorkCenterCode
					)
				VALUES
					(
							SourceTable.RouteCode,
							SourceTable.ElectrodeClassCode,
							SourceTable.ElectrodeThickness,
							SourceTable.CurrentCollectorClassCode,
							SourceTable.DefectCode,
							SourceTable.DefectUnitPrice,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID,
							SourceTable.CompanyCode,
							SourceTable.WorkCenterCode
					);


			-- Process Delete Table
            MERGE STB_ElectrodeWastePriceNew AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldRouteCode IS NULL THEN RouteCode
							    ELSE OldRouteCode
							END AS OldRouteCode,
							CASE
							    WHEN OldElectrodeClassCode IS NULL THEN ElectrodeClassCode
							    ELSE OldElectrodeClassCode
							END AS OldElectrodeClassCode,
							CASE
							    WHEN OldElectrodeThickness IS NULL THEN ElectrodeThickness
							    ELSE OldElectrodeThickness
							END AS OldElectrodeThickness,
							CASE
							    WHEN OldCurrentCollectorClassCode IS NULL THEN CurrentCollectorClassCode
							    ELSE OldCurrentCollectorClassCode
							END AS OldCurrentCollectorClassCode,
							CASE
							    WHEN OldDefectCode IS NULL THEN DefectCode
							    ELSE OldDefectCode
							END AS OldDefectCode,
							CASE
							    WHEN OldCompanyCode IS NULL THEN CompanyCode
							    ELSE OldCompanyCode
							END AS OldCompanyCode,
							CASE
							    WHEN OldWorkCenterCode IS NULL THEN WorkCenterCode
							    ELSE OldWorkCenterCode
							END AS OldWorkCenterCode,
							RouteCode,
							ElectrodeClassCode,
							ElectrodeThickness,
							CurrentCollectorClassCode,
							DefectCode,
							CompanyCode,
							WorkCenterCode
					FROM
							OPENXML(@idoc , @DeleteTableName , 2)
							WITH  (
										OldRouteCode VARCHAR(20),
										OldElectrodeClassCode VARCHAR(20),
										OldElectrodeThickness INT,
										OldCurrentCollectorClassCode VARCHAR(20),
										OldDefectCode VARCHAR(20),
										OldCompanyCode VARCHAR(20),
										OldWorkCenterCode VARCHAR(20),
										RouteCode VARCHAR(20),
										ElectrodeClassCode VARCHAR(20),
										ElectrodeThickness INT,
										CurrentCollectorClassCode VARCHAR(20),
										DefectCode VARCHAR(20),
										CompanyCode VARCHAR(20),
										WorkCenterCode VARCHAR(20)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.RouteCode = SourceTable.RouteCode AND
					TargetTable.ElectrodeClassCode = SourceTable.ElectrodeClassCode AND
					TargetTable.ElectrodeThickness = SourceTable.ElectrodeThickness AND
					TargetTable.CurrentCollectorClassCode = SourceTable.CurrentCollectorClassCode AND
					TargetTable.DefectCode = SourceTable.DefectCode AND
					TargetTable.CompanyCode = SourceTable.CompanyCode AND
					TargetTable.WorkCenterCode = SourceTable.WorkCenterCode
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
        PRINT 'Loop was removed'
    END
END
