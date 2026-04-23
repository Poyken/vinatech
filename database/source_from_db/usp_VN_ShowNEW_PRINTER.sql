CREATE PROC [dbo].[usp_VN_ShowNEW_PRINTER]
	@pProcessUserID VARCHAR(20)
AS
BEGIN
		 
			DECLARE @ProcessUserID VARCHAR(20) = @pProcessUserID

			SELECT
					TOP(1)
					ID,
					Barcode,
					MaterialName,
					MaterialCode,
					LotQty,
					LabelQty,
					Voltage,
					Farad,
					Rating,
					PartNo,
					CreateDateTime AS Dates,
					RIGHT(CreateDateTime,8) AS Times,
					CreateUserID,
					'Report' AS CommandType

			FROM
					STB_VN_NEW_PRINTER WITH(NOLOCK)
			WHERE
					 CreateUserID = @ProcessUserID AND StatusPrinter = 0

					 ORDER BY CreateDateTime DESC
END


--select * from STB_VN_NEW_PRINTER