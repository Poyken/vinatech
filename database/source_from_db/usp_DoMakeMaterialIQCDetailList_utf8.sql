
-- =============================================
-- Author:	    shjoo
-- Create date: 2016-02-16
-- Browsable : true
-- Group : 품질관리
-- Description:	입하 시 수입검사상세 정보를 생성합니다. (샘플수량 Insert한후에 -> usp_DoCreateMaterialQcSampleResult 호출)

-- Modified:
--  2020.07.01 수입검사 샘플수량 자동반영 (박진호 대리)
-- VPC 특성 및 치수 샘플수량 및 샘플결과 자동생성 처리. 박진호 과장 요청, By Jackaroe #211105
-- =============================================
CREATE PROCEDURE [dbo].[usp_DoMakeMaterialIQCDetailList]
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
	DECLARE @SerialLen BIGINT
	--DECLARE @MaxKeyField VARCHAR(20)
	DECLARE @MaxKey INT

	DECLARE @IQC_ITEM_OPTION VARCHAR(50)
	
	-- Declare Columns Variable
	DECLARE @MaterialQcNo VARCHAR(20) = @pMaterialQcNo
	DECLARE @MaterialQcDetailNo BIGINT
	DECLARE @MaterialCode VARCHAR(50) = (SELECT MaterialCode FROM STB_MaterialQcInfo WHERE MaterialQcNo = @MaterialQcNo)
	DECLARE @DecisionResult VARCHAR(1) 

	declare @companycode varchar(10)= (select companycode from STB_UserInfo where UserID = @ProcessUserID)
	declare @WorkCenterCode   varchar(20)= (select companycode from STB_UserInfo where UserID = @ProcessUserID)

	DECLARE @SampleQty BIGINT=0

	-- ProductGroupCode 추가
	Declare @ProductGroupCode VARCHAR(20)

	SET @IQC_ITEM_OPTION = dbo.fnGetProcessRule('IQC_ITEM_OPTION','BY_GROUP')
	--PRINT @IQC_ITEM_OPTION
	--SET @IQC_ITEM_OPTION = 'BY_GROUP'
	SELECT
			@DecisionResult = MII.DecisionResult
	FROM
			STB_MaterialQcInfo MII  with(nolock) 
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
			DECLARE @QcInspectionItemDesc VARCHAR(20)
			DECLARE @InspectionLevel       VARCHAR(20)
			DECLARE @InspectionType			VARCHAR(20)
			DECLARE @AQL					VARCHAR(20)
			DECLARE @InQty                         BIGINT
			 

			DECLARE @ArriveQty NUMERIC(20,5)
        
			DECLARE @DetailTable TABLE (
				QcInspectionItemCode VARCHAR(20)
			   ,ProductGroupCode VARCHAR(20)			  
			)
		
			IF @IQC_ITEM_OPTION = 'BY_MATERIAL'

					BEGIN
						--RAISERROR(@MaterialCode, 16, 1)
							INSERT INTO @DetailTable
							SELECT
									MII.QcInspectionItemCode
                                   ,MM.ProductGroupCode
								  
							FROM
									STB_MaterialQcInspectionItem MII WITH (NOLOCK)
							LEFT OUTER JOIN STB_MaterialMaster MM WITH (NOLOCK)
							  ON MM.MaterialCode = MII.MaterialCode
							WHERE
									MII.MaterialCode = @MaterialCode
					END 			
			ELSE 			
					BEGIN
							INSERT INTO @DetailTable
							SELECT
									III.QcInspectionItemCode
								   ,MM.ProductGroupCode
								   
							FROM
									STB_MaterialQcInspectionGroup MIG WITH (NOLOCK)
									LEFT OUTER JOIN STB_QcInspectionItem III WITH (NOLOCK) ON (MIG.QcInspectionGroupCode = III.QcInspectionGroupCode)
									LEFT OUTER JOIN STB_MaterialMaster MM WITH (NOLOCK) ON MIG.MaterialCode = MM.MaterialCode
							WHERE
									MIG.MaterialCode = @MaterialCode
			         END
						
					SELECT
							@ArriveQty = MII.QcQty
					FROM
							STB_MaterialQcInfo MII WITH (NOLOCK)
					WHERE	
							MII.MaterialQcNo = @MaterialQcNo

				--declare @test varchar(20)
				--select @test = count(*) from @DetailTable
			 --raiserror(@test,16,1)
			PRINT 'LAST 1'
				
           -- CURSOR
			DECLARE DetailCursor CURSOR FOR
				SELECT
						QcInspectionItemCode
					   ,ProductGroupCode					  
				FROM
						@DetailTable

			OPEN DetailCursor
			
			WHILE 1 = 1 

			BEGIN
				FETCH NEXT FROM DetailCursor INTO @QcInspectionItemCode, @ProductGroupCode
				
				IF @@FETCH_STATUS <> 0 BEGIN
					BREAK
				END					
				

				SELECT
						@MaterialQcDetailNo = ISNULL(MAX(MaterialQcDetailNo),0) + 1
				FROM
						STB_MaterialQcDetail WITH (NOLOCK)
				WHERE
						MaterialQcNo = @MaterialQcNo	
						


				SELECT
						@QcInspectionItemDesc = QcInspectionItemDesc, 
						@InspectionLevel=InspectionLevel,
						@InspectionType=InspectionType,
						@AQL=AQL
				FROM
						STB_MaterialQcDetail WITH (NOLOCK)
				WHERE
						MaterialQcNo = @MaterialQcNo	
						and QcInspectionItemCode = @QcInspectionItemCode
						/*
						declare @fd varchar(100) = @MaterialCode+'---'+@QcInspectionItemCode
						raiserror(@fd,16,1)
						*/
					
						--	declare @fd varchar(100) = @MaterialCode+'---'+@QcInspectionItemCode
						--raiserror(@fd,16,1)
						SET @SampleQty= CASE 								
								WHEN @QcInspectionItemCode = 'IQC_GPD_18' AND @MaterialCode in ('ECVT27-272','ECVT27-370','ECVT27-371','ECVT30-293') AND @companycode='VVT' then 10   --SD: add by Mr.Tung 21-March-2023 by OQC spec 
								WHEN @QcInspectionItemCode = 'IQC_GPD_18' THEN 10 
								
							
								WHEN @QcInspectionItemCode = 'IQC_GPD_20'   AND @MaterialCode in ('RDMD00-301') AND @companycode='VVT' then 6
								WHEN (@QcInspectionItemCode = 'OQC-CEEL13' or @QcInspectionItemCode = 'OQC-CEEL14'    or @QcInspectionItemCode = 'OQC_Cell4'   or @QcInspectionItemCode = 'OQC_MD9')   AND @MaterialCode in ('RDMD00-301') AND @companycode='VVT' then 3   --ESR: add by Mr.Tung 21-March-2023 by OQC spec 

								WHEN @QcInspectionItemCode = 'IQC_GPD_19'  AND @MaterialCode in ('ECVT27-272','ECVT27-370','ECVT27-371','ECVT30-293','RDMD00-301') AND @companycode='VVT' then 20   --ESR: add by Mr.Tung 21-March-2023 by OQC spec 
								WHEN @QcInspectionItemCode = 'IQC_GPD_19' THEN 10
							
								WHEN @QcInspectionItemCode = 'IQC_GPD_20' 
																			AND (
																					@MaterialCode in ('ECVT30-076','ECVT30-117','ECVT30-098','ECVT30-197','ECVT30-294','ECVT30-116', 'ECVT27-358', 'ECVT30-357') or 
																						(select count(*) from stb_materialmaster with(nolock) where materialcode=@MaterialCode and replace(replace(MaterialName,'HY-CAP',''),' ','') in ('VEC3R0507QG(3582)','VEP3R0507QG(3582)','VEC3R0367QG(3562)','VEC3R0387QG(3562)','VEP3R0367QG(3562)'))>0
																				)
																			AND @companycode='VVT' then 10    --CAP: add by  Mr.Tung  08-September-2023 by OQC spec
																			
								WHEN @QcInspectionItemCode = 'IQC_GPD_20' AND @MaterialCode in ('ECVT27-272','ECVT27-370','ECVT27-371','ECVT30-293') AND @companycode='VVT' then 3    --CAP: add by Mr.Tung 21-March-2023 by OQC spec 							 
								WHEN @QcInspectionItemCode = 'IQC_GPD_20' AND @MaterialCode IN ('ECVT27-369', 'ECVT27-358') and @companycode='VVT' THEN 10		-- 2025-10-08 add ECVT27-358									--add by Mr.Tung 04-April-2022 by OQC request
								WHEN @QcInspectionItemCode = 'IQC_GPD_20' AND (@MaterialCode <> 'ECVT27-369' AND @ProductGroupCode <> 'HC-VPC') THEN 3
									
								WHEN @QcInspectionItemCode = 'IQC_GPD_20' AND @MaterialCode = 'ECVT27-369' THEN 20
								WHEN @QcInspectionItemCode = 'IQC_GPD_20' AND @ProductGroupCode = 'HC-VPC' THEN 10

								--WHEN @QcInspectionItemCode = 'IQC_GPD_21' AND @MaterialCode = 'ECVT30-262' THEN 125


								WHEN @QcInspectionItemCode = 'IQC_GPD_20' THEN 3
								WHEN @QcInspectionItemCode = 'IQC_G1_072' and @companycode='VVT' THEN 2																				--add by Mr.Tung 27-April-2022 by IQC request
								when @QcInspectionItemCode in ('IQC_M01','IQC_M02','IQC_R03','IQC_R04','IQC_O1','IQC_O2','IQC_O3') then 10											--add by Mr.Tung 16-May-2023 by TQC spec 
								WHEN @QcInspectionItemCode IN ('PQC_V01_01','PQC_V01_02','PQC_V01_03','PQC_V01_04','PQC_V01_05') THEN 10
								WHEN @QcInspectionItemCode IN ('PQC_V01_07','PQC_V01_08') THEN 20

								WHEN @QcInspectionItemCode IN ('PQC_V01_09')   then
									case when @MaterialCode not in ('LIVT38-009') THEN 20 
									else 10
									end

								WHEN @QcInspectionItemCode IN ('PQC_V01_10') THEN 3  -- 외관 항목과 마찬가지로 합격여부로만 관리하므로 샘플입력 항목은 생성하지 않음.
								WHEN @InspectionLevel = 'S1'   THEN dbo.fnGetQcStandardSampleQty(@InspectionType, @ArriveQty, @AQL, @InspectionLevel)
								WHEN @QcInspectionItemCode IN (SELECT QcInspectionItemCode 
																FROM STB_MaterialQcInspectionItem  WITH (NOLOCK)
																WHERE InspectionLevel = 'S1' 
																GROUP BY QcInspectionItemCode)  THEN 5
								--THEN dbo.fnGetQcStandardSampleQty(InspectionType, @ArriveQty, AQL, InspectionLevel)
								--#211105 --#211227 최은화 과장님 요청 45, 200, 3
								
								 --Mr.Tung add on 2023-11-17 for QC request
								
								 when @QcInspectionItemCode in ( select QcInspectionItemCode from STB_QcInspectionItem   WITH(NOLOCK)  where ISNUMERIC(QcSpecDesc)=1) then ( select top 1 convert(int,QcSpecDesc) from STB_QcInspectionItem   WITH(NOLOCK)  where QcInspectionItemCode=@QcInspectionItemCode)
								-- WHEN @QcInspectionItemCode = 'IQC_GPD_19' AND @MaterialCode = 'RDMD00-301'  THEN 20
								--WHEN @QcInspectionItemCode = 'OQC-CEEL13' AND @MaterialCode = 'RDMD00-301' THEN 3
								--WHEN @QcInspectionItemCode = 'OQC-CEEL13' AND @MaterialCode = 'RDMD00-301'  THEN 3
								
								--WHEN @QcInspectionItemCode = 'OQC_Cell4' AND @MaterialCode = 'RDMD00-301' THEN 3
								--WHEN @QcInspectionItemCode = 'OQC_MD9' AND @MaterialCode = 'RDMD00-301'  THEN 3
								ELSE 0 END 

