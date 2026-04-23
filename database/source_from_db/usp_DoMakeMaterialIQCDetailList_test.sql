
-- =============================================
-- Author:	    shjoo
-- Create date: 2016-02-16
-- Browsable : true
-- Group : 품질관리
-- Description:	입하 시 수입검사상세 정보를 생성합니다.

-- Modified:
--  2020.07.01 수입검사 샘플수량 자동반영 (박진호 대리)
-- =============================================
Create PROCEDURE [dbo].[usp_DoMakeMaterialIQCDetailList_test]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pMaterialQcNo VARCHAR(20) = null
AS

BEGIN
	SET NOCOUNT ON;

	DECLARE @ProcessUserID VARCHAR(20) = @pProcessUserID
	DECLARE @ProcessLanguage VARCHAR(20) = @pProcessLanguage
	
	DECLARE @ERROR_MSG NVARCHAR(MAX)
	DECLARE @IsAutoKey BIT
	DECLARE @IsLoopIUD BIT
	DECLARE @PrefixString VARCHAR(20)
	DECLARE @SerialLen INT
	--DECLARE @MaxKeyField VARCHAR(20)
	DECLARE @MaxKey INT

	DECLARE @IQC_ITEM_OPTION VARCHAR(50)
	
	-- Declare Columns Variable
	DECLARE @MaterialQcNo VARCHAR(20) = @pMaterialQcNo
	DECLARE @MaterialQcDetailNo INT
	DECLARE @MaterialCode VARCHAR(50) = (SELECT MaterialCode FROM STB_MaterialQcInfo WHERE MaterialQcNo = @MaterialQcNo)
	DECLARE @DecisionResult VARCHAR(1) 

	DECLARE @SampleQty INT

	SET @IQC_ITEM_OPTION = dbo.fnGetProcessRule('IQC_ITEM_OPTION','BY_GROUP')
	--PRINT @IQC_ITEM_OPTION
	--SET @IQC_ITEM_OPTION = 'BY_GROUP'
	SELECT
			@DecisionResult = MII.DecisionResult
	FROM
			STB_MaterialQcInfo MII
	WHERE
			MII.MaterialQcNo = @MaterialQcNo

	--IF ISNULL(@DecisionResult,'') IN ('P','F')
	--BEGIN
	--		RAISERROR('이미 처리된 수입검사 정보입니다', 16, 1)
	--		RETURN
	--END

    BEGIN
        BEGIN TRY	
			
			DELETE FROM STB_MaterialQcSampleResult
			WHERE 
					MaterialQcNo = @MaterialQcNo

			DELETE FROM STB_MaterialQcDetail
			WHERE 
					MaterialQcNo = @MaterialQcNo


			DECLARE @QcInspectionItemCode VARCHAR(20)
			DECLARE @InspectionLevel           VARCHAR(20)
			 

			DECLARE @ArriveQty NUMERIC(10,3)
        
			DECLARE @DetailTable TABLE (
				QcInspectionItemCode VARCHAR(20)
			)

			IF @IQC_ITEM_OPTION = 'BY_MATERIAL'
			BEGIN
					INSERT INTO @DetailTable
					SELECT
							MII.QcInspectionItemCode
					FROM
							STB_MaterialQcInspectionItem MII WITH (NOLOCK)
					WHERE
							MII.MaterialCode = @MaterialCode
			END ELSE BEGIN
					INSERT INTO @DetailTable
					SELECT
							III.QcInspectionItemCode
					FROM
							STB_MaterialQcInspectionGroup MIG WITH (NOLOCK)
							LEFT OUTER JOIN STB_QcInspectionItem III WITH (NOLOCK)
								ON (MIG.QcInspectionGroupCode = III.QcInspectionGroupCode)
					WHERE
							MIG.MaterialCode = @MaterialCode
			END
						
			SELECT
					@ArriveQty = MII.QcQty
			FROM
					STB_MaterialQcInfo MII
			WHERE	
					MII.MaterialQcNo = @MaterialQcNo
					
        
			DECLARE DetailCursor CURSOR FOR
				SELECT
						QcInspectionItemCode
				FROM
						@DetailTable
			OPEN DetailCursor
			
			WHILE 1 = 1 BEGIN
				FETCH NEXT FROM DetailCursor INTO @QcInspectionItemCode
				
				IF @@FETCH_STATUS <> 0 BEGIN
					BREAK
				END		
			
				
				SELECT
						@MaterialQcDetailNo = ISNULL(MAX(MaterialQcDetailNo),0) + 1
				FROM
						STB_MaterialQcDetail
				WHERE
						MaterialQcNo = @MaterialQcNo		
					
				IF @IQC_ITEM_OPTION = 'BY_MATERIAL'
				BEGIN			
						;
						WITH InspectionItem AS
						(
							SELECT
									@MaterialQcNo AS MaterialQcNo,
									@MaterialQcDetailNo AS MaterialQcDetailNo, --순번
									III.QcInspectionGroupCode,
									IIG.QcInspectionGroupName,
									IIG.QcInspectionGroupDesc,
									III.QcInspectionItemCode,
									III.QcInspectionItemName,
									III.QcInspectionItemDesc,
									NULL AS GroupInspectionPrior,
									NULL AS GroupReportPrior,
									III.ItemInspectionPrior,
									III.ItemReportPrior,
									III.QcSpecDesc,
									III.InspectionType,
									III.IsMaterialSpec,
									MII.InspectionLevel, -- 테이블이 다름
									MII.AQL,
									0 AS RequestSampleQty,
									0 AS MaxAcceptDefectQty,
									NULL AS SampleQty,
									NULL AS PassedSampleQty,
									NULL AS DefectSampleQty,
									NULL AS SkipSampleQty,
									MII.SpecValue,
									MII.USL,
									MII.LSL,
									MII.UCL,
									MII.LCL,
									MII.TextSpecValue,
									NULL AS DecisionResult,
									GETDATE() AS CreateDateTime,
									@ProcessUserID AS CreateUserID,
									NULL AS ChangeDateTime,
									NULL AS ChangeUserID
							FROM
									STB_MaterialQcInspectionItem MII									
									LEFT OUTER JOIN STB_QcInspectionItem III										ON (III.QcInspectionItemCode = MII.QcInspectionItemCode)
									LEFT OUTER JOIN STB_QcInspectionGroup IIG									ON (IIG.QcInspectionGroupCode = III.QcInspectionGroupCode)
							WHERE
									MII.MaterialCode = @MaterialCode AND
									MII.QcInspectionItemCode = @QcInspectionItemCode
									
						)
						INSERT INTO STB_MaterialQcDetail
									(
										MaterialQcNo,
										MaterialQcDetailNo,
										QcInspectionGroupCode,
										QcInspectionGroupName,
										QcInspectionGroupDesc,
										QcInspectionItemCode,
										QcInspectionItemName,
										QcInspectionItemDesc,
										GroupInspectionPrior,
										GroupReportPrior,
										ItemInspectionPrior,
										ItemReportPrior,
										QcSpecDesc,
										InspectionType,
										IsMaterialSpec,
										InspectionLevel,
										AQL,
										RequestSampleQty,
										MaxAcceptDefectQty,
										SampleQty,
										PassedSampleQty,
										DefectSampleQty,
										SkipSampleQty,
										SpecValue,
										USL,
										LSL,
										UCL,
										LCL,
										TextSpecValue,
										DecisionResult,
										CreateDateTime,
										CreateUserID,
										ChangeDateTime,
										ChangeUserID
									)
						SELECT
								MaterialQcNo,
								MaterialQcDetailNo,
								QcInspectionGroupCode,
								QcInspectionGroupName,
								QcInspectionGroupDesc,
								QcInspectionItemCode,
								QcInspectionItemName,
								QcInspectionItemDesc,
								GroupInspectionPrior,
								GroupReportPrior,
								ItemInspectionPrior,
								ItemReportPrior,
								QcSpecDesc,
								InspectionType,
								IsMaterialSpec,
								InspectionLevel,
								AQL,
								dbo.fnGetQcStandardSampleQty(InspectionType, @ArriveQty, AQL, InspectionLevel),
								dbo.fnGetQcStandardMaxDefectQty(InspectionType, @ArriveQty, AQL, InspectionLevel),
								CASE WHEN QcInspectionItemCode = 'IQC_GPD_18' THEN 10 
								     WHEN QcInspectionItemCode = 'IQC_GPD_19' THEN 10 
									 WHEN QcInspectionItemCode = 'IQC_GPD_20' THEN 3
									 WHEN InspectionLevel = 'S1'   THEN 5                                     -- 2020.07.01 박진호대리 요청사항
									 ELSE 0 END AS SampleQty,
								0 AS PassedSampleQty,
								0 AS DefectSampleQty,
								0 AS SkipSampleQty,
								SpecValue,
								USL,
								LSL,
								UCL,
								LCL,
								TextSpecValue,
								DecisionResult,
								CreateDateTime,
								CreateUserID,
								ChangeDateTime,
								ChangeUserID
						FROM
								InspectionItem


				END ELSE BEGIN
						;
						WITH InspectionItem AS
						(
							SELECT
									@MaterialQcNo AS MaterialQcNo,
									@MaterialQcDetailNo AS MaterialQcDetailNo, --순번
									MIG.QcInspectionGroupCode,
									IIG.QcInspectionGroupName,
									IIG.QcInspectionGroupDesc,
									III.QcInspectionItemCode,
									III.QcInspectionItemName,
									III.QcInspectionItemDesc,
									MIG.GroupInspectionPrior,
									MIG.GroupReportPrior,
									III.ItemInspectionPrior,
									III.ItemReportPrior,
									III.QcSpecDesc,
									III.InspectionType,
									III.IsMaterialSpec,
									III.InspectionLevel,
									III.AQL,
									0 AS RequestSampleQty,
									0 AS MaxAcceptDefectQty,
									NULL AS SampleQty,
									NULL AS PassedSampleQty,
									NULL AS DefectSampleQty,
									NULL AS SkipSampleQty,
									III.SpecValue,
									III.USL,
									III.LSL,
									III.UCL,
									III.LCL,
									III.TextSpecValue,
									NULL AS DecisionResult,
									GETDATE() AS CreateDateTime,
									@ProcessUserID AS CreateUserID,
									NULL AS ChangeDateTime,
									NULL AS ChangeUserID
							FROM
									STB_MaterialQcInspectionGroup MIG
									LEFT OUTER JOIN STB_QcInspectionGroup IIG										ON (MIG.QcInspectionGroupCode = IIG.QcInspectionGroupCode)
									LEFT OUTER JOIN STB_QcInspectionItem III										ON (MIG.QcInspectionGroupCode = III.QcInspectionGroupCode)
							WHERE
									III.QcInspectionItemCode = @QcInspectionItemCode AND
									MIG.MaterialCode = @MaterialCode AND
									ISNULL(III.IsMaterialSpec, 0) = 0
							UNION ALL
							SELECT
									@MaterialQcNo AS MaterialQcNo,
									@MaterialQcDetailNo AS MaterialQcDetailNo, --순번
									MIG.QcInspectionGroupCode,
									IIG.QcInspectionGroupName,
									IIG.QcInspectionGroupDesc,
									III.QcInspectionItemCode,
									III.QcInspectionItemName,
									III.QcInspectionItemDesc,
									MIG.GroupInspectionPrior,
									MIG.GroupReportPrior,
									III.ItemInspectionPrior,
									III.ItemReportPrior,
									III.QcSpecDesc,
									III.InspectionType,
									III.IsMaterialSpec,
									MII.InspectionLevel, -- 테이블이 다름
									MII.AQL,
									0 AS RequestSampleQty,
									0 AS MaxAcceptDefectQty,
									NULL AS SampleQty,
									NULL AS PassedSampleQty,
									NULL AS DefectSampleQty,
									NULL AS SkipSampleQty,
									MII.SpecValue,
									MII.USL,
									MII.LSL,
									MII.UCL,
									MII.LCL,
									MII.TextSpecValue,
									NULL AS DecisionResult,
									GETDATE() AS CreateDateTime,
									@ProcessUserID AS CreateUserID,
									NULL AS ChangeDateTime,
									NULL AS ChangeUserID
							FROM
									STB_MaterialQcInspectionGroup MIG
									LEFT OUTER JOIN STB_QcInspectionGroup IIG										ON (MIG.QcInspectionGroupCode = IIG.QcInspectionGroupCode)
									LEFT OUTER JOIN STB_QcInspectionItem III										ON (MIG.QcInspectionGroupCode = III.QcInspectionGroupCode)
									LEFT OUTER JOIN STB_MaterialQcInspectionItem MII										ON (MIG.MaterialCode = MII.MaterialCode AND											III.QcInspectionItemCode = MII.QcInspectionItemCode)
							WHERE
									III.QcInspectionItemCode = @QcInspectionItemCode AND
									MIG.MaterialCode = @MaterialCode AND
									III.IsMaterialSpec = 1
						)

						INSERT INTO STB_MaterialQcDetail
									(
										MaterialQcNo,
										MaterialQcDetailNo,
										QcInspectionGroupCode,
										QcInspectionGroupName,
										QcInspectionGroupDesc,
										QcInspectionItemCode,
										QcInspectionItemName,
										QcInspectionItemDesc,
										GroupInspectionPrior,
										GroupReportPrior,
										ItemInspectionPrior,
										ItemReportPrior,
										QcSpecDesc,
										InspectionType,
										IsMaterialSpec,
										InspectionLevel,
										AQL,
										RequestSampleQty,
										MaxAcceptDefectQty,
										SampleQty,
										PassedSampleQty,
										DefectSampleQty,
										SkipSampleQty,
										SpecValue,
										USL,
										LSL,
										UCL,
										LCL,
										TextSpecValue,
										DecisionResult,
										CreateDateTime,
										CreateUserID,
										ChangeDateTime,
										ChangeUserID
									)
						SELECT
								MaterialQcNo,
								MaterialQcDetailNo,
								QcInspectionGroupCode,
								QcInspectionGroupName,
								QcInspectionGroupDesc,
								QcInspectionItemCode,
								QcInspectionItemName,
								QcInspectionItemDesc,
								GroupInspectionPrior,
								GroupReportPrior,
								ItemInspectionPrior,
								ItemReportPrior,
								QcSpecDesc,
								InspectionType,
								IsMaterialSpec,
								InspectionLevel,
								AQL,
								dbo.fnGetQcStandardSampleQty(InspectionType, @ArriveQty, AQL, InspectionLevel),
								dbo.fnGetQcStandardMaxDefectQty(InspectionType, @ArriveQty, AQL, InspectionLevel),
								CASE WHEN QcInspectionItemCode = 'IQC_GPD_18' THEN 10 
								     WHEN QcInspectionItemCode = 'IQC_GPD_19' THEN 10 
									 WHEN QcInspectionItemCode = 'IQC_GPD_20' AND @MaterialCode <> 'ECVT27-369' THEN 3
									 WHEN QcInspectionItemCode = 'IQC_GPD_20' AND @MaterialCode = 'ECVT27-369' THEN 10
									 WHEN InspectionLevel = 'S1'   THEN 5                                                ELSE 0 END AS SampleQty,                                -- 2020.07.01 박진호대리 요청사항
									 
								0 AS PassedSampleQty,
								0 AS DefectSampleQty,
								0 AS SkipSampleQty,
								SpecValue,
								USL,
								LSL,
								UCL,
								LCL,
								TextSpecValue,
								DecisionResult,
								CreateDateTime,
								CreateUserID,
								ChangeDateTime,
								ChangeUserID
						FROM
								InspectionItem

				END
				
				-- 여기까지 Detail
				-- 특성 검사항목에 대해 샘플리스트를 기본으로 생성해 줌. 품질부문요청 By Jackaroe 2019.10.29
				SET @SampleQty = CASE WHEN @QcInspectionItemCode = 'IQC_GPD_18' THEN 10
												  WHEN @QcInspectionItemCode = 'IQC_GPD_19' THEN 10
												  WHEN @QcInspectionItemCode = 'IQC_GPD_20' AND @MaterialCode <> 'ECVT27-369' THEN 3
												  WHEN @QcInspectionItemCode = 'IQC_GPD_20' AND @MaterialCode = 'ECVT27-369'   THEN 10  
												  WHEN @InspectionLevel = 'S1'   THEN 5                                                                               -- 2020.07.01 박진호대리 요청사항
												  ELSE 0 END 

				--IF @SampleQty <> 0 
				--BEGIN
				--	--Exec usp_DoCreateMaterialQcSampleResult @MaterialQcNo, @MaterialQcDetailNo, @SampleQty, 0       -- 시료별 수입검사결과에서 샘플수량만큼 셀이 자동생성되는 부분
				--END

			END
    END TRY

	BEGIN CATCH
		SET @ERROR_MSG = ERROR_MESSAGE()
		RAISERROR( @ERROR_MSG ,16, 1)
	END CATCH
	
	CLOSE DetailCursor;
	DEALLOCATE DetailCursor;
	
	END
END
