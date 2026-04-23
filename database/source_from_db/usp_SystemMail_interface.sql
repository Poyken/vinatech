CREATE PROC [dbo].[usp_SystemMail_interface] 
AS
BEGIN 
	Declare @SystemMailSeq BIGINT
	Declare @TargetMailAddress NVARCHAR(1000)
	Declare @MailSubject NVARCHAR(300)
	Declare @MailContents NVARCHAR(MAX)

	DECLARE CUR CURSOR FOR

	SELECT SystemMailSeq, TargetMailAddress, MailSubject, MailContents
	  FROM STB_SystemMail
	 WHERE MailSendYn = 'N'

	OPEN CUR 

	FETCH NEXT FROM CUR INTO @SystemMailSeq, @TargetMailAddress, @MailSubject, @MailContents

	--커서를이용해 한ROW씩 읽음 
	WHILE @@FETCH_STATUS = 0
	BEGIN
		EXEC msdb.dbo.sp_send_dbmail @profile_name='NAIS_MAIL',
									 @recipients=@TargetMailAddress,
									 @subject=@MailSubject,
									 @body=@MailContents,
									 @body_format = 'HTML'

		UPDATE STB_SystemMail
		   SET MailSendYn = 'Y'
		      ,ChangeDateTime = getdate()
			  ,ChangeUserID = 'admin'
		 WHERE SystemMailSeq = @SystemMailSeq
	
		FETCH NEXT FROM CUR INTO @SystemMailSeq, @TargetMailAddress, @MailSubject, @MailContents
	END

	--커서 닫고 초기화
	CLOSE CUR
	DEALLOCATE CUR
END