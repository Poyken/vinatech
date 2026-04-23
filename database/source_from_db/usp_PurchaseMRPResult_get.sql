-- =============================================
-- Author : Jackaroe(yjyu@vina.co.kr)
-- Group : 자재관리
-- Browsable : true
-- Create date : 2019-11-12
-- Description : 
-- Modified :
-- =============================================
CREATE PROCEDURE usp_PurchaseMRPResult_get
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pFromDate DATETIME,
	@pToDate DATETIME,
	@pProductClassCode VARCHAR(10) = NULL
AS
BEGIN
	Declare @FromDate VARCHAR(7) = CONVERT(VARCHAR(7), @pFromDate, 121)
	       ,@ToDate VARCHAR(7) = CONVERT(VARCHAR(7), @pToDate, 121)
	       ,@ProductClassCode VARCHAR(10) = CASE WHEN ISNULL(@pProductClassCode, '') = '' THEN 'VEC' ELSE @pProductClassCode END
		   
	SELECT A.BaseMonth
		  ,A.Volt
		  ,A.Farad
		  ,A.SizeW
		  ,A.SizeH
		  ,A.PlanQty
		  ,B.MaterialGroupName
		  ,B.MaterialName
		  ,B.UnitCode
		  ,B.UnitCost
		  ,B.UsedQty
		  ,B.UsedQty * CONVERT(NUMERIC(20,1), A.PlanQty) AS TotUsedQty
	  FROM (
			SELECT Volt
				  ,Farad
				  ,SizeW
				  ,SizeH
				  ,BaseMonth
				  ,SUM(PlanQty) * 1000 AS PlanQty
			  FROM STB_SalesMonthlyPlan SMP
			 GROUP BY SMP.Volt, SMP.Farad, SMP.SizeW, SMP.SizeH, SMP.BaseMonth
			) A
		LEFT OUTER JOIN (
			SELECT Volt
					,Farad
					,SizeW
					,SizeH
					,MaterialGroupName
					,MaterialName
					,UnitCode
					,MAX(UnitCost) AS UnitCost
					,MAX(UsedQty) AS UsedQty
				FROM STB_PurchaseBOM PB
				WHERE PB.ProductClassCode = @ProductClassCode
				AND PB.MaterialName <> ''
				GROUP BY PB.Volt, PB.Farad, PB.SizeW, PB.SizeH, PB.MaterialGroupName, PB.MaterialName, PB.UnitCode
		) B
		ON A.Volt = B.VOlt
	   AND A.Farad = B.Farad
	   AND A.SizeW = B.SizeW
	   AND A.SizeH = B.SizeH
	   WHERE A.BaseMonth BETWEEN @FromDate AND @ToDate
	   ORDER BY A.BaseMonth, A.Volt, A.Farad, A.SizeW, A.SizeH, B.MaterialGroupName, B.MaterialName
END