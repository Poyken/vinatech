-- 생산계획 인터페이스 프로시저
-- =============================================
-- Author: jackaroe(yjyu@vina.co.kr)
-- Create date: 2021-04-17
-- Browsable : true
-- Group : 인터페이스
-- Source Table: SmartFactoryV2.DBO.STB_MontylyProdPlan_ITF
-- Target Table: NEOE.NEOE.PR_Z_VINA_PLAN_IF
-- Description:	월별생산계획 인터페이스
-- Modified:
-- =============================================
CREATE PROC usp_MontylyProdPlan_itf
	@pProcessUserID VARCHAR(20) 
   ,@pProcessLanguage VARCHAR(20)
   ,@pIUCompanyCode VARCHAR(20)
AS
BEGIN
	Declare @IUCompanyCode VARCHAR(20) = @pIUCompanyCode

	-- 인터페이스 할 대상 변수 선언
	Declare @CompanyCode	NVARCHAR(7)
           ,@LineSeq	NUMERIC(17)
           ,@FactoryCode	NVARCHAR(7)
           ,@PlanMonth	NCHAR(6)
           ,@EmpCode	NVARCHAR(10)
           ,@PlanDateCode	NVARCHAR(3)
           ,@ProdPlanOrderNo	NUMERIC(4)
           ,@MaterialCode	NVARCHAR(20)
           ,@StockVNTQty	NUMERIC(17,4)
           ,@StockVVTQty	NUMERIC(17,4)
           ,@SalesNonDeliveryCellQty	NUMERIC(17,4)
           ,@SalesNonDeliveryMdlQty	NUMERIC(17,4)
           ,@PackingVNTQty	NUMERIC(17,4)
           ,@PackingVVTQty	NUMERIC(17,4)
           ,@AddProdVNTQty	NUMERIC(17,4)
           ,@AddProdVVTQty	NUMERIC(17,4)
           ,@SalesPlanFixCellQty	NUMERIC(17,4)
           ,@SalesPlanFixMdlQty	NUMERIC(17,4)
           ,@SalesPlanAddCellQty	NUMERIC(17,4)
           ,@SalesPlanAddMdlQty	NUMERIC(17,4)
           ,@ProdPlanPreProdQty	NUMERIC(17,4)
           ,@ProdPlanChangeReqQty	NUMERIC(17,4)
           ,@ProdPlanVNTQty	NUMERIC(17,4)
           ,@ProdPlanVVTQty	NUMERIC(17,4)
           ,@CreateDateTime	NVARCHAR(14)
           ,@CreateUserID	NVARCHAR(15)
           ,@ChangeDateTime	NVARCHAR(14)
           ,@ChangeUserID	NVARCHAR(15)
           ,@IUDFlag	VARCHAR(10)


	-- Cursor 선언
	Declare icur CURSOR FOR
		-- Query
		SELECT CD_COMPANY
              ,SEQ_MMPLAN
              ,CD_PLANT
              ,YM_PLAN
              ,NO_EMP
              ,CD_DT_PLAN
              ,STA_HST
              ,CD_ITEM
              ,QT_INV_KR
              ,QT_INV_VN
              ,QT_GI_REMAIN_CELL
              ,QT_GI_REMAIN_MDL
              ,QT_WGR_KR
              ,QT_WGR_VN
              ,QT_WGR_ADD_KR
              ,QT_WGR_ADD_VN
              ,QT_SAPLAN_CF_CELL
              ,QT_SAPLAN_CF_MDL
              ,QT_SAPLAN_ADD_CELL
              ,QT_SAPLAN_ADD_MDL
              ,QT_MPS_PRE
              ,QT_MPS_ADJUST
              ,QT_MPS_KR
              ,QT_MPS_VN
              ,DTS_INSERT
              ,ID_INSERT
              ,DTS_UPDATE
              ,ID_UPDATE
              ,FG_IUD
		  FROM NEOE.NEOE.PR_Z_VINA_PLAN_IF
		 WHERE CD_COMPANY = @IUCompanyCode
	OPEN icur
		WHILE 1 = 1 BEGIN
			FETCH NEXT FROM icur INTO
				@CompanyCode
               ,@LineSeq
               ,@FactoryCode
               ,@PlanMonth
               ,@EmpCode
               ,@PlanDateCode
               ,@ProdPlanOrderNo
               ,@MaterialCode
               ,@StockVNTQty
               ,@StockVVTQty
               ,@SalesNonDeliveryCellQty
               ,@SalesNonDeliveryMdlQty
               ,@PackingVNTQty
               ,@PackingVVTQty
               ,@AddProdVNTQty
               ,@AddProdVVTQty
               ,@SalesPlanFixCellQty
               ,@SalesPlanFixMdlQty
               ,@SalesPlanAddCellQty
               ,@SalesPlanAddMdlQty
               ,@ProdPlanPreProdQty
               ,@ProdPlanChangeReqQty
               ,@ProdPlanVNTQty
               ,@ProdPlanVVTQty
               ,@CreateDateTime
               ,@CreateUserID
               ,@ChangeDateTime
               ,@ChangeUserID
               ,@IUDFlag
            IF @@FETCH_STATUS <> 0 BEGIN
				BREAK
			END

			IF EXISTS (SELECT 1 
			             FROM SmartFactoryV2.DBO.STB_MontylyProdPlan_ITF
						WHERE CompanyCode = @CompanyCode
                          AND LineSeq = @LineSeq
                          AND FactoryCode = @FactoryCode
                          AND PlanMonth = @PlanMonth
                          AND EmpCode = @EmpCode
                          AND PlanDateCode = @PlanDateCode
                          AND ProdPlanOrderNo = @ProdPlanOrderNo
                          AND MaterialCode = @MaterialCode
			) BEGIN
				IF @IUDFlag = 'U' BEGIN
					-- UPDATE
					UPDATE SmartFactoryV2.DBO.STB_MontylyProdPlan_ITF
					   SET StockVNTQty = @StockVNTQty
                          ,StockVVTQty = @StockVVTQty
                          ,SalesNonDeliveryCellQty = @SalesNonDeliveryCellQty
                          ,SalesNonDeliveryMdlQty = @SalesNonDeliveryMdlQty
                          ,PackingVNTQty = @PackingVNTQty
                          ,PackingVVTQty = @PackingVVTQty
                          ,AddProdVNTQty = @AddProdVNTQty
                          ,AddProdVVTQty = @AddProdVVTQty
                          ,SalesPlanFixCellQty = @SalesPlanFixCellQty
                          ,SalesPlanFixMdlQty = @SalesPlanFixMdlQty
                          ,SalesPlanAddCellQty = @SalesPlanAddCellQty
                          ,SalesPlanAddMdlQty = @SalesPlanAddMdlQty
                          ,ProdPlanPreProdQty = @ProdPlanPreProdQty
                          ,ProdPlanChangeReqQty = @ProdPlanChangeReqQty
                          ,ProdPlanVNTQty = @ProdPlanVNTQty
                          ,ProdPlanVVTQty = @ProdPlanVVTQty
                          ,ChangeDateTime = GETDATE()
                          ,ChangeUserID = 'eai'
					 WHERE CompanyCode = @CompanyCode
                       AND LineSeq = @LineSeq
                       AND FactoryCode = @FactoryCode
                       AND PlanMonth = @PlanMonth
                       AND EmpCode = @EmpCode
                       AND PlanDateCode = @PlanDateCode
                       AND ProdPlanOrderNo = @ProdPlanOrderNo
                       AND MaterialCode = @MaterialCode
				END
			END ELSE BEGIN
				-- INSERT
				INSERT INTO STB_MontylyProdPlan_ITF (
					CompanyCode
                   ,LineSeq
                   ,FactoryCode
                   ,PlanMonth
                   ,EmpCode
                   ,PlanDateCode
                   ,ProdPlanOrderNo
                   ,MaterialCode
                   ,StockVNTQty
                   ,StockVVTQty
                   ,SalesNonDeliveryCellQty
                   ,SalesNonDeliveryMdlQty
                   ,PackingVNTQty
                   ,PackingVVTQty
                   ,AddProdVNTQty
                   ,AddProdVVTQty
                   ,SalesPlanFixCellQty
                   ,SalesPlanFixMdlQty
                   ,SalesPlanAddCellQty
                   ,SalesPlanAddMdlQty
                   ,ProdPlanPreProdQty
                   ,ProdPlanChangeReqQty
                   ,ProdPlanVNTQty
                   ,ProdPlanVVTQty
                   ,CreateDateTime
                   ,CreateUserID
                   ,ChangeDateTime
                   ,ChangeUserID
                   ,IUD_FLAG
				) VALUES (
					@CompanyCode
                   ,@LineSeq
                   ,@FactoryCode
                   ,@PlanMonth
                   ,@EmpCode
                   ,@PlanDateCode
                   ,@ProdPlanOrderNo
                   ,@MaterialCode
                   ,@StockVNTQty
                   ,@StockVVTQty
                   ,@SalesNonDeliveryCellQty
                   ,@SalesNonDeliveryMdlQty
                   ,@PackingVNTQty
                   ,@PackingVVTQty
                   ,@AddProdVNTQty
                   ,@AddProdVVTQty
                   ,@SalesPlanFixCellQty
                   ,@SalesPlanFixMdlQty
                   ,@SalesPlanAddCellQty
                   ,@SalesPlanAddMdlQty
                   ,@ProdPlanPreProdQty
                   ,@ProdPlanChangeReqQty
                   ,@ProdPlanVNTQty
                   ,@ProdPlanVVTQty
                   ,@CreateDateTime
                   ,@CreateUserID
                   ,@ChangeDateTime
                   ,@ChangeUserID
                   ,@IUDFlag
				)
			END
			

		END

		CLOSE icur;
		DEALLOCATE icur;

END