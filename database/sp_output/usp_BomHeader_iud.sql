-- =============================================
-- Author:	    Anonymous()
-- Create date: 2016-01-28
-- Browsable : true
-- Group : 공통
-- Description:	
-- Modified: --Mr Tung add on 2023-07-01 for Vietnam Factory
-- =============================================
CREATE PROCEDURE [dbo].[usp_BomHeader_iud]
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
  DECLARE @MaterialCode VARCHAR(50)
  DECLARE @BomVersion VARCHAR(20)
  DECLARE @RouteCode VARCHAR(20)
  DECLARE @IsBasic BIT
  DECLARE @BomHeaderDesc NVARCHAR(200)
  DECLARE @BasicRoutingCode VARCHAR(20)
  DECLARE @IsUsed BIT
  DECLARE @CreateDateTime DATETIME
  DECLARE @CreateUserID VARCHAR(20)
  DECLARE @ChangeDateTime DATETIME
  DECLARE @ChangeUserID VARCHAR(20)

  -- 이게 왜 없나? 
  DECLARE @BomUnit VARCHAR(10)



  --  if   companycode  =  VVT   --Mr Tung add on 2023-07-01 for Vietnam Factory
  DECLARE @companycode VARCHAR(20)
  select @companycode=companycode from STB_UserInfo
  where UserID=@pProcessUserID
  set @companycode = isnull(@companycode,'')




	DECLARE @iDoc INT

    EXEC SmartFramework.dbo.usp_GetSerialRule 
			@pTableName = 'STB_BomHeader',
			@pIsAutoKey = @IsAutoKey OUTPUT,
			@pIsLoopIUD = @IsLoopIUD OUTPUT,
			@pPrefixData = @PrefixString OUTPUT,
			@pSerialLen = @SerialLen OUTPUT

	--declare @aa varchar(10)=@companycode
    --raiserror (@aa ,16,1) 
    IF @IsAutoKey = 0 AND @IsLoopIUD = 0 and @companycode<>'VVT' BEGIN
   
	    EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
	
	    BEGIN TRY
			-- Process Insert Table
            MERGE STB_BomHeader AS TargetTable
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
							XMLData.MaterialCode,
							CASE 
								WHEN XMLData.BomVersion IS NULL THEN ''
								ELSE XMLData.BomVersion
							END AS BomVersion,
							XMLData.RouteCode,
							XMLData.IsBasic,
							XMLData.BomHeaderDesc,
							XMLData.BasicRoutingCode,
							XMLData.IsUsed,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID,
							XMLData.BomUnit
					FROM
							OPENXML(@idoc , @InsertTableName , 2)
							WITH  (
										OldMaterialCode VARCHAR(50),
										OldBomVersion VARCHAR(20),
										MaterialCode VARCHAR(50),
										BomVersion VARCHAR(20),
										RouteCode VARCHAR(20),
										IsBasic BIT,
										BomHeaderDesc NVARCHAR(200),
										BasicRoutingCode VARCHAR(20),
										IsUsed BIT,
										CreateDateTime  DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime  DATETIMEOFFSET,
										ChangeUserID VARCHAR(20),
										BomUnit VARCHAR(10)
									) XMLData
				) AS SourceTable
			ON
				(
					TargetTable.MaterialCode = SourceTable.MaterialCode AND
					TargetTable.BomVersion = SourceTable.BomVersion
				)

			WHEN MATCHED THEN
				UPDATE SET
					MaterialCode = SourceTable.MaterialCode,
					BomVersion = SourceTable.BomVersion,
					RouteCode = SourceTable.RouteCode,
					IsBasic = SourceTable.IsBasic,
					BomHeaderDesc = SourceTable.BomHeaderDesc,
					BasicRoutingCode = SourceTable.BasicRoutingCode,
					IsUsed = SourceTable.IsUsed,
					ChangeDateTime = SourceTable.ChangeDateTime,
					ChangeUserID = SourceTable.ChangeUserID,
					BomUnit = SourceTable.BomUnit
			WHEN NOT MATCHED THEN
				INSERT
					(
						MaterialCode,
						BomVersion,
						RouteCode,
						IsBasic,
						BomHeaderDesc,
						BasicRoutingCode,
						IsUsed,
						CreateDateTime,
						CreateUserID,
						BomUnit
					)
				VALUES
					(
							SourceTable.MaterialCode,
							SourceTable.BomVersion,
							SourceTable.RouteCode,
							SourceTable.IsBasic,
							SourceTable.BomHeaderDesc,
							SourceTable.BasicRoutingCode,
							SourceTable.IsUsed,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID,
							SourceTable.BomUnit
					);


			-- Process Update Table
            MERGE STB_BomHeader AS TargetTable
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
							XMLData.MaterialCode,
							CASE 
								WHEN XMLData.BomVersion IS NULL THEN ''
								ELSE XMLData.BomVersion
							END AS BomVersion,
							XMLData.RouteCode,
							XMLData.IsBasic,
							XMLData.BomHeaderDesc,
							XMLData.BasicRoutingCode,
							XMLData.IsUsed,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID,
							XMLData.BomUnit
					FROM
							OPENXML(@idoc , @UpdateTableName , 2)
							WITH  (
										OldMaterialCode VARCHAR(50),
										OldBomVersion VARCHAR(20),
										MaterialCode VARCHAR(50),
										BomVersion VARCHAR(20),
										RouteCode VARCHAR(20),
										IsBasic BIT,
										BomHeaderDesc NVARCHAR(200),
										BasicRoutingCode VARCHAR(20),
										IsUsed BIT,
										CreateDateTime  DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime  DATETIMEOFFSET,
										ChangeUserID VARCHAR(20),
										BomUnit VARCHAR(10)
									) XMLData
				) AS SourceTable
			ON
				(
					TargetTable.MaterialCode = SourceTable.OldMaterialCode AND
					TargetTable.BomVersion = SourceTable.OldBomVersion
				)

			WHEN MATCHED THEN
				UPDATE SET
					MaterialCode = SourceTable.MaterialCode,
					BomVersion = SourceTable.BomVersion,
					RouteCode = SourceTable.RouteCode,
					IsBasic = SourceTable.IsBasic,
					BomHeaderDesc = SourceTable.BomHeaderDesc,
					BasicRoutingCode = SourceTable.BasicRoutingCode,
					IsUsed = SourceTable.IsUsed,
					ChangeDateTime = SourceTable.ChangeDateTime,
					ChangeUserID = SourceTable.ChangeUserID,
					BomUnit = SourceTable.BomUnit
			WHEN NOT MATCHED THEN
				INSERT
					(
						MaterialCode,
						BomVersion,
						RouteCode,
						IsBasic,
						BomHeaderDesc,
						BasicRoutingCode,
						IsUsed,
						CreateDateTime,
						CreateUserID,
						BomUnit
					)
				VALUES
					(
							SourceTable.MaterialCode,
							SourceTable.BomVersion,
							SourceTable.RouteCode,
							SourceTable.IsBasic,
							SourceTable.BomHeaderDesc,
							SourceTable.BasicRoutingCode,
							SourceTable.IsUsed,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID,
							SourceTable.BomUnit
					);


			-- Process Delete Table
            MERGE STB_BomHeader AS TargetTable
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
							XMLData.MaterialCode,
							XMLData.BomVersion,
							XMLData.RouteCode,
							XMLData.IsBasic,
							XMLData.BomHeaderDesc,
							XMLData.BasicRoutingCode,
							XMLData.IsUsed,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID,
							XMLData.BomUnit
					FROM
							OPENXML(@idoc , @DeleteTableName , 2)
							WITH  (
										OldMaterialCode VARCHAR(50),
										OldBomVersion VARCHAR(20),
										MaterialCode VARCHAR(50),
										BomVersion VARCHAR(20),
										RouteCode VARCHAR(20),
										IsBasic BIT,
										BomHeaderDesc NVARCHAR(200),
										BasicRoutingCode VARCHAR(20),
										IsUsed BIT,
										CreateDateTime  DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime  DATETIMEOFFSET,
										ChangeUserID VARCHAR(20),
										BomUnit VARCHAR(10)
									) XMLData
				) AS SourceTable
			ON
				(
					TargetTable.MaterialCode = SourceTable.MaterialCode AND
					TargetTable.BomVersion = SourceTable.BomVersion
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
									XMLData.MaterialCode,
									XMLData.BomVersion,
									XMLData.RouteCode,
									XMLData.IsBasic,
									XMLData.BomHeaderDesc,
									XMLData.BasicRoutingCode,
									XMLData.IsUsed,
									XMLData.CreateDateTime,
									XMLData.CreateUserID,
									XMLData.ChangeDateTime,
									XMLData.ChangeUserID,
									XMLData.BomUnit
							FROM
									OPENXML(@idoc , @InsertTableName , 2)
							        WITH  (
											 OldMaterialCode VARCHAR(50),
											 OldBomVersion VARCHAR(20),
											 MaterialCode VARCHAR(50),
											 BomVersion VARCHAR(20),
											 RouteCode VARCHAR(20),
											 IsBasic BIT,
											 BomHeaderDesc NVARCHAR(200),
											 BasicRoutingCode VARCHAR(20),
											 IsUsed BIT,
											 CreateDateTime  DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime  DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20),
											 BomUnit VARCHAR(10)
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
									XMLData.MaterialCode,
									XMLData.BomVersion,
									XMLData.RouteCode,
									XMLData.IsBasic,
									XMLData.BomHeaderDesc,
									XMLData.BasicRoutingCode,
									XMLData.IsUsed,
									XMLData.CreateDateTime,
									XMLData.CreateUserID,
									XMLData.ChangeDateTime,
									XMLData.ChangeUserID,
									XMLData.BomUnit
							FROM
									OPENXML(@idoc , @UpdateTableName , 2)
							        WITH  (
											 OldMaterialCode VARCHAR(50),
											 OldBomVersion VARCHAR(20),
											 MaterialCode VARCHAR(50),
											 BomVersion VARCHAR(20),
											 RouteCode VARCHAR(20),
											 IsBasic BIT,
											 BomHeaderDesc NVARCHAR(200),
											 BasicRoutingCode VARCHAR(20),
											 IsUsed BIT,
											 CreateDateTime  DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime  DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20),
											 BomUnit VARCHAR(10)
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
									XMLData.MaterialCode,
									XMLData.BomVersion,
									XMLData.RouteCode,
									XMLData.IsBasic,
									XMLData.BomHeaderDesc,
									XMLData.BaiscRoutingCode,
									XMLData.IsUsed,
									XMLData.CreateDateTime,
									XMLData.CreateUserID,
									XMLData.ChangeDateTime,
									XMLData.ChangeUserID,
									XMLData.BomUnit
							FROM
									OPENXML(@idoc , @DeleteTableName , 2)
							        WITH  (
											 OldMaterialCode VARCHAR(50),
											 OldBomVersion VARCHAR(20),
											 MaterialCode VARCHAR(50),
											 BomVersion VARCHAR(20),
											 RouteCode VARCHAR(20),
											 IsBasic BIT,
											 BomHeaderDesc NVARCHAR(200),
											 BaiscRoutingCode VARCHAR(20),
											 IsUsed BIT,
											 CreateDateTime  DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime  DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20),
											 BomUnit VARCHAR(10)
											) XMLData


            OPEN SourceData

            WHILE 1 = 1 BEGIN
                FETCH NEXT FROM SourceData INTO
								 @IUD_FLAG,
								 @OldMaterialCode,
								 @OldBomVersion,
								 @MaterialCode,
								 @BomVersion,
								 @RouteCode,
								 @IsBasic,
								 @BomHeaderDesc,
								 @BasicRoutingCode,
								 @IsUsed,
								 @CreateDateTime,
								 @CreateUserID,
								 @ChangeDateTime,
								 @ChangeUserID,
								 @BomUnit


                IF @@FETCH_STATUS <> 0 BEGIN
					BREAK
				END
                IF @IUD_FLAG = 'INSERT' BEGIN
				
     --               IF EXISTS (SELECT 1 FROM STB_BomHeader WHERE MaterialCode = @MaterialCode) BEGIN
					--	RAISERROR('Duplicate Data : KeyField = %s', 16, 1, @MaterialCode)
					--END

                    IF @IsAutoKey = 1 BEGIN
						EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_BomHeader', @MaterialCode OUTPUT
                    END

                    INSERT INTO STB_BomHeader
						(
						    MaterialCode,
						    BomVersion,
						    RouteCode,
						    IsBasic,
						    BomHeaderDesc,
							BasicRoutingCode,
						    IsUsed,
						    CreateDateTime,
						    CreateUserID,
						    ChangeDateTime,
						    ChangeUserID,
							BomUnit
						)
						VALUES
						(
						    @MaterialCode,
						    @BomVersion,
						    @RouteCode,
						    @IsBasic,
						    @BomHeaderDesc,
							@BasicRoutingCode,
						    @IsUsed,
						    GETDATE(),
						    @pProcessUserID,
						    @ChangeDateTime,
						    @ChangeUserID,
							@BomUnit
						)

				END ELSE IF @IUD_FLAG = 'UPDATE' BEGIN

                    UPDATE STB_BomHeader
						SET
						    MaterialCode =   CASE
						                WHEN @MaterialCode IS NOT NULL THEN @MaterialCode
						                ELSE MaterialCode
						            END,
						    BomVersion =   CASE
						                WHEN @BomVersion IS NOT NULL THEN @BomVersion
						                ELSE BomVersion
						            END,
						    RouteCode =   CASE
						                WHEN @RouteCode IS NOT NULL THEN @RouteCode
						                ELSE RouteCode
						            END,
						    IsBasic =   CASE
						                WHEN @IsBasic IS NOT NULL THEN @IsBasic
						                ELSE IsBasic
						            END,
						    BomHeaderDesc =   CASE
						                WHEN @BomHeaderDesc IS NOT NULL THEN @BomHeaderDesc
						                ELSE BomHeaderDesc
						            END,
							BasicRoutingCode = CASE
										WHEN @BasicRoutingCode IS NOT NULL THEN @BasicRoutingCode
										ELSE BasicRoutingCode
									END,
						    IsUsed =   CASE
						                WHEN @IsUsed IS NOT NULL THEN @IsUsed
						                ELSE IsUsed
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
						    ChangeUserID = @pProcessUserID,
							BomUnit =   CASE
						                WHEN @BomUnit IS NOT NULL THEN @BomUnit
						                ELSE BomUnit
						            END
						WHERE
						    MaterialCode = @OldMaterialCode AND					
					        BomVersion = @OldBomVersion
 
				--Mr Tung add on 2023-07-01 for Vietnam Factory
			  	  if(@companycode='VVT') begin
						update STB_BomDetail
						set BomVersion=@BomVersion
						where MaterialCode=@OldMaterialCode and BomVersion=@OldBomVersion
				  end

                END ELSE IF @IUD_FLAG = 'DELETE' BEGIN
                    DELETE FROM STB_BomHeader
						WHERE
						    MaterialCode = @MaterialCode AND
						    BomVersion = @BomVersion
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

