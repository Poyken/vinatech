

-- =============================================
-- Author:		Jeon Gyeong Ho(khjun@awoo.co.kr)
-- Create date: 2018-09-05
-- Browsable : true
-- Group : 사출&프레스 관리
-- Description:	품목별 실적조회
-- =============================================
CREATE PROCEDURE [dbo].[usp_MaterialProdHist_get]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pCompanyCode VARCHAR(20) = NULL,
	@pWorkCenterCode VARCHAR(20) = NULL,
	@pFromDate DATETIME = NULL,
	@pToDate DATETIME = NULL,
	@pShiftCode VARCHAR(1) = NULL,
	@pMoldNumber VARCHAR(20) = NULL,
	@pMachineCode VARCHAR(20) = NULL
AS
BEGIN
	SET NOCOUNT ON;
	
	DECLARE @CompanyCode VARCHAR(20) = CASE WHEN ISNULL(@pCompanyCode,'') = '' THEN '%' ELSE @pCompanyCode END
    DECLARE @WorkCenterCode VARCHAR(20) = CASE WHEN ISNULL(@pWorkCenterCode,'') = '' THEN '%' ELSE @pWorkCenterCode END
	DECLARE @FromDate DATE = @pFromDate
	DECLARE @ToDate DATE = @pToDate
	DECLARE @ShiftCode VARCHAR(1) = CASE WHEN ISNULL(@pShiftCode,'') = '' THEN '%' ELSE @pShiftCode END
	DECLARE @MoldNumber VARCHAR(20) = CASE WHEN ISNULL(@pMoldNumber,'') = '' THEN '%' ELSE @pMoldNumber END
	DECLARE @MachineCode VARCHAR(20) = CASE WHEN ISNULL(@pMachineCode,'') = '' THEN '%' ELSE @pMachineCode END
	
	SELECT
			MPPH.MoldProdNo AS OldMoldProdNo,
			MPPH.MoldProdNo,			
			MPPH.CompanyCode,
			CI.CompanyName,
			MPPH.WorkCenterCode,
			WCI.WorkCenterName,			
			MPH.JobDate,
			MPH.ShiftCode,
			MPH.MachineCode,
			MPM.MachineName,
			MPH.MoldNumber,
			MBI.MoldTypeCode,
			MTI.MoldTypeName,
			MBI.MoldCategory1,
			MBI.MoldCategory2,
			MBI.MoldCategory3,
			MBI.MoldCategory4,
			MBI.RawMaterial,			
			MPPH.MaterialCode,
			MM.MaterialName,			
			MPPD.PlanQty,
			MPPH.ProdQty,
			(MPPH.ProdQty - MPPH.DefectQty - ISNULL(MPPH.TryQty,0)) AS GoodQty,
			MPPH.DefectQty,
			MPPH.TryQty,
			
			CASE WHEN (ISNULL(MPPH.ProdQty,0)-ISNULL(MPPH.TryQty,0)) <= 0 THEN 0
			ELSE (CONVERT(BIGINT,MPPH.DefectQty) * 1000000 / (MPPH.ProdQty-ISNULL(MPPH.TryQty,0)))
			END AS PPM,
			--(PPH.DefectQty * 1000000 / PPH.ProdQty) AS PPM,
			
			CASE WHEN (ISNULL(MPPH.ProdQty,0)-ISNULL(MPPH.TryQty,0)) = 0 THEN 0
			ELSE ISNULL((MPPH.DefectQty/CONVERT(NUMERIC(10,2),ISNULL(MPPH.ProdQty,0)- ISNULL(MPPH.TryQty,0))) * 100,0.0)
			END AS DefectRate,
			MPH.ActStartDateTime,
			MPH.ActEndDateTime
			
	FROM
			STB_MoldProductProdHist MPPH WITH(NOLOCK)
			LEFT OUTER JOIN STB_MoldProdHist MPH WITH(NOLOCK)
				ON MPPH.MoldProdNo = MPH.MoldProdNo
			LEFT OUTER JOIN STB_MoldBasicInfo MBI WITH(NOLOCK)	
				ON MPH.MoldNumber = MBI.MoldNumber
			LEFT OUTER JOIN STB_MoldProductMachine MPM WITH(NOLOCK)
				ON MPH.MachineCode = MPM.MachineCode
			LEFT OUTER JOIN STB_MoldTypeInfo MTI WITH(NOLOCK)
				ON MBI.MoldTypeCode = MTI.MoldTypeCode
			LEFT OUTER JOIN STB_MoldProdPlanDetail MPPD WITH(NOLOCK)
				ON MPH.DayPlanNo = MPPD.DayPlanNo
				AND MPPH.MaterialCode = MPPd.MaterialCode
			LEFT OUTER JOIN STB_WorkCenterInfo WCI WITH(NOLOCK)
				ON MPPH.WorkCenterCode = WCI.WorkCenterCode
			LEFT OUTER JOIN STB_CompanyInfo CI WITH(NOLOCK)
				ON MPPH.CompanyCode = CI.CompanyCode
			LEFT OUTER JOIN STB_MaterialMaster MM WITH(NOLOCK)
				ON MPPH.MaterialCode = MM.MaterialCode	
	WHERE
			MPPH.CompanyCode LIKE @CompanyCode AND
			MPPH.WorkCenterCode LIKE @WorkCenterCode AND
			MPH.ShiftCode LIKE @ShiftCode AND
			MPH.MoldNumber LIKE @MoldNumber AND
			MPH.MachineCode LIKE @MachineCode AND
			(@FromDate <= MPH.JobDate AND MPH.JobDate <= @ToDate)
	ORDER BY
			MPM.DisplayIndex
END
