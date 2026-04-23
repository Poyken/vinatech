
-- =============================================
-- Author:	    Kim Han Young(hykim@awoo.co.kr)
-- Create date: 2018-07-23
-- Browsable : true
-- Group : 영업관리
-- Description:	판매계획 조회
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_SalesPlan_get]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pCompanyCode VARCHAR(20) = NULL,
	@pCompanyName VARCHAR(20) = NULL,
	@pFromPlanYearMonth VARCHAR(7) = NULL,
	@pToPlanYearMonth VARCHAR(7) = NULL

AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @FromPlanYearMonth VARCHAR(7) = @pFromPlanYearMonth,
			@ToPlanYearMonth VARCHAR(7) = @pToPlanYearMonth

	IF @ToPlanYearMonth IS NULL BEGIN
		SELECT
				SP.SalePlanCode AS OldSalePlanCode,
				SP.SalePlanCode,
				SP.CompanyCode,
				SP.ProductGroupCode,
				PG.ProductGroupName,
				SP.ModelCode,
				MBI.ModelName,
				SP.PlanYearMonth,
				SP.CustomerCode,
				CI.CustomerName,
				CI.CIExtText01,
				SP.PlanType,
				SP.PlanQty,
				SP.PlanBaiscPrice,
				SP.PlanQty * SP.PlanBaiscPrice AS PlanAmount,
				SP.CreateDateTime,
				SP.CreateUserID,
				SP.ChangeDateTime,
				SP.ChangeUserID
		FROM
				STB_SalesPlan SP WITH(NOLOCK)
				LEFT OUTER JOIN STB_ProductGroup PG WITH(NOLOCK)
					ON	PG.ProductGroupCode = SP.ProductGroupCode 
				LEFT OUTER JOIN STB_ModelBasicInfo MBI WITH(NOLOCK)
					ON	MBI.ModelCode = SP.ModelCode
				LEFT OUTER JOIN STB_CustomerInfo CI WITH(NOLOCK)
					ON	CI.CustomerCode = SP.CustomerCode 
		WHERE
				@FromPlanYearMonth <= SP.PlanYearMonth
	END ELSE BEGIN
		SELECT
				SP.SalePlanCode AS OldSalePlanCode,
				SP.SalePlanCode,
				SP.CompanyCode,
				SP.ProductGroupCode,
				PG.ProductGroupName,
				SP.ModelCode,
				MBI.ModelName,
				SP.PlanYearMonth,
				SP.CustomerCode,
				CI.CustomerName,
				CI.CIExtText01,
				SP.PlanType,
				SP.PlanQty,
				SP.PlanBaiscPrice,
				SP.PlanQty * SP.PlanBaiscPrice AS PlanAmount,
				SP.CreateDateTime,
				SP.CreateUserID,
				SP.ChangeDateTime,
				SP.ChangeUserID
		FROM
				STB_SalesPlan SP WITH(NOLOCK)
				LEFT OUTER JOIN STB_ProductGroup PG WITH(NOLOCK)
					ON	PG.ProductGroupCode = SP.ProductGroupCode 
				LEFT OUTER JOIN STB_ModelBasicInfo MBI WITH(NOLOCK)
					ON	MBI.ModelCode = SP.ModelCode
				LEFT OUTER JOIN STB_CustomerInfo CI WITH(NOLOCK)
					ON	CI.CustomerCode = SP.CustomerCode 
		WHERE
				@FromPlanYearMonth <= SP.PlanYearMonth AND
				SP.PlanYearMonth <= @ToPlanYearMonth
	END

END

