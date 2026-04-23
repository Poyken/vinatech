-- =============================================================================
-- Author : Kangs (kilee@vina.co.kr)
-- Group : 품질관리 > [C220]시료별수입검사 > 부적합등록(IQC)등록화면 Tab-2 
-- Browsable : True
-- Create date : 2020-07-10
-- Description : 부적합등록(수입검사용) 
-- 2020.10.23 검사LotNo로 변경해달라고 해서 테이블 추가   (박진호님 요청)
-- 2020.11.05 테스트완료 적용
-- 2020.12.14 Lot조치사항 추가

-- [프로시저 실행문]
-- usp_QcDefectIQCReport_get 'kilee','Korean','VNI999999-99',''
-- usp_QcDefectIQCReport_get 'kilee','Korean','','' 
-- ======================================================================================
CREATE PROCEDURE [dbo].[usp_QcDefectIQCReport_get]                               
							@pProcessUserID VARCHAR(20),
							@pProcessLanguage VARCHAR(20),
							@pDefectReportNo VARCHAR(20) = NULL,
							@pLotNo VARCHAR(MAX) = NULL,					-- DinhManh update 2025-02-12 VARCHAR(20) => VARCHAR(MAX) for LotNo and IQCSampleLotList
							@pIQCSampleLotList VARCHAR(MAX) = NULL			-- Error can't show report for item has long length IQCSampleLotList
AS

