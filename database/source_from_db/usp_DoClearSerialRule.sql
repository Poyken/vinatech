-- =============================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Create date: 2020-09-14
-- Browsable : true
-- Group : 팝업
-- Description:	시리얼 번호를 초기화 합니다.
-- Modified:
-- =============================================
CREATE PROC usp_DoClearSerialRule
	@pTableName VARCHAR(50) = NULL
   ,@pInitNo INT = 0
AS
BEGIN
	Declare @TableName VARCHAR(50) = @pTableName
	       ,@InitNo INT = @pInitNo

	UPDATE SmartFramework.dbo.STB_SerialRule
	   SET LastSerialNo = @InitNo
	 WHERE TableName = @TableName
END