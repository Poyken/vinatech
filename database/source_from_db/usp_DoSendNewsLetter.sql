
-- =============================================
-- Author:	Jackaroe(yjyu@vina.co.kr)
-- Create date: 2019-04-18
-- Browsable : true
-- Group : 영업관리
-- Description: 뉴스레터 발송
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_DoSendNewsLetter]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pNewsLetterNo VARCHAR(20),
	@pNewsLetterMailingNo VARCHAR(200)
AS
BEGIN
	--뉴스레터 정보 조회
	Declare @NewsLetterNo VARCHAR(20) = @pNewsLetterNo
	       ,@NewsLetterMailingNo VARCHAR(20) = @pNewsLetterMailingNo
		   ,@NewsLetterHeader VARCHAR(MAX)
		   ,@NewsLetterContents VARCHAR(MAX)
		   ,@NewsLetterFooter VARCHAR(MAX)
		   ,@OriginalArticleLinkUrl VARCHAR(500)
		   ,@PublishNo VARCHAR(10)
		   ,@EmailContents VARCHAR(MAX)
		   ,@NewsLetterDetailNo VARCHAR(20)
		   ,@Title VARCHAR(200)
		   ,@TitleAlign VARCHAR(10)
		   ,@ImagePath VARCHAR(500)
		   ,@ImageWidth INT
		   ,@ImageAlign VARCHAR(10)
		   ,@ImageText VARCHAR(500)
		   ,@ImageTextAlign VARCHAR(10)
		   ,@Text VARCHAR(MAX)
		   ,@TextAlign VARCHAR(10)
		   ,@NewsLetterSendHistNo VARCHAR(20)
		   ,@Email VARCHAR(MAX)
		   ,@MailSubject VARCHAR(200)
		   ,@ErrorMessage VARCHAR(500)

	--뉴스레터 정보 조립
	SELECT @NewsLetterHeader = Header
	      ,@NewsLetterContents = Contents
		  ,@NewsLetterFooter = Footer
		  ,@OriginalArticleLinkUrl = OriginalArticleLinkUrl
		  ,@PublishNo = PublishNo
	  FROM STB_VINANewsLetterMaster
	 WHERE NewsLetterNo = @NewsLetterNo

	 SET @EmailContents = @NewsLetterHeader
	 --Header 치환
	 SET @EmailContents = REPLACE(@EmailContents,'@{PublishNo}', @PublishNo)
	 SET @EmailContents = REPLACE(@EmailContents,'@{OriginalArticleLinkUrl}', @OriginalArticleLinkUrl)

	 --Contents 조립
	 DECLARE ContentsData CURSOR FOR 
		SELECT Title
              ,TitleAlign
              ,ImagePath
              ,ImageWidth
              ,ImageAlign
              ,ImageText
              ,ImageTextAlign
              ,Text
              ,TextAlign
		  FROM STB_VINANewsLetterDetail
		 WHERE NewsLetterNo = @NewsLetterNo

	OPEN ContentsData

    WHILE 1 = 1 BEGIN
        FETCH NEXT FROM ContentsData INTO
							 @Title
							,@TitleAlign
							,@ImagePath
							,@ImageWidth
							,@ImageAlign
							,@ImageText
							,@ImageTextAlign
							,@Text
							,@TextAlign


        IF @@FETCH_STATUS <> 0 BEGIN
			BREAK
		END

		SET @EmailContents = @EmailContents + @NewsLetterContents

		--본문치환
		SET @EmailContents = REPLACE(@EmailContents,'@{TitleAlign}', ISNULL(@TitleAlign, ''))
		SET @EmailContents = REPLACE(@EmailContents,'@{Title}', ISNULL(@Title, ''))
		SET @EmailContents = REPLACE(@EmailContents,'@{ImageAlign}', ISNULL(@ImageAlign, ''))
		SET @EmailContents = REPLACE(@EmailContents,'@{ImagePath}', ISNULL(@ImagePath, ''))
		SET @EmailContents = REPLACE(@EmailContents,'@{ImageWidth}', ISNULL(@ImageWidth, 0))
		SET @EmailContents = REPLACE(@EmailContents,'@{ImageTextAlign}', ISNULL(@ImageTextAlign, ''))
		SET @EmailContents = REPLACE(@EmailContents,'@{ImageText}', ISNULL(@ImageText, ''))
		SET @EmailContents = REPLACE(@EmailContents,'@{TextAlign}', ISNULL(@TextAlign, ''))
		SET @EmailContents = REPLACE(@EmailContents,'@{Text}', ISNULL(@Text, ''))
	END

	CLOSE ContentsData;
	DEALLOCATE ContentsData;

	--Footer
	SET @EmailContents = @EmailContents + @NewsLetterFooter

	--& 치환
	SET @EmailContents = REPLACE(@EmailContents,'&', '&amp;')

	SELECT @Email = Email FROM STB_NewsLetterMailingInfo WHERE NewsLetterMailingNo = @NewsLetterMailingNo
	--SET @MailSubject = 'VINA Newsletter No. ' + @PublishNo
	SET @MailSubject = '[Newsletter] Snap In Ultracapacitor & New Applications'

	--뉴스레터 발송
	--데이터베이스 변경으로 수정함.
	--EXEC msdb.dbo.sp_send_dbmail @profile_name='NAIS_MAIL' 
	--                            ,@recipients=@Email
	--							,@subject = @MailSubject
	--							,@body = @EmailContents
	--							,@body_format = 'HTML' ;  

	EXEC usp_DoAddSystemMail @pProcessUserID = '' 
			                ,@pProcessLanguage = ''
							,@pTargetMailAddress=@Email
							,@pMailSubject = @MailSubject
							,@pMailContents = @EmailContents

	--뉴스레터 발송이력
	EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_NewsLetterSendHist',@NewsLetterSendHistNo OUTPUT
	
	INSERT INTO STB_NewsLetterSendHist (NewsLetterSendHistNo, NewsLetterMailingNo, NewsLetterNo, NewsLetterSource, CreateDateTime, CreateUserID)
		SELECT @NewsLetterSendHistNo, @NewsLetterMailingNo, @NewsLetterNo, @EmailContents, GETDATE(), 'eai'

	EXEC SmartFramework.dbo.usp_GetAddonStringResource	@pProcessLanguage,
										'^뉴스레터가 발송되었습니다..^',
										@ErrorMessage OUTPUT
		SET @ErrorMessage = @ErrorMessage + ' [%s]'
		RAISERROR(@ErrorMessage,16,1)
END
