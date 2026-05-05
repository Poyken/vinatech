-- Procedure: usp_BomDetail_iud
-- =============================================
-- Author:	    Anonymous()
-- Create date: 2016-02-04
-- Browsable : true
-- Group : 공통
-- Description:	
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_BomDetail_iud]
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
  DECLARE @OldMaterialCode VARCHAR(50)
  DECLARE @OldBomVersion VARCHAR(20)
  DECLARE @OldChildMaterialCode VARCHAR(50)
  DECLARE @OldChildBomVersion VARCHAR(20)
  DECLARE @MaterialCode VARCHAR(50)
  DECLARE @BomVersion VARCHAR(20)
  DECLARE @ChildMaterialCode VARCHAR(50)
  DECLARE @ChildBomVersion VARCHAR(20)
  DECLARE @BomUnit VARCHAR(10)
  DECLARE @UsedQty NUMERIC(20,10)
  DECLARE @RouteCode VARCHAR(20)
  DECLARE @IsOptionItem BIT
  DECLARE @BomDetailDesc VARCHAR(200)
  DECLARE @CreateDateTime DATETIME
  DECLARE @CreateUserID VARCHAR(20)
  DECLARE @ChangeDateTime DATETIME
  DECLARE @ChangeUserID VARCHAR(20)


	DECLARE @iDoc INT

    EXEC SmartFramework.dbo.usp_GetSerialRule 
			@pTableName = 'STB_BomDetail',
			@pIsAutoKey = @IsAutoKey OUTPUT,
			@pIsLoopIUD = @IsLoopIUD OUTPUT,
			@pPrefixData = @PrefixString OUTPUT,
			@pSerialLen = @SerialLen OUTPUT
    
    IF @IsAutoKey = 0 AND @IsLoopIUD = 0 BEGIN
   
	    EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
	
	    BEGIN TRY
			-- Process Insert Table
	
            MERGE STB_BomDetail AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN XMLData.OldMaterialCode IS NULL THEN XMLData.MaterialCode
							    ELSE XMLData.OldMaterialCode
							END AS OldMaterialCode,
							CASE
							    WHEN XMLData.OldBomVersion IS NULL THEN XMLData.BomVersion
							    ELSE XMLData.OldBomVersion
							END AS OldBomVersion,
							CASE
							    WHEN XMLData.OldChildMaterialCode IS NULL THEN XMLData.ChildMaterialCode
							    ELSE XMLData.OldChildMaterialCode
							END AS OldChildMaterialCode,
							CASE
							    WHEN XMLData.OldChildBomVersion IS NULL THEN XMLData.ChildBomVersion
							    ELSE XMLData.OldChildBomVersion
							END AS OldChildBomVersion,
							XMLData.MaterialCode,
							CASE 
								WHEN XMLData.BomVersion IS NULL THEN ''
								ELSE XMLData.BomVersion
							END AS BomVersion,
							XMLData.ChildMaterialCode,
							CASE 
								WHEN XMLData.ChildBomVersion IS NULL THEN ''
								ELSE XMLData.ChildBomVersion
							END AS ChildBomVersion,
							XMLData.BomUnit,
							XMLData.UsedQty,
							XMLData.RouteCode,
							XMLData.IsOptionItem,
							XMLData.BomDetailDesc,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @InsertTableName , 2)
							WITH  (
										OldMaterialCode VARCHAR(50),
										OldBomVersion VARCHAR(20),
										OldChildMaterialCode VARCHAR(50),
										OldChildBomVersion VARCHAR(20),
										MaterialCode VARCHAR(50),
										BomVersion VARCHAR(20),
										ChildMaterialCode VARCHAR(50),
										ChildBomVersion VARCHAR(20),
										BomUnit VARCHAR(10),
										UsedQty NUMERIC(20,10),
										RouteCode VARCHAR(20),
										IsOptionItem BIT,
										BomDetailDesc VARCHAR(200),
										CreateDateTime  DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime  DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) XMLData
				) AS SourceTable
			ON
				(
					TargetTable.MaterialCode = SourceTable.MaterialCode AND
					TargetTable.BomVersion = SourceTable.BomVersion AND
					TargetTable.ChildMaterialCode = SourceTable.ChildMaterialCode AND
					TargetTable.ChildBomVersion = SourceTable.ChildBomVersion
				)

			WHEN MATCHED THEN
				UPDATE SET
					MaterialCode = SourceTable.MaterialCode,
					BomVersion = SourceTable.BomVersion,
					ChildMaterialCode = SourceTable.ChildMaterialCode,
					ChildBomVersion = SourceTable.ChildBomVersion,
					BomUnit = SourceTable.BomUnit,
					UsedQty = SourceTable.UsedQty,
					RouteCode = SourceTable.RouteCode,
					IsOptionItem = SourceTable.IsOptionItem,
					BomDetailDesc = SourceTable.BomDetailDesc,
					ChangeDateTime = SourceTable.ChangeDateTime,
					ChangeUserID = SourceTable.ChangeUserID
			WHEN NOT MATCHED THEN
				INSERT
					(
						MaterialCode,
						BomVersion,
						ChildMaterialCode,
						ChildBomVersion,
						BomUnit,
						UsedQty,
						RouteCode,
						IsOptionItem,
						BomDetailDesc,
						CreateDateTime,
						CreateUserID
					)
				VALUES
					(
							SourceTable.MaterialCode,
							SourceTable.BomVersion,
							SourceTable.ChildMaterialCode,
							SourceTable.ChildBomVersion,
							SourceTable.BomUnit,
							SourceTable.UsedQty,
							SourceTable.RouteCode,
							SourceTable.IsOptionItem,
							SourceTable.BomDetailDesc,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID
					);


			-- Process Update Table
            MERGE STB_BomDetail AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN XMLData.OldMaterialCode IS NULL THEN XMLData.MaterialCode
							    ELSE XMLData.OldMaterialCode
							END AS OldMaterialCode,
							CASE
							    WHEN XMLData.OldBomVersion IS NULL THEN XMLData.BomVersion
							    ELSE XMLData.OldBomVersion
							END AS OldBomVersion,
							CASE
							    WHEN XMLData.OldChildMaterialCode IS NULL THEN XMLData.ChildMaterialCode
							    ELSE XMLData.OldChildMaterialCode
							END AS OldChildMaterialCode,
							CASE
							    WHEN XMLData.OldChildBomVersion IS NULL THEN XMLData.ChildBomVersion
							    ELSE XMLData.OldChildBomVersion
							END AS OldChildBomVersion,
							XMLData.MaterialCode,
							CASE 
								WHEN XMLData.BomVersion IS NULL THEN ''
								ELSE XMLData.BomVersion
							END AS BomVersion,
							XMLData.ChildMaterialCode,
							CASE 
								WHEN XMLData.ChildBomVersion IS NULL THEN ''
								ELSE XMLData.ChildBomVersion
							END AS ChildBomVersion,
							XMLData.BomUnit,
							XMLData.UsedQty,
							XMLData.RouteCode,
							XMLData.IsOptionItem,
							XMLData.BomDetailDesc,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @UpdateTableName , 2)
							WITH  (
										OldMaterialCode VARCHAR(50),
										OldBomVersion VARCHAR(20),
										OldChildMaterialCode VARCHAR(50),
										OldChildBomVersion VARCHAR(20),
										MaterialCode VARCHAR(50),
										BomVersion VARCHAR(20),
										ChildMaterialCode VARCHAR(50),
										ChildBomVersion VARCHAR(20),
										BomUnit VARCHAR(10),
										UsedQty NUMERIC(20,10),
										RouteCode VARCHAR(20),
										IsOptionItem BIT,
										BomDetailDesc VARCHAR(200),
										CreateDateTime  DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime  DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) XMLData
				) AS SourceTable
			ON
				(
					TargetTable.MaterialCode = SourceTable.OldMaterialCode AND
					TargetTable.BomVersion = SourceTable.OldBomVersion AND
					TargetTable.ChildMaterialCode = SourceTable.OldChildMaterialCode AND
					TargetTable.ChildBomVersion = SourceTable.OldChildBomVersion
				)

			WHEN MATCHED THEN
				
				UPDATE SET
					MaterialCode = SourceTable.MaterialCode,
					BomVersion = SourceTable.BomVersion,
					ChildMaterialCode = SourceTable.ChildMaterialCode,
					ChildBomVersion = SourceTable.ChildBomVersion,
					BomUnit = SourceTable.BomUnit,
					UsedQty = SourceTable.UsedQty,
					RouteCode = SourceTable.RouteCode,
					IsOptionItem = SourceTable.IsOptionItem,
					BomDetailDesc = SourceTable.BomDetailDesc,
					ChangeDateTime = SourceTable.ChangeDateTime,
					ChangeUserID = SourceTable.ChangeUserID
			WHEN NOT MATCHED THEN
				INSERT
					(
						MaterialCode,
						BomVersion,
						ChildMaterialCode,
						ChildBomVersion,
						BomUnit,
						UsedQty,
						RouteCode,
						IsOptionItem,
						BomDetailDesc,
						CreateDateTime,
						CreateUserID
					)
				VALUES
					(
							SourceTable.MaterialCode,
							SourceTable.BomVersion,
							SourceTable.ChildMaterialCode,
							SourceTable.ChildBomVersion,
							SourceTable.BomUnit,
							SourceTable.UsedQty,
							SourceTable.RouteCode,
							SourceTable.IsOptionItem,
							SourceTable.BomDetailDesc,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID
					);


			-- Process Delete Table
            MERGE STB_BomDetail AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN XMLData.OldMaterialCode IS NULL THEN XMLData.MaterialCode
							    ELSE XMLData.OldMaterialCode
							END AS OldMaterialCode,
							CASE
							    WHEN XMLData.OldBomVersion IS NULL THEN XMLData.BomVersion
							    ELSE XMLData.OldBomVersion
							END AS OldBomVersion,
							CASE
							    WHEN XMLData.OldChildMaterialCode IS NULL THEN XMLData.ChildMaterialCode
							    ELSE XMLData.OldChildMaterialCode
							END AS OldChildMaterialCode,
							CASE
							    WHEN XMLData.OldChildBomVersion IS NULL THEN XMLData.ChildBomVersion
							    ELSE XMLData.OldChildBomVersion
							END AS OldChildBomVersion,
							XMLData.MaterialCode,
							XMLData.BomVersion,
							XMLData.ChildMaterialCode,
							XMLData.ChildBomVersion,
							XMLData.BomUnit,
							XMLData.UsedQty,
							XMLData.RouteCode,
							XMLData.IsOptionItem,
							XMLData.BomDetailDesc,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @DeleteTableName , 2)
							WITH  (
										OldMaterialCode VARCHAR(50),
										OldBomVersion VARCHAR(20),
										OldChildMaterialCode VARCHAR(50),
										OldChildBomVersion VARCHAR(20),
										MaterialCode VARCHAR(50),
										BomVersion VARCHAR(20),
										ChildMaterialCode VARCHAR(50),
										ChildBomVersion VARCHAR(20),
										BomUnit VARCHAR(10),
										UsedQty NUMERIC(20,10),
										RouteCode VARCHAR(20),
										IsOptionItem BIT,
										BomDetailDesc VARCHAR(200),
										CreateDateTime  DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime  DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) XMLData
				) AS SourceTable
			ON
				(
					TargetTable.MaterialCode = SourceTable.MaterialCode AND
					TargetTable.BomVersion = SourceTable.BomVersion AND
					TargetTable.ChildMaterialCode = SourceTable.ChildMaterialCode AND
					TargetTable.ChildBomVersion = SourceTable.ChildBomVersion
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
									XMLData.OldMaterialCode,
									XMLData.OldBomVersion,
									XMLData.OldChildMaterialCode,
									XMLData.OldChildBomVersion,
									XMLData.MaterialCode,
									XMLData.BomVersion,
									XMLData.ChildMaterialCode,
									XMLData.ChildBomVersion,
									XMLData.BomUnit,
									XMLData.UsedQty,
									XMLData.RouteCode,
									XMLData.IsOptionItem,
									XMLData.BomDetailDesc,
									XMLData.CreateDateTime,
									XMLData.CreateUserID,
									XMLData.ChangeDateTime,
									XMLData.ChangeUserID
							FROM
									OPENXML(@idoc , @InsertTableName , 2)
							        WITH  (
											 OldMaterialCode VARCHAR(50),
											 OldBomVersion VARCHAR(20),
											 OldChildMaterialCode VARCHAR(50),
											 OldChildBomVersion VARCHAR(20),
											 MaterialCode VARCHAR(50),
											 BomVersion VARCHAR(20),
											 ChildMaterialCode VARCHAR(50),
											 ChildBomVersion VARCHAR(20),
											 BomUnit varchar(10),
											 UsedQty NUMERIC(20,10),
											 RouteCode VARCHAR(20),
											 IsOptionItem BIT,
											 BomDetailDesc VARCHAR(200),
											 CreateDateTime  DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime  DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											) XMLData
							UNION ALL
							SELECT
									'UPDATE' AS IUD_FLAG,
									CASE 
										WHEN XMLData.OldMaterialCode IS NULL THEN XMLData.MaterialCode
										ELSE XMLData.OldMaterialCode
									END AS OldMaterialCode,
									CASE 
										WHEN XMLData.OldBomVersion IS NULL THEN XMLData.BomVersion
										ELSE XMLData.OldBomVersion
									END AS OldBomVersion,
									CASE 
										WHEN XMLData.OldChildMaterialCode IS NULL THEN XMLData.ChildMaterialCode
										ELSE XMLData.OldChildMaterialCode
									END AS OldChildMaterialCode,
									CASE 
										WHEN XMLData.OldChildBomVersion IS NULL THEN XMLData.ChildBomVersion
										ELSE XMLData.OldChildBomVersion
									END AS OldChildBomVersion,
									XMLData.MaterialCode,
									XMLData.BomVersion,
									XMLData.ChildMaterialCode,
									XMLData.ChildBomVersion,
									XMLData.BomUnit,
									XMLData.UsedQty,
									XMLData.RouteCode,
									XMLData.IsOptionItem,
									XMLData.BomDetailDesc,
									XMLData.CreateDateTime,
									XMLData.CreateUserID,
									XMLData.ChangeDateTime,
									XMLData.ChangeUserID
							FROM
									OPENXML(@idoc , @UpdateTableName , 2)
							        WITH  (
											 OldMaterialCode VARCHAR(50),
											 OldBomVersion VARCHAR(20),
											 OldChildMaterialCode VARCHAR(50),
											 OldChildBomVersion VARCHAR(20),
											 MaterialCode VARCHAR(50),
											 BomVersion VARCHAR(20),
											 ChildMaterialCode VARCHAR(50),
											 ChildBomVersion VARCHAR(20),
											 BomUnit VARCHAR(10),
											 UsedQty NUMERIC(20,10),
											 RouteCode VARCHAR(20),
											 IsOptionItem BIT,
											 BomDetailDesc VARCHAR(200),
											 CreateDateTime  DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime  DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											) XMLData
							UNION ALL
							SELECT
									'DELETE' AS IUD_FLAG,
									CASE 
										WHEN XMLData.OldMaterialCode IS NULL THEN XMLData.MaterialCode
										ELSE XMLData.OldMaterialCode
									END AS OldMaterialCode,
									CASE 
										WHEN XMLData.OldBomVersion IS NULL THEN XMLData.BomVersion
										ELSE XMLData.OldBomVersion
									END AS OldBomVersion,
									CASE 
										WHEN XMLData.OldChildMaterialCode IS NULL THEN XMLData.ChildMaterialCode
										ELSE XMLData.OldChildMaterialCode
									END AS OldChildMaterialCode,
									CASE 
										WHEN XMLData.OldChildBomVersion IS NULL THEN XMLData.ChildBomVersion
										ELSE XMLData.OldChildBomVersion
									END AS OldChildBomVersion,
									XMLData.MaterialCode,
									XMLData.BomVersion,
									XMLData.ChildMaterialCode,
									XMLData.ChildBomVersion,
									XMLData.BomUnit,
									XMLData.UsedQty,
									XMLData.RouteCode,
									XMLData.IsOptionItem,
									XMLData.BomDetailDesc,
									XMLData.CreateDateTime,
									XMLData.CreateUserID,
									XMLData.ChangeDateTime,
									XMLData.ChangeUserID
							FROM
									OPENXML(@idoc , @DeleteTableName , 2)
							        WITH  (
											 OldMaterialCode VARCHAR(50),
											 OldBomVersion VARCHAR(20),
											 OldChildMaterialCode VARCHAR(50),
											 OldChildBomVersion VARCHAR(20),
											 MaterialCode VARCHAR(50),
											 BomVersion VARCHAR(20),
											 ChildMaterialCode VARCHAR(50),
											 ChildBomVersion VARCHAR(20),
											 BomUnit VARCHAR(10),
											 UsedQty NUMERIC(20,10),
											 RouteCode VARCHAR(20),
											 IsOptionItem BIT,
											 BomDetailDesc VARCHAR(200),
											 CreateDateTime  DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime  DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											) XMLData


            OPEN SourceData

            WHILE 1 = 1 BEGIN
                FETCH NEXT FROM SourceData INTO
								 @IUD_FLAG,
								 @OldMaterialCode,
								 @OldBomVersion,
								 @OldChildMaterialCode,
								 @OldChildBomVersion,
								 @MaterialCode,
								 @BomVersion,
								 @ChildMaterialCode,
								 @ChildBomVersion,
								 @BomUnit,
								 @UsedQty,
								 @RouteCode,
								 @IsOptionItem,
								 @BomDetailDesc,
								 @CreateDateTime,
								 @CreateUserID,
								 @ChangeDateTime,
								 @ChangeUserID


                IF @@FETCH_STATUS <> 0 BEGIN
					BREAK
				END
                IF @IUD_FLAG = 'INSERT' BEGIN

                    IF EXISTS (SELECT 1 FROM STB_BomDetail WHERE MaterialCode = @MaterialCode) BEGIN
						RAISERROR('Duplicate Data : KeyField = %s', 16, 1, @MaterialCode)
					END

                    IF @IsAutoKey = 1 BEGIN
						EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_BomDetail', @MaterialCode OUTPUT
                    END
				
                    INSERT INTO STB_BomDetail
						(
						    MaterialCode,
						    BomVersion,
						    ChildMaterialCode,
						    ChildBomVersion,
							BomUnit,
						    UsedQty,
						    RouteCode,
						    IsOptionItem,
						    BomDetailDesc,
						    CreateDateTime,
						    CreateUserID,
						    ChangeDateTime,
						    ChangeUserID
						)
						VALUES
						(
						    @MaterialCode,
						    @BomVersion,
						    @ChildMaterialCode,
						    @ChildBomVersion,
							@BomUnit,
						    @UsedQty,
						    @RouteCode,
						    @IsOptionItem,
						    @BomDetailDesc,
						    GETDATE(),
						    @pProcessUserID,
						    @ChangeDateTime,
						    @ChangeUserID
						)

				END ELSE IF @IUD_FLAG = 'UPDATE' BEGIN
			
                    UPDATE STB_BomDetail
						SET
						    MaterialCode =   CASE
						                WHEN @MaterialCode IS NOT NULL THEN @MaterialCode
						                ELSE MaterialCode
						            END,
						    BomVersion =   CASE
						                WHEN @BomVersion IS NOT NULL THEN @BomVersion
						                ELSE BomVersion
						            END,
						    ChildMaterialCode =   CASE
						                WHEN @ChildMaterialCode IS NOT NULL THEN @ChildMaterialCode
						                ELSE ChildMaterialCode
						            END,
						    ChildBomVersion =   CASE
						                WHEN @ChildBomVersion IS NOT NULL THEN @ChildBomVersion
						                ELSE ChildBomVersion
						            END,
							BomUnit = CASE
						                WHEN @BomUnit IS NOT NULL THEN @BomUnit
						                ELSE BomUnit
						            END,
						    UsedQty =   CASE
						                WHEN @UsedQty IS NOT NULL THEN @UsedQty
						                ELSE UsedQty
						            END,
						    RouteCode =   CASE
						                WHEN @RouteCode IS NOT NULL THEN @RouteCode
						                ELSE RouteCode
						            END,
						    IsOptionItem =   CASE
						                WHEN @IsOptionItem IS NOT NULL THEN @IsOptionItem
						                ELSE IsOptionItem
						            END,
						    BomDetailDesc =   CASE
						                WHEN @BomDetailDesc IS NOT NULL THEN @BomDetailDesc
						                ELSE BomDetailDesc
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
						    MaterialCode = @OldMaterialCode AND
						    BomVersion = @OldBomVersion AND
						    ChildMaterialCode = @OldChildMaterialCode AND
						    ChildBomVersion = @OldChildBomVersion
                END ELSE IF @IUD_FLAG = 'DELETE' BEGIN
                    DELETE FROM STB_BomDetail
						WHERE
						    MaterialCode = @MaterialCode AND
						    BomVersion = @BomVersion AND
						    ChildMaterialCode = @ChildMaterialCode AND
						    ChildBomVersion = @ChildBomVersion
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

GO

