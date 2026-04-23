-- =============================================
-- Author : Jackaroe(yjyu@vina.co.kr)
-- Group : 스마트팩토리
-- Browsable : true
-- Create date : 2020-06-09
-- Description : 공휴일 정보
-- Modified :
-- =============================================
CREATE PROCEDURE [dbo].[usp_Holidays_interface]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pBaseYear CHAR(4)
AS
BEGIN

	DECLARE @Url VARCHAR(8000) 
		   ,@QueryString varchar(50)

	Declare @TempXML TABLE (tempXML XML);
	Declare @TempValues TABLE (locdate VARCHAR(8), dateName NVARCHAR(100))

	SELECT @QueryString = '&solYear='+@pBaseYear+'&solMonth=&numOfRows=100'
	SELECT @Url = 'https://apis.data.go.kr/B090041/openapi/service/SpcdeInfoService/getRestDeInfo?serviceKey=P7cZGl3IZTCcd9g1ulKmuzC7y20D0FQ%2F2dK3cpFEdH5xmTmMKLOm1lLeVk8GPQ1QMjy6Es0OOsCV4ZuZpeFNFA%3D%3D' + @QueryString

		DECLARE @Response varchar(8000)
		DECLARE @XML xml
		DECLARE @Obj int 
		DECLARE @Result int 
		DECLARE @HTTPStatus int 
		DECLARE @ErrorMsg varchar(MAX)

		-- 해당연도 데이터 삭제
		DELETE FROM STB_HolidaysInfo WHERE BaseDate BETWEEN @pBaseYear + '-01-01' AND @pBaseYear + '-12-31'

		EXEC @Result = sp_OACreate 'MSXML2.XMLHttp', @Obj OUT 

		EXEC @Result = sp_OAMethod @Obj, 'open', NULL, 'GET', @URL, false
		EXEC @Result = sp_OAMethod @Obj, 'setRequestHeader', NULL, 'Content-Type', 'application/x-www-form-urlencoded'
		EXEC @Result = sp_OAMethod @Obj, send, NULL, ''
		EXEC @Result = sp_OAGetProperty @Obj, 'status', @HTTPStatus OUT 

		INSERT INTO @TempXML(tempXML)
			EXEC @Result = sp_OAGetProperty @Obj, 'responseXML.xml'

		SELECT @XML = tempXML FROM @TempXML
		
		INSERT INTO @TempValues
		SELECT locdate = XCol.value('(locdate)[1]', 'VARCHAR(8)')
		      ,dateName = XCol.value('(dateName)[1]', 'NVARCHAR(100)')
		  FROM @XML.nodes('/response/body/items/item') AS XTbl(XCol)

		INSERT INTO STB_HolidaysInfo (BaseDate, HolidayName, CreateDateTime)
			SELECT locdate, dateName, GETDATE()
			  FROM @TempValues
END