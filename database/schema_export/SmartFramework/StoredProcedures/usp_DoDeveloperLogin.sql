-- Procedure: usp_DoDeveloperLogin






-- =============================================
-- Author:		Kim Han Young
-- Create date: 2016-01-13
-- Browsable : false
-- Description:	Login as Developer
-- =============================================
CREATE PROCEDURE [dbo].[usp_DoDeveloperLogin]
	@pProcessUserID VARCHAR(20) = NULL,	-- LOB 테스트 이후에 = NULL 삭제할 것
	@pProcessLanguage VARCHAR(20) = NULL,
	@pIPAddress VARCHAR(20) = NULL,
	@pUserID VARCHAR(20),
	@pPassword VARCHAR(20)	
AS
BEGIN
	SET NOCOUNT ON;

    DECLARE @ProcessUserID VARCHAR(20) = @pProcessUserID,
			@ProcessLanguage VARCHAR(20) = @pProcessLanguage,
			@UserID VARCHAR(20) = @pUserID,
			@Password VARCHAR(20) = @pPassword,
			@IPAddress VARCHAR(20) = @pIPAddress,
			@AllowFlag VARCHAR(20),
			@IsDeveloper BIT,
			@CurrPassword VARBINARY(256),
			@OldIPAddress VARCHAR(20),
			@SystemCode VARCHAR(20),
			@ERPUserID VARCHAR(20),
			@ERPPassword VARCHAR(MAX), 
			@ERPLastChnagePasswordDateTime DATETIME,
			@ERPIncomCode VARCHAR(20)

	-- 집계기준일자 관련 추가 2019.09.25 By Jackaroe
	Declare @FromDate VARCHAR(10)
	       ,@ToDate VARCHAR(10)

	-- 사용자의 ERP 소속 구분
	Declare @ERPCdCompany VARCHAR(10)

	SELECT @ERPCdCompany = CASE WHEN CompanyCode = 'VNT' THEN '1000' ELSE '2000' END 
	  FROM SmartFactoryV2.dbo.STB_UserInfo
	 WHERE UserID = @pProcessUserID

	SELECT @FromDate = FromDate
	      ,@ToDate = ToDate
	  FROM SmartFactoryV2.dbo.STB_AggregationPeriod
	 WHERE BaseMonth = CASE WHEN CONVERT(INT, RIGHT(CONVERT(CHAR(8), GETDATE(), 112), 2)) >= 26 
	                        THEN CONVERT(CHAR(7), DATEADD(month, 1, GETDATE()), 121) 
							ELSE CONVERT(CHAR(7), GETDATE(), 121) END
			
	SELECT
			@AllowFlag = UI.AllowFlag,
			@IsDeveloper = UI.IsDeveloper,
			@CurrPassword = UI.Password,
			@SystemCode = UI.SystemCode,
			@OldIPAddress = UI.IPAddress,
			@ERPUserID = UI.Appendix8
	FROM
			STB_UserInfo UI WITH(NOLOCK)
	WHERE
			UI.UserID = @pUserID

	-- ERP Test
	SELECT @ERPPassword = PASS_WORD
	      ,@ERPLastChnagePasswordDateTime = SET_PWD_DAY
		  ,@ERPIncomCode = ME.CD_INCOM
	  FROM NEOE.NEOE.MA_USER MU
	  LEFT OUTER JOIN NEOE.NEOE.MA_EMP ME
	    ON MU.NO_EMP = ME.NO_EMP
	   AND MU.CD_COMPANY = ME.CD_COMPANY
	 WHERE MU.ID_USER = @ERPUserID
	   AND MU.CD_COMPANY = @ERPCdCompany
			
	IF @CurrPassword IS NULL BEGIN
		RAISERROR('Not found user',16,1)
		RETURN
	END
	IF @AllowFlag <> 'Allow' BEGIN
		RAISERROR('You are not allowed',16,1)
		RETURN
	END

	IF ISNULL(@ERPUserID, '') = '' OR  @ERPCdCompany = '2000' BEGIN
		IF PWDCOMPARE(@Password,@CurrPassword) <> 1 BEGIN
			RAISERROR('Invalid Password',16,1)
			RETURN
		END
	END ELSE BEGIN
		-- 퇴직, 휴직 여부를 체크한다.
		IF @ERPIncomCode IN ('002', '099') BEGIN
			RAISERROR('사용자가 휴직이거나 퇴직 상태입니다. 로그인할 수 없습니다.',16,1)
			RETURN
		END
		-- 패스워드 변경 일자를 체크한다.
		IF DATEDIFF(day, @ERPLastChnagePasswordDateTime, GETDATE()) >= 90 AND @ERPCdCompany = '1000'  BEGIN
			RAISERROR('90일 이상 패스워드를 변경하지 않았습니다. ERP를 통해 비밀번호를 변경한 뒤 로그인하시기 바랍니다.',16,1)
			RETURN
		END

		-- ERP기준으로 비밀번호를 비교한다.
		IF NEOE.NEOE.ERPiUVerify(@pPassword, @ERPPassword, @ERPCdCompany, @ERPUserID) <> 1 BEGIN
			RAISERROR('Invalid Password',16,1)
			RETURN
		END
	END

	IF @IsDeveloper <> 1 BEGIN
		RAISERROR('You are not developer',16,1)
		RETURN
	END		
	SELECT
			UI.UserID,
			UI.UserName,
			UI.Phone,
			UI.Mobile,
			UI.Email,			
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
			SUI.CompanyCode,
			CI.CompanyName,
			SUI.WorkCenterCode,
			WCI.WorkCenterName,
			@FromDate AS FromDate,
			@ToDate AS ToDate,

			-- TEST 
			CONVERT(DATE, @FromDate) AS FromDate2,
			CONVERT(DATE, @ToDate) AS ToDate2,

			CASE WHEN SUI.CompanyCode = 'VNT' AND SUI.WorkCenterCode = 'VNT_F1' THEN 'ROH_WH' 
				 WHEN SUI.CompanyCode = 'VNT' AND SUI.WorkCenterCode = 'VNT_F2' THEN SUI.MaterialWarehouseCode
			     WHEN SUI.CompanyCode = 'VVT' AND SUI.WorkCenterCode = 'VVT_F1' THEN 'ROH_VN_WH'
				 WHEN SUI.CompanyCode = 'VVT' AND SUI.WorkCenterCode = 'VVT_F2' THEN 'ROH_BG_WH'
				 ELSE NULL END AS MaterialWarehouseCode,
			CASE WHEN SUI.CompanyCode = 'VNT' AND SUI.WorkCenterCode = 'VNT_F1' THEN N'원자재창고' 
				 WHEN SUI.CompanyCode = 'VNT' AND SUI.WorkCenterCode = 'VNT_F2' AND SUI.MaterialWarehouseCode = 'W02' THEN N'원자재(소재)' 
				 WHEN SUI.CompanyCode = 'VNT' AND SUI.WorkCenterCode = 'VNT_F2' AND SUI.MaterialWarehouseCode = 'W14' THEN N'원자재(지지체)' 
			     WHEN SUI.CompanyCode = 'VVT' AND SUI.WorkCenterCode = 'VVT_F1' THEN N'Kho nguyên liệu'
				 WHEN SUI.CompanyCode = 'VVT' AND SUI.WorkCenterCode = 'VVT_F2' THEN N'Kho nguyên liệu(BG)'
				 ELSE NULL END AS MaterialWarehouseName,
			CASE WHEN SUI.CompanyCode = 'VNT' AND SUI.WorkCenterCode = 'VNT_F1' THEN 'ROUTE_WH' 
				 WHEN SUI.CompanyCode = 'VNT' AND SUI.WorkCenterCode = 'VNT_F2' AND SUI.MaterialWarehouseCode = 'W02' THEN 'W13' 
				 WHEN SUI.CompanyCode = 'VNT' AND SUI.WorkCenterCode = 'VNT_F2' AND SUI.MaterialWarehouseCode = 'W14' THEN 'W15' 
			     WHEN SUI.CompanyCode = 'VVT' AND SUI.WorkCenterCode = 'VVT_F1' THEN 'ROUTE_VN_WH'
				 WHEN SUI.CompanyCode = 'VVT' AND SUI.WorkCenterCode = 'VVT_F2' THEN 'ROUTE_BG_WH'
				 ELSE NULL END AS RouteWarehouseCode,
			CASE WHEN SUI.CompanyCode = 'VNT' AND SUI.WorkCenterCode = 'VNT_F1' THEN N'공정창고' 
				 WHEN SUI.CompanyCode = 'VNT' AND SUI.WorkCenterCode = 'VNT_F2' AND SUI.MaterialWarehouseCode = 'W02' THEN N'공정(소재)' 
				 WHEN SUI.CompanyCode = 'VNT' AND SUI.WorkCenterCode = 'VNT_F2' AND SUI.MaterialWarehouseCode = 'W14' THEN N'공정(지지체)' 
			     WHEN SUI.CompanyCode = 'VVT' AND SUI.WorkCenterCode = 'VVT_F1' THEN N'kho định tuyến'
				 WHEN SUI.CompanyCode = 'VVT' AND SUI.WorkCenterCode = 'VVT_F2' THEN N'kho định tuyến(BG)'
				 ELSE NULL END AS RouteWarehouseName
	FROM
			STB_UserInfo UI WITH(NOLOCK)
			LEFT OUTER JOIN SmartFactoryV2.dbo.STB_UserInfo SUI WITH(NOLOCK)
				ON	SUI.UserID = UI.UserID
			LEFT OUTER JOIN SmartFactoryV2.dbo.STB_CompanyInfo CI WITH(NOLOCK)
				ON	CI.CompanyCode = SUI.CompanyCode
			LEFT OUTER JOIN SmartFactoryV2.dbo.STB_WorkCenterInfo WCI WITH(NOLOCK)
				ON	WCI.WorkCenterCode = SUI.WorkCenterCode
	WHERE
			UI.UserID = @UserID

	IF @OldIPAddress IS NOT NULL AND @OldIPAddress <> @pIPAddress BEGIN
		DECLARE @LogoutMessage NVARCHAR(MAX)
		EXEC usp_GetAddonStringResource @pLanguage = @ProcessLanguage,
										@pName = '^{0} 에서 로그인되어 프로그램이 종료됩니다.^',
										@pValue = @LogoutMessage OUTPUT
		SET @LogoutMessage = REPLACE(@LogoutMessage,'{0}',@pIPAddress)
		EXEC usp_DoSendMessage	@pProcessUserID = @ProcessUserID,
								@pProcessLanguage = @ProcessLanguage,
								@pTargetUserID = @ProcessUserID,
								@pMessageType = 'Logout',
								@pTitle = @LogoutMessage,
								@pMessage = @LogoutMessage,
								@pIPAddress = @OldIPAddress
	END

	UPDATE STB_UserInfo
	SET
			IsLogin = 1,
			IPAddress = @IPAddress,
			LastLoginDateTime = GETDATE()
	WHERE
			UserID = @UserID
END

GO

