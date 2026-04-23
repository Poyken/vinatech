-- =============================================
-- Author:		Park Jong Seob(jspark@awoo.co.kr)
-- Browsable : false
-- Create date: 2016.01.18
-- Description:	Serial 번호 생성 규칙정보를 가져옵니다.
-- =============================================
CREATE PROCEDURE [dbo].[usp_GetSerialRule]
	@pTableName VARCHAR(50),
	@pIsAutoKey BIT = NULL OUTPUT,
	@pIsLoopIUD BIT = NULL OUTPUT,
	@pPrefixData VARCHAR(12) = NULL OUTPUT,
	@pSerialLen INT = NULL OUTPUT,
	@pNewSerialNo INT = NULL OUTPUT
AS
BEGIN
	SET NOCOUNT ON;

	EXEC SmartFramework.dbo.usp_GetSerialRule 
					@pTableName = @pTableName, --'STB_BomDetail',
					@pIsAutoKey = @pIsAutoKey OUTPUT,
					@pIsLoopIUD = @pIsLoopIUD OUTPUT,
					@pPrefixData = @pPrefixData OUTPUT,
					@pSerialLen = @pSerialLen OUTPUT
END
