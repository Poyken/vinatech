-- =============================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Create date: 2022-01-13
-- Browsable : true
-- Group : 품질관리
-- Description:	수입검사이력
-- exec usp_MaterialInspectionHist_get '','','VVT','VVT_F1','2026-01-01','2026-04-15','',''
-- =============================================
CREATE PROCEDURE [dbo].[usp_MaterialInspectionHist_get]
	@pProcessUserID     VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pCompanyCode VARCHAR(20),
	@pWorkCenterCode VARCHAR(20),
	@pFromDate          DATETIME,
	@pToDate			  DATETIME,
	@pMaterialQcNo     VARCHAR(20) = NULL,
	@pQcInspectionItemCode VARCHAR(20) = NULL
AS

BEGIN

   Declare @CompanyCode VARCHAR(20)  = CASE WHEN ISNULL(@pCompanyCode,'') = '' THEN '*' ELSE @pCompanyCode END
          ,@WorkCenterCode VARCHAR(20) = CASE WHEN ISNULL(@pWorkCenterCode,'') = '' THEN '*' ELSE @pWorkCenterCode END
   Declare @FromDate DATETIME     = @pFromDate
		  ,@ToDate DATETIME     = @pToDate
		  ,@MaterialQcNo VARCHAR(20) = CASE WHEN ISNULL(@pMaterialQcNo,'') = '' THEN '*' ELSE @pMaterialQcNo END
		  ,@QcInspectionItemCode VARCHAR(20) = CASE WHEN ISNULL(@pQcInspectionItemCode,'') = '' THEN '*' ELSE @pQcInspectionItemCode END
		  ,@MaterialWarehouseCode VARCHAR(20)

	SELECT @MaterialWarehouseCode = MaterialWarehouseCode
	  FROM STB_UserInfo
	 WHERE UserID = @pProcessUserID

	IF @WorkCenterCode = 'VNT_F2' AND ISNULL(@MaterialWarehouseCode, '') <> '' AND ISNULL(@MaterialWarehouseCode, '') <> 'W02' BEGIN
		SELECT MQI.BasicDate
			  ,MQI.MaterialCode
			  ,MM.MaterialName
			  ,MQI.MaterialQcNo
			  ,MQI.DecisionResult
			  ,MQI.MIIExtText01 AS InspWorkerCode
			  ,PWI.WorkerName AS inspWorkerName
			  ,MQD.QcInspectionItemName
			  ,ROW_NUMBER() OVER(PARTITION BY MQI.MaterialQcNo, MQD.QcInspectionItemName 
									 ORDER BY MQI.BasicDate, MQI.MaterialQcNo, MQD.QcInspectionItemName, MQSR.MaterialQcSampleNo ASC) AS MaterialQcSampleNo
			  ,MQSR.TestValue
			  ,MQI.DescText
			  ,MQI.IQCSampleLotList
		  FROM STB_MaterialQcInfo MQI with(nolock) 
		  LEFT OUTER JOIN STB_MaterialMaster MM with(nolock)
			ON MQI.MaterialCode = MM.MaterialCode
		  LEFT OUTER JOIN STB_ProdWorkerInfo PWI with(nolock)
			ON MQI.MIIExtText01 = PWI.WorkerCode
		  LEFT OUTER JOIN STB_MaterialQcDetail MQD with(nolock)
			ON MQI.MaterialQcNo = MQD.MaterialQcNo
		  LEFT OUTER JOIN STB_MaterialQcSampleResult MQSR	 with(nolock)
			ON MQSR.MaterialQcNo = MQD.MaterialQcNo		
		   AND MQSR.MaterialQcDetailNo = MQD.MaterialQcDetailNo
		 WHERE 1=1
		   AND MQI.InspectionDocType = 'IQC'
		   AND MQI.BasicDate BETWEEN @FromDate AND @ToDate
		   AND (@QcInspectionItemCode = '*' OR MQD.QcInspectionItemCode = @QcInspectionItemCode)
		   AND (@MaterialQcNo = '*' OR MQI.MaterialQcNo = @MaterialQcNo)
		   AND (@CompanyCode = '*' OR MQI.CompanyCode = @CompanyCode) 
		   AND (@WorkCenterCode = '*' OR MQI.WorkCenterCode = @WorkCenterCode)
		   AND MM.ProductGroupCode = 'CATALYST SUPPORT'
		 ORDER BY MQI.BasicDate, MQI.MaterialQcNo, MQD.QcInspectionItemName, MQSR.MaterialQcSampleNo
	END ELSE BEGIN
		SELECT MQI.BasicDate
			  ,MQI.MaterialCode
			  ,MM.MaterialName
			  ,MQI.MaterialQcNo
			  ,MQI.DecisionResult
			  ,MQI.MIIExtText01 AS InspWorkerCode
			  ,PWI.WorkerName AS inspWorkerName
			  ,MQD.QcInspectionItemName
			  ,ROW_NUMBER() OVER(PARTITION BY MQI.MaterialQcNo, MQD.QcInspectionItemName 
									 ORDER BY MQI.BasicDate, MQI.MaterialQcNo, MQD.QcInspectionItemName, MQSR.MaterialQcSampleNo ASC) AS MaterialQcSampleNo
			  ,MQSR.TestValue
			  ,MQI.DescText
			  ,MQI.IQCSampleLotList
			  ,MQD.LSL                        -- add by Mr.Tung on 2023-02-02
			  ,MQD.USL                        -- add by Mr.Tung on 2023-02-02
		  FROM STB_MaterialQcInfo MQI with(nolock) 
		  LEFT OUTER JOIN STB_MaterialMaster MM with(nolock)
			ON MQI.MaterialCode = MM.MaterialCode
		  LEFT OUTER JOIN STB_ProdWorkerInfo PWI with(nolock)
			ON MQI.MIIExtText01 = PWI.WorkerCode
		  LEFT OUTER JOIN STB_MaterialQcDetail MQD with(nolock)
			ON MQI.MaterialQcNo = MQD.MaterialQcNo
		  LEFT OUTER JOIN STB_MaterialQcSampleResult MQSR	 with(nolock)
			ON MQSR.MaterialQcNo = MQD.MaterialQcNo		
		   AND MQSR.MaterialQcDetailNo = MQD.MaterialQcDetailNo
		 WHERE 1=1
		   AND MQI.InspectionDocType = 'IQC'
		   AND MQI.BasicDate BETWEEN @FromDate AND @ToDate -- search day for request
		   AND (@QcInspectionItemCode = '*' OR MQD.QcInspectionItemCode = @QcInspectionItemCode)
		   AND (@MaterialQcNo = '*' OR MQI.MaterialQcNo = @MaterialQcNo)
		   AND (@CompanyCode = '*' OR MQI.CompanyCode = @CompanyCode) -- Mr.Trieu add search workcentercode
		   AND (@WorkCenterCode = '*' OR MQI.WorkCenterCode = @WorkCenterCode)
		   AND MM.ProductGroupCode <> 'CATALYST SUPPORT'
		 ORDER BY MQI.BasicDate, MQI.MaterialQcNo, MQD.QcInspectionItemName, MQSR.MaterialQcSampleNo
	END

END
