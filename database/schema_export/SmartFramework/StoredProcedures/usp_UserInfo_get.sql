-- Procedure: usp_UserInfo_get


-- =============================================
-- Author:	    Kim Han Young
-- Create date: 2016-01-15
-- Browsable : true
-- Group : 시스템관리 > 사용자관리
-- Description:	사용자 리스트를 조회합니다. Get User List
-- Modified: 
-- =============================================

--   EXEC [usp_UserInfo_get] '','monitoring01'

CREATE PROCEDURE [dbo].[usp_UserInfo_get]
	@pProcessUserID VARCHAR(20),
	@pUserID VARCHAR(20) = NULL,
	@pCompanyCode VARCHAR(20) = NULL
AS
BEGIN

	SET NOCOUNT ON;

    DECLARE @ProcessUserID VARCHAR(20) = @pProcessUserID,
			@UserID VARCHAR(20) = CASE WHEN ISNULL(@pUserID,'') = '' THEN '%' ELSE @pUserID END,
			@SystemCode VARCHAR(20),
			@CompanyCode VARCHAR(20) = CASE WHEN ISNULL(@pCompanyCode,'') = '' THEN '*' ELSE @pCompanyCode END
    
	SELECT
			@SystemCode = UI.SystemCode
	FROM
			STB_UserInfo UI WITH(NOLOCK)
	WHERE
			UI.UserID = @ProcessUserID

	SELECT
			UI.UserID,
			UI.UserName,
			CONVERT(NVARCHAR,NULL) AS Password,
			UI.Mobile,
			UI.Email,
			UI.AllowFlag,
			UI.UserImg,
			UI.SystemCode,
			UI.Appendix1,
			UI.Appendix2,
			UI.Appendix3,
			UI.Appendix4,
			UI.Appendix5,
			UI.Appendix6,
			UI.Appendix7,
			UI.Appendix8,
			--UI.Appendix9,
			--UI.Appendix10,
			CONVERT(DATE, CONVERT(VARCHAR(7), DATEADD(month, -1, GETDATE()), 121) + '-26') AS Appendix9,
			CONVERT(DATE, CONVERT(VARCHAR(7), GETDATE(), 121) + '-25') AS Appendix10,
			UI.CanMakeReport,
			UI.IsDeveloper,
			UI.CreateDateTime,
			UI.ChangeDateTime,
			SUI.CompanyCode,
			CI.CompanyName,
			SUI.WorkCenterCode,
			WCI.WorkCenterName,
			SUI.MaterialWarehouseCode,
			MW.MaterialWarehouseName,
			CONVERT(DATE, CONVERT(VARCHAR(7), DATEADD(month, -1, GETDATE()), 121) + '-26') AS FromDate,
			CONVERT(DATE, CONVERT(VARCHAR(7), GETDATE(), 121) + '-25') AS ToDate

	FROM 	STB_UserInfo UI WITH(NOLOCK)
			    LEFT OUTER JOIN SmartFactoryV2.dbo.STB_UserInfo SUI WITH(NOLOCK)				     ON	SUI.UserID = UI.UserID
				LEFT OUTER JOIN SmartFactoryV2.dbo.STB_CompanyInfo CI WITH(NOLOCK)				 ON	CI.CompanyCode = SUI.CompanyCode
				LEFT OUTER JOIN SmartFactoryV2.dbo.STB_WorkCenterInfo WCI WITH(NOLOCK)		 ON	WCI.WorkCenterCode = SUI.WorkCenterCode
				LEFT OUTER JOIN SmartFactoryV2.dbo.STB_MaterialWarehouse MW WITH(NOLOCK)	 ON MW.MaterialWarehouseCode = SUI.MaterialWarehouseCode
	WHERE 1=1
	   AND 	UI.UserID LIKE @UserID
	    AND ((@CompanyCode = '*') OR (SUI.CompanyCode = @CompanyCode)) 
	   
END

GO

