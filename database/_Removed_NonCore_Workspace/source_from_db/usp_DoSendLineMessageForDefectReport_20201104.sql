-- =============================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Create date: 2020-06-22
-- Browsable : true
-- Group : 품질관리
-- Description: 부적합보고서 등록 시 호출되어 라인 메시지를 발송한다.
-- Modified:
-- 2020.08.07 품질부서의견 내용도 전송되도록 요청 (최은화 과장)
-- exec usp_DoSendLineMessageForDefectReport 'kilee' , 'Korean', 'VN180705-06'
-- =============================================
Create PROCEDURE [dbo].[usp_DoSendLineMessageForDefectReport_20201104]
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
		   ,@QcOpinionContent NVARCHAR(MAX)         --2020.08.07 추가
		   ,@MaterialCode VARCHAR(20) -- 전파내용에 품목코드 추가 이미정 차장 요청 2020.10.09 By Jackaroe
           ,@MaterialName VARCHAR(100)
		   ,@PublishName NVARCHAR(100)  --2020.10.21추가
		   , @Spec VARCHAR(20)

    SELECT @IMG_PATH = DefectImage FROM STB_QcDefectReport WHERE DefectReportNo = @DefectReportNo

	IF @IMG_PATH IS NOT NULL BEGIN 
		SET @TIMESTAMP = 'C:\MES\WebSite\images\qcRpt\' + replace(replace(replace(replace(convert(varchar,getdate(),121),'-',''),':',''),'.',''),' ','') + '.jpg'

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
			  ,@ReceiveDeptName = BC3.Description
			  ,@OccurProcessName = BC4.Description
			  ,@MachineName = MM.MachineName
			  ,@DefectName = DI.BasicDefectName
			  ,@QcOpinionContent =  QDR.QcOpinionContent      --2020.08.07 추가
			  ,@MaterialCode = QDR.MaterialCode
			  ,@MaterialName = MM2.MaterialName                                           --품목명, 2020.11.04 추가
			  ,@PublishName = isnull(EI1.EmployeeName, QDR.PublishEmpID)           --발행자, 2020.11.04 추가
			  ,@Spec = VW.MBIExtText04  + '_' + VW.MBIExtText05   
	  FROM STB_QcDefectReport QDR
			  LEFT OUTER JOIN SmartFramework.dbo.STB_BaseCode BC1					ON QDR.DefectDivisionCode = BC1.ItemCode	   AND BC1.CodeGroup = 'DefectDivisionCode'
			  LEFT OUTER JOIN SmartFramework.dbo.STB_BaseCode BC2					ON QDR.PublishDeptCode = BC2.ItemCode	   AND BC2.CodeGroup = 'PublishDeptCode'
			  LEFT OUTER JOIN SmartFactoryIncubator.dbo.VW_EmployeeInfo EI1	    ON QDR.PublishEmpID = EI1.EmployeeNo	   
			  LEFT OUTER JOIN SmartFramework.dbo.STB_BaseCode BC3					ON QDR.ReceiveDeptCode = BC3.ItemCode	   AND BC3.CodeGroup = 'ReceiveDeptCode'
			  LEFT OUTER JOIN SmartFramework.dbo.STB_BaseCode BC4					ON QDR.OccurProcessCode = BC4.ItemCode	   AND BC4.CodeGroup = 'OccurProcessCode'
			  LEFT OUTER JOIN STB_MachineMaster MM										ON QDR.MachineCode = MM.MachineCode
			  LEFT OUTER JOIN SmartFactoryIncubator.dbo.VW_EmployeeInfo EI2	    ON QDR.ProdWorkerCode = EI2.EmployeeNo
			  LEFT OUTER JOIN STB_DefectInfo DI												ON QDR.DefectCode = DI.DefectCode
			  LEFT OUTER JOIN SmartFactoryIncubator.dbo.VW_EmployeeInfo EI3	    ON QDR.ActionWorkerCode = EI3.EmployeeNo
			  LEFT OUTER JOIN SmartFramework.dbo.STB_BaseCode BC5					ON QDR.ProdProcessResultCode = BC5.ItemCode	   AND BC5.CodeGroup = 'ProdProcessResultCode'
			  LEFT OUTER JOIN (
			                            SELECT DefectReportNo 
										 FROM STB_QcDefectReportReInspectionResult 
										GROUP BY DefectReportNo
									  ) QDRRR	    ON QDRRR.DefectReportNo = QDR.DefectReportNo
			  LEFT OUTER JOIN SmartFramework_File.dbo.STB_AttachedFileMaster AFM	    ON AFM.FileID = QDR.ProdProcessResultFile
			  LEFT OUTER JOIN STB_MaterialMaster MM2 ON MM2.MaterialCode = QDR.MaterialCode
			  LEFT OUTER JOIN VW_ModelBasicInfo VW   ON VW.ModelCode = MM2.MaterialCode
	 WHERE 1=1 
	   AND QDR.DefectReportNo = @DefectReportNo

	SET @LineMessage = '부적합보고서가 발행되었습니다 / [부적합구분] : ' + ISNULL(@DefectDivisionName,'')
	                    + ' / [발행부서] : ' + ISNULL(@PublishDeptName,'')
						+ ' / [수신부서] : ' + ISNULL(@ReceiveDeptName,'')
						+ ' / [발생공정] : ' + ISNULL(@OccurProcessName,'')
						+ ' / [품목코드] : ' + ISNULL(@MaterialCode,'')
						+ ' / [품목명] : ' + ISNULL(@MaterialName,'') 
						+ ' / [스펙] : ' + ISNULL(@SPEC,'') 
						+ ' / [설비명] : ' + ISNULL(@MachineName,'')
						+ ' / [발행자] : ' + ISNULL(@PublishName,'')
						+ ' / [부적합명] : ' + ISNULL(@DefectName,'')
						+ ' / [품질부서의견] : ' + ISNULL(@QcOpinionContent,'')                                                                    -- 2020.08.07 추가
						+ CASE WHEN @TIMESTAMP IS NULL THEN ' / [이미지링크] : 등록된 이미지가 없습니다.' 
						              ELSE ' / [이미지링크] : http://mes.hycap.co.kr:9952/images/qcRpt/' + RIGHT(@TIMESTAMP, 21) END

	--exec usp_DoSendGembaTroubleMessage '', '', @LineMessage
	exec usp_DoSendGembaTroubleMessageTest '', '', @LineMessage           -- test용 : usp_DoSendGembaTroubleMessageTest

END



 --select * from STB_QcDefectReport where DefectReportNo = 'VN180705-06'