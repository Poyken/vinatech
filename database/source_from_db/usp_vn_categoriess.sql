CREATE PROC [dbo].[usp_vn_categoriess]
as
begin
		SELECT DISTINCT TYPES  FROM TYPESCRAP WITH(NOLOCK) 
end