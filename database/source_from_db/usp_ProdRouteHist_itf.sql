-- 작업실적 인터페이스 프로시저
-- =============================================
-- Author: jackaroe(yjyu@vina.co.kr)
-- Create date: 2021-04-17
-- Browsable : true
-- Group : 인터페이스
-- Source Table: NEOE.NEOE.PR_WORK_MES
-- Target Table: SmartFactoryV2.DBO.STB_ProdRouteHist
-- Description:	작업실적 인터페이스
-- Modified:
-- =============================================
CREATE PROC [dbo].[usp_ProdRouteHist_itf]
	@pProcessUserID VARCHAR(20) 
   ,@pProcessLanguage VARCHAR(20)
   ,@pIUCompanyCode VARCHAR(20)
   ,@pProudRouteHistNo VARCHAR(20)
   ,@pFGStatus CHAR(1)
   ,@pIsRework CHAR(1) = 'N'
AS
BEGIN
	Declare @IUCompanyCode VARCHAR(20) = @pIUCompanyCode
	       ,@ProudRouteHistNo VARCHAR(20) = @pProudRouteHistNo
		   ,@SystemInterfaceNo VARCHAR(20)

	-- 인터페이스 할 대상 변수 선언
	Declare @CompanyCode	NVARCHAR(7)
           ,@WorkCenterCode	NVARCHAR(7)
           ,@ERPProdRouteHistNo	NVARCHAR(20)
           ,@LabelNo	NVARCHAR(20)
           ,@WorkNo	NVARCHAR(20)
           ,@OPCode	NVARCHAR(4)
           ,@MaterialCode	NVARCHAR(20)
           ,@WorkerCode	NVARCHAR(10)
           ,@ProdDateTime	NCHAR(8)
           ,@WorkTime	NCHAR(6)
           ,@ProdQty	NUMERIC(17,4)
           ,@DefectQty	NUMERIC(17,4)
           ,@GoodQty	NUMERIC(17,4)
           ,@IsRework	NCHAR(1)
           ,@WCCode	NVARCHAR(7)
           ,@CreateDateTime	NVARCHAR(14)
           ,@CreateUserID	NVARCHAR(15)
           ,@LotNo	NVARCHAR(50)
           ,@WCOPCode	NVARCHAR(4)
           ,@DefectPrcessQty	NUMERIC(17,4) 
           ,@IsDefect	NVARCHAR(1)
           ,@MachineCode	NVARCHAR(30)
           ,@FGCheck	NCHAR(1)
           ,@FGStatus	NCHAR(1)
           ,@IsError	NVARCHAR(20)
           ,@ProdRotueHistNo	NVARCHAR(20)
           ,@ProdWarehouseCode	NVARCHAR(7)
           ,@RawMaterialWarehouseCode	NVARCHAR(7)
           ,@IsWO	NCHAR(1)
           ,@IsProd	NCHAR(1)
           ,@BadWarehouseCode	NVARCHAR(7)
           ,@DefectCode	NVARCHAR(4)
           ,@DefectCauseCode	NVARCHAR(4)

	SET @IsRework = @pIsRework
	SET @FGStatus = @pFGStatus

	-- 시스템 인터페이스 일련번호 채번
	EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_SystemInterfaceNo',@SystemInterfaceNo OUTPUT

	-- 실적 입력
	INSERT INTO NEOE.NEOE.PR_WORK_MES (
		CD_COMPANY
       ,CD_PLANT
       ,NO_WO
       ,NO_LABEL
       ,NO_WORK 
       ,CD_OP
       ,CD_ITEM
       ,NO_EMP
       ,DT_WORK
       ,TM_WORK
       ,QT_WORK
       ,QT_REJECT
       ,QT_MOVE
       ,YN_REWORK
       ,CD_WC
       ,DTS_INSERT
       ,ID_INSERT
       ,NO_LOT
       ,CD_WCOP
       ,QT_BAD
       ,YN_BAD_PROC
       ,CD_EQUIP
       ,FG_CHK
       ,FG_STAUS
       ,YN_ERR
       ,NO_WORK_MES
       ,CD_SL_IN
       ,CD_SL_OT
       ,YN_WO
       ,YN_PRO
	   ,YN_WORK
       ,CD_SL_BAD_IN
       ,CD_REJECT
       ,CD_RESOURCE
	   
	) 
	SELECT @IUCompanyCode
	      ,'1000'
		  ,''
		  ,@SystemInterfaceNo
		  ,NULL
		  ,(SELECT CD_OP 
			      FROM NEOE.NEOE.V_PR_Z_VINA_ROUT_L
				 WHERE CD_COMPANY = @IUCompanyCode
				   AND CD_ITEM = MaterialCode
			   )
		  ,MaterialCode
		  ,WorkerCode
		  ,CONVERT(CHAR(8), ProdDateTime, 112)
		  ,0
		  ,ProdQty
		  ,(SELECT SUM(DefectQty) FROM STB_DefectRepairInfo WHERE ControlNo = PRH.ControlNo AND FindRouteCode = PRH.RouteCode)
		  ,ProdQty - (SELECT SUM(DefectQty) FROM STB_DefectRepairInfo WHERE ControlNo = PRH.ControlNo AND FindRouteCode = PRH.RouteCode)
		  ,@IsRework
		  ,CASE WHEN PRH.RouteCode = 'E-22' THEN '1100'
		        WHEN PRH.RouteCode = 'E-25' THEN '1200'
				WHEN PRH.RouteCode = 'E-28' THEN '1400'
				ELSE '' END
		  ,dbo.fnConvertDateTimeToVarchar('yyyymmddhhmiss', GETDATE())
		  ,WorkerCode
		  ,(SELECT DISTINCT Barcode FROM STB_SetInfo WHERE ControlNo = PRH.ControlNo)
		  ,REPLACE(RouteCode, '-', '')
		  ,(SELECT SUM(DefectQty) FROM STB_DefectRepairInfo WHERE ControlNo = PRH.ControlNo AND FindRouteCode = PRH.RouteCode)
		  ,CASE WHEN (SELECT SUM(DefectQty) FROM STB_DefectRepairInfo WHERE ControlNo = PRH.ControlNo AND FindRouteCode = PRH.RouteCode) = 0 THEN 'N' ELSE 'Y' END
		  ,MachineCode
		  ,'0'
		  ,@FGStatus
		  ,'N'
		  ,ProdRouteHistNo
		  ,'W03'
		  ,'W09'
		  ,'Y'
		  ,CASE WHEN @FGStatus = 'T' THEN 'Y' 
					WHEN @FGStatus = 'C' THEN 'N'
					ELSE '' END 
		  ,CASE WHEN @FGStatus = 'C' THEN 'Y' 
			    WHEN @FGStatus = 'T' THEN 'N'
			    ELSE '' END
		  ,'W07'
		  ,''
		  ,''
	  FROM SmartFactoryV2.dbo.STB_ProdRouteHist PRH
	 WHERE ProdRouteHistNo = @ProudRouteHistNo
END