CREATE PROC usp_VN_fin
@IDCODE NVARCHAR(50),
@PackingID NVARCHAR(50),
@MaterialCode NVARCHAR(50),
@MaterialName NVARCHAR(50),
@PartNo NVARCHAR(50),
@LotNo NVARCHAR(50),
@Total NVARCHAR(50),
--@TYPEINPUT NVARCHAR(50),
--@INPUT NVARCHAR(50),
@ProductionDate NVARCHAR(50),
@USERID NVARCHAR(50)
AS
BEGIN
		INSERT INTO STB_VN_FINISHGOODS
		(
			IDCODE,
			PackingID,
			MaterialCode,
			MaterialName,
			PartNo,
			LotNo,
			PackQty,
			INPUTFROM,
			StatusSystem,
			CreatDatePacked,
			USERID,
			CreateDate,
			MethodActions
		)
		VALUES
		(
			@IDCODE,
			@PackingID,
			@MaterialCode,
			@MaterialName,
			@PartNo,
			@LotNo,
			@Total,
			'NSX',
			N'Nhập',
			@ProductionDate ,
			@USERID,
			DATEADD(HH, -2, GETDATE()),
			N'Scan bằng Packing ID'
		)

		--SELECT TOP(100)* FROM STB_VN_FINISHGOODS ORDER BY DateExport DESC
END