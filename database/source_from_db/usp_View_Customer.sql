CREATE PROC [dbo].[usp_View_Customer] -- EXEC usp_View_Customer 'VVKQ123R010519'  EXEC usp_View_Customer 'VVOO182R710637'
@pLotNo VARCHAR(20) = NULL
AS
BEGIN

DECLARE @NP VARCHAR(1) = 'P'
DECLARE @NQ VARCHAR(1) = 'Q'
DECLARE @NS VARCHAR(1) = 'S'

DECLARE @PID NVARCHAR(40)
DECLARE @PRNO NVARCHAR(50)
DECLARE @QTY NVARCHAR(5)
DECLARE @DT NVARCHAR(30)
DECLARE @LOTNOS NVARCHAR(50)
DECLARE @PU NVARCHAR(200)

DECLARE @H VARCHAR(2)
DECLARE @M VARCHAR(2)
DECLARE @S VARCHAR(2)
DECLARE @SM VARCHAR(2)
DECLARE @PN NVARCHAR(50)
DECLARE @PNT NVARCHAR(50)

SELECT @H = DATEPART(HOUR, GETDATE());
SELECT @M = DATEPART(MINUTE, GETDATE());
SELECT @S = DATEPART(SECOND, GETDATE());
--SELECT @SM = DATEPART(MILLISECOND, GETDATE());

SET @DT = CONVERT(nvarchar(10),LEFT(REPLACE(NEWID(),'-',''),5)) --'4' + @H + @S --+  @SM  --@M --+ --
--SELECT GETDATE()
--SELECT  id,
--			(select top 1 newbarcode from STB_LotChangeMaterialHistory WITH(NOLOCK) where oldBarcode=LotNo) as newLotno
--			,LotNo, PackingID,MaterialCode,MaterialName,EmpNo,PrintTime,PackQty, isPrinted,PartNo,
--			(RANK() over (partition by LotNo,isPrinted order by  PackQty desc,printtime desc) ) as RankPackQty,
--			(ROW_NUMBER() over (partition by LotNo,isPrinted order by PackQty desc,printtime desc) ) as RowPackQty--,
--			  INTO #T1
--			FROM  [SmartFactoryV2].[dbo].[STB_SavePackingTime_VVT] DRI  WITH(NOLOCK) 

--			where 1=1 
--			 and  EmpNo not in ('test_worker','assy_packing','vvt_worker' ) AND DRI.LotNo = @LOTNO
			
--			SELECT * FROM #T1 t

		--	SELECT TOP(1)
		--			@PID = PackingID,
		--			@PRNO = PartNo,
		--			@QTY = PackQty

		--	FROM #T1 

		--	WHERE LotNo = @LOTNO

		--SELECT
		--		ProdDateTime
		--FROM 
		--	STB_ProdRouteHist WITH(NOLOCK)
		--LEFT JOIN
		--	STB_ProdRouteHist  ON STB_SetInfo.PN

		SELECT TOP(1)
					@PID = PackingID,
					@PRNO = PartNo,
					@QTY = PackQty,
					@PID = CONVERT(CHAR(8),STB_ProdRouteHist.ProdDateTime,112),
					@PRNO = LEFT(MM.MaterialName,23),
					@PN = RIGHT(@PRNO,17),
				    @PU = @NP +LTRIM(@PN) + @NQ + @QTY + @NS + CONVERT(CHAR(8),STB_ProdRouteHist.ProdDateTime,112)  + @DT
					
					-- HY-CAP VEC2R7106QG-B080 (1030)
					--  EXEC usp_View_Customer 'VVOO182R710637'
					-- P + PARTNO + Q + SỐ LƯỢNG + S + PACKINGID + SERINUMBER(LẤY THEO THỜI GIAN GIÂY SẼ KHÔNG TRÙNG SERINUMBER)
		FROM
				STB_SavePackingTime_VVT WITH(NOLOCK)

		LEFT JOIN 
				  
				  STB_SetInfo ON STB_SavePackingTime_VVT.LotNo = STB_SetInfo.Barcode

		LEFT JOIN
				
				STB_ProdRouteHist ON STB_SetInfo.PONo = STB_ProdRouteHist.PONo

		LEFT  OUTER JOIN 
		 
					STB_MaterialMaster MM	ON STB_SetInfo.MaterialCode = MM.MaterialCode
	  
		WHERE 
				LotNo = @pLotNo --'VVKQ123R010519'
		
		--SELECT  @PU = @NP + @PRNO + @NQ + @QTY + @NS + @PID + @DT --AS LOTNO
	
	SELECT @NP AS 'Chữ P', @PN AS 'PartNo' , @NQ AS 'Chữ Q', @QTY AS 'Số lượng', @NS AS 'Chữ S', @PID AS 'Ngày sản xuất', @DT AS 'Serianumber' ,@PU AS LOTNOSTEAMP,'Report' AS CommandType, 1 AS LABLELQTY
END


--select format(getdate(), 'hhmmsstt')

--SELECT * FROM STB_SavePackingTime_VVT

--select cast(getdate() as time)

--SELECT TOP(10)* FROM STB_ProdRouteHist sprh WHERE sprh.PONo = '220330000006'

--SELECT TOP(10)* FROM STB_SetInfo ssi WHERE ssi.PONo ='220330000006'


--SELECT CONVERT(nvarchar(10), getdate(), 100)

--SELECT CONVERT(CHAR(8),getdate(),112) as 'MyDate',CONVERT(CHAR(8),getdate(),112) as 'MyDateTime'

 
----B. NCHAR(8)
--SELECT CONVERT(NCHAR(8),getdate(),112) as 'MyDate',CONVERT(NCHAR(8),getdate(),112) as 'MyDateTime'

 
----C. FORMAT Function (new in SQL 2012) use format = yyyyMMdd returning the results as nvarchar.
--SELECT FORMAT(getdate(),'yyyyMMdd') as 'MyDate', FORMAT(getdate(),'yyyyMMdd')  as 'MyDateTime'
--SELECT TOP(100)* FROM STB_MaterialMaster ORDER BY CreateDateTime DESC

--SELECT * FROM STB_MaterialMaster

--SELECT CONVERT(nvarchar(10),LEFT(REPLACE(NEWID(),'-',''),5)) AS Random10