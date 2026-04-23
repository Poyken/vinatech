
CREATE PROCEDURE [dbo].[usp_VVT_Check_production_get]
	@pProcessUserID      VARCHAR(20),
	@pProcessLanguage  VARCHAR(20),	
	@pToMonth            Datetime = null,
	@pStage   VARCHAR(10)
AS

BEGIN
	SET NOCOUNT ON;

	if (@pToMonth is null ) 
	   begin
	     return
	   end

    DECLARE @ProcessUserID      VARCHAR(20) = @pProcessUserID
	DECLARE @ProcessLanguage  VARCHAR(20) = @pProcessLanguage 
	DECLARE @ToMonth             VARCHAR(19) =   CONVERT(varchar(10),CONVERT(datetime, /*convert (varchar(10),*/ @pToMonth/*,105)*/),120)  +' 08:30:00'             --REPLACE(SUBSTRING(CONVERT(VARCHAR(10), @pToMonth, 121), 1, 10), '-', '')                    -- 금일 6자리           SELECT  REPLACE(SUBSTRING(CONVERT(VARCHAR(12), '2019-12-27 08:30:00', 121), 1, 10), '-', '')     --> '20191228'
	DECLARE @ToMonthNextDay      VARCHAR(19) =   CONVERT(varchar(10),CONVERT(datetime, /*convert (varchar(10),*/ @pToMonth/*,105)*/)+1,120)+' 08:30:00'
	DECLARE @Stage               VARCHAR(4) =   case when (@pStage='' or @pStage='%') then '%' else 	upper(@pStage) end
				
	--select  CONVERT(varchar,CONVERT(datetime, /*convert (varchar(10),*/'2020-02-24'/*,105)*/+ ' 08:30:00'),120) 
	--select @Stage as barcode ,GETDATE() as CreateDateTime,@ToMonthNextDay as InputLineCode,'X'  as Winding,'X'   as Curling,'X'   as Sleeve,    'X'   as Visual, 'X'   as Packing
	--	return


/*
  ;with data as
  (
  SELECT 
	   barcode, 
	   InputLineCode,
	   ss.CreateDateTime,
	   case when RouteCode='V-22' then 1 else 0 end as V22,
	   --case when RouteCode='V-23' then 1 else 0 end as V23,
	   case when RouteCode='V-24' then  1  else  0  end as V24,
	   case when RouteCode='V-25' then  1  else  0  end as V25,
	   case when RouteCode='V-27' then  1  else 0  end as V27,
	   case when RouteCode='V-28' then  1  else  0  end as V28
  FROM STB_SetInfo SS left outer join STB_ProdRouteHist SP on SS.ControlNo = SP.ControlNo 
  WHERE 1=1
  --and InputLineCode like 'VV%'
  --and SS.ControlNo = SP.ControlNo 
  and ss.CreateDateTime >= @ToMonth and ss.CreateDateTime < @ToMonthNextDay
  --and SS.Barcode = 'VVKK113R010612'
  )
  select barcode, 
	   InputLineCode,
	   CreateDateTime,
	   case when sum(V22)=1 then 'O' else 'X' end as Winding,/*  sum(V23) as V23,*/   
	   case when sum(V24)=1 then 'O' else 'X' end  as Curling,  
	    case when sum(V25)=1 then 'O' else 'X' end  as Sleeve,   
		case when sum(V27)=1 then 'O' else 'X' end  as Visual, 
		 case when sum(V28)=1 then 'O' else 'X' end  as Packing
	   from data	  
   where barcode like 'VV%'
   group by Barcode, InputLineCode,CreateDateTime
   order by CreateDateTime,InputLineCode,Barcode
   */

		
  ;with data as 
  ( 
  SELECT 
	   barcode, 
	   InputLineCode, 
	   case when @Stage='%' then ss.CreateDateTime else sp.ProdDateTime end as CreateDateTime, 
	   case when RouteCode='V-22' then 1 else 0 end as V22, 
	   --case when RouteCode='V-23' then 1 else 0 end as V23, 
	   case when RouteCode='V-24' then  1  else  0  end as V24, 
	   case when RouteCode='V-25' then  1  else  0  end as V25, 
	   case when RouteCode='V-27' then  1  else 0  end as V27, 
	   case when RouteCode='V-28' then  1  else  0  end as V28 
  FROM STB_SetInfo SS left outer join STB_ProdRouteHist SP on SS.ControlNo = SP.ControlNo 
  WHERE 1=1 
  and (RouteCode like @Stage or RouteCode is null) 
  ) 
  select barcode,  
	   InputLineCode, 
	   CreateDateTime,	   
	   case when sum(V22)=1 then 'O' else 'X' end as Winding, /*  sum(V23) as V23,*/   
	   case when sum(V24)=1 then 'O' else 'X' end  as Curling,  
	    case when sum(V25)=1 then 'O' else 'X' end  as Sleeve,   
		case when sum(V27)=1 then 'O' else 'X' end  as Visual, 
		 case when sum(V28)=1 then 'O' else 'X' end  as Packing 
	   from data	  
   where barcode like 'VV%' 
   and CreateDateTime >=  @ToMonth and CreateDateTime < @ToMonthNextDay 
   group by Barcode, InputLineCode,CreateDateTime 
   order by CreateDateTime,InputLineCode,Barcode 
    
   END 