-- =============================================
-- Author: Park Jong Hoon(jhpark@awoo.co.kr)
-- Create date: 2016-05-18
-- Browsable : true
-- Group : 설비관리
-- Description:	설비정기점검항목 IUD
-- Modified:
-- 2021.10.29 Remark 컬럼추가
-- 2021.10.28 자동채번규칙 적용
-- =============================================
CREATE PROCEDURE [dbo].[usp_MachinePmItem_iud]
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
  DECLARE @OldMachinePmItemCode VARCHAR(20)
  DECLARE @MachinePmItemCode VARCHAR(20)
  DECLARE @CompanyCode VARCHAR(20)
  DECLARE @WorkCenterCode VARCHAR(20)
  DECLARE @MachineCode VARCHAR(20)
  DECLARE @PmItemName NVARCHAR(100)
  DECLARE @PmItemGroup NVARCHAR(100)
  DECLARE @PmItemSpec NVARCHAR(200)
  DECLARE @PmTermType VARCHAR(10)
  DECLARE @FinalPmDate DATE
  DECLARE @NextPmPlanDate DATE
  DECLARE @IsUsed BIT
  DECLARE @CreateDateTime DATETIME
  DECLARE @CreateUserID VARCHAR(20)
  DECLARE @ChangeDateTime DATETIME
  DECLARE @ChangeUserID VARCHAR(20)
  DECLARE @InspectionMethod VARCHAR(50)
  
    
    DECLARE @PmItemNameL NVARCHAR(100)
    DECLARE @PmItemGroupL NVARCHAR(100)
    DECLARE @PmItemSpecL NVARCHAR(200)
    DECLARE @InspectionMethodL VARCHAR(50)	

	DECLARE @iDoc INT

	Declare @pRemark Varchar(100)

	/*
	ALTER TABLE STB_MachinePmItem  ADD Remark Varchar(1000)

	*/

    EXEC SmartFramework.dbo.usp_GetSerialRule 
			@pTableName = 'STB_MachinePmItem',
			@pIsAutoKey = @IsAutoKey OUTPUT,
			@pIsLoopIUD = @IsLoopIUD OUTPUT,
			@pPrefixData = @PrefixString OUTPUT,
			@pSerialLen = @SerialLen OUTPUT
    
    IF @IsAutoKey = 0 AND @IsLoopIUD = 0 BEGIN
   
	    EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
	
	    BEGIN TRY
			-- Process Insert Table
            MERGE STB_MachinePmItem AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN XMLData.OldMachinePmItemCode IS NULL THEN XMLData.MachinePmItemCode
							    ELSE XMLData.OldMachinePmItemCode
							END AS OldMachinePmItemCode,
							XMLData.MachinePmItemCode,
							XMLData.CompanyCode,
							XMLData.WorkCenterCode,
							XMLData.MachineCode,
							XMLData.PmItemName,
							XMLData.InspectionMethod,
							XMLData.PmItemGroup,
							XMLData.PmItemSpec,
							XMLData.PmTermType,
							XMLData.FinalPmDate,
							XMLData.NextPmPlanDate,
							XMLData.IsUsed,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID,
							XMLData.PmItemNameL,
							XMLData.PmItemGroupL,
							XMLData.PmItemSpecL,
							XMLData.InspectionMethodL
							, XMLData.Remark
					FROM
							OPENXML(@idoc , @InsertTableName , 2)
							WITH  (
										OldMachinePmItemCode VARCHAR(20),
										MachinePmItemCode VARCHAR(20),
										CompanyCode VARCHAR(20),
										WorkCenterCode VARCHAR(20),
										MachineCode VARCHAR(20),
										PmItemName NVARCHAR(100),
										InspectionMethod VARCHAR(50),
										PmItemGroup NVARCHAR(100),
										PmItemSpec NVARCHAR(200),
										PmTermType VARCHAR(10),
										FinalPmDate DATETIMEOFFSET,
										NextPmPlanDate DATETIMEOFFSET,
										IsUsed BIT,
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20),
										PmItemNameL NVARCHAR(100),
										PmItemGroupL NVARCHAR(100),
										PmItemSpecL NVARCHAR(200),
										InspectionMethodL VARCHAR(50)
										, Remark VARCHAR(100)
									) XMLData
				) AS SourceTable
			ON
				(
					TargetTable.MachinePmItemCode = SourceTable.MachinePmItemCode
				)

			WHEN MATCHED THEN
				UPDATE SET
					MachinePmItemCode = SourceTable.MachinePmItemCode,
					CompanyCode = SourceTable.CompanyCode,
					WorkCenterCode = SourceTable.WorkCenterCode,
					MachineCode = SourceTable.MachineCode,
					PmItemName = SourceTable.PmItemName,
					InspectionMethod = SourceTable.InspectionMethod,
					PmItemGroup = SourceTable.PmItemGroup,
					PmItemSpec = SourceTable.PmItemSpec,
					PmTermType = SourceTable.PmTermType,
					FinalPmDate = SourceTable.FinalPmDate,
					NextPmPlanDate = SourceTable.NextPmPlanDate,
					IsUsed = SourceTable.IsUsed,
					ChangeDateTime = SourceTable.ChangeDateTime,
					ChangeUserID = SourceTable.ChangeUserID
				,	Remark = SourceTable.Remark
			WHEN NOT MATCHED THEN
				INSERT
					(
						MachinePmItemCode,
						CompanyCode,
						WorkCenterCode,
						MachineCode,
						PmItemName,
						InspectionMethod,
						PmItemGroup,
						PmItemSpec,
						PmTermType,
						FinalPmDate,
						NextPmPlanDate,
						IsUsed,
						CreateDateTime,
						CreateUserID
						, REmark
					)
				VALUES
					(
							SourceTable.MachinePmItemCode,
							SourceTable.CompanyCode,
							SourceTable.WorkCenterCode,
							SourceTable.MachineCode,
							SourceTable.PmItemName,
							SourceTable.InspectionMethod,
							SourceTable.PmItemGroup,
							SourceTable.PmItemSpec,
							SourceTable.PmTermType,
							SourceTable.FinalPmDate,
							SourceTable.NextPmPlanDate,
							SourceTable.IsUsed,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID,
							SourceTable.Remark
					);


			-- Process Update Table
            MERGE STB_MachinePmItem AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN XMLData.OldMachinePmItemCode IS NULL THEN XMLData.MachinePmItemCode
							    ELSE XMLData.OldMachinePmItemCode
							END AS OldMachinePmItemCode,
							XMLData.MachinePmItemCode,
							XMLData.CompanyCode,
							XMLData.WorkCenterCode,
							XMLData.MachineCode,
							XMLData.PmItemName,
							XMLData.InspectionMethod,
							XMLData.PmItemGroup,
							XMLData.PmItemSpec,
							XMLData.PmTermType,
							XMLData.FinalPmDate,
							XMLData.NextPmPlanDate,
							XMLData.IsUsed,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID,
							@pRemark AS Remark
					FROM
							OPENXML(@idoc , @UpdateTableName , 2)
							WITH  (
										OldMachinePmItemCode VARCHAR(20),
										MachinePmItemCode VARCHAR(20),
										CompanyCode VARCHAR(20),
										WorkCenterCode VARCHAR(20),
										MachineCode VARCHAR(20),
										PmItemName NVARCHAR(100),
										InspectionMethod VARCHAR(50),
										PmItemGroup NVARCHAR(100),
										PmItemSpec NVARCHAR(200),
										PmTermType VARCHAR(10),
										FinalPmDate DATETIMEOFFSET,
										NextPmPlanDate DATETIMEOFFSET,
										IsUsed BIT,
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
										, Remark VARCHAR(100)
									) XMLData
				) AS SourceTable
			ON
				(
					TargetTable.MachinePmItemCode = SourceTable.OldMachinePmItemCode
				)

			WHEN MATCHED THEN
				UPDATE SET
					MachinePmItemCode = SourceTable.MachinePmItemCode,
					CompanyCode = SourceTable.CompanyCode,
					WorkCenterCode = SourceTable.WorkCenterCode,
					MachineCode = SourceTable.MachineCode,
					PmItemName = SourceTable.PmItemName,
					InspectionMethod = SourceTable.InspectionMethod,
					PmItemGroup = SourceTable.PmItemGroup,
					PmItemSpec = SourceTable.PmItemSpec,
					PmTermType = SourceTable.PmTermType,
					FinalPmDate = SourceTable.FinalPmDate,
					NextPmPlanDate = SourceTable.NextPmPlanDate,
					IsUsed = SourceTable.IsUsed,
					ChangeDateTime = SourceTable.ChangeDateTime,
					ChangeUserID = SourceTable.ChangeUserID,
					Remark = SourceTable.Remark
			WHEN NOT MATCHED THEN
				INSERT
					(
						MachinePmItemCode,
						CompanyCode,
						WorkCenterCode,
						MachineCode,
						PmItemName,
						InspectionMethod,
						PmItemGroup,
						PmItemSpec,
						PmTermType,
						FinalPmDate,
						NextPmPlanDate,
						IsUsed,
						CreateDateTime,
						CreateUserID,
						Remark
					)
				VALUES
					(
							SourceTable.MachinePmItemCode,
							SourceTable.CompanyCode,
							SourceTable.WorkCenterCode,
							SourceTable.MachineCode,
							SourceTable.PmItemName,
							SourceTable.InspectionMethod,
							SourceTable.PmItemGroup,
							SourceTable.PmItemSpec,
							SourceTable.PmTermType,
							SourceTable.FinalPmDate,
							SourceTable.NextPmPlanDate,
							SourceTable.IsUsed,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID,
							SourceTable.Remark
					);


			-- Process Delete Table
            MERGE STB_MachinePmItem AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN XMLData.OldMachinePmItemCode IS NULL THEN XMLData.MachinePmItemCode
							    ELSE XMLData.OldMachinePmItemCode
							END AS OldMachinePmItemCode,
							XMLData.MachinePmItemCode,
							XMLData.CompanyCode,
							XMLData.WorkCenterCode,
							XMLData.MachineCode,
							XMLData.PmItemName,
							XMLData.InspectionMethod,
							XMLData.PmItemGroup,
							XMLData.PmItemSpec,
							XMLData.PmTermType,
							XMLData.FinalPmDate,
							XMLData.NextPmPlanDate,
							XMLData.IsUsed,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID,
							@pRemark AS Remark
					FROM
							OPENXML(@idoc , @DeleteTableName , 2)
							WITH  (
										OldMachinePmItemCode VARCHAR(20),
										MachinePmItemCode VARCHAR(20),
										CompanyCode VARCHAR(20),
										WorkCenterCode VARCHAR(20),
										MachineCode VARCHAR(20),
										PmItemName NVARCHAR(100),
										InspectionMethod VARCHAR(50),
										PmItemGroup NVARCHAR(100),
										PmItemSpec NVARCHAR(200),
										PmTermType VARCHAR(10),
										FinalPmDate DATETIMEOFFSET,
										NextPmPlanDate DATETIMEOFFSET,
										IsUsed BIT,
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20),
										Remark VARCHAR(100)
									) XMLData
				) AS SourceTable
			ON
				(
					TargetTable.MachinePmItemCode = SourceTable.MachinePmItemCode
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
									XMLData.OldMachinePmItemCode,
									XMLData.MachinePmItemCode,
									XMLData.CompanyCode,
									XMLData.WorkCenterCode,
									XMLData.MachineCode,
									XMLData.PmItemName,
									XMLData.InspectionMethod,
									XMLData.PmItemGroup,
									XMLData.PmItemSpec,
									XMLData.PmTermType,
									XMLData.FinalPmDate,
									XMLData.NextPmPlanDate,
									XMLData.IsUsed,
									XMLData.CreateDateTime,
									XMLData.CreateUserID,
									XMLData.ChangeDateTime,
									XMLData.ChangeUserID,
									XMLData.Remark
							FROM
									OPENXML(@idoc , @InsertTableName , 2)
							        WITH  (
											 OldMachinePmItemCode VARCHAR(20),
											 MachinePmItemCode VARCHAR(20),
											 CompanyCode VARCHAR(20),
											 WorkCenterCode VARCHAR(20),
											 MachineCode VARCHAR(20),
											 PmItemName NVARCHAR(100),
											 InspectionMethod VARCHAR(50),
											 PmItemGroup NVARCHAR(100),
											 PmItemSpec NVARCHAR(200),
											 PmTermType VARCHAR(10),
											 FinalPmDate DATETIMEOFFSET,
											 NextPmPlanDate DATETIMEOFFSET,
											 IsUsed BIT,
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20),
											 Remark VARCHAR(100)
											) XMLData
							UNION ALL
							SELECT
									'UPDATE' AS IUD_FLAG,
									CASE 
										WHEN XMLData.OldMachinePmItemCode IS NULL THEN XMLData.MachinePmItemCode
										ELSE XMLData.OldMachinePmItemCode
									END AS OldMachinePmItemCode,
									XMLData.MachinePmItemCode,
									XMLData.CompanyCode,
									XMLData.WorkCenterCode,
									XMLData.MachineCode,
									XMLData.PmItemName,
									XMLData.InspectionMethod,
									XMLData.PmItemGroup,
									XMLData.PmItemSpec,
									XMLData.PmTermType,
									XMLData.FinalPmDate,
									XMLData.NextPmPlanDate,
									XMLData.IsUsed,
									XMLData.CreateDateTime,
									XMLData.CreateUserID,
									XMLData.ChangeDateTime,
									XMLData.ChangeUserID,
									 XMLData.Remark
							FROM
									OPENXML(@idoc , @UpdateTableName , 2)
							        WITH  (
											 OldMachinePmItemCode VARCHAR(20),
											 MachinePmItemCode VARCHAR(20),
											 CompanyCode VARCHAR(20),
											 WorkCenterCode VARCHAR(20),
											 MachineCode VARCHAR(20),
											 PmItemName NVARCHAR(100),
											 InspectionMethod VARCHAR(50),
											 PmItemGroup NVARCHAR(100),
											 PmItemSpec NVARCHAR(200),
											 PmTermType VARCHAR(10),
											 FinalPmDate DATETIMEOFFSET,
											 NextPmPlanDate DATETIMEOFFSET,
											 IsUsed BIT,
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20),
											 Remark VARCHAR(100)
											) XMLData
							UNION ALL
							SELECT
									'DELETE' AS IUD_FLAG,
									CASE 
										WHEN XMLData.OldMachinePmItemCode IS NULL THEN XMLData.MachinePmItemCode
										ELSE XMLData.OldMachinePmItemCode
									END AS OldMachinePmItemCode,
									XMLData.MachinePmItemCode,
									XMLData.CompanyCode,
									XMLData.WorkCenterCode,
									XMLData.MachineCode,
									XMLData.PmItemName,
									XMLData.InspectionMethod,
									XMLData.PmItemGroup,
									XMLData.PmItemSpec,
									XMLData.PmTermType,
									XMLData.FinalPmDate,
									XMLData.NextPmPlanDate,
									XMLData.IsUsed,
									XMLData.CreateDateTime,
									XMLData.CreateUserID,
									XMLData.ChangeDateTime,
									XMLData.ChangeUserID,
									XMLData.Remark
							FROM
									OPENXML(@idoc , @DeleteTableName , 2)
							        WITH  (
											 OldMachinePmItemCode VARCHAR(20),
											 MachinePmItemCode VARCHAR(20),
											 CompanyCode VARCHAR(20),
											 WorkCenterCode VARCHAR(20),
											 MachineCode VARCHAR(20),
											 PmItemName NVARCHAR(100),
											 InspectionMethod VARCHAR(50),
											 PmItemGroup NVARCHAR(100),
											 PmItemSpec NVARCHAR(200),
											 PmTermType VARCHAR(10),
											 FinalPmDate DATETIMEOFFSET,
											 NextPmPlanDate DATETIMEOFFSET,
											 IsUsed BIT,
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20),
											 Remark VARCHAR(100)
											) XMLData


            OPEN SourceData

            WHILE 1 = 1 BEGIN
                FETCH NEXT FROM SourceData INTO
								 @IUD_FLAG,
								 @OldMachinePmItemCode,
								 @MachinePmItemCode,
								 @CompanyCode,
								 @WorkCenterCode,
								 @MachineCode,
								 @PmItemName,
								 @InspectionMethod,
								 @PmItemGroup,
								 @PmItemSpec,
								 @PmTermType,
								 @FinalPmDate,
								 @NextPmPlanDate,
								 @IsUsed,
								 @CreateDateTime,
								 @CreateUserID,
								 @ChangeDateTime,
								 @ChangeUserID,
								 @pRemark


                IF @@FETCH_STATUS <> 0 BEGIN
					BREAK
				END
                IF @IUD_FLAG = 'INSERT' BEGIN

                    IF EXISTS (SELECT 1 FROM STB_MachinePmItem WHERE MachinePmItemCode = @MachinePmItemCode) BEGIN
						RAISERROR('Duplicate Data : KeyField = %s', 16, 1, @MachinePmItemCode)
					END

                    IF @IsAutoKey = 1 BEGIN
						EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_MachinePmItem', @MachinePmItemCode OUTPUT

						-- 설비점검번호는 VN을 추가한다.
						--부적합보고서 번호는 VN을 추가한다. 
						--부적합 유형별로 머리글이 달랐으나 VN으로 통일함
                        SET @MachinePmItemCode = 'VN' + @MachinePmItemCode

                    END

                    INSERT INTO STB_MachinePmItem
						(
						    MachinePmItemCode,
						    CompanyCode,
						    WorkCenterCode,
						    MachineCode,
						    PmItemName,
						    InspectionMethod,
						    PmItemGroup,
						    PmItemSpec,
						    PmTermType,
						    FinalPmDate,
						    NextPmPlanDate,
						    IsUsed,
						    CreateDateTime,
						    CreateUserID,
						    ChangeDateTime,
						    ChangeUserID,
							Remark
						)
						VALUES
						(
						    @MachinePmItemCode,
						    @CompanyCode,
						    @WorkCenterCode,
						    @MachineCode,
						    @PmItemName,
						    @InspectionMethod,
						    @PmItemGroup,
						    @PmItemSpec,
						    @PmTermType,
						    @FinalPmDate,
						    @NextPmPlanDate,
						    @IsUsed,
						    GETDATE(),
						    @pProcessUserID,
						    @ChangeDateTime,
						    @ChangeUserID,
							@pRemark
						)

				END ELSE IF @IUD_FLAG = 'UPDATE' BEGIN
                    UPDATE STB_MachinePmItem
						SET
						    MachinePmItemCode =   CASE
						                WHEN @MachinePmItemCode IS NOT NULL THEN @MachinePmItemCode
						                ELSE MachinePmItemCode
						            END,
						    CompanyCode =   CASE
						                WHEN @CompanyCode IS NOT NULL THEN @CompanyCode
						                ELSE CompanyCode
						            END,
						    WorkCenterCode =   CASE
						                WHEN @WorkCenterCode IS NOT NULL THEN @WorkCenterCode
						                ELSE WorkCenterCode
						            END,
						    MachineCode =   CASE
						                WHEN @MachineCode IS NOT NULL THEN @MachineCode
						                ELSE MachineCode
						            END,
						    PmItemName =   CASE
						                WHEN @PmItemName IS NOT NULL THEN @PmItemName
						                ELSE PmItemName
						            END,
						    InspectionMethod = CASE
										WHEN @InspectionMethod IS NOT NULL THEN @InspectionMethod
										ELSE InspectionMethod
									END,
						    PmItemGroup =   CASE
						                WHEN @PmItemGroup IS NOT NULL THEN @PmItemGroup
						                ELSE PmItemGroup
						            END,
						    PmItemSpec =   CASE
						                WHEN @PmItemSpec IS NOT NULL THEN @PmItemSpec
						                ELSE PmItemSpec
						            END,
						    PmTermType =   CASE
						                WHEN @PmTermType IS NOT NULL THEN @PmTermType
						                ELSE PmTermType
						            END,
						    FinalPmDate =   CASE
						                WHEN @FinalPmDate IS NOT NULL THEN @FinalPmDate
						                ELSE FinalPmDate
						            END,
						    NextPmPlanDate =   CASE
						                WHEN @NextPmPlanDate IS NOT NULL THEN @NextPmPlanDate
						                ELSE NextPmPlanDate
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
						    ChangeUserID = @pProcessUserID
							, Remark = @pRemark
						WHERE
						    MachinePmItemCode = @OldMachinePmItemCode
                END ELSE IF @IUD_FLAG = 'DELETE' BEGIN
                    DELETE FROM STB_MachinePmItem
						WHERE
						    MachinePmItemCode = @MachinePmItemCode
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

