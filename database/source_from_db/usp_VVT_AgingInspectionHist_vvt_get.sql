-- =============================================
-- Author: Mr.Tung
-- Create date: 2021-04-10
-- Browsable : true
-- =============================================


CREATE PROCEDURE [dbo].[usp_VVT_AgingInspectionHist_vvt_get]
	@pProcessUserID     VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pFromDate          DATETIME,
	@pToDate			  DATETIME,
	@pMaterialQcNo     VARCHAR(20) = NULL,
	@pQcInspectionItemCode VARCHAR(20) = NULL,
	@pBarcode			  VARCHAR(20) = NULL,
	@pCompanyCode    VARCHAR(20) = NULL,                                          
	@pSizeCode           VARCHAR(20) = NULL                                       
AS
BEGIN

   Declare @CompanyCode        VARCHAR(20)  = CASE WHEN ISNULL(@pCompanyCode,'') = '' THEN '*' ELSE @pCompanyCode END
   Declare @FromDate               DATETIME     = @pFromDate
		     ,@ToDate                   DATETIME     = @pToDate
		     ,@MaterialQcNo           VARCHAR(20) = @pMaterialQcNo 
		     ,@QcInspectionItemCode VARCHAR(20) = @pQcInspectionItemCode
		     ,@Barcode				    VARCHAR(20) = @pBarcode
		     ,@SizeCode				    VARCHAR(20) = CASE WHEN ISNULL(@pSizeCode, '') = '' THEN '%' ELSE @pSizeCode END
	
	DECLARE @CharFOQC VARCHAR(1)='A';

	IF @Barcode IS NOT NULL and @Barcode<>''
	BEGIN
		SELECT @MaterialQcNo =  @CharFOQC + @Barcode
	END

	SELECT MQI.BasicDate
		  ,MQI.InspectionDocType
		  ,lcmh.BefMaterialCode as oldMaterialCode
		  ,MQI.MaterialCode
		  ,MaterialName as oldModelName
		  ,MBI.ModelName
		  ,(case when MBI.ModelName is null or MBI.ModelName='' then '' else 
					SUBSTRING(
					MBI.ModelName, 
					8, 
					IIF(
					CHARINDEX('(', MBI.ModelName, 0) - 8>=0,
					CHARINDEX('(', MBI.ModelName, 0) - 8,
					0)
					) 
				end ) AS PartNo
		  ,(CASE WHEN MBI.MBISizeW IS NOT NULL
			     THEN RIGHT('0'+CONVERT(VARCHAR, CONVERT(INT, MBI.MBISizeW)), 2) + CONVERT(VARCHAR, CONVERT(INT, MBI.MBISizeH))
				 ELSE CONVERT(VARCHAR(10), MBI.MBISizeD) END + CASE WHEN CHARINDEX('-L', MBI.ModelName) > 0 THEN 'L' ELSE '' END ) AS Size
		  --,SUBSTRING(MBI.ModelName, CHARINDEX('(', MBI.ModelName, 0) + 1, 4) AS Size
		  ,lcmh.OldBarcode  as  oldBarcode
		  ,STUFF(MQI.MaterialQcNo,1,1,'') AS ProdQcNo1
		  ,MQI.MaterialQcNo AS ProdQcNo
		  ,MQI.MaterialQcNo
		  ,MQI.DecisionResult
		  ,MQI.DescText
		  ,MQI.MIIExtText01 AS InspWorkerCode
		  ,PWI.WorkerName AS inspWorkerName
		  ,MQD.QcInspectionItemName
		  ,MQSR.MaterialQcSampleNo
		  ,MQSR.TestValue
		  ,MQI.VendorLotNo as Holding_Hist

	  FROM STB_MaterialQcInfo MQI WITH(NOLOCK) 
			  LEFT OUTER JOIN STB_ModelBasicInfo MBI WITH(NOLOCK) 		ON MQI.MaterialCode = MBI.ModelCode
			  LEFT OUTER JOIN STB_ProdWorkerInfo PWI WITH(NOLOCK) 		ON MQI.MIIExtText01 = PWI.WorkerCode
			  LEFT OUTER JOIN STB_MaterialQcDetail MQD WITH(NOLOCK) 		ON MQI.MaterialQcNo = MQD.MaterialQcNo
			  LEFT OUTER JOIN STB_MaterialQcSampleResult MQSR WITH(NOLOCK) 		 ON MQSR.MaterialQcNo = MQD.MaterialQcNo AND MQSR.MaterialQcDetailNo = MQD.MaterialQcDetailNo
			  left outer join STB_LotChangeMaterialHistory lcmh  WITH(NOLOCK)  on (@CharFOQC + lcmh.NewBarcode = mqi.MaterialQcNo )
			  left outer join STB_MaterialMaster mm   WITH(NOLOCK)   on    mm.MaterialCode = lcmh.BefMaterialCode
	 WHERE 1=1
	   AND (MQI.InspectionDocType = 'AOQC' )
	   AND (@QcInspectionItemCode IS NULL OR MQD.QcInspectionItemCode = @QcInspectionItemCode)
	   --AND MQD.QcInspectionItemCode IN ('IQC_GPD_18', 'IQC_GPD_19', 'IQC_GPD_20')
	   AND (@MaterialQcNo IS NULL OR MQI.MaterialQcNo = @MaterialQcNo )
	   AND MQI.BasicDate BETWEEN @FromDate AND @ToDate
	   AND ((@CompanyCode = '*') OR (MQI.CompanyCode = @CompanyCode))   
	   AND (SUBSTRING(MBI.ModelName, CHARINDEX('(', MBI.ModelName, 0) + 1, 4)          like @SizeCode  	or 
				(CASE WHEN MBI.MBISizeW IS NOT NULL
			     THEN RIGHT('0'+CONVERT(VARCHAR, CONVERT(INT, MBI.MBISizeW)), 2) + CONVERT(VARCHAR, CONVERT(INT, MBI.MBISizeH))
				 ELSE CONVERT(VARCHAR(10), MBI.MBISizeD) END + CASE WHEN CHARINDEX('-L', MBI.ModelName) > 0 THEN 'L' ELSE '' END ) like @SizeCode
	   )                              
	   --and MQSR.TestValue is not null
	 ORDER BY MQI.BasicDate, MQI.MaterialQcNo, MQD.QcInspectionItemName, MQSR.MaterialQcSampleNo

END



--select*
--	  FROM STB_MaterialQcInfo
--	  where materialqcno='AVVLR133R010603' or materialqcno like 'A%'
--	  or MaterialQcNo in (
--	  'VVKQ283R010508',
--'VVKT063R010519',
--'VVKT123R010515',
--'VVLJ193R010504'
--	  )

