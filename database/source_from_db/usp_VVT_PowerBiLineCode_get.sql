-- ==================================================================
-- Author      : kilee
-- Create date : 2020-03-10
-- Browsable   : True
-- Group       : 대시보드 > 베트남 Power-BI
-- Description : DB명 : [SmartFactoryV2]
-- Modified    :   

-- [프로시저 실행문]     usp_VVT_PowerBiLineCode_get 'kilee','Korean','2020-03-01 00:00:00', '', 'VVT'
-- ==================================================================

CREATE PROC [dbo].[usp_VVT_PowerBiLineCode_get]
				@pProcessUserID		VARCHAR(20),
				@pProcessLanguage   VARCHAR(20),
				@pMonth				DateTime,
				@pSizeCode				VARCHAR(20) = NULL,
				@pCompanyCode      VARCHAR(20) = NULL                                           

AS

BEGIN
	SET NOCOUNT ON;

	DECLARE @CompanyCode      VARCHAR(20) = CASE WHEN ISNULL(@pCompanyCode,'') = '' THEN '*' ELSE @pCompanyCode END
    DECLARE @ProcessUserID       VARCHAR(20) = @pProcessUserID
	DECLARE @ProcessLanguage   VARCHAR(20) = @pProcessLanguage   
    DECLARE @Month				  VARCHAR(6) = CONVERT(VARCHAR(7), @pMonth, 112)                                                                                     -- SELECT CONVERT(VARCHAR(7), '2020-02-01 00:00:00', 112)  
	DECLARE @SizeCode             VARCHAR(20) = CASE WHEN ISNULL(@pSizeCode, '') = '' THEN '%' ELSE @pSizeCode END    
	DECLARE @ToDay				  VARCHAR(02) = SUBSTRING(CONVERT(VARCHAR(10), GetDate()-1, 121), 9, 2)                                                            -- 전일자 두자리                SELECT  SUBSTRING(CONVERT(VARCHAR(10), GetDate()-1, 121), 9, 2) 		
	DECLARE @OneDay				  VARCHAR(11) = SUBSTRING(CONVERT(VARCHAR(10), @pMonth, 121), 0, 11)                                                             
	DECLARE @YesterDay			  VARCHAR(11) = REPLACE(SUBSTRING(CONVERT(VARCHAR(10), GetDate()-1, 121), 0, 11), '-', '')                                        -- 어제날짜   ex) 20200111    SELECT REPLACE(SUBSTRING(CONVERT(VARCHAR(10), GetDate()-1, 121), 0, 11), '-', '')     	 	


	Select  -- MP.LineCode
	         (Select SL.LineName From STB_LineInfo SL where SL.LineCode = MP.LineCode ) AS LineName
			, MP.사이즈
			, MP.월간계획
		--	, MP.*
	From Medium_Plan MP
	Where 1=1
	  AND MP.기준년월 =  (                                                                                                  
									SELECT  Replace(BaseMonth, '-', '')		
									FROM STB_AggregationPeriod
								   WHERE 1=1									
									 AND  FromDate  <= @OneDay
									 AND  ToDate     >= @OneDay
								)      

	   And 공정코드  IN ( 'E-28', 'V-28')
	   And  CompanyCode = @CompanyCode
	Order By MP.LineCode

			 
 END

