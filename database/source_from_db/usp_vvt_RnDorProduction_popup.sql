
create  PROCEDURE  [dbo].[usp_vvt_RnDorProduction_popup] 
AS 

BEGIN 
	SET NOCOUNT ON; 
	
	select N'SX Điện cực' as  TypeName , N'SX Điện cực' as TypeValue  union all    
	select N'RnD' ,     'RnD'                   

END 
