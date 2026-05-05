
-- =============================================
-- Author: Kangs (kilee@vina.co.kr)
-- Create date: 2020-12-02
-- Browsable : True
-- Group : 품질관리 > 제품검사 > [C545] 품목별공정별3대특성 데이터현황
-- Description:	
-- Modified:
-- 실행문 :  usp_ThreeCharacteristicsOfEachProcessbyItem_get_20201203 '','','1030','','2020-12-01','2020-12-31','IQC_GPD_18'
-- =============================================
CREATE PROCEDURE [dbo].[usp_ThreeCharacteristicsOfEachProcessbyItem_get_20201203]
						@pProcessUserID VARCHAR(20),
						@pProcessLanguage VARCHAR(20),
						@pSizeCode           VARCHAR(20) = NULL  ,
						@pFarad           VARCHAR(20) = NULL ,
						@pFromDate          DATETIME,
						@pToDate			  DATETIME,
						@pQcInspectionItemCode VARCHAR(20) = NULL
AS
BEGIN
	SET NOCOUNT ON;

	 Declare @FromDate               DATETIME     = @pFromDate
		     ,@ToDate                   DATETIME     = @pToDate
    DECLARE @QcInspectionItemCode VARCHAR(20) = CASE WHEN ISNULL(@pQcInspectionItemCode,'') = '' THEN '*' ELSE @pQcInspectionItemCode END
	             ,@SizeCode				    VARCHAR(20) = CASE WHEN ISNULL(@pSizeCode, '') = '' THEN '%' ELSE @pSizeCode END
				  ,@Farad 				    VARCHAR(20) = CASE WHEN ISNULL(@pFarad, '') = '' THEN '%' ELSE @pFarad END





	INSERT INTO #Korea

				SELECT A.Size
						--,A.MaterialCode					
						, A.Farad + 'F' as Farad
						, A.Spec_USL AS USL
						, A.Spec_LSL AS LSL
					--	, A.CompanyCode AS CompanyCode

						,   AVG_Value
								 AS AVG_Value

						, CPK
							  AS CPK

				FROM (		

								SELECT SUBSTRING(MBI.ModelName, CHARINDEX('(', MBI.ModelName, 0) + 1, 4) AS Size
										--  ,MQI.MaterialCode
										, MBI.MBIExtText05 AS Farad
										, MQII.USL as Spec_USL
										, MQII.LSL as Spec_LSL
										, MQI.CompanyCode AS CompanyCode
										, SUM(ROUND(MQSR.TestValue,2)) as SUM_Value
										, AVG(ROUND(MQSR.TestValue,2)) as AVG_Value
										, STDEV(ROUND(MQSR.TestValue,2)) as STDEV_Value

										--, (MQII.USL + MQII.LSL) / 2 as Value1
										--, (MQII.USL - MQII.LSL) / 2 as Value2
										--, ABS((MQII.USL + MQII.LSL) / 2 - AVG(MQSR.TestValue)) AS Value3
										--, ROUND(ABS((MQII.USL + MQII.LSL) / 2 - AVG(MQSR.TestValue)) /  ((MQII.USL - MQII.LSL) / 2), 2) AS Value4
										--, ROUND((MQII.USL - MQII.LSL)   /   (STDEV(MQSR.TestValue) * 6), 2) AS Value5
										--, (1-   ROUND(ABS((MQII.USL + MQII.LSL) / 2 - AVG(MQSR.TestValue)) /  ((MQII.USL - MQII.LSL) / 2), 2))    *    ROUND((MQII.USL - MQII.LSL)   /   (STDEV(MQSR.TestValue) * 6), 2)      AS CPK

										, Case When MQII.USL = 0 Then 0 
												When MQII.LSL = 0 Then 0  Else (MQII.USL + MQII.LSL) / 2 End AS Value1
										, Case When MQII.USL = 0 Then 0 
												When MQII.LSL = 0 Then 0  Else (MQII.USL - MQII.LSL) / 2  End AS Value2
									   , Case When MQII.USL = 0 Then 0 
												When MQII.LSL = 0 Then 0  Else ABS((MQII.USL + MQII.LSL) / 2 - AVG(MQSR.TestValue))  End AS Value3
									   , Case When MQII.USL = 0 Then 0 
												When MQII.LSL = 0 Then 0  Else ROUND(ABS((MQII.USL + MQII.LSL) / 2 - AVG(MQSR.TestValue)) /  ((MQII.USL - MQII.LSL) / 2), 2)  End AS Value4
									   , Case When MQII.USL = 0 Then 0 
												When MQII.LSL = 0 Then 0  Else ROUND((MQII.USL - MQII.LSL)   /   (STDEV(MQSR.TestValue) * 6), 2)  End AS Value5
									   , Case When MQII.USL = 0 Then 0 
												When MQII.LSL = 0 Then 0  Else (1-   ROUND(ABS((MQII.USL + MQII.LSL) / 2 - AVG(MQSR.TestValue)) /  ((MQII.USL - MQII.LSL) / 2), 2))    *    ROUND((MQII.USL - MQII.LSL)   /   (STDEV(MQSR.TestValue) * 6), 2)   End AS CPK

									  FROM STB_MaterialQcInfo MQI
											  LEFT OUTER JOIN STB_ModelBasicInfo MBI		ON MQI.MaterialCode = MBI.ModelCode
											  LEFT OUTER JOIN STB_ProdWorkerInfo PWI		ON MQI.MIIExtText01 = PWI.WorkerCode
											  LEFT OUTER JOIN STB_MaterialQcDetail MQD		ON MQI.MaterialQcNo = MQD.MaterialQcNo
											  LEFT OUTER JOIN STB_MaterialQcSampleResult MQSR		 ON MQSR.MaterialQcNo = MQD.MaterialQcNo		AND MQSR.MaterialQcDetailNo = MQD.MaterialQcDetailNo
											  LEFT OUTER JOIN STB_SetInfo SI ON SI.LotNumber = MQI.MaterialQcNo --#200903
											  LEFT OUTER JOIN STB_LineInfo LI ON SI.InputLineCode = LI.LineCode --#200903
											  LEFT OUTER JOIN STB_MaterialQcInspectionItem MQII ON MQI.MaterialCode = MQII.MaterialCode AND MQII.QcInspectionItemCode = MQD.QcInspectionItemCode
									 WHERE 1=1
									   AND MQI.InspectionDocType = 'OQC'
					   
									   --AND MQD.QcInspectionItemCode IN ('IQC_GPD_18')                                          -- SD 
									   --AND MQI.BasicDate BETWEEN '2020-12-01' AND '2020-12-30'
									   -- AND SUBSTRING(MBI.ModelName, CHARINDEX('(', MBI.ModelName, 0) + 1, 4) = '1030' AND MBI.MBIExtText05 = '10'

									   AND ((@QcInspectionItemCode = '*') OR (MQD.QcInspectionItemCode = @QcInspectionItemCode))   
									   AND MQI.BasicDate BETWEEN @FromDate AND @ToDate
										AND SUBSTRING(MBI.ModelName, CHARINDEX('(', MBI.ModelName, 0) + 1, 4)          like @SizeCode  	

					  
									 Group by SUBSTRING(MBI.ModelName, CHARINDEX('(', MBI.ModelName, 0) + 1, 4) 
											--	  , MQI.MaterialCode
												  , MQI.CompanyCode
												  ,MBI.MBIExtText05 
												  , MQII.USL 
												, MQII.LSL
								--	 ORDER BY SUBSTRING(MBI.ModelName, CHARINDEX('(', MBI.ModelName, 0) + 1, 4) 

				)  A
				WHERE 1=1
				  AND A.CompanyCode = 'VNT'





