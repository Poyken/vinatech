CREATE PROC [dbo].[usp_VN_ShowPrinteredModule]
@pFromdate DATE = NULL,
@pToDate DATE = NULL
AS
BEGIN
	    DECLARE @FromDate DATE = @pFromdate
		DECLARE @ToDate DATE = @pToDate

		SELECT
			    PackingID,
				Barcode,
				LotQty,
				LabelQty,
				Voltage,
				Farad,
				Rating,
				PartNo,
				Line,
				CreateDateTime AS DateCreated,
				RIGHT(CreateDateTime,8) AS Times,
				CreateUserID

		FROM 
				STB_VN_NEW_PRINTER WITH(NOLOCK)
		WHERE
					(
							((@FromDate IS NULL) OR CONVERT(DATE,CreateDateTime) >= @FromDate)
						AND
							((@ToDate IS NULL) OR CONVERT(DATE,CreateDateTime) <= @ToDate)
					)

		order by CreateDateTime desc
END


--SELECT * FROM STB_VN_NEW_PRINTER