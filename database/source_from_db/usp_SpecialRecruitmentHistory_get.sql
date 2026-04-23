-- =============================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Create date: 2023-06-21
-- Browsable : true
-- Group : 생산관리
-- Description: 특채 확정 및 내역을 조회한다.
-- =============================================
CREATE PROC [dbo].[usp_SpecialRecruitmentHistory_get]
	@pProcessLanguage VARCHAR(20)
   ,@pProcessUserID VARCHAR(20)
   ,@pFromDate DATE
   ,@pToDate DATE
   ,@pCompanyCode VARCHAR(20) = NULL
   ,@pWorkCenterCode VARCHAR(20) = NULL
   ,@pLotNo VARCHAR(20) = NULL
AS
BEGIN
	Declare @FromDate DateTime = CONVERT(CHAR(10), @pFromDate, 121) + ' 08:30:00'
	       ,@ToDate DateTime = CONVERT(CHAR(10), DATEADD(day, 1, @pToDate), 121) + ' 08:29:59'
		   ,@CompanyCode VARCHAR(20) = CASE WHEN ISNULL(@pCompanyCode, '') = '' THEN '*' ELSE @pCompanyCode END
		   ,@WorkCenterCode VARCHAR(20) = CASE WHEN ISNULL(@pWorkCenterCode, '') = '' THEN '*' ELSE @pWorkCenterCode END
		   ,@LotNo VARCHAR(20) = CASE WHEN ISNULL(@pLotNo, '') = '' THEN '*' ELSE @pLotNo END

	SELECT SI.MaterialCode
	      ,MM.MaterialName
		  ,SI.Barcode
		  ,CASE WHEN SRH.Barcode IS NULL THEN CONVERT(BIT, 0) ELSE CONVERT(BIT, 1) END AS IsSpecialRecruitment
		  ,SRH.SpecialRecruitmentRemark
		  ,SRH.CreateDateTime
		  ,SRH.CreateUserID
		  ,SRH.ChangeDateTime
		  ,SRH.ChangeUserID
	  FROM STB_SetInfo SI
	  LEFT OUTER JOIN STB_SpecialRecruitmentHistory SRH
	    ON SI.Barcode = SRH.Barcode
	   AND ISNULL(SRH.IsDelete, CONVERT(BIT, 0)) = CONVERT(BIT, 0)
	  LEFT OUTER JOIN STB_DayProdPlan DPP 
	    ON SI.DayPlanNo = DPP.DayPlanNo
	  LEFT OUTER JOIN STB_MaterialMaster MM
	    ON MM.MaterialCode = SI.MaterialCode
	 WHERE SI.InputJobDate BETWEEN @FromDate AND @ToDate
	   AND (@CompanyCode = '*' OR DPP.CompanyCode = @CompanyCode)
	   AND (@WorkCenterCode = '*' OR DPP.WorkCenterCode = @WorkCenterCode)
	   AND (@LotNo = '*' OR SI.Barcode = @LotNo)
	   --AND SI.IsProdFinish <> CONVERT(BIT, 1) 생산 완료된 Lot번호도 조회되도록 조건 삭제 2023.07.03 이수형 매니저님 요청 By Jackaroe
END