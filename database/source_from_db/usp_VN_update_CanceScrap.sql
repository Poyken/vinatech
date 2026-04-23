CREATE PROC [dbo].[usp_VN_update_CanceScrap]
	@pProcessLanguage VARCHAR(20),
	@pProcessUserID VARCHAR(20),
	@pIDPE INT
AS
BEGIN
SET NOCOUNT ON;

		    DECLARE @ProcessLanguage VARCHAR(20) = @pProcessLanguage,
			@ProcessUserID VARCHAR(20) = @pProcessUserID,
			@StatusError NVARCHAR(50),
		    @ErrorMessage NVARCHAR(MAX),
			@IDPE INT = @pIDPE
			
				SELECT 
						@StatusError=StatusError
				FROM 
						STB_VN_PRODUCTION_ERROR
				WHERE 
						IDPE=@IDPE

			
		 
		  IF  @StatusError=N'Báo phế'
				BEGIN
				   DECLARE @NotEnoughStockError NVARCHAR(MAX)
					EXEC usp_GetSystemStringResource	@ProcessLanguage,
														N'Nếu là trạng thái ^Báo phế^ bạn không thể hủy được, Bạn chỉ hủy được khi đang ^Chờ phế^',
														@NotEnoughStockError OUTPUT

					RAISERROR(@NotEnoughStockError,16,1)
					RETURN		
				END

				IF @IDPE IS NOT NULL AND @StatusError != N'Báo phế'

				BEGIN
							UPDATE STB_VN_PRODUCTION_ERROR

							SET
								    Flag=1
							WHERE	
									IDPE=@IDPE
				END
											
END