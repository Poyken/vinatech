create proc usp_VN_SumImportFinishedGood
	AS
	BEGIN
			SELECT
					SUM(PackQty)AS Qty,
					COUNT(LotNo) AS LotNo
			FROM
					STB_VN_FINISHGOODS WITH(NOLOCK)
			WHERE
					StatusSystem =N'Nhập' AND Statusout IS NULL
					
	END