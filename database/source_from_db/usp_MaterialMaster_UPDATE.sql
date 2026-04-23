-- =============================================
-- Author:	    Park Jong Seob(jspark@awoo.co.kr)
-- Create date: 2016-06-12
-- Browsable : true
-- Group : 품목마스터
-- Description:	품목마스터 IUD
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_MaterialMaster_UPDATE]
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
  DECLARE @ChildMaterialCode VARCHAR(50)
  DECLARE @IsInternalProd BIT
  DECLARE @IsProdPlan BIT
  DECLARE @IsPurchase BIT
  DECLARE @IsOrder BIT
  DECLARE @IsUseBackFlush BIT




	DECLARE @iDoc INT

    EXEC SmartFramework.dbo.usp_GetSerialRule 
			@pTableName = 'STB_MaterialMaster',
			@pIsAutoKey = @IsAutoKey OUTPUT,
			@pIsLoopIUD = @IsLoopIUD OUTPUT,
			@pPrefixData = @PrefixString OUTPUT,
			@pSerialLen = @SerialLen OUTPUT
    
    IF @IsAutoKey = 0 AND @IsLoopIUD = 0 BEGIN
   
	    EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
	
	    BEGIN TRY
			
			-- Process Update Table
            MERGE STB_MaterialMaster AS TargetTable
			USING
				(
					SELECT
							Clear_Duplicate.ChildMaterialCode,
							Clear_Duplicate.IsInternalProd,
							Clear_Duplicate.IsProdPlan,
							Clear_Duplicate.IsPurchase,
							Clear_Duplicate.IsOrder,
							Clear_Duplicate.IsUseBackFlush,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							(
								SELECT
										ChildMaterialCode,
										IsInternalProd,
										IsProdPlan,
										IsPurchase,
										IsOrder,
										IsUseBackFlush,
										RANK() OVER(PARTITION BY ChildMaterialCode order by ChildMaterialCode,MaterialCode DESC) AS RANK
								FROM
										OPENXML(@idoc , @UpdateTableName , 2)
										WITH  (
													ChildMaterialCode VARCHAR(50),
													MaterialCode VARCHAR(50),
													IsInternalProd BIT,
													IsProdPlan BIT,
													IsPurchase BIT,
													IsOrder BIT,
													IsUseBackFlush BIT
												) 
							)Clear_Duplicate
					WHERE
							Clear_Duplicate.RANK = 1
				) AS SourceTable
			ON
				(
					TargetTable.MaterialCode = SourceTable.ChildMaterialCode
				)

			WHEN MATCHED THEN
				UPDATE SET
					MaterialCode = SourceTable.ChildMaterialCode,
					IsInternalProd = SourceTable.IsInternalProd,
					IsProdPlan = SourceTable.IsProdPlan,
					IsPurchase = SourceTable.IsPurchase,
					IsOrder = SourceTable.IsOrder,
					IsUseBackFlush = SourceTable.IsUseBackFlush,
					ChangeDateTime = SourceTable.ChangeDateTime,
					ChangeUserID = SourceTable.ChangeUserID
			WHEN NOT MATCHED THEN
				INSERT
					(
						MaterialCode,
						IsInternalProd,
						IsProdPlan,
						IsPurchase,
						IsOrder,
						IsUseBackFlush,
						CreateDateTime,
						CreateUserID
					)
				VALUES
					(
							SourceTable.ChildMaterialCode,
							SourceTable.IsInternalProd,
							SourceTable.IsProdPlan,
							SourceTable.IsPurchase,
							SourceTable.IsOrder,
							SourceTable.IsUseBackFlush,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID
					);
        END TRY
	    BEGIN CATCH
            SET @ERROR_MSG = ERROR_MESSAGE()
			RAISERROR( @ERROR_MSG ,16, 1)
	    END CATCH
		
	    EXEC sp_xml_removedocument @idoc

    END
END
