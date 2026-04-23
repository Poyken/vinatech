
-- =============================================
-- Author:	    Anonymous()
-- Create date: 2016-02-17
-- Browsable : true
-- Group : 품질관리 > 시료별수입검사 & 시료별입고검사 > 2번째 Grid화면
--            품질관리 > 제품검사 > 2번째 Grid
-- Description:	수입검사 및 제품검사 상세를 조회합니다
-- Modified: 
--             @pMaterialQcNo 기본값 변경, 기존처럼 기본값이 Null인 경우 해외법인 입고현황 등의 화면에서는 Detail 테이블의 전체조회가 일어남. 2020.09.07 By Jackaroe
--             베트남 Tung이 Update문 수정한 것 잘못되어, @LotNumber추가하여 조건 변경함. (2020-09-21  kilee 수정)
--             베트남 Tung이 remove IQC & HYCAP condition on 22-June-2021
--             Mr.Tung add by Mr.Tung 16-May-2023 
--			   Mr.Tung add on 2023-06-18 for QC request
-- 프로시저 실행문 :  EXEC usp_MaterialQcDetail_get '','','VVPM193R038706-1'
-- =======================================================================================================================
CREATE PROCEDURE [dbo].[usp_MaterialQcDetail_get]   
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
	DECLARE @MaterialCode VARCHAR(60)  -- 2021.11.28
	DECLARE @WorkCenterCode VARCHAR(20)
	DECLARE @InspectionDocType VARCHAR(20)
	DECLARE @QcQty NUMERIC(20,5) = 0

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
			 -- DinhManh update 2025-05-16
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
		DECLARE @sumSampleQtyInspection int = 0 , @pQcInspectionItemCode varchar(20)='IQC_GPD_21'
		DECLARE @sumSampleQty특성_용량 numeric(20,5) = 20
		DECLARE @cCount INT

		-- UPDATE Request Sample Qty for 'IQC_GPD_22' -- following Ms.Doan Hanh's request 2025-08-26
		DECLARE @PackQty INT = NULL
		-- 2026-02-03 lấy trong bảng này trước, 
		SELECT @PackQty = RequestSampleQty FROM STB_OQCDetailSampleQty_VVT where MaterialCode = @MaterialCode and QCInspectionGroupCode = 'IQC_GPD_22'

		IF @PackQty IS NULL -- nếu không có tiêu chuẩn thì lấy số lượng đóng gói B781
			BEGIN
				SELECT TOP 1 @PackQty =  PackQty FROM STB_SavePackingTime_VVT SPT where LotNo = @currentLotno AND SPT.PackQty > 0 AND SPT.IsPrinted = 0 -- lấy số lượng đóng gói ở B781
			END


		IF (@PackQty > 0 AND @PackQty IS NOT NULL)
			BEGIN
				UPDATE STB_MaterialQcDetail
				SET RequestSampleQty = @PackQty
				WHERE MaterialQcNo = @currentLotno
				AND	QcInspectionItemCode IN  ('IQC_GPD_22')

				UPDATE STB_MaterialQcDetail
				SET SampleQty = case 
								when @PackQty >= 1 and @PackQty <= 8 THEN 2
								when @PackQty >= 9 and @PackQty <= 15 THEN 3
								when @PackQty >= 16 and @PackQty <= 25 THEN 5
								when @PackQty >= 26 and @PackQty <= 50 THEN 8
								when @PackQty >= 51 and @PackQty <= 90 THEN 13
								when @PackQty >= 91 and @PackQty <= 150 THEN 20
								when @PackQty >= 151 and @PackQty <= 280 THEN 32
								when @PackQty >= 281 and @PackQty <= 500 THEN 50
								when @PackQty >= 501 and @PackQty <= 1200 THEN 80
								when @PackQty >= 1201 and @PackQty <= 3200 THEN 125
								when @PackQty >= 3201 and @PackQty <= 10000 THEN 200
								when @PackQty >= 10001 and @PackQty <= 35000 THEN 315
								when @PackQty >= 35001 and @QcQty <= 150000 THEN 500
								when @PackQty >= 150001 and @PackQty <= 500000 THEN 800
								ELSE RequestSampleQty END
				WHERE MaterialQcNo = @currentLotno
				AND	QcInspectionItemCode IN  ('PQC_V01_06', 'IQC_GPD_21')

			END

		-- END UPDATE




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
			--Cập nhật số lượng kiểm tra ngoại quan
	
			set @sumSampleQtyInspection = case when @MaterialCodeMer in ('ECVT30-294')
			then 125
			else @sumSampleQtyInspection
			end
			--end

		 if(@MaterialCodeMer in ('ECVT30-294', 'ECVT30-370')) 
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

			 -- update by Mr.Manh 2025-09-09 following GII Standard for Al case (Mr.Phuong IQC TL request)
			update  STB_MaterialQcDetail 
			-- select top 1 * from STB_MaterialQcDetail
			set RequestSampleQty = case 
								when @QcQty >= 1 and @QcQty <= 8 THEN 2
								when @QcQty >= 9 and @QcQty <= 15 THEN 3
								when @QcQty >= 16 and @QcQty <= 25 THEN 5
								when @QcQty >= 26 and @QcQty <= 50 THEN 8
								when @QcQty >= 51 and @QcQty <= 90 THEN 13
								when @QcQty >= 91 and @QcQty <= 150 THEN 20
								when @QcQty >= 151 and @QcQty <= 280 THEN 32
								when @QcQty >= 281 and @QcQty <= 500 THEN 50
								when @QcQty >= 501 and @QcQty <= 1200 THEN 80
								when @QcQty >= 1201 and @QcQty <= 3200 THEN 125
								when @QcQty >= 3201 and @QcQty <= 10000 THEN 200
								when @QcQty >= 10001 and @QcQty <= 35000 THEN 315
								when @QcQty >= 35001 and @QcQty <= 150000 THEN 500
								when @QcQty >= 150001 and @QcQty <= 500000 THEN 800
								ELSE 1250 
							END

			WHERE 1=1
			 AND (MaterialQcNo = @MaterialQcNo)
			 and QcInspectionItemCode in ('IQC_G1_003')

			 -- Mr.Manh UPDATE ECVT30-370 2025-11-10 for JiangHai
			 IF @MaterialCode IN ('ECVT30-370', 'ECVT30-357')
				BEGIN
					 update  STB_MaterialQcDetail 
					set SampleQty = '10'
					WHERE 1=1
					 AND (MaterialQcNo = @MaterialQcNo)
					 and QcInspectionItemCode in ('IQC_GPD_20')
				 END
				-- END

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


			
			IF (@WorkCenterCode IN ('VVT_F1', 'VVT_F2') AND @InspectionDocType = 'IQC')     -- DinhManh update 2025-05-16 following IQC request, sample qty following  SI 0.1% Standard
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
							
							   CASE 
        WHEN MQD.InspectionLevel = 'G1'
            AND MQD.QcInspectionItemName = N'Ngoại quan'
            AND MQD.QcInspectionGroupName LIKE N'%Vỏ nhôm%'
        THEN 'G2'
        ELSE MQD.InspectionLevel
    END AS InspectionLevel,
	
	                     --MQD.InspectionLevel,
							MQD.AQL,
							-- MQD.RequestSampleQty,
							CASE 
								WHEN MQD.QcInspectionItemCode IN (select QcInspectionItemCode FROM STB_QcInspectionItem where IsSI01Standard = 1) AND (@QcQty > 1 AND @QcQty < 50) THEN 2
								WHEN MQD.QcInspectionItemCode IN (select QcInspectionItemCode FROM STB_QcInspectionItem where IsSI01Standard = 1) AND (@QcQty > 51 AND @QcQty < 500) THEN 3
								WHEN MQD.QcInspectionItemCode IN (select QcInspectionItemCode FROM STB_QcInspectionItem where IsSI01Standard = 1) AND (@QcQty > 501 AND @QcQty < 35000) THEN 5
								WHEN MQD.QcInspectionItemCode IN (select QcInspectionItemCode FROM STB_QcInspectionItem where IsSI01Standard = 1) AND (@QcQty > 35001) THEN 8
								ELSE MQD.RequestSampleQty
							END AS RequestSampleQty,
							MQD.MaxAcceptDefectQty,				
							--MQD.SampleQty ,                -- 베트남의 경우는 SD는 측정수량이 20
							-- Mr.Duy thay đổi theo QC bắc giang để đến lúc chỉnh số lượng của ngoại quan
								case when MQD.SampleQty >0 then 
									(
										CASE 
											WHEN MQD.QcInspectionItemCode IN (select QcInspectionItemCode FROM STB_QcInspectionItem where IsSI01Standard = 1) AND (@QcQty > 1 AND @QcQty < 50) THEN 2
											WHEN MQD.QcInspectionItemCode IN (select QcInspectionItemCode FROM STB_QcInspectionItem where IsSI01Standard = 1) AND (@QcQty > 51 AND @QcQty < 500) THEN 3
											WHEN MQD.QcInspectionItemCode IN (select QcInspectionItemCode FROM STB_QcInspectionItem where IsSI01Standard = 1) AND (@QcQty > 501 AND @QcQty < 35000) THEN 5
											WHEN MQD.QcInspectionItemCode IN (select QcInspectionItemCode FROM STB_QcInspectionItem where IsSI01Standard = 1) AND (@QcQty > 35001) THEN 8
											ELSE MQD.SampleQty
										END 
									)
										
								else 
									case when MQD.QcInspectionItemCode ='IQC_GPD_21'
									then	@sumSampleQtyInspection
									else MQD.SampleQty
									end
								end as SampleQty,
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
							/*
							   CASE 
        WHEN MQD.InspectionLevel = 'G1'
            AND MQD.QcInspectionItemName = N'Ngoại quan'
            AND MQD.QcInspectionGroupName LIKE N'%Vỏ nhôm%'
        THEN 'GII'
        ELSE MQD.InspectionLevel
    END AS InspectionLevel,
	*/
	                       MQD.InspectionLevel,
							MQD.AQL,
							MQD.RequestSampleQty,
							MQD.MaxAcceptDefectQty,				
							--MQD.SampleQty ,                -- 베트남의 경우는 SD는 측정수량이 20
							-- Mr.Duy thay đổi theo QC bắc giang để đến lúc chỉnh số lượng của ngoại quan
								case when MQD.SampleQty >0 then 
										MQD.SampleQty
								else 
									case when MQD.QcInspectionItemCode ='IQC_GPD_21'
									then	@sumSampleQtyInspection
									else MQD.SampleQty
									end
								end as SampleQty,
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
					
					CASE 
                        WHEN MQD.InspectionLevel = 'G1'
                        AND MQD.QcInspectionItemName = N'Ngoại quan'
                        AND MQD.QcInspectionGroupName LIKE N'%Vỏ nhôm%'
                             THEN 'G2'
                             ELSE MQD.InspectionLevel
                    END AS InspectionLevel,
					
					--MQD.InspectionLevel,
					MQD.AQL,
					MQD.RequestSampleQty,
					MQD.MaxAcceptDefectQty,				
					CASE WHEN ISNULL(MQD.SampleQty, 0) > 0 THEN MQD.SampleQty ELSE  MQD.RequestSampleQty END  AS SampleQty,       --2019.03.28 kilee (대상샘플수량과 샘플수량 동일하게)
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
