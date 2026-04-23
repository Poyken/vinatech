CREATE proc dtc_test 
as
begin
	INSERT INTO OLDNAISSVR.SmartFactoryV2.dbo.STB_DefectReportMail (ToAddress, CcAddress, MailSubject, MailContents)
					SELECT 'yjyu@vina.co.kr'
					      ,'yjstory@gmail.com'
						  ,'1'
						  ,'2'
end