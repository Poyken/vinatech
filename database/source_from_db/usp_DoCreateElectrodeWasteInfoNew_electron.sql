CREATE PROC [dbo].[usp_DoCreateElectrodeWasteInfoNew_electron]
	@pElectrodeLotNumber VARCHAR(20)
   ,@pJobDate VARCHAR(100)
   ,@pRouteCode VARCHAR(100)
   ,@pCurrentCollectorClassCode VARCHAR(100)
   ,@pMachineCode VARCHAR(100)
   ,@pDefectCode VARCHAR(100)
   ,@pDefectWeight VARCHAR(100)
   ,@pRemark NVARCHAR(100)
AS
BEGIN
	Declare @ElectrodeWasteNo VARCHAR(20)
	       ,@ElectrodeLotNumber VARCHAR(20) = @pElectrodeLotNumber
	       ,@CompanyCode VARCHAR(20) = case when @pElectrodeLotNumber like 'VV%' then 'VVT' else 'VNT' end          --add by Mr.Tung on 2022-May-24 for separate companycode
		   ,@WorkCenterCode VARCHAR(20) = case when @pElectrodeLotNumber like 'VV%' then 'VVT_F1' else 'VNT_F1' end
		   ,@LineCode VARCHAR(20) = 'ELECTRODE LINE'
		   ,@JobDate DATE = CONVERT(DATE, @pJobDate, 121)
		   ,@CalendarCode VARCHAR(20)
		   ,@RouteCode VARCHAR(20) = @pRouteCode
		   ,@ElectrodeClassCode VARCHAR(20)
		   ,@CurrentCollectorClassCode VARCHAR(20) = @pCurrentCollectorClassCode
		   ,@ElectrodeThickness VARCHAR(20)
		   ,@MachineCode VARCHAR(20) = @pMachineCode
		   ,@DefectCode VARCHAR(20) = @pDefectCode
		   ,@DefectWeight NUMERIC(20,5) = CONVERT(NUMERIC(20,5), @pDefectWeight)
		   ,@Remark NVARCHAR(100) = @pRemark
		   ,@materialcode VARCHAR(50) = ''
		   ,@materialname VARCHAR(200) = ''
		   

	-- 1. 일련번호 채번
	EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_ElectrodeWasteInfoNew',@ElectrodeWasteNo OUTPUT


	-- 2. 근무조코드
	SET @CalendarCode = dbo.fnGetCalendarCode()


	-- 3. 전극종류, 전극두께
	SELECT @ElectrodeClassCode = MaterialSource 
	      ,@ElectrodeThickness = MaterialThickness 
		  ,@materialcode = MaterialCode 
		  ,@materialname = MaterialName 
	  FROM STB_MaterialMaster
	 WHERE MaterialCode = (SELECT MaterialCode FROM STB_SetInfo WHERE Barcode = @ElectrodeLotNumber)


	 --add by Mr.Tung on 2022-May-24 for automatic get  Etching, Forming data 
	 set @CurrentCollectorClassCode = case when rtrim(ltrim(isnull(@pCurrentCollectorClassCode,'')))='' then 
												case when @materialcode like '%CRE%' or @materialname like '%etching%' or @materialname like '(+)' then 'Etching'
												else 'Forming' end
									  end


	INSERT INTO STB_ElectrodeWasteInfoNew 
	(
		ElectrodeWasteNo,CompanyCode,WorkCenterCode,LineCode,JobDate
       ,CalendarCode,RouteCode,ElectrodeClassCode,CurrentCollectorClassCode,ElectrodeThickness
       ,MachineCode,DefectCode,DefectWeight,Remark,CreateDateTime
       ,CreateUserID,Barcode
	) VALUES (
		@ElectrodeWasteNo,@CompanyCode,@WorkCenterCode,@LineCode, @JobDate
       ,@CalendarCode,@RouteCode,@ElectrodeClassCode,@CurrentCollectorClassCode,@ElectrodeThickness
       ,@MachineCode,@DefectCode,@DefectWeight,@Remark,GETDATE()
       ,'eai',@ElectrodeLotNumber
	)

END
