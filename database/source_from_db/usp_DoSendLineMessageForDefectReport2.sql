-- =============================================
-- Author: Kangs (kilee@vina.co.kr)
-- Create date: 2020-07-17
-- Browsable : true
-- Group : 품질관리 > [수입검사]용 LINE메세지
-- Description: 부적합보고서 등록 시 호출되어 라인 메시지를 발송한다.
-- Modified:

-- [프로시저 실행] usp_DoSendLineMessageForDefectReport2 '','','VNI201022-01'
-- =============================================
CREATE PROCEDURE [dbo].[usp_DoSendLineMessageForDefectReport2]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pDefectReportNo VARCHAR(20)
AS

BEGIN
	Declare @DefectReportNo VARCHAR(20) = @pDefectReportNo
	       ,@SQLIMG VARCHAR(MAX)
           ,@IMG_PATH VARBINARY(MAX)
           ,@TIMESTAMP VARCHAR(MAX)
           ,@ObjectToken INT
		   ,@DefectDivisionName NVARCHAR(50)
		   ,@PublishDeptName NVARCHAR(50)
		   ,@ReceiveDeptName NVARCHAR(50)
		   ,@OccurProcessName NVARCHAR(50)
		   ,@MachineName NVARCHAR(50)
		   ,@DefectName NVARCHAR(50)
		   ,@LineMessage NVARCHAR(MAX)

		   ,@ProdProcessResultName NVARCHAR(50)
           ,@CheckingCorrectiveAction NVARCHAR(50)
		   , @Nonconformity  NVARCHAR(50)
		   ,@PublishEmpName NVARCHAR(50)
		   , @CorrectiveActionName NVARCHAR(50)
    SELECT @IMG_PATH = DefectImage FROM STB_IQcDefectReport WHERE DefectReportNo = @DefectReportNo



	IF @IMG_PATH IS NOT NULL BEGIN 
		SET @TIMESTAMP = 'C:\MES\WebSite\images\qcRpt2\' + replace(replace(replace(replace(convert(varchar,getdate(),121),'-',''),':',''),'.',''),' ','') + '.jpg'

		EXEC sp_OACreate 'ADODB.Stream', @ObjectToken OUTPUT
		EXEC sp_OASetProperty @ObjectToken, 'Type', 1
		EXEC sp_OAMethod @ObjectToken, 'Open'
		EXEC sp_OAMethod @ObjectToken, 'Write', NULL, @IMG_PATH
		EXEC sp_OAMethod @ObjectToken, 'SaveToFile', NULL, @TIMESTAMP, 2
		EXEC sp_OAMethod @ObjectToken, 'Close'
		EXEC sp_OADestroy @ObjectToken
	END ELSE BEGIN
		SET @TIMESTAMP = NULL
	END

	SELECT @DefectDivisionName = BC1.Description
			  ,@PublishDeptName = BC2.Description
			 -- ,@ReceiveDeptName = BC3.Description
			  ,@OccurProcessName = BC4.Description
			 -- ,@MachineName = MM.MachineName
			  ,@DefectName = DI.BasicDefectName			  
			  ,@ProdProcessResultName =  BC5.Description                     -- 생산부분 처리명 (코드테이블)		
			  ,@CheckingCorrectiveAction = QDR.CheckingCorrectiveAction --시정조치확인
			  , @Nonconformity = QDR.Nonconformity
               ,@PublishEmpName =  EI1.EmployeeName 
			    , @CorrectiveActionName  = BC6.Description 
		 FROM STB_IQcDefectReport QDR             -- 수입검사용
			  LEFT OUTER JOIN SmartFramework.dbo.STB_BaseCode BC1					ON QDR.DefectDivisionCode = BC1.ItemCode	   AND BC1.CodeGroup = 'DefectDivisionCode'
			  LEFT OUTER JOIN SmartFramework.dbo.STB_BaseCode BC2					ON QDR.PublishDeptCode = BC2.ItemCode	   AND BC2.CodeGroup = 'PublishDeptCode'
			  LEFT OUTER JOIN SmartFactoryIncubator.dbo.VW_EmployeeInfo EI1	    ON QDR.PublishEmpID = EI1.EmployeeNo	   
			  --LEFT OUTER JOIN SmartFramework.dbo.STB_BaseCode BC3					ON QDR.ReceiveDeptCode = BC3.ItemCode	   AND BC3.CodeGroup = 'ReceiveDeptCode'
			  LEFT OUTER JOIN SmartFramework.dbo.STB_BaseCode BC4					ON QDR.OccurProcessCode = BC4.ItemCode	   AND BC4.CodeGroup = 'OccurProcessCode'
			  --LEFT OUTER JOIN STB_MachineMaster MM										ON QDR.MachineCode = MM.MachineCode
			  LEFT OUTER JOIN SmartFactoryIncubator.dbo.VW_EmployeeInfo EI2	    ON QDR.PublishEmpID = EI2.EmployeeNo
			  LEFT OUTER JOIN STB_DefectInfo DI												ON QDR.DefectDivisionCode = DI.DefectCode
			  LEFT OUTER JOIN SmartFactoryIncubator.dbo.VW_EmployeeInfo EI3	    ON QDR.PublishEmpID = EI3.EmployeeNo
			  LEFT OUTER JOIN SmartFramework.dbo.STB_BaseCode BC5					ON QDR.ProdProcessResultCode = BC5.ItemCode	   AND BC5.CodeGroup = 'ProdProcessResultCode'
			  LEFT OUTER JOIN SmartFramework.dbo.STB_BaseCode BC6	                ON QDR.CorrectiveActionCode = BC6.ItemCode	   AND BC6.CodeGroup = 'CorrectiveActionCode'               --추가(시정조치여부)
			  --LEFT OUTER JOIN (
			  --                          SELECT DefectReportNo 
					--					 FROM STB_QcDefectReportReInspectionResult 
					--					GROUP BY DefectReportNo
					--				  ) QDRRR	    ON QDRRR.DefectReportNo = QDR.DefectReportNo
			  --LEFT OUTER JOIN SmartFramework_File.dbo.STB_AttachedFileMaster AFM	    ON AFM.FileID = QDR.ProdProcessResultFile
	 WHERE 1=1 
	   AND QDR.DefectReportNo = @DefectReportNo

	SET @LineMessage = '부적합보고서가 발행되었습니다 / [부적합구분] : ' + ISNULL(@DefectDivisionName,'')
							+ ' / [발행부서] : ' + ISNULL(@PublishDeptName,'')						
							+ ' / [부적합내용] : ' + ISNULL(@Nonconformity,'')
							+ ' / [발행자] : ' +   ISNULL(@PublishEmpName,'') 
							+ ' / [조치여부사항] : ' + ISNULL(@CorrectiveActionName,'')
							+ CASE WHEN @TIMESTAMP IS NULL THEN ' / [이미지링크] : 등록된 이미지가 없습니다.' 
									ELSE ' / [이미지링크] : http://mes.hycap.co.kr:9952/images/qcRpt2/' + RIGHT(@TIMESTAMP, 21) END

      exec usp_DoSendGembaTroubleMessage '', '', @LineMessage           --원본
	--exec usp_DoSendGembaTroubleMessageTest '', '', @LineMessage           -- test용 : usp_DoSendGembaTroubleMessageTest

END