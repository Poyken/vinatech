
CREATE PROCEDURE [dbo].[usp_VVT_mrtungtestSQL]
AS
BEGIN

	SET NOCOUNT ON;

declare @nval varchar(100)='nam_2020';
declare @nval1 nvarchar(1000) = N';WITH x1 AS
( 	
	select Giai_thua = 1, N = 1
	union all
	select (x1.N+1) * ( x1.Giai_thua), (x1.N+1) as N
		from x1	 
		where x1.N<5
)
select 	
	N as ' + @nval + N'
	,	
	Giai_thua 
from x1;
'
exec sp_executesql @nval1;

end