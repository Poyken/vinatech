CREATE PROC [dbo].[usp_VN_GetData_FinishedGood]
@pDateget NVARCHAR(5)
AS
BEGIN
DECLARE @Days NVARCHAR(5) = @pDateget
if  Datepart(day,GETDATE()) = @Days  begin
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
	WHERE Country IN (N'Kỹ thuật sản phẩm',N'QA',N'Module',N'Đóng gói (Packing)',N'Sản Xuất (Production)') AND Statusout = N'Xuất' AND Statusout IS NOT NULL AND Flag = 1
    GROUP BY PublicCode)D
  ON A.PublicCode=D.PublicCode

  
    LEFT OUTER JOIN
  (SELECT PublicCode,sum(PackQty) AS TotalSale
    FROM STB_VN_FINISHGOODS 
	WHERE Country IN (
N'Ấn Độ (India)',
N'Anh Quốc (English)',
N'Australia',
N'Austria',
N'Bỉ (Belgium)',
N'Brazil',
N'Broad Band',
N'China',
N'Đài loan (Taiwan)',
N'Đức (Germany)',
N'Estonia',
N'Finland',
N'France',
N'Germany',
N'Hà lan (Netherlands)',
N'Hàn Quốc (Korea)',
N'hàn quốc(korea)',
N'HCM (Việt Nam)',
N'Hong kong',
N'Hongkong',
N'HUNGARY',
N'INDIA',
N'Israel',
N'Italy',
N'Kazakhstan',
N'KOREA',
N'MALAYSIA',
N'Moldova',
N'Mỹ (America)',
N'MYSORE, INDIA',
N'New Zealand',
N'Nga (Russia)',
N'Pháp (France)',
N'Poland(Phần Lan)',
N'SATCO(Sweden)',
N'Shanghai',
N'Singapore',
N'SLOVENIA',
N'South Africa',
N'Spain',
N'Special IND(Italy)',
N'Sweden',
N'Switzerland',
N'Taiwan',
N'Tây Ban Nha (Spain)',
N'Thái Lan (Thalan)',
N'Trung Quốc (China)',
N'TURKEY',
N'Turkey(Thổ Nhĩ Kỳ)',
N'UK',
N'UK (United Kingdom)',
N'Ukraine',
N'United Kingdom',
N'USA'
	) AND Statusout = N'Xuất' AND Statusout IS NOT NULL AND Flag = 1
    GROUP BY PublicCode)E
  ON A.PublicCode=E.PublicCode
)

SELECT 
DISTINCT 
PublicCode,
'' + replace(PartNo, ' ', '') + '' AS PartNo,
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

INSERT INTO STB_VN_CAPTURE_FINSHEDGOOD (PUBLICCODE,PARTNO ,UNIT,QTYINPUT,QTYOUT,QTYLOCATION,TOTALSALE,TOTALCURRENTLY,STATUSSALE,CAPUTER_DATE)
SELECT PublicCode, PartNo ,UNIT,QtyInput,Qtyout,Qtylocation,TotalSale,Result,StatusSale, GETDATE()
FROM #T1

 DROP TABLE #T1

END
end 

-- delete  STB_VN_CAPTURE_FINSHEDGOOD
-- select * from   STB_VN_CAPTURE_FINSHEDGOOD


 --select DISTINCT Country from STB_VN_FINISHGOODS 