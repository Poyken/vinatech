-- =============================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Create date: 2020.02.13
-- Browsable : true
-- Group : 자재관리
-- Description: 사업장별 원자재 입출고 창고 세팅 팝업
-- Modified:
-- =============================================
CREATE PROCEDURE usp_MaterialWarehouseInOutSet_popup
	@pProcessUserID varchar(20),
	@pProcessLanguage varchar(20),
	@pCompanyCode VARCHAR(20) = NULL,
	@pWorkCenterCode VARCHAR(20) = NULL
AS
BEGIN
	Declare @CompanyCode VARCHAR(20) = @pCompanyCode
	       ,@WorkCenterCode VARCHAR(20) = @pWorkCenterCode

	SELECT WarehouseInOutCode
	      ,WarehouseInOutName
		  ,SourceMaterialWarehouseCode
		  ,SourceMaterialWarehouseName
		  ,TargetMaterialWarehouseCode
		  ,TargetMaterialWarehouseName
	  FROM (
			SELECT 'O' AS WarehouseInOutCode
				  ,CASE WHEN @CompanyCode = 'VNT' THEN '출고' ELSE N'Vận chuyển' END AS WarehouseInOutName
				  ,CASE WHEN @CompanyCode = 'VNT' THEN 'ROH_WH' ELSE N'ROH_VN_WH' END AS SourceMaterialWarehouseCode
				  ,CASE WHEN @CompanyCode = 'VNT' THEN '원자재창고' ELSE N'Kho nguyên liệu (Việt Nam)' END AS SourceMaterialWarehouseName
				  ,CASE WHEN @CompanyCode = 'VNT' THEN 'ROUTE_WH' ELSE N'ROUTE_VN_WH' END AS TargetMaterialWarehouseCode
				  ,CASE WHEN @CompanyCode = 'VNT' THEN '공정창고' ELSE N'Kho xử lý (Việt Nam)' END AS TargetMaterialWarehouseName
			 UNION ALL
			SELECT 'I'
				  ,CASE WHEN @CompanyCode = 'VNT' THEN '반납' ELSE N'Trở về' END
				  ,CASE WHEN @CompanyCode = 'VNT' THEN 'ROUTE_WH' ELSE N'ROUTE_VN_WH' END
				  ,CASE WHEN @CompanyCode = 'VNT' THEN '공정창고' ELSE N'Kho xử lý (Việt Nam)' END
				  ,CASE WHEN @CompanyCode = 'VNT' THEN 'ROH_WH' ELSE N'ROH_VN_WH' END
				  ,CASE WHEN @CompanyCode = 'VNT' THEN '원자재창고' ELSE N'Kho nguyên liệu (Việt Nam)' END
		) A
END