

-- =============================================
-- Author:	    Kim Han Young(hykim@awoo.co.kr)
-- Create date: 2016-07-29
-- Browsable : true
-- Group : 자재관리
-- Description:	MRP 대상자재정보를 INSERT/UPDATE/DELETE 합니다.
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_MrpSourceMaterial_iud]
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
  DECLARE @OldMrpSourceNo VARCHAR(20)
  DECLARE @MrpSourceNo VARCHAR(20)
  DECLARE @MrpNo VARCHAR(20)
  DECLARE @MaterialCode VARCHAR(50)
  DECLARE @BomVersion VARCHAR(20)
  DECLARE @ProdPlanDate DATE
  DECLARE @PlanQty NUMERIC(20,5)
  DECLARE @AdjustQty NUMERIC(20,5)
  DECLARE @FixedQty NUMERIC(20,5)
  DECLARE @IsNotInclude BIT
  DECLARE @CreateDateTime DATETIME
  DECLARE @CreateUserID VARCHAR(20)
  DECLARE @ChangeDateTime DATETIME
  DECLARE @ChangeUserID VARCHAR(20)

  DECLARE @BefIsFixed BIT

	DECLARE @iDoc INT

    EXEC SmartFramework.dbo.usp_GetSerialRule 
			@pTableName = 'STB_MrpSourceMaterial',
			@pIsAutoKey = @IsAutoKey OUTPUT,
			@pIsLoopIUD = @IsLoopIUD OUTPUT,
			@pPrefixData = @PrefixString OUTPUT,
			@pSerialLen = @SerialLen OUTPUT
    
    IF @IsAutoKey = 0 AND @IsLoopIUD = 0 BEGIN
   
	    EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
	
	    BEGIN TRY
			-- Process Insert Table
            MERGE STB_MrpSourceMaterial AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldMrpSourceNo IS NULL THEN MrpSourceNo
							    ELSE OldMrpSourceNo
							END AS OldMrpSourceNo,
							MrpSourceNo,
							MrpNo,
							MaterialCode,
							BomVersion,
							ProdPlanDate,
							PlanQty,
							AdjustQty,
							FixedQty,
							IsNotInclude,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @InsertTableName , 2)
							WITH  (
										OldMrpSourceNo VARCHAR(20),
										MrpSourceNo VARCHAR(20),
										MrpNo VARCHAR(20),
										MaterialCode VARCHAR(50),
										BomVersion VARCHAR(20),
										ProdPlanDate DATETIMEOFFSET,
										PlanQty NUMERIC(20,5),
										AdjustQty NUMERIC(20,5),
										FixedQty NUMERIC(20,5),
										IsNotInclude BIT,
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.MrpSourceNo = SourceTable.MrpSourceNo
				)

			WHEN MATCHED THEN
				UPDATE SET
					MrpSourceNo = ISNULL(SourceTable.MrpSourceNo,TargetTable.MrpSourceNo),
					MrpNo = ISNULL(SourceTable.MrpNo,TargetTable.MrpNo),
					MaterialCode = ISNULL(SourceTable.MaterialCode,TargetTable.MaterialCode),
					BomVersion = ISNULL(SourceTable.BomVersion,TargetTable.BomVersion),
					ProdPlanDate = ISNULL(SourceTable.ProdPlanDate,TargetTable.ProdPlanDate),
					PlanQty = ISNULL(SourceTable.PlanQty,TargetTable.PlanQty),
					AdjustQty = ISNULL(SourceTable.AdjustQty,TargetTable.AdjustQty),
					FixedQty = ISNULL(SourceTable.FixedQty,TargetTable.FixedQty),
					IsNotInclude = ISNULL(SourceTable.IsNotInclude,TargetTable.IsNotInclude),
					ChangeDateTime = ISNULL(SourceTable.ChangeDateTime,TargetTable.ChangeDateTime),
					ChangeUserID = ISNULL(SourceTable.ChangeUserID,TargetTable.ChangeUserID)
			WHEN NOT MATCHED THEN
				INSERT
					(
						MrpSourceNo,
						MrpNo,
						MaterialCode,
						BomVersion,
						ProdPlanDate,
						PlanQty,
						AdjustQty,
						FixedQty,
						IsNotInclude,
						CreateDateTime,
						CreateUserID
					)
				VALUES
					(
							SourceTable.MrpSourceNo,
							SourceTable.MrpNo,
							SourceTable.MaterialCode,
							SourceTable.BomVersion,
							SourceTable.ProdPlanDate,
							SourceTable.PlanQty,
							SourceTable.AdjustQty,
							SourceTable.FixedQty,
							SourceTable.IsNotInclude,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID
					);


			-- Process Update Table
            MERGE STB_MrpSourceMaterial AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldMrpSourceNo IS NULL THEN MrpSourceNo
							    ELSE OldMrpSourceNo
							END AS OldMrpSourceNo,
							MrpSourceNo,
							MrpNo,
							MaterialCode,
							BomVersion,
							ProdPlanDate,
							PlanQty,
							AdjustQty,
							FixedQty,
							IsNotInclude,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @UpdateTableName , 2)
							WITH  (
										OldMrpSourceNo VARCHAR(20),
										MrpSourceNo VARCHAR(20),
										MrpNo VARCHAR(20),
										MaterialCode VARCHAR(50),
										BomVersion VARCHAR(20),
										ProdPlanDate DATETIMEOFFSET,
										PlanQty NUMERIC(20,5),
										AdjustQty NUMERIC(20,5),
										FixedQty NUMERIC(20,5),
										IsNotInclude BIT,
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.MrpSourceNo = SourceTable.OldMrpSourceNo
				)

			WHEN MATCHED THEN
				UPDATE SET
					MrpSourceNo = ISNULL(SourceTable.MrpSourceNo,TargetTable.MrpSourceNo),
					MrpNo = ISNULL(SourceTable.MrpNo,TargetTable.MrpNo),
					MaterialCode = ISNULL(SourceTable.MaterialCode,TargetTable.MaterialCode),
					BomVersion = ISNULL(SourceTable.BomVersion,TargetTable.BomVersion),
					ProdPlanDate = ISNULL(SourceTable.ProdPlanDate,TargetTable.ProdPlanDate),
					PlanQty = ISNULL(SourceTable.PlanQty,TargetTable.PlanQty),
					AdjustQty = ISNULL(SourceTable.AdjustQty,TargetTable.AdjustQty),
					FixedQty = ISNULL(SourceTable.FixedQty,TargetTable.FixedQty),
					IsNotInclude = ISNULL(SourceTable.IsNotInclude,TargetTable.IsNotInclude),
					ChangeDateTime = ISNULL(SourceTable.ChangeDateTime,TargetTable.ChangeDateTime),
					ChangeUserID = ISNULL(SourceTable.ChangeUserID,TargetTable.ChangeUserID)
			WHEN NOT MATCHED THEN
				INSERT
					(
						MrpSourceNo,
						MrpNo,
						MaterialCode,
						BomVersion,
						ProdPlanDate,
						PlanQty,
						AdjustQty,
						FixedQty,
						IsNotInclude,
						CreateDateTime,
						CreateUserID
					)
				VALUES
					(
							SourceTable.MrpSourceNo,
							SourceTable.MrpNo,
							SourceTable.MaterialCode,
							SourceTable.BomVersion,
							SourceTable.ProdPlanDate,
							SourceTable.PlanQty,
							SourceTable.AdjustQty,
							SourceTable.FixedQty,
							SourceTable.IsNotInclude,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID
					);


			-- Process Delete Table
            MERGE STB_MrpSourceMaterial AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldMrpSourceNo IS NULL THEN MrpSourceNo
							    ELSE OldMrpSourceNo
							END AS OldMrpSourceNo,
							MrpSourceNo,
							MrpNo,
							MaterialCode,
							BomVersion,
							ProdPlanDate,
							PlanQty,
							AdjustQty,
							FixedQty,
							IsNotInclude,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @DeleteTableName , 2)
							WITH  (
										OldMrpSourceNo VARCHAR(20),
										MrpSourceNo VARCHAR(20),
										MrpNo VARCHAR(20),
										MaterialCode VARCHAR(50),
										BomVersion VARCHAR(20),
										ProdPlanDate DATETIMEOFFSET,
										PlanQty NUMERIC(20,5),
										AdjustQty NUMERIC(20,5),
										FixedQty NUMERIC(20,5),
										IsNotInclude BIT,
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.MrpSourceNo = SourceTable.MrpSourceNo
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
									OldMrpSourceNo,
									MrpSourceNo,
									MrpNo,
									MaterialCode,
									BomVersion,
									ProdPlanDate,
									PlanQty,
									AdjustQty,
									FixedQty,
									IsNotInclude,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID
							FROM
									OPENXML(@idoc , @InsertTableName , 2)
							        WITH  (
											 OldMrpSourceNo VARCHAR(20),
											 MrpSourceNo VARCHAR(20),
											 MrpNo VARCHAR(20),
											 MaterialCode VARCHAR(50),
											 BomVersion VARCHAR(20),
											 ProdPlanDate DATETIMEOFFSET,
											 PlanQty NUMERIC(20,5),
											 AdjustQty NUMERIC(20,5),
											 FixedQty NUMERIC(20,5),
											 IsNotInclude BIT,
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											)
							UNION ALL
							SELECT
									'UPDATE' AS IUD_FLAG,
									CASE 
										WHEN OldMrpSourceNo IS NULL THEN MrpSourceNo
										ELSE OldMrpSourceNo
									END AS OldMrpSourceNo,
									MrpSourceNo,
									MrpNo,
									MaterialCode,
									BomVersion,
									ProdPlanDate,
									PlanQty,
									AdjustQty,
									FixedQty,
									IsNotInclude,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID
							FROM
									OPENXML(@idoc , @UpdateTableName , 2)
							        WITH  (
											 OldMrpSourceNo VARCHAR(20),
											 MrpSourceNo VARCHAR(20),
											 MrpNo VARCHAR(20),
											 MaterialCode VARCHAR(50),
											 BomVersion VARCHAR(20),
											 ProdPlanDate DATETIMEOFFSET,
											 PlanQty NUMERIC(20,5),
											 AdjustQty NUMERIC(20,5),
											 FixedQty NUMERIC(20,5),
											 IsNotInclude BIT,
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											)
							UNION ALL
							SELECT
									'DELETE' AS IUD_FLAG,
									CASE 
										WHEN OldMrpSourceNo IS NULL THEN MrpSourceNo
										ELSE OldMrpSourceNo
									END AS OldMrpSourceNo,
									MrpSourceNo,
									MrpNo,
									MaterialCode,
									BomVersion,
									ProdPlanDate,
									PlanQty,
									AdjustQty,
									FixedQty,
									IsNotInclude,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID
							FROM
									OPENXML(@idoc , @DeleteTableName , 2)
							        WITH  (
											 OldMrpSourceNo VARCHAR(20),
											 MrpSourceNo VARCHAR(20),
											 MrpNo VARCHAR(20),
											 MaterialCode VARCHAR(50),
											 BomVersion VARCHAR(20),
											 ProdPlanDate DATETIMEOFFSET,
											 PlanQty NUMERIC(20,5),
											 AdjustQty NUMERIC(20,5),
											 FixedQty NUMERIC(20,5),
											 IsNotInclude BIT,
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											) 


            OPEN SourceData

            WHILE 1 = 1 BEGIN
                FETCH NEXT FROM SourceData INTO
								 @IUD_FLAG,
								 @OldMrpSourceNo,
								 @MrpSourceNo,
								 @MrpNo,
								 @MaterialCode,
								 @BomVersion,
								 @ProdPlanDate,
								 @PlanQty,
								 @AdjustQty,
								 @FixedQty,
								 @IsNotInclude,
								 @CreateDateTime,
								 @CreateUserID,
								 @ChangeDateTime,
								 @ChangeUserID


                IF @@FETCH_STATUS <> 0 BEGIN
					BREAK
				END

				SELECT
						@BefIsFixed = MM.IsFixedMRP
				FROM
						STB_MrpMaster MM
				WHERE
						MM.MrpNo = @MrpNo

				IF ISNULL(@BefIsFixed, CONVERT(BIT, 0)) = CONVERT(BIT, 1)
				BEGIN
						RAISERROR('확정된 문서는 수정할 수 없습니다.', 16, 1, @MrpNo)
						RETURN
				END


                IF @IUD_FLAG = 'INSERT' BEGIN

                    IF EXISTS (SELECT 1 FROM STB_MrpSourceMaterial WHERE MrpSourceNo = @MrpSourceNo) BEGIN
						RAISERROR('Duplicate Data : KeyField = %s', 16, 1, @MrpSourceNo)
					END

                    IF @IsAutoKey = 1 BEGIN
						EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_MrpSourceMaterial', @MrpSourceNo OUTPUT
                    END

                    INSERT INTO STB_MrpSourceMaterial
						(
						    MrpSourceNo,
						    MrpNo,
						    MaterialCode,
						    BomVersion,
						    ProdPlanDate,
						    PlanQty,
						    AdjustQty,
						    FixedQty,
						    IsNotInclude,
						    CreateDateTime,
						    CreateUserID,
						    ChangeDateTime,
						    ChangeUserID
						)
						VALUES
						(
						    @MrpSourceNo,
						    @MrpNo,
						    @MaterialCode,
						    @BomVersion,
						    @ProdPlanDate,
						    @PlanQty,
						    @AdjustQty,
						    ISNULL(@PlanQty,0) + ISNULL(@AdjustQty,0),
						    @IsNotInclude,
						    GETDATE(),
						    @pProcessUserID,
						    @ChangeDateTime,
						    @ChangeUserID
						)

				END ELSE IF @IUD_FLAG = 'UPDATE' BEGIN
                    UPDATE STB_MrpSourceMaterial
						SET
						    MrpSourceNo =   ISNULL(@MrpSourceNo,MrpSourceNo),
						    MrpNo =   ISNULL(@MrpNo,MrpNo),
						    MaterialCode =   ISNULL(@MaterialCode,MaterialCode),
						    BomVersion =   ISNULL(@BomVersion,BomVersion),
						    ProdPlanDate =   ISNULL(@ProdPlanDate,ProdPlanDate),
						    PlanQty =   ISNULL(@PlanQty,PlanQty),
						    AdjustQty =   ISNULL(@AdjustQty,AdjustQty),
						    FixedQty =   ISNULL(@PlanQty,0) + ISNULL(@AdjustQty,0),
						    IsNotInclude =   ISNULL(@IsNotInclude,IsNotInclude),
						    CreateDateTime =   ISNULL(@CreateDateTime,CreateDateTime),
						    CreateUserID =   ISNULL(@CreateUserID,CreateUserID),
						    ChangeDateTime = GETDATE(),
						    ChangeUserID = @pProcessUserID
						WHERE
						    MrpSourceNo = @OldMrpSourceNo
                END ELSE IF @IUD_FLAG = 'DELETE' BEGIN
                    DELETE FROM STB_MrpSourceMaterial
						WHERE
						    MrpSourceNo = @MrpSourceNo
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

