	CREATE PROC [dbo].[usp_VN_UpdatePartNo]
	 @PartNo NVARCHAR(50)
	AS
	BEGIN
	DECLARE @VNCODE NVARCHAR(50)

	SELECT 
										@VNCODE = CODEVN
								FROM 
										STB_VN_CODEGOODFINISED
								WHERE

									CODEKR	= @PartNo

							UPDATE 
									STB_VN_FINISHGOODS

									SET PublicCode = @VNCODE

							WHERE 
									PartNo = @PartNo	

									END

									--select * from STB_VN_CODEGOODFINISED