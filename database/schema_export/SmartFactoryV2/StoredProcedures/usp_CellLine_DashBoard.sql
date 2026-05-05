-- Procedure: usp_CellLine_DashBoard
-- ==================================================================
-- Author      : kilee
-- Create date : 2021-11-01
-- Browsable   : true
-- Group       :  Power-BI
-- Description :  DB명 : [SmartFactoryV2]
-- Modified    : 대시보드 라인코드, 명 

-- ==================================================================

Create PROC [dbo].[usp_CellLine_DashBoard] 
				@pProcessUserID     VARCHAR(20),
				@pProcessLanguage VARCHAR(20),	
				@pCompanyCode VARCHAR(20) = NULL                    -- 추가
AS

BEGIN

	SET NOCOUNT ON;

	DECLARE @ProcessUserID     VARCHAR(20) = @pProcessUserID
	DECLARE @ProcessLanguage VARCHAR(20) = @pProcessLanguage    
	DECLARE @CompanyCode      VARCHAR(20) = CASE WHEN ISNULL(@pCompanyCode,'') = '' THEN '*' ELSE @pCompanyCode                    END


		SELECT  LineCode
			  , LineName
			  , CompanyCode 
		FROM STB_LineInfo


 END
GO

