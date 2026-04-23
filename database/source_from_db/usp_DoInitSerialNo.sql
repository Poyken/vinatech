-- =============================================
-- Author : Jackaroe(yjyu@vina.co.kr)
-- Group : 공통
-- Browsable : true
-- Create date : 2020-10-22
-- Description : 일련번호 초기화
-- =============================================
CREATE PROCEDURE usp_DoInitSerialNo
						@pProcessUserID VARCHAR(20),
						@pProcessLanguage VARCHAR(20),
						@pTableName VARCHAR(50),
						@pStartSerialNo INT = 1
AS

BEGIN
	Declare @TableName VARCHAR(50) = @pTableName
	       ,@StartSerialNo INT = @pStartSerialNo

	UPDATE SmartFramework.dbo.STB_SerialRule
	   SET LastSerialNo = @StartSerialNo
	 WHERE TableName = @TableName
END