-- =============================================
-- Author : Jackaroe(yjyu@vina.co.kr)
-- Group : 영업관리
-- Browsable : true
-- Create date : 2020-01-03
-- Description : 
-- Modified :
-- =============================================
CREATE PROCEDURE [dbo].[usp_HomepageInquiryCount_get]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20)
AS

BEGIN
	Declare @NewInquiryTotalCnt INT 
	       ,@MailTitle VARCHAR(500) = '홈페이지에 고객문의가 등록되었습니다.(' + CONVERT(VARCHAR(20), GETDATE(), 121) + ')'

	DELETE FROM STB_InquiryListTemp

	;With icnt AS (
		SELECT 'vina_inquiry' AS InquiryLoc, COUNT(*) AS NewInquiryCnt FROM VDB...vina_inquiry WHERE reg_date > (DATEDIFF(SECOND,{d '1970-01-01'}, GETDATE()) - (32400 + 2400)) UNION ALL
		SELECT 'vina_inquiry_cn' AS InquiryLoc, COUNT(*) AS NewInquiryCnt FROM VDB...vina_inquiry_cn WHERE reg_date > (DATEDIFF(SECOND,{d '1970-01-01'}, GETDATE()) - (32400 + 2400)) UNION ALL
		SELECT 'vina_inquiry_cn_new' AS InquiryLoc, COUNT(*) AS NewInquiryCnt FROM VDB...vina_inquiry_cn_new WHERE reg_date > (DATEDIFF(SECOND,{d '1970-01-01'}, GETDATE()) - (32400 + 2400)) UNION ALL
		SELECT 'vina_inquiry_eng' AS InquiryLoc, COUNT(*) AS NewInquiryCnt FROM VDB...vina_inquiry_eng WHERE reg_date > (DATEDIFF(SECOND,{d '1970-01-01'}, GETDATE()) - (32400 + 2400)) UNION ALL
		SELECT 'vina_inquiry_eng_new' AS InquiryLoc, COUNT(*) AS NewInquiryCnt FROM VDB...vina_inquiry_eng_new WHERE reg_date > (DATEDIFF(SECOND,{d '1970-01-01'}, GETDATE()) - (32400 + 2400)) UNION ALL
		SELECT 'vina_inquiry_new' AS InquiryLoc, COUNT(*) AS NewInquiryCnt FROM VDB...vina_inquiry_new WHERE reg_date > (DATEDIFF(SECOND,{d '1970-01-01'}, GETDATE()) - (32400 + 2400)) UNION ALL
		SELECT 'vina_inquiry_por' AS InquiryLoc, COUNT(*) AS NewInquiryCnt FROM VDB...vina_inquiry_por WHERE reg_date > (DATEDIFF(SECOND,{d '1970-01-01'}, GETDATE()) - (32400 + 2400)) UNION ALL
		SELECT 'vina_inquiry_por_new' AS InquiryLoc, COUNT(*) AS NewInquiryCnt FROM VDB...vina_inquiry_por_new WHERE reg_date > (DATEDIFF(SECOND,{d '1970-01-01'}, GETDATE()) - (32400 + 2400)) UNION ALL
		SELECT 'vina_inquiry_rus' AS InquiryLoc, COUNT(*) AS NewInquiryCnt FROM VDB...vina_inquiry_rus WHERE reg_date > (DATEDIFF(SECOND,{d '1970-01-01'}, GETDATE()) - (32400 + 2400)) UNION ALL
		SELECT 'vina_inquiry_rus_new' AS InquiryLoc, COUNT(*) AS NewInquiryCnt FROM VDB...vina_inquiry_rus_new WHERE reg_date > (DATEDIFF(SECOND,{d '1970-01-01'}, GETDATE()) - (32400 + 2400)) UNION ALL
		SELECT 'vina_inquiry_spn' AS InquiryLoc, COUNT(*) AS NewInquiryCnt FROM VDB...vina_inquiry_spn WHERE reg_date > (DATEDIFF(SECOND,{d '1970-01-01'}, GETDATE()) - (32400 + 2400)) UNION ALL
		SELECT 'vina_inquiry_spn_new' AS InquiryLoc, COUNT(*) AS NewInquiryCnt FROM VDB...vina_inquiry_spn_new WHERE reg_date > (DATEDIFF(SECOND,{d '1970-01-01'}, GETDATE()) - (32400 + 2400)) UNION ALL
		SELECT 'vina_inquiry_vtm_new' AS InquiryLoc, COUNT(*) AS NewInquiryCnt FROM VDB...vina_inquiry_vtm_new WHERE reg_date > (DATEDIFF(SECOND,{d '1970-01-01'}, GETDATE()) - (32400 + 2400))
	) 
	INSERT INTO STB_InquiryListTemp
		SELECT *
			FROM icnt

	SELECT @NewInquiryTotalCnt = SUM(NewInquiryCnt)
	  FROM STB_InquiryListTemp

	IF @NewInquiryTotalCnt > 0 BEGIN
		EXEC msdb.dbo.sp_send_dbmail @profile_name='NAIS_MAIL' 
									,@recipients='hwkim@vina.co.kr;heidi@vina.co.kr;yjyu@vina.co.kr;'
									,@subject = @MailTitle
									,@body = '첨부파일 내용을 확인하세요.'
									,@query = 'SELECT * FROM SmartFactoryV2.dbo.STB_InquiryListTemp'
									,@attach_query_result_as_file = 1
	END
END