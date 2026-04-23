-- =============================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Create date: 2021-10-30
-- Browsable : true
-- Group : 품질관리
-- Description:	VPC 제품검사 이력
-- Modified:
-- =================================================================================================================================
CREATE PROCEDURE [dbo].[usp_ProdInspectionHistQc_get]
	@pFromDate          DATETIME,
	@pToDate			  DATETIME,
	@pCompanyCode    VARCHAR(20) = NULL
AS
BEGIN

   Declare @CompanyCode        VARCHAR(20)  = CASE WHEN ISNULL(@pCompanyCode,'') = '' THEN '*' ELSE @pCompanyCode END
   Declare @FromDate               DATETIME     = @pFromDate
		  ,@ToDate                   DATETIME     = @pToDate
		  ,@datediff INT

	SET @datediff = DATEDIFF(day, @FromDate, @ToDate)

	IF @datediff > 60 BEGIN
		EXEC usp_RaiseLocalizedError 'Korean', '조회 기간이 너무 깁니다. 시작일자와 종료일자를 조정하세요.'
		RETURN
	END


	SELECT MQI.BasicDate AS 기준일자
		  ,MQI.MaterialCode AS 품목코드
		  ,MBI.ModelName AS 품목명
		  ,RTRIM(LTRIM(SUBSTRING(MBI.ModelName, CHARINDEX(' ', MBI.ModelName), 12))) as  PartNo
		  ,CASE WHEN MBI.MBISizeW IS NOT NULL
			     THEN RIGHT('0'+CONVERT(VARCHAR, CONVERT(INT, MBI.MBISizeW)), 2) + CONVERT(VARCHAR, CONVERT(INT, MBI.MBISizeH))
				 ELSE CONVERT(VARCHAR(10), MBI.MBISizeD) END + CASE WHEN CHARINDEX('-L', MBI.ModelName) > 0 THEN 'L' ELSE '' END AS Size
		  ,MQI.MaterialQcNo AS ProdQcNo
		  ,MQI.DecisionResult AS 판정결과
		  ,MQI.DescText AS 판정내용
		  ,MQI.MIIExtText01 AS 검사자코드
		  ,PWI.WorkerName AS 검사자명
		  ,MQD.QcInspectionItemName AS 검사항목
		  ,MQSR.MaterialQcSampleNo AS 검사순번
		  ,MQSR.TestValue AS 검사값
		  ,LI.LineCode --#200903
		  ,LI.LineDesc AS LineName --#200903
		  ,STUFF(
              (SELECT 
                 ', ' +levelB
                from VVT_OQC_REFER with(nolock) where mergeid = (select top 1 mergeid from vvt_oqc_refer where lotid =MQI.MaterialQcNo)  FOR XML PATH ('')
		      ), 1, 2, ''
            ) AS Classify

		  ,STUFF(
              (SELECT 
                ', ' + Lotid 
                from VVT_OQC_REFER with(nolock)  where mergeid = (select top 1 mergeid from vvt_oqc_refer where lotid =MQI.MaterialQcNo)  FOR XML PATH ('')
		      ), 1, 2, ''
             ) AS LotID_list
		 ,MQI.VendorLotNo as Holding_Hist
		 , lcmh.NewBarcode
		 , lcmh.AftMaterialCode
		 , replace(substring(spt.PackingID ,1,15),'-','') as KoreaLabel

	  FROM (SELECT * FROM STB_MaterialQcInfo with(nolock) WHERE InspectionDocType = 'OQC') MQI 
			  LEFT OUTER JOIN STB_ModelBasicInfo MBI with(nolock) 		ON MQI.MaterialCode = MBI.ModelCode
			  LEFT OUTER JOIN STB_ProdWorkerInfo PWI with(nolock) 		ON MQI.MIIExtText01 = PWI.WorkerCode
			  LEFT OUTER JOIN (SELECT * 
			                     FROM STB_MaterialQcDetail  with(nolock) 
								WHERE QcInspectionItemCode IN ('PQC_V01_01', 'PQC_V01_07','PQC_V01_08','PQC_V01_09')
							  ) MQD ON MQI.MaterialQcNo = MQD.MaterialQcNo
			  LEFT OUTER JOIN STB_MaterialQcSampleResult MQSR	 with(nolock) 	 ON MQSR.MaterialQcNo = MQD.MaterialQcNo		
																				AND MQSR.MaterialQcDetailNo = MQD.MaterialQcDetailNo
			  LEFT OUTER JOIN STB_SetInfo SI  with(nolock) ON SI.LotNumber = MQI.MaterialQcNo --#200903
			  LEFT OUTER JOIN STB_LineInfo LI  with(nolock) ON SI.InputLineCode = LI.LineCode --#200903
			  LEFT OUTER JOIN STB_LotChangeMaterialHistory lcmh   with(nolock)  on MQI.MaterialQcNo = lcmh.OldBarcode
			  OUTER apply( 
				select top 1 *
				from STB_SavePackingTime_VVT    with(nolock)  
				where LotNo = MQI.MaterialQcNo   and PackingID like 'VJ%'
				)spt
	 WHERE 1=1
	   AND ((@CompanyCode = '*') OR (MQI.CompanyCode = @CompanyCode))   
	   AND MQI.BasicDate BETWEEN @FromDate AND @ToDate
	   AND MQI.InspectionDocType = 'OQC'
	   AND MQD.QcInspectionItemCode IN ('PQC_V01_01', 'PQC_V01_07','PQC_V01_08','PQC_V01_09')
	   --AND MQI.MaterialQcNo Not In ('VJLU253R850601', 'VJLU183R850609', 'VJLU153R850602', 'VJLU183R850612', 'VJMJ013R850602', 'VJLU113R850606', 'VJLU153R850603')  --22. 01. 20 삼성 오딧 관련 추가. 22. 01. 24일 이후 삭제 예정
	 ORDER BY MQI.BasicDate, MQI.MaterialQcNo, MQD.QcInspectionItemName, MQSR.MaterialQcSampleNo

END