BEGIN
	Declare @DefectReportNo    VARCHAR(20) = @pDefectReportNo
	         , @DummyReportNo  VARCHAR(20) = @pDefectReportNo
			 , @LotNo                 VARCHAR(MAX) = CASE WHEN ISNULL(@pLotNo,'') = '' THEN '*' ELSE @pLotNo END						--
			 , @IQCSampleLotList  VARCHAR(MAX) = CASE WHEN ISNULL(@pIQCSampleLotList,'') = '' THEN '*' ELSE @pIQCSampleLotList END		--

	-- #200609
	-- EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_QcDefectReport',@DefectReportNo OUTPUT 
	-- 자동채번 로직을 사용할 경우 자동증가하는 순번에 따라 빈 번호가 생길 수 있으므로 수동 채번 로직을 적용
	-- 신규번호이면, 더미를 쿼리하고, 그렇지 않으면 해당 번호를 쿼리한다.
	-- @DefectReportNo 채번의 경우 미리 채번을 할 경우 중복 및 업데이트 오류 발생 가능성이 있어 iud에서 채번하는 것으로 수정


	--IF @LotNo IS NOT NULL       ---------------------------------------- 검사 Lot 있는 경우
 ---- IF (@LotNo IS NOT NULL AND @DefectReportNo IS NOT NULL)       ---------------------------------------- 검사 Lot는 있고, 부적합 번호도 있는 경우   (부적합등록 데이터 조회하는 경우)

	BEGIN

	--IF @DefectReportNo IS NULL  AND @LotNo IS NOT NULL
	
		--BEGIN 
		--	-- @DefectReportNo 채번
		--	SELECT @DefectReportNo = 'Automatic Numbering'

		--	SET @DummyReportNo = 'VNI999999-99'
		--END

		--RAISERROR(@pLotNo, 16, 1)
		--return
	
		SELECT  @DefectReportNo AS DefectReportNo

		--SELECT  CASE WHEN @DefectReportNo is NULL THEN   'VNI999999-99' ELSE @DefectReportNo END AS DefectReportNo		
				  ,QDR.DefectDivisionCode
				  ,BC1.Description AS DefectDivisionName
				  ,QDR.PublishDeptCode
				  ,BC2.Description AS PublishDeptName
				  ,QDR.PublishEmpID
				  ,EI1.EmployeeName AS PublishEmpName
				  ,QDR.OccurProcessCode
				  ,BC4.Description AS OccurProcessName
				  ,QDR.JobDate
				  , Case when isnull(QDR.LotNo, '') = '' then @LotNo else QDR.LotNo End   AS LotNo
				  ,QDR.CorrectiveActionCode AS CorrectiveActionCode                   -- 시정조치여부코드
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
				  , QDR.IsActionCode         AS ActionCode   -- 시정조치여부
				  , QDR.QcOpinionContent AS QcOpinionContent    -- 품질부서의견
				  , QDR.IsQcHeadConfirm  AS IsQcHeadConfirm       -- 품질부문장결재
				  , CASE WHEN QDR.IsQcHeadConfirm  = 0 THEN  '결재취소'  WHEN QDR.IsQcHeadConfirm  = 1 THEN  '결재완료'  ELSE '미완료' END       AS Payment              -- 품질부문장결재
				  , MQI.IQCSampleLotList                                                                                                                                                      AS IQCSampleLotList   -- 검사 Lot No (2020-10-23, 박진호요청)		     
		   -- FROM STB_IQcDefectReport QDR   -- 원본백업
		          , QDR.ActionContent AS ActionContent
			  FROM STB_MaterialQcInfo MQI	    
					-- LEFT OUTER JOIN  STB_NCR_Report SNR                                   ON QDR.DefectReportNo = SNR.NCRNo             --원본백업
					  LEFT OUTER JOIN  STB_NCR_Report SNR                                    ON SNR.LotNo =       MQI.IQCSampleLotList    --추가부분 (2020.10.23)
					  LEFT OUTER JOIN  STB_IQcDefectReport QDR     WITH(NOLOCK)	   ON SNR.NCRNo = QDR.DefectReportNo    --추가부분 (2020.10.23)
					  LEFT OUTER JOIN SmartFramework.dbo.STB_BaseCode BC1	           ON QDR.DefectDivisionCode = BC1.ItemCode	   AND BC1.CodeGroup = 'DefectDivisionCode'
					  LEFT OUTER JOIN SmartFramework.dbo.STB_BaseCode BC2	           ON QDR.PublishDeptCode = BC2.ItemCode	   AND BC2.CodeGroup = 'PublishDeptCode'
					  LEFT OUTER JOIN SmartFactoryIncubator.dbo.VW_EmployeeInfo EI1  ON QDR.PublishEmpID = EI1.EmployeeNo
				   -- LEFT OUTER JOIN SmartFramework.dbo.STB_BaseCode BC3	            ON QDR.ReceiveDeptCode = BC3.ItemCode	   AND BC3.CodeGroup = 'ReceiveDeptCode'
					  LEFT OUTER JOIN SmartFramework.dbo.STB_BaseCode BC4	            ON QDR.OccurProcessCode = BC4.ItemCode	   AND BC4.CodeGroup = 'OccurProcessCode'
				   -- LEFT OUTER JOIN STB_MachineMaster MM	                                ON QDR.MachineCode = MM.MachineCode
				   -- LEFT OUTER JOIN SmartFactoryIncubator.dbo.VW_EmployeeInfo EI2	ON QDR.ProdWorkerCode = EI2.EmployeeNo
				   -- LEFT OUTER JOIN STB_DefectInfo DI	                                        ON QDR.DefectCode = DI.DefectCode
				   -- LEFT OUTER JOIN SmartFactoryIncubator.dbo.VW_EmployeeInfo EI3	ON QDR.ActionWorkerCode = EI3.EmployeeNo
					  LEFT OUTER JOIN SmartFramework.dbo.STB_BaseCode BC5	            ON QDR.ProdProcessResultCode = BC5.ItemCode  AND BC5.CodeGroup = 'ProdProcessResultCode'
					  LEFT OUTER JOIN SmartFramework.dbo.STB_BaseCode BC6	            ON QDR.CorrectiveActionCode = BC6.ItemCode	   AND BC6.CodeGroup = 'CorrectiveActionCode'               --추가(시정조치여부)
					  LEFT OUTER JOIN (
												SELECT DefectReportNo 
												 FROM STB_QcDefectReportReInspectionResult 
												GROUP BY DefectReportNo
											  ) QDRRR 	ON QDRRR.DefectReportNo = QDR.DefectReportNo
					  LEFT OUTER JOIN SmartFramework_File.dbo.STB_AttachedFileMaster AFM	  ON AFM.FileID = QDR.ProdProcessResultFile		

			 WHERE 1=1 
			   And   MQI.IQCSampleLotList = @pLotNo

	  END


