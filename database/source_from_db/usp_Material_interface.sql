CREATE PROC [dbo].[usp_Material_interface]
AS
BEGIN
	-- 제품
	INSERT INTO STB_MaterialMaster (
		MaterialCode, MaterialName, MaterialNameL, AltMaterialCode, MaterialTypeCode
	   ,ProductGroupCode, MaterialUnit, BasicGrQty, MaterialSpec, MaterialSpecL
	   ,MaterialSource, MaterialThickness, AvgGrDay, IsDelegate, IsInternalProd
	   ,IsProdPlan, IsPurchase, IsOrder, IsUseFlush, IsUseBackFlush
	   ,IsClosed, IsRequireOqc, BeforeMaterialCode, RequestGrDay, BasicCostPrice
	   ,BasicPackingQty, DelegateMaterialCode, MaterialPurchaseType, MaxProdPlanQty, BasicRoutingCode
	   ,MMExtText08, MMExtText09, MMExtText10
	   ,CreateDateTime, CreateUserID, ChangeDateTime, ChangeUserID )
			SELECT B.PRODCD, B.PRODNM, B.PNO, NULL, 'FERT'
				  ,'HC-EDLC', B.PUNIT, NULL, NULL, NULL
				  ,NULL, NULL, NULL, 0, 0
				  ,1, 0, 0, 0, 0
				  ,0, 0, NULL, NULL, NULL
				  ,NULL, NULL, NULL, NULL, 'MainRouting'
				  ,B.용도, B.특성, B.특이사항
				  ,GETDATE(), 'eai', NULL, NULL
			  FROM ERPSVR.ERPDB.DBO.PRODUCT B
			 WHERE B.USEGBN = 'Y'
			   AND B.PRODCD NOT IN (SELECT MaterialCode FROM STB_MaterialMaster)
			   AND B.입력일시 > '2020-05-01'
			   AND B.ACTGBN = '1'

	--원자재
	INSERT INTO STB_MaterialMaster (
		MaterialCode, MaterialName, MaterialNameL, AltMaterialCode, MaterialTypeCode
	   ,ProductGroupCode, MaterialUnit, BasicGrQty, MaterialSpec, MaterialSpecL
	   ,MaterialSource, MaterialThickness, AvgGrDay, IsDelegate, IsInternalProd
	   ,IsProdPlan, IsPurchase, IsOrder, IsUseFlush, IsUseBackFlush
	   ,IsClosed, IsRequireOqc, BeforeMaterialCode, RequestGrDay, BasicCostPrice
	   ,BasicPackingQty, DelegateMaterialCode, MaterialPurchaseType, MaxProdPlanQty, BasicRoutingCode
	   ,MMExtText08, MMExtText09, MMExtText10
	   ,CreateDateTime, CreateUserID, ChangeDateTime, ChangeUserID )
			SELECT B.PRODCD, B.PRODNM, B.PNO, NULL, 'ROH'
				  ,'', B.PUNIT, NULL, NULL, NULL
				  ,NULL, NULL, NULL, 0, 0
				  ,1, 0, 0, 0, 0
				  ,0, 0, NULL, NULL, NULL
				  ,NULL, NULL, NULL, NULL, 'MainRouting'
				  ,B.용도, B.특성, B.특이사항
				  ,GETDATE(), 'eai', NULL, NULL
			  FROM ERPSVR.ERPDB.DBO.PRODUCT B
			 WHERE 1 = 1
			   AND B.USEGBN = 'Y'
			   AND B.PRODCD NOT IN (SELECT MaterialCode FROM STB_MaterialMaster)
			   AND B.ACTGBN <> '1'
			   AND B.입력일시 > '2020-05-01'
			   -- 기존 인터페이스 기준(입고이력)을 제거하고, 입력일시 기준으로 변경
			   -- 
END