-- =============================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Create date: 2022-10-21
-- Browsable : true
-- Group : 모듈관리
-- Description:	다이후쿠 향 Lot 및 출하정보
-- =============================================

CREATE PROCEDURE [dbo].[usp_ModuleProductionInfo_get]
						@pProcessUserID VARCHAR(20),
						@pProcessLanguage VARCHAR(20),
						@pFromDate DATE,
						@pToDate DATE
AS
BEGIN
	Declare @FromDate DATE = @pFromDate
	Declare @ToDate DATE = @pToDate

	SELECT MPI.ModuleProductionNo
          ,MPI.JobStartDate
          ,MPI.SemiProdLotNo1
          ,MPI.SemiProdLotNo2
          ,MPI.PinHoleQty
		  ,NULL AS DefectRate1
          ,MPI.ChangeCellQty
		  ,NULL AS DefectRate2
          ,MPI.DefectRepairRemark
          ,MPI.Farad
          ,MPI.ESR
          ,MPI.FinishedProdLotNo
          ,MPI.ShipmentDate
          ,MPI.ShipmentQty
          ,MPI.CreateDateTime
          ,MPI.CreateUserID
          ,MPI.ChangeDateTime
          ,MPI.ChangeUserID
	  FROM STB_ModuleProductionInfo MPI
	 WHERE (MPI.JobStartDate BETWEEN @FromDate AND @ToDate 
	         OR MPI.JobStartDate IS NULL)
	UNION ALL
	SELECT '합계'
          ,NULL
          ,NULL
          ,NULL
          ,SUM(MPI.PinHoleQty)
		  ,CASE WHEN SUM(MPI.ShipmentQty) = 0 THEN 0 ELSE SUM(MPI.PinHoleQty) / (SUM(MPI.ShipmentQty) * 136) * 100 END
          ,SUM(MPI.ChangeCellQty)
		  ,CASE WHEN SUM(MPI.ShipmentQty) = 0 THEN 0 ELSE SUM(MPI.ChangeCellQty) / (SUM(MPI.ShipmentQty) * 136) * 100 END
          ,NULL
          ,NULL
          ,NULL
          ,NULL
          ,NULL
          ,SUM(MPI.ShipmentQty)
          ,NULL
          ,NULL
          ,NULL
          ,NULL
	  FROM STB_ModuleProductionInfo MPI
	 WHERE (MPI.JobStartDate BETWEEN @FromDate AND @ToDate 
	         OR MPI.JobStartDate IS NULL)
END