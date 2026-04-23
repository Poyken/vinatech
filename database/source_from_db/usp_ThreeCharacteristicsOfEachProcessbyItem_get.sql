
-- =============================================
-- Author: Kangs (kilee@vina.co.kr)
-- Create date: 2020-12-02
-- Browsable : True
-- Group : 품질관리 > 제품검사 > [C545] 품목별공정별3대특성 데이터현황 Grid부분
-- Description:	
-- Modified:
-- 실행문 :  usp_ThreeCharacteristicsOfEachProcessbyItem_get '','','1025','','2021-02-01','2021-02-28','IQC_GPD_18'
--             usp_ThreeCharacteristicsOfEachProcessbyItem_get '','','','','2020-12-01','2020-12-31','IQC_GPD_18'
               -- usp_ThreeCharacteristicsOfEachProcessbyItem_get '','','','','2024-05-01','2024-05-31','IQC_GPD_18','VVT_F1'
-- ===============================================================================================================
CREATE PROCEDURE [dbo].[usp_ThreeCharacteristicsOfEachProcessbyItem_get]
						@pProcessUserID VARCHAR(20),
						@pProcessLanguage VARCHAR(20),
						@pSizeCode           VARCHAR(20) = NULL  ,
						@pFarad           VARCHAR(20) = NULL ,
						@pFromDate          DATETIME,
						@pToDate			  DATETIME,
						@pQcInspectionItemCode VARCHAR(20) = NULL,
						@pWorkCenterCode NVARCHAR(20) = NULL
AS
BEGIN
	SET NOCOUNT ON;

	 Declare @FromDate                DATETIME     = @pFromDate
		       ,@ToDate                    DATETIME     = @pToDate
               ,@QcInspectionItemCode VARCHAR(20) = CASE WHEN ISNULL(@pQcInspectionItemCode,'') = '' THEN '*' ELSE @pQcInspectionItemCode END
	           ,@SizeCode				     VARCHAR(20) = CASE WHEN ISNULL(@pSizeCode, '') = '' THEN '%' ELSE @pSizeCode END
			   ,@Farad 				         VARCHAR(20) = CASE WHEN ISNULL(@pFarad, '') = '' THEN '%' ELSE @pFarad END
			    ,@WorkCenterCode 			VARCHAR(20) = CASE WHEN ISNULL(@pWorkCenterCode, '') = '' THEN '%' ELSE @pWorkCenterCode END


-- 조회 SQL문 
--SELECT  VNT.Size    AS Size
--          , VNT.Farad AS Farad
SELECT  Case When VNT.Size is Null Then VVT.Size  End  AS Size
          , Case When VNT.Farad is Null Then VVT.Farad  End  AS Farad

          , ISNULL(MAX(VNT.USL), 0) AS USL
		   , ISNULL(MIN(VNT.LSL), 0) AS LSL
		   , ISNULL(AVG(VNT.AVG), 0) AS VNT_AVG
		   , ISNULL(AVG(VNT.CPK), 0) AS VNT_CPK
          , ISNULL(AVG(VVT.AVG), 0) AS VVT_AVG
          , ISNULl(AVG(VVT.CPK), 0)  AS VVT_CPK
		  
