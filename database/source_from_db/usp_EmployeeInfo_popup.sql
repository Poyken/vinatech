-- ==================================================================
-- Author      : Jackaroe(yjyu@vina.co.kr)
-- Create date : 2021-03-24
-- Browsable   : true
-- Group       : 팝업
-- Description : 
-- Modified    :  
-- ==================================================================

CREATE PROC [dbo].[usp_EmployeeInfo_popup]
AS
BEGIN
	SELECT EmployeeNo, EmployeeName
	  FROM SmartFactoryIncubator.dbo.VW_EmployeeInfo
	 WHERE ISNULL(LeaveDate, '') = '' OR ISNULL(LeaveDate, '') = '0000-00-00'
	 ORDER BY EmployeeNo
END