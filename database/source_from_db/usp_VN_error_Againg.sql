CREATE proc usp_VN_error_Againg
as
begin
select DefectDesc , COUNT(*)
from STB_DefectInfo with(nolock)
where DefectDesc <>'' AND IsUsed = 1
 GROUP BY DefectDesc
 HAVING COUNT(*) > 1

end
