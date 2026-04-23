
-- =============================================
-- Author: Lim Dong Seon(dsim@awoo.co.kr)
-- Create date: 2016-09-29
-- Browsable : true
-- Group : 수입검사 > 시료별수입검사 Tab- 3
-- Description:	시료별 수입검사 "부적합보고서" Report
-- Modified:  
-- 2020.12.04 검토자, 결재자 수정 (박진호 요청)

-- 품질부적합 test  : exec usp_GetMaterialQcInfo_ForReport @pProcessUserID='kilee',@pProcessLanguage='Korean',@pMaterialQcNo='20071300002'
--                         exec usp_GetMaterialQcInfo_ForReport @pProcessUserID='kilee',@pProcessLanguage='Korean',@pMaterialQcNo='20101900005'
-- =============================================
CREATE PROCEDURE [dbo].[usp_GetMaterialQcInfo_ForReport]
					@pProcessUserID VARCHAR(20),
					@pProcessLanguage VARCHAR(20),
					@pMaterialQcNo VARCHAR(20) = NULL
AS

BEGIN

	SET NOCOUNT ON;

	DECLARE @MaterialQcNo VARCHAR(20) = @pMaterialQcNo

	SELECT
			MQI.MaterialQcNo AS OldMaterialIqcNo,
			MQI.MaterialQcNo,
			Case	When ISNULL(MQI.DecisionResult,'') = 'P' Then '합격' 
			        When ISNULL(MQI.DecisionResult,'') = 'F' Then '불합격'	  Else '미검'	  End  AS DecisionResultText,
			MQI.QcQty                                                As QcQty,                                             -- 레포트화면에서 "Lot크기" 입고수
			MQI.InspectionType,
			MQI.TargetSampleQty,
			MQI.ActualSampleQty,			
			--Case When MQI.ActualSampleQty = 0 Then 0 
			--       When MQI.DefectSampleQty = 0 Then 0 
			--        Else  (MQI.DefectSampleQty / MQI.ActualSampleQty * 100) End  As DefectiveRate,   -- 레포트화면에서 "시료수" (불량수/시료수 * 백만) : 박진호요청 (2020-10-05 요청)
			MQI.DestoryInspectionQty,
			MQI.ProcessQty,
			MQI.MaxAcceptDefectQty,
			MQI.PassedSampleQty,
			MQI.DefectSampleQty,
			MQI.DecisionResult,
			MQI.DecisionDateTime,
			MQI.DecisionUserID,
			PW.UserName,
			MQI.SpecialAcceptDesc,
			MQI.DescText,
			MQI.VendorQcReport,								
			MDI.SourceCustomerCode,
	        C.CustomerName,
	        C.CustomerNameL,
			MQI.MaterialCode,  --품번
			MM.MaterialName,
			MM.MaterialSpec,   
			--MQI.CreateDateTime,
			Substring(Convert(Varchar, MQI.CreateDateTime), 1, 12) AS CreateDateTime,
			MQI.CreateUserID,
			PW.UserName                                                       AS UserName,             -- 2020.07.16추가
			--MQI.ChangeDateTime,                                                                         -- 원본백업
			CONVERT(VARCHAR(10), MQI.ChangeDateTime, 121)      AS  ChangeDateTime,  -- 수정
			CONVERT(VARCHAR(10), MQI.ChangeDateTime+7, 121 )  AS  ReplyDate,           -- 수정
			MQI.ChangeUserID,
			MVM.InspectionType AS MasterInspectionType,
			MVM.AQL               AS MasterAQL,
			MVM.InspectionLevel AS MasterInspectionLevel
