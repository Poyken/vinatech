-- =============================================
-- Author: Kim Han Young(hykim@awoo.co.kr)
-- Group : 품질관리
-- Browsable : true
-- Create date: 2016-08-30
-- Description: 공용검사문서 검사항목을 생성합니다.  [중요]
--                   2022.01.13  VJMJ113R850615 바코드 수동생성 (이현순)
--                   2022.01.13  RouteCode 주석처리  
-- 프로시저 실행 :   [usp_DoCreateCommInspDocItem] '','','20220113000174','VNT','VNT_F1','','','','','',''
--[usp_DoCreateCommInspDocItem] '','','20250122000174','VVT','VT_F2','','','','','',''
-- =================================================================================================================
CREATE PROCEDURE [dbo].[usp_DoCreateCommInspDocItem]
						@pProcessLanguage VARCHAR(20),
						@pProcessUserID VARCHAR(20),
						@pCommInspDocNo VARCHAR(20),
						@pCompanyCode	varchar(20)	,
						@pWorkCenterCode	varchar(20)	,
						@pLineCode	varchar(20) = NULL,
						@pRouteCode	varchar(20) = NULL,
						@pMachineCode	varchar(20) = NULL,
						@pMoldNumber	varchar(50) = NULL,
						@pMaterialCode	varchar(50) = NULL,
						@pCategoryName	nvarchar(50) = NULL,
						@pProductGroupCode	varchar(20) = NULL,
						@pLineCode1	varchar(20) = NULL
AS

