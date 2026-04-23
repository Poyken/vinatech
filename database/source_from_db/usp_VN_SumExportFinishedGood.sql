	CREATE proc [dbo].[usp_VN_SumExportFinishedGood]
	AS
	BEGIN
			SELECT
					SUM(PackQty)AS Qty,
					COUNT(LotNo) AS LotNo
			FROM
					STB_VN_FINISHGOODS WITH(NOLOCK)
			WHERE
					Statusout =N'Xuất' 
					
	END

