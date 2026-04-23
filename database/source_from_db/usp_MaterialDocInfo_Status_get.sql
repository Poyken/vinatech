
-- =============================================
-- Author:	    kilee 
-- Create date: 2019-12-05
-- Browsable : true
-- Group : 자재관리 
-- Description: [F414] 자재관리 > 사내창고이동
-- Modified: 
-- 프로시저 실행 :    Exec [usp_MaterialDocInfo_Status_get] '','',''
-- =============================================
CREATE PROCEDURE [dbo].[usp_MaterialDocInfo_Status_get]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pMaterialDocNo VARCHAR(20),
	@pIsBackFlush BIT = NULL
AS



BEGIN
	SET NOCOUNT ON;
	
	DECLARE @ProcessUserID VARCHAR(20) = @pProcessUserID
	DECLARE @ProcessLanguage VARCHAR(20) = @pProcessLanguage
	DECLARE @MaterialDocNo VARCHAR(20) = @pMaterialDocNo
	DECLARE @IsBackFlush BIT = ISNULL(@pIsBackFlush, CONVERT(BIT,0))		


	--IF @IsBackFlush = 1
	BEGIN

	   UPDATE STB_MaterialDocInfo
			SET DocStatus = 'CREATE'
		WHERE MaterialDocNo LIKE @MaterialDocNo
	END 

END

