-- =============================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Create date: 2019-01-24
-- Browsable : true
-- Group : 생산관리
-- Description:	전극슬리팅정보
-- =============================================
CREATE PROCEDURE [dbo].[usp_ElectrodeSlittingInfo_get]
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
	

	SELECT   ISNULL(ESI.ElectrodeLotNumber, SI.Barcode) AS ElectrodeLotNumber
			,ESI.MachineCode
			,MM.MachineName
			,ISNULL(case when @company='VVT' then dateadd(hour,2,(ESI.WorkDate)) else (ESI.WorkDate) end , getdate() ) WorkDate  --    Mr.Tung modified on 2023-07-05, require by Electrode Dept in Vietnam
			,ESI.WorkerCode 
			,PWI.WorkerName
			,ESI.Temperature
			,ESI.Humidity
			,ESI.PushingYn
			,ESI.VisualInspectionResult
			,ESI.SlittingLength
			,ESI.Remark
			,ESI.CreateDateTime
			,ESI.CreateUserID
			,ESI.ChangeDateTime
			,ESI.ChangeUserID
			,SI.MaterialCode
			,MM2.MaterialName
			,MM2.MaterialThickness
			,ESI.PicturesLotNo
	  FROM STB_SetInfo SI
	  LEFT OUTER JOIN STB_MaterialMaster MM2
	    ON SI.MaterialCode = MM2.MaterialCode
	  LEFT OUTER JOIN STB_ElectrodeSlittingInfo ESI
	    ON SI.Barcode = ESI.ElectrodeLotNumber
	  LEFT OUTER JOIN STB_MachineMaster MM
	    ON ESI.MachineCode = MM.MachineCode
	   LEFT OUTER JOIN STB_ProdWorkerInfo PWI
	    ON ESI.WorkerCode = PWI.WorkerCode
	 WHERE SI.Barcode = @ElectrodeLotNumber
END