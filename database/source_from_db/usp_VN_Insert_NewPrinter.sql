CREATE PROC usp_VN_Insert_NewPrinter
	@pProcessUserID VARCHAR(20) = NULL,
	@LotNo NVARCHAR(50) = NULL,
	@MaterialName NVARCHAR(50) = NULL,
	@MaterialCode NVARCHAR(30) = NULL,
	@LotQty INT = NULL,
	@LabelQty INT = NULL,
	@Volt NVARCHAR(30) = NULL,
	@Farad NVARCHAR(30) = NULL,
	@Rating NVARCHAR(30) = NULL,
	@PartNo NVARCHAR(30) = NULL
AS
BEGIN
		
			DECLARE @ProcessUserID VARCHAR(20) = @pProcessUserID

			INSERT INTO STB_VN_NEW_PRINTER 
			(
			LotNo,
			MaterialName,
			MaterialCode,
			LotQty,
			LabelQty,
			Volt,
			Farad,
			Rating,
			PartNo,
			CreateUserID,
			CreateDateTime
			) 
			VALUES
			(
			@LotNo,
			@MaterialName,
			@MaterialCode,
			@LotQty,
			@LabelQty,
			@Volt,
			@Farad,
			@Rating,
			@PartNo,
			@ProcessUserID,
			DATEADD(HH, -2, GETDATE())
			)
END