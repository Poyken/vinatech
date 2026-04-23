
CREATE  PROCEDURE  [dbo].[usp_VVTreply_RepairType_popup]

AS
BEGIN
	
	select  'all' as IsQC, 'all' as iid union all
		select  'other' as IsQC, 'other' as iid  union all
	/*
	select  'QC' as IsQC, 'QC' as iid union all
	select  'SX-QC' as IsQC, 'SX-QC' as iid 	union all

	select  'QC_BG' as IsQC, 'QC_BG' as iid union all
	select  'SX-QC_BG' as IsQC, 'SX-QC_BG' as iid 	union all
	select  'other' as IsQC, 'other' as iid 	
	*/
	select TypeErrorCode,TypeErrorNameVI from [STB_TypeErrorGroupOfFactory]
END
