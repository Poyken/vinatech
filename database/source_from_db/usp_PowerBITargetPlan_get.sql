-- ==================================================================
-- Author      : kilee
-- Create date : 2020-03-10
-- Browsable   : True
-- Group       : 대시보드 > 베트남 Power-BI
-- Description : DB명 : [SmartFactoryV2]
-- Modified    :   

-- [프로시저 실행문]      usp_PowerBITargetPlan_get 'kilee','Korean', '', '', '', ''
-- ==================================================================

CREATE PROC [dbo].[usp_PowerBITargetPlan_get]
				@pProcessUserID		VARCHAR(20),
				@pProcessLanguage   VARCHAR(20),
				@pMonth				DateTime,
				@pSizeCode				VARCHAR(20) = NULL,
				@pCompanyCode      VARCHAR(20) = NULL,
                @pLineName             VARCHAR(20) = NULL
AS

BEGIN
	SET NOCOUNT ON;

	DECLARE @CompanyCode      VARCHAR(20) = CASE WHEN ISNULL(@pCompanyCode,'') = '' THEN '*' ELSE @pCompanyCode END
    DECLARE @ProcessUserID       VARCHAR(20) = @pProcessUserID
	DECLARE @ProcessLanguage   VARCHAR(20) = @pProcessLanguage   
    DECLARE @Month				  VARCHAR(6) = CONVERT(VARCHAR(7), @pMonth, 112) -- 7자리로 변환해서 6자리로 받는 이유가??
	DECLARE @SizeCode             VARCHAR(20) = CASE WHEN ISNULL(@pSizeCode, '') = '' THEN '%' ELSE @pSizeCode END    
	DECLARE @ToDay				  VARCHAR(02) = SUBSTRING(CONVERT(VARCHAR(10), GetDate()-1, 121), 9, 2)                                                            -- 전일자 두자리                SELECT  SUBSTRING(CONVERT(VARCHAR(10), GetDate()-1, 121), 9, 2) 		
	DECLARE @OneDay				  VARCHAR(11) = SUBSTRING(CONVERT(VARCHAR(10), @pMonth, 121), 0, 11) -- Month를 변환해 놓고 이걸 쓰... 10자리로 변환해서 11자리로 받..
	DECLARE @YesterDay			  VARCHAR(11) = REPLACE(SUBSTRING(CONVERT(VARCHAR(10), GetDate()-1, 121), 0, 11), '-', '')                                     
	DECLARE @LineName			  VARCHAR(20) = CASE WHEN ISNULL(@pLineName, '') = '' THEN '%' ELSE @pLineName END

	IF @OneDay = '1900-01-01' BEGIN
		SET @OneDay = CONVERT(VARCHAR(10), dbo.fnGetAggregationPeriod(3), 112)
	END


	SELECT MP.CompanyCode AS CompanyCode
	       , SL.LineCode      AS LineCode
	       , SL.LineName       AS LineName
		  -- , SL.LineDesc AS LineName
	       , MAX(MP.사이즈)          AS 사이즈
	        , SUM(ISNULL(MP.PLANQTY,0))     AS 목표수량
	 FROM MEDIUM_PLAN MP
	 LEFT OUTER JOIN STB_LineInfo SL ON SL.LineCode = MP.LineCode
	 WHERE  1 = 1 
	    AND 기준년월 =  (                                                                                                  
									SELECT  Replace(BaseMonth, '-', '')		
									FROM STB_AggregationPeriod
								   WHERE 1=1									
									 AND  FromDate  <= @OneDay
									 AND  ToDate     >= @OneDay
								)      

					--AND 기준년월 =  (                                                                                                  
					--			'202006'
					--			)      
		AND MP.공정코드 IN ('V-28', 'E-28')
	    AND ((@CompanyCode = '*') OR (MP.CompanyCode = @CompanyCode))    
		AND SL.LineName LIKE @LineName
    
    Group By    MP.COMPANYCODE, SL.LineCode , SL.LineName, SL.LineDesc
   ORDER BY 		SL.LineCode 	
				 
 END