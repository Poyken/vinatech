-- =============================================
-- Author : 
-- Group : 
-- Browsable :
-- Create date : 
-- Description : 
  
-- =============================================
CREATE PROCEDURE [dbo].[usp_PublicCodeWithPartNo_popup]
						@pProcessUserID VARCHAR(20),
						@pProcessLanguage VARCHAR(20),
						@pProductGroupCode VARCHAR(20) = NULL,
						@pIsClosed CHAR(1) = '0'
AS

BEGIN
	SET NOCOUNT ON;

    DECLARE @ProcessUserID VARCHAR(20) = @pProcessUserID,
			    @ProcessLanguage VARCHAR(20) = @pProcessLanguage,
			    @ProductGroupCode  VARCHAR(20) = CASE WHEN ISNULL(@pProductGroupCode,'') = '' THEN '%' ELSE @pProductGroupCode END,
				@IsClosed CHAR(1) = CASE WHEN ISNULL(@pIsClosed, '') = '' THEN '*' ELSE @pIsClosed END


    SELECT PublicCode,PartNo from PublicCodeAndPartNo
END