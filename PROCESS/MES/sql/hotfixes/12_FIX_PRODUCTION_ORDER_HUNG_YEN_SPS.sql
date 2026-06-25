-- =============================================
-- Hotfix ID: 12_FIX_PRODUCTION_ORDER_HUNG_YEN_SPS
-- Target Object: usp_ProductionOrderInfo_HY_get, usp_ProductionOrderBom_HY_get, usp_GetMaterialGIForPO_HY, usp_ProductionOrderRouting_HY_get, usp_DoFixProductionOrder_HY, usp_ProductionOrderRouting_HY_iud, usp_DoCancelPO_HY
-- Author: vanduc
-- Date: 2026-06-11
-- Description: Tao 7 SP lien quan cho phan he Quan ly PO Hung Yen (_HY) tren cac bang dung chung.
-- =============================================

USE SmartFactoryV2;
GO

BEGIN TRAN;
GO

PRINT 'Starting Hotfix: 12_FIX_PRODUCTION_ORDER_HUNG_YEN_SPS...';
GO

-- =========================================================
-- 1. Stored Procedure: usp_ProductionOrderInfo_HY_get
-- =========================================================
IF EXISTS (SELECT 1 FROM sys.procedures WHERE name = 'usp_ProductionOrderInfo_HY_get')
    DROP PROCEDURE [dbo].[usp_ProductionOrderInfo_HY_get];
GO

CREATE PROCEDURE [dbo].[usp_ProductionOrderInfo_HY_get]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pFromYearMonth DATE  = NULL,
	@pToYearMonth DATE = NULL,
	@pProductGroupCode VARCHAR(20) = NULL,
	@pMaterialCode VARCHAR(20) = NULL,
	@pIsFix BIT = NULL,
	@pCompanyCode VARCHAR(20) = NULL,
	@pWorkCenterCode VARCHAR(20) = NULL
AS

