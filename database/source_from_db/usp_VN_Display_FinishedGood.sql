CREATE PROC [dbo].[usp_VN_Display_FinishedGood] 
@LotNo NVARCHAR(50)
AS
BEGIN
		SELECT
					Barcode AS LotNo,
					MaterialName,
					MaterialCode,
					MAX(LotQty) AS LotQty,
					PartNo,
					CreateUserID,
					CONVERT(DATE,CreateDateTime) AS CreateDateTime,
					RIGHT(CreateDateTime,8) AS Times

				
		FROM
					STB_VN_NEW_PRINTER WITH(NOLOCK)
		WHERE
					Barcode = @LotNo AND LotQty =(SELECT MAX(LotQty) AS Loqty FROM STB_VN_NEW_PRINTER WITH(NOLOCK) WHERE  Barcode =@LotNo) 

		GROUP BY
					Barcode,
					MaterialName,
					MaterialCode,
					PartNo,
					CreateUserID,
					CreateDateTime
				
END

