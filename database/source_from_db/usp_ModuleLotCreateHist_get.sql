-- =============================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Create date: 2020-07-17
-- Browsable : true
-- Group : 생산관리
-- Description: 모듈Lot생성이력
-- Modified:
-- =============================================
CREATE PROCEDURE usp_ModuleLotCreateHist_get
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pCompanyCode VARCHAR(20) = NULL,
	@pWorkCenterCode VARCHAR(20) = NULL,
	@pFromDate DATE,
	@pToDate DATE
AS
BEGIN
	Declare @CompanyCode VARCHAR(20) = @pCompanyCode
	       ,@WorkCenterCode VARCHAR(20) = @pWorkCenterCode
	       ,@FromDate DATETIME = CONVERT(CHAR(10), @pFromDate, 121) + ' 08:30:00'
	       ,@ToDate DATETIME = CONVERT(CHAR(10), DATEADD(day, 1, @pToDate), 121) + ' 08:30:00'

	SELECT MQI.CompanyCode
	      ,CI.CompanyName
		  ,MQI.WorkCenterCode
		  ,WCI.WorkCenterName
		  ,MQI.MaterialCode
		  ,MM.MaterialName
		  ,SI.ModuleLotNumber
		  ,SI.Barcode
		  ,MQI.QcQty 
		  ,MQI.InspectionType
		  ,MQI.CreateDateTime
		  ,MQI.CreateUserID
		  ,MQI.ChangeDateTime
		  ,MQI.ChangeUserID
	  FROM STB_SetInfo SI
	  LEFT OUTER JOIN STB_MaterialQcInfo MQI
	    ON SI.ModuleLotNumber = MQI.MaterialQcNo
	  LEFT OUTER JOIN STB_CompanyInfo CI
	    ON CI.CompanyCode = MQI.CompanyCode
	  LEFT OUTER JOIN STB_WorkCenterInfo WCI
	    ON WCI.WorkCenterCode = MQI.WorkCenterCode
	  LEFT OUTER JOIN STB_MaterialMaster MM
	    ON MM.MaterialCode = MQI.MaterialCode
	 WHERE SI.ModuleLotNumber IS NOT NULL
	   AND MQI.CompanyCode = @CompanyCode
	   AND MQI.WorkCenterCode = @WorkCenterCode
	   AND MQI.CreateDateTime BETWEEN @FromDate AND @ToDate
	 ORDER BY SI.ModuleLotNumber, SI.Barcode
END