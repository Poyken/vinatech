CREATE PROC [dbo].[usp_VN_update_ProdutionError]
	--@pProcessLanguage VARCHAR(20),
	--@pProcessUserID VARCHAR(20),
	@pIDPE  INT
AS
BEGIN

	SET NOCOUNT ON;

			DECLARE  @IDPE INT = @pIDPE,
		 --   DECLARE @ProcessLanguage VARCHAR(20) = @pProcessLanguage,
			--@ProcessUserID VARCHAR(20) = @pProcessUserID,
			@StatusError BIT,
		    @ErrorMessage NVARCHAR(MAX)
		

				SELECT 
						@StatusError=Flag
				FROM 
						STB_VN_PRODUCTION_ERROR
				WHERE 
						IDPE=@IDPE

					
				
			IF @IDPE IS NOT NULL AND @StatusError='False'

				BEGIN
						UPDATE STB_VN_PRODUCTION_ERROR
							SET
								    StatusError=N'Báo phế'
							WHERE	
									IDPE=@IDPE
				END

END

--EXEC usp_VN_update_ProdutionError '32'