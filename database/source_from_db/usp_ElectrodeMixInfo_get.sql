-- =============================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Create date: 2019-01-24
-- Browsable : true
-- Group : 생산관리 > [B550] 전극측정결과 > 믹싱첫번째 Tab화면
-- Description:	믹싱측정정보마스터
--                  2020.09.22 냉각수온도 추가 (안제헌)

-- Modify : #210304 @ElectrodeWasteList 와 @FoilWasteList를 폐기물 리스트에서 토탈 금액으로 변경 채민수 대리 요청
--          #210407 전극폐기무게, 호일폐기무게 추가 채민수 대리 요청
-- =============================================
CREATE PROCEDURE [dbo].[usp_ElectrodeMixInfo_get]
						@pProcessUserID VARCHAR(20),
						@pProcessLanguage VARCHAR(20),
						@pElectrodeLotNumber VARCHAR(20) = NULL
AS
BEGIN
	DECLARE @ElectrodeLotNumber VARCHAR(20)
	DECLARE @RowCount INT
	DECLARE @ElectrodeWasteList NUMERIC(20,5) --전극 #210304
	DECLARE @FoilWasteList NUMERIC(20,5) --호일이음부 #210304
	DECLARE @JobDate DATE 
	DECLARE @ElectrodeWasteWeight NUMERIC(20,5) -- #210407
	DECLARE @FoilWasteWeight NUMERIC(20,5) --#210304
	

	SET @ElectrodeLotNumber = @pElectrodeLotNumber



			   
		   -- add by Mr.Tung on 2022-June-07  for  auto fill Empty Mixing in Vietnam, prepared for  Viscosity Software read automatically
		   DECLARE @ccount INT = 0
		   select @ccount = count(*) from STB_ElectrodeMixInfo where electrodelotnumber=@ElectrodeLotNumber
		   if(@ElectrodeLotNumber like 'VV%' and @ccount=0)  
		   begin
                    INSERT INTO STB_ElectrodeMixInfo ( ElectrodeLotNumber,  ViscosityValue )
						VALUES ( @ElectrodeLotNumber,  NULL );
		   end
		   -- end by Mr.Tung

	
	declare @company varchar(10)=''
	select @company=CompanyCode from STB_UserInfo
	where UserID=@pProcessUserID


	SELECT @RowCount = COUNT(*)
	      ,@JobDate = case when @company='VVT' then dateadd(hour,2,MAX(EM.WorkDate)) else MAX(EM.WorkDate) end   --    Mr.Tung modified on 2023-07-05, require by Electrode Dept in Vietnam
	  FROM STB_SetInfo SI
	  LEFT OUTER JOIN STB_ElectrodeMixInfo EM	    ON SI.Barcode = EM.ElectrodeLotNumber
	  LEFT OUTER JOIN STB_MachineMaster MM	    ON EM.MachineCode = MM.MachineCode
	  LEFT OUTER JOIN STB_ProdWorkerInfo PWI	    ON EM.WorkerCode = PWI.WorkerCode
	 WHERE SI.Barcode = @ElectrodeLotNumber

	SELECT @ElectrodeWasteList = SUM(EWIN.DefectWeight * EWPN.DefectUnitPrice)
	      ,@ElectrodeWasteWeight = SUM(EWIN.DefectWeight)
              FROM STB_ElectrodeWasteInfoNew EWIN with(nolock) 
			  LEFT OUTER JOIN STB_ElectrodeWastePriceNew EWPN with(nolock) 
				ON EWPN.ElectrodeClassCode = EWIN.ElectrodeClassCode
			   AND EWPN.CurrentCollectorClassCode = EWIN.CurrentCollectorClassCode
			   AND EWPN.ElectrodeThickness = EWIN.ElectrodeThickness
			   AND EWPN.CompanyCode = EWIN.CompanyCode
			   AND EWPN.WorkCenterCode = EWIN.WorkCenterCode
			   AND EWPN.RouteCode = EWIN.RouteCode
			   AND EWPN.DefectCode = EWIN.DefectCode
              WHERE JobDate = @JobDate
				AND EWIN.DefectCode NOT IN (SELECT DefectCode 
									     FROM STB_DefectInfo 
									    WHERE BasicDefectName = '호일 이음부')

	SELECT @FoilWasteList = SUM(EWIN.DefectWeight * EWPN.DefectUnitPrice)
	      ,@FoilWasteWeight = SUM(EWIN.DefectWeight)
              FROM STB_ElectrodeWasteInfoNew EWIN with(nolock) 
			  LEFT OUTER JOIN STB_ElectrodeWastePriceNew EWPN with(nolock) 
				ON EWPN.ElectrodeClassCode = EWIN.ElectrodeClassCode
			   AND EWPN.CurrentCollectorClassCode = EWIN.CurrentCollectorClassCode
			   AND EWPN.ElectrodeThickness = EWIN.ElectrodeThickness
			   AND EWPN.CompanyCode = EWIN.CompanyCode
			   AND EWPN.WorkCenterCode = EWIN.WorkCenterCode
			   AND EWPN.RouteCode = EWIN.RouteCode
			   AND EWPN.DefectCode = EWIN.DefectCode
              WHERE JobDate = @JobDate
				AND EWIN.DefectCode IN (SELECT DefectCode 
									     FROM STB_DefectInfo  with(nolock) 
									    WHERE BasicDefectName = '호일 이음부')

	IF @RowCount = 0 BEGIN
		RAISERROR('전극 바코드가 존재하지 않습니다.' ,16, 1)
		RETURN
	END
	ELSE BEGIN
		SELECT 	 ISNULL(EM.ElectrodeLotNumber, SI.Barcode) AS ElectrodeLotNumber
				,EM.MachineCode
				,MM.MachineName
				,isnull(case when @company='VVT' then dateadd(hour,2,(EM.WorkDate)) else (EM.WorkDate) end, getdate() ) WorkDate   --    Mr.Tung modified on 2023-07-05, require by Electrode Dept in Vietnam
				,EM.WorkerCode 
				,PWI.WorkerName
				,EM.Temperature 
				,EM.Humidity    
				--,EM.ProductionQty 
				,case when isnull(EM.ProductionQty,0)>0  then EM.ProductionQty 
						else (select sum(InputQty1) from STB_ElectrodeMixStepInfo with(nolock) where ElectrodeLotNumber=SI.Barcode) --add by Mr.Tung on 2022-05-05 by Production Request 
				 end as ProductionQty
				,EM.TankInsideTemp 
				,EM.ViscosityValue 
				,EM.SpecificGravityValue 
				,EM.MixingTemperature    
				,EM.SpecificComment      
				,EM.CreateDateTime       
				,EM.CreateUserID         
				,EM.ChangeDateTime       
				,EM.ChangeUserID
				,SI.MaterialCode
				,MM2.MaterialName
				,MM2.MaterialThickness
				,MM2.MaterialSource
				,dbo.fnGetCalendarCode() AS SystemCalendarCode
				,EM.CoolantTemperature AS CoolantTemperature                               -- 냉각수온도 추가 (안제헌, 2020.09.22)
				,EM.ViscosityResult
				,case   when ((select count(*) from STB_ElectrodeMixStepInfo where ElectrodeMaterialCode like '%GAHSCB-001' and ElectrodeLotNumber=SI.Barcode)) = 0    --if not use Hansol Binder     Mr.Tung modified on 2022-06-30, require by Electrode Dept in Vietnam
						then EM.ViscosityResult 
						else ((case when ViscosityValue>=1800 AND ViscosityValue<=2200 then 'OK' else 'NG' end)) end --if use Hansol binder

				,@ElectrodeWasteList AS ElectrodeWasteList
				,@FoilWasteList AS FoilWasteList
				,'Report' AS CommandType
				,dbo.fnGetCalendarName() AS CalendarName
				,@ElectrodeWasteWeight AS ElectrodeWasteWeight
				,@FoilWasteWeight AS FoilWasteWeight

		  FROM STB_SetInfo SI with(nolock) 
		  LEFT OUTER JOIN STB_MaterialMaster MM2	 with(nolock) 		ON SI.MaterialCode = MM2.MaterialCode
		  LEFT OUTER JOIN STB_ElectrodeMixInfo EM with(nolock) 			ON SI.Barcode = EM.ElectrodeLotNumber
		  LEFT OUTER JOIN STB_MachineMaster MM		 with(nolock)    	ON EM.MachineCode = MM.MachineCode
		  LEFT OUTER JOIN STB_ProdWorkerInfo PWI	 with(nolock) 		ON EM.WorkerCode = PWI.WorkerCode 		 
		 WHERE SI.Barcode = @ElectrodeLotNumber
	END

END


