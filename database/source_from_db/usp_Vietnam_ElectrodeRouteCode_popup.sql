

create PROCEDURE [dbo].[usp_Vietnam_ElectrodeRouteCode_popup]
						@pProcessUserID VARCHAR(20) = NULL ,
						@pProcessLanguage VARCHAR(20) = NULL ,
						@pCompanyCode VARCHAR(20) = NULL 
AS

BEGIN

	select 'Mixing' as ElectrodeRouteCode , 'Cong doan Mixing' as ElectrodeRouteName union all
	select 'Coating' as ElectrodeRouteCode , 'Cong doan Coating' as ElectrodeRouteName union all
	select 'Rollpress' as ElectrodeRouteCode , 'Cong doan Rollpress' as  ElectrodeRouteName union all
	select 'Slitting' as ElectrodeRouteCode , 'Cong doan Slitting' as ElectrodeRouteName

END
