-- =============================================
-- Author : Kangs(kilee@vina.co.kr)
-- Group : 품질관리 > [c390 부적합보고서] > 파워BI용
-- Browsable : true
-- Create date : 2019-10-28
-- Description : 
-- Modified : 
-- Exec [usp_QcDefectReport_PowerBI_get] '2020-10-01','2020-10-30'
-- =============================================
CREATE PROCEDURE [dbo].[usp_QcDefectReport_PowerBI_get]  
						@pFromDate DATETIME,
						@pToDate DATETIME
AS
BEGIN
	Declare @FromDate DATETIME = CONVERT(VARCHAR(10), @pFromDate, 121) + ' 08:30:00'
	       ,@ToDate DATETIME = CONVERT(VARCHAR(10), DATEADD(day, 1, @pToDate), 121) + ' 08:30:00'

	IF @FromDate = '1900-01-01 08:30:00' BEGIN
		SET @FromDate = dbo.fnGetAggregationPeriod(1)
		SET @ToDate = dbo.fnGetAggregationPeriod(2)
	END

	SELECT QDR.DefectReportNo AS 부적합번호
		  ,QDR.DefectDivisionCode  AS 발행부서코드
		  ,BC1.Description  AS 발행부서명                     --AS DefectDivisionName 
		  ,QDR.PublishDeptCode AS 수신처코드
		  ,isnull(BC2.Description,isnull((select top 1 Description from [SmartFramework].[dbo].[STB_BaseCode] 
											where ItemCode=QDR.PublishDeptCode and CodeGroup='PublishDeptCode'),QDR.PublishDeptCode) ) AS 수신처명 --PublishDeptName
		  ,QDR.PublishEmpID AS 작성자ID
		  ,isnull(EI1.EmployeeName,isnull((select top 1 WorkerName from [SmartFactoryV2].[dbo].[STB_ProdWorkerInfo] 
											where WorkerCode=QDR.PublishEmpID),QDR.PublishEmpID) ) AS 작성자명  --PublishEmpName 
		  ,QDR.ReceiveDeptCode AS 발생코드
		  ,BC3.Description  AS 발생코드명         --AS ReceiveDeptName 
		  ,BC4.Description  AS 발생공정명       -- AS OccurProcessName
		  ,QDR.MachineCode AS 발생설비코드
		  ,MM.MachineName AS 발생설비명
		  ,QDR.ProdWorkerCode  AS 작업자코드
		  ,isnull(EI2.EmployeeName,isnull((select top 1 WorkerName from [SmartFactoryV2].[dbo].[STB_ProdWorkerInfo] 
											where WorkerCode=QDR.ProdWorkerCode),QDR.ProdWorkerCode) ) AS 작업자명   --ProdWorkerName
		  ,QDR.JobDate  AS 작업일자
		  ,QDR.LotNo  AS LotNo
		  ,QDR.MaterialCode AS 품목코드
		  ,QDR.MaterialName AS 품목명
		  ,QDR.MaterialSpec AS 규격
		  ,QDR.LotNo2 AS LotNo2
		  ,QDR.LotNo3 AS LotNo3
		  ,QDR.LotNo4 AS LotNo4
		  ,QDR.LotNo5 AS  LotNo5
		  ,QDR.DefectCode AS 부적합코드
		  ,DI.BasicDefectName AS 부적합명  --DefectName
		  ,QDR.DefectLotSize AS Lot수량
		  ,QDR.DefectErrorCnt AS 불량수량
		  ,QDR.DefectSampleCnt AS 샘플검사수량
		  ,QDR.LotLimitCnt AS LotLimitCnt
		  ,QDR.ActionContent AS 조치사항
		  ,QDR.ActionWorkerCode  AS 조치자ID
		  ,isnull(EI3.EmployeeName,isnull((select top 1 WorkerName from [SmartFactoryV2].[dbo].[STB_ProdWorkerInfo] 
											where WorkerCode=QDR.ActionWorkerCode),QDR.ActionWorkerCode) ) AS 조치자명  -- ActionWorkerName 
		  ,QDR.QcOpinionContent   as 품질부서의견
		  ,QDR.IsCustomerSendRequired as 고객송부의견
		  ,QDR.ProdCauseContent as 생산부문원인분석
		  ,QDR.ProdMeasuresContent  as 생산부문대책수립
		  ,QDR.ProdProcessContent as 생산부문처리결과
		  ,QDR.ProdProcessResultCode as 생산부문처리결과코드
		  ,BC5.Description AS  생산부문처리결과명    --ProdProcessResultName 
		  ,QDR.LossCost as 폐기금액
		  ,QDR.ProdProcessContentAuthorUserName as 작성자명
		  ,QDR.ProdProcessContentCheckUserName as 확인자명
		  ,QDR.QcMeasuresContent as 품질부서대책검증
		  ,QDR.QcFlwupCheckContent as 품질부서사후관리내용
		  ,QDR.IsQcAsSatisfaction as 사후관리만족
		  ,QDR.IsProdHeadConfirm as 생산부문장결재
		  ,QDR.ProdHeadComment as  생산부문장코멘트
		  ,QDR.IsQcHeadConfirm as 품질부문장결재
		  ,QDR.QcHeadComment as  품질부문장코멘트
		  ,QDR.CreateDateTime as 생성일자
		  ,QDR.CreateUserID as 정보생성일시
		  ,QDR.ProdProcessResultFile as 생산부문처리결과파일
		  ,AFM.[FileName]
		  ,AFM.FileSize 
		  ,CONVERT(VARBINARY(MAX),NULL) AS FileData
		  , QDR.ApprovalStepID as 진행스텝코드
		  , Case When QDR.ApprovalStepID = 1 THEN '생산부문장반려'
		           When QDR.ApprovalStepID = 2 THEN '생산부문장승인'
				   When QDR.ApprovalStepID = 3 THEN '품질부문장반려'
				   When QDR.ApprovalStepID = 4 THEN '품질부문장승인'
				   When QDR.ApprovalStepID = 5 THEN '공장장반려'
				   When QDR.ApprovalStepID = 6 THEN '공장장승인' ELSE '대책서_작성단계' END AS 진행단계   --ApprovalStep
	  FROM STB_QcDefectReport QDR
	  LEFT OUTER JOIN SmartFramework.dbo.STB_BaseCode BC1	    ON QDR.DefectDivisionCode = BC1.ItemCode	   AND BC1.CodeGroup = 'DefectDivisionCode'
	  LEFT OUTER JOIN SmartFramework.dbo.STB_BaseCode BC2	    ON QDR.PublishDeptCode = BC2.ItemCode	   AND BC2.CodeGroup = 'PublishDeptCode'
	   LEFT OUTER JOIN SmartFactoryIncubator.dbo.VW_EmployeeInfo EI1	     ON QDR.PublishEmpID = EI1.EmployeeNo
	   LEFT OUTER JOIN SmartFramework.dbo.STB_BaseCode BC3	    ON QDR.ReceiveDeptCode = BC3.ItemCode	   AND BC3.CodeGroup = 'ReceiveDeptCode'
	  LEFT OUTER JOIN SmartFramework.dbo.STB_BaseCode BC4	    ON QDR.OccurProcessCode = BC4.ItemCode	   AND BC4.CodeGroup = 'OccurProcessCode'
	  LEFT OUTER JOIN STB_MachineMaster MM	    ON QDR.MachineCode = MM.MachineCode
	  LEFT OUTER JOIN SmartFactoryIncubator.dbo.VW_EmployeeInfo EI2	    ON QDR.ProdWorkerCode = EI2.EmployeeNo
      LEFT OUTER JOIN STB_DefectInfo DI	    ON QDR.DefectCode = DI.DefectCode
	  LEFT OUTER JOIN SmartFactoryIncubator.dbo.VW_EmployeeInfo EI3	    ON QDR.ActionWorkerCode = EI3.EmployeeNo
	  LEFT OUTER JOIN SmartFramework.dbo.STB_BaseCode BC5	    ON QDR.ProdProcessResultCode = BC5.ItemCode	   AND BC5.CodeGroup = 'ProdProcessResultCode'
	  LEFT OUTER JOIN (SELECT DefectReportNo 
	                     FROM STB_QcDefectReportReInspectionResult 
						GROUP BY DefectReportNo
					  ) QDRRR
	    ON QDRRR.DefectReportNo = QDR.DefectReportNo
	  LEFT OUTER JOIN SmartFramework_File.dbo.STB_AttachedFileMaster AFM	    ON AFM.FileID = QDR.ProdProcessResultFile
	  LEFT OUTER JOIN STB_ApprovalLineInfo ALI	    ON ALI.ApprovalStepID = QDR.ApprovalStepID
	 WHERE 1=1 
	   AND QDR.CreateDateTime BETWEEN @FromDate AND @ToDate
	   AND QDR.DefectReportNo IN ('VN210327-01', 'VN210502-01', 'VN210610-01', 'VN210807-01', 'VN210916-04', 'VN210925-07', 'VN210925-08')
	 ORDER BY QDR.DefectReportNo
END