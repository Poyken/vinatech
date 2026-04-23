

-- =============================================
-- Author: Kim Han Young(hykim@awoo.co.kr)
-- Group : 시스템
-- Browsable : false
-- Create date: 2016-10-25
-- Description:	RFC 프로시저 정보를 조회합니다.
-- =============================================
CREATE PROCEDURE [dbo].[usp_GetRfcProcedure]
	@pProcedureName NVARCHAR(200)
AS
BEGIN
	SET NOCOUNT ON;

    EXEC usp_GetProcedures @pProcedureName = @pProcedureName
END



