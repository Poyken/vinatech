-- =============================================
-- Author: Mr.Tung
-- Create date: 2021-12-30
-- Browsable : true
-- =============================================
CREATE  PROCEDURE [dbo].[usp_Vietnam_RollPressingSlitting_get]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pElectrodeLotNumber VARCHAR(20) = NULL
AS
BEGIN
	DECLARE @ElectrodeLotNumber VARCHAR(20)
	SET @ElectrodeLotNumber = @pElectrodeLotNumber

	declare @topLotNo  VARCHAR(20) ; 
	declare @error varchar(1000) =''; 



	select top 1 @topLotNo = sim.barcode FROM STB_SetInfo SIM   with(nolock) 
	join STB_SetInfo SIB  with(nolock)  on  sim.materialcode = sib.materialcode
	LEFT OUTER JOIN STB_ElectrodeRollPressingInfo ERPI  with(nolock)  ON  SIM.Barcode = ERPI.ElectrodeLotNumber
	--LEFT OUTER JOIN STB_ElectrodeWasteInfoNew eci  with(nolock) on SIM.Barcode = eci.Barcode
	where sib.barcode= @ElectrodeLotNumber
	and sim.createdatetime < sib.createdatetime
	and ERPI.GoodQty is null
	and SIM.Barcode like 'VV%'
	--and sim.barcode < 'VVMJ1820001E04'
	and sim.barcode < @ElectrodeLotNumber
	--and (eci.CompanyCode='VVT' or eci.CompanyCode is null)
	order by sim.CreateDateTime,sim.barcode	
	/*
   if(@topLotNo <> @ElectrodeLotNumber and @@ROWCOUNT>0 )
		select  @error = @error + ' ROLLPRESS: LOT DIEN CUC:    "'+@topLotNo+'"    CHUA NHAP CONG DOAN ROLLPRESS, CAN NHAP LOT:      "'+@topLotNo+'"    TRUOC';
*/

		

	select top 1 @topLotNo = sim.barcode FROM STB_SetInfo SIM   with(nolock) 
	join STB_SetInfo SIB  with(nolock)  on  sim.materialcode = sib.materialcode 
	LEFT OUTER JOIN STB_ElectrodeRollPressingInfo ERPI  with(nolock)  ON  SIM.Barcode = ERPI.ElectrodeLotNumber 
	--LEFT OUTER JOIN STB_ElectrodeWasteInfoNew eci  with(nolock) on SIM.Barcode = eci.Barcode
	OUTER APPLY (
		select top 1 * from STB_ElectrodeSlittingResult esr  with(nolock)  
		where esr.ElectrodeLotNumber = ERPI.ElectrodeLotNumber 			
		) esr
	where sib.barcode= @ElectrodeLotNumber 
	and sim.createdatetime < sib.createdatetime 
	and SIM.Barcode like 'VV%'
	and ERPI.GoodQty>0	
	and sim.barcode < @ElectrodeLotNumber
	and  ( esr.GoodQtyLength is null   and  esr.ProductionQty is null )
	--and (eci.CompanyCode='VVT' or eci.CompanyCode is null)
	order by sim.CreateDateTime,sim.barcode 
	   	/*
    if(@topLotNo <> @ElectrodeLotNumber and @@ROWCOUNT>0 ) 
		select  @error = @error + 
									'                                                                                                     ' +
									'                                                                                                     ' +
				'SLITTING: LOT DIEN CUC:    "'+@topLotNo+'"    CHUA NHAP CONG DOAN SLITTING, CAN NHAP LOT:      "'+@topLotNo+'"    TRUOC'; 
		
		*/
		
	if(@error<>'') 
	begin 
			raiserror (@error,16,1) ; 
			return; 
	end 
	

	select  @ElectrodeLotNumber as ElectrodeLotNumber 
	

	----SELECT   ISNULL(ERPI.ElectrodeLotNumber, SI.Barcode) AS ElectrodeLotNumber
	----		,ERPI.MachineCode
	----		,MM.MachineName
	----		,ERPI.WorkDate
	----		,ERPI.WorkerCode 
	----		,PWI.WorkerName
	----		,ERPI.Temperature
	----		,ERPI.Humidity
	----		,ERPI.RollingDensityValue
	----		,ERPI.RollingDensityResult
	----		,ERPI.HeadGapInitLeft
	----		,ERPI.HeadGapInitRight
	----		,ERPI.ProdConTemp
	----		,ERPI.ProdConSpeed
	----		,ERPI.ProductionQty
	----		,ERPI.GoodQty
	----		,ERPI.BadQty
	----		,ERPI.VisualInspectionResult
	----		,ERPI.CreateDateTime
	----		,ERPI.CreateUserID
	----		,ERPI.ChangeDateTime
	----		,ERPI.ChangeUserID
	----		,SI.MaterialCode
	----		,MM2.MaterialName
	----		,MM2.MaterialThickness
	----		,'Report' AS CommandType
	----		,'O' AS IsRollPress
	----		, dbo.fnGetElectrodeDensityAvg(@ElectrodeLotNumber) AS QcRollingDensityValue
	----		, Round(dbo.fnGetElectrodeDensityAvg(@ElectrodeLotNumber), 3) AS QcRollingDensityValueNew
	----  FROM STB_SetInfo SI with(nolock) 
	----  LEFT OUTER JOIN STB_MaterialMaster MM2 with(nolock) 	                 ON SI.MaterialCode = MM2.MaterialCode
	----  LEFT OUTER JOIN STB_ElectrodeRollPressingInfo ERPI with(nolock) 	    ON SI.Barcode = ERPI.ElectrodeLotNumber
	----  LEFT OUTER JOIN STB_MachineMaster MM with(nolock) 	    ON ERPI.MachineCode = MM.MachineCode
	----   LEFT OUTER JOIN STB_ProdWorkerInfo PWI with(nolock) 	    ON ERPI.WorkerCode = PWI.WorkerCode
	---- WHERE SI.Barcode = @ElectrodeLotNumber
	   
END