BEGIN
	SET NOCOUNT ON;

    DECLARE @ProcessUserID      VARCHAR(20) = @pProcessUserID,
			    @ProcessLanguage  VARCHAR(20) = @pProcessLanguage,
			    @FromYearMonth    VARCHAR(7) = CONVERT(VARCHAR,@pFromYearMonth,120),
			    @ToYearMonth        VARCHAR(7) = CONVERT(VARCHAR,ISNULL(@pToYearMonth,'9999-12-31'),120),
			    @ProductGroupCode VARCHAR(20) = CASE WHEN ISNULL(@pProductGroupCode,'') = '' THEN '%' ELSE @pProductGroupCode END,
			    @MaterialCode         VARCHAR(20) = CASE WHEN ISNULL(@pMaterialCode,'') = '' THEN '%' ELSE @pMaterialCode END,
			    @IsFix BIT = @pIsFix

  DECLARE @CompanyCode    VARCHAR(20) = CASE WHEN ISNULL(@pCompanyCode,'') = '' THEN '%' ELSE @pCompanyCode END
  DECLARE @WorkCenterCode VARCHAR(20) = CASE WHEN ISNULL(@pWorkCenterCode,'') = '' THEN '%' ELSE @pWorkCenterCode END

	SELECT
			POI.PONo,
			POI.CompanyCode,
			POI.WorkCenterCode,
			POI.PlanYearMonth,
			POI.POType,
			POI.IsReworkPO,
			POI.MaterialCode,
			-- Check các trường hợp là case
			CASE 
                  WHEN MM.MaterialCode ='ECVT30-336' THEN 'VVVEC30-059'
				  WHEN MM.MaterialCode='ECVT30-344' then 'VVWEC30-054'
				  WHEN MM.MaterialCode='ECVT30-356' then 'VVWECT30-054'
				  WHEN MM.MaterialCode='ECVT27-322' then 'VVVEC27-001'
			      WHEN MM.MaterialCode='ECVT30-219' then 'VVVEC30-001'
				  WHEN MM.MaterialCode='ECVT30-371' then 'VVWEC30-078'
				  WHEN MM.MaterialCode='RE3000-100' then 'VVWEC30-056'
				  WHEN MM.MaterialCode='ECVT27-323' then 'VVWEC27-001'
				  WHEN MM.MaterialCode='ECVT30-220' then 'VVWEC30-001'
				  WHEN MM.MaterialCode='ECVT30-313' then 'VVWECT30-001'
				  WHEN MM.MaterialCode='ECVT30-331' then 'VVWEC30-044'
				  WHEN MM.MaterialCode='RE3000-131' then 'VVWEC30-075'
				  WHEN MM.MaterialCode='ECVT27-372' then 'VVVEC27-003'
				   WHEN MM.MaterialCode='ECVT30-278' then 'VVVEC30-004'
				   WHEN MM.MaterialCode='ECVT27-373' THEN 'VVWEC27-003'
				   WHEN MM.MaterialCode='ECVT30-276' THEN 'VVWEC30-004'
				   WHEN MM.MaterialCode='ECVT30-285' THEN 'VVWECT30-004'
				   WHEN MM.MaterialCode='ECVT30-268' THEN 'VVWEC30-005'
				   WHEN MM.MaterialCode='ECVT30-360' THEN 'VVWEC30-072'
				   WHEN MM.MaterialCode='ECVT30-229' THEN 'VNWEC30-032'
				   WHEN MM.MaterialCode='RE2700-089' THEN 'VVVET27-008'
				   WHEN MM.MaterialCode='LIVT38-018' THEN 'VNVEL38-001'
				   WHEN MM.MaterialCode='LIVT38-030' THEN 'VNVEL38-011'
				   WHEN MM.MaterialCode='LIVT38-019' THEN 'VNVEL38-002'
				   WHEN MM.MaterialCode='ECVT27-374' THEN 'VVVEC27-035'
				   WHEN MM.MaterialCode='ECVT30-279' THEN 'VVVEC30-006'
				   WHEN MM.MaterialCode='ECVT30-353' THEN 'VVWECT30-006'
				   WHEN MM.MaterialCode='LIVT38-026' THEN 'VNVEL38-006'
				   WHEN MM.MaterialCode='ECVT30-275' THEN 'VVWEC30-006'
				   WHEN MM.MaterialCode='ECVT30-281' THEN 'VVWEC30-007'
				   WHEN MM.MaterialCode='ECVT30-305' THEN 'VVWECT30-007'
				   WHEN MM.MaterialCode='RE2700-083' THEN 'VVVET27-001'
				   WHEN MM.MaterialCode='ECVT30-347' THEN 'VVWEC30-062'
				   WHEN MM.MaterialCode='ECVT27-334' THEN 'VVVEC27-005'
				   WHEN MM.MaterialCode='ECVT30-234' THEN 'VVVEC30-008'
				   WHEN MM.MaterialCode='ECVT30-335' THEN 'VVWECT30-008'
				   WHEN MM.MaterialCode='ECVT30-235' THEN 'VVWEC30-008'
				   WHEN MM.MaterialCode='ECVT30-283' THEN 'VVWEC30-012'
				   WHEN MM.MaterialCode='ECVT30-318' THEN 'VVWECT30-012'
				   WHEN MM.MaterialCode='ECVT27-367' THEN 'VVVEC27-011'
				   WHEN MM.MaterialCode='ECVT30-269' THEN 'VVVEC30-013'
				   WHEN MM.MaterialCode='ECVT27-368' THEN 'VVWEC27-011'
				   WHEN MM.MaterialCode='ECVT30-292' THEN 'VVWEC30-033'
				   WHEN MM.MaterialCode='ECVT30-270' THEN 'VVWEC30-013'
				   WHEN MM.MaterialCode='RDMD00-V01' THEN 'VVWEC30-048'
				   WHEN MM.MaterialCode='ECVT30-295' THEN 'VVWEC30-035'
				   WHEN MM.MaterialCode='ECVT27-399' THEN 'VVVET27-003'
				   WHEN MM.MaterialCode='ECVT27-343' THEN 'VVVEC27-012'
				   WHEN MM.MaterialCode='ECVT30-246' THEN 'VVVEC30-014'
				   WHEN MM.MaterialCode='ECVT30-345' THEN 'VVWEC30-055'
				   WHEN MM.MaterialCode='ECVT28-001' THEN 'VVVEC28-001'
				   WHEN MM.MaterialCode='ECVT25-116' THEN 'VVVEC30-047'
				   WHEN MM.MaterialCode='ECVT27-344' THEN 'VVWEC27-012'
				   WHEN MM.MaterialCode='ECVT27-370' THEN 'VVWEC27-015'
				   WHEN MM.MaterialCode='ECVT30-247' THEN 'VVWEC30-014'
				   WHEN MM.MaterialCode='ECVT30-307' THEN 'VVWECT30-014'
				   WHEN MM.MaterialCode='RE3000-119' THEN 'VVWEC30-074'
				   WHEN MM.MaterialCode='ECVT30-334' THEN 'VVWEC30-039'
				   WHEN MM.MaterialCode='RE3000-129' THEN 'VVWEC30-073'
				   WHEN MM.MaterialCode='RE3000-134' THEN 'VVWEC30-076'
				   WHEN MM.MaterialCode='ECVT30-346' THEN 'VVWEC30-065'
				   WHEN MM.MaterialCode='ECVT27-386' THEN 'VVVEC27-014'
				   WHEN MM.MaterialCode='RE3000-105' THEN 'VVWEC30-059'
				   WHEN MM.MaterialCode='ECVT30-301' THEN 'VVWECT30-037'
				   WHEN MM.MaterialCode='ECVT27-388' THEN 'VVVET27-004'
				   WHEN MM.MaterialCode='LIVT38-007' THEN 'VNVEL38-004'
				   WHEN MM.MaterialCode='RE3800-019' THEN 'VNVEL38-014'
				   WHEN MM.MaterialCode='RE3000-109' THEN 'VVWEC30-067'
				   WHEN MM.MaterialCode='ECVT30-367' THEN 'VVWEC30-024'
				   WHEN MM.MaterialCode='ECVT30-369' THEN 'VVWECT30-024'
				   WHEN MM.MaterialCode='ECVT30-309' THEN 'VVWEC30-038'
				   WHEN MM.MaterialCode='RE2700-090' THEN 'VVVET27-011'
				   WHEN MM.MaterialCode='LIVT38-032' THEN 'VNVEL38-012'
				   WHEN MM.MaterialCode='LIVT38-016' THEN 'VNVEL38-020'
				   WHEN MM.MaterialCode='LIVT38-035' THEN 'VNVEL38-019'
				   WHEN MM.MaterialCode='ECVT30-250' THEN 'VVWEC30-017'
				   WHEN MM.MaterialCode='ECVT30-341' THEN 'VVWECT30-017'
				   WHEN MM.MaterialCode='RE3000-098' THEN 'VVWEC30-052'
				   WHEN MM.MaterialCode='ECVT30-352' THEN 'VVWEC30-060'
				   WHEN MM.MaterialCode='RE3000-123' THEN 'VVWEC30-068'
				   WHEN MM.MaterialCode='ECVT30-251' THEN 'VVVEC30-022'
				   WHEN MM.MaterialCode='ECVT27-350' THEN 'VVWEC27-018'
				   WHEN MM.MaterialCode='ECVT30-359' THEN 'VVWEC30-071'
				   WHEN MM.MaterialCode='ECVT30-262' THEN 'VVWEC30-018'
				   WHEN MM.MaterialCode='ECVT30-350' THEN 'VVWECT30-018'
				   WHEN MM.MaterialCode='ECVT27-383' THEN 'VVVEC27-017'
				   WHEN MM.MaterialCode='ECVT30-134' THEN 'VVVEC30-044'
				   WHEN MM.MaterialCode='ECVT30-312' THEN 'VVWECT30-022'
				   WHEN MM.MaterialCode='ECVT30-288' THEN 'VVVEC30-045'
				   WHEN MM.MaterialCode='ECVT30-289' THEN 'VVVEC30-050'
				   WHEN MM.MaterialCode='ECVT27-405' THEN 'VVVET27-010'
				   WHEN MM.MaterialCode='RE2700-088' THEN 'VVVET27-005'
				   WHEN MM.MaterialCode='ECVT30-354' THEN 'VVWEC30-066'
				   WHEN MM.MaterialCode='LIVT38-008' THEN 'VNVEL38-008'
				   WHEN MM.MaterialCode='LIVT30-022'  THEN 'VNVEL38-005'
                   WHEN MM.MaterialCode='RE3800-026'  THEN 'VNVEL38-016'
				   WHEN MM.MaterialCode='LIVT38-031'  THEN 'VNVEL38-013'
				   WHEN MM.MaterialCode='LIVT38-033'  THEN 'VNVEL38-017'
				   WHEN MM.MaterialCode='LIVT38-034'  THEN 'VNVEL38-018'
				   WHEN MM.MaterialCode='LIVT38-027'  THEN 'VNVEL38-003'
				   WHEN MM.MaterialCode='LIVT38-015'  THEN 'VNVEL38-015'
				   WHEN MM.MaterialCode='ECVT30-333'  THEN 'VVVEC30-057'
				   WHEN MM.MaterialCode='ECVT27-382'  THEN 'VVVEC27-032'
				   WHEN MM.MaterialCode='ECVT27-403'  THEN 'VVVEC27-040'
				   WHEN MM.MaterialCode='ECVT30-310'  THEN 'VVWEC30-045'
				   WHEN MM.MaterialCode='ECVT27-352'  THEN 'VVVEC27-020'
				   WHEN MM.MaterialCode='ECVT30-254'  THEN 'VVVEC30-023'
				   WHEN MM.MaterialCode='ECVT30-120'  THEN 'VVVEC30-024'
				   WHEN MM.MaterialCode='ECVT27-353'  THEN 'VVWEC27-020'
				   WHEN MM.MaterialCode='ECVT30-297'  THEN 'YSECVT30-317'
				   WHEN MM.MaterialCode='ECVT30-317'  THEN 'VVWEC30-040'
				   WHEN MM.MaterialCode='ECVT30-348'  THEN 'VVWEC30-063'
				   WHEN MM.MaterialCode='ECVT30-273'  THEN 'VVWEC30-026'
				   WHEN MM.MaterialCode='RE3000-122'  THEN 'VVWEC30-069'
				   WHEN MM.MaterialCode='HCVT23-061'  THEN 'VVVHC23-007'
				   WHEN MM.MaterialCode='ECVT27-401'  THEN 'VVVET27-007'
				   WHEN MM.MaterialCode='ECVT30-284'  THEN 'VVWEC30-028'
				   WHEN MM.MaterialCode='ECVT27-356'  THEN 'VVWEC27-022'
				   WHEN MM.MaterialCode='ECVT27-397'  THEN 'VVWECT27-022'
				   WHEN MM.MaterialCode='ECVT27-355'  THEN 'VVVEC27-022'
				   WHEN MM.MaterialCode='ECVT27-358'  THEN 'VVVEC27-023'
				   WHEN MM.MaterialCode='ECVT30-343'  THEN 'VVWEC30-053'
				   WHEN MM.MaterialCode='ECVT30-261'  THEN 'VVWEC30-030'
				   WHEN MM.MaterialCode='ECVT27-400'  THEN 'VVVET27-006'
				   WHEN MM.MaterialCode='ECVT30-258'  THEN 'VVWEC30-029'
				   WHEN MM.MaterialCode='ECVT30-257'  THEN 'VVVEC30-029'
				   WHEN MM.MaterialCode='ECVT30-260'  THEN 'VVVEC30-030'
				   WHEN MM.MaterialCode='RE3000-120'  THEN 'VVVEC30-061'
				   WHEN MM.MaterialCode='ECVT30-271'  THEN 'VVVEC30-031'
				   WHEN MM.MaterialCode='ECVT30-287'  THEN 'VVWEC30-036'
				   WHEN MM.MaterialCode='ECVT27-247'  THEN 'VVVEC27-025'
				   WHEN MM.MaterialCode='ECVT30-115'  THEN 'VVVEC30-033'
				   WHEN MM.MaterialCode='ECVT30-316'  THEN 'VVVEC30-054'
				   WHEN MM.MaterialCode='ECVT30-113'  THEN 'VVVEC30-032'
				   WHEN MM.MaterialCode='ECVT30-372'  THEN 'VVVEC30-056'
				   WHEN MM.MaterialCode='RE3000-125'  THEN 'VVVEC30-063'
				   WHEN MM.MaterialCode='RE3000-136'  THEN 'VVVEC30-041'
				   WHEN MM.MaterialCode='ECVT30-215'  THEN 'VVVEC30-052'
				   WHEN MM.MaterialCode='RE3000-116'  THEN 'VVVES-001'
				   WHEN MM.MaterialCode='RE3000-096'  THEN 'VVVEC30-S01'
				   WHEN MM.MaterialCode='ECVT30-342'  THEN 'VVVEC30-058'
				   WHEN MM.MaterialCode='ECVT30-104'  THEN 'VNVEC30-039'
				   WHEN MM.MaterialCode='ECVT27-213'  THEN 'VVVEC27-028'
				   WHEN MM.MaterialCode='ECVT30-204'  THEN 'VVVEC30-035'
				   WHEN MM.MaterialCode='ECVT30-370'  THEN 'SGSJHSC-001'
				   WHEN MM.MaterialCode='RE3000-118'  THEN 'VVVES-002'
				   WHEN MM.MaterialCode='ECVT30-116'  THEN 'VVVEC30-038'
				   WHEN MM.MaterialCode='RE3000-071'  THEN 'VVVEC30-S56'
				   WHEN MM.MaterialCode='ECVT30-076'  THEN 'VVVEC30-043'
				   WHEN MM.MaterialCode='ECVT30-358'  THEN 'VVVEC30-062'
				   WHEN MM.MaterialCode='ECVT30-117'  THEN 'VVVEC30-046'
				   WHEN MM.MaterialCode='RDMD00-287'  THEN 'MVCE60-096'
				   WHEN MM.MaterialCode='RDMD00-307'  THEN 'MVCE60-103'
				   WHEN MM.MaterialCode='RDMD00-345'  THEN 'MVCE60-119'
				   WHEN MM.MaterialCode='RDMD00-301'  THEN 'MVCE60-100'
				   WHEN MM.MaterialCode='RDMD00-330'  THEN 'MVCE60-109'
				   WHEN MM.MaterialCode='ECVT54-055'  THEN 'MVCE54-001'
				   WHEN MM.MaterialCode='EDVTMD-153'  THEN 'MVCE54-003'
				   WHEN MM.MaterialCode='EDVTMD-142'  THEN 'MVCE54-024'
				   WHEN MM.MaterialCode='EDVTMD-206'  THEN 'MVCE54-026'
				   WHEN MM.MaterialCode='EDVTMD-161'  THEN 'MVCE60-001'
				   WHEN MM.MaterialCode='EDVTMD-151'  THEN 'MVCE60-002'
				   WHEN MM.MaterialCode='EDVTMD-203'  THEN 'MVCE60-087'
				   WHEN MM.MaterialCode='EDVTMD-152'  THEN 'MVCE60-003'
				   WHEN MM.MaterialCode='RDMD00-349'  THEN 'MVCE60-123'
				   WHEN MM.MaterialCode='RDMD00-350'  THEN 'MVCE60-122'
				   WHEN MM.MaterialCode='EDVTMD-237'  THEN 'MVCE60-137'
				   WHEN MM.MaterialCode='EDVTMD-205'  THEN 'MVCE60-086'
				   WHEN MM.MaterialCode='EDVTMD-146'  THEN 'MVCE54-004'
				   WHEN MM.MaterialCode='RDMD00-369'  THEN 'MVCE54-131'
				   WHEN MM.MaterialCode='ECVT54-060'  THEN 'MVCE54-005'
				   WHEN MM.MaterialCode='EDVTMD-190'  THEN 'MVCE60-019'
				   WHEN MM.MaterialCode='EDVTMD-187'  THEN 'MVCE60-007'
				   WHEN MM.MaterialCode='EDVTMD-095'  THEN 'MVCE60-018'
				   WHEN MM.MaterialCode='EDVTMD-217'  THEN 'MVCE90-002'
				   WHEN MM.MaterialCode='EDVTMD-174'  THEN 'MVCE60-027'
				   WHEN MM.MaterialCode='RDMD00-238'  THEN 'MVCE60-076'
				   WHEN MM.MaterialCode='EDVTMD-230'  THEN 'MVCE60-128'
				   WHEN MM.MaterialCode='RDMD00-378'  THEN 'MVCE60-138'
				   WHEN MM.MaterialCode='EDVTMD-188'  THEN 'MVCE60-075'
				   WHEN MM.MaterialCode='RDMD00-313'  THEN 'MVCE60-101'
				   WHEN MM.MaterialCode='EDVTMD-199'  THEN 'MVCE60-085'
				   WHEN MM.MaterialCode='EDVTMD-197'  THEN 'MVCE60-079'
				   WHEN MM.MaterialCode='EDVTMD-201'  THEN 'MVCE60-084'
				   WHEN MM.MaterialCode='EDVTMD-235'  THEN 'MMVCE60-136'
				   WHEN MM.MaterialCode='RDMD00-292'  THEN 'MVCE60-117'
				   WHEN MM.MaterialCode='RDMD00-203'  THEN 'MVCE60-088'
				   WHEN MM.MaterialCode='EDVTMD-204'  THEN 'MVCE60-089'
				   WHEN MM.MaterialCode='EDVTMD-169'  THEN 'MVCE90-001'
				   WHEN MM.MaterialCode='EDVTMD-182'  THEN 'MVCE60-020'
				   WHEN MM.MaterialCode='RDMD00-353'  THEN 'MVCE60-124'
				   WHEN MM.MaterialCode='EDVTMD-207'  THEN 'MVCE60-080'
				   WHEN MM.MaterialCode='RDMD00-285'  THEN 'MVCE54-056'
				   WHEN MM.MaterialCode='ECVT54-054'  THEN 'MVCE54-050'
				   WHEN MM.MaterialCode='EDVTMD-193'  THEN 'MVCE60-063'
				   WHEN MM.MaterialCode='RDMD00-347'  THEN 'MVCE60-121'
				   WHEN MM.MaterialCode='EDVTMD-234'  THEN 'MVCE60-129'
				   WHEN MM.MaterialCode='EDVTMD-S01'  THEN 'MVCE60-104'
				   WHEN MM.MaterialCode='RDMD00-339'  THEN 'MVCE60-114'
				   WHEN MM.MaterialCode='EDVTMD-221'  THEN 'MVCE60-016'
				   WHEN MM.MaterialCode='RDMD00-319'  THEN 'MVCE60-105'
				   WHEN MM.MaterialCode='EDVTMD-191'  THEN 'MVCE60-070'
				   WHEN MM.MaterialCode='EDVTMD-232'  THEN 'MVCE60-132'
				   WHEN MM.MaterialCode='ECVT54-009'  THEN 'MVCE54-009'
				   WHEN MM.MaterialCode='ECVT54-056'  THEN 'MVCE54-010'
				   WHEN MM.MaterialCode='ECVT60-013'  THEN 'MVCE60-008'
				   WHEN MM.MaterialCode='EDVTMD-210'  THEN 'MVCE60-095'
				   WHEN MM.MaterialCode='ECVT60-011'  THEN 'MVCE60-009'
				   WHEN MM.MaterialCode='RDMD00-217'  THEN 'MVCE60-036'
				   WHEN MM.MaterialCode='EDVTMD-181'  THEN 'MVCE60-034'
				   WHEN MM.MaterialCode='EDVTMD-179'  THEN 'MVCE60-064'
				   WHEN MM.MaterialCode='EDVTMD-184'  THEN 'MVCE60-066'
				   WHEN MM.MaterialCode='RDMD00-329'  THEN 'MVCE60-108'
				   WHEN MM.MaterialCode='EDVTMD-231'  THEN 'MVCE60-134'
				   WHEN MM.MaterialCode='EDVTMD-149'  THEN 'MVCE54-015'
				   WHEN MM.MaterialCode='EDVTMD-127'  THEN 'MVCE54-128'
				   WHEN MM.MaterialCode='ECVT60-020'  THEN 'MVCE60-067'
				   WHEN MM.MaterialCode='RDMD00-V02'  THEN 'MVCE60-091'
				   WHEN MM.MaterialCode='RDMD00-332'  THEN 'MVCE60-112'
				   WHEN MM.MaterialCode='RDMD00-228'  THEN 'MVCE60-073'
				   WHEN MM.MaterialCode='EDVTMD-200'  THEN 'MVCE60-072'
				   WHEN MM.MaterialCode='RDMD00-282'  THEN 'MVCE60-097'
				   WHEN MM.MaterialCode='EDVTMD-158'  THEN 'MVCE54-031'
				   WHEN MM.MaterialCode='RDMD00-230'  THEN 'MVCE54-129'
				   WHEN MM.MaterialCode='EDVTMD-163'  THEN 'MVCC60-071'
				   WHEN MM.MaterialCode='RDMD00-380'  THEN 'MVCE54-132'
				   WHEN MM.MaterialCode='EDVTMD-139'  THEN 'MVCR01-006'
				   WHEN MM.MaterialCode='EDVTMD-148'  THEN 'MVCE54-016'
				   WHEN MM.MaterialCode='EDVTMD-167'  THEN 'MVCE54-017'
				   WHEN MM.MaterialCode='EDVTMD-202'  THEN 'MVCE54-055'
				   WHEN MM.MaterialCode='RDMD00-364'  THEN 'MVCE54-130'
				   WHEN MM.MaterialCode='ECVT60-009'  THEN 'MVCC60-011'
				   WHEN MM.MaterialCode='EDVTMD-194'  THEN 'MVCE60-012'
				   WHEN MM.MaterialCode='EDVTMD-192'  THEN 'MVCE60-025'
				   WHEN MM.MaterialCode='RDMD00-123'  THEN 'MVCE60-026'
				   WHEN MM.MaterialCode='ECVT60-010'  THEN 'MVCE60-030'
				   WHEN MM.MaterialCode='RDMD00-261'  THEN 'MVCC60-098'
				   WHEN MM.MaterialCode='EDVTMD-226'  THEN 'MVCE60-113'
				   WHEN MM.MaterialCode='RDMD00-136'  THEN 'MVCC120-002'
				   WHEN MM.MaterialCode='EDVTMD-164'  THEN 'MVCE54-019'
				   WHEN MM.MaterialCode='ECVT54-061'  THEN 'MVCE54-020'
				   WHEN MM.MaterialCode='ECVT60-012'  THEN 'MVCC60-013'
				   WHEN MM.MaterialCode='EDVTMD-222'  THEN 'MVCE60-094'
				   WHEN MM.MaterialCode='RDMD00-322'  THEN 'MVCE60-102'
				   WHEN MM.MaterialCode='EDVTMD-220'  THEN 'MVCE60-107'
				   WHEN MM.MaterialCode='RDMD00-272'  THEN 'MVCE60-069'
				   WHEN MM.MaterialCode='EDVTMD-198'  THEN 'MVCE60-078'
				   WHEN MM.MaterialCode='EDVTMD-156'  THEN 'MVCE60-015'
				   WHEN MM.MaterialCode='RDMD00-346'  THEN 'MVCE60-120'
				   WHEN MM.MaterialCode='RDMD00-356'  THEN 'MVCE60-126'
				   WHEN MM.MaterialCode='RDMD00-366'  THEN 'MVCE60-135'
				   WHEN MM.MaterialCode='RDMD00-360'  THEN 'MVCE60-130'
				   WHEN MM.MaterialCode='RDMD00-355'  THEN 'MVCE60-127'
				   WHEN MM.MaterialCode='EDVTMD-118'  THEN 'MVCC60-062'
				   WHEN MM.MaterialCode='RDMD00-289'  THEN 'MVCE60-082'
				   WHEN MM.MaterialCode='RDMD00-250'  THEN 'MVCE60-083'
				   WHEN MM.MaterialCode='RDMD00-276'  THEN 'MVCE60-092'
				   WHEN MM.MaterialCode='RDMD00-359'  THEN 'MVCE60-131'
				   WHEN MM.MaterialCode='RDMD00-266'  THEN 'MVCE60-090'
				   WHEN MM.MaterialCode='EDVTMD-183'  THEN 'MVCE90-065'
				   WHEN MM.MaterialCode='RDMD00-368'  THEN 'MVCE90-066'
				   WHEN MM.MaterialCode='ECVT54-033'  THEN 'MVCE54-039'
				   WHEN MM.MaterialCode='EDVTMD-160'  THEN 'MVCE120-001'
				   WHEN MM.MaterialCode='EDVTMD-216'  THEN 'MVCE120-003'
				   WHEN MM.MaterialCode='EDVTMD-144'  THEN 'MVCE60-017'
                  ELSE ''
            END AS MaterialCodeVN,
			CASE
			    WHEN MM.MaterialCode='ECVT27-344' THEN 'HY-CAP WEC2R7106QG (1030 Low)'
				else MM.MaterialName
			end as MaterialName,
			POI.BomVersion,
			POI.PlanQty,
			POI.ProdOrderQty,
			POI.ProdFinishQty,
			(POI.PlanQty - POI.ProdFinishQty) AS  DiffQty,
			POI.ProdOrderQty / POI.PlanQty * 100.0 AS ProdOrderRate,
			POI.ProdFinishQty / POI.PlanQty * 100.0 AS ProdRate,
			POI.IsFix,
			POI.FixUserID,
			POI.FixDateTime,
			POI.IsCancel,
			POI.CancelDateTime,
			POI.CancelUserID,
			POI.POExtText01,
			POI.POExtText02,
			POI.POExtText03,
			POI.POExtText04,
			POI.POExtText05,
			POI.BasicRoutingCode,
			BRI.BasicRoutingName,
			POI.CreateDateTime,
			POI.CreateUserID,
			POI.ChangeDateTime,
			POI.ChangeUserID,
		
			MM.ProductGroupCode,
			MM.MaterialUnit,
			POI.LotBeforeReDroping, 
			POI.DefectSummaryNoBeforeDroping 
	FROM
			                       STB_ProductionOrderInfo POI WITH(NOLOCK)
			LEFT OUTER JOIN STB_MaterialMaster MM        WITH(NOLOCK)	 ON MM.MaterialCode = POI.MaterialCode
			LEFT OUTER JOIN STB_BasicRoutingInfo BRI       WITH(NOLOCK)  ON BRI.BasicRoutingCode = POI.BasicRoutingCode

	WHERE 1=1
			AND @FromYearMonth <= POI.PlanYearMonth 
			AND POI.PlanYearMonth <= @ToYearMonth 
			AND ISNULL(MM.ProductGroupCode, '') LIKE @ProductGroupCode + '%'
			AND POI.MaterialCode LIKE @MaterialCode 
			AND POI.IsCancel = 0 
			AND (@IsFix IS NULL OR POI.IsFix = @IsFix)
			AND POI.CompanyCode LIKE @CompanyCode 
			AND POI.WorkCenterCode LIKE @WorkCenterCode

	ORDER BY
			POI.PONo

