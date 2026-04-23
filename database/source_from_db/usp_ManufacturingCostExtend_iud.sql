
-- =============================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Create date: 2021-08-23
-- Browsable : true
-- Group : 원가관리
-- Description:	
-- Modified:
-- =============================================
CREATE PROCEDURE dbo.usp_ManufacturingCostExtend_iud
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
  DECLARE @OldApplyDate DATE
  DECLARE @OldCompanyCode VARCHAR(20)
  DECLARE @OldWorkCenterCode VARCHAR(20)
  DECLARE @OldMaterialCode VARCHAR(20)
  DECLARE @ApplyDate DATE
  DECLARE @CompanyCode VARCHAR(20)
  DECLARE @WorkCenterCode VARCHAR(20)
  DECLARE @MaterialCode VARCHAR(20)
  DECLARE @IsManual BIT
  DECLARE @ActivatedCarbonCostPrice NUMERIC(20,10)
  DECLARE @ActiveMaterialCostPrice NUMERIC(20,10)
  DECLARE @ConductiveMaterialCostPrice NUMERIC(20,10)
  DECLARE @BinderCostPrice NUMERIC(20,10)
  DECLARE @SurfactantCostPrice NUMERIC(20,10)
  DECLARE @MenstruumCostPrice NUMERIC(20,10)
  DECLARE @CurrentCollectorCostPrice NUMERIC(20,10)
  DECLARE @TerminalCostPrice NUMERIC(20,10)
  DECLARE @ATLTerminalCostPrice NUMERIC(20,10)
  DECLARE @SeparatorCostPrice NUMERIC(20,10)
  DECLARE @PiTapeCostPrice NUMERIC(20,10)
  DECLARE @RubberStopperCostPrice NUMERIC(20,10)
  DECLARE @TerminalBoardCostPrice NUMERIC(20,10)
  DECLARE @WasherCostPrice NUMERIC(20,10)
  DECLARE @ElectrolyteCostPrice NUMERIC(20,10)
  DECLARE @CaseCostPrice NUMERIC(20,10)
  DECLARE @SleeveCostPrice NUMERIC(20,10)
  DECLARE @BottomPlateCostPrice NUMERIC(20,10)
  DECLARE @PackagingMaterialCostPrice NUMERIC(20,10)
  DECLARE @PCBForModuleCostPrice NUMERIC(20,10)
  DECLARE @WireForModuleCostPrice NUMERIC(20,10)
  DECLARE @MaterialCostPrice NUMERIC(20,10)
  DECLARE @LaborCostPrice NUMERIC(20,10)
  DECLARE @OverheadCostPrice NUMERIC(20,10)
  DECLARE @CreateDateTime DATETIME
  DECLARE @CreateUserID VARCHAR(20)
  DECLARE @ChangeDateTime DATETIME
  DECLARE @ChangeUserID VARCHAR(20)


	DECLARE @iDoc INT

    EXEC SmartFramework.dbo.usp_GetSerialRule 
			@pTableName = 'STB_ManufacturingCostExtend',
			@pIsAutoKey = @IsAutoKey OUTPUT,
			@pIsLoopIUD = @IsLoopIUD OUTPUT,
			@pPrefixData = @PrefixString OUTPUT,
			@pSerialLen = @SerialLen OUTPUT
    
    IF @IsAutoKey = 0 AND @IsLoopIUD = 0 BEGIN
        PRINT 'Batch was removed'
    END ELSE BEGIN
        
        EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
        BEGIN TRY
		    DECLARE SourceData CURSOR FOR
                SELECT
                        'INSERT' AS IUD_FLAG,
									OldApplyDate,
									OldCompanyCode,
									OldWorkCenterCode,
									OldMaterialCode,
									ApplyDate,
									CompanyCode,
									WorkCenterCode,
									MaterialCode,
									IsManual,
									ActivatedCarbonCostPrice,
									ActiveMaterialCostPrice,
									ConductiveMaterialCostPrice,
									BinderCostPrice,
									SurfactantCostPrice,
									MenstruumCostPrice,
									CurrentCollectorCostPrice,
									TerminalCostPrice,
									ATLTerminalCostPrice,
									SeparatorCostPrice,
									PiTapeCostPrice,
									RubberStopperCostPrice,
									TerminalBoardCostPrice,
									WasherCostPrice,
									ElectrolyteCostPrice,
									CaseCostPrice,
									SleeveCostPrice,
									BottomPlateCostPrice,
									PackagingMaterialCostPrice,
									PCBForModuleCostPrice,
									WireForModuleCostPrice,
									MaterialCostPrice,
									LaborCostPrice,
									OverheadCostPrice,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID
							FROM
									OPENXML(@idoc , @InsertTableName , 2)
							        WITH  (
											 OldApplyDate DATETIMEOFFSET,
											 OldCompanyCode VARCHAR(20),
											 OldWorkCenterCode VARCHAR(20),
											 OldMaterialCode VARCHAR(20),
											 ApplyDate DATETIMEOFFSET,
											 CompanyCode VARCHAR(20),
											 WorkCenterCode VARCHAR(20),
											 MaterialCode VARCHAR(20),
											 IsManual BIT,
											 ActivatedCarbonCostPrice NUMERIC(20,10),
											 ActiveMaterialCostPrice NUMERIC(20,10),
											 ConductiveMaterialCostPrice NUMERIC(20,10),
											 BinderCostPrice NUMERIC(20,10),
											 SurfactantCostPrice NUMERIC(20,10),
											 MenstruumCostPrice NUMERIC(20,10),
											 CurrentCollectorCostPrice NUMERIC(20,10),
											 TerminalCostPrice NUMERIC(20,10),
											 ATLTerminalCostPrice NUMERIC(20,10),
											 SeparatorCostPrice NUMERIC(20,10),
											 PiTapeCostPrice NUMERIC(20,10),
											 RubberStopperCostPrice NUMERIC(20,10),
											 TerminalBoardCostPrice NUMERIC(20,10),
											 WasherCostPrice NUMERIC(20,10),
											 ElectrolyteCostPrice NUMERIC(20,10),
											 CaseCostPrice NUMERIC(20,10),
											 SleeveCostPrice NUMERIC(20,10),
											 BottomPlateCostPrice NUMERIC(20,10),
											 PackagingMaterialCostPrice NUMERIC(20,10),
											 PCBForModuleCostPrice NUMERIC(20,10),
											 WireForModuleCostPrice NUMERIC(20,10),
											 MaterialCostPrice NUMERIC(20,10),
											 LaborCostPrice NUMERIC(20,10),
											 OverheadCostPrice NUMERIC(20,10),
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											)
							UNION ALL
							SELECT
									'UPDATE' AS IUD_FLAG,
									CASE 
										WHEN OldApplyDate IS NULL THEN ApplyDate
										ELSE OldApplyDate
									END AS OldApplyDate,
									CASE 
										WHEN OldCompanyCode IS NULL THEN CompanyCode
										ELSE OldCompanyCode
									END AS OldCompanyCode,
									CASE 
										WHEN OldWorkCenterCode IS NULL THEN WorkCenterCode
										ELSE OldWorkCenterCode
									END AS OldWorkCenterCode,
									CASE 
										WHEN OldMaterialCode IS NULL THEN MaterialCode
										ELSE OldMaterialCode
									END AS OldMaterialCode,
									ApplyDate,
									CompanyCode,
									WorkCenterCode,
									MaterialCode,
									IsManual,
									ActivatedCarbonCostPrice,
									ActiveMaterialCostPrice,
									ConductiveMaterialCostPrice,
									BinderCostPrice,
									SurfactantCostPrice,
									MenstruumCostPrice,
									CurrentCollectorCostPrice,
									TerminalCostPrice,
									ATLTerminalCostPrice,
									SeparatorCostPrice,
									PiTapeCostPrice,
									RubberStopperCostPrice,
									TerminalBoardCostPrice,
									WasherCostPrice,
									ElectrolyteCostPrice,
									CaseCostPrice,
									SleeveCostPrice,
									BottomPlateCostPrice,
									PackagingMaterialCostPrice,
									PCBForModuleCostPrice,
									WireForModuleCostPrice,
									MaterialCostPrice,
									LaborCostPrice,
									OverheadCostPrice,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID
							FROM
									OPENXML(@idoc , @UpdateTableName , 2)
							        WITH  (
											 OldApplyDate DATETIMEOFFSET,
											 OldCompanyCode VARCHAR(20),
											 OldWorkCenterCode VARCHAR(20),
											 OldMaterialCode VARCHAR(20),
											 ApplyDate DATETIMEOFFSET,
											 CompanyCode VARCHAR(20),
											 WorkCenterCode VARCHAR(20),
											 MaterialCode VARCHAR(20),
											 IsManual BIT,
											 ActivatedCarbonCostPrice NUMERIC(20,10),
											 ActiveMaterialCostPrice NUMERIC(20,10),
											 ConductiveMaterialCostPrice NUMERIC(20,10),
											 BinderCostPrice NUMERIC(20,10),
											 SurfactantCostPrice NUMERIC(20,10),
											 MenstruumCostPrice NUMERIC(20,10),
											 CurrentCollectorCostPrice NUMERIC(20,10),
											 TerminalCostPrice NUMERIC(20,10),
											 ATLTerminalCostPrice NUMERIC(20,10),
											 SeparatorCostPrice NUMERIC(20,10),
											 PiTapeCostPrice NUMERIC(20,10),
											 RubberStopperCostPrice NUMERIC(20,10),
											 TerminalBoardCostPrice NUMERIC(20,10),
											 WasherCostPrice NUMERIC(20,10),
											 ElectrolyteCostPrice NUMERIC(20,10),
											 CaseCostPrice NUMERIC(20,10),
											 SleeveCostPrice NUMERIC(20,10),
											 BottomPlateCostPrice NUMERIC(20,10),
											 PackagingMaterialCostPrice NUMERIC(20,10),
											 PCBForModuleCostPrice NUMERIC(20,10),
											 WireForModuleCostPrice NUMERIC(20,10),
											 MaterialCostPrice NUMERIC(20,10),
											 LaborCostPrice NUMERIC(20,10),
											 OverheadCostPrice NUMERIC(20,10),
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											)
							UNION ALL
							SELECT
									'DELETE' AS IUD_FLAG,
									CASE 
										WHEN OldApplyDate IS NULL THEN ApplyDate
										ELSE OldApplyDate
									END AS OldApplyDate,
									CASE 
										WHEN OldCompanyCode IS NULL THEN CompanyCode
										ELSE OldCompanyCode
									END AS OldCompanyCode,
									CASE 
										WHEN OldWorkCenterCode IS NULL THEN WorkCenterCode
										ELSE OldWorkCenterCode
									END AS OldWorkCenterCode,
									CASE 
										WHEN OldMaterialCode IS NULL THEN MaterialCode
										ELSE OldMaterialCode
									END AS OldMaterialCode,
									ApplyDate,
									CompanyCode,
									WorkCenterCode,
									MaterialCode,
									IsManual,
									ActivatedCarbonCostPrice,
									ActiveMaterialCostPrice,
									ConductiveMaterialCostPrice,
									BinderCostPrice,
									SurfactantCostPrice,
									MenstruumCostPrice,
									CurrentCollectorCostPrice,
									TerminalCostPrice,
									ATLTerminalCostPrice,
									SeparatorCostPrice,
									PiTapeCostPrice,
									RubberStopperCostPrice,
									TerminalBoardCostPrice,
									WasherCostPrice,
									ElectrolyteCostPrice,
									CaseCostPrice,
									SleeveCostPrice,
									BottomPlateCostPrice,
									PackagingMaterialCostPrice,
									PCBForModuleCostPrice,
									WireForModuleCostPrice,
									MaterialCostPrice,
									LaborCostPrice,
									OverheadCostPrice,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID
							FROM
									OPENXML(@idoc , @DeleteTableName , 2)
							        WITH  (
											 OldApplyDate DATETIMEOFFSET,
											 OldCompanyCode VARCHAR(20),
											 OldWorkCenterCode VARCHAR(20),
											 OldMaterialCode VARCHAR(20),
											 ApplyDate DATETIMEOFFSET,
											 CompanyCode VARCHAR(20),
											 WorkCenterCode VARCHAR(20),
											 MaterialCode VARCHAR(20),
											 IsManual BIT,
											 ActivatedCarbonCostPrice NUMERIC(20,10),
											 ActiveMaterialCostPrice NUMERIC(20,10),
											 ConductiveMaterialCostPrice NUMERIC(20,10),
											 BinderCostPrice NUMERIC(20,10),
											 SurfactantCostPrice NUMERIC(20,10),
											 MenstruumCostPrice NUMERIC(20,10),
											 CurrentCollectorCostPrice NUMERIC(20,10),
											 TerminalCostPrice NUMERIC(20,10),
											 ATLTerminalCostPrice NUMERIC(20,10),
											 SeparatorCostPrice NUMERIC(20,10),
											 PiTapeCostPrice NUMERIC(20,10),
											 RubberStopperCostPrice NUMERIC(20,10),
											 TerminalBoardCostPrice NUMERIC(20,10),
											 WasherCostPrice NUMERIC(20,10),
											 ElectrolyteCostPrice NUMERIC(20,10),
											 CaseCostPrice NUMERIC(20,10),
											 SleeveCostPrice NUMERIC(20,10),
											 BottomPlateCostPrice NUMERIC(20,10),
											 PackagingMaterialCostPrice NUMERIC(20,10),
											 PCBForModuleCostPrice NUMERIC(20,10),
											 WireForModuleCostPrice NUMERIC(20,10),
											 MaterialCostPrice NUMERIC(20,10),
											 LaborCostPrice NUMERIC(20,10),
											 OverheadCostPrice NUMERIC(20,10),
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											) 


            OPEN SourceData

            WHILE 1 = 1 BEGIN
                FETCH NEXT FROM SourceData INTO
								 @IUD_FLAG,
								 @OldApplyDate,
								 @OldCompanyCode,
								 @OldWorkCenterCode,
								 @OldMaterialCode,
								 @ApplyDate,
								 @CompanyCode,
								 @WorkCenterCode,
								 @MaterialCode,
								 @IsManual,
								 @ActivatedCarbonCostPrice,
								 @ActiveMaterialCostPrice,
								 @ConductiveMaterialCostPrice,
								 @BinderCostPrice,
								 @SurfactantCostPrice,
								 @MenstruumCostPrice,
								 @CurrentCollectorCostPrice,
								 @TerminalCostPrice,
								 @ATLTerminalCostPrice,
								 @SeparatorCostPrice,
								 @PiTapeCostPrice,
								 @RubberStopperCostPrice,
								 @TerminalBoardCostPrice,
								 @WasherCostPrice,
								 @ElectrolyteCostPrice,
								 @CaseCostPrice,
								 @SleeveCostPrice,
								 @BottomPlateCostPrice,
								 @PackagingMaterialCostPrice,
								 @PCBForModuleCostPrice,
								 @WireForModuleCostPrice,
								 @MaterialCostPrice,
								 @LaborCostPrice,
								 @OverheadCostPrice,
								 @CreateDateTime,
								 @CreateUserID,
								 @ChangeDateTime,
								 @ChangeUserID


                IF @@FETCH_STATUS <> 0 BEGIN
					BREAK
				END
                IF @IUD_FLAG = 'INSERT' BEGIN
					PRINT 'Not Used'
				END ELSE IF @IUD_FLAG = 'UPDATE' BEGIN
					IF EXISTS (SELECT 1 FROM STB_ManufacturingCostExtend WHERE ApplyDate = @ApplyDate AND CompanyCode = @CompanyCode AND WorkCenterCode = @WorkCenterCode AND MaterialCode = @MaterialCode) BEGIN
						UPDATE STB_ManufacturingCostExtend
							SET
								IsManual =   ISNULL(@IsManual,IsManual),
								ActivatedCarbonCostPrice =   ISNULL(@ActivatedCarbonCostPrice,ActivatedCarbonCostPrice),
								ActiveMaterialCostPrice =   ISNULL(@ActiveMaterialCostPrice,ActiveMaterialCostPrice),
								ConductiveMaterialCostPrice =   ISNULL(@ConductiveMaterialCostPrice,ConductiveMaterialCostPrice),
								BinderCostPrice =   ISNULL(@BinderCostPrice,BinderCostPrice),
								SurfactantCostPrice =   ISNULL(@SurfactantCostPrice,SurfactantCostPrice),
								MenstruumCostPrice =   ISNULL(@MenstruumCostPrice,MenstruumCostPrice),
								CurrentCollectorCostPrice =   ISNULL(@CurrentCollectorCostPrice,CurrentCollectorCostPrice),
								TerminalCostPrice =   ISNULL(@TerminalCostPrice,TerminalCostPrice),
								ATLTerminalCostPrice =   ISNULL(@ATLTerminalCostPrice,ATLTerminalCostPrice),
								SeparatorCostPrice =   ISNULL(@SeparatorCostPrice,SeparatorCostPrice),
								PiTapeCostPrice =   ISNULL(@PiTapeCostPrice,PiTapeCostPrice),
								RubberStopperCostPrice =   ISNULL(@RubberStopperCostPrice,RubberStopperCostPrice),
								TerminalBoardCostPrice =   ISNULL(@TerminalBoardCostPrice,TerminalBoardCostPrice),
								WasherCostPrice =   ISNULL(@WasherCostPrice,WasherCostPrice),
								ElectrolyteCostPrice =   ISNULL(@ElectrolyteCostPrice,ElectrolyteCostPrice),
								CaseCostPrice =   ISNULL(@CaseCostPrice,CaseCostPrice),
								SleeveCostPrice =   ISNULL(@SleeveCostPrice,SleeveCostPrice),
								BottomPlateCostPrice =   ISNULL(@BottomPlateCostPrice,BottomPlateCostPrice),
								PackagingMaterialCostPrice =   ISNULL(@PackagingMaterialCostPrice,PackagingMaterialCostPrice),
								PCBForModuleCostPrice =   ISNULL(@PCBForModuleCostPrice,PCBForModuleCostPrice),
								WireForModuleCostPrice =   ISNULL(@WireForModuleCostPrice,WireForModuleCostPrice),
								MaterialCostPrice =   ISNULL(@MaterialCostPrice,MaterialCostPrice),
								LaborCostPrice =   ISNULL(@LaborCostPrice,LaborCostPrice),
								OverheadCostPrice =   ISNULL(@OverheadCostPrice,OverheadCostPrice),
								CreateDateTime =   ISNULL(@CreateDateTime,CreateDateTime),
								CreateUserID =   ISNULL(@CreateUserID,CreateUserID),
								ChangeDateTime = GETDATE(),
								ChangeUserID = @pProcessUserID
							WHERE
								ApplyDate = @OldApplyDate AND
								CompanyCode = @OldCompanyCode AND
								WorkCenterCode = @OldWorkCenterCode AND
								MaterialCode = @OldMaterialCode
					END ELSE BEGIN
						INSERT INTO STB_ManufacturingCostExtend
						(
						    ApplyDate,
						    CompanyCode,
						    WorkCenterCode,
						    MaterialCode,
						    IsManual,
						    ActivatedCarbonCostPrice,
						    ActiveMaterialCostPrice,
						    ConductiveMaterialCostPrice,
						    BinderCostPrice,
						    SurfactantCostPrice,
						    MenstruumCostPrice,
						    CurrentCollectorCostPrice,
						    TerminalCostPrice,
						    ATLTerminalCostPrice,
						    SeparatorCostPrice,
						    PiTapeCostPrice,
						    RubberStopperCostPrice,
						    TerminalBoardCostPrice,
						    WasherCostPrice,
						    ElectrolyteCostPrice,
						    CaseCostPrice,
						    SleeveCostPrice,
						    BottomPlateCostPrice,
						    PackagingMaterialCostPrice,
						    PCBForModuleCostPrice,
						    WireForModuleCostPrice,
						    MaterialCostPrice,
						    LaborCostPrice,
						    OverheadCostPrice,
						    CreateDateTime,
						    CreateUserID,
						    ChangeDateTime,
						    ChangeUserID
						)
						VALUES
						(
						    @ApplyDate,
						    @CompanyCode,
						    @WorkCenterCode,
						    @MaterialCode,
						    @IsManual,
						    @ActivatedCarbonCostPrice,
						    @ActiveMaterialCostPrice,
						    @ConductiveMaterialCostPrice,
						    @BinderCostPrice,
						    @SurfactantCostPrice,
						    @MenstruumCostPrice,
						    @CurrentCollectorCostPrice,
						    @TerminalCostPrice,
						    @ATLTerminalCostPrice,
						    @SeparatorCostPrice,
						    @PiTapeCostPrice,
						    @RubberStopperCostPrice,
						    @TerminalBoardCostPrice,
						    @WasherCostPrice,
						    @ElectrolyteCostPrice,
						    @CaseCostPrice,
						    @SleeveCostPrice,
						    @BottomPlateCostPrice,
						    @PackagingMaterialCostPrice,
						    @PCBForModuleCostPrice,
						    @WireForModuleCostPrice,
						    @MaterialCostPrice,
						    @LaborCostPrice,
						    @OverheadCostPrice,
						    GETDATE(),
						    @pProcessUserID,
						    @ChangeDateTime,
						    @ChangeUserID
						)
					END
                END ELSE IF @IUD_FLAG = 'DELETE' BEGIN
                    DELETE FROM STB_ManufacturingCostExtend
						WHERE
						    ApplyDate = @OldApplyDate AND
						    CompanyCode = @OldCompanyCode AND
						    WorkCenterCode = @OldWorkCenterCode AND
						    MaterialCode = @OldMaterialCode
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
