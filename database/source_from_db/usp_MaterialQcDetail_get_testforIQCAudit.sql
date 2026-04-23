-- =============================================
-- Author:		DinhManh
-- Create date: 2025-05-13
-- Description:	test on 2025-05-13 for audit 
-- =============================================
CREATE PROCEDURE [dbo].[usp_MaterialQcDetail_get_testforIQCAudit]
	-- Add the parameters for the stored procedure here
								@pProcessUserID VARCHAR(20),
								@pProcessLanguage VARCHAR(20),
								@pMaterialQcNo VARCHAR(20) = 'MaterialQcNo' 
WITH RECOMPILE
AS
BEGIN
	SET NOCOUNT ON;
	
	DECLARE @MaterialQcNo VARCHAR(20) = CASE WHEN ISNULL(@pMaterialQcNo,'') = '' THEN '*' ELSE @pMaterialQcNo END
	DECLARE @Barcode         VARCHAR(20) 
	DECLARE @CompanyCode VARCHAR(20)
	DECLARE @WorkCenterCode VARCHAR(20)
	DECLARE @InspectionDocType VARCHAR(20)
	DECLARE @QcQty NUMERIC(20,5) = 0
	DECLARE @MaterialCode VARCHAR(60)  -- 2021.11.28

	Declare @QcInspectionItemCodeList TABLE (
		QcInspectionItemCode VARCHAR(20)
	   ,Is0825 INT
	);

	INSERT INTO @QcInspectionItemCodeList
		SELECT 'PQC_V01_01', 1
		UNION ALL
		SELECT 'PQC_V01_02', 0
		UNION ALL
		SELECT 'PQC_V01_03', 0
		UNION ALL
		SELECT 'PQC_V01_04', 0
		UNION ALL
		SELECT 'PQC_V01_05', 0

    
	SELECT  @Barcode = Barcode
	         , @MaterialCode = MaterialCode  -- 2021.11.28
	  FROM STB_SetInfo
	WHERE LotNumber  = @MaterialQcNo

	SELECT @CompanyCode = CompanyCode ,  
			@MaterialCode = isnull(MaterialCode,@MaterialCode),
			-- DinhManh update
			@WorkCenterCode = WorkCenterCode,
			@InspectionDocType = InspectionDocType,
			@QcQty = QcQty

	  FROM STB_MaterialQcInfo
	 WHERE MaterialQcNo = @MaterialQcNo

			--	SELECT   Barcode, LotNumber, *
			--  FROM STB_SetInfo
			--WHERE LotNumber  = '20092100004'


		
	-- IF @MaterialQcNo LIKE 'VV%'    -- 베트남 바코드의 경우   -- 기존 소스 백업
	  IF @CompanyCode LIKE 'VVT'    -- 베트남 바코드의 경우

	   BEGIN 



			   DECLARE @LotNonew1 VARCHAR(20) = ''
			DECLARE @LotNonew2 VARCHAR(20) = ''
			DECLARE @LotNonew3 VARCHAR(20) = ''
			DECLARE @LotNonew4 VARCHAR(20) = ''
			DECLARE @LotNonew5 VARCHAR(20) = ''
			DECLARE @LotNonew6 VARCHAR(20) = ''

			DECLARE @currentLotno VARCHAR(20) = ''

			select @LotNonew1 = NewBarcode
			from STB_LotChangeMaterialHistory  WITH(NOLOCK)
			where OldBarcode=@MaterialQcNo; 
	
			select @LotNonew2 = NewBarcode
			from STB_LotChangeMaterialHistory  WITH(NOLOCK)
			where OldBarcode=@LotNonew1 ;

			select @LotNonew3 = NewBarcode
			from STB_LotChangeMaterialHistory  WITH(NOLOCK)
			where OldBarcode=@LotNonew2 ;

			select @LotNonew4 = NewBarcode
			from STB_LotChangeMaterialHistory  WITH(NOLOCK)
			where OldBarcode=@LotNonew3 ;

			select @LotNonew5 = NewBarcode
			from STB_LotChangeMaterialHistory  WITH(NOLOCK)
			where OldBarcode=@LotNonew4 ;

			select @LotNonew6 = NewBarcode
			from STB_LotChangeMaterialHistory  WITH(NOLOCK)
			where OldBarcode=@LotNonew5 ;
	

		 select @currentLotno = Barcode 
		 from STB_SetInfo   WITH(NOLOCK) where Barcode in (@MaterialQcNo,@LotNonew1,@LotNonew2,@LotNonew3,@LotNonew4,@LotNonew5,@LotNonew6);


		-- 베트남  부문창님 of QC require to check 20 SD value and 20 ESR value
		-- Mr.Tung EA 베트남 modified updating this area 
		-- Date:  28-August-2020
		-- START
		DECLARE @sumSampleQtyESR numeric(20,5) = 20
		DECLARE @sumSampleQtySD numeric(20,5) = 10
		DECLARE @sumSampleQtyCAP numeric(20,5) = 3
		DECLARE @sumSampleQty특성_용량 numeric(20,5) = 20
		DECLARE @cCount INT



		--CAP
		-- Mr.Duy thêm tất cả các mã của hàng VPC bắc giang đổi 특성_용량 từ ktra 20 -> 10 theo yêu cầu của Ms.Thơm 2025-02-21
		select @cCount = count(*)
		  from 
		  stb_modelbasicinfo with(nolock) 
		  where modelcode=(select materialcode from STB_SetInfo where Barcode=@currentLotno) 
		  and ((ModelName like '%VEC2R7%1840%'  and convert(numeric(10,2),isnull(MBIExtText05,0))=50)
		  or (ModelName like '%VEL%'))

	 	 if (@cCount>0  )
	 	 begin
			select @sumSampleQtyESR  = 20
			select @sumSampleQtySD   = 10
			select @sumSampleQtyCAP  = 10
			select @sumSampleQty특성_용량  = 10
		 end
		 

		 ----  2023-September-08 by Mr.Tung , removed 40 ESR for 1030 model
		 select @cCount = count(*) 
		 from STB_SetInfo  with(nolock) 
		 where Barcode=@MaterialQcNo 
		 and (
				MaterialCode in ('ECVT30-076','ECVT30-117','ECVT30-098','ECVT30-197','ECVT30-294','ECVT30-116','ECVT30-294') or 
				(select count(*) from stb_materialmaster with(nolock) where materialcode=@MaterialCode and replace(replace(MaterialName,'HY-CAP',''),' ','') in ('VEC3R0507QG(3582)','VEP3R0507QG(3582)','VEC3R0367QG(3562)','VEC3R0387QG(3562)','VEP3R0367QG(3562)'))>0
			 )

		declare @MaterialCodeMer varchar(20)

			SELECT @MaterialCodeMer = c.MaterialCode 
			FROM VVT_OQC_REFER  a  with(nolock)
			join STB_SetInfo  b  WITH(NOLOCK) on a.mergeid = b.Barcode 
			join STB_MaterialMaster  c  WITH(NOLOCK) on b.MaterialCode = c.MaterialCode 
			WHERE  (finished is not null or finished<>'')  
			and a.isSeparated = '1'
			and  mergeid = CASE WHEN (CHARINDEX('-', @MaterialQcNo) > 0) THEN SUBSTRING(@MaterialQcNo, 1, CHARINDEX('-', @MaterialQcNo) - 1) ELSE @MaterialQcNo END
		print @MaterialCodeMer
		 if(@MaterialCodeMer in ('ECVT30-294'))
		 begin
			select @sumSampleQtyCAP  = 10
		 end

		 if (@cCount>0  )
	 	 begin
		 	select @sumSampleQtyESR  = 20
			select @sumSampleQtySD   = 10
			select @sumSampleQtyCAP  = 10
		 end



		 declare @itemforcheck varchar(4)='10'  --Mr.Tung add on 2023-11-17 for QC request
		 update   mqd  
		 set   SampleQty=convert(int,isnull((SELECT  (case when ISNUMERIC(QcSpecDesc)=1 then QcSpecDesc else @itemforcheck end)	FROM  STB_QcInspectionItem  WITH(NOLOCK) WHERE QcInspectionItemCode=mqd.QcInspectionItemCode),@itemforcheck))
		 from STB_MaterialQcDetail mqd
		 WHERE 1=1
			 AND (MaterialQcNo = @MaterialQcNo)  
			 and isnull(TextSpecValue,'')=''
			 and QcInspectionItemCode in ( select QcInspectionItemCode from STB_QcInspectionItem   WITH(NOLOCK)  where ISNUMERIC(QcSpecDesc)=1)

			 if(@MaterialCode ='RDMD00-301')
				begin
					set	@sumSampleQtyCAP =6
				end 
			 --raiserror(@MaterialCode,16,1)
		 update  STB_MaterialQcDetail 
			set SampleQty = @sumSampleQtyCAP
			WHERE 1=1
			 AND (MaterialQcNo = @MaterialQcNo)
			 and QcInspectionItemCode in ('IQC_GPD_20')


		--ESR
		   update  STB_MaterialQcDetail 
			set SampleQty = @sumSampleQtyESR
			WHERE 1=1
			 AND (MaterialQcNo = @MaterialQcNo)
			 and QcInspectionItemCode in ('IQC_GPD_19')

			 
		--SD Mr.Tung add on 2021-July-17 for SD measure , IQC inspection of HY-CAP import from HeadQuarter
		   update  STB_MaterialQcDetail 
			set SampleQty = 5                 --5 values of SD
			WHERE 1=1
			 AND (MaterialQcNo = @MaterialQcNo)
			 and QcInspectionItemCode in ('IQC_GPD_18')
			 and (select top 1 InspectionDocType from STB_MaterialQcInfo where MaterialQcNo = @MaterialQcNo)='IQC'
		-- END by Mr.Tung
			   		 

					
		--SD add by loan change quality sd=10 ea
	    	update  STB_MaterialQcDetail 
			set SampleQty = @sumSampleQtySD
			WHERE 1=1
			 AND (MaterialQcNo = @MaterialQcNo)
			 and QcInspectionItemCode in ('IQC_GPD_18')

			 --SD add by duy change quality sd=10 ea
	    	update  STB_MaterialQcDetail 
			set SampleQty = @sumSampleQty특성_용량
			WHERE 1=1
			 AND (MaterialQcNo = @MaterialQcNo)
			 and QcInspectionItemCode in ('PQC_V01_09')

			 --begin by Mr.Tung on 27-April-2022 for Vietnam factory
			 declare @SampleQty int = 0
			declare @MaterialQcDetailNo VARCHAR(30) = ''
			
			select top 1
			@SampleQty = CASE 
												  WHEN QcInspectionItemCode = 'IQC_G1_072' and @CompanyCode='VVT' THEN 2			--add by Mr.Tung 27-April-2022 by IQC request
												  when QcInspectionItemCode in ('IQC_M01','IQC_M02','IQC_R03','IQC_R04','IQC_O1','IQC_O2','IQC_O3') then 10   --add by Mr.Tung 16-May-2023 by TQC spec 
												 
												  ELSE 0 END ,
			@MaterialQcDetailNo = MaterialQcDetailNo
			from STB_MaterialQcDetail with(nolock) 
			WHERE 1=1 
			 AND (MaterialQcNo = @MaterialQcNo) 
			 
			IF @SampleQty <> 0 				
				BEGIN
					Exec usp_DoCreateMaterialQcSampleResult @MaterialQcNo, @MaterialQcDetailNo, @SampleQty, 0       -- 시료별 수입검사결과에서 샘플수량만큼 셀이 자동생성되는 부분
                            --[프로시저 실행 Test]  usp_DoCreateMaterialQcSampleResult '20070300016','6',5,0                     -- [참고] 화면 생성버튼에서 불러주는 프로시저는 다름 (Exec usp_DoMakeMaterialQcSampleResult )					
				END
			--end by Mr.Tung on 27-April-2022 for Vietnam factory

			IF (@WorkCenterCode IN ('VVT_F1', 'VVT_F2') AND @InspectionDocType = 'IQC')     -- DinhManh update

				BEGIN

					
					--raiserror('hello', 16, 1)
					--return
					SELECT
						MQD.MaterialQcNo AS OldMaterialIqcNo,
						MQD.MaterialQcDetailNo AS OldMaterialIqcDetailNo,
						MQD.MaterialQcNo,
						MQD.MaterialQcDetailNo,
						MQD.QcInspectionGroupCode,
						MQD.QcInspectionGroupName,
						MQD.QcInspectionGroupDesc,
						MQD.QcInspectionItemCode,
						MQD.QcInspectionItemName,
						MQD.QcInspectionItemDesc,
						MQD.GroupInspectionPrior,
						MQD.GroupReportPrior,
						MQD.ItemInspectionPrior,
						MQD.ItemReportPrior,
						MQD.QcSpecDesc,
						MQD.InspectionType,
						MQD.IsMaterialSpec,
						MQD.InspectionLevel,
						MQD.AQL,
						--MQD.RequestSampleQty,
						CASE 
							WHEN MQD.QcInspectionItemCode IN (select QcInspectionItemCode FROM STB_QcInspectionItem where IsSI01Standard = 1) AND (@QcQty > 1 AND @QcQty < 50) THEN 2
							WHEN MQD.QcInspectionItemCode IN (select QcInspectionItemCode FROM STB_QcInspectionItem where IsSI01Standard = 1) AND (@QcQty > 51 AND @QcQty < 500) THEN 3
							WHEN MQD.QcInspectionItemCode IN (select QcInspectionItemCode FROM STB_QcInspectionItem where IsSI01Standard = 1) AND (@QcQty > 501 AND @QcQty < 35000) THEN 5
							WHEN MQD.QcInspectionItemCode IN (select QcInspectionItemCode FROM STB_QcInspectionItem where IsSI01Standard = 1) AND (@QcQty > 35001) THEN 8
							ELSE MQD.RequestSampleQty
						END AS RequestSampleQty,
						MQD.MaxAcceptDefectQty,				
						--MQD.SampleQty ,                -- 베트남의 경우는 SD는 측정수량이 20
						CASE 
							WHEN MQD.QcInspectionItemCode IN (select QcInspectionItemCode FROM STB_QcInspectionItem where IsSI01Standard = 1) AND (@QcQty > 1 AND @QcQty < 50) THEN 2
							WHEN MQD.QcInspectionItemCode IN (select QcInspectionItemCode FROM STB_QcInspectionItem where IsSI01Standard = 1) AND (@QcQty > 51 AND @QcQty < 500) THEN 3
							WHEN MQD.QcInspectionItemCode IN (select QcInspectionItemCode FROM STB_QcInspectionItem where IsSI01Standard = 1) AND (@QcQty > 501 AND @QcQty < 35000) THEN 5
							WHEN MQD.QcInspectionItemCode IN (select QcInspectionItemCode FROM STB_QcInspectionItem where IsSI01Standard = 1) AND (@QcQty > 35001) THEN 8
							ELSE MQD.SampleQty
						END AS SampleQty,
						MQD.PassedSampleQty,
						MQD.DefectSampleQty,
						MQD.SkipSampleQty,
						MQD.SpecValue,
						MQD.USL,
						--Case When MQD.USL is null then 10000 Else MQD.USL End AS USL, -- 박진호 대리요청 (2020-07-15)
						MQD.LSL,
						MQD.UCL,
						MQD.LCL,
						MQD.TextSpecValue,
						MQD.DecisionResult,
						MQD.Description,
						MQD.CreateDateTime,
						MQD.CreateUserID,
						MQD.ChangeDateTime,
						MQD.ChangeUserID				
				FROM  STB_MaterialQcDetail MQD WITH(NOLOCK)
				WHERE 1=1
					 AND ((@MaterialQcNo = '*') OR (MQD.MaterialQcNo = @MaterialQcNo)) 
				ORDER BY ItemReportPrior ASC

				END
			
			ELSE 
				BEGIN
					SELECT
						MQD.MaterialQcNo AS OldMaterialIqcNo,
						MQD.MaterialQcDetailNo AS OldMaterialIqcDetailNo,
						MQD.MaterialQcNo,
						MQD.MaterialQcDetailNo,
						MQD.QcInspectionGroupCode,
						MQD.QcInspectionGroupName,
						MQD.QcInspectionGroupDesc,
						MQD.QcInspectionItemCode,
						MQD.QcInspectionItemName,
						MQD.QcInspectionItemDesc,
						MQD.GroupInspectionPrior,
						MQD.GroupReportPrior,
						MQD.ItemInspectionPrior,
						MQD.ItemReportPrior,
						MQD.QcSpecDesc,
						MQD.InspectionType,
						MQD.IsMaterialSpec,
						MQD.InspectionLevel,
						MQD.AQL,
						MQD.RequestSampleQty,
						MQD.MaxAcceptDefectQty,				
						MQD.SampleQty ,                -- 베트남의 경우는 SD는 측정수량이 20
						MQD.PassedSampleQty,
						MQD.DefectSampleQty,
						MQD.SkipSampleQty,
						MQD.SpecValue,
						MQD.USL,
						--Case When MQD.USL is null then 10000 Else MQD.USL End AS USL, -- 박진호 대리요청 (2020-07-15)
						MQD.LSL,
						MQD.UCL,
						MQD.LCL,
						MQD.TextSpecValue,
						MQD.DecisionResult,
						MQD.Description,
						MQD.CreateDateTime,
						MQD.CreateUserID,
						MQD.ChangeDateTime,
						MQD.ChangeUserID				
				FROM  STB_MaterialQcDetail MQD WITH(NOLOCK)
				WHERE 1=1
					 AND ((@MaterialQcNo = '*') OR (MQD.MaterialQcNo = @MaterialQcNo)) 
				ORDER BY ItemReportPrior ASC

				END
				
	     	

	END ELSE BEGIN
	     	IF @pProcessUserID = 'yjyu' BEGIN
			--	SELECT
			--		MQD.MaterialQcNo AS OldMaterialIqcNo,
			--		MQD.MaterialQcDetailNo AS OldMaterialIqcDetailNo,
			--		MQD.MaterialQcNo,
			--		MQD.MaterialQcDetailNo,
			--		MQD.QcInspectionGroupCode,
			--		MQD.QcInspectionGroupName,
			--		MQD.QcInspectionGroupDesc,
			--		MQD.QcInspectionItemCode,
			--		MQD.QcInspectionItemName,
			--		MQD.QcInspectionItemDesc,
			--		MQD.GroupInspectionPrior,
			--		MQD.GroupReportPrior,
			--		MQD.ItemInspectionPrior,
			--		MQD.ItemReportPrior,
			--		MQD.QcSpecDesc,
			--		MQD.InspectionType,
			--		MQD.IsMaterialSpec,
			--		MQD.InspectionLevel,
			--		MQD.AQL,
			--		MQD.RequestSampleQty,
			--		MQD.MaxAcceptDefectQty,				
			--		CASE WHEN ISNULL(MQD.SampleQty, 0) > 0 THEN MQD.SampleQty ELSE MQD.RequestSampleQty END  AS SampleQty,       --2019.03.28 kilee (대상샘플수량과 샘플수량 동일하게)
			--		--CASE WHEN MQD.QcInspectionItemCode = 'IQC_GPD_20' THEN 10 ELSE MQD.SampleQty END AS SampleQty,           --10개 고정
			--		MQD.PassedSampleQty,
			--		MQD.DefectSampleQty,
			--		MQD.SkipSampleQty,
			--		MQD.SpecValue,
			--		MQD.USL,
			--		--Case When MQD.USL is null then 10000 Else MQD.USL End AS USL, -- 박진호 대리요청 (2020-07-15)
			--		MQD.LSL,
			--		MQD.UCL,
			--		MQD.LCL,
			--		MQD.TextSpecValue,
			--		MQD.DecisionResult,
			--		'' AS Description ,
			--		MQD.CreateDateTime,
			--		MQD.CreateUserID,
			--		MQD.ChangeDateTime,
			--		MQD.ChangeUserID,
			--		0 AS Cpk				
			--FROM  [110.11.27.5].SmartFactoryV2.dbo.STB_MaterialQcDetail MQD WITH(NOLOCK)
			--LEFT OUTER JOIN [110.11.27.5].SmartFactoryV2.dbo.STB_MaterialQcInfo MQI
			--  ON MQI.MaterialQcNo = MQD.MaterialQcNo
			--WHERE 1=1
			--	 AND MQD.MaterialQcNo = @MaterialQcNo
			--	 AND MQD.QcInspectionItemCode NOT IN (SELECT QcInspectionItemCode 
			--											FROM @QcInspectionItemCodeList
			--										   WHERE Is0825 <= CASE WHEN MQI.MaterialCode = 'LIVT38-018' THEN 0 ELSE 1 END
			--									 )
			--ORDER BY ItemReportPrior ASC
			print '1'
			END ELSE BEGIN

				SELECT
					MQD.MaterialQcNo AS OldMaterialIqcNo,
					MQD.MaterialQcDetailNo AS OldMaterialIqcDetailNo,
					MQD.MaterialQcNo,
					MQD.MaterialQcDetailNo,
					MQD.QcInspectionGroupCode,
					MQD.QcInspectionGroupName,
					MQD.QcInspectionGroupDesc,
					MQD.QcInspectionItemCode,
					MQD.QcInspectionItemName,
					MQD.QcInspectionItemDesc,
					MQD.GroupInspectionPrior,
					MQD.GroupReportPrior,
					MQD.ItemInspectionPrior,
					MQD.ItemReportPrior,
					MQD.QcSpecDesc,
					MQD.InspectionType,
					MQD.IsMaterialSpec,
					MQD.InspectionLevel,
					MQD.AQL,
					MQD.RequestSampleQty,
					MQD.MaxAcceptDefectQty,				
					CASE WHEN ISNULL(MQD.SampleQty, 0) > 0 THEN MQD.SampleQty ELSE MQD.RequestSampleQty END  AS SampleQty,       --2019.03.28 kilee (대상샘플수량과 샘플수량 동일하게)
					--CASE WHEN MQD.QcInspectionItemCode = 'IQC_GPD_20' THEN 10 ELSE MQD.SampleQty END AS SampleQty,           --10개 고정
					MQD.PassedSampleQty,
					MQD.DefectSampleQty,
					MQD.SkipSampleQty,
					MQD.SpecValue,
					MQD.USL,
					--Case When MQD.USL is null then 10000 Else MQD.USL End AS USL, -- 박진호 대리요청 (2020-07-15)
					MQD.LSL,
					MQD.UCL,
					MQD.LCL,
					MQD.TextSpecValue,
					MQD.DecisionResult,
					MQD.Description ,
					MQD.CreateDateTime,
					MQD.CreateUserID,
					MQD.ChangeDateTime,
					MQD.ChangeUserID,
					MQD.Cpk				
			FROM  STB_MaterialQcDetail MQD WITH(NOLOCK)
			LEFT OUTER JOIN STB_MaterialQcInfo MQI
			  ON MQI.MaterialQcNo = MQD.MaterialQcNo
			WHERE 1=1
				 AND MQD.MaterialQcNo = @MaterialQcNo
				 AND MQD.QcInspectionItemCode NOT IN (SELECT QcInspectionItemCode 
														FROM @QcInspectionItemCodeList
													   WHERE Is0825 <= CASE WHEN MQI.MaterialCode = 'LIVT38-018' THEN 0 ELSE 1 END
												 )
			ORDER BY ItemReportPrior ASC
			END

	END
END
