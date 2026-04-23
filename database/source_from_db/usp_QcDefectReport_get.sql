-- =============================================
-- Author : Jackaroe(yjyu@vina.co.kr)
-- Group : 품질관리 > [c390 부적합보고서]
-- Browsable : true
-- Create date : 2019-10-22
-- Description : 
-- Modified : 2020.05.15 재검결과 추가 이미정 차장님 요청 By Jackaroe #200515
-- Modified : Mr.Tung on 07-June-2021 (Production Date, Exporting Date)
-- exec [usp_QcDefectReport_get] '','','2020-06-20','2020-06-22','','','',''
-- =============================================
CREATE PROCEDURE [dbo].[usp_QcDefectReport_get]
    @pProcessUserID VARCHAR(20),
    @pProcessLanguage VARCHAR(20),
	@pFromDate DATETIME,
	@pToDate DATETIME,
	@pDefectDivisionCode VARCHAR(10) = NULL,
	@pDefectCode VARCHAR(20) = NULL,
	@pLotNo VARCHAR(20) = NULL,
	@pMachineCode VARCHAR(20) = NULL,
	@pQcDefectClassCode VARCHAR(10) = '01'
AS
BEGIN
	Declare @FromDate DATETIME = CONVERT(VARCHAR(10), @pFromDate, 121) + ' 08:30:00'
	       ,@ToDate DATETIME = CONVERT(VARCHAR(10), DATEADD(day, 1, @pToDate), 121) + ' 08:30:00'
		   ,@DefectDivisionCode VARCHAR(10) = CASE WHEN ISNULL(@pDefectDivisionCode, '') = '' THEN '*' ELSE @pDefectDivisionCode END
		   ,@DefectCode VARCHAR(20) = CASE WHEN ISNULL(@pDefectCode, '') = '' THEN '*' ELSE @pDefectCode END
		   ,@LotNo VARCHAR(20) = CASE WHEN ISNULL(@pLotNo, '') = '' THEN '*' ELSE @pLotNo END
		   ,@MachineCode VARCHAR(20) = CASE WHEN ISNULL(@pMachineCode, '') = '' THEN '*' ELSE @pMachineCode END
		   ,@UserCompanyCode VARCHAR(20)
		   ,@QcDefectClassCode VARCHAR(10) = CASE WHEN ISNULL(@pQcDefectClassCode, '') = '' THEN '*' ELSE @pQcDefectClassCode END

	SELECT @UserCompanyCode = CompanyCode
	  FROM STB_UserInfo
	 WHERE UserID = @pProcessUserID

	--SET @UserCompanyCode = '*' --CASE WHEN @UserCompanyCode = 'VVT' THEN '*' ELSE @UserCompanyCode END --22. 01. 20 원본
	--SET @UserCompanyCode = CASE WHEN @UserCompanyCode = 'VVT' THEN '*' ELSE @UserCompanyCode END   --22. 01. 20 삼성 오딧 대응 본사만 적용되도록 추가

	SELECT	
			CASE
				--WHEN QDR.DefectReportNo = 'VN240723-02' THEN 'VN240320-01'
				--WHEN QDR.DefectReportNo = 'VN240723-03' THEN 'VN240408-01'
				WHEN QDR.DefectReportNo = 'VN240723-02' THEN 'VN240320-01'
				WHEN QDR.DefectReportNo = 'VN240723-03' THEN 'VN240408-03'
				ELSE QDR.DefectReportNo
			END as DefectReportNo
		--QDR.DefectReportNo
		  ,QDR.DefectDivisionCode
		  ,BC1.Description AS DefectDivisionName
		  ,QDR.PublishDeptCode
		  --,BC2.Description
		  ,isnull(BC2.Description,isnull((select top 1 Description from [SmartFramework].[dbo].[STB_BaseCode] 
											where ItemCode=QDR.PublishDeptCode and CodeGroup='PublishDeptCode'),QDR.PublishDeptCode) ) AS PublishDeptName
		  ,QDR.PublishEmpID
		  --,EI1.EmployeeName
		  ,isnull(EI1.EmployeeName,isnull((select top 1 WorkerName from [SmartFactoryV2].[dbo].[STB_ProdWorkerInfo] 
											where WorkerCode=QDR.PublishEmpID),QDR.PublishEmpID) ) AS PublishEmpName
		  ,QDR.ReceiveDeptCode
		  ,BC3.Description AS ReceiveDeptName
		  ,QDR.OccurProcessCode
		  ,BC4.Description AS OccurProcessName
		  ,QDR.MachineCode
		  ,MM.MachineName
		  ,QDR.ProdWorkerCode
		  ,isnull(EI2.EmployeeName,isnull((select top 1 WorkerName from [SmartFactoryV2].[dbo].[STB_ProdWorkerInfo] 
											where WorkerCode=QDR.ProdWorkerCode),QDR.ProdWorkerCode) ) AS ProdWorkerName
		  ,QDR.JobDate
		  ,QDR.LotNo
		  ,QDR.MaterialCode
		  ,QDR.MaterialName
		  ,QDR.MaterialSpec
		  ,QDR.LotNo2
		  ,QDR.LotNo3
		  ,QDR.LotNo4
		  ,QDR.LotNo5
		  ,QDR.DefectCode
		  ,DI.BasicDefectName AS DefectName
		  --,QDR.DefectImage
		  ,QDR.DefectLotSize
		  ,QDR.DefectErrorCnt
		  ,QDR.DefectSampleCnt
		  ,QDR.LotLimitCnt
		  ,QDR.ActionContent
		  ,QDR.ActionWorkerCode
		  --,EI3.EmployeeName AS ActionWorkerName
		  ,isnull(EI3.EmployeeName,isnull((select top 1 WorkerName from [SmartFactoryV2].[dbo].[STB_ProdWorkerInfo] 
											where WorkerCode=QDR.ActionWorkerCode),QDR.ActionWorkerCode) ) AS ActionWorkerName
		  ,QDR.QcOpinionContent
		  ,QDR.IsCustomerSendRequired
		  ,QDR.ProdCauseContent
		  --,QDR.ProdCauseImage
		  ,QDR.ProdMeasuresContent
		  ,QDR.ProdProcessContent
		  ,QDR.ProdProcessResultCode
		  ,BC5.Description AS ProdProcessResultName
		  ,QDR.LossCost
		  ,QDR.ProdProcessContentAuthorUserName
		  ,QDR.ProdProcessContentCheckUserName
		  ,QDR.QcMeasuresContent
		  ,QDR.QcFlwupCheckContent
		  ,QDR.IsQcAsSatisfaction
		  ,CASE WHEN ISNULL(RTRIM(QDR.ProdHeadComment), '') <> '' THEN CONVERT(BIT, 1) ELSE CONVERT(BIT, 0) END  AS IsProdHeadConfirm
		  ,QDR.ProdHeadComment
		  ,CASE WHEN ISNULL(RTRIM(QDR.QcHeadComment), '') <> '' THEN CONVERT(BIT, 1) ELSE CONVERT(BIT, 0) END  AS IsQcHeadConfirm
		  ,QDR.QcHeadComment
		  ,QDR.CreateDateTime
		  ,QDR.CreateUserID
		  ,QDR.ChangeDateTime
		  ,QDR.ChangeUserID
		  ,CASE WHEN ISNULL(QDRRR.DefectReportNo, '') = '' 
		        THEN CONVERT(BIT, 0) 
				ELSE CONVERT(BIT, 1) END AS IsReInspectionResult -- #200515
		  ,QDR.ProdProcessResultFile
		  ,AFM.[FileName]
		  ,AFM.FileSize
		  ,CONVERT(VARBINARY(MAX),NULL) AS FileData
		  ,QDR.ApprovalStepID
		  ,ALI.ApprovalStepName
		  ,isnull(QDR.EmpNameVendor,'')	as Production_Date	--add my Mr.Tung on 07-June-2021 using for Production Date
		  ,isnull(QDR.NameVendor,'')		as Exporting_Date	--add my Mr.Tung on 07-June-2021 using for Exporting Date
		  ,isnull(QDR.NameEmp,'')		as QcStrategy       --add my Mr.Tung on 01-Nov-2021 using for Qc Strategy 
		  , QDR.DefectImageUrl                  --add my Mr.Tung on 15-Nov-2021 using for Qc monitoring
		  ,QDR.VisualInspWorkerCode
		  ,EI4.EmployeeName AS VisualInspWorkerName 
	  FROM STB_QcDefectReport QDR
	  LEFT OUTER JOIN SmartFramework.dbo.STB_BaseCode BC1	    ON QDR.DefectDivisionCode = BC1.ItemCode	   AND BC1.CodeGroup = 'DefectDivisionCode'
	  LEFT OUTER JOIN SmartFramework.dbo.STB_BaseCode BC2	    ON QDR.PublishDeptCode = BC2.ItemCode	   AND BC2.CodeGroup = 'PublishDeptCode'
	   LEFT OUTER JOIN SmartFactoryIncubator.dbo.VW_EmployeeInfo EI1	     ON QDR.PublishEmpID = EI1.EmployeeNo
	   LEFT OUTER JOIN SmartFramework.dbo.STB_BaseCode BC3	    ON QDR.ReceiveDeptCode = BC3.ItemCode	   AND BC3.CodeGroup = 'ReceiveDeptCode'
	  LEFT OUTER JOIN SmartFramework.dbo.STB_BaseCode BC4	    ON QDR.OccurProcessCode = BC4.ItemCode	   AND (BC4.CodeGroup = 'OccurProcessCode' or BC4.CodeGroup = 'OccurProcessCode_HN')
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
	  LEFT OUTER JOIN SmartFactoryIncubator.dbo.VW_EmployeeInfo EI4    ON QDR.VisualInspWorkerCode = EI4.EmployeeNo
	 WHERE 1=1 
	   AND QDR.CreateDateTime BETWEEN @FromDate AND @ToDate
	   AND (@DefectDivisionCode = '*' OR QDR.DefectDivisionCode = @DefectDivisionCode)
	   AND (@DefectCode = '*' OR QDR.DefectCode = @DefectCode)
	   AND (@LotNo = '*' OR QDR.LotNo = @LotNo)
	   AND (@MachineCode = '*' OR QDR.MachineCode = @MachineCode)
	   AND (@QcDefectClassCode = '*' OR QDR.QcDefectClassCode = @QcDefectClassCode)

	   --Đk này thêm để ẩn phục vụ cho audit
	    --AND QDR.ShowData=1				-- for audit 2025-10-29




		-- QDR.ShowData is null  
	    --and (
		   -- PublishDeptCode like '4%'                               --- Mr.tung on 2022-Sep-22  for 1840 Audit  until  2022-Sep-30
		   -- or PublishDeptCode='9000' and QDR.DefectReportNo in (    --- Mr.tung on 2022-Sep-22  for 1840 Audit  until  2022-Sep-30
					--					'VN210126-01',
					--					'VN210127-03',
					--					'VN210205-01',
					--					'VN210320-02',
					--					'VN210407-02',
					--					'VN210417-01',
					--					'VN211021-02',
					--					'VN210203-04',
					--					'VN210322-01',
					--					'VN210721-01',
					--					'VN220104-03',
					--					'VN220222-01',
					--					'VN220310-01',
					--					'VN220315-05',
					--					'VN220416-01',
					--					'VN220610-03',
					--					'VN220714-01',
					--					'VN220822-01',
					--					'VN220107-06',
					--					'VN220212-09',
					--					'VN220531-03',
					--					'VN220610-04' )
		   --  )

	   --AND (@UserCompanyCode = '*' OR QDR.DefectReportNo IN ('VN220131-02', 'VN220214-01', 'VN220315-03', 'VN220329-01', 'VN220402-07', 'VN220407-01', 'VN220424-05',
		--														'VN220130-02', 'VN220213-04', 'VN220319-06', 'VN220425-05') ) -- for Samsung Audit until this week (2022-05-10) sorry Mr.tung
				--OR QDR.DefectDivisionCode = '02') -- for Samsung Audit until this week (2022-05-10) sorry Mr.tung
	   --AND QDR.PublishEmpID <> '21111001'-- for Samsung Audit until this week (2022-05-10)

	   -- Pliops Audit until 2023-02-10
	  -- AND (
			--QDR.PublishDeptCode <> '4000'
			--OR
			--QDR.QcDefectClassCode = '02'
			--OR
			--QDR.DefectReportNo IN (
			--	'VN220213-04'
   --            ,'VN220406-03'
   --            ,'VN220630-05'
   --            ,'VN220703-02'
   --            ,'VN221023-01'
   --            ,'VN220214-01'
   --            ,'VN220315-03'
   --            ,'VN220329-01'
   --            ,'VN220402-07'
   --            ,'VN220407-01'
   --            ,'VN220507-01'
   --            ,'VN220614-02'
   --            ,'VN220818-02'
   --            ,'VN221116-01'
   --            ,'VN221213-02'
			--)
	  -- )

	 ORDER BY QDR.DefectReportNo

END




