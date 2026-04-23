CREATE PROC [dbo].[usp_VN_Search_Againg_Ngoaiquan]
--SELECT * FROM STB_MasterAgaingDetails
--SELECT * FROM STB_NgoaiQuan
@pBarCode NVARCHAR(50) = NULL
AS
BEGIN
		DECLARE @Barcode NVARCHAR(100)= CASE WHEN ISNULL (@pBarCode, '') = '' THEN '%' ELSE @pBarCode END
		
		select  * from 
		(SELECT
				T1.LOTNO,
				CONVERT(VARCHAR(10),(T1.CreateDateTime),120)  AS DATAGAING,
				T1.MODEL,
				T1.NAMEERROR,
				--T1.QTYINPUT,
				--T1.QTYOK,
				null QTYINPUT,
				null QTYOK,
				null NGESR,
				T1.NGLC,
				null NGOTHER,
				T1.QTYINPUT as INPUTQTY,
				T1.QtyOK as OK,
			
				  isnull(NGESR,0)+	isnull(NGLC,0)+	isnull(NGOTHER,0) as QTYERROR--,
				--T2.VITRILO,
				--T2.VITRICURLING
				
		FROM
				STB_MasterAgaingDetails T1 WITH(NOLOCK)
				--FULL JOIN STB_NgoaiQuan T2 WITH(NOLOCK)
				--ON T1.LOTNO = T2.LOTNO
		WHERE
				(
					(T1.LOTNO LIKE @Barcode)
				)

		union all
		select 
						ISNULL(t2.lotno, 'Total') AS lotno,
						'' DATAGAING,
						'' MODEL,
						'ZSubTotal' NAMEERROR,
						max(QTYINPUT) QTYINPUT,
						max(QTYOK) QTYOK,
						sum(T1.NGESR) NGESR ,
						sum(T1.NGLC) NGLC ,
						sum(T1.NGOTHER) NGOTHER,
						sum(T2.INPUTQTY) INPUTQTY,
						sum(T2.OK) ok,
						sum(T2.QTYERROR) QTYERROR
		FROM
						STB_MasterAgaingDetails T1 WITH(NOLOCK)
						FULL JOIN STB_NgoaiQuan T2 WITH(NOLOCK)
						ON T1.LOTNO = T2.LOTNO

				WHERE
						(
							(T2.LOTNO LIKE @Barcode)
						)
		Group by t2.lotno
		) A1
		ORDER BY A1.LotNo,NAMEERROR
END

--select * from STB_MasterAgaingDetails
--select * from STB_NgoaiQuan