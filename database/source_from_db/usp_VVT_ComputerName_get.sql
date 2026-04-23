--exec usp_VVT_ComputerName_get '',''

CREATE  PROCEDURE [dbo].[usp_VVT_ComputerName_get]
						@pDept NVARCHAR(100) = NULL,
						@pComputerName  NVARCHAR(100) = NULL,
						@pSearch varchar(10) = null
AS
     
	
BEGIN 
	SET NOCOUNT ON;

	/*
	update   abc 
	set EmpID=(select top 1 EmpID from  SmartFactoryV2.dbo.stb_Vietnam_controlpanel where ComputerName=abc.ComputerName and EmpID is not null and replace(EmpID,' ','')<>'')
	from SmartFactoryV2.dbo.stb_Vietnam_controlpanel abc
	where  EmpID is  null or replace(EmpID,' ','')=''
	*/

	--RAISERROR (@pDept,16,1);
	/*
	select distinct top 10000  isnull(EmpID,'')EmpID,ComputerName 
	from  SmartFactoryV2.dbo.stb_Vietnam_controlpanel with(nolock)
	where (isnull(@pDept,'')='' or ComputerName like '%'+@pDept+'%')
	and   (isnull(@pComputerName,'')='' or ComputerName like '%'+@pComputerName+'%')
	and ComputerName not like '%CELL%' and ComputerName<> 'DESKTOP-JLRU374' and ComputerName not like '%KIOS%'
	order by ComputerName
	--Lỗi 16 hecxa thì do có kí tự đặc biệt hoặc tiếng hàn trong EmpID
	*/

	--
	if (@pSearch = 'update')
	begin
	--RAISERROR(@pSearch, 16, 1)
		delete from stb_Vietnam_controlpanel_test

		insert into  stb_Vietnam_controlpanel_test(EmpID,ComputerName,CreateDateTime)
		select DISTINCT top 10000   isnull(EmpID,'') as EmpID,ComputerName,GETDATE() from  SmartFactoryV2.dbo.stb_Vietnam_controlpanel with(nolock)
		where (isnull(@pDept,'')='' or ComputerName like '%'+@pDept+'%')
		and   (isnull(@pComputerName,'')='' or ComputerName like '%'+@pComputerName+'%')
		and ComputerName not like '%CELL%' and ComputerName<> 'DESKTOP-JLRU374' and ComputerName not like '%KIOS%'
		and status1 is null
		order by ComputerName
		
	end
	if (@pSearch = 'search')
	begin
	--RAISERROR(@pSearch, 16, 1)
			SELECT * FROM Stb_Vietnam_ControlPanel_test
	end

END 

