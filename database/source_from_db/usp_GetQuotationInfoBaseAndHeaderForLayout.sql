
-- =============================================
-- Author:	    Shin In Jae(ijshin@awoo.co.kr)
-- Create date: 2018-08-14
-- Browsable : true
-- Group : Quotation
-- Description:	견적관리 - 기준견적정보와 견적정보를 가져옵니다. (레이아웃 버전)
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_GetQuotationInfoBaseAndHeaderForLayout]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pOrgQuotationNo VARCHAR(20) = NULL,
	@pQuotationNo VARCHAR(20) = NULL,
	@pCompanyCode VARCHAR(20) = NULL,
	@pCustomerCode VARCHAR(20) = NULL
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @OrgQuotationNo VARCHAR(20) = CASE WHEN ISNULL(@pOrgQuotationNo,'') = '' THEN '' ELSE @pOrgQuotationNo END
	DECLARE @QuotationNo VARCHAR(20) = CASE WHEN ISNULL(@pQuotationNo,'') = '' THEN '' ELSE @pQuotationNo END
	DECLARE @CompanyCode VARCHAR(20) = CASE WHEN ISNULL(@pCompanyCode,'') = '' THEN '' ELSE @pCompanyCode END
	DECLARE @CustomerCode VARCHAR(20) = CASE WHEN ISNULL(@pCustomerCode,'') = '' THEN '' ELSE @pCustomerCode END

		SELECT
				-- Base
				OQI.OrgQuotationNo AS BaseOldOrgQuotationNo, -- 이전기준견적번호
				OQI.OrgQuotationNo AS BaseOrgQuotationNo, -- 기준견적번호
				OQI.CompanyCode AS BaseCompanyCode, -- 사업자코드
				CPI.CompanyName AS BaseCompanyName, -- 사업자명
				OQI.CustomerCode AS BaseCustomerCode,-- 거래선코드
				CTI.CustomerName AS BaseCustomerName, -- 거래선명
				OQI.QuotationCreateDate AS BaseQuotationCreateDate,
				OQI.QuotationUserID AS BaseQuotationUserID, -- 견적작성자
				UI1.UserName AS BaseQuotationUserName, -- 견적작성자명
				OQI.QuotationToName AS BaseQuotationToName,
				OQI.QuotationToTelNo AS BaseQuotationToTelNo,
				OQI.QuotationToEmail AS BaseQuotationToEmail,
				OQI.OrgQuotationText AS BaseOrgQuotationText,
				OQI.OrgQuotationDesc AS BaseOrgQuotationDesc,
				OQI.CreateDateTime AS BaseCreateDateTime,
				OQI.CreateUserID AS BaseCreateUserID,
				OQI.ChangeDateTime AS BaseChangeDateTime,
				OQI.ChangeUserID AS BaseChangeUserID,

				-- Header
				QI.QuotationNo AS HeaderOldQuotationNo, -- 이전견적번호
				QI.QuotationNo AS HeaderQuotationNo, -- 견적번호
				QI.OrgQuotationNo AS HeaderOrgQuotationNo, -- 기준견적번호
				QI.QuotationSeq AS HeaderQuotationSeq, -- 견적생성순번
				QI.QuotationDate AS HeaderQuotationDate, -- 견적일자
				QI.QuotationVersionDesc AS HeaderQuotationVersionDesc, -- 견적버젼상세정보
				QI.QuotationUserID AS HeaderQuotationUserID, -- 견적작성자
				UI2.UserName AS HeaderQuotationUserName, -- 견적작성자명
				QI.CurrencyUnit AS HeaderCurrencyUnit, -- 견적화폐단위
				ISNULL(QI.ExchangeRate,0) AS HeaderExchangeRate, -- 기준환율
				ISNULL(QI.TotalAmount,0) AS HeaderTotalAmount, -- 총금액
				ISNULL(QI.TotalWonAmount,0) AS HeaderTotalWonAmount, -- 총원화금액
				ISNULL(QI.NegoTotalAmount,0) AS HeaderNegoTotalAmount, -- 네고후총금액
				ISNULL(QI.NegoTotalWonAmount,0) AS HeaderNegoTotalWonAmount, -- 네고후총원화금액
				QI.QuotationDetailDesc AS HeaderQuotationDetailDesc, -- 견적상세정보
				QI.RequestDeliveryDate AS HeaderRequestDeliveryDate, -- 납품요청일자
				QI.IsApproval AS HeaderIsApproval, -- 승인여부
				QI.ApprovalUserID AS HeaderApprovalUserID, -- 승인자아이디
				UI3.UserName AS HeaderApprovalUserName, -- 승인자명
				QI.ApprovalDateTime AS HeaderApprovalDateTime, -- 승인일시
				QI.CreateDateTime AS HeaderCreateDateTime, -- 정보생성일시
				QI.CreateUserID AS HeaderCreateUserID, -- 정보생성자
				QI.ChangeDateTime AS HeaderChangeDateTime, -- 정보수정일시
				QI.ChangeUserID AS HeaderChangeUserID -- 정보수정자
		FROM
				STB_OrgQuotationInfo OQI WITH(NOLOCK) -- Base
				INNER JOIN STB_QuotationInfo QI WITH(NOLOCK) -- Header
					ON(QI.OrgQuotationNo = OQI.OrgQuotationNo)
				LEFT OUTER JOIN STB_CompanyInfo CPI(NOLOCK) -- Base
					ON(CPI.CompanyCode = OQI.CompanyCode)
				LEFT OUTER JOIN STB_CustomerInfo CTI(NOLOCK) -- Base
					ON(CTI.CustomerCode = OQI.CustomerCode)
				LEFT OUTER JOIN VW_UserInfo UI1 WITH(NOLOCK) -- Base
					ON(OQI.QuotationUserID = UI1.UserID)
				LEFT OUTER JOIN VW_UserInfo UI2 WITH(NOLOCK) -- Header
					ON(QI.QuotationUserID = UI2.UserID)
				LEFT OUTER JOIN VW_UserInfo UI3 WITH(NOLOCK) -- Header
					ON(QI.ApprovalUserID = UI3.UserID)
		WHERE
				(OQI.OrgQuotationNo = @OrgQuotationNo) AND
				(QI.QuotationNo = @QuotationNo)

END

