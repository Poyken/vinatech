-- =============================================
-- Author:	    Jeon Gyeong Ho(khjun@awoo.co.kr)
-- Create date: 2018-08-30
-- Browsable : true
-- Group : 품질관리 > 제품검사(Lot No)
-- Description:	출하검사 관리 화면을 조회합니다.
-- Modified:  [C530] 시료별 제품검사
-- 2019.12.25 사업장코드 추가
-- 제품 검사자 코드도 검색 조건에 반영되도록 수정. 이미정 차장님 요청 By Jackaroe 2020.05.18 #20200518
-- 제품 검사자 코드와 제품검사자명 컬럼 추가 By Jackaroe 2020.05.18 #20200518
-- 2020.09.14 납품일자가 아닌 심사(합격)일자로 변경 

-- TEST : exec usp_GetMaterialOQcInfo @pProcessUserID='kilee',@pProcessLanguage='Korean',@pMaterialCode=default,@pFromDate='2020-09-11',@pToDate='2020-09-11',@pDecisionResult=default,@pBarCode='19072900001'
--  exec usp_GetMaterialOQcInfo @pProcessUserID='anhduy157',@pProcessLanguage='vi',@pMaterialCode='',@pDecisionFromDate='2025-01-01',@pDecisionToDate='2025-01-12',@pDecisionResult='',@pBarCode=''
-- =============================================
CREATE PROCEDURE [dbo].[usp_GetMaterialOQcInfo]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
    @pMaterialCode VARCHAR(50) = NULL,
	--@pFromDate DATE = NULL,
	--@pToDate DATE = NULL,
	@pDecisionResult VARCHAR(10) = NULL,
	@pBarCode VARCHAR(20) = NULL,
	@pCompanyCode VARCHAR(20) = NULL,
	@pProdInspWorkerCode VARCHAR(20) = NULL ,

	@pDecisionFromDate DATE = null,
	@pDecisionToDate DATE = null


