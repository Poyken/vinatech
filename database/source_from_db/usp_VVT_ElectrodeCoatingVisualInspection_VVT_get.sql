-- =============================================
-- Author: Mr.Tung
-- Create date: 2022-03-22
-- Browsable : true
-- [usp_VVT_ElectrodeCoatingVisualInspection_VVT_get] '','','2023-01-31','2023-02-21'
-- =============================================
CREATE PROCEDURE [dbo].[usp_VVT_ElectrodeCoatingVisualInspection_VVT_get]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pFromDate DAteTime = NULL,
	@pToDate DAteTime = NULL--,
	--@pBarCode VARCHAR(50) = NULL
AS
BEGIN
	
	SET nocount on;

	declare @FromDate VARCHAR(20)= convert(varchar(10),@pFromDate,120) +  ' 08:00:00';
	declare @ToDate VARCHAR(20)= convert(varchar(10),dateadd(day,1,@pToDate),120) + ' 08:00:00';


		select ERPVII.* 			
		,ECI2.MachineCode
		,MM.MachineName
		,eci.TocDo_Coating
		,eci.ViscosityValue
		from STB_ElectrodeCoatingVisualInspectionInfo ERPVII with(nolock) 	
		left outer join STB_Viscosity_ElectrodCoatingInfo_VVT  eci with(nolock) 
									on  ERPVII.ElectrodeLotNumber = eci.ElectrodeLotNumber
		 LEFT OUTER JOIN STB_ElectrodeCoatingInfo ECI2 with(nolock)	  ON ERPVII.ElectrodeLotNumber = ECI2.ElectrodeLotNumber
		 LEFT OUTER JOIN STB_MachineMaster MM	 with(nolock)	      ON ECI2.MachineCode = MM.MachineCode
		where  ERPVII.CreateDateTime between @FromDate and @ToDate
		and ERPVII.electrodelotnumber like 'V%E%'
			 
END
