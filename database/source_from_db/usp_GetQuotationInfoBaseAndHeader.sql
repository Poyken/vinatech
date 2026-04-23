
-- =============================================
-- Author:	    Shin In Jae(ijshin@awoo.co.kr)
-- Create date: 2018-08-13
-- Browsable : true
-- Group : Quotation
-- Description:	견적관리 - 기준견적정보와 견적정보를 가져옵니다.
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_GetQuotationInfoBaseAndHeader]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),

	@pCompanyCode VARCHAR(20) = NULL, -- 사업장코드
	@pCustomerCode VARCHAR(20) = NULL, -- 거래선코드
	@pQuotationDateFrom DATE = NULL, -- 견적일자From
	@pQuotationDateTo DATE = NULL, -- 견적일자To
	@pQuotationUserID VARCHAR(20) = NULL, -- 견적작성자
	@pIsQuotationLastVersionOnly BIT = NULL -- 최종버전만조회

AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @CompanyCode VARCHAR(20) = CASE WHEN ISNULL(@pCompanyCode,'') = '' THEN '%' ELSE @pCompanyCode END
	DECLARE @CustomerCode VARCHAR(20) = CASE WHEN ISNULL(@pCustomerCode,'') = '' THEN '%' ELSE @pCustomerCode END
	DECLARE @QuotationDateFrom DATE = CASE WHEN @pQuotationDateFrom IS NULL THEN (SELECT MIN(QuotationDate) FROM STB_QuotationInfo WITH(NOLOCK) WHERE QuotationDate IS NOT NULL) ELSE @pQuotationDateFrom END
	DECLARE	@QuotationDateTo DATE = CASE WHEN @pQuotationDateTo IS NULL THEN (SELECT MAX(QuotationDate) FROM STB_QuotationInfo WITH(NOLOCK) WHERE QuotationDate IS NOT NULL) ELSE @pQuotationDateTo END
	DECLARE @QuotationUserID VARCHAR(20) = CASE WHEN ISNULL(@pQuotationUserID,'') = '' THEN '%' ELSE @pQuotationUserID END
	DECLARE @IsQuotationLastVersionOnly VARCHAR(20) = ISNULL(@pIsQuotationLastVersionOnly,CONVERT(BIT, 0))

	DECLARE @MAX_TMPTABLE TABLE
	(
		OrgQuotationNo VARCHAR(20) PRIMARY KEY,
		QuotationSeq INT
	)

	INSERT INTO @MAX_TMPTABLE
		(
			OrgQuotationNo,
			QuotationSeq
		)
		SELECT
				QI.OrgQuotationNo AS OrgQuotationNo, -- 기준견적번호
				MAX(QI.QuotationSeq) AS MaxQuotationSeq -- 견적생성순번
		FROM
				STB_OrgQuotationInfo OQI WITH(NOLOCK) -- Base
				INNER JOIN STB_QuotationInfo QI WITH(NOLOCK) -- Header
					ON(QI.OrgQuotationNo = OQI.OrgQuotationNo)
		WHERE
				(OQI.CompanyCode LIKE @CompanyCode) AND
				(OQI.CustomerCode LIKE @CustomerCode) AND
				(QI.QuotationDate BETWEEN @QuotationDateFrom AND @QuotationDateTo) AND
				(QI.QuotationUserID LIKE @QuotationUserID)

		GROUP BY QI.OrgQuotationNo


	DECLARE @HIS_TMPTABLE TABLE
	(
		OrgQuotationNo VARCHAR(20) PRIMARY KEY
	)

	INSERT INTO @HIS_TMPTABLE
		(
			OrgQuotationNo
		)
		SELECT
				QI.OrgQuotationNo AS OrgQuotationNo -- 기준견적번호
		FROM
				STB_OrgQuotationInfo OQI WITH(NOLOCK) -- Base
				INNER JOIN STB_QuotationInfo QI WITH(NOLOCK) -- Header
					ON(QI.OrgQuotationNo = OQI.OrgQuotationNo)
		WHERE
				(OQI.CompanyCode LIKE @CompanyCode) AND
				(OQI.CustomerCode LIKE @CustomerCode) AND
				(QI.QuotationDate BETWEEN @QuotationDateFrom AND @QuotationDateTo) AND
				(QI.QuotationUserID LIKE @QuotationUserID) AND
				@IsQuotationLastVersionOnly != 1

		GROUP BY QI.OrgQuotationNo

	SELECT
			-- Base
			OQI.OrgQuotationNo AS BaseOldOrgQuotationNo, -- 이전기준견적번호
			OQI.OrgQuotationNo AS BaseOrgQuotationNo, -- 기준견적번호
			OQI.CompanyCode AS BaseCompanyCode, -- 사업자코드
			CPI.CompanyName AS BaseCompanyName, -- 사업자명
			OQI.CustomerCode AS BaseCustomerCode,-- 거래선코드
			CTI.CustomerName AS BaseCustomerName, -- 거래선명
			OQI.QuotationCreateDate AS BaseQuotationCreateDate, -- 견적생성일자
			OQI.QuotationUserID AS BaseQuotationUserID, -- 견적작성자
			UI1.UserName AS BaseQuotationUserName, -- 견적작성자명
			OQI.QuotationToName AS BaseQuotationToName, -- 거래선담당자
			OQI.QuotationToTelNo AS BaseQuotationToTelNo, -- 거래선연락처
			OQI.QuotationToEmail AS BaseQuotationToEmail, -- 거래천이메일
			OQI.OrgQuotationText AS BaseOrgQuotationText, --견적내용
			OQI.OrgQuotationDesc AS BaseOrgQuotationDesc, -- 견적상세정보
			OQI.CreateDateTime AS BaseCreateDateTime, -- 정보생성일시
			OQI.CreateUserID AS BaseCreateUserID, -- 정보생성자
			OQI.ChangeDateTime AS BaseChangeDateTime, -- 정보수정일시
			OQI.ChangeUserID AS BaseChangeUserID, -- 정보수정자

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
			INNER JOIN @HIS_TMPTABLE HTB
				ON(HTB.OrgQuotationNo = QI.OrgQuotationNo)
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
			(OQI.CompanyCode LIKE @CompanyCode) AND
			(OQI.CustomerCode LIKE @CustomerCode) AND
			(QI.QuotationUserID LIKE @QuotationUserID)

	UNION

	SELECT
			-- Base
			OQI.OrgQuotationNo AS BaseOldOrgQuotationNo, -- 이전기준견적번호
			OQI.OrgQuotationNo AS BaseOrgQuotationNo, -- 기준견적번호
			OQI.CompanyCode AS BaseCompanyCode, -- 사업자코드
			CPI.CompanyName AS BaseCompanyName, -- 사업자명
			OQI.CustomerCode AS BaseCustomerCode,-- 거래선코드
			CTI.CustomerName AS BaseCustomerName, -- 거래선명
			OQI.QuotationCreateDate AS BaseQuotationCreateDate, -- 견적생성일자
			OQI.QuotationUserID AS BaseQuotationUserID, -- 견적작성자
			UI1.UserName AS BaseQuotationUserName, -- 견적작성자명
			OQI.QuotationToName AS BaseQuotationToName, -- 거래선담당자
			OQI.QuotationToTelNo AS BaseQuotationToTelNo, -- 거래선연락처
			OQI.QuotationToEmail AS BaseQuotationToEmail, -- 거래천이메일
			OQI.OrgQuotationText AS BaseOrgQuotationText, --견적내용
			OQI.OrgQuotationDesc AS BaseOrgQuotationDesc, -- 견적상세정보
			OQI.CreateDateTime AS BaseCreateDateTime, -- 정보생성일시
			OQI.CreateUserID AS BaseCreateUserID, -- 정보생성자
			OQI.ChangeDateTime AS BaseChangeDateTime, -- 정보수정일시
			OQI.ChangeUserID AS BaseChangeUserID, -- 정보수정자

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
			INNER JOIN @MAX_TMPTABLE MTB
				ON(MTB.OrgQuotationNo = QI.OrgQuotationNo AND
				(CASE WHEN @IsQuotationLastVersionOnly = 1 THEN MTB.QuotationSeq ELSE 1 END = CASE WHEN @IsQuotationLastVersionOnly = 1 THEN QI.QuotationSeq ELSE 1 END))
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
			(OQI.CompanyCode LIKE @CompanyCode) AND
			(OQI.CustomerCode LIKE @CustomerCode) AND
			(QI.QuotationDate BETWEEN @QuotationDateFrom AND @QuotationDateTo ) AND
			(QI.QuotationUserID LIKE @QuotationUserID)

	ORDER BY BaseOrgQuotationNo ASC, HeaderQuotationSeq ASC, HeaderQuotationNo ASC
END