FROM 
 (
SELECT A.Size	       AS Size
		, A.Farad + 'F' AS Farad
		, A.Spec_USL  AS USL
		, A.Spec_LSL   AS LSL
		, A.AVG_Value  AS AVG
		, A.CPK          AS CPK
FROM (		

				SELECT SUBSTRING(MBI.ModelName, CHARINDEX('(', MBI.ModelName, 0) + 1, 4) AS Size
						--  ,MQI.MaterialCode
						, MBI.MBIExtText05 AS Farad
						, MQII.USL as Spec_USL
						, MQII.LSL as Spec_LSL
						, MQI.CompanyCode AS CompanyCode
						--,MQI.WorkCenterCode

						, Case When Sum(MQSR.TestValue)  = 0 Then 0  Else SUM(MQSR.TestValue) End as SUM_Value
						, Case When Sum(MQSR.TestValue) = 0 Then 0  Else AVG(MQSR.TestValue) End as AVG_Value
						, Case When Sum(MQSR.TestValue)  = 0 Then 0  Else STDEV(MQSR.TestValue) End as STDEV_Value

						, Case When MQII.USL = 0 Then 0 
						        When MQII.LSL = 0 Then 0  Else (MQII.USL + MQII.LSL) / 2 End AS Value1

						, Case When MQII.USL = 0 Then 0 
						        When MQII.LSL = 0 Then 0  Else (MQII.USL - MQII.LSL) / 2  End AS Value2

                       , Case When MQII.USL = 0 Then 0 
						        When MQII.LSL = 0 Then 0  Else ABS((MQII.USL + MQII.LSL) / 2 - AVG(MQSR.TestValue))  End AS Value3

                       , Case When MQII.USL = 0 Then 0 
					            When MQII.LSL = 0 Then 0 
					            When ABS((MQII.USL + MQII.LSL) / 2 - AVG(MQSR.TestValue)) = 0 Then 0
								 When AVG(MQSR.TestValue) = 0 Then 0
						        When MQII.LSL = 0 Then 0  Else ROUND(ABS((MQII.USL + MQII.LSL) / 2 - AVG(MQSR.TestValue)) /  ((MQII.USL - MQII.LSL) / 2), 2)  End AS Value4

                       , Case When MQII.USL = 0 Then 0 
					            When MQII.USL - MQII.LSL  = 0 Then 0 
								 When  (STDEV(MQSR.TestValue) * 6) = 0 Then 0 
						        When MQII.LSL = 0 Then 0  Else ROUND((MQII.USL - MQII.LSL)   /   (STDEV(MQSR.TestValue) * 6), 2)  End AS Value5

                       , Case When MQII.USL = 0 Then 0
					            When (MQII.USL + MQII.LSL) = 0 Then 0
								When STDEV(MQSR.TestValue) = 0 Then 0
								When ABS(MQII.USL - MQII.LSL) = 0 Then 0
								When AVG(MQSR.TestValue) = 0  OR  AVG(MQSR.TestValue) = 1    Then 0
								When ABS((MQII.USL + MQII.LSL) / 2 - AVG(MQSR.TestValue)) /  ((MQII.USL - MQII.LSL) / 2) = 0 Then 0
								When AVG(MQSR.TestValue) = 0 OR  AVG(MQSR.TestValue) = 1 Then 0
						        When MQII.LSL = 0 Then 0   Else (1- ROUND(ABS((MQII.USL + MQII.LSL) / 2 - AVG(MQSR.TestValue)) / ((MQII.USL - MQII.LSL) / 2), 2)) * ROUND((MQII.USL - MQII.LSL) / (STDEV(MQSR.TestValue) * 6), 2)   End AS CPK
							
					  FROM STB_MaterialQcInfo MQI
							  LEFT OUTER JOIN STB_ModelBasicInfo MBI		ON MQI.MaterialCode = MBI.ModelCode
							  LEFT OUTER JOIN STB_ProdWorkerInfo PWI		ON MQI.MIIExtText01 = PWI.WorkerCode
							  LEFT OUTER JOIN STB_MaterialQcDetail MQD		ON MQI.MaterialQcNo = MQD.MaterialQcNo
							  LEFT OUTER JOIN STB_MaterialQcSampleResult MQSR		 ON MQSR.MaterialQcNo = MQD.MaterialQcNo		AND MQSR.MaterialQcDetailNo = MQD.MaterialQcDetailNo
							  LEFT OUTER JOIN STB_SetInfo SI ON SI.LotNumber = MQI.MaterialQcNo --#200903
							  LEFT OUTER JOIN STB_LineInfo LI ON SI.InputLineCode = LI.LineCode --#200903
							  LEFT OUTER JOIN STB_MaterialQcInspectionItem MQII ON MQI.MaterialCode = MQII.MaterialCode AND MQII.QcInspectionItemCode = MQD.QcInspectionItemCode
					 WHERE 1=1
					   AND MQI.InspectionDocType = 'OQC' AND MQI.WorkCenterCode = @WorkCenterCode  -- Add  addition work center code follow Vietnam QC
					   
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
					   


) A
WHERE 1=1
	AND A.CompanyCode = 'VNT'
GROUP BY 
			  A.Size					
			, A.Farad
			, A.Spec_USL
			, A.Spec_LSL
			, A.CompanyCode
			, A.AVG_Value
			, A.STDEV_Value
			,Value1
			, Value2
			,Value3
			,Value4
			,Value5
			, cpk
) VNT

