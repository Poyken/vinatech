-- =============================================
-- Author : Jackaroe(yjyu@vina.co.kr)
-- Group : 품질관리 > [C385] 부적합보고서 등록화면
-- Browsable : true
-- Create date : 2019-10-22
-- Description : 보고서 채번 로직 변경 Jackaroe #200609
--                   2021.02.19 발행부서 Fix
-- 프로시저실행 :  usp_QcDefectReportDummy_get 'kilee','Korean',''
-- =============================================
CREATE PROCEDURE [dbo].[usp_QcDefectReportDummy_get]
                                --usp_QcDefectIQCReport_get  : 비슷한 프로시저

    @pProcessUserID VARCHAR(20),
    @pProcessLanguage VARCHAR(20),
	@pDefectReportNo VARCHAR(20) = NULL
AS

BEGIN
	Declare @DefectReportNo VARCHAR(20) = @pDefectReportNo
	         , @DummyReportNo VARCHAR(20) = @pDefectReportNo

--if(@pDefectReportNo like 'VN240321-01')
--	begin
--		set @DefectReportNo = 'VN240723-02' 
--		set  @DummyReportNo = 'VN240723-02' 
--	end

--if(@pDefectReportNo like 'VN240408-03')
--	begin
--		set @DefectReportNo = 'VN240723-03' 
--		set  @DummyReportNo = 'VN240723-03' 
--	end
	-- #200609
	-- EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_QcDefectReport',@DefectReportNo OUTPUT 
	-- 자동채번 로직을 사용할 경우 자동증가하는 순번에 따라 빈 번호가 생길 수 있으므로 수동 채번 로직을 적용
	-- 신규번호이면, 더미를 쿼리하고, 그렇지 않으면 해당 번호를 쿼리한다.
	-- @DefectReportNo 채번의 경우 미리 채번을 할 경우 중복 및 업데이트 오류 발생 가능성이 있어 iud에서 채번하는 것으로 수정

	IF @DefectReportNo IS NULL BEGIN 
		-- @DefectReportNo 채번
		SELECT @DefectReportNo = 'Automatic Numbering'

		SET @DummyReportNo = 'VN999999-99'
	END
	
	SELECT 
		--CASE
		--	WHEN @pDefectReportNo like 'VN240320-01' THEN 'VN240320-01' 
		--	WHEN @pDefectReportNo like 'VN240408-03' THEN 'VN240408-03' 
			
		--	ELSE @DefectReportNo
		--END as DefectReportNo
	@DefectReportNo AS DefectReportNo
		  ,QDR.DefectDivisionCode
		  ,BC1.Description AS DefectDivisionName
		  ,QDR.PublishDeptCode
		  ,BC2.Description AS PublishDeptName
		  ,QDR.PublishEmpID
		  --,EI1.EmployeeName AS PublishEmpName
		  ,isnull(EI1.EmployeeName,isnull((select top 1 WorkerName from [SmartFactoryV2].[dbo].[STB_ProdWorkerInfo] 
											where WorkerCode=QDR.PublishEmpID),QDR.PublishEmpID) ) AS PublishEmpName
		   , QDR.ReceiveDeptCode    --원본
		-- , Case When QDR.PublishDeptCode = '4000' Then '2100 '
		--          When QDR.PublishDeptCode = '9000' Then '3100' Else Null  End As ReceiveDeptCode         -- 2021.02.19 변경
		  ,BC3.Description AS ReceiveDeptName
		  ,QDR.OccurProcessCode
		  ,BC4.Description AS OccurProcessName
		  ,QDR.MachineCode
		  ,MM.MachineName
		  ,QDR.ProdWorkerCode
		  --,EI2.EmployeeName AS ProdWorkerName
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
		  ,QDR.DefectImage
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
		  ,QDR.ProdCauseImage
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
		  ,CONVERT(BIT, 0) AS IsProdHeadConfirm
		  ,QDR.ProdHeadComment
		  ,CONVERT(BIT, 0) AS IsQcHeadConfirm
		  ,QDR.QcHeadComment,
		   QDR.NameVendor,
		   QDR.EmpNameVendor,
		   QDR.EmpNameVendor AS NameEmp
		  ,GETDATE() AS CreateDateTime
		  ,QDR.CreateUserID
		  ,QDR.ChangeDateTime
		  ,QDR.ChangeUserID
		  ,CONVERT(BIT, 0) AS IsReInspectionResult -- #200515
		  ,QDR.ProdProcessResultFile
		  ,AFM.[FileName]
		  ,AFM.FileSize
		  ,ISNULL(AFM.FileContents, CONVERT(VARBINARY(MAX),NULL)) AS FileData
		  ,QDR.VisualInspWorkerCode
		  ,EI4.EmployeeName AS VisualInspWorkerName
	  FROM STB_QcDefectReport QDR	  
	   LEFT OUTER JOIN SmartFramework.dbo.STB_BaseCode BC1	    ON QDR.DefectDivisionCode = BC1.ItemCode	   AND BC1.CodeGroup = 'DefectDivisionCode'
	   LEFT OUTER JOIN SmartFramework.dbo.STB_BaseCode BC2	    ON QDR.PublishDeptCode = BC2.ItemCode	   AND BC2.CodeGroup = 'PublishDeptCode'
	   LEFT OUTER JOIN SmartFactoryIncubator.dbo.VW_EmployeeInfo EI1	     ON QDR.PublishEmpID = EI1.EmployeeNo
	   LEFT OUTER JOIN SmartFramework.dbo.STB_BaseCode BC3	    ON QDR.ReceiveDeptCode = BC3.ItemCode	   AND BC3.CodeGroup = 'ReceiveDeptCode'
	   LEFT OUTER JOIN SmartFramework.dbo.STB_BaseCode BC4	    ON QDR.OccurProcessCode = BC4.ItemCode	   AND BC4.CodeGroup = 'OccurProcessCode'
	   LEFT OUTER JOIN STB_MachineMaster MM	                        ON QDR.MachineCode = MM.MachineCode
	   LEFT OUTER JOIN SmartFactoryIncubator.dbo.VW_EmployeeInfo EI2	    ON QDR.ProdWorkerCode = EI2.EmployeeNo
       LEFT OUTER JOIN STB_DefectInfo DI	                                ON QDR.DefectCode = DI.DefectCode
	   LEFT OUTER JOIN SmartFactoryIncubator.dbo.VW_EmployeeInfo EI3	    ON QDR.ActionWorkerCode = EI3.EmployeeNo
	   LEFT OUTER JOIN SmartFramework.dbo.STB_BaseCode BC5	    ON QDR.ProdProcessResultCode = BC5.ItemCode	   AND BC5.CodeGroup = 'ProdProcessResultCode'
	   LEFT OUTER JOIN (SELECT DefectReportNo 
	                     FROM STB_QcDefectReportReInspectionResult 
						GROUP BY DefectReportNo
					  ) QDRRR                                                	    ON QDRRR.DefectReportNo = QDR.DefectReportNo
	  LEFT OUTER JOIN SmartFramework_File.dbo.STB_AttachedFileMaster AFM	    ON AFM.FileID = QDR.ProdProcessResultFile
	  LEFT OUTER JOIN SmartFactoryIncubator.dbo.VW_EmployeeInfo EI4	    ON QDR.VisualInspWorkerCode = EI4.EmployeeNo
	 WHERE 1=1 
	   AND QDR.DefectReportNo = @DummyReportNo

END