END
GO

PRINT 'Procedure usp_ProductionOrderInfo_HY_get created successfully.';
GO

-- =========================================================
-- 2. Stored Procedure: usp_ProductionOrderBom_HY_get
-- =========================================================
IF EXISTS (SELECT 1 FROM sys.procedures WHERE name = 'usp_ProductionOrderBom_HY_get')
    DROP PROCEDURE [dbo].[usp_ProductionOrderBom_HY_get];
GO

CREATE PROCEDURE [dbo].[usp_ProductionOrderBom_HY_get]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pPONo VARCHAR(20)  = NULL,
	@pMaterialCode VARCHAR(50) = NULL,
	@pIsUseAll BIT = NULL
AS
BEGIN
	SET NOCOUNT ON;

    DECLARE @ProcessUserID VARCHAR(20) = @pProcessUserID,
			@ProcessLanguage VARCHAR(20) = @pProcessLanguage,
			@PONo VARCHAR(20) = @pPONo,
			@MaterialCode VARCHAR(50) = CASE WHEN ISNULL(@pMaterialCode,'') = '' THEN '%' ELSE @pMaterialCode END,
			@IsUseAll BIT = CASE WHEN ISNULL(@pIsUseAll,0) = 1 THEN 0 ELSE 1 END

	SELECT TOP 10
			CASE
				WHEN POB.ParentId IS NULL THEN 1
				ELSE 2
			END AS Seq,
			POB.Id,
			POB.ParentId,
			POB.MaterialCode,
			MM.MaterialName,
			POB.BomVersion,
			POB.ChildMaterialCode,
			CMM.MaterialName AS ChildMaterialName,
			CMM.MaterialTypeCode,
			MT.MaterialTypeName,
			CMM.MaterialSpec,
			CMM.ProductGroupCode,
			PG.ProductGroupName,
			POB.ChildBomVersion,
			POB.BomUnit,
			CMM.MaterialUnit,
			ISNULL((
				SELECT
						SUM(MS.StockQty)
				FROM
						STB_MaterialStock MS WITH(NOLOCK)
				WHERE
						MS.CompanyCode = PO.CompanyCode AND
						MS.WorkCenterCode = PO.WorkCenterCode AND
						MS.MaterialCode = POB.ChildMaterialCode AND
						MS.MaterialStockAttribute = 'NORMAL'
			),0) AS StockQty,
			POB.UsedQty,
			POB.TotalUsedQty,
			POB.RouteCode,
			POB.IsOptionItem,
			POB.BomDetailDesc,
			POB.StdCombSec
	FROM
			STB_ProductionOrderBom POB WITH(NOLOCK)
			INNER JOIN STB_ProductionOrderInfo PO WITH(NOLOCK)
				ON	PO.PONo = POB.PONo
			LEFT OUTER JOIN STB_MaterialMaster MM WITH(NOLOCK)
				ON	MM.MaterialCode = POB.MaterialCode
			LEFT OUTER JOIN STB_MaterialMaster CMM WITH(NOLOCK)
				ON	CMM.MaterialCode = POB.ChildMaterialCode
			LEFT OUTER JOIN STB_MaterialType MT WITH(NOLOCK)
				ON	MT.MaterialTypeCode = CMM.MaterialTypeCode
			LEFT OUTER JOIN STB_ProductGroup PG WITH(NOLOCK)
				ON	PG.ProductGroupCode = CMM.ProductGroupCode
	WHERE
			POB.PONo = @PONo AND
			POB.MaterialCode LIKE @MaterialCode AND
			POB.IsUseProduction IN (1,@IsUseAll)
	ORDER BY
			CASE
				WHEN POB.ParentId IS NULL THEN 1
				ELSE 2
			END,
			POB.MaterialCode,
			POB.BomVersion
