-- =============================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Create date: 2019-01-24
-- Browsable : true
-- Group : 생산관리 >
--            품질관리 > 
-- Description:	전극코딩공정정보
--                  2020.08.12 구형규요청

-- usp_ElectrodeCoatingInfo_get '','','VJKP1720001E01'
-- =============================================
CREATE PROCEDURE [dbo].[usp_ElectrodeCoatingInfo_get]
						@pProcessUserID VARCHAR(20),
						@pProcessLanguage VARCHAR(20),
						@pElectrodeLotNumber VARCHAR(20) = NULL
AS

BEGIN
	DECLARE @ElectrodeLotNumber VARCHAR(20)
	SET @ElectrodeLotNumber = @pElectrodeLotNumber


		declare @company varchar(10)=''
	select @company=CompanyCode from STB_UserInfo
	where UserID=@pProcessUserID
	   



	SELECT   ISNULL(ECI.ElectrodeLotNumber, SI.Barcode) AS ElectrodeLotNumber
			,ECI.MachineCode
			,MM.MachineName
			,isnull(case when @company='VVT' then dateadd(hour,2,(ECI.WorkDate)) else (ECI.WorkDate) end, getdate() ) as WorkDate   --    Mr.Tung modified on 2023-07-05, require by Electrode Dept in Vietnam
			,ECI.WorkerCode 
			,PWI.WorkerName
			,ECI.Temperature
			,ECI.Humidity
			,ECI.ElectrodeMaterialCode
			,ECI.MaterialLotNumber
			,ECI.OneSideHeadGapLeft
			,ECI.OneSideHeadGapRight
			,ECI.BothSideHeadGapLeft
			,ECI.BothSideHeadGapRight
			,ECI.OneSideCoatingWidth
			,ECI.BothSideCoatingWidth
			,ECI.UnwindingValue
			,ECI.RewindingValue
			,ECI.ProductionQty
			,ECI.GoodQty
			,ECI.BadQty
			,ECI.Remark
			,ECI.SpecificComment1
			,ECI.SpecificComment2
			,ECI.CreateDateTime
			,ECI.CreateUserID
			,ECI.ChangeDateTime
			,ECI.ChangeUserID
			,SI.MaterialCode
			,MM2.MaterialName
			,MM2.MaterialThickness
			,'Report' AS CommandType
			,'X'        AS IsRollPress				
			, Case When Right(MM2.MaterialName, 3) = '(+)'  Then '에칭' 
			         When Right(MM2.MaterialName, 3) = '(-)'  Then '화성'  Else '기타' End  AS ElectrodeDivision       -- 에칭/화성구분 (kilee추가-구형규요청, 2020-08-13)           
			,isnull(ECI.CohesionResult,0) as CohesionResult
			,veci.ViscosityValue --Mr.Tung add on 05-Nov-2021 as Vietnam Production request
			,veci.ViscosityResult --Mr.Tung add on 05-Nov-2021 as Vietnam Production request
			,veci.TocDo_Coating --Mr.Tung add on 25-May-2022 as Vietnam Production request
			,ECI.CurrentCollectorThickness
	  FROM STB_SetInfo SI
			  LEFT OUTER JOIN STB_MaterialMaster MM2	      ON SI.MaterialCode = MM2.MaterialCode
			  LEFT OUTER JOIN STB_ElectrodeCoatingInfo ECI	  ON SI.Barcode = ECI.ElectrodeLotNumber
			  LEFT OUTER JOIN STB_MachineMaster MM	      ON ECI.MachineCode = MM.MachineCode
			  LEFT OUTER JOIN STB_ProdWorkerInfo PWI	      ON ECI.WorkerCode = PWI.WorkerCode
			  LEFT OUTER JOIN stb_Viscosity_ElectrodCoatingInfo_VVT veci on ECI.ElectrodeLotNumber = veci.ElectrodeLotNumber --Mr.Tung add on 05-Nov-2021 as Vietnam Production request
	 WHERE SI.Barcode = @ElectrodeLotNumber

END

