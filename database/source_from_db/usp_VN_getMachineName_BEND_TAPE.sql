
CREATE  PROC  [dbo].[usp_VN_getMachineName_BEND_TAPE]
AS
BEGIN
	SET NOCOUNT ON;

	select 'Taping £1' as MachineName,'Taping £1' as MachineNameVal 
	union all
	select 'Taping £2' , 'Taping £2'  
	union all
	select 'Taping £3' , 'Taping £3'  
	union all
	select 'Taping £3' , 'Taping £3'  
	union all
	select 'Taping £4' , 'Taping £4'  
	union all
	select 'Bending £1' , 'Bending £2'  
	union all
	select 'Bending £3' , 'Bending £3'  
	union all
	select 'Bending £4' , 'Bending £4'  
	union all
	select 'Bending £1(10)' , 'Bending £1(10)'  
	union all
	select 'Bending £2(13)' , 'Bending £2(13)'  
	union all
	select 'Bending £3(16)' , 'Bending £3(16)'
	union all
	select 'Bending £4(module)' , 'Bending £4(module)'
	union all
	select 'Toshiba' , 'Toshiba'
	union all
	select 'Cutting £1(8)' , 'Cutting £1(8)'
	union all
	select 'Cutting £2(10)' , 'Cutting £2(10)'
	union all
	select 'Cutting £3(module)' , 'Cutting £3(module)'
END
