CREATE PROCEDURE [dbo].[usp_VVTMaterialWarehouse_HOLDexpired]
								@pProcessUserID varchar(50)
								,@pCompanyCode					 varchar(50)
								,@pWorkCenterCode				varchar(50)
								,@pSourceMaterialWarehouseCode  varchar(50)
								,@pWarehouseInOutCode			varchar(50)
								,@pLotID						 varchar(50)
								,@pWorkerCode					 varchar(50)
								,@pLineCode						varchar(50)

AS

BEGIN


if(@pCompanyCode<>'VVT') return;
	
	declare @TargetMaterialWarehouseCode VARCHAR(50)	= case when @pSourceMaterialWarehouseCode like '%VN_WH' then 'HOLDING_VN_WH' 
															   when @pSourceMaterialWarehouseCode like '%BG_WH' then 'HOLDING_BG_WH'
															   when @pSourceMaterialWarehouseCode like '%HN_WH' then 'HOLDING_HN_WH'  
															   else @pSourceMaterialWarehouseCode end

			
	if(@pSourceMaterialWarehouseCode=@TargetMaterialWarehouseCode) return;

		   
	   Declare @MaterialWarehouseInOutHistNo VARCHAR(20) 
			EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_MaterialWarehouseInOutHist',@MaterialWarehouseInOutHistNo OUTPUT

			-- INSERT문
			INSERT INTO STB_MaterialWarehouseInOutHist (
															MaterialWarehouseInOutHistNo
															,CompanyCode
															,WorkCenterCode
															,SourceMaterialWarehouseCode
															,TargetMaterialWarehouseCode
															,WarehouseInOutCode
															,LotID
															,WorkerCode
															,LineCode
															,CreateUserID
														) VALUES  (
																		@MaterialWarehouseInOutHistNo
																		,@pCompanyCode
																		,@pWorkCenterCode
																		,@pSourceMaterialWarehouseCode
																		,@TargetMaterialWarehouseCode
																		,@pWarehouseInOutCode
																		,@pLotID
																		,@pWorkerCode
																		,@pLineCode
																		,@pProcessUserID
																	)


			update STB_MaterialLotInfo
			set MaterialWarehouseCode=@TargetMaterialWarehouseCode  ,
			 MaterialLocationCode=@TargetMaterialWarehouseCode+'_01' 
			where LotID=@pLotID 
			and MaterialWarehouseCode not like 'ROUTE%'
			and MaterialWarehouseCode not like 'PROD%'

END
