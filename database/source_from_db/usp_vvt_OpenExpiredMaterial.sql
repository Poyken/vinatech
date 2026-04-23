

CREATE PROCEDURE [dbo].[usp_vvt_OpenExpiredMaterial]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pFromDate datetime=null,
	@pToDate datetime=null,
	@pLotID VARCHAR(20)=null
AS
BEGIN
	SET NOCOUNT ON;


	declare @counttime int = null
	declare @count int =0
	declare @OpenExpired bit = null


	select @count=count(*) 
	from stb_vvt_OpenExpiredMaterial with(nolock) 
	where Lotid=@pLotID 
	

	--if(@count>0) 
	--begin
	--	select top 1 @OpenExpired = OpenExpired
	--	from stb_vvt_OpenExpiredMaterial with(nolock) 
	--	where Lotid=@pLotID
	--	group by Lotid
	--	order by createdatetime desc
	--end
	   	

	if(len(@pLotID)>10 and @count =0 )
		insert into stb_vvt_OpenExpiredMaterial(LotID,CreateUserID,OpenExpired) 
		values(@pLotID,@pProcessUserID,convert(BIT,1))

	
	;with data1 as (
	select LotID,max(createdatetime) as createdatetime
	from stb_vvt_OpenExpiredMaterial  with(nolock) 
	where (LotID=@pLotID or isnull(@pLotID,'')='' )
	and (createdatetime between @pFromDate and @pToDate or @pFromDate is null or @pToDate is null)
	group by lotid
	)
	select 
		 voem.*, 		 
		 (case  when   (DATEPART(HOUR, voem.createdatetime) > 10)     
				then     convert(varchar(10), voem.createdatetime, 120)    
				else    convert(varchar(10),DATEADD(DAY, -1,  voem.createdatetime), 120)       
			 end 
		 ) as  JobDate 
	from stb_vvt_OpenExpiredMaterial voem with(nolock) 
	join data1 on voem.lotid=data1.lotid and voem.createdatetime = data1.createdatetime 
	order by voem.createdatetime desc 

END

