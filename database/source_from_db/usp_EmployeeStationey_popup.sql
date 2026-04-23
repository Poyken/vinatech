CREATE procedure [dbo].[usp_EmployeeStationey_popup]
as
begin
	select  Codeemp,
			Name,
			Department,
			Sex,
			Birthday,
			Address,
			Phonenumber,
			isUsed
	from Stb_EmployeeStationery
	where IsUsed =1

end