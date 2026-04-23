CREATE PROC usp_VN_ShowModule
@pLotNo NVARCHAR(50) = NULL
AS
BEGIN

DECLARE @LOTNO NVARCHAR(50) = @pLotNo

IF(@LOTNO IS NOT NULL)

BEGIN
			SELECT 
					PackingID,
					LOTNO,
					QTY,
					DIVIDETHENUMBER,
					TOTALQTY,
					VOL,
					FWAR,
					PARTNO,
					SIZE,
					CASE
					WHEN ISUSED = 1 THEN N'Bạn có thể in tem cho mã này vì đã được xác nhận'
					WHEN ISUSED = 0 THEN N'Chờ xác nhận bạn mới có thể in'
					ELSE ''
					END AS StatusPrinter 

			FROM 
					STB_VN_MASTERMODULES WITH(NOLOCK)
					WHERE LOTNO = @LOTNO
END

ELSE

	BEGIN
			SELECT
			    PackingID,
				LOTNO,
				QTY,
				DIVIDETHENUMBER,
				TOTALQTY,
				VOL,
				FWAR,
				PARTNO,
				SIZE,
				CASE
				WHEN ISUSED = 1 THEN N'Bạn có thể in tem cho mã này vì đã được xác nhận'
				WHEN ISUSED = 0 THEN N'Chờ xác nhận bạn mới có thể in'
				ELSE ''
				END AS StatusPrinter 

		FROM 
				STB_VN_MASTERMODULES WITH(NOLOCK)
		
	END
END