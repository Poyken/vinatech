CREATE proc usp_VN_GraphichFinishedGood
@pFromdate DATE = NULL,
@pToDate DATE = NULL
AS
BEGIN

WITH cte AS 
 (
	SELECT 
	 DISTINCT row_number() OVER(partition by A.PublicCode order by A.PublicCode) rn,
		A.Flag,
		A.PartNo,
		A.PublicCode,
		B.QtyInput,
		C.Qtyout,
		D.Qtylocation,
		E.TotalSale,
		b.QtyInput - C.Qtyout AS TotalCurrently
  FROM
		STB_VN_FINISHGOODS A
  
   LEFT OUTER JOIN
  (
	SELECT
			PublicCode,sum(PackQty) AS QtyInput
			
    FROM 
			STB_VN_FINISHGOODS 
	WHERE 
			Flag = 1
    GROUP BY PublicCode)B

  ON A.PublicCode= B.PublicCode

    LEFT OUTER JOIN
  (
   SELECT
	PublicCode,sum(PackQty) AS Qtyout
    FROM STB_VN_FINISHGOODS 
	WHERE Statusout = N'Xuất' AND Statusout IS NOT NULL AND  Flag = 1
    GROUP BY PublicCode)C
  ON A.PublicCode=C.PublicCode
  
    INNER JOIN
  (
   SELECT
	PublicCode,PartNo
    FROM STB_VN_FINISHGOODS 
	WHERE Flag = 1 AND StatusSystem = N'Nhập'
    GROUP BY PublicCode,PartNo)T
  ON A.PublicCode=T.PublicCode

    LEFT OUTER JOIN
  (SELECT PublicCode,sum(PackQty) AS Qtylocation
  
    FROM STB_VN_FINISHGOODS 
	WHERE Country IN ('QA','Module',N'Đóng gói (Packing)',N'Sản Xuất (Production)') AND Statusout = N'Xuất' AND Statusout IS NOT NULL AND Flag = 1
    GROUP BY PublicCode)D
  ON A.PublicCode=D.PublicCode

  
    LEFT OUTER JOIN
  (SELECT PublicCode,sum(PackQty) AS TotalSale
    FROM STB_VN_FINISHGOODS 
	WHERE Country IN (N'Mỹ (America)',N'Trung Quốc (China)',N'Pháp (France)',N'Đài loan (Taiwan)',N'Hàn Quốc (Korea)',N'Tây Ban Nha (Spain)',N'Nga (Russia)',N'Bỉ (Belgium)',N'Hongkong',N'Ấn Độ (India)',N'Anh Quốc (English)',N'Thái Lan (Thalan)',N'Đức (Germany)') AND Statusout = N'Xuất' AND Statusout IS NOT NULL AND Flag = 1
    GROUP BY PublicCode)E
  ON A.PublicCode=E.PublicCode
)

SELECT 
DISTINCT 
PublicCode, 
REPLACE(RTRIM(PartNo), ' ',' ') AS PartNo,
'PCS' AS UNIT,
QtyInput,
Qtyout,
Qtylocation,
TotalSale,
CASE	
	WHEN Qtyout IS NULL	THEN QtyInput
	ELSE TotalCurrently
END AS Result,
CASE
	WHEN CAST(Qtylocation  AS NVARCHAR(50)) IS NULL AND CAST(TotalSale AS NVARCHAR(50)) IS NULL THEN N'Vẫn ở trong kho'
	WHEN CAST(Qtylocation  AS NVARCHAR(50)) IS NOT NULL AND CAST(TotalSale AS NVARCHAR(50)) IS NOT NULL THEN N'Xuất nội bộ, và xuất bán hàng'
	WHEN CAST(Qtylocation AS NVARCHAR(50)) IS NOT NULL  THEN N'Xuất nội bộ'
	WHEN CAST(TotalSale AS NVARCHAR(50)) IS NOT NULL THEN N'Xuất bán hàng'
	ELSE CAST(QtyInput AS NVARCHAR(50))  
	END AS StatusSale
	INTO #T1
FROM CTE
WHERE Flag = 1

CREATE TABLE #Tbl
(
	PublicCode NVARCHAR(50), 
	PartNo NVARCHAR(50),
	UNIT NVARCHAR(50),
	QtyInput INT,
	Qtyout INT,
	Qtylocation NVARCHAR(50),
	TotalSale NVARCHAR(50),
	Result INT,
	StatusSale NVARCHAR(50)
)
--QtyInput,Qtyout,Qtylocation,TotalSale,Result,
INSERT INTO #Tbl (QtyInput,Qtyout,Result)

SELECT 
		--PublicCode,
		--PartNo,
		--UNIT,
		   SUM(QtyInput) OVER (PARTITION BY PartNo ORDER BY PartNo) AS QtyInput,
		   SUM(Qtyout) OVER (PARTITION BY PartNo ORDER BY PartNo) AS Qtyout,
		   SUM(Result) OVER (PARTITION BY PartNo ORDER BY PartNo) AS Result--,
		   --SUM(Qtylocation) OVER (PARTITION BY PartNo ORDER BY PartNo) AS Qtylocation,
		   --SUM(TotalSale) OVER (PARTITION BY PartNo ORDER BY PartNo) AS TotalSale,
		--StatusSale
FROM
		#T1

SELECT
		QtyInput,
		Qtyout,
		Result
FROM
		#Tbl

ORDER BY 	
		QtyInput,Qtyout,Result DESC

DROP TABLE #T1
DROP TABLE #Tbl
		
END