END
GO

PRINT 'Procedure usp_ProductionOrderBom_HY_get created successfully.';
GO

-- =========================================================
-- 3. Stored Procedure: usp_GetMaterialGIForPO_HY
-- =========================================================
IF EXISTS (SELECT 1 FROM sys.procedures WHERE name = 'usp_GetMaterialGIForPO_HY')
    DROP PROCEDURE [dbo].[usp_GetMaterialGIForPO_HY];
GO

CREATE PROCEDURE [dbo].[usp_GetMaterialGIForPO_HY]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pPONo VARCHAR(20) = NULL
AS
BEGIN
	SET NOCOUNT ON;

    DECLARE @ProcessUserID VARCHAR(20) = @pProcessUserID,
			@ProcessLanguage VARCHAR(20) = @pProcessLanguage,
			@PONo VARCHAR(20) = @pPONo

	SELECT
			MDI.MaterialDocNo,
			MDI.SourceMaterialWarehouseCode,
			SMW.MaterialWarehouseName AS SourceMaterialWarehouseName,
			MDI.TargetMaterialWarehouseCode,
			TMW.MaterialWarehouseName AS TargetMaterialWarehouseName,
			MDLI.MaterialLotNo,
			MDLI.LotID,
			MDLI.LotNo,
			MDLI.MaterialCode,
			MM.MaterialName,
			MDLI.MaterialStockAttribute,
			MDLI.StockAttrib1,
			MDLI.StockAttrib2,
			MDLI.StockAttrib3,
			MDLI.StockQty,
			MDLI.CreateDateTime,
			MDLI.CreateUserID
	FROM
			STB_MaterialDocInfo MDI WITH(NOLOCK)
			LEFT OUTER JOIN STB_MaterialWarehouse SMW WITH(NOLOCK)
				ON	SMW.MaterialWarehouseCode = MDI.SourceMaterialWarehouseCode
			LEFT OUTER JOIN STB_MaterialWarehouse TMW WITH(NOLOCK)
				ON	TMW.MaterialWarehouseCode = MDI.TargetMaterialWarehouseCode
			INNER JOIN STB_MaterialDocLotInfo MDLI WITH(NOLOCK)
				ON	MDLI.MaterialDocNo = MDI.MaterialDocNo
			LEFT OUTER JOIN STB_MaterialMaster MM WITH(NOLOCK)
				ON	MM.MaterialCode = MDLI.MaterialCode
	WHERE
			MDI.PONo = @PONo
