-- =============================================
-- Author : Jackaroe(yjyu@vina.co.kr)
-- Group : 스마트팩토리
-- Browsable : true
-- Create date : 2020-06-09
-- Description : 기상청 날씨정보(매 정시 초단기예보)
-- Modified :
-- =============================================
CREATE PROCEDURE [dbo].[usp_UltraSrtNcst_interface]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pBaseTime INT = NULL
AS
BEGIN

	DECLARE @Url VARCHAR(8000) 
		   ,@QueryString varchar(50)
		   ,@BaseTime INT = CASE WHEN @pBaseTime IS NULL THEN CONVERT(INT, CONVERT(CHAR(2), GETDATE(), 108)) ELSE @pBaseTime END

	Declare @TempXML TABLE (tempXML XML);
	Declare @TempValues TABLE (Category VARCHAR(10), ObsrValue NUMERIC(10,2))

	SELECT @QueryString = '&base_date='+ CONVERT(CHAR(8),GETDATE(),112) + '&base_time=' + RIGHT('0' + CONVERT(VARCHAR(2),@BaseTime), 2) + '00'
	SELECT @Url = 'http://apis.data.go.kr/1360000/VilageFcstInfoService_2.0/getUltraSrtNcst?serviceKey=P7cZGl3IZTCcd9g1ulKmuzC7y20D0FQ%2F2dK3cpFEdH5xmTmMKLOm1lLeVk8GPQ1QMjy6Es0OOsCV4ZuZpeFNFA%3D%3D&numOfRows=1000&pageNo=1&nx=63&ny=89' + @QueryString

	IF EXISTS (SELECT 1 FROM STB_UltraSrtNcst WHERE BaseDate = CONVERT(CHAR(8),GETDATE(),112) AND BaseHour = CONVERT(INT, CONVERT(CHAR(2),GETDATE(),108))) BEGIN
		RAISERROR('Duplicate Data!', 16, 1, NULL)
	END ELSE BEGIN
		DECLARE @Response varchar(8000)
		DECLARE @XML xml
		DECLARE @Obj int 
		DECLARE @Result int 
		DECLARE @HTTPStatus int 
		DECLARE @ErrorMsg varchar(MAX)

		EXEC @Result = sp_OACreate 'MSXML2.XMLHttp', @Obj OUT 

		EXEC @Result = sp_OAMethod @Obj, 'open', NULL, 'GET', @URL, false
		EXEC @Result = sp_OAMethod @Obj, 'setRequestHeader', NULL, 'Content-Type', 'application/x-www-form-urlencoded'
		EXEC @Result = sp_OAMethod @Obj, send, NULL, ''
		EXEC @Result = sp_OAGetProperty @Obj, 'status', @HTTPStatus OUT 

		INSERT INTO @TempXML(tempXML)
			EXEC @Result = sp_OAGetProperty @Obj, 'responseXML.xml'

		SELECT @XML = tempXML FROM @TempXML
		
		INSERT INTO @TempValues
		SELECT Category = XCol.value('(category)[1]', 'VARCHAR(10)')
		      ,ObsrValue = XCol.value('(obsrValue)[1]', 'NUMERIC(10,2)')
		  FROM @XML.nodes('/response/body/items/item') AS XTbl(XCol)

		INSERT INTO STB_UltraSrtNcst (BaseDate, BaseHour, OriginalXML, Temperature, Humidity)
			SELECT GETDATE()
			      ,@BaseTime
				  ,tempXML
				  ,(SELECT ObsrValue FROM @TempValues WHERE Category = 'T1H')
				  ,(SELECT ObsrValue FROM @TempValues WHERE Category = 'REH')
			  FROM @TempXML
	END
END