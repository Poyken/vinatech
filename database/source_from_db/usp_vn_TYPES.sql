CREATE PROC [dbo].[usp_vn_TYPES]
as
begin
		SELECT DISTINCT TYPES  FROM TYPESCRAP WITH(NOLOCK) 
		 where TYPES not like 'del-%'
end