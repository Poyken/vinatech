-- =============================================
-- Author:		Mr.Manh
-- Create date: 2026-03-09
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[usp_QCInspectionStatisticsVVT_get]
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

	IF ISNULL(@pBarCode,'') = ''
	BEGIN
		;WITH getlistMaterialQcNo AS (
			SELECT
					MQI.MaterialQcNo,
					MQI.InspectionDocType,
					MQI.DecisionDateTime AS DecisionDate
			FROM
					STB_MaterialQcInfo MQI WITH(NOLOCK)
			WHERE 1=1
					AND (MQI.InspectionDocType = @InspectionDocType) 
					AND (@DecisionResult = '*' OR MQI.DecisionResult = @DecisionResult) 
					AND (@MaterialCode = '*' OR MQI.MaterialCode = @MaterialCode) 
					AND (MQI.DecisionDateTime IS NULL OR MQI.DecisionDateTime  BETWEEN @DecisionFromDate AND @DecisionToDate)       

					AND ((@CompanyCode = '*') OR (MQI.CompanyCode = @CompanyCode)) 
					AND MQI.WorkCenterCode in (@WorkCenterCode,'VVT_F2')
				--	AND (MQI.MaterialQcNo LIKE @BarCode 
				--	  OR  MQI.MaterialQcNo IN (SELECT LotNumber   FROM STB_SetInfo                       WHERE Barcode = @Barcode OR NewBarcode=@Barcode) 
				--	  OR  MQI.MaterialQcNo =  (SELECT NewBarcode FROM STB_LotChangeMaterialHistory WHERE OldBarcode = @Barcode ))   -- 2020.04.17  기종변경에 따른 수정
				--AND (MQI.MaterialQcNo IN (SELECT LotNumber   FROM STB_SetInfo WHERE IsNotWip = CONVERT(BIT, 0)) 
				--	OR MQI.MaterialQcNo IN (SELECT lotid FROM VVT_OQC_REFER where isSeparated = 1 AND CreatedLot = 1))   -- DinhManh update 2025-04-26 to search Separated Lot following QC request
			)
		,getStatistics AS (
			SELECT 	
				a.MaterialQcNo,
				SUM(RequestSampleQty) AS RequestSampleQty,
				SUM(SampleQty) AS SampleQty,
				SUM(PassedSampleQty) AS PassedSampleQty,
				SUM(DefectSampleQty) AS DefectSampleQty
				--SUM(SkipSampleQty) AS SkipSampleQty
			FROM getlistMaterialQcNo a WITH(NOLOCK)
			LEFT OUTER JOIN STB_MaterialQcDetail MQD WITH(NOLOCK) ON MQD.MaterialQcNo = a.MaterialQcNo
			GROUP BY a.MaterialQcNo
		)

		SELECT 
			gs.MaterialQcNo,
			--MQI.CompanyCode,
			--CI.CompanyName,
			MQI.WorkCenterCode,
			WCI.WorkCenterName,
			(CASE WHEN ISNULL(LCMH.NewBarcode,'') = '' THEN   MQI.MaterialCode  ELSE LCMH.AftMaterialCode END) AS MaterialCode, --update 2025-04-09
			(CASE WHEN ISNULL(LCMH.NewBarcode,'') = '' THEN   MM.MaterialName  
				ELSE (SELECT a1.MaterialName FROM STB_MaterialMaster a1 where a1.MaterialCode = LCMH.AftMaterialCode) END) AS MaterialName, -- update 2025-04-09
			MM.MaterialTypeCode,
			MT.BasicMaterialType,
			MT.MaterialTypeName,
			MM.ProductGroupCode,
			PG.ProductGroupName,
			MM.MaterialUnit,
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
			--MQI.PassedSampleQty,
			--MQI.DefectSampleQty,
			gs.RequestSampleQty,
			gs.SampleQty,
			gs.PassedSampleQty,
			gs.DefectSampleQty,
			DR.DecisionResultText,
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
		FROM getStatistics gs WITH (NOLOCK)
		LEFT OUTER JOIN STB_MaterialQcInfo MQI WITH(NOLOCK) ON MQI.MaterialQcNo = gs.MaterialQcNo
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

	END

	ELSE
	BEGIN
		;WITH getlistMaterialQcNo AS (
			SELECT
					MQI.MaterialQcNo,
					MQI.InspectionDocType,
					MQI.DecisionDateTime AS DecisionDate
			FROM
					STB_MaterialQcInfo MQI WITH(NOLOCK)
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
					OR MQI.MaterialQcNo IN (SELECT lotid FROM VVT_OQC_REFER where isSeparated = 1 AND CreatedLot = 1)) 
			)
		,getStatistics AS (
			SELECT 	
				a.MaterialQcNo,
				SUM(RequestSampleQty) AS RequestSampleQty,
				SUM(SampleQty) AS SampleQty,
				SUM(PassedSampleQty) AS PassedSampleQty,
				SUM(DefectSampleQty) AS DefectSampleQty
				--SUM(SkipSampleQty) AS SkipSampleQty
			FROM getlistMaterialQcNo a WITH(NOLOCK)
			LEFT OUTER JOIN STB_MaterialQcDetail MQD WITH(NOLOCK) ON MQD.MaterialQcNo = a.MaterialQcNo
			GROUP BY a.MaterialQcNo
		)

		SELECT 
			gs.MaterialQcNo,
			--MQI.CompanyCode,
			--CI.CompanyName,
			MQI.WorkCenterCode,
			WCI.WorkCenterName,
			(CASE WHEN ISNULL(LCMH.NewBarcode,'') = '' THEN   MQI.MaterialCode  ELSE LCMH.AftMaterialCode END) AS MaterialCode, --update 2025-04-09
			(CASE WHEN ISNULL(LCMH.NewBarcode,'') = '' THEN   MM.MaterialName  
				ELSE (SELECT a1.MaterialName FROM STB_MaterialMaster a1 where a1.MaterialCode = LCMH.AftMaterialCode) END) AS MaterialName, -- update 2025-04-09
			MM.MaterialTypeCode,
			MT.BasicMaterialType,
			MT.MaterialTypeName,
			MM.ProductGroupCode,
			PG.ProductGroupName,
			MM.MaterialUnit,
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
			--MQI.PassedSampleQty,
			--MQI.DefectSampleQty,
			gs.RequestSampleQty,
			gs.SampleQty,
			gs.PassedSampleQty,
			gs.DefectSampleQty,
			DR.DecisionResultText,
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
		FROM getStatistics gs WITH (NOLOCK)
		LEFT OUTER JOIN STB_MaterialQcInfo MQI WITH(NOLOCK) ON MQI.MaterialQcNo = gs.MaterialQcNo
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

	END



		--ELSE IF ISNULL(@pBarCode,'') <> '')
		--BEGIN
		--	SELECT
		--			MQI.MaterialQcNo AS OldMaterialQcNo,
		--			MQI.MaterialQcNo,
		--			MQI.InspectionDocType,
		--			MQI.DecisionDateTime AS DecisionDate
		--	FROM
		--			STB_MaterialQcInfo MQI WITH(NOLOCK)
		--	WHERE 1=1
		--			AND (MQI.InspectionDocType = @InspectionDocType) 
		--			AND (@DecisionResult = '*' OR MQI.DecisionResult = @DecisionResult) 
		--			AND (@MaterialCode = '*' OR MQI.MaterialCode = @MaterialCode)
		--			AND ((@CompanyCode = '*') OR (MQI.CompanyCode = @CompanyCode))  
		--			AND MQI.WorkCenterCode in (@WorkCenterCode,'VVT_F2')
		--			AND (MQI.MaterialQcNo LIKE @BarCode 
		--			  OR  MQI.MaterialQcNo IN (SELECT LotNumber   FROM STB_SetInfo                       WHERE Barcode = @Barcode OR NewBarcode=@Barcode) 
		--			  OR  MQI.MaterialQcNo =  (SELECT NewBarcode FROM STB_LotChangeMaterialHistory WHERE OldBarcode = @Barcode ))   -- 2020.04.17  기종변경에 따른 수정
		--			AND (MQI.MaterialQcNo IN (SELECT LotNumber   FROM STB_SetInfo WHERE IsNotWip = CONVERT(BIT, 0)) 
		--			OR MQI.MaterialQcNo IN (SELECT lotid FROM VVT_OQC_REFER where isSeparated = 1 AND CreatedLot = 1)) 
		--	END
		--ELSE IF (@InspectionDocType = 'IQC' and ISNULL(@pBarCode,'') = '')
		--BEGIN
		--	SELECT
		--			MQI.MaterialQcNo AS OldMaterialQcNo,
		--			MQI.MaterialQcNo,
		--			MQI.InspectionDocType,
		--			MQI.DecisionDateTime AS DecisionDate
		--FROM
		--		STB_MaterialQcInfo MQI WITH(NOLOCK)
		--WHERE 1=1
		--		AND (MQI.InspectionDocType = @InspectionDocType) 
		--		AND (@DecisionResult = '*' OR MQI.DecisionResult = @DecisionResult) 
		--		AND (@MaterialCode = '*' OR MQI.MaterialCode = @MaterialCode) 
		--		AND (MQI.DecisionDateTime IS NULL OR MQI.DecisionDateTime  BETWEEN @DecisionFromDate AND @DecisionToDate) 
		--		AND ((@CompanyCode = '*') OR (MQI.CompanyCode = @CompanyCode)) 
		--		AND MQI.WorkCenterCode in (@WorkCenterCode,'VVT_F2')
		--		--AND (MQI.MaterialQcNo LIKE @BarCode 
		--		--  OR  MQI.MaterialQcNo IN (SELECT LotNumber   FROM STB_SetInfo                       WHERE Barcode = @Barcode OR NewBarcode=@Barcode) 
		--		--  OR  MQI.MaterialQcNo =  (SELECT NewBarcode FROM STB_LotChangeMaterialHistory WHERE OldBarcode = @Barcode ))
		--END

		--ELSE IF (@InspectionDocType = 'IQC' and ISNULL(@pBarCode,'') <> '')
		--BEGIN
		--	SELECT
		--			MQI.MaterialQcNo AS OldMaterialQcNo,
		--			MQI.MaterialQcNo,
		--			MQI.InspectionDocType,
		--			MQI.DecisionDateTime AS DecisionDate
		--	FROM
		--			STB_MaterialQcInfo MQI WITH(NOLOCK)
		--	WHERE 1=1
		--			AND (MQI.InspectionDocType = @InspectionDocType) 
		--			AND (@DecisionResult = '*' OR MQI.DecisionResult = @DecisionResult) 
		--			AND (@MaterialCode = '*' OR MQI.MaterialCode = @MaterialCode) 
		--			AND ((@CompanyCode = '*') OR (MQI.CompanyCode = @CompanyCode))  
		--			AND MQI.WorkCenterCode in (@WorkCenterCode,'VVT_F2')
		--			AND (MQI.MaterialQcNo LIKE @BarCode 
		--			  OR  MQI.MaterialQcNo IN (SELECT LotNumber   FROM STB_SetInfo                       WHERE Barcode = @Barcode OR NewBarcode=@Barcode) 
		--			  OR  MQI.MaterialQcNo =  (SELECT NewBarcode FROM STB_LotChangeMaterialHistory WHERE OldBarcode = @Barcode ))   -- 2020.04.17  기종변경에 따른 수정
		--END



END
