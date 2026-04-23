-- ==================================================================
-- Author      : kilee
-- Create date : 2020-03-10
-- Browsable   : True
-- Group       : 대시보드 > 베트남 Power-BI
-- Description : DB명 : [SmartFactoryV2]
-- Modified    :   

-- [프로시저 실행문]   usp_PowerBIDefectPrice_get 'kilee','Korean','2020-06-01 00:00:00', '', 'VVT', 'Manual Line #2', '포장'
-- ==================================================================

CREATE PROC [dbo].[usp_PowerBIDefectPrice_get]
				@pProcessUserID		VARCHAR(20),
				@pProcessLanguage   VARCHAR(20),
				@pMonth				DateTime,
				@pSizeCode				VARCHAR(20) = NULL,
				@pCompanyCode      VARCHAR(20) = NULL,
				@pLineName             VARCHAR(20) = NULL ,
				@pRouteName          VARCHAR(20) = NULL                                         
AS

BEGIN
	SET NOCOUNT ON;

	DECLARE @CompanyCode      VARCHAR(20) = CASE WHEN ISNULL(@pCompanyCode,'') = '' THEN '*' ELSE @pCompanyCode END
    DECLARE @ProcessUserID       VARCHAR(20) = @pProcessUserID
	DECLARE @ProcessLanguage   VARCHAR(20) = @pProcessLanguage   
    DECLARE @Month				  VARCHAR(6)  = CONVERT(VARCHAR(7), @pMonth, 112)                                                                                     -- SELECT CONVERT(VARCHAR(7), '2020-02-01 00:00:00', 112)  
	DECLARE @SizeCode             VARCHAR(20) = CASE WHEN ISNULL(@pSizeCode, '') = '' THEN '%' ELSE @pSizeCode END    
	DECLARE @ToDay				  VARCHAR(02) = SUBSTRING(CONVERT(VARCHAR(10), GetDate()-1, 121), 9, 2)                                                            -- 전일자 두자리                SELECT  SUBSTRING(CONVERT(VARCHAR(10), GetDate()-1, 121), 9, 2) 		
	DECLARE @OneDay				  VARCHAR(11) = SUBSTRING(CONVERT(VARCHAR(10), @pMonth, 121), 0, 11)                                                             
	DECLARE @YesterDay			  VARCHAR(11) = REPLACE(SUBSTRING(CONVERT(VARCHAR(10), GetDate()-1, 121), 0, 11), '-', '')                                        -- 어제날짜   ex) 20200111    SELECT REPLACE(SUBSTRING(CONVERT(VARCHAR(10), GetDate()-1, 121), 0, 11), '-', '')     	 	
	DECLARE @LineName			  VARCHAR(30) = CASE WHEN ISNULL(@pLineName, '') = '' THEN '%' ELSE @pLineName END     
	DECLARE @RouteName		  VARCHAR(20) = CASE WHEN ISNULL(@pRouteName, '') = '' THEN '%' ELSE @pRouteName END

	SELECT  MP.LineCode                                                                                 AS LineCode 
	        --, (Select LineName From STB_LineInfo SL WHERE SL.LineCode = MP.LineCode)     AS LineName

			, SL.LineName                               AS LineName
			, LEFT(SR.RouteName, 2)                             AS RouteName
	        , IsNull(SUM(MP.Target_Defect_Price), 0)													   AS Target_Defect_Price
			, IsNull(SUM(MP.월간계획), 0)					             								   AS Target_Qty
			, Max(사이즈)                                                                                   AS Size                           --- 한 라인에 사이즈가 2개 이상이 있어서 Max사용
			, MP.CompanyCode AS CompanyCode
			, MP.공정코드 AS RouteCode
	 FROM MEDIUM_PLAN MP
	         LEFT OUTER JOIN STB_LineInfo SL   ON SL.LineCode = MP.LineCode
			 LEFT OUTER JOIN STB_RouteInfo SR ON SR.RouteCode = MP.공정코드
	 WHERE  1 = 1 
	    AND 기준년월 =  (                                                                                                  
									SELECT  Replace(BaseMonth, '-', '')		
									FROM STB_AggregationPeriod
								   WHERE 1=1									
									 AND  FromDate  <= @OneDay
									 AND  ToDate     >= @OneDay
								)      
		AND MP.공정코드 IN ('V-28', 'E-28')
		AND SR.RouteName LIKE '%'+@RouteName+'%'                                                -- test용
	    AND ((@CompanyCode = '*') OR (MP.CompanyCode = @CompanyCode))    
		AND SL.LineName LIKE @LineName

    Group By MP.LineCode, 공정코드, SL.LineName , MP.CompanyCode, MP.공정코드, SR.RouteName    
    Order By MP.LineCode


				 
 END