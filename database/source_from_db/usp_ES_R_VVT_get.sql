
/* exec usp_LotTrackingInfo_VVT2_get '','','VVT','2020-05-01','2020-06-05','','','',''    */

CREATE  PROCEDURE [dbo].[usp_ES_R_VVT_get]
						@pProcessUserID VARCHAR(20),
						@pProcessLanguage VARCHAR(20),
						@pCompanyCode VARCHAR(20) = NULL,  
						@pFromDate DATETIME = NULL,
						@pToDate DATETIME = NULL,	
						@pLineCode VARCHAR(20) = NULL,	
						@pMaterialCode VARCHAR(30) = NULL
AS
	--DECLARE @FromDate DATETIME = @pFromDate
	--DECLARE @ToDate DATETIME = @pToDate
	DECLARE @CompanyCode      VARCHAR(20) = CASE WHEN ISNULL(@pCompanyCode,'') = '' THEN '*' ELSE @pCompanyCode END
	DECLARE @FromDate   VARCHAR(19) = CONVERT(VARCHAR(10), @pFromDate, 120) + ' 08:30:00'                                                            -- SELECT  CONVERT(VARCHAR(10), '2019-09-16', 121) + ' 08:30:00' 
	DECLARE @ToDate      VARCHAR(19) = CONVERT(VARCHAR(10), DATEADD(DAY, 1, CONVERT(smalldatetime, @pToDate)), 120) + ' 08:30:00'         -- 다음날 SELECT CONVERT(VARCHAR(10), DATEADD(DAY, 1, CONVERT(smalldatetime, '2019-09-17 00:01:09')), 121) + ' 08:30:00'    		
	DECLARE	@LineCode      VARCHAR(20) = CASE WHEN ISNULL(@pLineCode, '') = ''     THEN '%' ELSE @pLineCode     END	
	DECLARE	@MaterialCode VARCHAR(30) = CASE WHEN ISNULL(@pMaterialCode, '') = '' THEN '*' ELSE @pMaterialCode END

BEGIN
	

SELECT top (1000000)

       machinecode      
	  , Case When inspectvalue <  1 THEN inspectvalue * 1000 ELSE inspectvalue END AS inspectvalue
      ,[inspectvalue1]
      ,[inspectvalue2]
      ,[inspectime]
	  --, Convert(datetime, left(inspectime,20), 121)+2/24   as inspectime
, case when [ip]='192.168.0.11' then '1'	   when [ip]='192.168.0.12' then '2'	   when [ip]='192.168.0.13' then '3'
	   when [ip]='192.168.0.14' then '4'	   when [ip]='192.168.0.15' then '5'	   when [ip]='192.168.0.16' then '6'
	   when [ip]='192.168.0.17' then '7'	   when [ip]='192.168.0.18' then '8'	   when [ip]='192.168.0.19' then '9'
	   else line_num end as line_num    
, case when [ip]='192.168.0.11' then 'VVC-01'	   when [ip]='192.168.0.12' then 'VVC-02'	   when [ip]='192.168.0.13' then 'VVC-03'
	   when [ip]='192.168.0.14' then 'VVC-04'	   when [ip]='192.168.0.15' then 'VVC-05'	   when [ip]='192.168.0.16' then 'VVC-06'
	   when [ip]='192.168.0.17' then 'VVC-07'	   when [ip]='192.168.0.18' then 'VVC-08'	   when [ip]='192.168.0.19' then 'VVC-09'
	   else linecode end as linecode    
, case when [ip]='192.168.0.11' then 'ECVT30-220'	   when [ip]='192.168.0.12' then 'ECVT30-220'	   when [ip]='192.168.0.13' then 'ECVT27-343'
	   when [ip]='192.168.0.14' then 'ECVT30-276'	   when [ip]='192.168.0.15' then 'ECVT30-276'	   when [ip]='192.168.0.16' then 'ECVT30-234'
	   when [ip]='192.168.0.17' then 'ECVT30-220'	   when [ip]='192.168.0.18' then 'ECVT30-234'	   when [ip]='192.168.0.19' then 'ECVT30-276'
	   else materialcode end as materialcode 

  FROM [SmartFactoryV2].[dbo].[STB_E_SR_VVT]
  where linecode like @LineCode and inspectime >= @FromDate and inspectime <= @ToDate
  order by id desc

END