--			, MDD.MaterialIqcNo
           , MQI.MIIExtText04   -- 원본불량율
		
		   --, Isnull((MQI.DefectSampleQty / MQI.QcQty * 100), 0) as DefectiveRate  -- 불량율 박진호요청

		   , SIR.DefectReportNo        AS DefectReportNo
		   , SIR.DefectDivisionCode
		   , BC1.Description             AS DefectDivisionName  -- 부적합명
		   , SIR.PublishDeptCode
		   , BC2.Description             AS PublishDeptName   --부적합발행부서명
		   , SIR.PublishDeptCode
		   , SIR.LotNo 
		   , SIR.CorrectiveActionCode  AS CorrectiveActionCode
		   , BC3.Description               AS CorrectiveActionName   --시정조치여부명
		   , SIR.ProdProcessResultCode  AS ProdProcessResultCode
		   , BC5.Description                 AS ProdProcessName    --생산부문처리결과  (재작업, 특채 등)
		   , SIR.DefectImage  
		   , SIR.DefectImage2
		   , SIR.Nonconformity
		   , SIR.ImmediateAction
		   , SIR.CauseInvestigation
		   , SIR.PreventionRecurrence
		   , SIR.DetectionCounterMeasures 		   
		   , SIR.CheckingCorrectiveAction   --시정조치확인
		   , SIR.Validation   --제품유효성확인
		   , MQI.DescText AS LotNo
		   , MQI.IQCSampleLotList  AS IQCSampleLotList    --검사 Lot NO
		   , PG.ProductGroupName AS ProductGroupName            
		  -- , Case When MQI.MIIExtText04 =0 then 0 when MDD.LotNoQty = 0         then 0 	else CONVERT(BIGINT, ( CONVERT(NUMERIC(20,5), MQI.MIIExtText04) / CONVERT(NUMERIC(20,5), MDD.LotNoQty)  * 100))  end as DefectiveRate   -- Lot불량율(%) 원본백업 (박진호)
		   , Case when  MQI.DefectSampleQty = 0 then 0 when MQI.ActualSampleQty = 0   then 0 else CONVERT(BIGINT, ( CONVERT(NUMERIC(20,5), MQI.DefectSampleQty) / CONVERT(NUMERIC(20,5), MQI.ActualSampleQty)  * 100))    End as DefectiveRate   -- Lot불량율(%) 박진호요청 (2020.12.09)
		   , Case When	BC2.Description = '품질부문'          Then '' 
		           When	BC2.Description = '베트남품질부문' Then 'Mr.Tung'  Else '' End  Reviewer
		   , Case When	BC2.Description = '품질부문' Then '이미정'  
		            When	BC2.Description = '베트남품질부문' Then 'Je-Sik Eom'  Else '' End  Approver
	FROM
			STB_MaterialQcInfo MQI WITH(NOLOCK)
			--LEFT OUTER JOIN STB_MaterialQcDetail MQD  WITH(NOLOCK)				ON MQD.MaterialQcNo = MQI.MaterialQcNo
			--LEFT OUTER JOIN STB_MaterialDocDetail MDD WITH(NOLOCK)				ON MDD.MaterialIqcNo = MQI.MaterialQcNo
			LEFT OUTER JOIN (
										 SELECT DISTINCT MDD.MaterialDocNo as MaterialDocNo,
																MDD.MaterialIqcNo as MaterialIqcNo ,
																Count(MDLI.LotNo)	as LotNoQty            -- 2020-09-06 추가 	
											FROM
													                 STB_MaterialDocDetail MDD WITH(NOLOCK)
													INNER JOIN STB_MaterialQcInfo MQI WITH(NOLOCK)		 ON MQI.MaterialQcNo = MDD.MaterialIqcNo
													INNER JOIN STB_MaterialDocInfo MDI WITH(NOLOCK)		 ON MDI.MaterialDocNo = MDD.MaterialDocNo
													INNER JOIN STB_MaterialDocLotInfo MDLI WITH(NOLOCK) ON MDLI.MaterialDocNo = MDD.MaterialDocNo   And MDLI.MaterialDocDetailNo = MDD.MaterialDocDetailNo      -- 2020.09.06 추가
											WHERE 1=1
													--MQI.InspectionDocType LIKE @InspectionDocType 
													--AND	(MQI.DecisionResult LIKE @DecisionResult) 
													--AND	(MQI.MaterialCode LIKE @MaterialCode) 
													--AND	(MDI.MaterialDocNo LIKE @MaterialDeliveryNo) 
													--AND	(MDI.SourceCustomerCode LIKE @CustomerCode) 
													--AND	(MQI.BasicDate BETWEEN @FromDate AND @ToDate)
											Group by MDD.MaterialDocNo,	MDD.MaterialIqcNo                            
									) MDD				                                    ON MDD.MaterialIqcNo = MQI.MaterialQcNo

			LEFT OUTER JOIN STB_MaterialDocInfo MDI WITH(NOLOCK)				ON MDI.MaterialDocNo = MDD.MaterialDocNo
			LEFT OUTER JOIN STB_CustomerInfo C WITH(NOLOCK)				ON MDI.SourceCustomerCode = C.CustomerCode
			LEFT OUTER JOIN STB_MaterialMaster MM WITH(NOLOCK)				ON MQI.MaterialCode = MM.MaterialCode
			LEFT OUTER JOIN STB_ProductGroup PG WITH(NOLOCK)			ON MM.ProductGroupCode = PG.ProductGroupCode  --2020.10.05 추가
			LEFT OUTER JOIN [SmartFramework].[dbo].[STB_UserInfo] PW WITH (NOLOCK)				ON PW.UserID = CASE WHEN ISNULL(MQI.DecisionUserID,'') = '' THEN @pProcessUserID ELSE MQI.DecisionUserID END
			LEFT OUTER JOIN STB_MaterialVendorMapping MVM WITH(NOLOCK)				ON MVM.MaterialCode = MM.MaterialCode
			LEFT OUTER JOIN STB_IQcDefectReport SIR WITH(NOLOCK)				ON SIR.LotNo = MQI.IQCSampleLotList              -- 부적합등록화면부분 2020.07.15 추가
			LEFT OUTER JOIN SmartFramework.dbo.STB_BaseCode BC1	ON SIR.DefectDivisionCode = BC1.ItemCode	   AND BC1.CodeGroup = 'DefectDivisionCode'
		   LEFT OUTER JOIN SmartFramework.dbo.STB_BaseCode BC2	    ON SIR.PublishDeptCode = BC2.ItemCode	       AND BC2.CodeGroup = 'PublishDeptCode'	                -- 부적합발행부서
		   LEFT OUTER JOIN SmartFramework.dbo.STB_BaseCode BC3	    ON SIR.CorrectiveActionCode = BC3.ItemCode   AND BC3.CodeGroup = 'CorrectiveActionCode'
		-- LEFT OUTER JOIN SmartFramework.dbo.STB_BaseCode BC4	ON SIR.OccurProcessCode = BC4.ItemCode	   AND BC4.CodeGroup = 'OccurProcessCode'	        -- 발생공정
		   LEFT OUTER JOIN SmartFramework.dbo.STB_BaseCode BC5	    ON SIR.ProdProcessResultCode = BC5.ItemCode AND BC5.CodeGroup = 'ProdProcessResultCode'  -- 생산부문처리결과코드
	WHERE	1=1	  
	   AND MQI.MaterialQcNo = @MaterialQcNo
		--and (mqi.DecisionDateTime<'2022-01-01'   --Mr.Tung Audit 2245 on 24-March-2023
		--or  SIR.defectreportno in (
		--	'VVNI220119-01',
		--	'VVNI220318-01',
		--	'VVNI220729-01'
		--	)
	 --   )

	--ORDER BY 			ItemReportPrior ASC

END