END
GO

PRINT 'Procedure usp_GetMaterialGIForPO_HY created successfully.';
GO

-- =========================================================
-- 4. Stored Procedure: usp_ProductionOrderRouting_HY_get
-- =========================================================
IF EXISTS (SELECT 1 FROM sys.procedures WHERE name = 'usp_ProductionOrderRouting_HY_get')
    DROP PROCEDURE [dbo].[usp_ProductionOrderRouting_HY_get];
GO

CREATE PROCEDURE [dbo].[usp_ProductionOrderRouting_HY_get]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
    @pPONo VARCHAR(20) = NULL
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @PONo VARCHAR(20) = @pPONo

	SELECT
			POR.PoRoutingSeqNo AS OldPoRoutingSeqNo,
			POR.PoRoutingSeqNo,
			POR.PONo,
			POR.RouteCode,
			RI.RouteName,
			POR.RouteIndex,
			POR.IsInputRoute,
			POR.IsOutputRoute,
			POR.CreateDateTime,
			POR.CreateUserID,
			POR.ChangeDateTime,
			POR.ChangeUserID
	FROM
			STB_ProductionOrderRouting POR WITH(NOLOCK)
			LEFT OUTER JOIN STB_RouteInfo RI WITH(NOLOCK)
				ON RI.RouteCode = POR.RouteCode
	WHERE
			POR.PONo = @PONo