--   ELSE        ----------------------------------------------------------------------------- 그 밖의 신규로 등록하는 경우!!

--	   --IF @DefectReportNo IS NULL  AND @LotNo IS NOT NULL
	
--		BEGIN 
--			-- @DefectReportNo 채번
--			SELECT @DefectReportNo = 'Automatic Numbering'
--			     SET @DummyReportNo = 'VNI999999-99'
--		END
	
--SELECT @DefectReportNo AS DefectReportNo
--		  ,QDR.DefectDivisionCode
--		  ,BC1.Description AS DefectDivisionName
--		  ,QDR.PublishDeptCode
--		  ,BC2.Description AS PublishDeptName
--		  ,QDR.PublishEmpID
--		  ,EI1.EmployeeName AS PublishEmpName
--		  ,QDR.OccurProcessCode
--		  ,BC4.Description AS OccurProcessName
--		  ,QDR.JobDate
--		  , Case when isnull(QDR.LotNo, '') = '' then @LotNo else QDR.LotNo End   AS LotNo
--		  ,QDR.CorrectiveActionCode AS CorrectiveActionCode                   -- 시정조치여부코드
--		  ,BC6.Description AS CorrectiveActionName                                   -- 시정조치여부명
--		  ,QDR.DefectImage
--		  ,QDR.DefectImage2  
--		  ,QDR.DefectLotSize		
--		  ,QDR.ProdProcessResultCode                                        -- 생산부분 처리코드 (재작업, 특채 등)
--		  ,BC5.Description AS ProdProcessResultName                    -- 생산부분 처리명 (코드테이블)		
--		  ,CONVERT(BIT, 0) AS IsProdHeadConfirm		  
--		  ,CONVERT(BIT, 0) AS IsQcHeadConfirm		  
--		  ,GETDATE() AS CreateDateTime
--		  ,QDR.CreateUserID
--		  ,QDR.ChangeDateTime
--		  ,QDR.ChangeUserID
--		  ,CONVERT(BIT, 0) AS IsReInspectionResult -- #200515
--		  ,QDR.ProdProcessResultFile
--		  ,AFM.[FileName]
--		  ,AFM.FileSize
--		  ,ISNULL(AFM.FileContents, CONVERT(VARBINARY(MAX),NULL)) AS FileData
--		  , QDR.Nonconformity  AS Nonconformity     --부적합내용
--		  , QDR.ImmediateAction AS  ImmediateAction  --즉시조치
--		  , QDR.CauseInvestigation AS  CauseInvestigation  --원인조사
--		  , QDR.PreventionRecurrence AS  PreventionRecurrence  --재발방지조치
--		  , QDR.DetectionCounterMeasures AS  DetectionCounterMeasures  --검출대책수립		  
--		  , QDR.CheckingCorrectiveAction AS  CheckingCorrectiveAction  --시정조치확인
--		  , QDR.Validation                     AS  Validation  --제품유효성확인
--		  , QDR.IsActionCode         AS ActionCode   -- 시정조치여부
--		  , QDR.QcOpinionContent AS QcOpinionContent    -- 품질부서의견
--          , QDR.IsQcHeadConfirm  AS IsQcHeadConfirm       -- 품질부문장결재
--		  , CASE WHEN QDR.IsQcHeadConfirm  = 0 THEN  '결재취소'  WHEN QDR.IsQcHeadConfirm  = 1 THEN  '결재완료'  ELSE '미완료' END   AS Payment              -- 품질부문장결재
--		  , MQI.IQCSampleLotList                                                                                                                                                  AS IQCSampleLotList   -- 검사 Lot No (2020-10-23, 박진호요청)
		     
