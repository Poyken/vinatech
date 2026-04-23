CREATE proc [dbo].[usp_vn_view_weigh] --EXEC usp_vn_view_weigh '2022-05-20','2022-05-20'
@pFrom DATE,
@pTo DATE
AS
BEGIN

	DECLARE @FromDate   VARCHAR(19) = CONVERT(VARCHAR(10), @pFrom, 120) + ' 10:00:00'                                                            -- SELECT  CONVERT(VARCHAR(10), '2019-09-16', 121) + ' 08:30:00' 
	DECLARE @ToDate      VARCHAR(19) = CONVERT(VARCHAR(10), DATEADD(DAY, 1, CONVERT(smalldatetime, @pTo)), 120) + ' 10:00:00'    

			SELECT
						-- thím chuê  QC yêu cầu đổi thành line 20, audit từ ngày 28 tháng 9 ,2022
					case when we.LINECODE='VVC-21' then 'VVC-20' else we.LINECODE end LINECODE, 
			
					   -- thím chuê QC yêu cầu đổi thành line 20, audit từ ngày 28 tháng 9 ,2022
					case when we.LINECODE='VVC-21' then 'Cell Line # 20' else (case when we.LINENAME is null or we.LINENAME='' then li.LineName else we.LINENAME end) end as LINENAME,
					
					 -- thím chuê QC yêu cầu đổi thành line 20, audit từ ngày 28 tháng 9 ,2022
					case when we.LINECODE='VVC-21' then '1840' else (case when we.MODEL is null or we.MODEL='' then '0825' else we.MODEL end) end as MODEL,		
					WEIGH,
				   CREATEDATE,
					RIGHT(CREATEDATE,8) AS TIMES,
					CASE
						WHEN
								WEIGH >= 12.02 THEN 'OK'
						WHEN
								WEIGH <= 2.40  THEN 'NG'
						WHEN
								WEIGH < -0.004 THEN 'NG'
					ELSE ''

				   END AS OKNG,

				   case  when   (DATEPART(HOUR, CREATEDATE)>10)     or    (DATEPART(HOUR, CREATEDATE)=10 and DATEPART(MINUTE, CREATEDATE)>0)     
					then     convert(varchar(10),CREATEDATE,120)    
					else    convert(varchar(10),DATEADD(DAY, -1,  CREATEDATE),120)       
					end  as CreateDateTime
			FROM
					STB_VN_Weigh we WITH(NOLOCK)
					left outer join STB_LineInfo li with(nolock) on we.LINECODE=li.LineCode
			WHERE
				
					CONVERT(DATE,CREATEDATE) BETWEEN @pFrom AND @pTo

					ORDER BY CREATEDATE DESC
		END
	


--select * from  STB_LineInfo
