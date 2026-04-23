CREATE PROC usp_VN_FinishedAccount
@pCode NVARCHAR(50) = NULL,
@pCodeKr NVARCHAR(50) = NULL 
AS
BEGIN
		--DECLARE @Code NVARCHAR(50) = @pCode
		--DECLARE @Ckr NVARCHAR(50) = @pCodeKr

		
				DECLARE @Code VARCHAR(100) = CASE WHEN ISNULL(@pCode,'') = '' THEN '%' ELSE @pCode END,
				@Ckr VARCHAR(100)= CASE WHEN ISNULL (@pCodeKr, '') = '' THEN '%' ELSE @pCodeKr END

SELECT 
		CODEKR,
		CODEACC,
		IsUse,
		CreateDateTime,
		ChangeDateTime,ChangeUserID
FROM 
		STB_VN_CODEGOODFINISED WITH(NOLOCK)
--WHERE
--		CODEACC = @Code
--		AND
--		CODEKR = @Ckr
		
END

