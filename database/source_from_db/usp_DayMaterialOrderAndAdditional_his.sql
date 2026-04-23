
-- =============================================
-- Author: Park Jong Hoon(jhpark@awoo.co.kr)
-- Create date: 2016-02-04
-- Browsable : true
-- Group : 자재관리
-- Description:	자재발주전표 IUD
-- Modified:  usp_DayMaterialOrderAndAdditional_his '','','VVT','VVT_F1','2024-11-26','2024-11-26','','','' 
-- Modified:  usp_DayMaterialOrderAndAdditional_his '','','','','','','','','241023000016' 
-- =============================================
CREATE PROCEDURE [dbo].[usp_DayMaterialOrderAndAdditional_his]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pCompanyCode VARCHAR(20) = NULL,
	@pWorkCenterCode VARCHAR(20) = NULL,
	@pFromDate DATE = NULL,
	@pToDate DATE = NULL,
	@pLineCode VARCHAR(20) = NULL,
	@pMaterialCode VARCHAR(20) = NULL,
	@pPoNo VARCHAR(20) = NULL
AS
BEGIN
	SET NOCOUNT ON;

   		DECLARE @CompanyCode VARCHAR(20) = CASE WHEN ISNULL(@pCompanyCode,'') = '' THEN '%' ELSE @pCompanyCode END
		DECLARE @WorkCenterCode VARCHAR(20) = CASE WHEN ISNULL(@pWorkCenterCode,'') = '' THEN '%' ELSE @pWorkCenterCode END
		DECLARE @LineCode VARCHAR(30) = CASE WHEN ISNULL(@pLineCode,'') = '' THEN '%' ELSE @pLineCode END
		DECLARE @FromDate DATE = @pFromDate
		DECLARE @ToDate DATE = @pToDate
		DECLARE @MaterialCode VARCHAR(30) = CASE WHEN ISNULL(@pMaterialCode,'') = '' THEN '%' ELSE @pMaterialCode END			 
		DECLARE @PoNo VARCHAR(30) = @pPoNo

	

		IF (@pPoNo IS NULL OR @pPoNo = '') 
					begin
							select * from STB_DayMaterialOrder 
							where 
								CAST(CreateDateTime AS DATE) BETWEEN @FromDate AND @ToDate
								AND  WorkCenterCode LIKE @WorkCenterCode 
								AND  LineCode LIKE @LineCode 
							order by createdatetime DESc
					end
		else
					begin
							select * from STB_DayMaterialOrder 
							where 
								 Pono=@PoNo
							order by createdatetime DESc
					end
END


