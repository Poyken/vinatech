


-- =============================================
-- Author: Jeon Gyeong Ho(khjun@awoo.co.kr)
-- Group : 시스템
-- Browsable : false
-- Create date: 2018-10-25
-- Description: 채번규칙으로 시리얼을 생성합니다
-- =============================================
CREATE PROCEDURE [dbo].[usp_DoCreateSerial]
	@pTableName VARCHAR(50),
	@pSerialNo VARCHAR(20) = NULL OUTPUT
AS
BEGIN
	SET NOCOUNT ON;

    EXEC SmartFramework.dbo.usp_DoCreateSerial	@pTableName = @pTableName,
												                @pSerialNo = @pSerialNo OUTPUT
END
