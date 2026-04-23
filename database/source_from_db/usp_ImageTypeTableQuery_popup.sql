-- =============================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Create date: 2020.09.18
-- Browsable : true
-- Group : 팝업
-- Description: Varbinary 형태의 이미지를 뷰잉하기 위한  공용 프로시저
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_ImageTypeTableQuery_popup]
								@pProcessUserID varchar(20),
								@pProcessLanguage varchar(20),
								@pTable VARCHAR(50) = NULL,
								@pImageColumn VARCHAR(MAX) = NULL,
								@pWhereColumn VARCHAR(100) = NULL,
								@pWhereValue VARCHAR(100) = NULL
AS

BEGIN
	Declare @Table VARCHAR(50) = @pTable
	       ,@ImageColumn VARCHAR(MAX) = @pImageColumn
		   ,@WhereColumn VARCHAR(100) = @pWhereColumn
		   ,@WhereValue VARCHAR(100) = @pWhereValue
		   ,@QueryString VARCHAR(MAX) = ''

	
	SET @QueryString = 'SELECT ' + @ImageColumn + ' AS ImageCol FROM ' + @Table + ' WHERE ' + @WhereColumn + ' = ''' + @WhereValue + ''''

	exec(@QueryString)

END



/*

-- 2021.05.25 테스트
SELECT DefectImage AS ImageCol FROM STB_NCR_Report WHERE  NCRNo = 'VVNI210522-03'

*/