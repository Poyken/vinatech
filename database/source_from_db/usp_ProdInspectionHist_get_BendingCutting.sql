-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE usp_ProdInspectionHist_get_BendingCutting
			@pProcessUserID     VARCHAR(20),
			@pProcessLanguage VARCHAR(20),
			@pFromDate          DATETIME,
			@pToDate			  DATETIME,
			@pMaterialQcNo     VARCHAR(20) = NULL,
			@pQcInspectionItemCode VARCHAR(20) = NULL,
			@pBarcode			  VARCHAR(20) = NULL,
			@pCompanyCode    VARCHAR(20) = NULL,                                         -- 사업장 추가 (2019.12.22, kilee)
			@pWorkCenterCode VARCHAR(20) = NULL,
			@pSizeCode           VARCHAR(20) = NULL,                                         -- 사이즈 추가 (2020.01.07, kilee)
			@pDecisionResult      VARCHAR(20) = NULL                                        -- 판정결과 추가 -> 이미정님 요청 (2021.04.30, kilee)
AS
BEGIN

   Declare @CompanyCode        VARCHAR(20)  = CASE WHEN ISNULL(@pCompanyCode,'') = '' THEN '*' ELSE @pCompanyCode END
   Declare @FromDate               DATETIME     = @pFromDate
		     ,@ToDate                   DATETIME     = @pToDate
		     ,@MaterialQcNo           VARCHAR(20) = CASE WHEN ISNULL(@pMaterialQcNo,'') = '' THEN '*' ELSE @pMaterialQcNo END
		     ,@QcInspectionItemCode VARCHAR(20) = CASE WHEN ISNULL(@pQcInspectionItemCode,'') = '' THEN '*' ELSE @pQcInspectionItemCode END
		     ,@Barcode				    VARCHAR(20) = @pBarcode
		     ,@SizeCode				    VARCHAR(20) = CASE WHEN ISNULL(@pSizeCode, '') = '' THEN '*' ELSE  @pSizeCode  END
			 --,@DecisionResult        VARCHAR(20) =  @pDecisionResult     --  kilee 추가 - 이미정추가 (2021.04.30)
			  ,@DecisionResult        VARCHAR(20) =  CASE WHEN ISNULL(@pDecisionResult,'') = '' THEN '*' ELSE @pDecisionResult END  --  kilee 추가 - 이미정추가 (2021.04.30)
			,@WorkCenterCode VARCHAR(20) = CASE WHEN ISNULL(@pWorkCenterCode,'') = '' THEN '*' ELSE @pWorkCenterCode END
			 
			   --select @workcentercode=Workcentercode from sTB_userinfo where userid = @pProcessUserID -- Lấy nhà máy hà nam để lấy dữ liệu

			
	--#211118
	Declare @PeriodCnt INT

	SELECT @PeriodCnt = DATEDIFF(day, @FromDate, @ToDate)

	--IF @PeriodCnt > 100 AND (@SizeCode = '*' OR @SizeCode = '0825') and @pCompanyCode <>'VVT'  ---Mr.Tung add CompanyCode that excluded Vietnam site
	--BEGIN
	--	EXEC usp_RaiseLocalizedError @pProcessLanguage, '조회기간은 100일을 초과할 수 없습니다.'
	--	RETURN
	--END

	IF @Barcode IS NOT NULL 	
	BEGIN
		SELECT @MaterialQcNo = LotNumber
		  FROM STB_SetInfo with(nolock) 
		 WHERE Barcode = @Barcode
	END

	IF @CompanyCode = 'VVT' BEGIN

		;with mqi as(
		SELECT  dateadd(hour,2 , convert(datetime,MQI.BasicDate)) BasicDate   --Mr.Tung add date, avoid decrease 1 day 
			  ,MQI.MaterialCode
			  ,MBI.ModelName
			  --,SUBSTRING(MBI.ModelName, 8, (CHARINDEX('(', MBI.ModelName, 0) - 8)) AS PartNo

			  ,RTRIM(LTRIM(SUBSTRING(MBI.ModelName, CHARINDEX(' ', MBI.ModelName), 12))) as  PartNo  -- modified by Mr.Tung on 07-May-2021, due SUBSTRING whenever ModelName length to short
			  --,SUBSTRING(MBI.ModelName, CHARINDEX('(', MBI.ModelName, 0) + 1, 4) AS Size
			  ,CASE WHEN MBI.MBISizeW IS NOT NULL
					 THEN RIGHT('0'+CONVERT(VARCHAR, CONVERT(INT, MBI.MBISizeW)), 2) + CONVERT(VARCHAR, CONVERT(INT, MBI.MBISizeH))
					 ELSE CONVERT(VARCHAR(10), MBI.MBISizeD) END + CASE WHEN CHARINDEX('-L', MBI.ModelName) > 0 THEN 'L' ELSE '' END AS Size
			  ,MQI.MaterialQcNo AS ProdQcNo 
		  	 ,CASE WHEN MQI.MaterialQcNo = 'VVPM212R750625' THEN isnull(lcmh.NewBarcode, si.Barcode)
					ELSE isnull(si.Barcode, lcmh.NewBarcode) END as NewBarcode 
			 , lcmh.AftMaterialCode
			 , replace(substring(spt.PackingID ,1,15),'-','') as KoreaLabel
			  ,MQI.DecisionResult
			  ,MQI.DescText
			  ,MQI.QcMarking
			  ,MQI.MIIExtText01 AS InspWorkerCode
			  ,PWI.WorkerName AS inspWorkerName
			  ,MQD.QcInspectionItemName
			  ,ROW_NUMBER() OVER(PARTITION BY MQI.MaterialQcNo, MQD.QcInspectionItemName 
									 ORDER BY MQI.BasicDate, MQI.MaterialQcNo, MQD.QcInspectionItemName, MQSR.MaterialQcSampleNo ASC) AS MaterialQcSampleNo
			  ,MQSR.TestValue
			  ,LI.LineCode --#200903
			  ,LI.LineDesc AS LineName --#200903
		  

			  --this STUFF and XML PATH for Vietnam Classify Only 
			  --Mr.Tung add on 17-March-2021
			  ,STUFF(
				  (SELECT 
					 ', ' +levelB
					from VVT_OQC_REFER with(nolock) where mergeid = (select top 1 mergeid from vvt_oqc_refer  with(nolock) where lotid =MQI.MaterialQcNo)  FOR XML PATH ('')
				  ), 1, 2, ''
				) AS Classify

			  ,STUFF(
				  (SELECT 
					', ' + Lotid 
					from VVT_OQC_REFER with(nolock)  where mergeid = (select top 1 mergeid from vvt_oqc_refer with(nolock)  where lotid =MQI.MaterialQcNo)  FOR XML PATH ('')
				  ), 1, 2, ''
				 ) AS LotID_list
			 ,MQI.VendorLotNo as Holding_Hist

			 , MQSR.CreateDateTime

		  FROM STB_MaterialQcInfo_BendingCutting MQI with(nolock) 
				  LEFT OUTER JOIN STB_ModelBasicInfo MBI with(nolock) 		ON MQI.MaterialCode = MBI.ModelCode
				  LEFT OUTER JOIN STB_ProdWorkerInfo PWI with(nolock) 		ON MQI.MIIExtText01 = PWI.WorkerCode
				  LEFT OUTER JOIN STB_MaterialQcDetail_BendingCutting MQD with(nolock) 		ON MQI.MaterialQcNo = MQD.MaterialQcNo
				  LEFT OUTER JOIN STB_MaterialQcSampleResult_BendingCutting MQSR	 with(nolock) 	 ON MQSR.MaterialQcNo = MQD.MaterialQcNo		
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
		   AND MQI.InspectionDocType = 'BCQC'
			AND MQD.QcInspectionItemCode IN (select QcInspectionItemCode from  STB_QcInspectionItem where IsHideOrShowHistory=1) --Mr.Duy cấu hình dòng này ở C121 cột Ẩn/Hiển thị 
		   --AND (@QcInspectionItemCode IS NULL OR MQD.QcInspectionItemCode = @QcInspectionItemCode)
		   AND (@QcInspectionItemCode = '*' OR MQD.QcInspectionItemCode = @QcInspectionItemCode)
		   AND (@MaterialQcNo = '*' OR MQI.MaterialQcNo = @MaterialQcNo)
		   AND MQI.BasicDate BETWEEN @FromDate AND @ToDate
		   AND ((@CompanyCode = '*') OR (MQI.CompanyCode = @CompanyCode))   
		  AND (
				(@workcentercode = 'VVT_F3' AND MQI.WorkCenterCode = 'VVT_F3')
				OR (@workcentercode <> 'VVT_F3' AND MQI.WorkCenterCode IN ('VVT_F1', 'VVT_F2'))
)
		   --AND SUBSTRING(MBI.ModelName, CHARINDEX('(', MBI.ModelName, 0) + 1, 4)          like @SizeCode  	                                 -- 추가사항
	   
		   --and RIGHT('0'+CONVERT(VARCHAR, CONVERT(INT, MBI.MBISizeW)), 2) + CONVERT(VARCHAR, CONVERT(INT, MBI.MBISizeH)) like  '%' + @SizeCode + '%' -- modified by Mr.Tung on 07-May-2021, due user can not search 1320 model
		   AND (@SizeCode = '*' OR RIGHT('0'+CONVERT(VARCHAR, CONVERT(INT, MBI.MBISizeW)), 2) + CONVERT(VARCHAR, CONVERT(INT, MBI.MBISizeH)) like  '%' + @SizeCode + '%') -- Condition modify (using index)
		   AND ((@DecisionResult = '*') OR (MQI.DecisionResult  = @DecisionResult))    -- 이미정님 요청 (2021.04.30, kilee)


		--   and mqi.BasicDate < (case when MQI.MaterialCode in ('ECVT27-213',
		--									'ECVT30-197',
		--									'ECVT30-204',
		--									'ECVT30-098',
		--									'ECVT30-116',
		--									'ECVT25-099',
		--									'VSECVT30-098',
		--									'ECVT27-385',
		--									'ECVT30-294',
		--									'RE3000-086') then '2022-01-01' else convert(varchar(10),dateadd(day,1,getdate()),120) end)										
		--union all 
		--	SELECT  [colu1]
	 --     ,[colu2]
	 --     ,[colu3]
	 --     ,[colu4]
	 --     ,[colu5]
	 --     ,[colu6]
	 --     ,[colu7]
	 --     ,[colu8]
	 --     ,[colu9]
	 --     ,[colu10]
	 --     ,[colu11]
	 --     ,[colu12]
	 --     ,[colu13]
	 --     ,[colu14]
	 --     ,[colu15]
	 --     ,[colu16]
	 --     ,[colu17]
	 --     ,[colu18]
	 --     ,[colu19]
	 --     ,[colu20]
	 --     ,[colu21]
	 --     ,[colu22]
	 -- FROM [SmartFactoryV2].[dbo].[stb_vvt_oqc_2022]
	 --   where colu1 BETWEEN @FromDate AND @ToDate
		--and @SizeCode='*' or @SizeCode='3562'

	  )

	  select*from mqi
		ORDER BY BasicDate, ProdQcNo, QcInspectionItemName, MaterialQcSampleNo
  END ELSE BEGIN
	;with mqi as(
		SELECT MQI.BasicDate
			  ,MQI.MaterialCode
			  ,MBI.ModelName
			  --,SUBSTRING(MBI.ModelName, 8, (CHARINDEX('(', MBI.ModelName, 0) - 8)) AS PartNo

			  ,RTRIM(LTRIM(SUBSTRING(MBI.ModelName, CHARINDEX(' ', MBI.ModelName), 12))) as  PartNo  -- modified by Mr.Tung on 07-May-2021, due SUBSTRING whenever ModelName length to short
			  --,SUBSTRING(MBI.ModelName, CHARINDEX('(', MBI.ModelName, 0) + 1, 4) AS Size
			  ,CASE WHEN MBI.MBISizeW IS NOT NULL
					 THEN RIGHT('0'+CONVERT(VARCHAR, CONVERT(INT, MBI.MBISizeW)), 2) + CONVERT(VARCHAR, CONVERT(INT, MBI.MBISizeH))
					 ELSE CONVERT(VARCHAR(10), MBI.MBISizeD) END + CASE WHEN CHARINDEX('-L', MBI.ModelName) > 0 THEN 'L' ELSE '' END AS Size
			  ,MQI.MaterialQcNo AS ProdQcNo 
		  	 , isnull(si.Barcode, lcmh.NewBarcode) as NewBarcode
			 , lcmh.AftMaterialCode
			 , '' as KoreaLabel
			  ,MQI.DecisionResult
			  ,MQI.DescText
			  ,MQI.MIIExtText01 AS InspWorkerCode
			  ,PWI.WorkerName AS inspWorkerName
			  ,MQD.QcInspectionItemName
			  ,ROW_NUMBER() OVER(PARTITION BY MQI.MaterialQcNo, MQD.QcInspectionItemName 
									 ORDER BY MQI.BasicDate, MQI.MaterialQcNo, MQD.QcInspectionItemName, MQSR.MaterialQcSampleNo ASC) AS MaterialQcSampleNo
			  ,MQSR.TestValue
			  ,LI.LineCode --#200903
			  ,LI.LineDesc AS LineName --#200903
		  

			  --this STUFF and XML PATH for Vietnam Classify Only 
			  --Mr.Tung add on 17-March-2021
			  ,'' AS Classify

			  ,'' AS LotID_list
			 ,MQI.VendorLotNo as Holding_Hist

			 , MQSR.CreateDateTime

		  FROM STB_MaterialQcInfo_BendingCutting MQI with(nolock) 
				  LEFT OUTER JOIN STB_ModelBasicInfo MBI with(nolock) 		ON MQI.MaterialCode = MBI.ModelCode
				  LEFT OUTER JOIN STB_ProdWorkerInfo PWI with(nolock) 		ON MQI.MIIExtText01 = PWI.WorkerCode
				  LEFT OUTER JOIN STB_MaterialQcDetail_BendingCutting MQD with(nolock) 		ON MQI.MaterialQcNo = MQD.MaterialQcNo
				  LEFT OUTER JOIN STB_MaterialQcSampleResult_BendingCutting MQSR	 with(nolock) 	 ON MQSR.MaterialQcNo = MQD.MaterialQcNo		
																					AND MQSR.MaterialQcDetailNo = MQD.MaterialQcDetailNo
				  LEFT OUTER JOIN STB_SetInfo SI  with(nolock) ON SI.LotNumber = MQI.MaterialQcNo --#200903
				  LEFT OUTER JOIN STB_LineInfo LI  with(nolock) ON SI.InputLineCode = LI.LineCode --#200903
				  LEFT OUTER JOIN STB_LotChangeMaterialHistory lcmh   with(nolock)  on MQI.MaterialQcNo = lcmh.OldBarcode
		 WHERE 1=1
		   AND MQI.InspectionDocType = 'BCQC'
			AND (MQD.QcInspectionItemCode IN ('IQC_GPD_18', 'IQC_GPD_19', 'IQC_GPD_20', 'PQC_V01_01', 'PQC_V01_02'
										  , 'PQC_V01_03', 'PQC_V01_04', 'PQC_V01_05','PQC_V01_07','PQC_V01_08'
										  ,'PQC_V01_09','PQC_M01_001')
					OR MQD.QcInspectionItemCode LIKE 'IQC_G36%'
				)
		   --AND (@QcInspectionItemCode IS NULL OR MQD.QcInspectionItemCode = @QcInspectionItemCode)
		   AND (@QcInspectionItemCode = '*' OR MQD.QcInspectionItemCode = @QcInspectionItemCode)
		   AND (@MaterialQcNo = '*' OR MQI.MaterialQcNo = @MaterialQcNo)
		   AND MQI.BasicDate BETWEEN @FromDate AND @ToDate
		   AND ((@CompanyCode = '*') OR (MQI.CompanyCode = @CompanyCode))   
		   --AND SUBSTRING(MBI.ModelName, CHARINDEX('(', MBI.ModelName, 0) + 1, 4)          like @SizeCode  	                                 -- 추가사항
	   
		   --and RIGHT('0'+CONVERT(VARCHAR, CONVERT(INT, MBI.MBISizeW)), 2) + CONVERT(VARCHAR, CONVERT(INT, MBI.MBISizeH)) like  '%' + @SizeCode + '%' -- modified by Mr.Tung on 07-May-2021, due user can not search 1320 model
		   AND (@SizeCode = '*' OR RIGHT('0'+CONVERT(VARCHAR, CONVERT(INT, MBI.MBISizeW)), 2) + CONVERT(VARCHAR, CONVERT(INT, MBI.MBISizeH)) like  '%' + @SizeCode + '%') -- Condition modify (using index)
		   AND ((@DecisionResult = '*') OR (MQI.DecisionResult  = @DecisionResult))    -- 이미정님 요청 (2021.04.30, kilee)


		--   and mqi.BasicDate < (case when MQI.MaterialCode in ('ECVT27-213',
		--									'ECVT30-197',
		--									'ECVT30-204',
		--									'ECVT30-098',
		--									'ECVT30-116',
		--									'ECVT25-099',
		--									'VSECVT30-098',
		--									'ECVT27-385',
		--									'ECVT30-294',
		--									'RE3000-086') then '2022-01-01' else convert(varchar(10),dateadd(day,1,getdate()),120) end)										
		--union all 
		--	SELECT  [colu1]
	 --     ,[colu2]
	 --     ,[colu3]
	 --     ,[colu4]
	 --     ,[colu5]
	 --     ,[colu6]
	 --     ,[colu7]
	 --     ,[colu8]
	 --     ,[colu9]
	 --     ,[colu10]
	 --     ,[colu11]
	 --     ,[colu12]
	 --     ,[colu13]
	 --     ,[colu14]
	 --     ,[colu15]
	 --     ,[colu16]
	 --     ,[colu17]
	 --     ,[colu18]
	 --     ,[colu19]
	 --     ,[colu20]
	 --     ,[colu21]
	 --     ,[colu22]
	 -- FROM [SmartFactoryV2].[dbo].[stb_vvt_oqc_2022]
	 --   where colu1 BETWEEN @FromDate AND @ToDate
		--and @SizeCode='*' or @SizeCode='3562'

	  )

	  select *
	    from mqi
	   ORDER BY BasicDate, ProdQcNo, QcInspectionItemName, MaterialQcSampleNo
  END

  


END