AS
BEGIN
	SET NOCOUNT ON;
	
	DECLARE @MaterialCode VARCHAR(50)  = CASE WHEN ISNULL(@pMaterialCode,'') = ''   THEN '*'          ELSE @pMaterialCode   END
	--DECLARE @FromDate DATE                = CASE WHEN @pFromDate IS NULL              THEN GETDATE() ELSE @pFromDate       END
	--DECLARE @ToDate DATE                   = CASE WHEN @pToDate IS NULL                 THEN GETDATE() ELSE @pToDate          END

	DECLARE @DecisionResult VARCHAR(10) = CASE WHEN ISNULL(@pDecisionResult,'') = '' THEN '*'           ELSE @pDecisionResult END 
	DECLARE @BarCode        VARCHAR(20) = CASE WHEN ISNULL(@pBarCode,'') = ''        THEN '%'           ELSE @pBarCode        END 
    DECLARE @CompanyCode VARCHAR(20) = CASE WHEN ISNULL(@pCompanyCode,'') = '' THEN '*'            ELSE @pCompanyCode END  --2019.12.25 추가
	DECLARE @ProdInspWorkerCode VARCHAR(20) = CASE WHEN ISNULL(@pProdInspWorkerCode,'') = '' THEN '*' ELSE @pProdInspWorkerCode END

	--DECLARE @DecisionFromDate DATE = CASE WHEN @pDecisionFromDate IS NULL THEN GETDATE()-10 ELSE @pDecisionFromDate END   -- 판정일시 조건추가 (이미정, 2020-09-14)
	--DECLARE @DecisionToDate    DATE = CASE WHEN @pDecisionToDate     IS NULL THEN GETDATE() ELSE @pDecisionToDate    END
	
	--DECLARE @DecisionFromDate         VARCHAR(19) = CONVERT(VARCHAR(10), @pDecisionFromDate, 121) + ' 08:30:00'                                                            -- SELECT  CONVERT(VARCHAR(10), '2019-09-16', 121) + ' 08:30:00' 
	--DECLARE @DecisionToDate            VARCHAR(19) = CONVERT(VARCHAR(10), DATEADD(DAY, 1, CONVERT(smalldatetime, @pDecisionToDate)), 121) + ' 23:59:59'     -- 다음날 SELECT CONVERT(VARCHAR(10), DATEADD(DAY, 1, CONVERT(smalldatetime, '2019-09-17 00:01:09')), 121) + ' 08:30:00'    
	-- 이걸 왜 23시까지로 해놨을까... 

	-- 판정일시 기준을 당일 24시간 기준으로 변경 김소연님 요청 2021.08.01 by Jackaroe
	DECLARE @DecisionFromDate         VARCHAR(19) = CONVERT(VARCHAR(10), @pDecisionFromDate, 121) + ' 00:00:00'
	DECLARE @DecisionToDate            VARCHAR(19) = CONVERT(VARCHAR(10), DATEADD(DAY, 1, CONVERT(smalldatetime, @pDecisionToDate)), 121) + ' 00:00:00'

	-- 고객심사 대비 작업장 추가
	Declare @WorkCenterCode VARCHAR(20)

	SELECT @WorkCenterCode = WorkCenterCode 
	  FROM STB_UserInfo
	 WHERE UserID = @pProcessUserID

	 -- DinhManh update 2025-04-08
	 --IF (@BarCode <> '%' AND EXISTS (SELECT 1 from STB_LotChangeMaterialHistory LCMH where LCMH.OldBarCode = @Barcode)) 
		-- BEGIN 
		--	 SELECT @BarCode = NewBarcode
		--	  FROM STB_LotChangeMaterialHistory 
		--	 WHERE OldBarcode = @pBarcode

		--	--raiserror (@Barcode,16,1)
		--	--return
		-- END


	--raiserror (@Barcode,16,1)
	--return

	IF (@CompanyCode = 'VVT' and @WorkCenterCode <>'VVT_F3')
	 BEGIN
		--만약 베트남법인을 선택하면, @WorkCenterCode를 VVT_F1으로 변경해준다
		--본사에서 베트남법인의 내역을 조회할 경우 기존 로직으로는 조회가 되지 않음.
		-- nếu là tài khoản bắc ninh và bắc giang sẽ tìm thấy dữ liệu của nhau
		set @WorkCenterCode='VVT_F1'
		-- When the headquarters inspects the products of the Vietnamese corporation, only VVT is parameter on the search condition, so add WorkCenterCode of the headquarters. 2025.01.20 by Jackaroe
		/*
		if @WorkCenterCode IN ('VVT_F1', 'VVT_F2', 'VNT_F1', 'VNT_F4') BEGIN
			set @WorkCenterCode='VVT_F1,VVT_F2'
		END else BEGIN
			set @WorkCenterCode='VVT_F3'
		END
		*/
	END
	
	--raiserror (@WorkCenterCode,16,1)
	-- DinhManh update 2025-04-09 following QC Request, for MaterialCode, MaterialName after change Lot
	if(@WorkCenterCode ='VVT_F1')
	Begin
	SELECT
			MQI.MaterialQcNo AS OldMaterialQcNo,
			MQI.MaterialQcNo,
			DR.DecisionResultText,
			MQI.CompanyCode,
			CI.CompanyName,
			MQI.WorkCenterCode,
			WCI.WorkCenterName,
			--MQI.MaterialCode,
			(CASE WHEN ISNULL(LCMH.NewBarcode,'') = '' THEN   MQI.MaterialCode  ELSE LCMH.AftMaterialCode END) AS MaterialCode, --update 2025-04-09
			--MM.MaterialName,
			(CASE WHEN ISNULL(LCMH.NewBarcode,'') = '' THEN   MM.MaterialName  
				ELSE (SELECT a1.MaterialName FROM STB_MaterialMaster a1 where a1.MaterialCode = LCMH.AftMaterialCode) END) AS MaterialName, -- update 2025-04-09
			MM.MaterialTypeCode,
			MT.BasicMaterialType,
			MT.MaterialTypeName,
			MM.ProductGroupCode,
			PG.ProductGroupName,
			MM.MaterialUnit,
			--MM.MaterialSpec,
			(CASE WHEN ISNULL(LCMH.NewBarcode,'') = '' THEN   MM.MaterialSpec  
				ELSE (SELECT a2.MaterialSpec FROM STB_MaterialMaster a2 where a2.MaterialCode = LCMH.AftMaterialCode) END) AS MaterialSpec, --update 2025-04-09
			MM.MaterialSource,
			MM.BeforeMaterialCode,
			MQI.QcQty,
			MQI.InspectionType,
			MQI.TargetSampleQty,
			MQI.ActualSampleQty,
			MQI.DestoryInspectionQty,
			MQI.ProcessQty,
			MQI.MaxAcceptDefectQty,
			MQI.PassedSampleQty,
			MQI.DefectSampleQty,
			MQI.DecisionResult,
			MQI.DecisionDateTime,
			MQI.DecisionUserID,
			MQI.SpecialAcceptDesc,
			MQI.DescText,
			MQI.QcMarking,
			MQI.CapDungLuong,  -- thêm cấp dung lượng 
			MQI.VendorQcReport,
			MQI.VendorLotNo,
			MQI.MIIExtText01,
			MQI.MIIExtText02,
			MQI.MIIExtText03,
			MQI.MIIExtText04,
			MQI.MIIExtText05,
			MQI.CreateDateTime,
			MQI.CreateUserID,
			MQI.ChangeDateTime,
			MQI.ChangeUserID,
			--MQI.BasicDate,
			MQI.DecisionDateTime AS DecisionDate,          --2020.09.14 
			PWI.WorkerName               --#2020.05.18
	FROM
			STB_MaterialQcInfo MQI WITH(NOLOCK)
			LEFT OUTER JOIN STB_CompanyInfo CI WITH(NOLOCK)				ON MQI.CompanyCode = CI.CompanyCode
			LEFT OUTER JOIN STB_WorkCenterInfo WCI WITH(NOLOCK)		ON MQI.WorkCenterCode = WCI.WorkCenterCode
			LEFT OUTER JOIN STB_MaterialDocDetail MDD WITH(NOLOCK)	ON MDD.MaterialIqcNo = MQI.MaterialQcNo
			LEFT OUTER JOIN STB_MaterialDocInfo MDI WITH(NOLOCK)		ON MDI.MaterialDocNo = MDD.MaterialDocNo
			LEFT OUTER JOIN STB_MaterialWarehouse MW WITH(NOLOCK)	ON MDI.TargetMaterialWarehouseCode = MW.MaterialWarehouseCode
			LEFT OUTER JOIN STB_MaterialMaster MM WITH(NOLOCK)		ON MQI.MaterialCode = MM.MaterialCode
			LEFT OUTER JOIN STB_CustomerInfo C WITH(NOLOCK)				ON MDI.SourceCustomerCode = C.CustomerCode
			LEFT OUTER JOIN STB_MaterialType MT WITH(NOLOCK)			ON MM.MaterialTypeCode = MT.MaterialTypeCode
			LEFT OUTER JOIN STB_ProductGroup PG WITH(NOLOCK)			ON MM.ProductGroupCode = PG.ProductGroupCode
			LEFT OUTER JOIN VW_DecisionResult DR                    			ON DR.DecisionResult = MQI.DecisionResult
			LEFT OUTER JOIN STB_ProdWorkerInfo PWI                            ON PWI.WorkerCode = MQI.MIIExtText01                    --#2020.05.18

			LEFT OUTER JOIN STB_LotChangeMaterialHistory LCMH WITH(NOLOCK)		ON MQI.MaterialQcNo = LCMH.OldBarcode  -- update 2025-04-09
	   --   LEFT OUTER JOIN STB_MaterialVendorMapping MVM WITH(NOLOCK) ON MVM.MaterialCode = MQI.MaterialCode AND MVM.CustomerCode = MDI.SourceCustomerCode
	WHERE 1=1
			AND (MQI.InspectionDocType = 'OQC') 
			AND (@DecisionResult = '*' OR MQI.DecisionResult = @DecisionResult) 
			AND (@MaterialCode = '*' OR MQI.MaterialCode = @MaterialCode) 
		--  AND (MQI.BasicDate BETWEEN @FromDate AND @ToDate)			                                                                             -- 기존소스백업 From~To (2020.09.14)
			AND (MQI.DecisionDateTime IS NULL OR MQI.DecisionDateTime  BETWEEN @DecisionFromDate AND @DecisionToDate)        -- 판정일시로 변경 (이미정, 2020.09.14)	 

			AND ((@CompanyCode = '*') OR (MQI.CompanyCode = @CompanyCode))                                                                                -- CompanyCode 추가 (2019.12.25)
			--AND MQI.WorkCenterCode = @WorkCenterCode -- 작업자의 작업장을 따라가도록 수정 2022.11.21 By Jackaroe
			--AND MQI.WorkCenterCode in (SELECT Item FROM dbo.fnSplitToTable(',',@WorkCenterCode)) -- Mr.Duy chia nhà máy bắc ninh , bắc giang và hà nam ra riêng
			AND MQI.WorkCenterCode in (@WorkCenterCode,'VVT_F2')
		 -- AND (MQI.MaterialQcNo LIKE @BarCode OR MQI.MaterialQcNo IN (SELECT LotNumber FROM STB_SetInfo WHERE Barcode = @Barcode))   -- 대표Lot로 묶인 제품검사 Lot의 경우 내부 Lot로도 대표 Lot를 조회할 수 있도록 조회조건 수정. 품질부문. 2019.10.28. By Jackaroe (원본백업)
			AND (MQI.MaterialQcNo LIKE @BarCode 
			  OR  MQI.MaterialQcNo IN (SELECT LotNumber   FROM STB_SetInfo                       WHERE Barcode = @Barcode OR NewBarcode=@Barcode) 
			  OR  MQI.MaterialQcNo =  (SELECT NewBarcode FROM STB_LotChangeMaterialHistory WHERE OldBarcode = @Barcode ))   -- 2020.04.17  기종변경에 따른 수정
		--AND (@ProdInspWorkerCode = '*' OR MQI.MIIExtText01 = @ProdInspWorkerCode) -- 일단 보류 작업자의 작업방식을 고려하여 수정할 필요가 있음. 2020.05.18 By Jackaroe
		--AND MQI.MaterialQcNo Not In ('VJLU253R850601', 'VJLU183R850609', 'VJLU153R850602', 'VJLU183R850612', 'VJMJ013R850602', 'VJLU113R850606', 'VJLU153R850603')  --22. 01. 20 삼성 오딧 관련 추가. 22. 01. 24일 이후 삭제 예정
		AND (MQI.MaterialQcNo IN (SELECT LotNumber   FROM STB_SetInfo WHERE IsNotWip = CONVERT(BIT, 0)) 
			OR MQI.MaterialQcNo IN (SELECT lotid FROM VVT_OQC_REFER where isSeparated = 1 AND CreatedLot = 1))   -- DinhManh update 2025-04-26 to search Separated Lot following QC request
	END
	ELSE
	BEGIN
		SELECT
			MQI.MaterialQcNo AS OldMaterialQcNo,
			MQI.MaterialQcNo,
			DR.DecisionResultText,
			MQI.CompanyCode,
			CI.CompanyName,
			MQI.WorkCenterCode,
			WCI.WorkCenterName,
			--MQI.MaterialCode,
			(CASE WHEN ISNULL(LCMH.NewBarcode,'') = '' THEN   MQI.MaterialCode  ELSE LCMH.AftMaterialCode END) AS MaterialCode, --update 2025-04-09
			--MM.MaterialName,
			(CASE WHEN ISNULL(LCMH.NewBarcode,'') = '' THEN   MM.MaterialName  
				ELSE (SELECT a1.MaterialName FROM STB_MaterialMaster a1 where a1.MaterialCode = LCMH.AftMaterialCode) END) AS MaterialName, -- update 2025-04-09
			Mark.MarkingName as MarkingLetter,				--update 2025-07-31 for Ha Nam factory
			MM.MaterialTypeCode,
			MT.BasicMaterialType,
			MT.MaterialTypeName,
			MM.ProductGroupCode,
			PG.ProductGroupName,
			MM.MaterialUnit,
			--MM.MaterialSpec,
			(CASE WHEN ISNULL(LCMH.NewBarcode,'') = '' THEN   MM.MaterialSpec  
				ELSE (SELECT a2.MaterialSpec FROM STB_MaterialMaster a2 where a2.MaterialCode = LCMH.AftMaterialCode) END) AS MaterialSpec, --update 2025-04-09
			MM.MaterialSource,
			MM.BeforeMaterialCode,
			MQI.QcQty,
			MQI.InspectionType,
			MQI.TargetSampleQty,
			MQI.ActualSampleQty,
			MQI.DestoryInspectionQty,
			MQI.ProcessQty,
			MQI.MaxAcceptDefectQty,
			MQI.PassedSampleQty,
			MQI.DefectSampleQty,
			MQI.DecisionResult,
			MQI.DecisionDateTime,
			MQI.DecisionUserID,
			MQI.SpecialAcceptDesc,
			MQI.DescText,
			MQI.VendorQcReport,
			MQI.VendorLotNo,
			MQI.MIIExtText01,
			MQI.MIIExtText02,
			MQI.MIIExtText03,
			MQI.MIIExtText04,
			MQI.MIIExtText05,
			MQI.CreateDateTime,
			MQI.CreateUserID,
			MQI.ChangeDateTime,
			MQI.ChangeUserID,
			--MQI.BasicDate,
			MQI.DecisionDateTime AS DecisionDate,          --2020.09.14 
			PWI.WorkerName               --#2020.05.18
	FROM
			STB_MaterialQcInfo MQI WITH(NOLOCK)
			LEFT OUTER JOIN STB_CompanyInfo CI WITH(NOLOCK)				ON MQI.CompanyCode = CI.CompanyCode
			LEFT OUTER JOIN STB_WorkCenterInfo WCI WITH(NOLOCK)		ON MQI.WorkCenterCode = WCI.WorkCenterCode
			LEFT OUTER JOIN STB_MaterialDocDetail MDD WITH(NOLOCK)	ON MDD.MaterialIqcNo = MQI.MaterialQcNo
			LEFT OUTER JOIN STB_MaterialDocInfo MDI WITH(NOLOCK)		ON MDI.MaterialDocNo = MDD.MaterialDocNo
			LEFT OUTER JOIN STB_MaterialWarehouse MW WITH(NOLOCK)	ON MDI.TargetMaterialWarehouseCode = MW.MaterialWarehouseCode
			LEFT OUTER JOIN STB_MaterialMaster MM WITH(NOLOCK)		ON MQI.MaterialCode = MM.MaterialCode
			LEFT OUTER JOIN STB_CustomerInfo C WITH(NOLOCK)				ON MDI.SourceCustomerCode = C.CustomerCode
			LEFT OUTER JOIN STB_MaterialType MT WITH(NOLOCK)			ON MM.MaterialTypeCode = MT.MaterialTypeCode
			LEFT OUTER JOIN STB_ProductGroup PG WITH(NOLOCK)			ON MM.ProductGroupCode = PG.ProductGroupCode
			LEFT OUTER JOIN VW_DecisionResult DR                    			ON DR.DecisionResult = MQI.DecisionResult
			LEFT OUTER JOIN STB_ProdWorkerInfo PWI                            ON PWI.WorkerCode = MQI.MIIExtText01                    --#2020.05.18

			LEFT OUTER JOIN STB_LotChangeMaterialHistory LCMH WITH(NOLOCK)		ON MQI.MaterialQcNo = LCMH.OldBarcode  -- update 2025-04-09
	   --   LEFT OUTER JOIN STB_MaterialVendorMapping MVM WITH(NOLOCK) ON MVM.MaterialCode = MQI.MaterialCode AND MVM.CustomerCode = MDI.SourceCustomerCode
			LEFT OUTER JOIN STB_CreateMarkingLetterAndQtyForBarcode Mark WITH(NOLOCK) ON MQI.MaterialQcNo = Mark.Barcode
	WHERE 1=1
			AND (MQI.InspectionDocType = 'OQC') 
			AND (@DecisionResult = '*' OR MQI.DecisionResult = @DecisionResult) 
			AND (@MaterialCode = '*' OR MQI.MaterialCode = @MaterialCode) 
		--  AND (MQI.BasicDate BETWEEN @FromDate AND @ToDate)			                                                                             -- 기존소스백업 From~To (2020.09.14)
			AND (MQI.DecisionDateTime IS NULL OR MQI.DecisionDateTime  BETWEEN @DecisionFromDate AND @DecisionToDate)        -- 판정일시로 변경 (이미정, 2020.09.14)	 

			AND ((@CompanyCode = '*') OR (MQI.CompanyCode = @CompanyCode))                                                                                -- CompanyCode 추가 (2019.12.25)
			--AND MQI.WorkCenterCode = @WorkCenterCode -- 작업자의 작업장을 따라가도록 수정 2022.11.21 By Jackaroe
			--AND MQI.WorkCenterCode in (SELECT Item FROM dbo.fnSplitToTable(',',@WorkCenterCode)) -- Mr.Duy chia nhà máy bắc ninh , bắc giang và hà nam ra riêng
			AND MQI.WorkCenterCode in (@WorkCenterCode)
		 -- AND (MQI.MaterialQcNo LIKE @BarCode OR MQI.MaterialQcNo IN (SELECT LotNumber FROM STB_SetInfo WHERE Barcode = @Barcode))   -- 대표Lot로 묶인 제품검사 Lot의 경우 내부 Lot로도 대표 Lot를 조회할 수 있도록 조회조건 수정. 품질부문. 2019.10.28. By Jackaroe (원본백업)
			AND (MQI.MaterialQcNo LIKE @BarCode 
			  OR  MQI.MaterialQcNo IN (SELECT LotNumber   FROM STB_SetInfo                       WHERE Barcode = @Barcode) 
			  OR  MQI.MaterialQcNo =  (SELECT NewBarcode FROM STB_LotChangeMaterialHistory WHERE OldBarcode = @Barcode ))   -- 2020.04.17  기종변경에 따른 수정
		--AND (@ProdInspWorkerCode = '*' OR MQI.MIIExtText01 = @ProdInspWorkerCode) -- 일단 보류 작업자의 작업방식을 고려하여 수정할 필요가 있음. 2020.05.18 By Jackaroe
		--AND MQI.MaterialQcNo Not In ('VJLU253R850601', 'VJLU183R850609', 'VJLU153R850602', 'VJLU183R850612', 'VJMJ013R850602', 'VJLU113R850606', 'VJLU153R850603')  --22. 01. 20 삼성 오딧 관련 추가. 22. 01. 24일 이후 삭제 예정
		AND MQI.MaterialQcNo IN (SELECT LotNumber   FROM STB_SetInfo WHERE IsNotWip = CONVERT(BIT, 0)) 

	end	
END
