
-- =============================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Create date: 2019-11-12
-- Browsable : true
-- Group : 자재관리
-- Description:	
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_PurchaseBOM_iud]
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
  DECLARE @OldBOMIndex BIGINT
  DECLARE @BOMIndex BIGINT
  DECLARE @ProductClassCode VARCHAR(10)
  DECLARE @Volt NUMERIC(3,1)
  DECLARE @Farad NUMERIC(10,1)
  DECLARE @SizeW INT
  DECLARE @SizeH INT
  DECLARE @SizeCode VARCHAR(10)
  DECLARE @MaterialGroupName VARCHAR(100)
  DECLARE @MaterialName VARCHAR(100)
  DECLARE @UsedQty NUMERIC(38,20)
  DECLARE @UnitCode VARCHAR(10)
  DECLARE @PurchaseUnitCost NUMERIC(20,5)
  DECLARE @UnitCost NUMERIC(20,5)
  DECLARE @Remark VARCHAR(MAX)


	DECLARE @iDoc INT

    EXEC SmartFramework.dbo.usp_GetSerialRule 
			@pTableName = 'STB_PurchaseBOM',
			@pIsAutoKey = @IsAutoKey OUTPUT,
			@pIsLoopIUD = @IsLoopIUD OUTPUT,
			@pPrefixData = @PrefixString OUTPUT,
			@pSerialLen = @SerialLen OUTPUT
    
    IF @IsAutoKey = 0 AND @IsLoopIUD = 0 BEGIN
   
	    EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
	
	    BEGIN TRY
			-- Process Insert Table
            MERGE STB_PurchaseBOM AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldBOMIndex IS NULL THEN BOMIndex
							    ELSE OldBOMIndex
							END AS OldBOMIndex,
							BOMIndex,
							ProductClassCode,
							Volt,
							Farad,
							SizeW,
							SizeH,
							SizeCode,
							MaterialGroupName,
							MaterialName,
							UsedQty,
							UnitCode,
							PurchaseUnitCost,
							UnitCost,
							Remark
					FROM
							OPENXML(@idoc , @InsertTableName , 2)
							WITH  (
										OldBOMIndex BIGINT,
										BOMIndex BIGINT,
										ProductClassCode VARCHAR(10),
										Volt NUMERIC(3,1),
										Farad NUMERIC(10,1),
										SizeW INT,
										SizeH INT,
										SizeCode VARCHAR(10),
										MaterialGroupName VARCHAR(100),
										MaterialName VARCHAR(100),
										UsedQty NUMERIC(38,20),
										UnitCode VARCHAR(10),
										PurchaseUnitCost NUMERIC(20,5),
										UnitCost NUMERIC(20,5),
										Remark VARCHAR(MAX)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.BOMIndex = SourceTable.BOMIndex
				)

			WHEN MATCHED THEN
				UPDATE SET
					ProductClassCode = ISNULL(SourceTable.ProductClassCode,TargetTable.ProductClassCode),
					Volt = ISNULL(SourceTable.Volt,TargetTable.Volt),
					Farad = ISNULL(SourceTable.Farad,TargetTable.Farad),
					SizeW = ISNULL(SourceTable.SizeW,TargetTable.SizeW),
					SizeH = ISNULL(SourceTable.SizeH,TargetTable.SizeH),
					SizeCode = ISNULL(SourceTable.SizeCode,TargetTable.SizeCode),
					MaterialGroupName = ISNULL(SourceTable.MaterialGroupName,TargetTable.MaterialGroupName),
					MaterialName = ISNULL(SourceTable.MaterialName,TargetTable.MaterialName),
					UsedQty = ISNULL(SourceTable.UsedQty,TargetTable.UsedQty),
					UnitCode = ISNULL(SourceTable.UnitCode,TargetTable.UnitCode),
					PurchaseUnitCost = ISNULL(SourceTable.PurchaseUnitCost,TargetTable.PurchaseUnitCost),
					UnitCost = ISNULL(SourceTable.UnitCost,TargetTable.UnitCost),
					Remark = ISNULL(SourceTable.Remark,TargetTable.Remark)
			WHEN NOT MATCHED THEN
				INSERT
					(
						ProductClassCode,
						Volt,
						Farad,
						SizeW,
						SizeH,
						SizeCode,
						MaterialGroupName,
						MaterialName,
						UsedQty,
						UnitCode,
						PurchaseUnitCost,
						UnitCost,
						Remark
					)
				VALUES
					(
							SourceTable.ProductClassCode,
							SourceTable.Volt,
							SourceTable.Farad,
							SourceTable.SizeW,
							SourceTable.SizeH,
							SourceTable.SizeCode,
							SourceTable.MaterialGroupName,
							SourceTable.MaterialName,
							SourceTable.UsedQty,
							SourceTable.UnitCode,
							SourceTable.PurchaseUnitCost,
							SourceTable.UnitCost,
							SourceTable.Remark
					);


			-- Process Update Table
            MERGE STB_PurchaseBOM AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldBOMIndex IS NULL THEN BOMIndex
							    ELSE OldBOMIndex
							END AS OldBOMIndex,
							BOMIndex,
							ProductClassCode,
							Volt,
							Farad,
							SizeW,
							SizeH,
							SizeCode,
							MaterialGroupName,
							MaterialName,
							UsedQty,
							UnitCode,
							PurchaseUnitCost,
							UnitCost,
							Remark
					FROM
							OPENXML(@idoc , @UpdateTableName , 2)
							WITH  (
										OldBOMIndex BIGINT,
										BOMIndex BIGINT,
										ProductClassCode VARCHAR(10),
										Volt NUMERIC(3,1),
										Farad NUMERIC(10,1),
										SizeW INT,
										SizeH INT,
										SizeCode VARCHAR(10),
										MaterialGroupName VARCHAR(100),
										MaterialName VARCHAR(100),
										UsedQty NUMERIC(38,20),
										UnitCode VARCHAR(10),
										PurchaseUnitCost NUMERIC(20,5),
										UnitCost NUMERIC(20,5),
										Remark VARCHAR(MAX)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.BOMIndex = SourceTable.OldBOMIndex
				)

			WHEN MATCHED THEN
				UPDATE SET
					ProductClassCode = ISNULL(SourceTable.ProductClassCode,TargetTable.ProductClassCode),
					Volt = ISNULL(SourceTable.Volt,TargetTable.Volt),
					Farad = ISNULL(SourceTable.Farad,TargetTable.Farad),
					SizeW = ISNULL(SourceTable.SizeW,TargetTable.SizeW),
					SizeH = ISNULL(SourceTable.SizeH,TargetTable.SizeH),
					SizeCode = ISNULL(SourceTable.SizeCode,TargetTable.SizeCode),
					MaterialGroupName = ISNULL(SourceTable.MaterialGroupName,TargetTable.MaterialGroupName),
					MaterialName = ISNULL(SourceTable.MaterialName,TargetTable.MaterialName),
					UsedQty = ISNULL(SourceTable.UsedQty,TargetTable.UsedQty),
					UnitCode = ISNULL(SourceTable.UnitCode,TargetTable.UnitCode),
					PurchaseUnitCost = ISNULL(SourceTable.PurchaseUnitCost,TargetTable.PurchaseUnitCost),
					UnitCost = ISNULL(SourceTable.UnitCost,TargetTable.UnitCost),
					Remark = ISNULL(SourceTable.Remark,TargetTable.Remark)
			WHEN NOT MATCHED THEN
				INSERT
					(
						ProductClassCode,
						Volt,
						Farad,
						SizeW,
						SizeH,
						SizeCode,
						MaterialGroupName,
						MaterialName,
						UsedQty,
						UnitCode,
						PurchaseUnitCost,
						UnitCost,
						Remark
					)
				VALUES
					(
							SourceTable.ProductClassCode,
							SourceTable.Volt,
							SourceTable.Farad,
							SourceTable.SizeW,
							SourceTable.SizeH,
							SourceTable.SizeCode,
							SourceTable.MaterialGroupName,
							SourceTable.MaterialName,
							SourceTable.UsedQty,
							SourceTable.UnitCode,
							SourceTable.PurchaseUnitCost,
							SourceTable.UnitCost,
							SourceTable.Remark
					);


			-- Process Delete Table
            MERGE STB_PurchaseBOM AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldBOMIndex IS NULL THEN BOMIndex
							    ELSE OldBOMIndex
							END AS OldBOMIndex,
							BOMIndex,
							ProductClassCode,
							Volt,
							Farad,
							SizeW,
							SizeH,
							SizeCode,
							MaterialGroupName,
							MaterialName,
							UsedQty,
							UnitCode,
							PurchaseUnitCost,
							UnitCost,
							Remark
					FROM
							OPENXML(@idoc , @DeleteTableName , 2)
							WITH  (
										OldBOMIndex BIGINT,
										BOMIndex BIGINT,
										ProductClassCode VARCHAR(10),
										Volt NUMERIC(3,1),
										Farad NUMERIC(10,1),
										SizeW INT,
										SizeH INT,
										SizeCode VARCHAR(10),
										MaterialGroupName VARCHAR(100),
										MaterialName VARCHAR(100),
										UsedQty NUMERIC(38,20),
										UnitCode VARCHAR(10),
										PurchaseUnitCost NUMERIC(20,5),
										UnitCost NUMERIC(20,5),
										Remark VARCHAR(MAX)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.BOMIndex = SourceTable.BOMIndex
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
									OldBOMIndex,
									BOMIndex,
									ProductClassCode,
									Volt,
									Farad,
									SizeW,
									SizeH,
									SizeCode,
									MaterialGroupName,
									MaterialName,
									UsedQty,
									UnitCode,
									PurchaseUnitCost,
									UnitCost,
									Remark
							FROM
									OPENXML(@idoc , @InsertTableName , 2)
							        WITH  (
											 OldBOMIndex BIGINT,
											 BOMIndex BIGINT,
											 ProductClassCode VARCHAR(10),
											 Volt NUMERIC(3,1),
											 Farad NUMERIC(10,1),
											 SizeW INT,
											 SizeH INT,
											 SizeCode VARCHAR(10),
											 MaterialGroupName VARCHAR(100),
											 MaterialName VARCHAR(100),
											 UsedQty NUMERIC(38,20),
											 UnitCode VARCHAR(10),
											 PurchaseUnitCost NUMERIC(20,5),
											 UnitCost NUMERIC(20,5),
											 Remark VARCHAR(MAX)
											)
							UNION ALL
							SELECT
									'UPDATE' AS IUD_FLAG,
									CASE 
										WHEN OldBOMIndex IS NULL THEN BOMIndex
										ELSE OldBOMIndex
									END AS OldBOMIndex,
									BOMIndex,
									ProductClassCode,
									Volt,
									Farad,
									SizeW,
									SizeH,
									SizeCode,
									MaterialGroupName,
									MaterialName,
									UsedQty,
									UnitCode,
									PurchaseUnitCost,
									UnitCost,
									Remark
							FROM
									OPENXML(@idoc , @UpdateTableName , 2)
							        WITH  (
											 OldBOMIndex BIGINT,
											 BOMIndex BIGINT,
											 ProductClassCode VARCHAR(10),
											 Volt NUMERIC(3,1),
											 Farad NUMERIC(10,1),
											 SizeW INT,
											 SizeH INT,
											 SizeCode VARCHAR(10),
											 MaterialGroupName VARCHAR(100),
											 MaterialName VARCHAR(100),
											 UsedQty NUMERIC(38,20),
											 UnitCode VARCHAR(10),
											 PurchaseUnitCost NUMERIC(20,5),
											 UnitCost NUMERIC(20,5),
											 Remark VARCHAR(MAX)
											)
							UNION ALL
							SELECT
									'DELETE' AS IUD_FLAG,
									CASE 
										WHEN OldBOMIndex IS NULL THEN BOMIndex
										ELSE OldBOMIndex
									END AS OldBOMIndex,
									BOMIndex,
									ProductClassCode,
									Volt,
									Farad,
									SizeW,
									SizeH,
									SizeCode,
									MaterialGroupName,
									MaterialName,
									UsedQty,
									UnitCode,
									PurchaseUnitCost,
									UnitCost,
									Remark
							FROM
									OPENXML(@idoc , @DeleteTableName , 2)
							        WITH  (
											 OldBOMIndex BIGINT,
											 BOMIndex BIGINT,
											 ProductClassCode VARCHAR(10),
											 Volt NUMERIC(3,1),
											 Farad NUMERIC(10,1),
											 SizeW INT,
											 SizeH INT,
											 SizeCode VARCHAR(10),
											 MaterialGroupName VARCHAR(100),
											 MaterialName VARCHAR(100),
											 UsedQty NUMERIC(38,20),
											 UnitCode VARCHAR(10),
											 PurchaseUnitCost NUMERIC(20,5),
											 UnitCost NUMERIC(20,5),
											 Remark VARCHAR(MAX)
											) 


            OPEN SourceData

            WHILE 1 = 1 BEGIN
                FETCH NEXT FROM SourceData INTO
								 @IUD_FLAG,
								 @OldBOMIndex,
								 @BOMIndex,
								 @ProductClassCode,
								 @Volt,
								 @Farad,
								 @SizeW,
								 @SizeH,
								 @SizeCode,
								 @MaterialGroupName,
								 @MaterialName,
								 @UsedQty,
								 @UnitCode,
								 @PurchaseUnitCost,
								 @UnitCost,
								 @Remark


                IF @@FETCH_STATUS <> 0 BEGIN
					BREAK
				END
                IF @IUD_FLAG = 'INSERT' BEGIN

                    IF EXISTS (SELECT 1 FROM STB_PurchaseBOM WHERE BOMIndex = @BOMIndex) BEGIN
						RAISERROR('Duplicate Data : KeyField = %s', 16, 1, @BOMIndex)
					END

                    IF @IsAutoKey = 1 BEGIN
                        EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_PurchaseBOM',@BOMIndex OUTPUT
                    END

                    INSERT INTO STB_PurchaseBOM
						(
						    ProductClassCode,
						    Volt,
						    Farad,
						    SizeW,
						    SizeH,
						    SizeCode,
						    MaterialGroupName,
						    MaterialName,
						    UsedQty,
						    UnitCode,
						    PurchaseUnitCost,
						    UnitCost,
						    Remark
						)
						VALUES
						(
						    @ProductClassCode,
						    @Volt,
						    @Farad,
						    @SizeW,
						    @SizeH,
						    @SizeCode,
						    @MaterialGroupName,
						    @MaterialName,
						    @UsedQty,
						    @UnitCode,
						    @PurchaseUnitCost,
						    @UnitCost,
						    @Remark
						)

				END ELSE IF @IUD_FLAG = 'UPDATE' BEGIN
                    UPDATE STB_PurchaseBOM
						SET
						    ProductClassCode =   ISNULL(@ProductClassCode,ProductClassCode),
						    Volt =   ISNULL(@Volt,Volt),
						    Farad =   ISNULL(@Farad,Farad),
						    SizeW =   ISNULL(@SizeW,SizeW),
						    SizeH =   ISNULL(@SizeH,SizeH),
						    SizeCode =   ISNULL(@SizeCode,SizeCode),
						    MaterialGroupName =   ISNULL(@MaterialGroupName,MaterialGroupName),
						    MaterialName =   ISNULL(@MaterialName,MaterialName),
						    UsedQty =   ISNULL(@UsedQty,UsedQty),
						    UnitCode =   ISNULL(@UnitCode,UnitCode),
						    PurchaseUnitCost =   ISNULL(@PurchaseUnitCost,PurchaseUnitCost),
						    UnitCost =   ISNULL(@UnitCost,UnitCost),
						    Remark =   ISNULL(@Remark,Remark)
						WHERE
						    BOMIndex = @OldBOMIndex
                END ELSE IF @IUD_FLAG = 'DELETE' BEGIN
                    DELETE FROM STB_PurchaseBOM
						WHERE
						    BOMIndex = @OldBOMIndex
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