END
GO

PRINT 'Procedure usp_ProductionOrderRouting_HY_get created successfully.';
GO

-- =========================================================
-- 5. Stored Procedure: usp_DoFixProductionOrder_HY
-- =========================================================
IF EXISTS (SELECT 1 FROM sys.procedures WHERE name = 'usp_DoFixProductionOrder_HY')
    DROP PROCEDURE [dbo].[usp_DoFixProductionOrder_HY];
GO

CREATE PROCEDURE [dbo].[usp_DoFixProductionOrder_HY]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pPONo VARCHAR(20),
	@pBasicRoutingCode VARCHAR(20) = NULL
AS
BEGIN
	SET NOCOUNT ON;

    DECLARE @ProcessUserID VARCHAR(20) = @pProcessUserID,
			@ProcessLanguage VARCHAR(20) = @pProcessLanguage,
			@PONo VARCHAR(20) = @pPONo,
			@BasicRoutingCode VARCHAR(20) = @pBasicRoutingCode,
			@IsFix BIT

	SELECT
			@IsFix = POI.IsFix
	FROM
			STB_ProductionOrderInfo POI
			LEFT OUTER JOIN STB_MaterialMaster MM
				ON MM.MaterialCode = POI.MaterialCode
	WHERE
			POI.PONo = @PONo

	IF ISNULL(@IsFix,0) = 1 BEGIN
			EXEC usp_RaiseLocalizedError @ProcessLanguage, '이미 확정된 PO입니다'
			RETURN
	END

	UPDATE	STB_ProductionOrderInfo
	SET
			IsFix = 1,
			FixDateTime = GETDATE(),
			FixUserID = @ProcessUserID,
			ChangeDateTime = GETDATE(),
			ChangeUserID = @ProcessUserID
	WHERE
			PONo = @PONo

END
GO

PRINT 'Procedure usp_DoFixProductionOrder_HY created successfully.';
GO

-- =========================================================
-- 6. Stored Procedure: usp_ProductionOrderRouting_HY_iud
-- =========================================================
IF EXISTS (SELECT 1 FROM sys.procedures WHERE name = 'usp_ProductionOrderRouting_HY_iud')
    DROP PROCEDURE [dbo].[usp_ProductionOrderRouting_HY_iud];
GO

CREATE PROCEDURE [dbo].[usp_ProductionOrderRouting_HY_iud]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
    @pProcessViewName VARCHAR(50),
	@pXml NVARCHAR(MAX) = null
