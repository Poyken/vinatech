

CREATE  PROCEDURE [dbo].[usp_VVT_ComputerName_iud]						
						@pEmpId NVARCHAR(100) = NULL,
						@pComputerName  NVARCHAR(100) = NULL,
						@pProcessUserID VARCHAR(20)=null

AS
     
	
BEGIN
	SET NOCOUNT ON;

	--RAISERROR(@pComputerName,16,1)

	update  SmartFactoryV2.dbo.stb_Vietnam_controlpanel 
	set EmpID=@pEmpId , ChangeDateTime=getdate() ,  Offices=isnull(@pProcessUserID,Offices)
	where  ComputerName=@pComputerName 
	and (isnull(EmpID,'')='' or ChangeDateTime >  dateadd(day,-3,getdate()) or ChangeDateTime is null)
	
END
--select * from stb_Vietnam_controlpanel where ComputerName = '120lo5q42BP'