--LEFT OUTER JOIN (
FULL OUTER JOIN (
						SELECT A.Size	       AS Size
								, A.Farad + 'F' AS Farad
								, A.Spec_USL  AS USL
								, A.Spec_LSL   AS LSL
								, A.AVG_Value  AS AVG
								, A.CPK          AS CPK
						FROM (		

										SELECT SUBSTRING(MBI.ModelName, CHARINDEX('(', MBI.ModelName, 0) + 1, 4) AS Size
												, MBI.MBIExtText05 AS Farad
												, MQII.USL as Spec_USL
												, MQII.LSL as Spec_LSL
												, MQI.CompanyCode AS CompanyCode

	, Case When Sum(MQSR.TestValue)  = 0 Then 0  Else SUM(MQSR.TestValue) End as SUM_Value
						, Case When Sum(MQSR.TestValue) = 0 Then 0  Else AVG(MQSR.TestValue) End as AVG_Value
						, Case When Sum(MQSR.TestValue)  = 0 Then 0  Else STDEV(MQSR.TestValue) End as STDEV_Value

						, Case When MQII.USL = 0 Then 0 
						        When MQII.LSL = 0 Then 0  Else (MQII.USL + MQII.LSL) / 2 End AS Value1

						, Case When MQII.USL = 0 Then 0 
						        When MQII.LSL = 0 Then 0  Else (MQII.USL - MQII.LSL) / 2  End AS Value2

                       , Case When MQII.USL = 0 Then 0 
						        When MQII.LSL = 0 Then 0  Else ABS((MQII.USL + MQII.LSL) / 2 - AVG(MQSR.TestValue))  End AS Value3

                       , Case When MQII.USL = 0 Then 0 
					            When MQII.LSL = 0 Then 0 
					            When ABS((MQII.USL + MQII.LSL) / 2 - AVG(MQSR.TestValue)) = 0 Then 0
								 When AVG(MQSR.TestValue) = 0 Then 0
						        When MQII.LSL = 0 Then 0  Else ROUND(ABS((MQII.USL + MQII.LSL) / 2 - AVG(MQSR.TestValue)) /  ((MQII.USL - MQII.LSL) / 2), 2)  End AS Value4

                       , Case When MQII.USL = 0 Then 0 
					            When MQII.USL - MQII.LSL  = 0 Then 0 
								 When  (STDEV(MQSR.TestValue) * 6) = 0 Then 0 
						        When MQII.LSL = 0 Then 0  Else ROUND((MQII.USL - MQII.LSL)   /   (STDEV(MQSR.TestValue) * 6), 2)  End AS Value5

                             , Case When MQII.USL = 0 Then 0
					            When (MQII.USL + MQII.LSL) = 0 Then 0
								When STDEV(MQSR.TestValue) = 0 Then 0
								When ABS(MQII.USL - MQII.LSL) = 0 Then 0
								When AVG(MQSR.TestValue) = 0  OR  AVG(MQSR.TestValue) = 1    Then 0
								When ABS((MQII.USL + MQII.LSL) / 2 - AVG(MQSR.TestValue)) /  ((MQII.USL - MQII.LSL) / 2) = 0 Then 0
								When AVG(MQSR.TestValue) = 0 OR  AVG(MQSR.TestValue) = 1 Then 0
						        When MQII.LSL = 0 Then 0   Else (1- ROUND(ABS((MQII.USL + MQII.LSL) / 2 - AVG(MQSR.TestValue)) / ((MQII.USL - MQII.LSL) / 2), 2)) * ROUND((MQII.USL - MQII.LSL) / (STDEV(MQSR.TestValue) * 6), 2)   End AS CPK

											  FROM STB_MaterialQcInfo MQI
													  LEFT OUTER JOIN STB_ModelBasicInfo MBI		ON MQI.MaterialCode = MBI.ModelCode
													  LEFT OUTER JOIN STB_ProdWorkerInfo PWI		ON MQI.MIIExtText01 = PWI.WorkerCode
													  LEFT OUTER JOIN STB_MaterialQcDetail MQD		ON MQI.MaterialQcNo = MQD.MaterialQcNo
													  LEFT OUTER JOIN STB_MaterialQcSampleResult MQSR		 ON MQSR.MaterialQcNo = MQD.MaterialQcNo		AND MQSR.MaterialQcDetailNo = MQD.MaterialQcDetailNo
													  LEFT OUTER JOIN STB_SetInfo SI ON SI.LotNumber = MQI.MaterialQcNo --#200903
													  LEFT OUTER JOIN STB_LineInfo LI ON SI.InputLineCode = LI.LineCode --#200903
													  LEFT OUTER JOIN STB_MaterialQcInspectionItem MQII ON MQI.MaterialCode = MQII.MaterialCode AND MQII.QcInspectionItemCode = MQD.QcInspectionItemCode
											 WHERE 1=1
											   AND MQI.InspectionDocType = 'OQC' AND MQI.WorkCenterCode = @WorkCenterCode  -- Add  addition work center code follow Vietnam QC
					   
											   --AND MQD.QcInspectionItemCode IN ('IQC_GPD_18')                                          -- SD 
											   --AND MQI.BasicDate BETWEEN '2020-12-01' AND '2020-12-30'
											   -- AND SUBSTRING(MBI.ModelName, CHARINDEX('(', MBI.ModelName, 0) + 1, 4) = '1030' AND MBI.MBIExtText05 = '10'

											   AND ((@QcInspectionItemCode = '*') OR (MQD.QcInspectionItemCode = @QcInspectionItemCode))   
											   AND MQI.BasicDate BETWEEN @FromDate AND @ToDate
												AND SUBSTRING(MBI.ModelName, CHARINDEX('(', MBI.ModelName, 0) + 1, 4)          like @SizeCode  	

					  
											 Group by SUBSTRING(MBI.ModelName, CHARINDEX('(', MBI.ModelName, 0) + 1, 4) 												
														  , MQI.CompanyCode
														  ,MBI.MBIExtText05 
														  , MQII.USL 
														, MQII.LSL
														,MQI.WorkCenterCode

						) A
						WHERE 1=1
							AND A.CompanyCode = 'VVT'     --베트남
							
						GROUP BY 
						  A.Size					
						, A.Farad
						, A.Spec_USL
						, A.Spec_LSL
						, A.CompanyCode
						, A.AVG_Value
						, A.STDEV_Value
						,Value1
						, Value2
						,Value3
						,Value4
						,Value5
						, cpk
                         )

				VVT On VVT.Size = VNT.Size 	AND VVT.Farad = VNT.Farad 

WHERE 1=1
GROUP BY VNT.Size    
          , VNT.Farad 
		  	, VVT.Size
			, VVT.Farad 
 Order by VNT.Size    
          , VNT.Farad 


END

-- SELECT TOP(100)* FROM STB_MaterialQcInfo WHERE WorkCenterCode = 'VVT_F1' ORDER BY CreateDateTime DESC



--SELECT TOP(100)* FROM STB_MaterialQcInfo WHERE WorkCenterCode = 'VVT_F2' ORDER BY CreateDateTime DESC

 --SELECT DISTINCT QcInspectionGroupCode FROM STB_MaterialQcDetail WHERE QcInspectionGroupCode IS NOT NULL