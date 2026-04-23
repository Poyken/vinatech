

CREATE PROCEDURE [dbo].[usp_Vietnam_ElectrodeWHcode_popup]
						@pProcessUserID VARCHAR(20) = NULL ,
						@pProcessLanguage VARCHAR(20) = NULL ,
						@pCompanyCode VARCHAR(20) = NULL 
AS

BEGIN

	select 'ELEC_VN_WH' as WHCode , 'Electrode Slitting WH / Kho Slitting Dien cuc Viet nam' as WHname union all
	select 'ROUTE_VN_WH' as WHCode , 'Production stage WH / Kho Cong doan SX Viet nam' as WHname
END
