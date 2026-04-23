CREATE PROC [dbo].[usp_VN_SummaryModule]
@pBarCode NVARCHAR(50) = NULL
AS
BEGIN
	  DECLARE @Barcode NVARCHAR(100)= CASE WHEN ISNULL (@pBarCode, '') = '' THEN '%' ELSE @pBarCode END
			select * from  (SELECT 
			T1.LOTNO,
			null QTY,
			null  DIVIDETHENUMBER,
			T2.QTYACT,
			null TOTALQTY,
			T2.MaterialCode,
			T2.MaterialName,
			T2.LOTNO as lotcell
			
				FROM
					STB_VN_MASTERMODULES T1 WITH(NOLOCK)
					LEFT JOIN STB_VN_DETAILMODULES T2 WITH(NOLOCK)
					ON T1.GROUPID = T2.GROUPID
				WHERE
						(
							(T1.LOTNO LIKE @Barcode)
						)
		UNION

		select 
								ISNULL(T1.LOTNO, 'Total') AS lotno,
								MAX(T1.QTY) QTY,
								MAX(T1.DIVIDETHENUMBER) DIVIDETHENUMBER,
								SUM(T2.QTYACT) QTYACT,
								MAX(T1.TOTALQTY) TOTALQTY ,
								'ZSubTotal' MaterialCode,
								'' MaterialName,
								'' lotcell

				FROM
					STB_VN_MASTERMODULES T1 WITH(NOLOCK)
					LEFT JOIN STB_VN_DETAILMODULES T2 WITH(NOLOCK)
					ON T1.GROUPID = T2.GROUPID
				WHERE
						(
							(T1.LOTNO LIKE @Barcode)
						) 
				group by T1.lotno) A1
				order by A1.lotno

END

