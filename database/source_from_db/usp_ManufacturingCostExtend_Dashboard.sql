-- =============================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Create date: 2021.08.21
-- Browsable : true
-- Group : 원가관리
-- Description: 품목별 원가 확장속성 조회(대시보드)
-- Modified:
-- =============================================
CREATE PROC [dbo].[usp_ManufacturingCostExtend_Dashboard]
	@pCompanyCode VARCHAR(20) = NULL
   ,@pWorkCenterCode VARCHAR(20) = NULL
   ,@pMaterialCode VARCHAR(20) = NULL
AS
BEGIN
	Declare @ApplyDate DATE
	       ,@CompanyCode VARCHAR(20) = CASE WHEN ISNULL(@pCompanyCode, '') = '' THEN '*' ELSE @pCompanyCode END
           ,@WorkCenterCode VARCHAR(20) = CASE WHEN ISNULL(@pWorkCenterCode, '') = '' THEN '*' ELSE @pWorkCenterCode END
           ,@MaterialCode VARCHAR(20) = CASE WHEN ISNULL(@pMaterialCode, '') = '' THEN '*' ELSE @pMaterialCode END

	Declare @ManufacturingCostExtendTable TABLE (
		ApplyDate DATE
	   ,CompanyCode VARCHAR(20)
	   ,CompanyName NVARCHAR(200)
	   ,WorkCenterCode VARCHAR(20)
	   ,WorkCenterName NVARCHAR(200)
	   ,ProductType VARCHAR(100)
	   ,MaterialCode VARCHAR(20)
	   ,MaterialName NVARCHAR(200)
	   ,IsUsed BIT
	   ,[Volt(V)]  VARCHAR(20)
	   ,[Farad(F)]  VARCHAR(20)
	   ,Volt VARCHAR(20)
	   ,Farad VARCHAR(20)
	   ,MBISizeH NUMERIC(20,4)
	   ,MBISizeW NUMERIC(20,4)
	   ,MBISizeD VARCHAR(20)
	   ,MaterialTypeCode VARCHAR(20)
	   ,MaterialTypeName NVARCHAR(200)
	   ,IsManual BIT
	   ,DirectCostPrice NUMERIC(20, 10)
	   ,IndirectCodePrice NUMERIC(20, 10)
	   ,ProductionCostPrice NUMERIC(20, 10)
	   ,[활성탄] NUMERIC(20, 10)
	   ,[활물질] NUMERIC(20, 10)
	   ,[도전재] NUMERIC(20, 10)
	   ,[바인더] NUMERIC(20, 10)
	   ,[계면활성제] NUMERIC(20, 10)
	   ,[용매] NUMERIC(20, 10)
	   ,[집전체] NUMERIC(20, 10)
	   ,[터미널] NUMERIC(20, 10)
	   ,[ATL단자] NUMERIC(20, 10)
	   ,[분리막] NUMERIC(20, 10)
	   ,[PI-TAPE] NUMERIC(20, 10)
	   ,[고무전] NUMERIC(20, 10)
	   ,[단자판] NUMERIC(20, 10)
	   ,[와샤] NUMERIC(20, 10)
	   ,[전해액] NUMERIC(20, 10)
	   ,[케이스] NUMERIC(20, 10)
	   ,[슬리브] NUMERIC(20, 10)
	   ,[저판] NUMERIC(20, 10)
	   ,[포장재] NUMERIC(20, 10)
	   ,[모듈용PCB] NUMERIC(20, 10)
	   ,[모듈용Wire] NUMERIC(20, 10)
	   ,MaterialCostPrice NUMERIC(20, 10)
	   ,LaborCostPrice NUMERIC(20, 10)
	   ,OverheadCostPrice NUMERIC(20, 10)
	   ,CreateDateTime DATETIME
	   ,CreateUserID  VARCHAR(20)
	   ,ChangeDateTime DATETIME
	   ,ChangeUserID VARCHAR(20)
	);

	Declare @ManufacturingCostExtendTable2 TABLE (
		ApplyDate DATE
	   ,CompanyCode VARCHAR(20)
	   ,CompanyName NVARCHAR(200)
	   ,WorkCenterCode VARCHAR(20)
	   ,WorkCenterName NVARCHAR(200)
	   ,ProductType VARCHAR(100)
	   ,MaterialCode VARCHAR(20)
	   ,MaterialName NVARCHAR(200)
	   ,IsUsed BIT
	   ,[Volt(V)]  VARCHAR(20)
	   ,[Farad(F)]  VARCHAR(20)
	   ,Volt VARCHAR(20)
	   ,Farad VARCHAR(20)
	   ,MBISizeH NUMERIC(20,4)
	   ,MBISizeW NUMERIC(20,4)
	   ,MBISizeD VARCHAR(20)
	   ,MaterialTypeCode VARCHAR(20)
	   ,MaterialTypeName NVARCHAR(200)
	   ,IsManual BIT
	   ,DirectCostPrice NUMERIC(20, 10)
	   ,IndirectCodePrice NUMERIC(20, 10)
	   ,ProductionCostPrice NUMERIC(20, 10)
	   ,RawMaterialName NVARCHAR(100)
	   ,RawMaterialCostPrice NUMERIC(20,10)
	   ,MaterialCostPrice NUMERIC(20, 10)
	   ,LaborCostPrice NUMERIC(20, 10)
	   ,OverheadCostPrice NUMERIC(20, 10)
	);

	SELECT @ApplyDate = ApplyDate FROM STB_ManufacturingCostApplyInfo WHERE IsApply = CONVERT(BIT, 1)

	;WITH CostBaseInfo AS (
		SELECT *
		  FROM (
				SELECT ApplyDate
					  ,CompanyCode
					  ,WorkCenterCode
					  ,MaterialCode
					  ,CostTypeCode
					  ,MIN(CostPrice) AS CostPrice
					  ,IsUsed
				  FROM STB_ManufacturingCostByRoute
				 WHERE RouteCode IN (SELECT RouteCode 
				                       FROM STB_RouteInfo 
									  WHERE RouteType = 'Route-28')
				 GROUP BY ApplyDate
						 ,CompanyCode
						 ,WorkCenterCode
						 ,MaterialCode
						 ,CostTypeCode
						 ,IsUsed
			) AS Base PIVOT (
				MIN(CostPrice) FOR CostTypeCode IN (DC, IC, PC)
			) A
	)
	INSERT INTO @ManufacturingCostExtendTable
	SELECT CBI.ApplyDate
		  ,CBI.CompanyCode
		  ,CI.CompanyName
		  ,CBI.WorkCenterCode
		  ,WCI.WorkCenterName
		  ,MBI.MBIExtText03 AS ProductType
		  ,CBI.MaterialCode
		  ,MM.MaterialName
		  ,CBI.IsUsed
		  ,MBI.MBIExtText04 AS [Volt(V)]
		  ,MBI.MBIExtText05 AS [Farad(F)]
		  ,MBI.MBIExtText01 AS Volt
		  ,MBI.MBIExtText02 AS Farad
		  ,MBI.MBISizeH
		  ,MBI.MBISizeW
		  ,CASE WHEN MBI.MBISizeW IS NOT NULL
				THEN RIGHT('0'+CONVERT(VARCHAR, CONVERT(INT, MBI.MBISizeW)), 2) + CONVERT(VARCHAR, CONVERT(INT, MBI.MBISizeH))
				ELSE CONVERT(VARCHAR(10), MBI.MBISizeD) END + CASE WHEN CHARINDEX('-L', MBI.ModelName) > 0 THEN 'L' ELSE '' END AS MBISizeD
		  ,MT.MaterialTypeCode
		  ,MT.MaterialTypeName
		  ,ISNULL(MCE.IsManual, CONVERT(BIT, 0)) AS IsManual
		  ,CBI.DC AS DirectCostPrice
		  ,CBI.IC AS IndirectCodePrice
		  ,CBI.PC AS ProductionCostPrice
		  ,ISNULL(MCE.ActivatedCarbonCostPrice, 0)
		  ,ISNULL(MCE.ActiveMaterialCostPrice, 0)
		  ,ISNULL(MCE.ConductiveMaterialCostPrice, 0)
		  ,ISNULL(MCE.BinderCostPrice, 0)
		  ,ISNULL(MCE.SurfactantCostPrice, 0)
		  ,ISNULL(MCE.MenstruumCostPrice, 0)
		  ,ISNULL(MCE.CurrentCollectorCostPrice, 0)
		  ,ISNULL(MCE.TerminalCostPrice, 0)
		  ,ISNULL(MCE.ATLTerminalCostPrice, 0)
		  ,ISNULL(MCE.SeparatorCostPrice, 0)
		  ,ISNULL(MCE.PiTapeCostPrice, 0)
		  ,ISNULL(MCE.RubberStopperCostPrice, 0)
		  ,ISNULL(MCE.TerminalBoardCostPrice, 0)
		  ,ISNULL(MCE.WasherCostPrice, 0)
		  ,ISNULL(MCE.ElectrolyteCostPrice, 0)
		  ,ISNULL(MCE.CaseCostPrice, 0)
		  ,ISNULL(MCE.SleeveCostPrice, 0)
		  ,ISNULL(MCE.BottomPlateCostPrice, 0)
		  ,ISNULL(MCE.PackagingMaterialCostPrice, 0)
		  ,ISNULL(MCE.PCBForModuleCostPrice, 0)
		  ,ISNULL(MCE.WireForModuleCostPrice, 0)
		  ,ISNULL(MCE.MaterialCostPrice, 0)
		  ,ISNULL(MCE.LaborCostPrice, 0)
		  ,ISNULL(MCE.OverheadCostPrice, 0)
		  ,MCE.CreateDateTime
		  ,MCE.CreateUserID
		  ,MCE.ChangeDateTime
		  ,MCE.ChangeUserID
	  FROM CostBaseInfo CBI
	  LEFT OUTER JOIN STB_ManufacturingCostExtend MCE
		ON CBI.ApplyDate = MCE.ApplyDate
	   AND CBI.CompanyCode = MCE.CompanyCode
	   AND CBI.WorkCenterCode = MCE.WorkCenterCode
	   AND CBI.MaterialCode = MCE.MaterialCode
	  LEFT OUTER JOIN STB_CompanyInfo CI
		ON CI.CompanyCode = CBI.CompanyCode
	  LEFT OUTER JOIN STB_WorkCenterInfo WCI
		ON WCI.WorkCenterCode = CBI.WorkCenterCode
	  LEFT OUTER JOIN STB_MaterialMaster MM
		ON MM.MaterialCode = CBI.MaterialCode
	  LEFT OUTER JOIN VW_ModelBasicInfo MBI
		ON MBI.ModelCode = CBI.MaterialCode
	  LEFT OUTER JOIN STB_MaterialType MT WITH(NOLOCK)
		ON MT.MaterialTypeCode = MBI.MaterialTypeCode 
	  LEFT OUTER JOIN STB_ProductGroup PG WITH(NOLOCK)
		ON PG.ProductGroupCode = MBI.ProductGroupCode
	 WHERE CBI.ApplyDate = @ApplyDate
	   AND (@CompanyCode = '*' OR CBI.CompanyCode = @CompanyCode)
	   AND (@WorkCenterCode = '*' OR CBI.WorkCenterCode = @WorkCenterCode)
	   AND (@MaterialCode = '*' OR CBI.MaterialCode = @MaterialCode)

	print convert(varchar(10), @@rowcount)

	INSERT INTO @ManufacturingCostExtendTable2
	SELECT ApplyDate
	      ,CompanyCode
	      ,CompanyName
	      ,WorkCenterCode
	      ,WorkCenterName
	      ,ProductType
	      ,MaterialCode
	      ,MaterialName
	      ,IsUsed
	      ,[Volt(V)]
	      ,[Farad(F)]
	      ,Volt
	      ,Farad
	      ,MBISizeH
	      ,MBISizeW
	      ,MBISizeD
	      ,MaterialTypeCode
	      ,MaterialTypeName
	      ,IsManual
	      ,DirectCostPrice
	      ,IndirectCodePrice
	      ,ProductionCostPrice
		  ,RawMaterialName
		  ,RawMaterialCostPrice
		  ,MaterialCostPrice
	      ,LaborCostPrice
	      ,OverheadCostPrice
	  FROM (SELECT ApplyDate
	             ,CompanyCode
	             ,CompanyName
	             ,WorkCenterCode
	             ,WorkCenterName
	             ,ProductType
	             ,MaterialCode
	             ,MaterialName
	             ,IsUsed
	             ,[Volt(V)]
	             ,[Farad(F)]
	             ,Volt
	             ,Farad
	             ,MBISizeH
	             ,MBISizeW
	             ,MBISizeD
	             ,MaterialTypeCode
	             ,MaterialTypeName
	             ,IsManual
	             ,DirectCostPrice
	             ,IndirectCodePrice
	             ,ProductionCostPrice
				 ,[활성탄]
			     ,[활물질]
			     ,[도전재]
			     ,[바인더]
			     ,[계면활성제]
			     ,[용매]
			     ,[집전체]
			     ,[터미널]
			     ,[ATL단자]
			     ,[분리막]
			     ,[PI-TAPE]
			     ,[고무전]
			     ,[단자판]
			     ,[와샤]
			     ,[전해액]
			     ,[케이스]
			     ,[슬리브]
			     ,[저판]
			     ,[포장재]
			     ,[모듈용PCB]
			     ,[모듈용Wire]
				 ,MaterialCostPrice
			     ,LaborCostPrice
			     ,OverheadCostPrice
	          FROM @ManufacturingCostExtendTable
		   ) p
	UNPIVOT
		(RawMaterialCostPrice FOR RawMaterialName IN (
			 [활성탄]
			,[활물질]
			,[도전재]
			,[바인더]
			,[계면활성제]
			,[용매]
			,[집전체]
			,[터미널]
			,[ATL단자]
			,[분리막]
			,[PI-TAPE]
			,[고무전]
			,[단자판]
			,[와샤]
			,[전해액]
			,[케이스]
			,[슬리브]
			,[저판]
			,[포장재]
			,[모듈용PCB]
			,[모듈용Wire]
		)
	) AS unpvt

	SELECT ApplyDate
	      ,CompanyCode
	      ,CompanyName
	      ,WorkCenterCode
	      ,WorkCenterName
	      ,ProductType
	      ,MaterialCode
	      ,MaterialName
	      ,IsUsed
	      ,[Volt(V)]
	      ,[Farad(F)]
	      ,Volt
	      ,Farad
	      ,MBISizeH
	      ,MBISizeW
	      ,MBISizeD
	      ,MaterialTypeCode
	      ,MaterialTypeName
	      ,IsManual
	      ,DirectCostPrice
	      ,IndirectCodePrice
	      ,ProductionCostPrice
		  ,RawMaterialName
		  ,RawMaterialCostPrice
		  ,CASE WHEN MaterialCostPrice = 0 THEN 0 ELSE RawMaterialCostPrice / MaterialCostPrice END AS CostPriceRate
		  ,MaterialCostPrice
	      ,LaborCostPrice
	      ,OverheadCostPrice
	  FROM @ManufacturingCostExtendTable2
	 ORDER BY ApplyDate, CompanyCode, WorkCenterCode, MaterialCode
	         ,CASE WHEN RawMaterialName = '활성탄' THEN 1 
			       WHEN RawMaterialName = '활물질' THEN 2
			       WHEN RawMaterialName = '도전재' THEN 3
			       WHEN RawMaterialName = '바인더' THEN 4 
			       WHEN RawMaterialName = '계면활성제' THEN 5 
			       WHEN RawMaterialName = '용매' THEN 6
			       WHEN RawMaterialName = '집전체' THEN 7 
			       WHEN RawMaterialName = '터미널' THEN 8 
			       WHEN RawMaterialName = 'ATL단자' THEN 9 
			       WHEN RawMaterialName = '분리막' THEN 10 
			       WHEN RawMaterialName = 'PI-TAPE' THEN 11
			       WHEN RawMaterialName = '고무전' THEN 12
			       WHEN RawMaterialName = '단자판' THEN 13
			       WHEN RawMaterialName = '와샤' THEN 14
			       WHEN RawMaterialName = '전해액' THEN 15
			       WHEN RawMaterialName = '케이스' THEN 16
			       WHEN RawMaterialName = '슬리브' THEN 17
			       WHEN RawMaterialName = '저판' THEN 18
			       WHEN RawMaterialName = '포장재' THEN 19
			       WHEN RawMaterialName = '모듈용PCB' THEN 20
			       WHEN RawMaterialName = '모듈용Wire' THEN 21
				   ELSE 1000 END
END