


-- =============================================
-- Author:		Jeon Gyeong Ho(khjun@awoo.co.kr)
-- Create date: 2018-09-05
-- Browsable : true
-- Group : 생산관리
-- Description:	금형생산실적 피벗 화면
-- =============================================
CREATE PROCEDURE [dbo].[usp_GetMoldProdHistReport]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pCompanyCode VARCHAR(20) = NULL,
	@pWorkCenterCode VARCHAR(20) = NULL,
	@pMoldNumber VARCHAR(20) = NULL,
	@pMachineCode VARCHAR(20) = NULL,
	@pStartDate DATE = NULL,
	@pEndDate DATE = NULL
AS
BEGIN
	SET NOCOUNT ON;
	
	DECLARE @CompanyCode VARCHAR(20) = CASE WHEN ISNULL(@pCompanyCode,'') = '' THEN '%' ELSE @pCompanyCode END
    DECLARE @WorkCenterCode VARCHAR(20) = CASE WHEN ISNULL(@pWorkCenterCode,'') = '' THEN '%' ELSE @pWorkCenterCode END
    DECLARE @MoldNumber VARCHAR(20) = CASE WHEN ISNULL(@pMoldNumber,'') = '' THEN '%' ELSE @pMoldNumber END
    DECLARE @MachineCode VARCHAR(20) = CASE WHEN ISNULL(@pMachineCode,'') = '' THEN '%' ELSE @pMachineCode END
    DECLARE @StartDate DATE = @pStartDate
	DECLARE @EndDate DATE = @pEndDate

	;WITH MoldProd AS
	(
		SELECT
				MPH.*
		FROM
				STB_MoldProdHist MPH WITH(NOLOCK)
		WHERE
				((@StartDate <= MPH.JobDate) AND (MPH.JobDate <= @EndDate)) AND
				MPH.CompanyCode LIKE @CompanyCode AND
				MPH.WorkCenterCode LIKE @WorkCenterCode AND
				MPH.MachineCode LIKE @MachineCode AND
				MPH.MoldNumber LIKE @MoldNumber
	), MoldProductHist AS
	(
		SELECT
				MPPH.MoldProdNo,
				SUM(MPPH.DefectQty) AS DefectQty,
				SUM(MPPH.ProdQty) - SUM(MPPH.TryQty) AS ProdQty,
				SUM(MPPH.TryQty) AS TryQty
		FROM
				STB_MoldProductProdHist MPPH WITH(NOLOCK)
		WHERE
				MPPH.MoldProdNo IN (SELECT MoldProdNo FROM MoldProd)
		GROUP BY
				MPPH.MoldProdNo
	)
	SELECT
			MPH.JobDate,
			MPH.ShiftCode,
			MPH.WorkerCode,
			WI.WorkerName,
			MPH.MachineCode,
			PM.MachineName,
			MPH.MoldNumber,
			MBI.MoldCategory1,					--차종
			MBI.MoldCategory2,					--품명
			MBI.MoldCategory3,					--규격
			MBI.RawMaterial,	
			SUM(MPH.ShotQty) AS ShotQty,
			SUM(MPPH.ProdQty) AS ProdQty,
			SUM(MPPH.DefectQty) AS DefectQty,
			SUM(MPPH.TryQty) AS TryQty			
	FROM
			MoldProd MPH WITH(NOLOCK)
			LEFT OUTER JOIN MoldProductHist MPPH WITH(NOLOCK)
				ON MPPH.MoldProdNo = MPH.MoldProdNo
			LEFT OUTER JOIN STB_MoldProductMachine PM WITH(NOLOCK)
				ON PM.MachineCode = MPH.MachineCode
			LEFT OUTER JOIN STB_ProdWorkerInfo WI WITH(NOLOCK)
				ON WI.WorkerCode = MPH.WorkerCode
			LEFT OUTER JOIN STB_MoldBasicInfo MBI WITH(NOLOCK)
				ON MBI.MoldNumber = MPH.MoldNumber
	WHERE
			((@StartDate <= MPH.JobDate) AND (MPH.JobDate <= @EndDate)) AND
			MPH.CompanyCode LIKE @CompanyCode AND
			MPH.WorkCenterCode LIKE @WorkCenterCode AND
			MPH.MachineCode LIKE @MachineCode AND
			MPH.MoldNumber LIKE @MoldNumber
	GROUP BY
			MPH.JobDate,
			MPH.ShiftCode,
			MPH.WorkerCode,
			WI.WorkerName,
			MPH.MachineCode,
			PM.MachineName,
			MPH.MoldNumber,
			MBI.MoldCategory1,
			MBI.MoldCategory2,
			MBI.MoldCategory3,
			MBI.RawMaterial
END
