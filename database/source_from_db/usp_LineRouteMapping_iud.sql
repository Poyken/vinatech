-- =============================================
-- Author:	    Park Jong Seob(jspark@awoo.co.kr)
-- Create date: 2016-05-18
-- Browsable : true
-- Group : 생산관리공통
-- Description:	라인공정구성정보를 저장합니다.
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_LineRouteMapping_iud]
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
    DECLARE @AlltTableName VARCHAR(100) = '/DataSet/' + @ProcessViewName
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
  DECLARE @OldLineCode VARCHAR(20)
  DECLARE @OldRouteCode VARCHAR(20)
  DECLARE @LineCode VARCHAR(20)
  DECLARE @RouteCode VARCHAR(20)
  DECLARE @RouteIndex INT
  DECLARE @CreateDateTime DATETIME
  DECLARE @CreateUserID VARCHAR(20)
  DECLARE @ChangeDateTime DATETIME
  DECLARE @ChangeUserID VARCHAR(20)


	DECLARE @iDoc INT

	    EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
	
	    BEGIN TRY

			-- Process Update Table
			;WITH SourceTable_CTE AS (
					SELECT
							CASE
							    WHEN XMLData.OldLineCode IS NULL THEN XMLData.LineCode
							    ELSE XMLData.OldLineCode
							END AS OldLineCode,
							CASE
							    WHEN XMLData.OldRouteCode IS NULL THEN XMLData.RouteCode
							    ELSE XMLData.OldRouteCode
							END AS OldRouteCode,
							XMLData.LineCode,
							XMLData.RouteCode,
							XMLData.RouteIndex,
							XMLData.IsProcessLineProduct,
							XMLData.MaterialWarehouseCode,
							IsUsed,
							XMLData.GILocationCode,
							XMLData.GRWarehouseCode,
							XMLData.GRLocationCode,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @AlltTableName , 2)
							WITH  (
										OldLineCode VARCHAR(20),
										OldRouteCode VARCHAR(20),
										LineCode VARCHAR(20),
										RouteCode VARCHAR(20),
										IsUsed BIT,
										RouteIndex INT,
										IsProcessLineProduct BIT,
										MaterialWarehouseCode VARCHAR(20),
										GILocationCode VARCHAR(20),
										GRWarehouseCode VARCHAR(20),
										GRLocationCode VARCHAR(20),
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) XMLData
				) 
            MERGE STB_LineRouteMapping AS TargetTable
			USING
				(
					SELECT
							*
					FROM
							SourceTable_CTE
					WHERE
							IsUsed = 1
						
				) AS SourceTable
			ON
				(
					TargetTable.LineCode = SourceTable.OldLineCode AND
					TargetTable.RouteCode = SourceTable.OldRouteCode
				)

			WHEN MATCHED THEN
				UPDATE SET
					LineCode = SourceTable.LineCode,
					RouteCode = SourceTable.RouteCode,
					RouteIndex = SourceTable.RouteIndex,
					IsProcessLineProduct = SourceTable.IsProcessLineProduct,
					MaterialWarehouseCode = SourceTable.MaterialWarehouseCode,
					GILocationCode = SourceTable.GILocationCode,
					GRWarehouseCode = SourceTable.GRWarehouseCode,
					GRLocationCode = SourceTable.GRLocationCode,
					ChangeDateTime = SourceTable.ChangeDateTime,
					ChangeUserID = SourceTable.ChangeUserID
			WHEN NOT MATCHED THEN
				INSERT
					(
						LineCode,
						RouteCode,
						RouteIndex,
						IsProcessLineProduct,
						MaterialWarehouseCode,
						GILocationCode,
						GRWarehouseCode,
						GRLocationCode,
						CreateDateTime,
						CreateUserID
					)
				VALUES
					(
							SourceTable.LineCode,
							SourceTable.RouteCode,
							SourceTable.RouteIndex,
							SourceTable.IsProcessLineProduct,
							SourceTable.MaterialWarehouseCode,
							SourceTable.GILocationCode,
							SourceTable.GRWarehouseCode,
							SourceTable.GRLocationCode,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID
					)
			WHEN NOT MATCHED BY SOURCE AND TargetTable.LineCode IN (SELECT LineCode FROM SourceTable_CTE) THEN
				DELETE;
				



        END TRY
	    BEGIN CATCH
            SET @ERROR_MSG = ERROR_MESSAGE()
			RAISERROR( @ERROR_MSG ,16, 1)
	    END CATCH
		
	    EXEC sp_xml_removedocument @idoc

END
