
CREATE proc [dbo].[usp_Vietnam_DryOven_popup]
@pProcessLanguage VARCHAR(20),
@pProcessUserID varchar(20) = null
AS
BEGIN			

		select 'Torr' as unit, 'Torr' as unitname
		union all
		select 'MPa' as unit, 'MPa' as unitname

END
