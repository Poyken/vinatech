
-- =============================================
-- Author:	     Mr.Tung
-- Create date:  2021-05-13
-- =============================================

CREATE PROCEDURE [dbo].[usp_Vietnam_GetModulePartNumber]
AS
BEGIN

	SET NOCOUNT ON;
	
select  distinct partno, PARTNO
from    STB_QC_LOTNO_MODULE  with(nolock)
where   partno is not null

END
