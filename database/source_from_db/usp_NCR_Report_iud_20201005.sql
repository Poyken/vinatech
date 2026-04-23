
-- =============================================
-- Author:	    Anonymous()
-- Create date: 2020-09-07
-- Browsable : true
-- Group : 품질관리 > 시료별수입검사> NCR등록
-- Description:	
-- Modified:
-- =============================================
Create PROCEDURE [dbo].[usp_NCR_Report_iud_20201005]
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
  DECLARE @OldNCRNo VARCHAR(20)
  DECLARE @NCRNo VARCHAR(20)
  DECLARE @JobDate DATETIME
  DECLARE @CompanyCode VARCHAR(20)
  DECLARE @OccurProcessCode VARCHAR(20)
  DECLARE @MaterialName VARCHAR(80)
  DECLARE @CustomName VARCHAR(60)
  DECLARE @standardName VARCHAR(60)
  DECLARE @LotNo VARCHAR(80)
  DECLARE @Qty INT
  DECLARE @InspectionQty INT
  DECLARE @BadQty INT
  DECLARE @PPM INT
  DECLARE @InQty INT
  DECLARE @BadLotQty INT
  DECLARE @DefectiveRate NUMERIC(5,2)
  DECLARE @CreateUserID VARCHAR(20)
  DECLARE @Nonconformity NVARCHAR(4000)
  DECLARE @ImmediateAction NVARCHAR(4000)
  DECLARE @CustomImmediateAction NVARCHAR(4000)
  
  DECLARE @IsActionCode BIT
  DECLARE @EffectivenessCheck BIT
  DECLARE @DefectImage VARBINARY(MAX)
  DECLARE @DefectImage2 VARBINARY(MAX)
  DECLARE @CreateDateTime DATETIME

  -- 2020.10.05 추가 및 수정
    DECLARE @CustomCountermeasureImage BIGINT  	
	DECLARE @FileName NVARCHAR(255)
	DECLARE @FileSize BIGINT
	DECLARE @FileData VARBINARY(MAX)



	DECLARE @iDoc INT

    EXEC usp_GetSerialRule 
			@pTableName = 'STB_NCR_Report',
			@pIsAutoKey = @IsAutoKey OUTPUT,
			@pIsLoopIUD = @IsLoopIUD OUTPUT,
			@pPrefixData = @PrefixString OUTPUT,
			@pSerialLen = @SerialLen OUTPUT
    
    IF @IsAutoKey = 0 AND @IsLoopIUD = 0 BEGIN
        
        EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
	
	    BEGIN TRY
			-- Process Insert Table
            MERGE STB_NCR_Report AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldNCRNo IS NULL THEN NCRNo
							    ELSE OldNCRNo
							END AS OldNCRNo,
							NCRNo,
							JobDate,
							CompanyCode,
							OccurProcessCode,
							MaterialName,
							CustomName,
							standardName,
							LotNo,
							Qty,
							InspectionQty,
							BadQty,
							PPM,
							InQty,
							BadLotQty,
							DefectiveRate,
							@pProcessUserID AS CreateUserID,
							Nonconformity,
							ImmediateAction,
							CustomImmediateAction,
							dbo.fnBase64ToBinary(CustomCountermeasureImage) as CustomCountermeasureImage,
							IsActionCode,
							EffectivenessCheck,
							dbo.fnBase64ToBinary(DefectImage) as DefectImage,
							dbo.fnBase64ToBinary(DefectImage2) as DefectImage2,
							GETDATE() AS CreateDateTime
					FROM
							OPENXML(@idoc , @InsertTableName , 2)
							WITH  (
										OldNCRNo VARCHAR(20),
										NCRNo VARCHAR(20),
										JobDate DATETIMEOFFSET,
										CompanyCode VARCHAR(20),
										OccurProcessCode VARCHAR(20),
										MaterialName VARCHAR(80),
										CustomName VARCHAR(60),
										standardName VARCHAR(60),
										LotNo VARCHAR(80),
										Qty INT,
										InspectionQty INT,
										BadQty INT,
										PPM INT,
										InQty INT,
										BadLotQty INT,
										DefectiveRate NUMERIC(5,2),
										CreateUserID VARCHAR(20),
										Nonconformity NVARCHAR(4000),
										ImmediateAction NVARCHAR(4000),
										CustomImmediateAction NVARCHAR(4000),
										CustomCountermeasureImage NVARCHAR(MAX),
										IsActionCode BIT,
										EffectivenessCheck BIT,
										DefectImage NVARCHAR(MAX),
										DefectImage2 NVARCHAR(MAX),
										CreateDateTime DATETIMEOFFSET
									) 
				) AS SourceTable
			ON
				(
					TargetTable.NCRNo = SourceTable.NCRNo
				)

			WHEN MATCHED THEN
				UPDATE SET
					NCRNo = ISNULL(SourceTable.NCRNo,TargetTable.NCRNo),
					JobDate = ISNULL(SourceTable.JobDate,TargetTable.JobDate),
					CompanyCode = ISNULL(SourceTable.CompanyCode,TargetTable.CompanyCode),
					OccurProcessCode = ISNULL(SourceTable.OccurProcessCode,TargetTable.OccurProcessCode),
					MaterialName = ISNULL(SourceTable.MaterialName,TargetTable.MaterialName),
					CustomName = ISNULL(SourceTable.CustomName,TargetTable.CustomName),
					standardName = ISNULL(SourceTable.standardName,TargetTable.standardName),
					LotNo = ISNULL(SourceTable.LotNo,TargetTable.LotNo),
					Qty = ISNULL(SourceTable.Qty,TargetTable.Qty),
					InspectionQty = ISNULL(SourceTable.InspectionQty,TargetTable.InspectionQty),
					BadQty = ISNULL(SourceTable.BadQty,TargetTable.BadQty),
					PPM = ISNULL(SourceTable.PPM,TargetTable.PPM),
					InQty = ISNULL(SourceTable.InQty,TargetTable.InQty),
					BadLotQty = ISNULL(SourceTable.BadLotQty,TargetTable.BadLotQty),
					DefectiveRate = ISNULL(SourceTable.DefectiveRate,TargetTable.DefectiveRate),
					Nonconformity = ISNULL(SourceTable.Nonconformity,TargetTable.Nonconformity),
					ImmediateAction = ISNULL(SourceTable.ImmediateAction,TargetTable.ImmediateAction),
					CustomImmediateAction = ISNULL(SourceTable.CustomImmediateAction,TargetTable.CustomImmediateAction),
					CustomCountermeasureImage = ISNULL(SourceTable.CustomCountermeasureImage,TargetTable.CustomCountermeasureImage),
					IsActionCode = ISNULL(SourceTable.IsActionCode,TargetTable.IsActionCode),
					EffectivenessCheck = ISNULL(SourceTable.EffectivenessCheck,TargetTable.EffectivenessCheck),
					DefectImage = ISNULL(SourceTable.DefectImage,TargetTable.DefectImage),
					DefectImage2 = ISNULL(SourceTable.DefectImage2,TargetTable.DefectImage2)
			WHEN NOT MATCHED THEN
				INSERT
					(
						NCRNo,
						JobDate,
						CompanyCode,
						OccurProcessCode,
						MaterialName,
						CustomName,
						standardName,
						LotNo,
						Qty,
						InspectionQty,
						BadQty,
						PPM,
						InQty,
						BadLotQty,
						DefectiveRate,
						CreateUserID,
						Nonconformity,
						ImmediateAction,
						CustomImmediateAction,
						CustomCountermeasureImage,
						IsActionCode,
						EffectivenessCheck,
						DefectImage,
						DefectImage2,
						CreateDateTime
					)
				VALUES
					(
							SourceTable.NCRNo,
							SourceTable.JobDate,
							SourceTable.CompanyCode,
							SourceTable.OccurProcessCode,
							SourceTable.MaterialName,
							SourceTable.CustomName,
							SourceTable.standardName,
							SourceTable.LotNo,
							SourceTable.Qty,
							SourceTable.InspectionQty,
							SourceTable.BadQty,
							SourceTable.PPM,
							SourceTable.InQty,
							SourceTable.BadLotQty,
							SourceTable.DefectiveRate,
							SourceTable.CreateUserID,
							SourceTable.Nonconformity,
							SourceTable.ImmediateAction,
							SourceTable.CustomImmediateAction,
							SourceTable.CustomCountermeasureImage,
							SourceTable.IsActionCode,
							SourceTable.EffectivenessCheck,
							SourceTable.DefectImage,
							SourceTable.DefectImage2,
							SourceTable.CreateDateTime
					);


			-- Process Update Table
            MERGE STB_NCR_Report AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldNCRNo IS NULL THEN NCRNo
							    ELSE OldNCRNo
							END AS OldNCRNo,
							NCRNo,
							JobDate,
							CompanyCode,
							OccurProcessCode,
							MaterialName,
							CustomName,
							standardName,
							LotNo,
							Qty,
							InspectionQty,
							BadQty,
							PPM,
							InQty,
							BadLotQty,
							DefectiveRate,
							@pProcessUserID AS CreateUserID,
							Nonconformity,
							ImmediateAction,
							CustomImmediateAction,
							dbo.fnBase64ToBinary(CustomCountermeasureImage) as CustomCountermeasureImage,
							IsActionCode,
							EffectivenessCheck,
							dbo.fnBase64ToBinary(DefectImage) as DefectImage,
							dbo.fnBase64ToBinary(DefectImage2) as DefectImage2,
							GETDATE() AS CreateDateTime
					FROM
							OPENXML(@idoc , @UpdateTableName , 2)
							WITH  (
										OldNCRNo VARCHAR(20),
										NCRNo VARCHAR(20),
										JobDate DATETIMEOFFSET,
										CompanyCode VARCHAR(20),
										OccurProcessCode VARCHAR(20),
										MaterialName VARCHAR(80),
										CustomName VARCHAR(60),
										standardName VARCHAR(60),
										LotNo VARCHAR(80),
										Qty INT,
										InspectionQty INT,
										BadQty INT,
										PPM INT,
										InQty INT,
										BadLotQty INT,
										DefectiveRate NUMERIC(5,2),
										CreateUserID VARCHAR(20),
										Nonconformity NVARCHAR(4000),
										ImmediateAction NVARCHAR(4000),
										CustomImmediateAction NVARCHAR(4000),
										CustomCountermeasureImage NVARCHAR(MAX),
										IsActionCode BIT,
										EffectivenessCheck BIT,
										DefectImage NVARCHAR(MAX),
										DefectImage2 NVARCHAR(MAX),
										CreateDateTime DATETIMEOFFSET
									) 
				) AS SourceTable
			ON
				(
					TargetTable.NCRNo = SourceTable.OldNCRNo
				)

			WHEN MATCHED THEN
				UPDATE SET
					NCRNo = ISNULL(SourceTable.NCRNo,TargetTable.NCRNo),
					JobDate = ISNULL(SourceTable.JobDate,TargetTable.JobDate),
					CompanyCode = ISNULL(SourceTable.CompanyCode,TargetTable.CompanyCode),
					OccurProcessCode = ISNULL(SourceTable.OccurProcessCode,TargetTable.OccurProcessCode),
					MaterialName = ISNULL(SourceTable.MaterialName,TargetTable.MaterialName),
					CustomName = ISNULL(SourceTable.CustomName,TargetTable.CustomName),
					standardName = ISNULL(SourceTable.standardName,TargetTable.standardName),
					LotNo = ISNULL(SourceTable.LotNo,TargetTable.LotNo),
					Qty = ISNULL(SourceTable.Qty,TargetTable.Qty),
					InspectionQty = ISNULL(SourceTable.InspectionQty,TargetTable.InspectionQty),
					BadQty = ISNULL(SourceTable.BadQty,TargetTable.BadQty),
					PPM = ISNULL(SourceTable.PPM,TargetTable.PPM),
					InQty = ISNULL(SourceTable.InQty,TargetTable.InQty),
					BadLotQty = ISNULL(SourceTable.BadLotQty,TargetTable.BadLotQty),
					DefectiveRate = ISNULL(SourceTable.DefectiveRate,TargetTable.DefectiveRate),
					Nonconformity = ISNULL(SourceTable.Nonconformity,TargetTable.Nonconformity),
					ImmediateAction = ISNULL(SourceTable.ImmediateAction,TargetTable.ImmediateAction),
					CustomImmediateAction = ISNULL(SourceTable.CustomImmediateAction,TargetTable.CustomImmediateAction),
					CustomCountermeasureImage = ISNULL(SourceTable.CustomCountermeasureImage,TargetTable.CustomCountermeasureImage),
					IsActionCode = ISNULL(SourceTable.IsActionCode,TargetTable.IsActionCode),
					EffectivenessCheck = ISNULL(SourceTable.EffectivenessCheck,TargetTable.EffectivenessCheck),
					DefectImage = ISNULL(SourceTable.DefectImage,TargetTable.DefectImage),
					DefectImage2 = ISNULL(SourceTable.DefectImage2,TargetTable.DefectImage2)
			WHEN NOT MATCHED THEN
				INSERT
					(
						NCRNo,
						JobDate,
						CompanyCode,
						OccurProcessCode,
						MaterialName,
						CustomName,
						standardName,
						LotNo,
						Qty,
						InspectionQty,
						BadQty,
						PPM,
						InQty,
						BadLotQty,
						DefectiveRate,
						CreateUserID,
						Nonconformity,
						ImmediateAction,
						CustomImmediateAction,
						CustomCountermeasureImage,
						IsActionCode,
						EffectivenessCheck,
						DefectImage,
						DefectImage2,
						CreateDateTime
					)
				VALUES
					(
							SourceTable.NCRNo,
							SourceTable.JobDate,
							SourceTable.CompanyCode,
							SourceTable.OccurProcessCode,
							SourceTable.MaterialName,
							SourceTable.CustomName,
							SourceTable.standardName,
							SourceTable.LotNo,
							SourceTable.Qty,
							SourceTable.InspectionQty,
							SourceTable.BadQty,
							SourceTable.PPM,
							SourceTable.InQty,
							SourceTable.BadLotQty,
							SourceTable.DefectiveRate,
							SourceTable.CreateUserID,
							SourceTable.Nonconformity,
							SourceTable.ImmediateAction,
							SourceTable.CustomImmediateAction,
							SourceTable.CustomCountermeasureImage,
							SourceTable.IsActionCode,
							SourceTable.EffectivenessCheck,
							SourceTable.DefectImage,
							SourceTable.DefectImage2,
							SourceTable.CreateDateTime
					);


			-- Process Delete Table
            MERGE STB_NCR_Report AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldNCRNo IS NULL THEN NCRNo
							    ELSE OldNCRNo
							END AS OldNCRNo,
							NCRNo
					FROM
							OPENXML(@idoc , @DeleteTableName , 2)
							WITH  (
										OldNCRNo VARCHAR(20),
										NCRNo VARCHAR(20)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.NCRNo = SourceTable.NCRNo
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
									OldNCRNo,
									NCRNo,
									JobDate,
									CompanyCode,
									OccurProcessCode,
									MaterialName,
									CustomName,
									standardName,
									LotNo,
									Qty,
									InspectionQty,
									BadQty,
									PPM,
									InQty,
									BadLotQty,
									DefectiveRate,
									CreateUserID,
									Nonconformity,
									ImmediateAction,
									CustomImmediateAction,
									dbo.fnBase64ToBinary(CustomCountermeasureImage) as CustomCountermeasureImage,
									IsActionCode,
									EffectivenessCheck,
									dbo.fnBase64ToBinary(DefectImage) as DefectImage,
									dbo.fnBase64ToBinary(DefectImage2) as DefectImage2,
									CreateDateTime
							FROM
									OPENXML(@idoc , @InsertTableName , 2)
							        WITH  (
											 OldNCRNo VARCHAR(20),
											 NCRNo VARCHAR(20),
											 JobDate DATETIMEOFFSET,
											 CompanyCode VARCHAR(20),
											 OccurProcessCode VARCHAR(20),
											 MaterialName VARCHAR(80),
											 CustomName VARCHAR(60),
											 standardName VARCHAR(60),
											 LotNo VARCHAR(80),
											 Qty INT,
											 InspectionQty INT,
											 BadQty INT,
											 PPM INT,
											 InQty INT,
											 BadLotQty INT,
											 DefectiveRate NUMERIC(5,2),
											 CreateUserID VARCHAR(20),
											 Nonconformity NVARCHAR(4000),
											 ImmediateAction NVARCHAR(4000),
											 CustomImmediateAction NVARCHAR(4000),
											 CustomCountermeasureImage NVARCHAR(MAX),
											 IsActionCode BIT,
											 EffectivenessCheck BIT,
											 DefectImage NVARCHAR(MAX),
											 DefectImage2 NVARCHAR(MAX),
											 CreateDateTime DATETIMEOFFSET
											)
							UNION ALL
							SELECT
									'UPDATE' AS IUD_FLAG,
									CASE 
										WHEN OldNCRNo IS NULL THEN NCRNo
										ELSE OldNCRNo
									END AS OldNCRNo,
									NCRNo,
									JobDate,
									CompanyCode,
									OccurProcessCode,
									MaterialName,
									CustomName,
									standardName,
									LotNo,
									Qty,
									InspectionQty,
									BadQty,
									PPM,
									InQty,
									BadLotQty,
									DefectiveRate,
									CreateUserID,
									Nonconformity,
									ImmediateAction,
									CustomImmediateAction,
									dbo.fnBase64ToBinary(CustomCountermeasureImage) as CustomCountermeasureImage,
									IsActionCode,
									EffectivenessCheck,
									dbo.fnBase64ToBinary(DefectImage) as DefectImage,
									dbo.fnBase64ToBinary(DefectImage2) as DefectImage2,
									CreateDateTime
							FROM
									OPENXML(@idoc , @UpdateTableName , 2)
							        WITH  (
											 OldNCRNo VARCHAR(20),
											 NCRNo VARCHAR(20),
											 JobDate DATETIMEOFFSET,
											 CompanyCode VARCHAR(20),
											 OccurProcessCode VARCHAR(20),
											 MaterialName VARCHAR(80),
											 CustomName VARCHAR(60),
											 standardName VARCHAR(60),
											 LotNo VARCHAR(80),
											 Qty INT,
											 InspectionQty INT,
											 BadQty INT,
											 PPM INT,
											 InQty INT,
											 BadLotQty INT,
											 DefectiveRate NUMERIC(5,2),
											 CreateUserID VARCHAR(20),
											 Nonconformity NVARCHAR(4000),
											 ImmediateAction NVARCHAR(4000),
											 CustomImmediateAction NVARCHAR(4000),
											 CustomCountermeasureImage NVARCHAR(MAX),
											 IsActionCode BIT,
											 EffectivenessCheck BIT,
											 DefectImage NVARCHAR(MAX),
											 DefectImage2 NVARCHAR(MAX),
											 CreateDateTime DATETIMEOFFSET
											)
							UNION ALL
							SELECT
									'DELETE' AS IUD_FLAG,
									CASE 
										WHEN OldNCRNo IS NULL THEN NCRNo
										ELSE OldNCRNo
									END AS OldNCRNo,
									NCRNo,
									JobDate,
									CompanyCode,
									OccurProcessCode,
									MaterialName,
									CustomName,
									standardName,
									LotNo,
									Qty,
									InspectionQty,
									BadQty,
									PPM,
									InQty,
									BadLotQty,
									DefectiveRate,
									CreateUserID,
									Nonconformity,
									ImmediateAction,
									CustomImmediateAction,
									dbo.fnBase64ToBinary(CustomCountermeasureImage) as CustomCountermeasureImage,
									IsActionCode,
									EffectivenessCheck,
									dbo.fnBase64ToBinary(DefectImage) as DefectImage,
									dbo.fnBase64ToBinary(DefectImage2) as DefectImage2,
									CreateDateTime
							FROM
									OPENXML(@idoc , @DeleteTableName , 2)
							        WITH  (
											 OldNCRNo VARCHAR(20),
											 NCRNo VARCHAR(20),
											 JobDate DATETIMEOFFSET,
											 CompanyCode VARCHAR(20),
											 OccurProcessCode VARCHAR(20),
											 MaterialName VARCHAR(80),
											 CustomName VARCHAR(60),
											 standardName VARCHAR(60),
											 LotNo VARCHAR(80),
											 Qty INT,
											 InspectionQty INT,
											 BadQty INT,
											 PPM INT,
											 InQty INT,
											 BadLotQty INT,
											 DefectiveRate NUMERIC(5,2),
											 CreateUserID VARCHAR(20),
											 Nonconformity NVARCHAR(4000),
											 ImmediateAction NVARCHAR(4000),
											 CustomImmediateAction NVARCHAR(4000),
											 CustomCountermeasureImage NVARCHAR(MAX),
											 IsActionCode BIT,
											 EffectivenessCheck BIT,
											 DefectImage NVARCHAR(MAX),
											 DefectImage2 NVARCHAR(MAX),
											 CreateDateTime DATETIMEOFFSET
											) 


            OPEN SourceData

            WHILE 1 = 1 BEGIN
                FETCH NEXT FROM SourceData INTO
								 @IUD_FLAG,
								 @OldNCRNo,
								 @NCRNo,
								 @JobDate,
								 @CompanyCode,
								 @OccurProcessCode,
								 @MaterialName,
								 @CustomName,
								 @standardName,
								 @LotNo,
								 @Qty,
								 @InspectionQty,
								 @BadQty,
								 @PPM,
								 @InQty,
								 @BadLotQty,
								 @DefectiveRate,
								 @CreateUserID,
								 @Nonconformity,
								 @ImmediateAction,
								 @CustomImmediateAction,
								 @CustomCountermeasureImage,
								 @IsActionCode,
								 @EffectivenessCheck,
								 @DefectImage,
								 @DefectImage2,
								 @CreateDateTime


                IF @@FETCH_STATUS <> 0 BEGIN
					BREAK
				END
                IF @IUD_FLAG = 'INSERT' BEGIN

                    IF EXISTS (SELECT 1 FROM STB_NCR_Report WHERE NCRNo = @NCRNo) BEGIN
						RAISERROR('Duplicate Data : KeyField = %s', 16, 1, @NCRNo)
					END

                    IF @IsAutoKey = 1 BEGIN
                        EXEC usp_DoCreateSerial 'STB_NCR_Report',@NCRNo OUTPUT
                    END

                    INSERT INTO STB_NCR_Report
						(
						    NCRNo,
						    JobDate,
						    CompanyCode,
						    OccurProcessCode,
						    MaterialName,
						    CustomName,
						    standardName,
						    LotNo,
						    Qty,
						    InspectionQty,
						    BadQty,
						    PPM,
						    InQty,
						    BadLotQty,
						    DefectiveRate,
						    CreateUserID,
						    Nonconformity,
						    ImmediateAction,
						    CustomImmediateAction,
						    CustomCountermeasureImage,
						    IsActionCode,
						    EffectivenessCheck,
						    DefectImage,
						    DefectImage2,
						    CreateDateTime
						)
						VALUES
						(
						    @NCRNo,
						    @JobDate,
						    @CompanyCode,
						    @OccurProcessCode,
						    @MaterialName,
						    @CustomName,
						    @standardName,
						    @LotNo,
						    @Qty,
						    @InspectionQty,
						    @BadQty,
						    @PPM,
						    @InQty,
						    @BadLotQty,
						    @DefectiveRate,
						    @pProcessUserID,
						    @Nonconformity,
						    @ImmediateAction,
						    @CustomImmediateAction,
						    @CustomCountermeasureImage,
						    @IsActionCode,
						    @EffectivenessCheck,
						    @DefectImage,
						    @DefectImage2,
						    GETDATE()
						)

				END ELSE IF @IUD_FLAG = 'UPDATE' BEGIN
                    UPDATE STB_NCR_Report
						SET
						    NCRNo =   ISNULL(@NCRNo,NCRNo),
						    JobDate =   ISNULL(@JobDate,JobDate),
						    CompanyCode =   ISNULL(@CompanyCode,CompanyCode),
						    OccurProcessCode =   ISNULL(@OccurProcessCode,OccurProcessCode),
						    MaterialName =   ISNULL(@MaterialName,MaterialName),
						    CustomName =   ISNULL(@CustomName,CustomName),
						    standardName =   ISNULL(@standardName,standardName),
						    LotNo =   ISNULL(@LotNo,LotNo),
						    Qty =   ISNULL(@Qty,Qty),
						    InspectionQty =   ISNULL(@InspectionQty,InspectionQty),
						    BadQty =   ISNULL(@BadQty,BadQty),
						    PPM =   ISNULL(@PPM,PPM),
						    InQty =   ISNULL(@InQty,InQty),
						    BadLotQty =   ISNULL(@BadLotQty,BadLotQty),
						    DefectiveRate =   ISNULL(@DefectiveRate,DefectiveRate),
						    CreateUserID =   ISNULL(@CreateUserID,CreateUserID),
						    Nonconformity =   ISNULL(@Nonconformity,Nonconformity),
						    ImmediateAction =   ISNULL(@ImmediateAction,ImmediateAction),
						    CustomImmediateAction =   ISNULL(@CustomImmediateAction,CustomImmediateAction),
						    CustomCountermeasureImage =   ISNULL(@CustomCountermeasureImage,CustomCountermeasureImage),
						    IsActionCode =   ISNULL(@IsActionCode,IsActionCode),
						    EffectivenessCheck =   ISNULL(@EffectivenessCheck,EffectivenessCheck),
						    DefectImage =   ISNULL(@DefectImage,DefectImage),
						    DefectImage2 =   ISNULL(@DefectImage2,DefectImage2),
						    CreateDateTime =   ISNULL(@CreateDateTime,CreateDateTime)
						WHERE
						    NCRNo = @OldNCRNo
                END ELSE IF @IUD_FLAG = 'DELETE' BEGIN
                    DELETE FROM STB_NCR_Report
						WHERE
						    NCRNo = @OldNCRNo
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
