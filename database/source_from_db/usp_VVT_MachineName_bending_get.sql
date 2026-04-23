
CREATE  PROC  [dbo].[usp_VVT_MachineName_bending_get]
@pWorkCenterCode varchar(20),
@pRework INT = 0
AS
BEGIN
	SET NOCOUNT ON;

		if(ISNULL(@pRework,0)=1) begin
				select distinct MachineName , MachineName MachineNameVal
				from STB_MachineMaster with(nolock) where IsUsed=1
			end 

		-- -------------------- 2025-01-13 DinhManh add for Ha Nam factory 
		else if(@pWorkCenterCode='VVT_F3')
			begin
				SELECT MCM.MachineName
				FROM STB_ProductMachine PM
				LEFT OUTER JOIN STB_MachineMaster MCM WITH(NOLOCK) ON PM.MachineCode = MCM.MachineCode
				WHERE	PM.RouteCode = 'VE08'
					and MCM.MachineName LIKE '%Taping%'
				
			end
		----------------------------------------------------------------

		else 
			begin
				select 'Taping 1' as MachineName,'Taping 1' as MachineNameVal 
				union all
				select 'Taping 2' , 'Taping 2'  
				union all
				select 'Taping 3' , 'Taping 3'  
				union all
				select 'Taping 4' , 'Taping 4'  
				union all
				select 'Taping 5' , 'Taping 5'  
				union all
				select 'Taping 6' , 'Taping 6'  
				union all
				select 'Taping 7' , 'Taping 7'  
				union all
				select 'Taping 8' , 'Taping 8'  
				union all
				select 'Bending 1' , 'Bending 1'  
				union all
				select 'Bending 2' , 'Bending 2'  
				union all
				select 'Bending 3' , 'Bending 3'  
				union all
				select 'Bending 4' , 'Bending 4'  
				union all

				select 'Bending 1(10)' , 'Bending 1(10)'  
				union all
				select 'Bending 2(13)' , 'Bending 2(13)'  
				union all
				select 'Bending 3(16)' , 'Bending 3(16)'
				union all
				select 'Bending 4(module)' , 'Bending 4(module)'
				union all
				select 'Toshiba' , 'Toshiba'
				union all
				select 'Cutting 1(8)' , 'Cutting 1(8)'
				union all
				select 'Cutting 2(10)' , 'Cutting 2(10)'
				union all
				select 'Cutting 3(module)' , 'Cutting 3(module)'
				union all
				select 'Tapping #1 BG' , 'Tapping #1 BG'
		end
END
