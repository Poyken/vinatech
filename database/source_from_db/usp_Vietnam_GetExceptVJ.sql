
-- =============================================
-- Author:	    Mr.Tung(nguyentung@vina.co.kr)
-- Create date: 2021-04-02
-- Browsable : true
-- Modified:
-- exec usp_Vietnam_GetExceptVJ 'VVLL263R012631', ''
-- =============================================
CREATE PROCEDURE [dbo].[usp_Vietnam_GetExceptVJ]                                  
						@pLotNo VARCHAR(100) = NULL,
						@pDisableVJ INT   OUTPUT
AS

BEGIN
	SET NOCOUNT ON;
		
	DECLARE @LotNo VARCHAR(100) = @pLotNo 
	

select @pDisableVJ = count(*) 
from (
	select 'VVLL253R012628' as LotNo 
	union all 
	select 'VVLL253R012611' 	union all 
	select 'VVLL263R012631' 	union all 
	select 'VVLL203R018614' 	union all 
	select 'VVLL213R018613' 	union all 
	select 'VVLL223R018608' 	union all 
	select 'VVLL233R018612' 	
	union all 
	select   'VVLL233R018630'   union all 
	select   'VVLL133R012604'   union all   
	select   'VVLL183R012616'   union all   
	select   'VVLL183R012617'   union all   
	select   'VVLL263R012614'   union all   
	select   'VVLL183R012622'   union all   
	select   'VVLL113R012620'   union all   
	select   'VVLL113R012602'   union all   
	select   'VVLL183R012621'   union all   
	select   'VVLL153R012625'   union all   
	select   'VVLL253R012629'   union all   
	select   'VVLL113R012619'   union all   
	select   'VVLL123R012601'   union all   
	select   'VVLL083R012627'   union all   
	select   'VVLL113R012621'   
	union all
	 select  'VVLL113R012627'  union all  
	 select  'VVLL123R012626'  union all  
	 select  'VVLL133R012613'  union all  
	 select  'VVLL153R012607'  union all  
	 select  'VVLL153R012614'  union all  
	 select  'VVLL153R012623'  union all  
	 select  'VVLL163R012608'  union all  
	 select  'VVLL173R012628'  union all  
	 select  'VVLL183R012602'  union all  
	 select  'VVLL183R012633'  union all  
	 select  'VVLL193R012626'  union all  
	 select  'VVLL203R012607'  union all  
	 select  'VVLL223R012601'  union all  
	 select  'VVLL223R012620'  union all  
	 select  'VVLL233R012614'  union all  
	 select  'VVLL233R012635'  union all  
	 select  'VVLL243R012623'  union all  
	 select  'VVLL253R012601'  union all  
	 select  'VVLL253R012613'  union all  
	 select  'VVLL123R012603'  union all  
	 select  'VVLL123R012626'  union all  
	 select  'VVLL163R012608'  union all  
	 select  'VVLL173R012628'  
	 union  all  
	select  'VVLL253R012625'  union  all  
	select  'VVLL153R012602'  union  all  
	select  'VVLL123R012602'  union  all  
	select  'VVLL153R012633'  union  all  
	select  'VVLL133R012602'  union  all  
	select  'VVLL153R012601'  union  all  
	select  'VVLL153R012605'  union  all  
	select  'VVLL153R012604'  union  all  
	select  'VVLL133R012627'  
	union all
	select  'VVLL233R018612'  union  all  --ngày 19 tháng 6 2021
	select  'VVLL233R018627'  union  all  
	select  'VVLL253R018625'  union  all  
	select  'VVLL253R018629'  union  all  
	select  'VVLL253R018624'  union  all  
	select  'VVLL243R018610'  union  all  
	select  'VVLL233R018630'  union  all  
	select  'VVLL233R018628'  union  all  
	select  'VVLL203R018621'  union  all  
	select  'VJLL223R018620'  union  all  
	select  'VVLL213R018623'  union  all  
	select  'VVLJ243R018632'  union  all  
	select  'VVLL223R018618'  union  all  
	select  'VVNO162R750603'  union  all  
	select  'VVLL223R018613'    
	union all
	select  'VVLL253R018626'  union  all  
	select  'VVLL233R018612'  union  all
	select  'VVLL173R012612'

	) CheckTable
where LotNo = @LotNo


END


--declare @isAllowVJ int = 0
--exec usp_Vietnam_GetExceptVJ '',@isAllowVJ OUTPUT
--print @isAllowVJ