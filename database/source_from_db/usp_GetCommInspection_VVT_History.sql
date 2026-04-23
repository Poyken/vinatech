
CREATE PROCEDURE [dbo].[usp_GetCommInspection_VVT_History]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pCompanyCode VARCHAR(20) = NULL,
	@pWorkCenterCode VARCHAR(20) = NULL,
	@pFromDate DATE = NULL,
	@pToDate DATE = NULL,
	@pCommInspTypeCode VARCHAR(50) = NULL,
	@pIsFinished BIT = NULL,
	@pBarcode VARCHAR(20) = NULL
AS


BEGIN
	SET NOCOUNT ON;
	
    DECLARE @CompanyCode VARCHAR(20)    = CASE WHEN ISNULL(@pCompanyCode,'') = '' THEN '*' ELSE @pCompanyCode END
    DECLARE @WorkCenterCode VARCHAR(20) = CASE WHEN ISNULL(@pWorkCenterCode,'') = '' THEN '%' ELSE @pWorkCenterCode END
    DECLARE @FromDate DATEtime = CONVERT(VARCHAR(10), @pFromDate, 120) + ' 10:00:00' 
	DECLARE @ToDate DATEtime = CONVERT(VARCHAR(10), DATEADD(DAY, 1, CONVERT(smalldatetime, @pToDate)), 120) + ' 10:00:00' 
	DECLARE @CommInspTypeCode VARCHAR(50) = CASE WHEN ISNULL(@pCommInspTypeCode,'') = '' THEN '%' ELSE @pCommInspTypeCode END
	DECLARE @IsFinished BIT = @pIsFinished
	DECLARE @Barcode VARCHAR(20) = CASE WHEN ISNULL(@pBarcode, '') = '' THEN '*' ELSE @pBarcode END                                                             -- 추가사항
    
	SELECT
			CASE WHEN CIDH.ComPanyCode = 'VNT' THEN '전주본사'
	        WHEN CIDH.ComPanyCode = 'VVT' THEN '베트남' ELSE '기타' END   AS 사업장,
			CIDH.CommInspDocNo AS OldCommInspDocNo,
			CIDH.CommInspDocNo,
			CIDH.CommInspTypeCode,
			CITI.CommInspTypeName,
			CITI.CommInspTypeDesc,
			CIDH.CompanyCode,
			CIDH.WorkCenterCode,
			CIDH.MaterialCode,
			M.MaterialName,
			M.MaterialTypeCode,
			M.ProductGroupCode,
			CIDH.RefDocNo,
			SI.Barcode,
			SI.PONo,
			CIDH.JobDate,
			CIDH.ShiftCode,
			CIDH.InspTimeCode,
			CIDH.CategoryName,
			CIDH.ProdNo,
			ISNULL(CIDH.IsFinished,0) AS IsFinished,
			ISNULL(SI.IsFinalInspection,0) AS IsFix,
			CIDH.DocDesc,
			CIDH.InspUserID,
			max(cimh.MeasureDateTime) as CreateDateTime,			
			CIDH.CreateUserID,
			CIDH.ChangeDateTime,
			CIDH.ChangeUserID,
			CIDH.CIDHExtText02                            -- 2020.01.17 비고내용 추가사항

			,(case  when   (DATEPART(HOUR, cimh.MeasureDateTime)>=10)   
					then     convert(varchar(10),cimh.MeasureDateTime,120)    
					else    convert(varchar(10),DATEADD(DAY, -1,  cimh.MeasureDateTime),120)       
					end 
			 )   as  MeasureDateTime


			,max(cimh.InspWorkerCode) InspWorkerCode
			,si.InputLineCode
			,(case when sum(case when isnull(cimh.MeasureResult,'OK')='NG' then 1 else 0 end)>0 then 'NG' else 'OK' end) as NG_count
			,sum(case when cimh.MeasureResult='NG' or  cimh.MeasureResult='OK' then 1 else 0 end) as CheckQty
			,CIDH.accontent
	FROM
			STB_CommInspDocHistory                     CIDH WITH(NOLOCK)
			LEFT OUTER JOIN STB_CommInspTypeInfo CITI  WITH(NOLOCK)			ON  CITI.CommInspTypeCode = CIDH.CommInspTypeCode
			LEFT OUTER JOIN STB_MaterialMaster         M  WITH(NOLOCK)			ON  M.MaterialCode = CIDH.MaterialCode
			LEFT OUTER JOIN STB_SetInfo                   SI  WITH(NOLOCK)			ON  SI.ControlNo = CIDH.ProdNo
			
			LEFT OUTER JOIN STB_CommInspDocItem CIDI WITH(NOLOCK)				ON  CIDH.CommInspDocNo = CIDI.CommInspDocNo						
			LEFT OUTER JOIN STB_CommInspMeasureHist cimh with (nolock)  on  cimh.CommInspDocItemNo=cidi.CommInspDocItemNo
			--LEFT OUTER JOIN STB_ProdWorkerInfo pwi with (nolock)        on  pwi.WorkerCode=cimh.InspWorkerCode

	WHERE 1=1
	   AND ((@CompanyCode = '*') OR (CIDH.CompanyCode = @CompanyCode)) -- 추가 용은재 (2020.01.23)
	   AND	(CIDH.WorkCenterCode = @WorkCenterCode) 
	   AND	(CIDH.CommInspTypeCode = @CommInspTypeCode) 
	   AND	(cimh.MeasureDateTime BETWEEN @FromDate AND @ToDate) 
	   AND	(CIDH.IsFinished = @IsFinished) 
	    AND (@Barcode = '*' OR SI.Barcode LIKE @Barcode)
		and cimh.MeasureDateTime is not null
	group by 
			CIDH.CommInspDocNo,
			CIDH.CommInspTypeCode,
			CITI.CommInspTypeName,
			CITI.CommInspTypeDesc,
			CIDH.CompanyCode,
			CIDH.WorkCenterCode,
			CIDH.MaterialCode,
			M.MaterialName,
			M.MaterialTypeCode,
			M.ProductGroupCode,
			CIDH.RefDocNo,
			SI.Barcode,
			SI.PONo,
			CIDH.JobDate,
			CIDH.ShiftCode,
			CIDH.InspTimeCode,
			CIDH.CategoryName,
			CIDH.ProdNo,
			CIDH.IsFinished,
			SI.IsFinalInspection,
			CIDH.DocDesc,
			CIDH.InspUserID,
			CIDH.CreateDateTime,
			CIDH.CreateUserID,
			CIDH.ChangeDateTime,
			CIDH.ChangeUserID,
			CIDH.CIDHExtText02        ,
			(case  when   (DATEPART(HOUR, cimh.MeasureDateTime)>=10)   
					then     convert(varchar(10),cimh.MeasureDateTime,120)    
					else    convert(varchar(10),DATEADD(DAY, -1,  cimh.MeasureDateTime),120)       
					end 
			 ),
			
			si.InputLineCode
			,CIDH.accontent
END


--select  cimh.*
--	FROM
--			STB_CommInspDocHistory                     CIDH WITH(NOLOCK)
--			LEFT OUTER JOIN STB_SetInfo                   SI  WITH(NOLOCK)			ON  SI.ControlNo = CIDH.ProdNo			
--			LEFT OUTER JOIN STB_CommInspDocItem CIDI WITH(NOLOCK)				ON  CIDH.CommInspDocNo = CIDI.CommInspDocNo						
--			LEFT OUTER JOIN STB_CommInspMeasureHist cimh with (nolock)  on  cimh.CommInspDocItemNo=cidi.CommInspDocItemNo
--where si.barcode='VVLJ063R033517'


--select top 1000 * from
--STB_CommInspDocItem
--where CommInspDocNo='20210106000073'