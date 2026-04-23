-- =============================================
-- Author : Jackaroe(yjyu@vina.co.kr)
-- Group : 공통
-- Browsable : true
-- Create date : 2020-04-03
-- Description : 문자메시지 조립 및 데이터 Insert
-- Modified :
-- Desc : @pParams에 치환 문자열을 ,로 연결하여 입력하면, @pMsg에서 {#1}부터 순서대로 치환하여 메시지를 완성한다.
--        @pParams의 개수와 {#..}의 개수가 다르면 @pParams의 개수 기준으로 적용된다.
-- =============================================
CREATE PROC [dbo].[usp_DoSendSMS]
	@pProcessUserID varchar(20)
   ,@pProcessLanguage varchar(20)
   ,@pMobileNoList VARCHAR(MAX)
   ,@pMsg NVARCHAR(MAX)
   ,@pParams NVARCHAR(500)
AS
BEGIN
	Declare @MobileNoList VARCHAR(MAX) = @pMobileNoList
		   ,@Msg NVARCHAR(MAX) = @pMsg
		   ,@Params NVARCHAR(500) = @pParams
		   ,@MsgType VARCHAR(10)
		   ,@SmsSendUrl VARCHAR(500)
		   ,@RowNo INT
		   ,@Item VARCHAR(100) 

	-- 최종문자열  2022.02.28 By Jackaroe
	Declare @finData VARCHAR(MAX)

	-- @Params 를 테이블로 변환 커서를 통해 반복 처리하여 최종 문자열 완성
	DECLARE cur CURSOR FOR

	SELECT RowNo, Item FROM dbo.fnSplitToTable(',', @Params)

	OPEN cur

	FETCH NEXT FROM cur INTO @RowNo, @Item

	WHILE @@FETCH_STATUS = 0
	BEGIN
		SET @Msg = REPLACE(@Msg, '{#'+CONVERT(VARCHAR(10), @RowNo)+'}', @Item)
	
		FETCH NEXT FROM cur INTO @RowNo, @Item
	END

	CLOSE cur
	DEALLOCATE cur

	--문자1004 내부처리 기준 때문에 &를 다른 문자로 치환함.
	SET @Msg = REPLACE(@Msg, '&', '_')
	SET @Msg = REPLACE(@Msg, '#', '_')

	SET @MsgType = CASE WHEN DATALENGTH(@Msg) < 80 THEN 'SMS' ELSE 'MMS' END

	IF @MsgType = 'SMS' BEGIN
		SET @SmsSendUrl = 'http://www.munja1004.co.kr/Remote/RemoteSms.html'
	END ELSE BEGIN
		SET @SmsSendUrl = 'http://www.munja1004.co.kr/Remote/RemoteMms.html'
	END

	INSERT INTO STB_SystemSms (
		MobileNoList
       ,MsgType
       ,Msg
       ,SmsSendUrl
       ,CreateUserID
	) VALUES (
		@MobileNoList
	   ,@MsgType
	   ,@Msg
	   ,@SmsSendUrl
	   ,@pProcessUserID
	)

	-- 입력 후 스케줄러를 기다리지 않고 직접 발송 2022.02.28 By Jackaroe
	SET @finData = @SmsSendUrl + '?remote_id=vinatech&remote_pass=vina3066&remote_num=1&remote_phone='+@MobileNoList+'&remote_callback=0637153020&remote_msg=' + @Msg

	exec HttpRequest @finData
END