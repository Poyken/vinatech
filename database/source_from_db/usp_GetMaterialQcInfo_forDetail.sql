-- =============================================
-- Author:		DinhManh
-- Create date: 2026-02-04
-- Description:	<Description,,>
-- =============================================	-- exec usp_GetMaterialQcInfo_forDetail 'DinhManh', 'vi', '', 'None', '', 'VVT', '', 'OQC', '2026-01-01', '2026-02-06'
CREATE PROCEDURE [dbo].[usp_GetMaterialQcInfo_forDetail]
	-- Add the parameters for the stored procedure here
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
    @pMaterialCode VARCHAR(50) = NULL,
	@pDecisionResult VARCHAR(10) = NULL,
	@pBarCode VARCHAR(20) = NULL,
	@pCompanyCode VARCHAR(20) = NULL,
	@pProdInspWorkerCode VARCHAR(20) = NULL ,
	@pInspectionDocType VARCHAR(20) = NULL,
	@pDecisionFromDate DATE = null,
	@pDecisionToDate DATE = null
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	DECLARE @MaterialCode VARCHAR(50)  = CASE WHEN ISNULL(@pMaterialCode,'') = ''   THEN '*'          ELSE @pMaterialCode   END

	DECLARE @DecisionResult VARCHAR(10) = CASE WHEN ISNULL(@pDecisionResult,'') = '' THEN '*'           ELSE @pDecisionResult END 
	DECLARE @BarCode        VARCHAR(20) = CASE WHEN ISNULL(@pBarCode,'') = ''        THEN '%'           ELSE @pBarCode        END 
    DECLARE @CompanyCode VARCHAR(20) = CASE WHEN ISNULL(@pCompanyCode,'') = '' THEN '*'            ELSE @pCompanyCode END  
	DECLARE @ProdInspWorkerCode VARCHAR(20) = CASE WHEN ISNULL(@pProdInspWorkerCode,'') = '' THEN '*' ELSE @pProdInspWorkerCode END
	DECLARE @DecisionFromDate         VARCHAR(19) = CONVERT(VARCHAR(10), @pDecisionFromDate, 121) + ' 00:00:00'
	DECLARE @DecisionToDate            VARCHAR(19) = CONVERT(VARCHAR(10), DATEADD(DAY, 1, CONVERT(smalldatetime, @pDecisionToDate)), 121) + ' 00:00:00'
	DECLARE @InspectionDocType VARCHAR(20) = CASE WHEN ISNULL(@pInspectionDocType,'') = '' THEN '*'           ELSE @pInspectionDocType END 
	Declare @WorkCenterCode VARCHAR(20)

	SELECT @WorkCenterCode = WorkCenterCode 
	  FROM STB_UserInfo
	 WHERE UserID = @pProcessUserID

	 IF (@CompanyCode = 'VVT' and @WorkCenterCode <>'VVT_F3')
	 BEGIN
		set @WorkCenterCode='VVT_F1'
	END

	if(@InspectionDocType = 'OQC' and ISNULL(@pBarCode,'') = '')
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
			MQI.InspectionDocType,
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
			AND (MQI.InspectionDocType = @InspectionDocType) 
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
	ELSE IF (@InspectionDocType = 'OQC' and ISNULL(@pBarCode,'') <> '')
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
				MQI.InspectionDocType,
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
				AND (MQI.InspectionDocType = @InspectionDocType) 
				AND (@DecisionResult = '*' OR MQI.DecisionResult = @DecisionResult) 
				AND (@MaterialCode = '*' OR MQI.MaterialCode = @MaterialCode) 

				AND ((@CompanyCode = '*') OR (MQI.CompanyCode = @CompanyCode))  
				AND MQI.WorkCenterCode in (@WorkCenterCode,'VVT_F2')
				AND (MQI.MaterialQcNo LIKE @BarCode 
				  OR  MQI.MaterialQcNo IN (SELECT LotNumber   FROM STB_SetInfo                       WHERE Barcode = @Barcode OR NewBarcode=@Barcode) 
				  OR  MQI.MaterialQcNo =  (SELECT NewBarcode FROM STB_LotChangeMaterialHistory WHERE OldBarcode = @Barcode ))   -- 2020.04.17  기종변경에 따른 수정
			AND (MQI.MaterialQcNo IN (SELECT LotNumber   FROM STB_SetInfo WHERE IsNotWip = CONVERT(BIT, 0)) 
				OR MQI.MaterialQcNo IN (SELECT lotid FROM VVT_OQC_REFER where isSeparated = 1 AND CreatedLot = 1))   -- DinhManh update 2025-04-26 to search Separated Lot following QC request
		END
	ELSE IF (@InspectionDocType = 'IQC' and ISNULL(@pBarCode,'') = '')
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
			MQI.InspectionDocType,
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
			AND (MQI.InspectionDocType = @InspectionDocType) 
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
			  OR  MQI.MaterialQcNo =  (SELECT NewBarcode FROM STB_LotChangeMaterialHistory WHERE OldBarcode = @Barcode ))
	END

	ELSE IF (@InspectionDocType = 'IQC' and ISNULL(@pBarCode,'') <> '')
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
				MQI.InspectionDocType,
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
				AND (MQI.InspectionDocType = @InspectionDocType) 
				AND (@DecisionResult = '*' OR MQI.DecisionResult = @DecisionResult) 
				AND (@MaterialCode = '*' OR MQI.MaterialCode = @MaterialCode) 

				AND ((@CompanyCode = '*') OR (MQI.CompanyCode = @CompanyCode))  
				AND MQI.WorkCenterCode in (@WorkCenterCode,'VVT_F2')
				AND (MQI.MaterialQcNo LIKE @BarCode 
				  OR  MQI.MaterialQcNo IN (SELECT LotNumber   FROM STB_SetInfo                       WHERE Barcode = @Barcode OR NewBarcode=@Barcode) 
				  OR  MQI.MaterialQcNo =  (SELECT NewBarcode FROM STB_LotChangeMaterialHistory WHERE OldBarcode = @Barcode ))   -- 2020.04.17  기종변경에 따른 수정
	END

END