INSERT INTO #Vietnam

				SELECT B.Size
						--,A.MaterialCode					
						, B.Farad + 'F' as Farad
						, B.Spec_USL AS USL
						, B.Spec_LSL AS LSL
					--	, A.CompanyCode AS CompanyCode

	


						,   AVG_Value
								 AS AVG_Value

						, CPK
							  AS _CPK


	
				FROM (		

								SELECT SUBSTRING(MBI.ModelName, CHARINDEX('(', MBI.ModelName, 0) + 1, 4) AS Size
										--  ,MQI.MaterialCode
										, MBI.MBIExtText05 AS Farad
										, MQII.USL as Spec_USL
										, MQII.LSL as Spec_LSL
										, MQI.CompanyCode AS CompanyCode
										, SUM(ROUND(MQSR.TestValue,2)) as SUM_Value
										, AVG(ROUND(MQSR.TestValue,2)) as AVG_Value
										, STDEV(ROUND(MQSR.TestValue,2)) as STDEV_Value


										, Case When MQII.USL = 0 Then 0 
												When MQII.LSL = 0 Then 0  Else (MQII.USL + MQII.LSL) / 2 End AS Value1
										, Case When MQII.USL = 0 Then 0 
												When MQII.LSL = 0 Then 0  Else (MQII.USL - MQII.LSL) / 2  End AS Value2
									   , Case When MQII.USL = 0 Then 0 
												When MQII.LSL = 0 Then 0  Else ABS((MQII.USL + MQII.LSL) / 2 - AVG(MQSR.TestValue))  End AS Value3
									   , Case When MQII.USL = 0 Then 0 
												When MQII.LSL = 0 Then 0  Else ROUND(ABS((MQII.USL + MQII.LSL) / 2 - AVG(MQSR.TestValue)) /  ((MQII.USL - MQII.LSL) / 2), 2)  End AS Value4
									   , Case When MQII.USL = 0 Then 0 
												When MQII.LSL = 0 Then 0  Else ROUND((MQII.USL - MQII.LSL)   /   (STDEV(MQSR.TestValue) * 6), 2)  End AS Value5
									   , Case When MQII.USL = 0 Then 0 
												When MQII.LSL = 0 Then 0  Else (1-   ROUND(ABS((MQII.USL + MQII.LSL) / 2 - AVG(MQSR.TestValue)) /  ((MQII.USL - MQII.LSL) / 2), 2))    *    ROUND((MQII.USL - MQII.LSL)   /   (STDEV(MQSR.TestValue) * 6), 2)   End AS CPK

									  FROM STB_MaterialQcInfo MQI
											  LEFT OUTER JOIN STB_ModelBasicInfo MBI		ON MQI.MaterialCode = MBI.ModelCode
											  LEFT OUTER JOIN STB_ProdWorkerInfo PWI		ON MQI.MIIExtText01 = PWI.WorkerCode
											  LEFT OUTER JOIN STB_MaterialQcDetail MQD		ON MQI.MaterialQcNo = MQD.MaterialQcNo
											  LEFT OUTER JOIN STB_MaterialQcSampleResult MQSR		 ON MQSR.MaterialQcNo = MQD.MaterialQcNo		AND MQSR.MaterialQcDetailNo = MQD.MaterialQcDetailNo
											  LEFT OUTER JOIN STB_SetInfo SI ON SI.LotNumber = MQI.MaterialQcNo --#200903
											  LEFT OUTER JOIN STB_LineInfo LI ON SI.InputLineCode = LI.LineCode --#200903
											  LEFT OUTER JOIN STB_MaterialQcInspectionItem MQII ON MQI.MaterialCode = MQII.MaterialCode AND MQII.QcInspectionItemCode = MQD.QcInspectionItemCode
									 WHERE 1=1
									   AND MQI.InspectionDocType = 'OQC'
					   
									   --AND MQD.QcInspectionItemCode IN ('IQC_GPD_18')                                          -- SD 
									   --AND MQI.BasicDate BETWEEN '2020-12-01' AND '2020-12-30'
									   -- AND SUBSTRING(MBI.ModelName, CHARINDEX('(', MBI.ModelName, 0) + 1, 4) = '1030' AND MBI.MBIExtText05 = '10'

									   AND ((@QcInspectionItemCode = '*') OR (MQD.QcInspectionItemCode = @QcInspectionItemCode))   
									   AND MQI.BasicDate BETWEEN @FromDate AND @ToDate
										AND SUBSTRING(MBI.ModelName, CHARINDEX('(', MBI.ModelName, 0) + 1, 4)          like @SizeCode  	

					  
									 Group by SUBSTRING(MBI.ModelName, CHARINDEX('(', MBI.ModelName, 0) + 1, 4) 
											--	  , MQI.MaterialCode
												  , MQI.CompanyCode
												  ,MBI.MBIExtText05 
												  , MQII.USL 
												, MQII.LSL
								--	 ORDER BY SUBSTRING(MBI.ModelName, CHARINDEX('(', MBI.ModelName, 0) + 1, 4) 


				) B
				WHERE 1=1 
				AND B.CompanyCode = 'VVT'



SELECT K.*
        , V.*
From #Korea K
 Left Outer join #Vietnam V On K.Size = V.Size

 DROP TABLE #Korea
  DROP TABLE #Vietnam


END