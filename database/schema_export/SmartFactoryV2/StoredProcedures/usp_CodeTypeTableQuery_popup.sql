-- Procedure: usp_CodeTypeTableQuery_popup
-- =============================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Create date: 2020.09.18
-- Browsable : true
-- Group : 팝업
-- Description: 코드유형의 테이블을 쿼리하는 공용 프로시저
-- Modified:
-- =============================================
CREATE PROCEDURE usp_CodeTypeTableQuery_popup
								@pProcessUserID varchar(20),
								@pProcessLanguage varchar(20),
								@pTable VARCHAR(50) = NULL,
								@pCodeColumn VARCHAR(50) = NULL,
								@pNameColumn VARCHAR(50) = NULL,
								@pSortColumn VARCHAR(50) = NULL
AS

BEGIN
	Declare @Table VARCHAR(50) = @pTable
	       ,@CodeColumn VARCHAR(50) = @pCodeColumn
		   ,@NameColumn VARCHAR(50) = @pNameColumn
		   ,@SortColumn VARCHAR(50) = @pSortColumn
		   ,@queryString VARCHAR(MAX)

	SET @queryString = 'SELECT ' + @CodeColumn + ' AS code, ' + @NameColumn + ' AS name'
	SET @queryString = @queryString + ' FROM ' +  @Table
	SET @queryString = @queryString + ' ORDER BY ' + @SortColumn

	execute (@queryString)
END
GO

