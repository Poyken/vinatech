CREATE PROC [dbo].[usp_DocumentListMon]
	@emailList VARCHAR(MAX)
AS
BEGIN
	Declare @CheckResult VARCHAR(MAX)
	       ,@MailContents VARCHAR(MAX) = NULL
		   ,@MailTitle VARCHAR(200) = '기록물 대사 결과입니다.(' + CONVERT(VARCHAR(19), GETDATE(), 121) + ')'

	Declare cur CURSOR FOR

	SELECT DocManagementCode + ' | 문서기록만 존재 <br />' AS CheckResult
	  FROM STB_DocManagementInfo
	 WHERE DocManagementCode NOT IN (SELECT FileName FROM STB_DocFileCheckResult)
	 UNION ALL
	SELECT FileName + ' | 파일만 존재 <br />'
	  FROM STB_DocFileCheckResult
	 WHERE FileName NOT IN (SELECT DocManagementCode FROM STB_DocManagementInfo)

	 OPEN cur

	 FETCH NEXT FROM cur INTO @CheckResult

	 WHILE @@FETCH_STATUS = 0 BEGIN
		SET @MailContents = @MailContents + @CheckResult

		FETCH NEXT FROM cur INTO @CheckResult
	 END

	 IF @MailContents IS NOT NULL BEGIN
		 EXEC usp_DoAddSystemMail @pProcessUserID = '' 
			                ,@pProcessLanguage = ''
							,@pTargetMailAddress=@emailList
							,@pMailSubject = @MailTitle
							,@pMailContents = @MailContents
	 END

	 CLOSE cur
	 DEALLOCATE cur
END