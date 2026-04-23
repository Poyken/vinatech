
-- =============================================
-- Author:	Kangs (kilee@vina.co.kr)
-- Create date: 2020-09-18
-- Browsable : true
-- Group : 품질관리
-- Description:	[C425] 전극공정검사이력조회
-- Modified:  2019-11-09  바코드 추가
--            2020-09-14 
--            2020-10-06 일괄업로드 데이터의 바코드 표시를 위해 변경 By Jackaroe #201006
--            2021-07-19 Mr.Tung change WHERE condition to  @CommInspTypeCode
--            2021-12-27 점도 추가 이미정 차장 요청 by Jackaroe

-- usp_GetElectrodeCommInspectionHistory   'kilee','','VNT','VNT_F1','2020-09-13 00:00:00','2020-09-17 00:00:00','ROUTE_ELECTRODE_QUALITY','', 'VJKR1212001E05'      -- 한 Lot만 검색시
-- usp_GetElectrodeCommInspectionHistory   'kilee','','VNT','VNT_F1','2020-09-13 00:00:00','2020-09-17 00:00:00','ROUTE_ELECTRODE_QUALITY','', ''                            -- 전체검색시
-- ===================================================================================================================
CREATE PROCEDURE [dbo].[usp_GetElectrodeCommInspectionHistory_AUDIT]
						@pProcessUserID VARCHAR(20),
						@pProcessLanguage VARCHAR(20),
						@pCompanyCode VARCHAR(20) = NULL,
						@pWorkCenterCode VARCHAR(20) = NULL,
						@pFromDate DATE = NULL,
						@pToDate DATE = NULL
						--,
						--@pCommInspTypeCode VARCHAR(50) = NULL,
						--@pIsFinished BIT = NULL,
						--@pBarcode VARCHAR(20) = NULL
AS

BEGIN
	SET NOCOUNT ON;
	
    DECLARE @CompanyCode VARCHAR(20)    = CASE WHEN ISNULL(@pCompanyCode,'') = '' THEN '*' ELSE @pCompanyCode END
    DECLARE @WorkCenterCode VARCHAR(20) = CASE WHEN ISNULL(@pWorkCenterCode,'') = '' THEN '*' ELSE @pWorkCenterCode END
    DECLARE @FromDate DATE = @pFromDate
	DECLARE @ToDate    DATE = @pToDate
	--DECLARE @CommInspTypeCode VARCHAR(50) = CASE WHEN ISNULL(@pCommInspTypeCode,'') = '' THEN '%' ELSE @pCommInspTypeCode END
	--DECLARE @IsFinished BIT = @pIsFinished
	--DECLARE @Barcode   VARCHAR(20) = CASE WHEN ISNULL(@pBarcode, '') = '' THEN '*' ELSE @pBarcode END                                                             -- 추가사항    

   select * from STB_CommInspDocHistoryAudit			
   --select * from STB_CommInspDocHistory 			
END