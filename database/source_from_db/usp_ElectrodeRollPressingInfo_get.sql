-- =============================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Create date: 2019-01-24
-- Browsable : true
-- Group : 생산관리
-- Description:	전극롤프레싱정보
-- =============================================
CREATE PROCEDURE [dbo].[usp_ElectrodeRollPressingInfo_get]
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

	   

	SELECT   ISNULL(ERPI.ElectrodeLotNumber, SI.Barcode) AS ElectrodeLotNumber
			,ERPI.MachineCode
			,MM.MachineName
			,isnull(case when @company='VVT' then dateadd(hour,2,(ERPI.WorkDate)) else (ERPI.WorkDate) end, getdate() ) WorkDate   --    Mr.Tung modified on 2023-07-05, require by Electrode Dept in Vietnam
			,ERPI.WorkerCode 
			,PWI.WorkerName
			,ERPI.Temperature
			,ERPI.Humidity
			,ERPI.RollingDensityValue
			,ERPI.RollingDensityResult
			,ERPI.HeadGapInitLeft
			,ERPI.HeadGapInitRight
			,ERPI.ProdConTemp
			,ERPI.ProdConSpeed
			,ERPI.ProductionQty
			,ERPI.GoodQty
			,ERPI.BadQty
			,ERPI.VisualInspectionResult
			,ERPI.CreateDateTime
			,ERPI.CreateUserID
			,ERPI.ChangeDateTime
			,ERPI.ChangeUserID
			,SI.MaterialCode
			,MM2.MaterialName
			,MM2.MaterialThickness
			,'Report' AS CommandType
			,'O' AS IsRollPress
			,dbo.fnGetElectrodeDensityAvg(@ElectrodeLotNumber) AS QcRollingDensityValue
	  FROM STB_SetInfo SI
	  LEFT OUTER JOIN STB_MaterialMaster MM2	                 ON SI.MaterialCode = MM2.MaterialCode
	  LEFT OUTER JOIN STB_ElectrodeRollPressingInfo ERPI	    ON SI.Barcode = ERPI.ElectrodeLotNumber
	  LEFT OUTER JOIN STB_MachineMaster MM	    ON ERPI.MachineCode = MM.MachineCode
	   LEFT OUTER JOIN STB_ProdWorkerInfo PWI	    ON ERPI.WorkerCode = PWI.WorkerCode
	 WHERE SI.Barcode = @ElectrodeLotNumber
END