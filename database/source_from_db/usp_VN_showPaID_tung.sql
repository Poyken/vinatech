CREATE PROC [dbo].[usp_VN_showPaID_tung] 
@PID NVARCHAR(50)
AS
BEGIN

WITH CTE AS
(
	SELECT 
	DISTINCT row_number() OVER(partition by A.PackingID order by A.PackingID) rn
	,A.ProductionDate
	,A.PackingID
	,A.MaterialCode
	,A.CreateUserID
	,A.MaterialLocationCode
	,A.MaterialWarehouseCode
	,A.CompanyCode
	,B.Total
	,N'Nhập' AS INPUT
	,'NSX' AS TYPEINPUT
	,SUBSTRING(C.MaterialName,7,40) AS PartNo
	,C.MaterialName
	,A.LotNo

  FROM
		STB_MaterialLotInfo A

  LEFT OUTER JOIN
  (
	 SELECT 
			 PackingID,
			max(PackQty) AS Total
	 FROM 
			STB_SavePackingTime_VVT B
 
  WHERE isPrinted = 1

  GROUP BY PackingID

  )B

ON A.PackingID = B.PackingID

  --LEFT OUTER JOIN
  --(
	 --SELECT 
		--	LotNo,PackingID
	 --FROM 
		--	STB_MaterialLotInfo E


  --GROUP BY LotNo,PackingID
  --  --ORDER BY LotNo DESC


  --)E
  
  --ON A.PackingID = E.PackingID

  LEFT OUTER JOIN
  (
	SELECT
			MaterialName,
			MaterialCode
	FROM
			stb_materialmaster C

  GROUP BY MaterialName,MaterialCode

  )C

  ON A.MaterialCode = C.MaterialCode
  where A.PackingID=@PID
)

SELECT
    TOP(1)
	 ProductionDate
	,PackingID
	,MaterialCode
	,CreateUserID
	,MaterialLocationCode
	,MaterialWarehouseCode
	,Total
	,INPUT
	,TYPEINPUT
	,PartNo
	,MaterialName
	,LotNo

FROM CTE

WHERE PackingID = @PID AND CompanyCode = 'VVT' AND (MaterialLocationCode like 'PROD%VN%' or MaterialWarehouseCode like 'PROD%VN%')

GROUP BY 

	 ProductionDate
	,PackingID
	,MaterialCode
	,CreateUserID
	,MaterialLocationCode
	,MaterialWarehouseCode
	,Total
	,INPUT
	,TYPEINPUT
	,PartNo
	,MaterialName
	,LotNo

ORDER BY LotNo DESC



-- SELECT * FROM STB_MaterialLotInfo WHERE  CompanyCode = 'VVT' AND ProductionDate = '2023-01-09' AND MaterialLocationCode = 'PROD_VN_WH_01'  AND PACKINGID ='PKNJ0600005'

-- EXEC usp_VN_showPaID 'PKNJ0900028'

-- SELECT * FROM STB_MaterialLotInfo WHERE  CompanyCode = 'VVT'  AND MaterialLocationCode = 'PROD_VN_WH_01'  AND PACKINGID ='PKNJ0900028'

--SELECT 
--SUBSTRING(MaterialName,7,40) AS PartNo,
--T1.LotNo,
--T2.MaterialName,
--T1.CreateUserID,
--T1.ProductionDate,
--T1.PackingID,
--T1.MaterialCode,
--SUM(T1.CurrentQty) AS Total,
--'NSX' AS TYPEINPUT,
--N'Nhập' AS INPUT
--FROM STB_MaterialLotInfo T1 
--LEFT JOIN  stb_materialmaster T2
--ON T1.MaterialCode = T2.MaterialCode
--WHERE T1.PackingID = @PID AND CompanyCode = 'VVT' AND MaterialLocationCode = 'PROD_VN_WH_01' 
--GROUP BY T1.PackingID,T1.MaterialCode,T1.ProductionDate,T1.CreateUserID,T2.MaterialName,T1.LotNo,T1.CreateDateTime
--ORDER BY T1.CreateDateTime DESC
END


--ProductionDate = '2023-01-06' AND

--select * from STB_SavePackingTime_VVT where PackingID ='PKNJ0900028'

-- EXEC usp_VN_showPaID_tung 'PKNJ0900028'