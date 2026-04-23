

-- =============================================
-- Author:	    Kim Han Young(hykim@awoo.co.kr)
-- Create date: 2016-07-29
-- Browsable : true
-- Group : 자재관리
-- Description:	MRP 전개정보를 INSERT/UPDATE/DELETE 합니다.
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_MrpTargetMaterial_iud]
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
  DECLARE @OldMrpTargetNo VARCHAR(20)
  DECLARE @MrpTargetNo VARCHAR(20)
  DECLARE @MrpNo VARCHAR(20)
  DECLARE @MaterialCode VARCHAR(50)
  DECLARE @CalcQty NUMERIC(20,5)
  DECLARE @AdjustQty NUMERIC(20,5)
  DECLARE @FixedQty NUMERIC(20,5)
  DECLARE @ProdPlanDate DATE
  DECLARE @AgvGrDay INT
  DECLARE @PlanOrderDate DATE
  DECLARE @CustomerCode VARCHAR(20)
  DECLARE @MaterialOrderNo VARCHAR(20)
  DECLARE @MaterialOrderItemNo VARCHAR(20)
  DECLARE @PlanGrDate DATE
  DECLARE @CreateDateTime DATETIME
  DECLARE @CreateUserID VARCHAR(20)
  DECLARE @ChangeDateTime DATETIME
  DECLARE @ChangeUserID VARCHAR(20)

  DECLARE @BefIsFixed BIT


	DECLARE @iDoc INT

    EXEC SmartFramework.dbo.usp_GetSerialRule 
			@pTableName = 'STB_MrpTargetMaterial',
			@pIsAutoKey = @IsAutoKey OUTPUT,
			@pIsLoopIUD = @IsLoopIUD OUTPUT,
			@pPrefixData = @PrefixString OUTPUT,
			@pSerialLen = @SerialLen OUTPUT
    
    IF @IsAutoKey = 0 AND @IsLoopIUD = 0 BEGIN
   
	    EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
	
	    BEGIN TRY
			-- Process Insert Table
            MERGE STB_MrpTargetMaterial AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldMrpTargetNo IS NULL THEN MrpTargetNo
							    ELSE OldMrpTargetNo
							END AS OldMrpTargetNo,
							MrpTargetNo,
							MrpNo,
							MaterialCode,
							CalcQty,
							AdjustQty,
							FixedQty,
							ProdPlanDate,
							AgvGrDay,
							PlanOrderDate,
							CustomerCode,
							MaterialOrderNo,
							MaterialOrderItemNo,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @InsertTableName , 2)
							WITH  (
										OldMrpTargetNo VARCHAR(20),
										MrpTargetNo VARCHAR(20),
										MrpNo VARCHAR(20),
										MaterialCode VARCHAR(50),
										CalcQty NUMERIC(20,5),
										AdjustQty NUMERIC(20,5),
										FixedQty NUMERIC(20,5),
										ProdPlanDate DATETIMEOFFSET,
										AgvGrDay INT,
										PlanOrderDate DATETIMEOFFSET,
										CustomerCode VARCHAR(20),
										MaterialOrderNo VARCHAR(20),
										MaterialOrderItemNo VARCHAR(20),
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.MrpTargetNo = SourceTable.MrpTargetNo
				)

			WHEN MATCHED THEN
				UPDATE SET
					MrpTargetNo = ISNULL(SourceTable.MrpTargetNo,TargetTable.MrpTargetNo),
					MrpNo = ISNULL(SourceTable.MrpNo,TargetTable.MrpNo),
					MaterialCode = ISNULL(SourceTable.MaterialCode,TargetTable.MaterialCode),
					CalcQty = ISNULL(SourceTable.CalcQty,TargetTable.CalcQty),
					AdjustQty = ISNULL(SourceTable.AdjustQty,TargetTable.AdjustQty),
					FixedQty = ISNULL(SourceTable.FixedQty,TargetTable.FixedQty),
					ProdPlanDate = ISNULL(SourceTable.ProdPlanDate,TargetTable.ProdPlanDate),
					AgvGrDay = ISNULL(SourceTable.AgvGrDay,TargetTable.AgvGrDay),
					PlanOrderDate = ISNULL(SourceTable.PlanOrderDate,TargetTable.PlanOrderDate),
					CustomerCode = ISNULL(SourceTable.CustomerCode,TargetTable.CustomerCode),
					MaterialOrderNo = ISNULL(SourceTable.MaterialOrderNo,TargetTable.MaterialOrderNo),
					MaterialOrderItemNo = ISNULL(SourceTable.MaterialOrderItemNo,TargetTable.MaterialOrderItemNo),
					ChangeDateTime = ISNULL(SourceTable.ChangeDateTime,TargetTable.ChangeDateTime),
					ChangeUserID = ISNULL(SourceTable.ChangeUserID,TargetTable.ChangeUserID)
			WHEN NOT MATCHED THEN
				INSERT
					(
						MrpTargetNo,
						MrpNo,
						MaterialCode,
						CalcQty,
						AdjustQty,
						FixedQty,
						ProdPlanDate,
						AgvGrDay,
						PlanOrderDate,
						CustomerCode,
						MaterialOrderNo,
						MaterialOrderItemNo,
						CreateDateTime,
						CreateUserID
					)
				VALUES
					(
							SourceTable.MrpTargetNo,
							SourceTable.MrpNo,
							SourceTable.MaterialCode,
							SourceTable.CalcQty,
							SourceTable.AdjustQty,
							SourceTable.FixedQty,
							SourceTable.ProdPlanDate,
							SourceTable.AgvGrDay,
							SourceTable.PlanOrderDate,
							SourceTable.CustomerCode,
							SourceTable.MaterialOrderNo,
							SourceTable.MaterialOrderItemNo,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID
					);


			-- Process Update Table
            MERGE STB_MrpTargetMaterial AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldMrpTargetNo IS NULL THEN MrpTargetNo
							    ELSE OldMrpTargetNo
							END AS OldMrpTargetNo,
							MrpTargetNo,
							MrpNo,
							MaterialCode,
							CalcQty,
							AdjustQty,
							FixedQty,
							ProdPlanDate,
							AgvGrDay,
							PlanOrderDate,
							CustomerCode,
							MaterialOrderNo,
							MaterialOrderItemNo,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @UpdateTableName , 2)
							WITH  (
										OldMrpTargetNo VARCHAR(20),
										MrpTargetNo VARCHAR(20),
										MrpNo VARCHAR(20),
										MaterialCode VARCHAR(50),
										CalcQty NUMERIC(20,5),
										AdjustQty NUMERIC(20,5),
										FixedQty NUMERIC(20,5),
										ProdPlanDate DATETIMEOFFSET,
										AgvGrDay INT,
										PlanOrderDate DATETIMEOFFSET,
										CustomerCode VARCHAR(20),
										MaterialOrderNo VARCHAR(20),
										MaterialOrderItemNo VARCHAR(20),
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.MrpTargetNo = SourceTable.OldMrpTargetNo
				)

			WHEN MATCHED THEN
				UPDATE SET
					MrpTargetNo = ISNULL(SourceTable.MrpTargetNo,TargetTable.MrpTargetNo),
					MrpNo = ISNULL(SourceTable.MrpNo,TargetTable.MrpNo),
					MaterialCode = ISNULL(SourceTable.MaterialCode,TargetTable.MaterialCode),
					CalcQty = ISNULL(SourceTable.CalcQty,TargetTable.CalcQty),
					AdjustQty = ISNULL(SourceTable.AdjustQty,TargetTable.AdjustQty),
					FixedQty = ISNULL(SourceTable.FixedQty,TargetTable.FixedQty),
					ProdPlanDate = ISNULL(SourceTable.ProdPlanDate,TargetTable.ProdPlanDate),
					AgvGrDay = ISNULL(SourceTable.AgvGrDay,TargetTable.AgvGrDay),
					PlanOrderDate = ISNULL(SourceTable.PlanOrderDate,TargetTable.PlanOrderDate),
					CustomerCode = ISNULL(SourceTable.CustomerCode,TargetTable.CustomerCode),
					MaterialOrderNo = ISNULL(SourceTable.MaterialOrderNo,TargetTable.MaterialOrderNo),
					MaterialOrderItemNo = ISNULL(SourceTable.MaterialOrderItemNo,TargetTable.MaterialOrderItemNo),
					ChangeDateTime = ISNULL(SourceTable.ChangeDateTime,TargetTable.ChangeDateTime),
					ChangeUserID = ISNULL(SourceTable.ChangeUserID,TargetTable.ChangeUserID)
			WHEN NOT MATCHED THEN
				INSERT
					(
						MrpTargetNo,
						MrpNo,
						MaterialCode,
						CalcQty,
						AdjustQty,
						FixedQty,
						ProdPlanDate,
						AgvGrDay,
						PlanOrderDate,
						CustomerCode,
						MaterialOrderNo,
						MaterialOrderItemNo,
						CreateDateTime,
						CreateUserID
					)
				VALUES
					(
							SourceTable.MrpTargetNo,
							SourceTable.MrpNo,
							SourceTable.MaterialCode,
							SourceTable.CalcQty,
							SourceTable.AdjustQty,
							SourceTable.FixedQty,
							SourceTable.ProdPlanDate,
							SourceTable.AgvGrDay,
							SourceTable.PlanOrderDate,
							SourceTable.CustomerCode,
							SourceTable.MaterialOrderNo,
							SourceTable.MaterialOrderItemNo,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID
					);


			-- Process Delete Table
            MERGE STB_MrpTargetMaterial AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldMrpTargetNo IS NULL THEN MrpTargetNo
							    ELSE OldMrpTargetNo
							END AS OldMrpTargetNo,
							MrpTargetNo,
							MrpNo,
							MaterialCode,
							CalcQty,
							AdjustQty,
							FixedQty,
							ProdPlanDate,
							AgvGrDay,
							PlanOrderDate,
							CustomerCode,
							MaterialOrderNo,
							MaterialOrderItemNo,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @DeleteTableName , 2)
							WITH  (
										OldMrpTargetNo VARCHAR(20),
										MrpTargetNo VARCHAR(20),
										MrpNo VARCHAR(20),
										MaterialCode VARCHAR(50),
										CalcQty NUMERIC(20,5),
										AdjustQty NUMERIC(20,5),
										FixedQty NUMERIC(20,5),
										ProdPlanDate DATETIMEOFFSET,
										AgvGrDay INT,
										PlanOrderDate DATETIMEOFFSET,
										CustomerCode VARCHAR(20),
										MaterialOrderNo VARCHAR(20),
										MaterialOrderItemNo VARCHAR(20),
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.MrpTargetNo = SourceTable.MrpTargetNo
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
									OldMrpTargetNo,
									MrpTargetNo,
									MrpNo,
									MaterialCode,
									CalcQty,
									AdjustQty,
									FixedQty,
									ProdPlanDate,
									AgvGrDay,
									PlanOrderDate,
									CustomerCode,
									MaterialOrderNo,
									MaterialOrderItemNo,
									PlanGrDate,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID
							FROM
									OPENXML(@idoc , @InsertTableName , 2)
							        WITH  (
											 OldMrpTargetNo VARCHAR(20),
											 MrpTargetNo VARCHAR(20),
											 MrpNo VARCHAR(20),
											 MaterialCode VARCHAR(50),
											 CalcQty NUMERIC(20,5),
											 AdjustQty NUMERIC(20,5),
											 FixedQty NUMERIC(20,5),
											 ProdPlanDate DATETIMEOFFSET,
											 AgvGrDay INT,
											 PlanOrderDate DATETIMEOFFSET,
											 CustomerCode VARCHAR(20),
											 MaterialOrderNo VARCHAR(20),
											 MaterialOrderItemNo VARCHAR(20),
											 PlanGrDate DATETIMEOFFSET,
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											)
							UNION ALL
							SELECT
									'UPDATE' AS IUD_FLAG,
									CASE 
										WHEN OldMrpTargetNo IS NULL THEN MrpTargetNo
										ELSE OldMrpTargetNo
									END AS OldMrpTargetNo,
									MrpTargetNo,
									MrpNo,
									MaterialCode,
									CalcQty,
									AdjustQty,
									FixedQty,
									ProdPlanDate,
									AgvGrDay,
									PlanOrderDate,
									CustomerCode,
									MaterialOrderNo,
									MaterialOrderItemNo,
									PlanGrDate,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID
							FROM
									OPENXML(@idoc , @UpdateTableName , 2)
							        WITH  (
											 OldMrpTargetNo VARCHAR(20),
											 MrpTargetNo VARCHAR(20),
											 MrpNo VARCHAR(20),
											 MaterialCode VARCHAR(50),
											 CalcQty NUMERIC(20,5),
											 AdjustQty NUMERIC(20,5),
											 FixedQty NUMERIC(20,5),
											 ProdPlanDate DATETIMEOFFSET,
											 AgvGrDay INT,
											 PlanOrderDate DATETIMEOFFSET,
											 CustomerCode VARCHAR(20),
											 MaterialOrderNo VARCHAR(20),
											 MaterialOrderItemNo VARCHAR(20),
											 PlanGrDate DATETIMEOFFSET,
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											)
							UNION ALL
							SELECT
									'DELETE' AS IUD_FLAG,
									CASE 
										WHEN OldMrpTargetNo IS NULL THEN MrpTargetNo
										ELSE OldMrpTargetNo
									END AS OldMrpTargetNo,
									MrpTargetNo,
									MrpNo,
									MaterialCode,
									CalcQty,
									AdjustQty,
									FixedQty,
									ProdPlanDate,
									AgvGrDay,
									PlanOrderDate,
									CustomerCode,
									MaterialOrderNo,
									MaterialOrderItemNo,
									PlanGrDate,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID
							FROM
									OPENXML(@idoc , @DeleteTableName , 2)
							        WITH  (
											 OldMrpTargetNo VARCHAR(20),
											 MrpTargetNo VARCHAR(20),
											 MrpNo VARCHAR(20),
											 MaterialCode VARCHAR(50),
											 CalcQty NUMERIC(20,5),
											 AdjustQty NUMERIC(20,5),
											 FixedQty NUMERIC(20,5),
											 ProdPlanDate DATETIMEOFFSET,
											 AgvGrDay INT,
											 PlanOrderDate DATETIMEOFFSET,
											 CustomerCode VARCHAR(20),
											 MaterialOrderNo VARCHAR(20),
											 MaterialOrderItemNo VARCHAR(20),
											 PlanGrDate DATETIMEOFFSET,
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											) 


            OPEN SourceData

            WHILE 1 = 1 BEGIN
                FETCH NEXT FROM SourceData INTO
								 @IUD_FLAG,
								 @OldMrpTargetNo,
								 @MrpTargetNo,
								 @MrpNo,
								 @MaterialCode,
								 @CalcQty,
								 @AdjustQty,
								 @FixedQty,
								 @ProdPlanDate,
								 @AgvGrDay,
								 @PlanOrderDate,
								 @CustomerCode,
								 @MaterialOrderNo,
								 @MaterialOrderItemNo,
								 @PlanGrDate,
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

                    IF EXISTS (SELECT 1 FROM STB_MrpTargetMaterial WHERE MrpTargetNo = @MrpTargetNo) BEGIN
						RAISERROR('Duplicate Data : KeyField = %s', 16, 1, @MrpTargetNo)
					END

                    IF @IsAutoKey = 1 BEGIN
						EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_MrpTargetMaterial', @MrpTargetNo OUTPUT
                    END

                    INSERT INTO STB_MrpTargetMaterial
						(
						    MrpTargetNo,
						    MrpNo,
						    MaterialCode,
						    CalcQty,
						    AdjustQty,
						    FixedQty,
						    ProdPlanDate,
						    AgvGrDay,
						    PlanOrderDate,
						    CustomerCode,
						    MaterialOrderNo,
						    MaterialOrderItemNo,
							PlanGrDate,
						    CreateDateTime,
						    CreateUserID,
						    ChangeDateTime,
						    ChangeUserID
						)
						VALUES
						(
						    @MrpTargetNo,
						    @MrpNo,
						    @MaterialCode,
						    @CalcQty,
						    @AdjustQty,
						    @FixedQty,
						    @ProdPlanDate,
						    @AgvGrDay,
						    @PlanOrderDate,
						    @CustomerCode,
						    @MaterialOrderNo,
						    @MaterialOrderItemNo,
							@PlanGrDate,
						    GETDATE(),
						    @pProcessUserID,
						    @ChangeDateTime,
						    @ChangeUserID
						)

				END ELSE IF @IUD_FLAG = 'UPDATE' BEGIN
                    UPDATE STB_MrpTargetMaterial
						SET
						    MrpTargetNo =   ISNULL(@MrpTargetNo,MrpTargetNo),
						    MrpNo =   ISNULL(@MrpNo,MrpNo),
						    MaterialCode =   ISNULL(@MaterialCode,MaterialCode),
						    CalcQty =   ISNULL(@CalcQty,CalcQty),
						    AdjustQty =   ISNULL(@AdjustQty,AdjustQty),
						    FixedQty =   ISNULL(@FixedQty,FixedQty),
						    ProdPlanDate =   ISNULL(@ProdPlanDate,ProdPlanDate),
						    AgvGrDay =   ISNULL(@AgvGrDay,AgvGrDay),
						    PlanOrderDate =   ISNULL(@PlanOrderDate,PlanOrderDate),
						    CustomerCode =   ISNULL(@CustomerCode,CustomerCode),
							PlanGrDate =	ISNULL(@PlanGrDate,PlanGrDate),
						    MaterialOrderNo =   ISNULL(@MaterialOrderNo,MaterialOrderNo),
						    MaterialOrderItemNo =   ISNULL(@MaterialOrderItemNo,MaterialOrderItemNo),
						    CreateDateTime =   ISNULL(@CreateDateTime,CreateDateTime),
						    CreateUserID =   ISNULL(@CreateUserID,CreateUserID),
						    ChangeDateTime = GETDATE(),
						    ChangeUserID = @pProcessUserID
						WHERE
						    MrpTargetNo = @OldMrpTargetNo
                END ELSE IF @IUD_FLAG = 'DELETE' BEGIN
                    DELETE FROM STB_MrpTargetMaterial
						WHERE
						    MrpTargetNo = @MrpTargetNo
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

