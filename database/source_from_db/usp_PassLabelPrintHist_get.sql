-- =============================================
-- Author : Jackaroe(yjyu@vina.co.kr)
-- Group : 품질관리
-- Browsable : true
-- Create date : 2020-02-06
-- Description : 합격라벨출력(임시)
-- Modified :
-- =============================================
CREATE PROCEDURE [dbo].[usp_PassLabelPrintHist_get]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pFromDate DATE,
	@pToDate DATE
AS
BEGIN
	Declare @FromDate DATE = @pFromDate
	       ,@ToDate DATE = @pToDate

	SELECT PLPH.PassLabelPrintNo
		  ,PLPH.MaterialCode
		  ,MM.MaterialName
		  ,PLPH.Barcode
		  ,PLPH.TestDate
		  ,PLPH.ManDate
		  ,DATEADD(day, -1, DATEADD(month, ISNULL(MM.MMExtInt01, 1), PLPH.ManDate)) AS PackDate
		  ,PLPH.TestUserID
		  ,UI.UserName AS TestUser
		  ,PLPH.StockQty
		  ,PLPH.MaterialUnit
		  ,PLPH.CreateDateTime
		  ,PLPH.CreateUserID
		  ,PLPH.ChangeDateTime
		  ,PLPH.ChangeUserID
		  ,'Report' AS CommandType
		  ,0 AS LabelQty
	  FROM STB_PassLabelPrintHist PLPH
	  LEFT OUTER JOIN STB_MaterialMaster MM
	    ON PLPH.MaterialCode = MM.MaterialCode
	  LEFT OUTER JOIN SmartFramework.dbo.STB_UserInfo UI
	    ON PLPH.TestUserID = UI.UserID
	 WHERE PLPH.TestDate BETWEEN @FromDate AND @ToDate
END