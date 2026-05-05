-- Procedure: usp_DoRfcLogin






-- =============================================
-- Author:		Kim Han Young
-- Create date: 2016-10-21
-- Browsable : false
-- Description:	Login as RfcUser
-- =============================================
CREATE PROCEDURE [dbo].[usp_DoRfcLogin]
	@pUserID VARCHAR(20),
	@pPassword VARCHAR(20),
	@pIPAddress VARCHAR(20) = NULL
AS
BEGIN
	SET NOCOUNT ON;

    DECLARE @UserID VARCHAR(20) = @pUserID,
			@Password VARCHAR(20) = @pPassword,
			@AllowFlag VARCHAR(20),
			@CurrPassword VARBINARY(256)
			
	-- 집계기준일자 관련 추가 2019.09.25 By Jackaroe
	Declare @FromDate VARCHAR(10)
	       ,@ToDate VARCHAR(10)

	SELECT @FromDate = FromDate
	      ,@ToDate = ToDate
	  FROM SmartFactoryV2.dbo.STB_AggregationPeriod
	 WHERE BaseMonth = CASE WHEN CONVERT(INT, RIGHT(CONVERT(CHAR(8), GETDATE(), 112), 2)) >= 26 
	                        THEN CONVERT(CHAR(7), DATEADD(month, 1, GETDATE()), 121) 
							ELSE CONVERT(CHAR(7), GETDATE(), 121) END

	SELECT
			@AllowFlag = UI.AllowFlag,
			@CurrPassword = UI.Password
	FROM
			STB_UserInfo UI WITH(NOLOCK)
	WHERE
			UI.UserID = @pUserID
			
	IF @CurrPassword IS NULL BEGIN
		RAISERROR('Not found user',16,1)
		RETURN
	END
	IF @AllowFlag <> 'Allow' BEGIN
		RAISERROR('You are not allowed',16,1)
		RETURN
	END
	IF PWDCOMPARE(@Password,@CurrPassword) <> 1 BEGIN
		RAISERROR('Invalid Password',16,1)
		RETURN
	END

	SELECT
			UI.UserID,
			UI.UserName,
			UI.Phone,
			UI.Mobile,
			UI.Email,			
			'Korean' AS Language,
			UI.Appendix1,
			UI.Appendix2,
			UI.Appendix3,
			UI.Appendix4,
			UI.Appendix5,
			UI.Appendix6,
			UI.Appendix7,
			UI.Appendix8,
			UI.Appendix9,
			UI.Appendix10,
			UI.IsLogin,
			UI.IPAddress,
			UI.SystemCode,
			@FromDate AS FromDate,
			@ToDate AS ToDate,
			CASE WHEN SUI.CompanyCode = 'VNT' THEN 'ROH_WH' 
			     WHEN SUI.CompanyCode = 'VVT' THEN 'ROH_VN_WH'
				 ELSE NULL END AS MaterialWarehouseCode,
			CASE WHEN SUI.CompanyCode = 'VNT' THEN N'원자재창고' 
			     WHEN SUI.CompanyCode = 'VVT' THEN N'Kho nguyên liệu'
				 ELSE NULL END AS MaterialWarehouseName,
			CASE WHEN SUI.CompanyCode = 'VNT' THEN 'ROUTE_WH' 
			     WHEN SUI.CompanyCode = 'VVT' THEN 'ROUTE_VN_WH'
				 ELSE NULL END AS RouteWarehouseCode,
			CASE WHEN SUI.CompanyCode = 'VNT' THEN N'공정창고' 
			     WHEN SUI.CompanyCode = 'VVT' THEN N'kho định tuyến'
				 ELSE NULL END AS RouteWarehouseName
	FROM
			STB_UserInfo UI
	LEFT OUTER JOIN SmartFactoryV2.dbo.STB_UserInfo SUI WITH(NOLOCK)
				ON	SUI.UserID = UI.UserID
			LEFT OUTER JOIN SmartFactoryV2.dbo.STB_CompanyInfo CI WITH(NOLOCK)
				ON	CI.CompanyCode = SUI.CompanyCode
			LEFT OUTER JOIN SmartFactoryV2.dbo.STB_WorkCenterInfo WCI WITH(NOLOCK)
				ON	WCI.WorkCenterCode = SUI.WorkCenterCode
	WHERE
			UI.UserID = @UserID
END







GO

