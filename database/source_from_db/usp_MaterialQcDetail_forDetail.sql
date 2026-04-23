-- =============================================
-- Author:		Mr.Manh
-- Create date: 2026-02-04
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[usp_MaterialQcDetail_forDetail]
	-- Add the parameters for the stored procedure here
				@pProcessUserID VARCHAR(20),
				@pProcessLanguage VARCHAR(20),
				@pMaterialQcNo VARCHAR(20) = Null 
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