AS
BEGIN
	SET NOCOUNT ON;

    DECLARE @ProcessUserID VARCHAR(20) = @pProcessUserID
    DECLARE @ProcessLanguage VARCHAR(20) = @pProcessLanguage
    DECLARE @ProcessViewName VARCHAR(50) = @pProcessViewName
    DECLARE @InsertTableName VARCHAR(100) = '/DataSet/' + @ProcessViewName + '_INSERT'
    DECLARE @UpdateTableName VARCHAR(100) = '/DataSet/' + @ProcessViewName + '_UPDATE'
    DECLARE @DeleteTableName VARCHAR(100) = '/DataSet/' + @ProcessViewName + '_DELETE'
    DECLARE @ERROR_MSG NVARCHAR(MAX)
    DECLARE @IUD_FLAG VARCHAR(10)
    DECLARE @IsAutoKey BIT
    DECLARE @IsLoopIUD BIT
    DECLARE @PrefixString VARCHAR(20)
    DECLARE @SerialLen INT

    -- Declare Columns Variable
  DECLARE @OldPoRoutingSeqNo BIGINT
  DECLARE @PoRoutingSeqNo BIGINT
  DECLARE @PONo VARCHAR(20)
  DECLARE @RouteCode VARCHAR(20)
  DECLARE @RouteIndex INT
  DECLARE @IsInputRoute BIT
  DECLARE @IsOutputRoute BIT
  DECLARE @CreateDateTime DATETIME
  DECLARE @CreateUserID VARCHAR(20)
  DECLARE @ChangeDateTime DATETIME
  DECLARE @ChangeUserID VARCHAR(20)

	DECLARE @iDoc INT

    EXEC SmartFramework.dbo.usp_GetSerialRule 
			@pTableName = 'STB_ProductionOrderRouting',
			@pIsAutoKey = @IsAutoKey OUTPUT,
			@pIsLoopIUD = @IsLoopIUD OUTPUT,
			@pPrefixData = @PrefixString OUTPUT,
			@pSerialLen = @SerialLen OUTPUT
    
    IF @IsAutoKey = 0 AND @IsLoopIUD = 0 BEGIN
   
	    EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
	
	    BEGIN TRY
			-- Process Insert Table
            MERGE STB_ProductionOrderRouting AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldPoRoutingSeqNo IS NULL THEN PoRoutingSeqNo
							    ELSE OldPoRoutingSeqNo
							END AS OldPoRoutingSeqNo,
							PoRoutingSeqNo,
							PONo,
							RouteCode,
							RouteIndex,
							IsInputRoute,
							IsOutputRoute,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @InsertTableName , 2)
							WITH  (
										OldPoRoutingSeqNo BIGINT,
										PoRoutingSeqNo BIGINT,
										PONo VARCHAR(20),
										RouteCode VARCHAR(20),
										RouteIndex INT,
										IsInputRoute BIT,
										IsOutputRoute BIT,
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.PoRoutingSeqNo = SourceTable.PoRoutingSeqNo
				)

			WHEN MATCHED THEN
				UPDATE SET
					PONo = ISNULL(SourceTable.PONo,TargetTable.PONo),
					RouteCode = ISNULL(SourceTable.RouteCode,TargetTable.RouteCode),
					RouteIndex = ISNULL(SourceTable.RouteIndex,TargetTable.RouteIndex),
					IsInputRoute = ISNULL(SourceTable.IsInputRoute,TargetTable.IsInputRoute),
					IsOutputRoute = ISNULL(SourceTable.IsOutputRoute,TargetTable.IsOutputRoute),
					ChangeDateTime = ISNULL(SourceTable.ChangeDateTime,TargetTable.ChangeDateTime),
					ChangeUserID = ISNULL(SourceTable.ChangeUserID,TargetTable.ChangeUserID)
			WHEN NOT MATCHED THEN
				INSERT
					(
						PONo,
						RouteCode,
						RouteIndex,
						IsInputRoute,
						IsOutputRoute,
						CreateDateTime,
						CreateUserID
					)
				VALUES
					(
							SourceTable.PONo,
							SourceTable.RouteCode,
							SourceTable.RouteIndex,
							SourceTable.IsInputRoute,
							SourceTable.IsOutputRoute,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID
					);


			-- Process Update Table
            MERGE STB_ProductionOrderRouting AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldPoRoutingSeqNo IS NULL THEN PoRoutingSeqNo
							    ELSE OldPoRoutingSeqNo
							END AS OldPoRoutingSeqNo,
							PoRoutingSeqNo,
							PONo,
							RouteCode,
							RouteIndex,
							IsInputRoute,
							IsOutputRoute,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @UpdateTableName , 2)
							WITH  (
										OldPoRoutingSeqNo BIGINT,
										PoRoutingSeqNo BIGINT,
										PONo VARCHAR(20),
										RouteCode VARCHAR(20),
										RouteIndex INT,
										IsInputRoute BIT,
										IsOutputRoute BIT,
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.PoRoutingSeqNo = SourceTable.OldPoRoutingSeqNo
				)

			WHEN MATCHED THEN
				UPDATE SET
					PONo = ISNULL(SourceTable.PONo,TargetTable.PONo),
					RouteCode = ISNULL(SourceTable.RouteCode,TargetTable.RouteCode),
					RouteIndex = ISNULL(SourceTable.RouteIndex,TargetTable.RouteIndex),
					IsInputRoute = ISNULL(SourceTable.IsInputRoute,TargetTable.IsInputRoute),
					IsOutputRoute = ISNULL(SourceTable.IsOutputRoute,TargetTable.IsOutputRoute),
					ChangeDateTime = ISNULL(SourceTable.ChangeDateTime,TargetTable.ChangeDateTime),
					ChangeUserID = ISNULL(SourceTable.ChangeUserID,TargetTable.ChangeUserID)
			WHEN NOT MATCHED THEN
				INSERT
					(
						PONo,
						RouteCode,
						RouteIndex,
						IsInputRoute,
						IsOutputRoute,
						CreateDateTime,
						CreateUserID
					)
				VALUES
					(
							SourceTable.PONo,
							SourceTable.RouteCode,
							SourceTable.RouteIndex,
							SourceTable.IsInputRoute,
							SourceTable.IsOutputRoute,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID
					);


			-- Process Delete Table
            MERGE STB_ProductionOrderRouting AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldPoRoutingSeqNo IS NULL THEN PoRoutingSeqNo
							    ELSE OldPoRoutingSeqNo
							END AS OldPoRoutingSeqNo,
							PoRoutingSeqNo,
							PONo,
							RouteCode,
							RouteIndex,
							IsInputRoute,
							IsOutputRoute,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @DeleteTableName , 2)
							WITH  (
										OldPoRoutingSeqNo BIGINT,
										PoRoutingSeqNo BIGINT,
										PONo VARCHAR(20),
										RouteCode VARCHAR(20),
										RouteIndex INT,
										IsInputRoute BIT,
										IsOutputRoute BIT,
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.PoRoutingSeqNo = SourceTable.PoRoutingSeqNo
				)

			WHEN MATCHED THEN
				DELETE;

        END TRY
	    BEGIN CATCH
            SET @ERROR_MSG = ERROR_MESSAGE()
			RAISERROR( @ERROR_MSG ,16, 1)
	    END CATCH
		
	    EXEC sp_xml_removedocument @idoc

    END ELSE BEGIN
        EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
        BEGIN TRY
		    DECLARE SourceData CURSOR FOR
                SELECT
                        'INSERT' AS IUD_FLAG,
									OldPoRoutingSeqNo,
									PoRoutingSeqNo,
									PONo,
									RouteCode,
									RouteIndex,
									IsInputRoute,
									IsOutputRoute,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID
							FROM
									OPENXML(@idoc , @InsertTableName , 2)
							        WITH  (
											 OldPoRoutingSeqNo BIGINT,
											 PoRoutingSeqNo BIGINT,
											 PONo VARCHAR(20),
											 RouteCode VARCHAR(20),
											 RouteIndex INT,
											 IsInputRoute BIT,
											 IsOutputRoute BIT,
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											)
							UNION ALL
							SELECT
									'UPDATE' AS IUD_FLAG,
									CASE 
										WHEN OldPoRoutingSeqNo IS NULL THEN PoRoutingSeqNo
										ELSE OldPoRoutingSeqNo
									END AS OldPoRoutingSeqNo,
									PoRoutingSeqNo,
									PONo,
									RouteCode,
									RouteIndex,
									IsInputRoute,
									IsOutputRoute,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID
							FROM
									OPENXML(@idoc , @UpdateTableName , 2)
							        WITH  (
											 OldPoRoutingSeqNo BIGINT,
											 PoRoutingSeqNo BIGINT,
											 PONo VARCHAR(20),
											 RouteCode VARCHAR(20),
											 RouteIndex INT,
											 IsInputRoute BIT,
											 IsOutputRoute BIT,
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											)
							UNION ALL
							SELECT
									'DELETE' AS IUD_FLAG,
									CASE 
										WHEN OldPoRoutingSeqNo IS NULL THEN PoRoutingSeqNo
										ELSE OldPoRoutingSeqNo
									END AS OldPoRoutingSeqNo,
									PoRoutingSeqNo,
									PONo,
									RouteCode,
									RouteIndex,
									IsInputRoute,
									IsOutputRoute,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID
							FROM
									OPENXML(@idoc , @DeleteTableName , 2)
							        WITH  (
											 OldPoRoutingSeqNo BIGINT,
											 PoRoutingSeqNo BIGINT,
											 PONo VARCHAR(20),
											 RouteCode VARCHAR(20),
											 RouteIndex INT,
											 IsInputRoute BIT,
											 IsOutputRoute BIT,
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											) 


            OPEN SourceData

            WHILE 1 = 1 BEGIN
                FETCH NEXT FROM SourceData INTO
								 @IUD_FLAG,
								 @OldPoRoutingSeqNo,
								 @PoRoutingSeqNo,
								 @PONo,
								 @RouteCode,
								 @RouteIndex,
								 @IsInputRoute,
								 @IsOutputRoute,
								 @CreateDateTime,
								 @CreateUserID,
								 @ChangeDateTime,
								 @ChangeUserID


                IF @@FETCH_STATUS <> 0 BEGIN
					BREAK
				END
                IF @IUD_FLAG = 'INSERT' BEGIN

                    IF EXISTS (SELECT 1 FROM STB_ProductionOrderRouting WHERE PoRoutingSeqNo = @PoRoutingSeqNo) BEGIN
						RAISERROR('Duplicate Data : KeyField = %s', 16, 1, @PoRoutingSeqNo)
					END

                    IF @IsAutoKey = 1 BEGIN
                        EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_ProductionOrderRouting',@PoRoutingSeqNo OUTPUT
                    END

                    INSERT INTO STB_ProductionOrderRouting
						(
						    PONo,
						    RouteCode,
						    RouteIndex,
						    IsInputRoute,
						    IsOutputRoute,
						    CreateDateTime,
						    CreateUserID,
						    ChangeDateTime,
						    ChangeUserID
						)
						VALUES
						(
						    @PONo,
						    @RouteCode,
						    @RouteIndex,
						    @IsInputRoute,
						    @IsOutputRoute,
						    GETDATE(),
						    @pProcessUserID,
						    @ChangeDateTime,
						    @ChangeUserID
						)

				END ELSE IF @IUD_FLAG = 'UPDATE' BEGIN
                    UPDATE STB_ProductionOrderRouting
						SET
						    PONo =   ISNULL(@PONo,PONo),
						    RouteCode =   ISNULL(@RouteCode,RouteCode),
						    RouteIndex =   ISNULL(@RouteIndex,RouteIndex),
						    IsInputRoute =   ISNULL(@IsInputRoute,IsInputRoute),
						    IsOutputRoute =   ISNULL(@IsOutputRoute,IsOutputRoute),
						    CreateDateTime =   ISNULL(@CreateDateTime,CreateDateTime),
						    CreateUserID =   ISNULL(@CreateUserID,CreateUserID),
						    ChangeDateTime = GETDATE(),
						    ChangeUserID = @pProcessUserID
						WHERE
						    PoRoutingSeqNo = @OldPoRoutingSeqNo
                END ELSE IF @IUD_FLAG = 'DELETE' BEGIN
                    DELETE FROM STB_ProductionOrderRouting
						WHERE
						    PoRoutingSeqNo = @OldPoRoutingSeqNo
                END
            END
        END TRY
		BEGIN CATCH
			SET @ERROR_MSG = ERROR_MESSAGE()
			RAISERROR( @ERROR_MSG ,16, 1)
		END CATCH
			
		CLOSE SourceData;
		DEALLOCATE SourceData;
			
		EXEC sp_xml_removedocument @idoc	
    END
