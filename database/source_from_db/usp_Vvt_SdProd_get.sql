-- =============================================
-- Author : Mr.Tung
-- Group : 공통
-- Browsable : true
-- Create date : 2021-05-19
-- Description : 패킹수량 팝업
-- Modified :
-- ============================================= exec usp_Vvt_SdProd_get'','','2024-11-01','2024-11-20',1,2,3,4
CREATE PROCEDURE [dbo].[usp_Vvt_SdProd_get]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pFromdate datetime = NULL,
	@pTodate datetime = NULL,
	@pMachine int = null,
	@pMachine2 int = null,
	@pMachine3 int = null,
	@pMachine4 int = null
AS
BEGIN
	SET NOCOUNT ON;

		Declare @FromDate               Datetime = convert(datetime, convert(varchar(10),@pFromDate,120)+' 10:00:00' ,120)
			 , @ToDate                   Datetime = convert(datetime, convert(varchar(10),Dateadd(Day,1,@pToDate),120)+' 10:00:00' ,120)
			
		set @pMachine = ISNULL(@pMachine,0);
		set @pMachine2 = ISNULL(@pMachine2,0);
		--set @pMachine3 = ISNULL(@pMachine3,0);
		--set @pMachine4 = ISNULL(@pMachine4,0);

	--if(@pMachine=9 or @pMachine2=9) begin
	--	select  LotNo AS "판정(등급)", col1 as "No.", col2 AS "LC Data", col3 AS "Volt 1", col4 AS "Volt 2", col5 AS "Current", 
	--	col6 AS "Cap.용량", col7 AS "ESR Data", col8, col9, col10, col11,  col35, createdate, createuser, changedate AS DateTimes, changeuser
	--			,  (case  when   (DATEPART(HOUR, isnull(changedate,createdate) )>10)      
	--				then     convert(varchar(10),isnull(changedate,createdate),120)    
	--				else    convert(varchar(10),DATEADD(DAY, -1,  isnull(changedate,createdate)),120)       
	--				end 
	--				)     as Dates
	--	from [dbo].[STB_Vvt_SdProd] with(nolock)
	--	where isnull(changedate,createdate) between @Fromdate and @Todate
	--	and (col35 = 9)
		--union all
		--select  LotNo AS "판정(등급)", col1 as "No.", col2 AS "LC Data", col3 AS "Volt 1", col4 AS "Volt 2", col5 AS "Current", 
		--col6 AS "Cap.용량", col7 AS "ESR Data", col8, col9, col10, col11,  col35, createdate, createuser, changedate AS DateTimes, changeuser
		--		,  (case  when   (DATEPART(HOUR, isnull(changedate,createdate) )>10)      
		--			then     convert(varchar(10),isnull(changedate,createdate),120)    
		--			else    convert(varchar(10),DATEADD(DAY, -1,  isnull(changedate,createdate)),120)       
		--			end 
		--			)     as Dates
		--from [dbo].[STB_Vvt_SdProd_20221230] with(nolock)
		--where isnull(changedate,createdate) between @Fromdate and @Todate
		--and (col35 = 9)		
	--end 
	--else begin
	--	select  LotNo, col1, col2, col3, col4, col5, col6, col7, col8, col9, col10, col11,  col35, createdate, createuser, changedate, changeuser
	--			,  (case  when   (DATEPART(HOUR, isnull(changedate,createdate) )>10)      
	--				then     convert(varchar(10),isnull(changedate,createdate),120)    
	--				else    convert(varchar(10),DATEADD(DAY, -1,  isnull(changedate,createdate)),120)       
	--				end 
	--				)     as inputdate
	--	from [dbo].[STB_Vvt_SdProd] with(nolock)
	--	where isnull(changedate,createdate) between @Fromdate and @Todate
	--	and (col35 = @pMachine or col35 = @pMachine2 /*or col35 = @pMachine3 or col35 = @pMachine4 */)
		--union all
		--select  LotNo, col1, col2, col3, col4, col5, col6, col7, col8, col9, col10, col11,  col35, createdate, createuser, changedate, changeuser
		--		,  (case  when   (DATEPART(HOUR, isnull(changedate,createdate) )>10)      
		--			then     convert(varchar(10),isnull(changedate,createdate),120)    
		--			else    convert(varchar(10),DATEADD(DAY, -1,  isnull(changedate,createdate)),120)       
		--			end 
		--			)     as inputdate
		--from [dbo].[STB_Vvt_SdProd_20221230] with(nolock)
		--where isnull(changedate,createdate) between @Fromdate and @Todate
		--and (col35 = @pMachine or col35 = @pMachine2 /*or col35 = @pMachine3 or col35 = @pMachine4 */)
	--end

	if(@pMachine=9 or @pMachine2=9) begin
		select  LotNo AS "판정(등급)", col1 as "No.", col2 AS "LC Data", col3 AS "Volt 1", col4 AS "Volt 2", col5 AS "Current", 
		col6 AS "Cap.용량", col7 AS "ESR Data", col8, col9, col10, col11,  col35, createdate, createuser, changedate AS DateTimes, changeuser
				,  (case  when   (DATEPART(HOUR, isnull(changedate,createdate) )>10)      
					then     convert(varchar(10),isnull(changedate,createdate),120)    
					else    convert(varchar(10),DATEADD(DAY, -1,  isnull(changedate,createdate)),120)       
					end 
					)     as Dates
		from [dbo].[STB_Vvt_SdProds] with(nolock)
		where isnull(changedate,createdate) between @Fromdate and @Todate
		--and (col35 = 9)
		order by createuser, id
		END
	else begin
		select  LotNo, col1, col2, col3, col4, col5, col6, col7, col8, col9, col10, col11,  col35, createdate, createuser, changedate, changeuser
				,  (case  when   (DATEPART(HOUR, isnull(changedate,createdate) )>10)      
					then     convert(varchar(10),isnull(changedate,createdate),120)    
					else    convert(varchar(10),DATEADD(DAY, -1,  isnull(changedate,createdate)),120)       
					end 
					)     as inputdate
		from [dbo].[STB_Vvt_SdProds] with(nolock)
		where isnull(changedate,createdate) between @Fromdate and @Todate
		--and (col35 = @pMachine or col35 = @pMachine2 /*or col35 = @pMachine3 or col35 = @pMachine4 */)
		order by createuser, id
	END	
END



