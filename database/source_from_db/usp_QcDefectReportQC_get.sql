-- =============================================
-- Author : Jackaroe(yjyu@vina.co.kr)
-- Group : 품질관리 > PowerBI용 
-- Browsable : true
-- Create date : 2020-08-31
-- Description : 품질 최우석
-- Modified :

-- =============================================
CREATE PROCEDURE [dbo].[usp_QcDefectReportQC_get]
	@pFromDate DATETIME,
	@pToDate DATETIME
AS
BEGIN
	Declare @FromDate DATETIME = CONVERT(VARCHAR(10), @pFromDate, 121) + ' 08:30:00'
	       ,@ToDate DATETIME = CONVERT(VARCHAR(10), DATEADD(day, 1, @pToDate), 121) + ' 08:30:00'

	SELECT QDR.DefectReportNo AS 부적합보고서번호
		  ,QDR.DefectDivisionCode AS 부적합구분코드
		  ,BC1.Description AS 부적합구분명
		  ,QDR.PublishDeptCode AS 발행부서코드
		  ,isnull(BC2.Description,isnull((select top 1 Description from [SmartFramework].[dbo].[STB_BaseCode] 
											where ItemCode=QDR.PublishDeptCode and CodeGroup='PublishDeptCode'),QDR.PublishDeptCode) ) AS 발행부서명
		  ,QDR.PublishEmpID AS 발행자사번
		  ,isnull(EI1.EmployeeName,isnull((select WorkerName from [SmartFactoryV2].[dbo].[STB_ProdWorkerInfo] 
											where WorkerCode=QDR.ActionWorkerCode),QDR.ActionWorkerCode) ) AS 발행자명
		  ,QDR.ReceiveDeptCode AS 수신부서코드
		  ,BC3.Description AS 수신부서명
		  ,QDR.OccurProcessCode AS 발생공정코드
		  ,BC4.Description AS 발생공정명
		  ,QDR.MachineCode AS 설비코드
		  ,MM.MachineName AS 설비명
		  ,QDR.ProdWorkerCode AS 작업자사번
		  ,isnull(EI2.EmployeeName,isnull((select WorkerName from [SmartFactoryV2].[dbo].[STB_ProdWorkerInfo] 
											where WorkerCode=QDR.ActionWorkerCode),QDR.ActionWorkerCode) ) AS 작업자명
		  ,QDR.JobDate AS 작업일자
		  ,QDR.LotNo AS LotNo
		  ,QDR.MaterialCode AS 품목코드
		  ,QDR.MaterialName AS 품목명
		  ,QDR.MaterialSpec AS 품목스펙
		  ,QDR.LotNo2 AS LotNo2
		  ,QDR.LotNo3 AS LotNo3
		  ,QDR.LotNo4 AS LotNo4
		  ,QDR.LotNo5 AS LotNo5
		  ,QDR.DefectCode AS 부적합코드
		  ,DI.BasicDefectName AS 부적합명
		  ,QDR.DefectLotSize AS Lot수량
		  ,QDR.DefectErrorCnt AS 불량수량
		  ,QDR.DefectSampleCnt AS 시료수
		  ,QDR.ActionContent AS 조치사항
		  ,QDR.ActionWorkerCode AS 조치자사번
		  ,EI3.EmployeeName AS 조치자명
		  ,QDR.QcOpinionContent AS 품질부서의견
		  ,QDR.IsCustomerSendRequired AS 고객송부필요여부
		  ,QDR.ProdCauseContent AS 생산원인분석
		  ,QDR.ProdMeasuresContent AS 생산부문대책수립
		  ,QDR.ProdProcessContent AS 생산부문처리결과
		  ,QDR.ProdProcessResultCode AS 생산부문처리결과코드
		  ,BC5.Description AS 생산부문처리결과명
		  ,QDR.LossCost AS 폐기금액
		  ,QDR.ProdProcessContentAuthorUserName AS 작성자명
		  ,QDR.ProdProcessContentCheckUserName AS 확인자명
		  ,QDR.QcMeasuresContent AS 품질부서대책검증
		  ,QDR.QcFlwupCheckContent AS 품질부서사후관리내용
		  ,QDR.IsQcAsSatisfaction AS 사후관리만족여부
		  ,QDR.IsProdHeadConfirm AS 생산부문장결재여부
		  ,QDR.ProdHeadComment AS 생산부문장코멘트
		  ,QDR.IsQcHeadConfirm AS 품질부문장결재여부
		  ,QDR.QcHeadComment AS 품질부문장코멘트
		  ,CASE WHEN ISNULL(QDRRR.DefectReportNo, '') = '' 
		        THEN CONVERT(BIT, 0) 
				ELSE CONVERT(BIT, 1) END AS 재검여부 -- #200515
		  ,QDR.CreateDateTime AS 등록일시
		  ,QDR.DefectImageUrl AS 이미지URL
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
	  AND QDR.DefectReportNo IN ('VN210327-01', 'VN210502-01', 'VN210610-01', 'VN210807-01', 'VN210916-04', 'VN210925-07', 'VN210925-08')
	 WHERE 1=1 
	   AND QDR.CreateDateTime BETWEEN @FromDate AND @ToDate
	 ORDER BY QDR.DefectReportNo
END