CREATE PROC [dbo].[usp_lineinfo_qcaudit]
AS
BEGIN
	select linecode , replace(replace(linename,'#',''),'  ',' ') as linename, replace(replace(linedesc,'#',''),'  ',' ')  as linedesc
	  from stb_lineinfo with(nolock)
	  where companycode='VVT' and isused=1 and linecode not like 'SB2%'
	  order by linecode
END