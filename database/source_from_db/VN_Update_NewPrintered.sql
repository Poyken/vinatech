CREATE PROC VN_Update_NewPrintered
@ID INT
AS
BEGIN
		DECLARE @Sts BIT

		DECLARE @IDS INT

		SELECT
				@Sts=StatusPrinter
		FROM
				STB_VN_NEW_PRINTER WITH(NOLOCK)
		WHERE
				ID = @ID

		IF @Sts = 0

			BEGIN
					UPDATE STB_VN_NEW_PRINTER
					SET 
						StatusPrinter = 1
					WHERE 
						 ID = @ID
			END

END

--SELECT * FROM STB_VN_NEW_PRINTER

--exec VN_Update_NewPrintered '8'

--update STB_VN_NEW_PRINTER
--set StatusPrinter = 0
--WHERE 
--ID = ID
