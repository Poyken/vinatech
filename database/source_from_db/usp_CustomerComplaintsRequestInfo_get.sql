-- =============================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Create date: 2020-09-28
-- Browsable : true
-- Group : 영업관리
-- Description: 고객불만 처리 요구서를 조회한다.
-- Modified:
-- =============================================

CREATE PROCEDURE usp_CustomerComplaintsRequestInfo_get
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pFromDate DATE,
	@pToDate DATE
AS

BEGIN
	Declare @FromDate DATETIME = CONVERT(CHAR(10), @pFromDate, 121) + ' 00:00:00'
	       ,@ToDate DATETIME = CONVERT(CHAR(10), @pToDate, 121) + ' 23:59:59'

	SELECT CCRI.CustomerComplaintsRequestNo
	      ,CCRI.ReceiptDate
		  ,CCRI.SubmissionDate
          ,CCRI.AgencyCode
		  ,AI.AgencyName
          ,CCRI.CustomerName
          ,CCRI.SalesManagerID
		  ,UI.UserName AS SalesManagerName
          ,CCRI.MaterialCode
		  ,MBI.ModelName AS MaterialName
          ,CCRI.DeliveryDate
          ,CCRI.DeliveryQty
          ,CCRI.ComplaintContent
          ,CCRI.ComplaintImage
          ,CCRI.UseConditionContent
          ,CCRI.MassSampleClassCode
		  ,BC.Description AS MassSampleClassName
          ,CCRI.LotNo
          ,CCRI.MarkingLetter
          ,CCRI.ApplicationName
          ,CCRI.InputQty
          ,CCRI.DefectQty
          ,CCRI.IsCustomerComplaintsReport
          ,CCRI.ProcessingRequestDate
          ,CCRI.CustomerRequestContent
          ,CCRI.CustomerRequestImage
          ,CCRI.SalesRequestContent
          ,CCRI.SalesRequestImage
          ,CCRI.CreateDateTime
          ,CCRI.CreateUserID
          ,CCRI.ChangeDateTime
          ,CCRI.ChangeUserID
      FROM STB_CustomerComplaintsRequestInfo CCRI
	  LEFT OUTER JOIN STB_AgencyInfo AI
	    ON AI.AgencyCode = CCRI.AgencyCode
	  LEFT OUTER JOIN SmartFramework.dbo.STB_UserInfo UI
	    ON UI.UserID = CCRI.SalesManagerID
	  LEFT OUTER JOIN STB_ModelBasicInfo MBI
	    ON MBI.ModelCode = CCRI.MaterialCode
	  LEFT OUTER JOIN SmartFramework.dbo.STB_BaseCode BC
	    ON BC.ItemCode = CCRI.MassSampleClassCode
	   AND BC.CodeGroup = 'MassSampleClassCode'
	 WHERE CCRI.CreateDateTime BETWEEN @FromDate AND @ToDate


END