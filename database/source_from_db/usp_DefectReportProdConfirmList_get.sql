-- =============================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Create date: 2022-12-30
-- Browsable : True
-- Group : 프로세스
-- Description:	
-- ===============================================================================================================
CREATE PROCEDURE [dbo].[usp_DefectReportProdConfirmList_get]
						@pProcessUserID VARCHAR(20),
						@pProcessLanguage VARCHAR(20),
						@pBaseDate DATE,
						@pPublishDeptCode VARCHAR(20),
						@pQcDefectClassCode VARCHAR(20),
						@pMailAddress VARCHAR(MAX)
AS
BEGIN
	Declare @BaseDate DATE = @pBaseDate
	Declare @PublishDeptCode VARCHAR(20) = @pPublishDeptCode
	Declare @QcDefectClassCode VARCHAR(20) = @pQcDefectClassCode
	Declare @MailAddress VARCHAR(MAX) = @pMailAddress
	Declare @Prefix NVARCHAR(MAX) 
	Declare @Body NVARCHAR(MAX) = ''
	Declare @Postfix NVARCHAR(MAX)
	Declare @EmailBody NVARCHAR(MAX)
	Declare @MailSubject NVARCHAR(1000)

	Declare @RowCount INT -- 쿼리 건 수 저장

	SET @MailSubject = '생산부문장 코멘트 대상 목록입니다. (' + CONVERT(VARCHAR(19), GETDATE(), 121) + ')'

	SET @Prefix = CONVERT(VARCHAR(19), GETDATE(), 121) + N' 기준 부적합 보고서 중 생산부문장 코맨트 대상 목록입니다.<br><br>'
	SET @Prefix = @Prefix + N'    <table width="500" cellspacing="1" cellpadding="1" border="1">'
    SET @Prefix = @Prefix + N'      <colgroup>'
    SET @Prefix = @Prefix + N'        <col width="20%">'
	SET @Prefix = @Prefix + N'        <col width="50%">'
	SET @Prefix = @Prefix + N'        <col width="30%">'
    SET @Prefix = @Prefix + N'      </colgroup>'
    SET @Prefix = @Prefix + N'      <thead>'
	SET @Prefix = @Prefix + N'      <tr>'
	SET @Prefix = @Prefix + N'        <th>부적합번호</th>'
	SET @Prefix = @Prefix + N'        <th>품목명</th>'
	SET @Prefix = @Prefix + N'        <th>불량증상명</th>'
	SET @Prefix = @Prefix + N'      </tr>'
	SET @Prefix = @Prefix + N'      </thead>'
	SET @Prefix = @Prefix + N'      <tbody>'

	SELECT @Body = @Body + '<tr><td><a href="http://mes.hycap.co.kr:9952/confirmLink/ProdConfirmPage.asp?qcDefectReportNo=' + QDR.DefectReportNo + '&connectString='+QDR.ConnectString+'" target="_blank">'+DefectReportNo+'</a></td><td>'+ISNULL(QDR.MaterialName, '')+'</td><td>'+ISNULL(DI.BasicDefectName, '')+'</td></tr>'
	  FROM STB_QcDefectReport QDR
	  LEFT OUTER JOIN STB_DefectInfo DI
	    ON QDR.DefectCode = DI.DefectCode
	 WHERE QDR.PublishDeptCode = @PublishDeptCode
	   AND RTRIM(ISNULL(QDR.ProdMeasuresContent, '')) != ''
	   AND RTRIM(ISNULL(QDR.ProdHeadComment, '')) = ''
	   AND QDR.CreateDateTime > @BaseDate
	   AND QDR.QcDefectClassCode = @QcDefectClassCode

	SET @RowCount = @@ROWCOUNT

	SET @Postfix = '</tbody></table>'

	SET @EmailBody = @Prefix + @Body + @Postfix

	PRINT '@RowCount ::: ' + CONVERT(VARCHAR, @RowCount)

	IF @RowCount > 0 BEGIN
		EXEC usp_DoAddDefectReportMail @pProcessUserID = @pProcessUserID
								,@pProcessLanguage = @pProcessLanguage
								,@pToMailAddress= @MailAddress
								,@pCcMailAddress= ''
								,@pMailSubject = @MailSubject
								,@pMailContents = @EmailBody
	END ELSE BEGIN
		PRINT '대상 건이 없습니다.'
	END
END