-- =============================================
-- Author:		Mr.Duy
-- Create date: 2025-01-10
-- Description:	Lấy mã kho đến có trường hợp ngoại lệ
-- ============================================= 
CREATE PROCEDURE [dbo].[usp_TargetMaterialWarehouse_popup] -- exec usp_TargetMaterialWarehouse_popup 'VVT', 'VVT_F4'
	@pCompanyCode VARCHAR(20) = NULL,
	@pWorkCenterCode VARCHAR(20) = NULL
AS
BEGIN

	SET NOCOUNT ON;
	
	DECLARE @CompanyCode VARCHAR(20) = CASE WHEN ISNULL(@pCompanyCode,'') = '' THEN '*' ELSE @pCompanyCode END
	DECLARE @WorkCenterCode VARCHAR(20) = CASE WHEN ISNULL(@pWorkCenterCode,'') = '' THEN '*' ELSE @pWorkCenterCode END
	
	IF @WorkCenterCode <> 'VVT_F4'
		BEGIN

			SELECT
			        MW.MaterialWarehouseCode,
			        MW.CompanyCode,
			        MW.WorkCenterCode,
			        MW.MaterialWarehouseName,
			        MW.MaterialWarehouseNameL,
			        MW.MaterialWarehouseDesc,
			        MW.MaterialWarehouseDescL,
			        MW.WHExtText01,
			        MW.WHExtText02,
			        MW.WHExtText03,
			        MW.WHExtText04,
			        MW.WHExtText05
			FROM
			        STB_MaterialWarehouse MW WITH(NOLOCK)
			        
			WHERE
					((@CompanyCode = '*') OR (MW.CompanyCode = @CompanyCode)) AND
					((@WorkCenterCode = '*') OR (MW.WorkCenterCode = @WorkCenterCode))
			union all
				select 
					Case 
						when @WorkCenterCode='VVT_F1'
							then 'ROH_BG_WH'
						when @WorkCenterCode='VVT_F2'
							then 'ROH_VN_WH'
						else 'NO_CONFIG'
					end
					
					 as MaterialWarehouseCode,
					'VVT',
					@WorkCenterCode,
					Case 
						when @WorkCenterCode='VVT_F1'
							then '원자재창고(베트남)'
						when @WorkCenterCode='VVT_F2'
							then 'Bg_원자재창고(베트남)'
						else 'NO_CONFIG'
					end as MaterialWarehouseName,
					'',
					'',
					'',
					'',
					'',
					'',
					'',
					''
			-- Mr.Manh update 2026-01-10: export to Bac Giang 2
			union all
				select 
					--Case 
					--	when @WorkCenterCode='VVT_F1'
					--		then 'ROH_BG_WH'
					--	when @WorkCenterCode='VVT_F2'
					--		then 'ROH_VN_WH'
					--	else 'NO_CONFIG'
					--end
					
					'MODULE_BG2_WH' as MaterialWarehouseCode,
					'VVT',
					@WorkCenterCode,
					--Case 
					--	when @WorkCenterCode='VVT_F1'
					--		then '원자재창고(베트남)'
					--	when @WorkCenterCode='VVT_F2'
					--		then 'Bg_원자재창고(베트남)'
					--	else 'NO_CONFIG'
					--end
					'BG2_모듈(베트남)' as MaterialWarehouseName,
					'',
					'',
					'',
					'',
					'',
					'',
					'',
					''
			END
		ELSE
			BEGIn
			SELECT
			        MW.MaterialWarehouseCode,
			        MW.CompanyCode,
			        MW.WorkCenterCode,
			        MW.MaterialWarehouseName,
			        MW.MaterialWarehouseNameL,
			        MW.MaterialWarehouseDesc,
			        MW.MaterialWarehouseDescL,
			        MW.WHExtText01,
			        MW.WHExtText02,
			        MW.WHExtText03,
			        MW.WHExtText04,
			        MW.WHExtText05
			FROM
			        STB_MaterialWarehouse MW WITH(NOLOCK)
			        
			WHERE
					((@CompanyCode = '*') OR (MW.CompanyCode = @CompanyCode)) AND
					((@WorkCenterCode = '*') OR (MW.WorkCenterCode = @WorkCenterCode))
			union all
				select 
					Case 
						when @WorkCenterCode='VVT_F1'
							then 'ROH_BG_WH'
						when @WorkCenterCode='VVT_F2'
							then 'ROH_VN_WH'
						else 'NO_CONFIG'
					end
					
					 as MaterialWarehouseCode,
					'VVT',
					@WorkCenterCode,
					Case 
						when @WorkCenterCode='VVT_F1'
							then '원자재창고(베트남)'
						when @WorkCenterCode='VVT_F2'
							then 'Bg_원자재창고(베트남)'
						else 'NO_CONFIG'
					end as MaterialWarehouseName,
					'',
					'',
					'',
					'',
					'',
					'',
					'',
					''
			END

END

