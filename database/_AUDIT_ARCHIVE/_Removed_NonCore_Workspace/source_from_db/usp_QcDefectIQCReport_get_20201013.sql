-- =============================================
-- Author : kilee@vina.co.kr)
-- Group : 품질관리 >  [C220]시료별수입검사 > 수입검사_부적합등록 및 결재하는 화면 Tab2 
-- Browsable : true
-- Create date : 2020-07-10
-- Description : 

-- usp_QcDefectIQCReport_get 'kilee','Korean','VNI999999-99',''
-- usp_QcDefectIQCReport_get 'kilee','Korean','VNI200717-01','' 
-- =============================================

Create PROCEDURE [dbo].[usp_QcDefectIQCReport_get_20201013]
                               -- usp_QcDefectReportDummy_get  : 원본 프로시저 참조용
    @pProcessUserID VARCHAR(20),
    @pProcessLanguage VARCHAR(20),
	@pDefectReportNo VARCHAR(20) = NULL,
	@pLotNo VARCHAR(20) = null
AS

BEGIN
	Declare @DefectReportNo VARCHAR(20) = @pDefectReportNo
	          ,@DummyReportNo VARCHAR(20) = @pDefectReportNo
			 -- , @LotNo VARCHAR(20) = CASE WHEN ISNULL(@pLotNo,'') = '' THEN '%' ELSE @pLotNo END 
			  , @LotNo         VARCHAR(20) = CASE WHEN ISNULL(@pLotNo,'') = '' THEN '*' ELSE @pLotNo END
			 --  ,@LotNo VARCHAR(20) = @pLotNo
	-- #200609
	-- EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_QcDefectReport',@DefectReportNo OUTPUT 
	-- 자동채번 로직을 사용할 경우 자동증가하는 순번에 따라 빈 번호가 생길 수 있으므로 수동 채번 로직을 적용
	-- 신규번호이면, 더미를 쿼리하고, 그렇지 않으면 해당 번호를 쿼리한다.
	-- @DefectReportNo 채번의 경우 미리 채번을 할 경우 중복 및 업데이트 오류 발생 가능성이 있어 iud에서 채번하는 것으로 수정

	IF @DefectReportNo IS NULL  AND @LotNo IS NOT NULL
	
	BEGIN 
		-- @DefectReportNo 채번
		SELECT @DefectReportNo = 'Automatic Numbering'

		SET @DummyReportNo = 'VNI999999-99'
	END
	
	SELECT @DefectReportNo AS DefectReportNo
		  ,QDR.DefectDivisionCode
		  ,BC1.Description AS DefectDivisionName
		  ,QDR.PublishDeptCode
		  ,BC2.Description AS PublishDeptName
		  ,QDR.PublishEmpID
		  ,EI1.EmployeeName AS PublishEmpName
		--  ,QDR.ReceiveDeptCode
		  --,BC3.Description AS ReceiveDeptName
		  ,QDR.OccurProcessCode
		  ,BC4.Description AS OccurProcessName
		 -- ,QDR.MachineCode
		 
		 -- ,QDR.ProdWorkerCode
		 -- ,EI2.EmployeeName AS ProdWorkerName
		  ,QDR.JobDate
		  , Case when isnull(QDR.LotNo, '') = '' then @LotNo else QDR.LotNo end AS LotNo
		  --,QDR.MaterialCode
		  --,QDR.MaterialName
		  --,QDR.MaterialSpec
		  --,QDR.LotNo2
		  --,QDR.LotNo3
		  --,QDR.LotNo4
		  --,QDR.LotNo5
		  ,QDR.CorrectiveActionCode AS CorrectiveActionCode                   -- 시정조치여부코드
		  --,QDR.CorrectiveActionName AS CorrectiveActionName                 -- 시정조치여부명
		  ,BC6.Description AS CorrectiveActionName                                   -- 시정조치여부명
		  ,QDR.DefectImage
		  ,QDR.DefectImage2  
		  ,QDR.DefectLotSize		
		  ,QDR.ProdProcessResultCode                                        -- 생산부분 처리코드 (재작업, 특채 등)
		  ,BC5.Description AS ProdProcessResultName                    -- 생산부분 처리명 (코드테이블)		
		  ,CONVERT(BIT, 0) AS IsProdHeadConfirm		  
		  ,CONVERT(BIT, 0) AS IsQcHeadConfirm		  
		  ,GETDATE() AS CreateDateTime
		  ,QDR.CreateUserID
		  ,QDR.ChangeDateTime
		  ,QDR.ChangeUserID
		  ,CONVERT(BIT, 0) AS IsReInspectionResult -- #200515
		  ,QDR.ProdProcessResultFile
		  ,AFM.[FileName]
		  ,AFM.FileSize
		  ,ISNULL(AFM.FileContents, CONVERT(VARBINARY(MAX),NULL)) AS FileData
		  , QDR.Nonconformity  AS Nonconformity     --부적합내용
		  , QDR.ImmediateAction AS  ImmediateAction  --즉시조치
		  , QDR.CauseInvestigation AS  CauseInvestigation  --원인조사
		  , QDR.PreventionRecurrence AS  PreventionRecurrence  --재발방지조치
		  , QDR.DetectionCounterMeasures AS  DetectionCounterMeasures  --검출대책수립		  
		  , QDR.CheckingCorrectiveAction AS  CheckingCorrectiveAction  --시정조치확인
		  , QDR.Validation                     AS  Validation  --제품유효성확인
		  , QDR.IsActionCode  AS ActionCode   -- 시정조치여부

		  , QDR.QcOpinionContent AS QcOpinionContent    -- 품질부서의견
          , QDR.IsQcHeadConfirm AS IsQcHeadConfirm       -- 품질부문장결재
		  , CASE WHEN QDR.IsQcHeadConfirm  = 0 THEN  '결재취소'  WHEN QDR.IsQcHeadConfirm  = 1 THEN  '결재완료'  ELSE '미완료' END       AS Payment       -- 품질부문장결재
	  FROM STB_IQcDefectReport QDR
			  LEFT OUTER JOIN SmartFramework.dbo.STB_BaseCode BC1	    ON QDR.DefectDivisionCode = BC1.ItemCode	   AND BC1.CodeGroup = 'DefectDivisionCode'
			  LEFT OUTER JOIN SmartFramework.dbo.STB_BaseCode BC2	    ON QDR.PublishDeptCode = BC2.ItemCode	   AND BC2.CodeGroup = 'PublishDeptCode'
			   LEFT OUTER JOIN SmartFactoryIncubator.dbo.VW_EmployeeInfo EI1	     ON QDR.PublishEmpID = EI1.EmployeeNo
			   --LEFT OUTER JOIN SmartFramework.dbo.STB_BaseCode BC3	    ON QDR.ReceiveDeptCode = BC3.ItemCode	   AND BC3.CodeGroup = 'ReceiveDeptCode'
			  LEFT OUTER JOIN SmartFramework.dbo.STB_BaseCode BC4	    ON QDR.OccurProcessCode = BC4.ItemCode	   AND BC4.CodeGroup = 'OccurProcessCode'
			  --LEFT OUTER JOIN STB_MachineMaster MM	    ON QDR.MachineCode = MM.MachineCode
			  --LEFT OUTER JOIN SmartFactoryIncubator.dbo.VW_EmployeeInfo EI2	    ON QDR.ProdWorkerCode = EI2.EmployeeNo
			  --LEFT OUTER JOIN STB_DefectInfo DI	    ON QDR.DefectCode = DI.DefectCode
			  --LEFT OUTER JOIN SmartFactoryIncubator.dbo.VW_EmployeeInfo EI3	    ON QDR.ActionWorkerCode = EI3.EmployeeNo
			  LEFT OUTER JOIN SmartFramework.dbo.STB_BaseCode BC5	    ON QDR.ProdProcessResultCode = BC5.ItemCode	   AND BC5.CodeGroup = 'ProdProcessResultCode'
			  LEFT OUTER JOIN SmartFramework.dbo.STB_BaseCode BC6	    ON QDR.CorrectiveActionCode = BC6.ItemCode	   AND BC6.CodeGroup = 'CorrectiveActionCode'               --추가(시정조치여부)
			  LEFT OUTER JOIN (SELECT DefectReportNo 
										 FROM STB_QcDefectReportReInspectionResult 
										GROUP BY DefectReportNo
									  ) QDRRR 	    ON QDRRR.DefectReportNo = QDR.DefectReportNo
			  LEFT OUTER JOIN SmartFramework_File.dbo.STB_AttachedFileMaster AFM	    ON AFM.FileID = QDR.ProdProcessResultFile
	 WHERE 1=1 
	   AND QDR.DefectReportNo = @DummyReportNo	  
	--AND	(QDR.LotNo LIKE @LotNo)             -- 수불문서번호
	--AND ((@LotNo = '*') OR (QDR.LotNo = @LotNo))               -- 수불문서번호 (kilee, 2020-07-14)
END