-- =============================================
-- Author: Park Jong Hoon(jhpark@awoo.co.kr)
-- Create date: 2016-05-18
-- Browsable : true
-- Group : 설비관리
-- Description:	스페어파트 표준저장위치 IUD
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_vbSparePartBasicLocation_iud]
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
  DECLARE @OldSPWarehouseCode VARCHAR(20)
  DECLARE @OldSparePartCode VARCHAR(20)
  DECLARE @SPWarehouseCode VARCHAR(20)
  DECLARE @SparePartCode VARCHAR(20)
  DECLARE @SPLocationCode VARCHAR(20)

	DECLARE @iDoc INT
	
	--Master.SPWarehouseCode,
	--		Master.SPWarehouseName,
			
	--		Master.CompanyCode,
	--		CI.CompanyName,
	--		CI.CompanyNameL,
			
	--		Master.WorkCenterCode,
	--		WCI.WorkCenterName,
	--		WCI.WorkCenterNameL,
			
	--		Master.SparePartCode,
	--		Master.SparePartName,
	--		Master.SparePartSpec01,
	--		Master.SparePartSpec02,
	--		Master.SparePartSpec03,
	--		Master.SparePartSpec04,
	--		Master.SparePartSpec05,
	--		Master.SparePartImage,
	--		Master.BasicUnitPrice,
	--		Master.BasicDeliveryDay,
	--		Master.BasicUnit,
	--		Master.SafeQty,
	--		Master.LastDeliveryVendor,
	--		Master.CompatibilityGroup,
			
	--		Detail.SPLocationCode,
	--		Detail.SPLocationGroup,
	--		Detail.SPLocationName
	

   
     EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
	
	    BEGIN TRY
			
			;WITH SourceTable_CTE AS(
				
				SELECT
						CASE
						    WHEN XMLData.OldSPWarehouseCode IS NULL THEN XMLData.SPWarehouseCode
						    ELSE XMLData.OldSPWarehouseCode
						END AS OldSPWarehouseCode,
						CASE
						    WHEN XMLData.OldSparePartCode IS NULL THEN XMLData.SparePartCode
						    ELSE XMLData.OldSparePartCode
						END AS OldSparePartCode,
						XMLData.SPWarehouseCode,
						XMLData.SparePartCode,
						XMLData.SPLocationCode
				FROM
						OPENXML(@idoc , @AlltTableName , 2)
						WITH (
								OldSPWarehouseCode VARCHAR(20),
								OldSparePartCode VARCHAR(20),
								SPWarehouseCode VARCHAR(20),
								SparePartCode VARCHAR(20),
								SPLocationCode VARCHAR(20)
								)XMLData
			)
			
			-- Process Update Table
            MERGE STB_VNSparePartBasicLocation AS TargetTable
			USING
				(
					SELECT
							*
					FROM
							SourceTable_CTE
					WHERE
							SPLocationCode IS NOT NULL
				) AS SourceTable
			ON
				(
					TargetTable.SPWarehouseCode = SourceTable.OldSPWarehouseCode AND
					TargetTable.SparePartCode = SourceTable.OldSparePartCode
				)

			WHEN MATCHED THEN
				UPDATE SET
					SPWarehouseCode = SourceTable.SPWarehouseCode,
					SparePartCode = SourceTable.SparePartCode,
					SPLocationCode = SourceTable.SPLocationCode

				
			WHEN NOT MATCHED THEN
			
				INSERT
					(
						SPWarehouseCode,
						SparePartCode,
						SPLocationCode
					)
				VALUES
					(
							SourceTable.SPWarehouseCode,
							SourceTable.SparePartCode,
							SourceTable.SPLocationCode
					)

			WHEN NOT MATCHED BY SOURCE AND TargetTable.SPWarehouseCode IN (SELECT SPWarehouseCode FROM SourceTable_CTE) AND TargetTable.SparePartCode IN (SELECT SparePartCode FROM SourceTable_CTE)  THEN
					DELETE;


        END TRY
	    BEGIN CATCH
            SET @ERROR_MSG = ERROR_MESSAGE()
			RAISERROR( @ERROR_MSG ,16, 1)
	    END CATCH
	
	    EXEC sp_xml_removedocument @idoc
		

END

