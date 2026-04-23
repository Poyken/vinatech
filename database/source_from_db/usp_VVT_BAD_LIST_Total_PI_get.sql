-- ==================================================================
-- Author      : kilee
-- Create date : 2019-12-25
-- Browsable   : true
-- Group       :  Power-BI 모니터링 화면 > 베트남대시보드
-- Description :  DB명 : [SmartFactoryV2]
-- Modified    :  Power-PI 베트남대시보드의 월간불량수량 빅5부분 Chart
-- ==================================================================

-- [프로시저 실행문]      usp_VVT_BAD_LIST_Total_PI_get   '','','2020-02-01', '', 'VVT'
--                            usp_VVT_BAD_LIST_Total_PI_get   '','','2020-03-01', '', 'VVT', '2020-03-26', '2020-04-25'

CREATE PROC [dbo].[usp_VVT_BAD_LIST_Total_PI_get]
				@pProcessUserID VARCHAR(20),
				@pProcessLanguage VARCHAR(20),
				@pMonth DateTime,
				@pSizeCode VARCHAR(20) = null,
				@pCompanyCode VARCHAR(20) = NULL,

				@pFromDate DATE = NULL,
				@pToDate DATE = NULL           
AS

BEGIN
	SET NOCOUNT ON;

	DECLARE @CompanyCode      VARCHAR(20) = CASE WHEN ISNULL(@pCompanyCode,'') = '' THEN '*' ELSE @pCompanyCode END
    DECLARE @ProcessUserID      VARCHAR(20) = @pProcessUserID
	DECLARE @ProcessLanguage  VARCHAR(20) = @pProcessLanguage   
	DECLARE @Month               VARCHAR(6) = CONVERT(VARCHAR(6), @pMonth, 112)	
	DECLARE @SizeCode            VARCHAR(20) = CASE WHEN ISNULL(@pSizeCode, '') = '' THEN '%' ELSE @pSizeCode END    
	DECLARE @ToDay               VARCHAR(08) = REPLACE(SUBSTRING(CONVERT(VARCHAR(10), GetDate()-1, 121), 0, 11), '-', '')                                                        -- 전일자 두자리           SELECT  REPLACE(SUBSTRING(CONVERT(VARCHAR(10), GetDate()-1, 121), 0, 11), '-', '')   	
	
	DECLARE @FromDate DATE = @pFromDate
	DECLARE @ToDate    DATE = @pToDate

		
	--add by Mr.Tung on 12-May-2021 as Vietnam Production Realtime requests
	if(@CompanyCode='VVT')
	begin
				DECLARE @currentdate datetime = DATEADD(DAY,0,getdate()	)
				DECLARE @fullToday     varchar(10) = convert( varchar(10),DATEADD(DAY,1,@currentdate),120)			
					if(DAY(@currentdate)>25) 
						begin 
							select @currentdate = convert( varchar(10),DATEADD(MONTH,1, @currentdate),120) 
						end 

				--	select @ToDay = DAY (@currentdate)
				select @Month = replace(convert( varchar(7),DATEADD(MONTH,0, @currentdate),120),'-','')
					DECLARE @tmpdate    varchar(10) = convert(varchar(10),@currentdate,120)	
					DECLARE @jodatefrom varchar(10)= convert( varchar(7),DATEADD(MONTH,-1, @tmpdate),120) + '-26'
					DECLARE @jodateto   varchar(10)= convert( varchar(7),DATEADD(MONTH, 0, @tmpdate),120) + '-26'
	
			select	 @FromDate  = @jodatefrom + ' 10:30:00'   
			select	 @ToDate     = @jodateto +' 10:30:00'					
	end


	

	 SELECT TOP(5) AA.DefectDesc AS 불량종류
		            ,  AA.DefectQty      AS 불량수량
					, AA.DefectCode
			FROM (
						SELECT						
								ROW_NUMBER() OVER( ORDER BY SUM(DRI.DefectQty - DRI.RepairQty) DESC) 순위										
							  --, DRI.DefectCode
							  --, DI.BasicDefectName                    AS DefectName
							  , DG.BasicDefectGroupName              AS DefectDesc    -- 어쩔수없이 이걸로  

							  --, DI.DefectDesc                            AS DefectDesc
							  , SUM(DRI.DefectQty - DRI.RepairQty) AS DefectQty
							  , MAX(DRI.DefectCode)                     AS DefectCode
						FROM
													  STB_DefectRepairInfo DRI WITH(NOLOCK)                                                                                             
								LEFT OUTER JOIN STB_MaterialMaster  MM WITH(NOLOCK)						ON MM.MaterialCode = DRI.MaterialCode
								LEFT OUTER JOIN STB_SetInfo SI WITH(NOLOCK)									ON SI.ControlNo = DRI.ControlNo
								LEFT OUTER JOIN STB_LineInfo FLI WITH(NOLOCK)								ON FLI.LineCode = DRI.FindLineCode
								LEFT OUTER JOIN STB_RouteInfo RI WITH(NOLOCK)								ON RI.RouteCode = DRI.FindRouteCode			
								LEFT OUTER JOIN STB_DefectInfo DI WITH(NOLOCK)								ON DI.DefectCode = DRI.DefectCode			
								LEFT OUTER JOIN STB_DefectCauseInfo DCI WITH(NOLOCK)						ON DCI.DefectCauseCode = DRI.DefectCauseCode			
								LEFT OUTER JOIN STB_CustomerInfo CUI WITH(NOLOCK)						ON CUI.CustomerCode = DRI.DutyVendorCode
								LEFT OUTER JOIN VW_RepairType RT												ON RT.RepairType = DRI.RepairType
								LEFT OUTER JOIN VW_DefectCauseType DCT										ON DCT.DefectCauseType = DRI.DefectCauseType
								LEFT OUTER JOIN SmartFramework.dbo.STB_UserInfo UI WITH(NOLOCK)		ON UI.UserID = DRI.RepairUserID
								LEFT OUTER JOIN VW_ShiftCode VFSC WITH(NOLOCK)							ON VFSC.ShiftCode = DRI.FindShiftCode
								LEFT OUTER JOIN VW_ShiftCode VCSC WITH(NOLOCK)							ON VCSC.ShiftCode = DRI.CauseShiftCode			
								LEFT OUTER JOIN STB_ProdRouteHist PRH  WITH(NOLOCK)                     ON PRH.ControlNo = DRI.ControlNo                AND PRH.RouteCode = DRI.FindRouteCode    -- 2019.09.17 추가 조인
								LEFT OUTER JOIN STB_ProdWorkerInfo PWI                                       ON PRH.WorkerCode = PWI.WorkerCode
								LEFT OUTER JOIN STB_MaterialQcInfo MQI                                        ON MQI.MaterialQcNo = SI.LotNumber

								LEFT OUTER JOIN STB_DefectGroup DG WITH(NOLOCK)				            ON DI.DefectGroupCode = DG.DefectGroupCode
						WHERE 1=1
								AND (DRI.CompanyCode LIKE @CompanyCode) 
								--AND	(DRI.WorkCenterCode LIKE @WorkCenterCode) 			
								--AND	(@MaterialCode = '*' OR DRI.MaterialCode = @MaterialCode)
								--AND	(@LineCode = '*' OR DRI.FindLineCode IN (SELECT Item FROM dbo.fnSplitToTable(',',@LineCode))) 
								AND	DRI.FindJobdate BETWEEN @FromDate AND @ToDate
								--AND	DRI.RepairType NOT IN ('MISSING')
								--AND (@FindRouteCode = '*' OR DRI.FindRouteCode = @FindRouteCode)                                      
								--AND (@DefectCode = '*' OR DRI.DefectCode = @DefectCode)                                                    
						GROUP BY
								--DRI.DefectCode
							  --, DI.BasicDefectName         
							   DG.BasicDefectGroupName
							--  , DI.DefectDesc                
						  --ORDER BY 순위
						  	)  AA						
			ORDER BY  AA.순위





	-- 원본백업 (2020-03-31)

	 --SELECT TOP(5) BB.Kind  AS 불량종류
		--            ,   ISNULL(BB.Qty, 0)   AS 불량수량
	 --FROM (
		--	   SELECT  AA.BAD_Kind                                              AS Kind
		--			   , SUM(ISNULL(AA.Qty, 0))                                                AS Qty  
		--			   , ROW_NUMBER() OVER( ORDER BY SUM(ISNULL(AA.QTY, 0)) DESC) 순위
		--		FROM (
		--					SELECT  *     
		--					FROM STB_BAD_LIST2
		--					WHERE 1=1
		--					  --AND standardDate LIKE '202001%'					
		--					  --AND standardDate LIKE @Month + '%'  OR standardDate IN ('20191226', '20191227','20191228','20191229','20191230','20191231')                 --- 해결해야될 사항
		--					  AND standardDate LIKE '202004' + '%'  OR standardDate IN ('20200326', '20200327','20200328','20200329','20200330','20200331')                 --- 해결해야될 사항
		--				)  AA
		--		WHERE 1=1			
		--		GROUP BY  AA.BAD_Kind
		--		)   BB
		--	ORDER BY  BB.순위
			
			 
 END