END
GO

PRINT 'Procedure usp_ProductionOrderRouting_HY_iud created successfully.';
GO

-- =========================================================
-- 7. Stored Procedure: usp_DoCancelPO_HY
-- =========================================================
IF EXISTS (SELECT 1 FROM sys.procedures WHERE name = 'usp_DoCancelPO_HY')
    DROP PROCEDURE [dbo].[usp_DoCancelPO_HY];
GO

CREATE PROCEDURE [dbo].[usp_DoCancelPO_HY]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pPONo VARCHAR(20),
	@pDefectSummaryNo VARCHAR(20)=null
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @PONo VARCHAR(20) = @pPONo
	DECLARE @DefectSummaryNo VARCHAR(20) =@pDefectSummaryNo

	DECLARE @IsCancel BIT
	DECLARE @IsFix BIT
	DECLARE @ErrorMessage NVARCHAR(500)

	IF EXISTS (
				SELECT	1
				FROM
						STB_SetInfo SI WITH(NOLOCK)
				WHERE
						SI.PONo = @PONo
				) BEGIN
			EXEC SmartFramework.dbo.usp_GetAddonStringResource	@pProcessLanguage,
											'^Lot이 생성된 PO는 취소할 수 없습니다^',
											@ErrorMessage OUTPUT
			SET @ErrorMessage = @ErrorMessage + ' [%s]'
			RAISERROR(@ErrorMessage,16,1,@PONo)
			RETURN

	END

	SELECT @IsCancel = IsCancel
	      ,@IsFix = IsFix
	  FROM STB_ProductionOrderInfo WITH(NOLOCK)
	 WHERE PONo = @PONo

	IF ISNULL(@IsCancel,0) = 1 BEGIN
			EXEC usp_RaiseLocalizedError    @pProcessLanguage,
											'이미 취소된 계획입니다'
	END

	UPDATE	STB_ProductionOrderInfo
	SET
			IsCancel = 1,
			IsFix = 0,
			ChangeDateTime = GETDATE(),
			ChangeUserID = @pProcessUserID
	WHERE
			PONo = @PONo

	
	if(@DefectSummaryNo is not null)
	begin
			UPDATE STB_ReDropping  set isStatus = 1 where DefectSummaryNo =  @DefectSummaryNo
	end

END
GO

PRINT 'Procedure usp_DoCancelPO_HY created successfully.';
GO

COMMIT TRAN;
PRINT 'Transaction COMMIT successfully. Stored procedures created.';
-- ROLLBACK
GO