------------------------------------------------------------- add 2024/12/20 start  -- thêm số lượng mẫu cần test
				--raiserror(@pProcessUserID,16,1)
				--if(@pProcessUserID='Hant-1998')
				--		begin
				--		select 	 @SampleQty=	MII.SampleQty		FROM
				--					STB_MaterialQcInspectionItem MII	 WITH (NOLOCK)								
				--		WHERE
				--					MII.MaterialCode = @MaterialCode AND
				--					MII.QcInspectionItemCode = @QcInspectionItemCode	
				--		end
------------------------------------------------------------- add 2024/12/20 end
										

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
									STB_MaterialQcInspectionItem MII	 WITH (NOLOCK)								
									LEFT OUTER JOIN STB_QcInspectionItem III	 WITH (NOLOCK) ON (III.QcInspectionItemCode = MII.QcInspectionItemCode)
									LEFT OUTER JOIN STB_QcInspectionGroup IIG	 WITH (NOLOCK) ON (IIG.QcInspectionGroupCode = III.QcInspectionGroupCode)
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
								

								@SampleQty,
								------CASE WHEN QcInspectionItemCode = 'IQC_GPD_18' AND @MaterialCode in ('ECVT27-272','ECVT27-370','ECVT27-371','ECVT30-293') AND @companycode='VVT' then 10   --SD: add by Mr.Tung 21-March-2023 by OQC spec 
								------	 WHEN QcInspectionItemCode = 'IQC_GPD_18' THEN 10 
								------	 WHEN QcInspectionItemCode = 'IQC_GPD_19' AND @MaterialCode in ('ECVT27-272','ECVT27-370','ECVT27-371','ECVT30-293') AND @companycode='VVT' then 20   --ESR: add by Mr.Tung 21-March-2023 by OQC spec 
								------     WHEN QcInspectionItemCode = 'IQC_GPD_19' THEN 10 
								------	 WHEN QcInspectionItemCode = 'IQC_GPD_20' AND @MaterialCode in ('ECVT27-272','ECVT27-370','ECVT27-371','ECVT30-293') AND @companycode='VVT' then 3    --CAP: add by Mr.Tung 21-March-2023 by OQC spec 							 
									 
								------	 WHEN QcInspectionItemCode = 'IQC_GPD_20' AND (@MaterialCode <> 'ECVT27-369' AND @ProductGroupCode <> 'HC-VPC') THEN 3
								------	 WHEN QcInspectionItemCode = 'IQC_GPD_20' AND @MaterialCode = 'ECVT27-369' and @companycode='VVT' THEN 10 --add by Mr.Tung 04-April-2022 by OQC request
								------	 WHEN @QcInspectionItemCode = 'IQC_G1_072' and @companycode='VVT' THEN 2			--add by Mr.Tung 27-April-2022 by IQC request
								------	 when @QcInspectionItemCode in ('IQC_M01','IQC_M02','IQC_R03','IQC_R04') then 10    --add by Mr.Tung 27-April-2022 by TQC spec 
								------	 WHEN QcInspectionItemCode = 'IQC_GPD_20' AND @MaterialCode = 'ECVT27-369' THEN 20
								------	 WHEN QcInspectionItemCode = 'IQC_GPD_20' AND @ProductGroupCode = 'HC-VPC' THEN 10
								------	 WHEN InspectionLevel = 'S1'   THEN dbo.fnGetQcStandardSampleQty(InspectionType, @ArriveQty, AQL, InspectionLevel)
								------	 --#211105 --#211227 최은화 과장님 요청 45, 200, 3
								------	 WHEN @QcInspectionItemCode IN ('PQC_V01_01','PQC_V01_02','PQC_V01_03','PQC_V01_04','PQC_V01_05') THEN 10
								------	 WHEN @QcInspectionItemCode IN ('PQC_V01_07','PQC_V01_08') THEN 20
								------	 WHEN @QcInspectionItemCode IN ('PQC_V01_09') THEN 20
								------	 WHEN @QcInspectionItemCode IN ('PQC_V01_10') THEN 3
								------	 when QcInspectionItemDesc in (N'Chiều dài dây',N'Kích Thước M',N'Kích Thước N',N'Kích Thước R') then 10
								------								   ELSE 0 END AS SampleQty,      -- 2020.07.01 박진호대리 요청사항 (원본백업)

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

			ELSE   --  @IQC_ITEM_OPTION <> 'BY_MATERIAL' (위 IF문의 반대조건)

			    BEGIN
						
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
									STB_MaterialQcInspectionGroup MIG WITH (NOLOCK)
									LEFT OUTER JOIN STB_QcInspectionGroup IIG WITH (NOLOCK) ON (MIG.QcInspectionGroupCode = IIG.QcInspectionGroupCode)
									LEFT OUTER JOIN STB_QcInspectionItem III WITH (NOLOCK) ON (MIG.QcInspectionGroupCode = III.QcInspectionGroupCode)
							WHERE 1=1
									AND III.QcInspectionItemCode = @QcInspectionItemCode 
									AND	MIG.MaterialCode = @MaterialCode 
									AND	ISNULL(III.IsMaterialSpec, 0) = 0 
									AND III.InspectionLevel = 	@InspectionLevel                                      -- 2020.07.03
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
									STB_MaterialQcInspectionGroup MIG WITH (NOLOCK)
									LEFT OUTER JOIN STB_QcInspectionGroup IIG	 WITH (NOLOCK)		ON (MIG.QcInspectionGroupCode = IIG.QcInspectionGroupCode)
									LEFT OUTER JOIN STB_QcInspectionItem III WITH (NOLOCK)		ON (MIG.QcInspectionGroupCode = III.QcInspectionGroupCode)
									LEFT OUTER JOIN STB_MaterialQcInspectionItem MII WITH (NOLOCK)		ON (MIG.MaterialCode = MII.MaterialCode AND											III.QcInspectionItemCode = MII.QcInspectionItemCode)
							WHERE 1=1
									AND III.QcInspectionItemCode = @QcInspectionItemCode
									AND MIG.MaterialCode = @MaterialCode 
									AND	III.IsMaterialSpec = 1 
									--AND III.InspectionLevel = 	@InspectionLevel                                      -- 2020.07.03						
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


								@SampleQty,
								--------CASE WHEN QcInspectionItemCode = 'IQC_GPD_18' THEN 10
								--------     WHEN QcInspectionItemCode = 'IQC_GPD_18' AND @MaterialCode in ('ECVT27-272','ECVT27-370','ECVT27-371','ECVT30-293') AND @companycode='VVT' then 10   --SD: add by Mr.Tung 21-March-2023 by OQC spec 
								--------	 WHEN QcInspectionItemCode = 'IQC_GPD_19' THEN 10
								--------	 WHEN QcInspectionItemCode = 'IQC_GPD_19' AND @MaterialCode in ('ECVT27-272','ECVT27-370','ECVT27-371','ECVT30-293') AND @companycode='VVT' then 20   --ESR: add by Mr.Tung 21-March-2023 by OQC spec 
								--------	 WHEN QcInspectionItemCode = 'IQC_GPD_20' AND @MaterialCode in ('ECVT27-272','ECVT27-370','ECVT27-371','ECVT30-293') AND @companycode='VVT' then 3    --CAP: add by Mr.Tung 21-March-2023 by OQC spec 							 
									 
								--------	 WHEN QcInspectionItemCode = 'IQC_GPD_20' AND (@MaterialCode <> 'ECVT27-369' AND @ProductGroupCode <> 'HC-VPC') THEN 3
								--------	 WHEN QcInspectionItemCode = 'IQC_GPD_20' AND @MaterialCode = 'ECVT27-369' and @companycode='VVT' THEN 10 --add by Mr.Tung 01-April-2022 by OQC request
								--------	 WHEN @QcInspectionItemCode = 'IQC_G1_072' and @companycode='VVT' THEN 2			--add by Mr.Tung 27-April-2022 by IQC request
								--------	 when @QcInspectionItemCode in ('IQC_M01','IQC_M02','IQC_R03','IQC_R04') then 10    --add by Mr.Tung 27-April-2022 by TQC spec 
								--------	 WHEN QcInspectionItemCode = 'IQC_GPD_20' AND @MaterialCode = 'ECVT27-369' THEN 20
								--------	 WHEN QcInspectionItemCode = 'IQC_GPD_20' AND @ProductGroupCode = 'HC-VPC' THEN 10
								--------	 --WHEN InspectionLevel = 'S1'   
								--------	 WHEN QcInspectionItemCode IN (SELECT QcInspectionItemCode 
								--------	                                 FROM STB_MaterialQcInspectionItem  WITH (NOLOCK)
								--------									WHERE InspectionLevel = 'S1' 
								--------									GROUP BY QcInspectionItemCode)  THEN 5
								--------	 --THEN dbo.fnGetQcStandardSampleQty(InspectionType, @ArriveQty, AQL, InspectionLevel)
								--------	 --#211105 --#211227 최은화 과장님 요청 45, 200, 3
								--------	 WHEN @QcInspectionItemCode IN ('PQC_V01_01','PQC_V01_02','PQC_V01_03','PQC_V01_04','PQC_V01_05') THEN 10
								--------	 WHEN @QcInspectionItemCode IN ('PQC_V01_07','PQC_V01_08') THEN 20
								--------	 WHEN @QcInspectionItemCode IN ('PQC_V01_09') THEN 20
								--------	 WHEN @QcInspectionItemCode IN ('PQC_V01_10') THEN 3
								--------	 when QcInspectionItemDesc in (N'Chiều dài dây',N'Kích Thước M',N'Kích Thước N',N'Kích Thước R') then 10
								--------	 ELSE 0 END AS SampleQty,      -- 2020.07.01 박진호대리 요청사항 (원본백업)
									 
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
			           

					IF @SampleQty <> 0 				
					BEGIN
					------------------------ add 2024/12/20 start  -- 
				
						declare @USL NUMERIC (20,5) 
						declare @LSL NUMERIC (20,5)
						select @USL=USL, @LSL=LSL from STB_QcInspectionItem  where  QcInspectionItemCode=@QcInspectionItemCode
						if(@WorkCenterCode ='VVT_F3' and @USL is null and @LSL is null )
						begin
								set @SampleQty =0
						end
								
				
						

					----------------------- add 2024/12/20 end
					

					PRINT 'LAST LAST IF'
					Exec usp_DoCreateMaterialQcSampleResult @MaterialQcNo, @MaterialQcDetailNo, @SampleQty, 0       -- 시료별 수입검사결과에서 샘플수량만큼 셀이 자동생성되는 부분
                            --[프로시저 실행 Test]  usp_DoCreateMaterialQcSampleResult '20070300016','6',5,0                     -- [참고] 화면 생성버튼에서 불러주는 프로시저는 다름 (Exec usp_DoMakeMaterialQcSampleResult )					
				END

			END
    END TRY

	BEGIN CATCH
		SET @ERROR_MSG = ERROR_MESSAGE()
		RAISERROR( @ERROR_MSG ,16, 1)
	END CATCH
	
	CLOSE DetailCursor;
	DEALLOCATE DetailCursor;
	
	END

	PRINT 'LAST LAST END'
END

