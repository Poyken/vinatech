
-- =============================================
-- Author:	    Shin In Jae(ijshin@awoo.co.kr)
-- Create date: 2018-08-16
-- Browsable : true
-- Group : Quotation
-- Description:	견적관리 - 견적정보상세를 조회합니다. (레이아웃 버전)
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_GetQuotationDetailInfoForLayout]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pQuotationNo VARCHAR(20) = NULL

AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @QuotationNo VARCHAR(20) = CASE WHEN ISNULL(@pQuotationNo,'') = '' THEN '%' ELSE @pQuotationNo END

    
	SELECT
			QDI.QuotationDetailNo AS OldQuotationDetailNo, -- 이전견적상세번호
			QDI.QuotationDetailNo, -- 견적상세번호
			QDI.QuotationNo, -- 견적번호
			QDI.QuotationDetailSeq, -- 견적상세순번
			QDI.MaterialCode, -- 재자코드
			CI.MaterialName, -- 자재명
			CI.MaterialNameL, -- 자재명2
			CI.MaterialSpec, -- 재자규격
			CI.MaterialSpecL, -- 자재규격2
			QDI.QuotationMaterialCode, -- 견적자재코드
			QDI.QuotationMaterialName, -- 견적자재명
			QDI.QuotationMaterialSpec, -- 견적자재규격
			QDI.QuotationQty, -- 견적수량
			QDI.QuotationUnitPrice, -- 견적단가
			ISNULL(QDI.QuotationQty, 0) * ISNULL(QDI.QuotationUnitPrice, 0) AS QuotationQtyPrice_Summary, -- 합계
			QDI.QuotationItemDesc, -- 비고내용
			QDI.CreateDateTime, -- 정보생성일시
			QDI.CreateUserID, -- 정보생성자
			QDI.ChangeDateTime, -- 정보수정일시
			QDI.ChangeUserID -- 정보수정자
	FROM
			STB_QuotationDetailInfo QDI WITH(NOLOCK)
			LEFT OUTER JOIN STB_MaterialMaster CI WITH(NOLOCK)
				ON QDI.MaterialCode = CI.MaterialCode
		
	WHERE
			(QDI.QuotationNo = @QuotationNo) 

END

