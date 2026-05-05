-- Procedure: usp_AllUserInfo_Popup
-- =============================================
-- Author: Jeon Gyeong Ho(khjun@awoo.co.kr)
-- Create date: 2018-08-17
-- Browsable : true
-- Group : 팝업
-- Description:	팝업 작업자코드
-- Modified: 생산 작업자를 가져옵니다  > EA 요청/처리내역 요청자사번
-- Exec usp_AllUserInfo_Popup
-- =============================================
CREATE PROCEDURE [dbo].[usp_AllUserInfo_Popup]
				@pProcessUserID VARCHAR(20),
				@pProcessLanguage VARCHAR(20)
AS
BEGIN

	SELECT EmployeeNo, EmployeeName
	  FROM SmartFactoryIncubator.dbo.VW_EmployeeInfo
	 ORDER BY EmployeeName

END



GO