BEGIN
	--SET NOCOUNT ON;
	--print @pCommInspDocNo +'__'+@pCompanyCode+'__'+@pWorkCenterCode+'__'+@pLineCode+'__'+@pRouteCode+'__'+@pMachineCode+'__'+@pMoldNumber+'__'+@pCategoryName+'__'+@pProductGroupCode+'__'+@pLineCode1
    DECLARE @ProcessLanguage VARCHAR(20) = @pProcessLanguage,
				@ProcessUserID VARCHAR(20) = @pProcessUserID,
				@CommInspDocNo VARCHAR(20) = @pCommInspDocNo,
				@CommInspTypeCode VARCHAR(50),
				@CompanyCode	varchar(20)= ISNULL(@pCompanyCode,''),
				@WorkCenterCode	varchar(20)= ISNULL(@pWorkCenterCode,''),
				@LineCode	varchar(20)= ISNULL(@pLineCode,''),
				@RouteCode	varchar(20)= ISNULL(@pRouteCode,''),
				@MachineCode	varchar(20)= ISNULL(@pMachineCode,''),
				@MoldNumber	varchar(20)= ISNULL(@pMoldNumber,''),
				@MaterialCode	varchar(20)= RTRIM(LTRIM(ISNULL(@pMaterialCode,''))),
				@CategoryName	varchar(20)= ISNULL(@pCategoryName,''),
				@ProductGroupCode	varchar(20)= ISNULL(@pProductGroupCode,''),
				@LineCode1	varchar(20)= ISNULL(@pLineCode1,'')
	SELECT
			@CommInspTypeCode = CIDH.CommInspTypeCode
	FROM
			STB_CommInspDocHistory CIDH
	WHERE
			CIDH.CommInspDocNo = @CommInspDocNo
	
	DECLARE @Items TABLE
	(
		Row INT IDENTITY(1,1),
		CommInspItemCode VARCHAR(50),
		CommInspUnit VARCHAR(20),
		RouteCode VARCHAR(20),
		CommInspInputType CHAR(1),
		CommInspItemDesc NVARCHAR(200),
		CommInspItemSpec VARCHAR(50),
		CommInspUpper VARCHAR(50),
		CommInspLower VARCHAR(50),
		ItemTargetQty INT
	)
	INSERT INTO @Items
	SELECT
			cii.CommInspItemCode,
			CII.CommInspUnit,
			CII.RouteCode,
			CII.CommInspInputType,
			/*CASE
							WHEN cii.CommInspItemCode='V_RQ_T_BG' and @MaterialCode in ('ECVT30-115','ECVT30-316','ECVT30-349') THEN  2 --Ms.Hồng yêu cầu
							ELSE CII.CommInspInputType
						END as CommInspInputType,*/
			CII.CommInspItemDesc,
			CASE CII.IsIndividualSpec
				WHEN 1 THEN CIIS.CommInspItemSpec
				ELSE CII.CommInspItemSpec
			END,
			CASE CII.IsIndividualSpec
				WHEN 1 THEN CIIS.CommInspUpper
				ELSE CII.CommInspUpper
			END,
			CASE CII.IsIndividualSpec
				WHEN 1 THEN CIIS.CommInspLower
				ELSE CII.CommInspLower
			END,
			--CII.ItemTargetQty
			CASE
							WHEN cii.CommInspItemCode='V_RQ_T_BG' and @MaterialCode in ('ECVT30-115','ECVT30-316','ECVT30-349') THEN  16 --Ms.Hồng yêu cầu
							WHEN (CIIS.ItemTargetQtyIndividual IS NOT NULL OR CIIS.ItemTargetQtyIndividual <> '') THEN CIIS.ItemTargetQtyIndividual
							ELSE CII.ItemTargetQty
						END as ItemTargetQty
	FROM
			STB_CommInspItem CII WITH(NOLOCK)
			LEFT OUTER JOIN 
			(
				SELECT
						CIIS.CommInspItemCode,
						CIIS.CommInspItemSpec,
						CASE
							WHEN @LineCode1 = 'VVBGC-11' and @MaterialCode ='ECVT30-115' THEN  CIIS.CommInspUpperManually
							ELSE CIIS.CommInspUpper
						END as CommInspUpper,
						CASE
							WHEN @LineCode1 = 'VVBGC-11' and @MaterialCode ='ECVT30-115'  THEN  CIIS.CommInspLowerManually
							ELSE CIIS.CommInspLower
						END as CommInspLower,
						CIIS.ItemTargetQtyIndividual
						--CIIS.CommInspUpper,
						--CIIS.CommInspLower
				FROM
						STB_CommInspIndividualSpec CIIS WITH(NOLOCK)
				WHERE
						CIIS.CompanyCode = @CompanyCode AND
						CIIS.WorkCenterCode = @WorkCenterCode AND
						CIIS.LineCode LIKE @LineCode AND
						--CIIS.RouteCode LIKE @RouteCode AND
						CIIS.MachineCode LIKE @MachineCode AND
						--CIIS.MoldNumber LIKE @MoldNumber AND
						CIIS.MaterialCode LIKE @MaterialCode AND
						CIIS.CategoryName LIKE @CategoryName
			) CIIS
				ON CIIS.CommInspItemCode = CII.CommInspItemCode
				--ON	CIIS.CommInspItemCode = CII.CommInspItemCode AND
				--	CIIS.CompanyCode = CII.CompanyCode AND
				--	CIIS.WorkCenterCode = CII.WorkCenterCode AND
				--	((CITI.IsRouteKey = 0 AND CIIS.RouteCode = CII.RouteCode) OR (CITI.IsRouteKey = 1 AND CIIS.RouteCode = @RouteCode)) AND
				--	--((CITI.IsFacilityRouteKey = 0 AND CIIS.FacilityRouteCode = CII.FacilityRouteCode) OR (CITI.IsFacilityRouteKey = 1)) AND
				--	((CITI.IsMachineKey = 0 AND CIIS.MachineCode = CII.MachineCode) OR (CITI.IsMachineKey = 1 AND CIIS.MachineCode = @MachineCode)) AND
				--	((CITI.IsMoldKey = 0 AND CIIS.MoldNumber = CII.MoldNumber) OR (CITI.IsMoldKey = 1 AND CIIS.MoldNumber = @MoldNumber)) AND
				--	((CITI.IsMaterialKey = 0 AND CIIS.MaterialCode = CII.MaterialCode) OR (CITI.IsMaterialKey = 1 AND CIIS.MaterialCode = @MaterialCode)) AND
				--	((CITI.IsCategoryKey = 0 AND CIIS.CategoryName = CII.CategoryName) OR (CITI.IsCategoryKey = 1 AND CIIS.CategoryName = @CategoryName))
	WHERE
			(CII.CompanyCode = @CompanyCode) AND
			(CII.WorkCenterCode = @WorkCenterCode) AND
			(CII.CommInspTypeCode = @CommInspTypeCode) AND
			((CII.LineCode = '') OR (CII.LineCode = @LineCode)) AND
			--((CII.RouteCode = '') OR (CII.RouteCode = @RouteCode)) AND
			((CII.MachineCode = '') OR (CII.MachineCode = @MachineCode)) AND
			--((CII.MoldNumber = '') OR (CII.MoldNumber = @MoldNumber)) AND
			((CII.ProductGroupCode = '') OR (CII.ProductGroupCode = @ProductGroupCode)) AND
			((CII.MaterialCode = '') OR (CII.MaterialCode = @MaterialCode)) AND
			((CII.CategoryName = '') OR (CII.CategoryName = @CategoryName))
	ORDER BY
			CII.DisplayIndex

	DECLARE @Row INT,
			@Count INT,
			@CommInspDocItemNo VARCHAR(20),
			@CommInspMeasureNo VARCHAR(20)

	SELECT
			@Row = 1,
			@Count = COUNT(*)
	FROM
			@Items

	WHILE @Row <= @Count BEGIN
		EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_CommInspDocItem', @CommInspDocItemNo OUTPUT

		INSERT INTO STB_CommInspDocItem
		(
			CommInspDocItemNo,
			CommInspDocNo,
			CommInspItemCode,
			CommInspUnit,
			RouteCode,
			CommInspItemDesc,
			CommInspInputType,
			CommInspItemSpec,
			CommInspUpper,
			CommInspLower,
			ItemTargetQty,
			ItemQty,
			CreateDateTime,
			CreateUserID
		)
		SELECT
				@CommInspDocItemNo,
				@CommInspDocNo,
				I.CommInspItemCode,
				I.CommInspUnit,
				I.RouteCode,
				I.CommInspItemDesc,
				I.CommInspInputType,
				I.CommInspItemSpec,
				I.CommInspUpper,
				I.CommInspLower,
				I.ItemTargetQty,
				0,
				GETDATE(),
				@ProcessUserID
		FROM
				@Items I
				INNER JOIN STB_CommInspItem CII
					ON	CII.CommInspItemCode = I.CommInspItemCode
		WHERE
				I.Row = @Row

		SET @Row = @Row + 1
	END

END

--select * from STB_CommInspDocItem where CommInspDocNo='20241223000007'

--select * from STB_CommInspDocHistory where CommInspDocNo='20241223000007'