--   -- FROM STB_IQcDefectReport QDR   -- 원본백업
--	  FROM STB_MaterialQcInfo MQI	    
--	        -- LEFT OUTER JOIN  STB_NCR_Report SNR                                   ON QDR.DefectReportNo = SNR.NCRNo             --원본백업
--			  LEFT OUTER JOIN  STB_NCR_Report SNR                                    ON SNR.LotNo =       MQI.IQCSampleLotList    --추가부분 (2020.10.23)
--			  LEFT OUTER JOIN  STB_IQcDefectReport QDR     WITH(NOLOCK)	   ON SNR.NCRNo = QDR.DefectReportNo    --추가부분 (2020.10.23)

--			  LEFT OUTER JOIN SmartFramework.dbo.STB_BaseCode BC1	           ON QDR.DefectDivisionCode = BC1.ItemCode	   AND BC1.CodeGroup = 'DefectDivisionCode'
--			  LEFT OUTER JOIN SmartFramework.dbo.STB_BaseCode BC2	           ON QDR.PublishDeptCode = BC2.ItemCode	   AND BC2.CodeGroup = 'PublishDeptCode'
--			  LEFT OUTER JOIN SmartFactoryIncubator.dbo.VW_EmployeeInfo EI1  ON QDR.PublishEmpID = EI1.EmployeeNo
--		   -- LEFT OUTER JOIN SmartFramework.dbo.STB_BaseCode BC3	            ON QDR.ReceiveDeptCode = BC3.ItemCode	   AND BC3.CodeGroup = 'ReceiveDeptCode'
--			  LEFT OUTER JOIN SmartFramework.dbo.STB_BaseCode BC4	            ON QDR.OccurProcessCode = BC4.ItemCode	   AND BC4.CodeGroup = 'OccurProcessCode'
--		   -- LEFT OUTER JOIN STB_MachineMaster MM	                                ON QDR.MachineCode = MM.MachineCode
--		   -- LEFT OUTER JOIN SmartFactoryIncubator.dbo.VW_EmployeeInfo EI2	ON QDR.ProdWorkerCode = EI2.EmployeeNo
--		   -- LEFT OUTER JOIN STB_DefectInfo DI	                                        ON QDR.DefectCode = DI.DefectCode
--		   -- LEFT OUTER JOIN SmartFactoryIncubator.dbo.VW_EmployeeInfo EI3	ON QDR.ActionWorkerCode = EI3.EmployeeNo
--			  LEFT OUTER JOIN SmartFramework.dbo.STB_BaseCode BC5	            ON QDR.ProdProcessResultCode = BC5.ItemCode  AND BC5.CodeGroup = 'ProdProcessResultCode'
--			  LEFT OUTER JOIN SmartFramework.dbo.STB_BaseCode BC6	            ON QDR.CorrectiveActionCode = BC6.ItemCode	   AND BC6.CodeGroup = 'CorrectiveActionCode'               --추가(시정조치여부)
--			  LEFT OUTER JOIN (
--			                            SELECT DefectReportNo 
--										 FROM STB_QcDefectReportReInspectionResult 
--										GROUP BY DefectReportNo
--									  ) QDRRR 	ON QDRRR.DefectReportNo = QDR.DefectReportNo
--			  LEFT OUTER JOIN SmartFramework_File.dbo.STB_AttachedFileMaster AFM	  ON AFM.FileID = QDR.ProdProcessResultFile		

--	 WHERE 1=1 
--	    And MQI.IQCSampleLotList= @DummyReportNo	    	   
--	   --And MQI.IQCSampleLotList= 'VNI999999-99'                -- 테스트용 주석

	    
END