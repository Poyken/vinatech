-- Procedure: usp_SerialRule_get






-- =============================================
-- Author:		Park Jong Seob(jspark@awoo.co.kr)
-- Create date: 2016.01.22
-- Description:	Table별 Key 생성 로직을 관리합니다.
-- =============================================
CREATE PROCEDURE [dbo].[usp_SerialRule_get]
	@pProcessUserID VARCHAR(20) = NULL,
	@pProcessLanguage VARCHAR(20) = NULL,
	@pTableName VARCHAR(50) = NULL
AS
BEGIN
	DECLARE @TableName VARCHAR(20) = ISNULL(@pTableName,'*')
	
	SELECT
			SR.TableName AS OldTableName,
			SR.TableName,
			SR.TableDescription,
			SR.IsAutoKey,
			SR.IsLoopIUD,
			SR.PrefixData,
			SR.SerialLen
	FROM
			STB_SerialRule SR
	WHERE
			(@TableName = '*') OR (SR.TableName LIKE @TableName + '%')
END







GO

