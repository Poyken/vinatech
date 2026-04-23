-- =============================================
-- Author:	    Anonymous()
-- Create date: 2021-03-31
-- Browsable : true
-- Group : 품질관리
-- Description:	수입검사그룹을 조회합니다
-- Modified:
-- =============================================
CREATE  PROCEDURE [dbo].[usp_SDParamTest_get]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pUtcOffset INT,
	@pFromDate date = null,
	@pToDate date = null,
	@pResult nvarchar(50)=null,
	@pModelNo nvarchar(50) = null,
	@pLotNo nvarchar(50) = null,
	@pEmployee nvarchar(50) = null,
	@pLine nvarchar(20)=null

AS
BEGIN
	SET NOCOUNT ON;
     
	 select * from 
	    
	(SELECT
	        SDT.CodeParam,
			SDT.ModelNo,
			SDT.LotNo,
			dbo.fnGetLocalTime(SDT.Date, @pUtcOffset) AS Date, -- The varchar type is not controlled by the screen. It must be delivered in date format.
	        SDT.Employee,
	        SDT.ChargingVoltage,
			SDT.ChargingCurrent,
			SDT.ChargingTime,
			SDT.LeavingTime,
			SDT.V1Time,
			SDT.V2Time,
			SDT.V1LMT,
			SDT.DV_DT,
			SDT.Attribute1 as LineName,
			case when DT.TP = DT.total then 'PASS'
				 WHEN DT.TF > 0 THEN 'FAIL'
				 else NULL end as Result
			
	FROM
	         stb_SDParam SDT 
			left join (	

		    select IDParam, sum(total) as total,sum(TF) as TF,sum(TP) as TP from 
			(select IDParam,count(*) as total, 
			case when result= 'Fail' then count(*) else NULL end as TF,
			case when result= 'Pass' then count(*) else NULL end as TP
			 from stb_SDValueTest 
			 group by IDParam,result) a
			 group by IDParam) DT
			ON SDT.CodeParam = DT.IDParam
	WHERE 1=1
			and ((@pFromDate is null and @pToDate is null) or SDT.Date between @pFromDate and @pToDate)
			and (@pModelNo is null or @pModelNo ='' or ModelNo like '%'+@pModelNo+'%')
			and (@pLotNo is null or @pLotNo='' or LotNo like '%'+@pLotNo+'%')
			and (@pEmployee is null or @pEmployee ='' or Employee like '%'+@pLotNo+'%')
			and (@pLine is null or @pLine='' or Attribute1 =@pLine)

		) abc
			where (@pResult is null or @pResult='' or abc.Result = @pResult)
				order by cast (CodeParam as numeric)
END

