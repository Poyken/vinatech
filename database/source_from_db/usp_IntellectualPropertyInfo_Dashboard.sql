-- =============================================
-- Author : Jackaroe(yjyu@vina.co.kr)
-- Group : 지적재산권관리
-- Browsable : true
-- Create date : 2022-03-31
-- Description : 
-- Modified :
-- =============================================
CREATE PROCEDURE [dbo].[usp_IntellectualPropertyInfo_Dashboard]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20)
AS
BEGIN
	SELECT CASE WHEN IPI.IsDomestic = CONVERT(BIT, 1) THEN '국내' ELSE '해외' END AS [국가구분]
          ,IPI.NationCode AS [국가코드]
		  ,IPI.InventionName AS [발명의 명칭]
          ,IPI.InventorNames AS [발명자]
          ,IPI.ApplicationNo AS [출원번호]
          ,IPI.TechnologyClass AS [기술구분]
          ,IPI.TechnologyDetailClass AS [세부구분]
          ,CASE WHEN IPI.IsCore = CONVERT(BIT, 1) THEN '핵심' ELSE '' END AS [핵심구분]
		  ,Year(IPI.ApplicationDate) AS [출원연도]
          ,IPI.ApplicationDate AS [출원일]
          ,IPI.RegistrationNo AS [등록번호]
		  ,Year(IPI.RegistrationDate) AS [등록연도]
          ,IPI.RegistrationDate AS [등록일]
          ,IPI.PatentStatus AS [특허/실용구분]
          ,IPI.LegalStatus AS [법적상태]
          ,IPI.ApplicationOwner AS [출원인]
          ,IPI.InventorNames AS [발명자]
          ,IPI.RightStatus AS [현재권리자]
          ,IPI.ClaimNumber AS [청구항 수]
          ,IPI.ExaminationProgressStatus AS [심사진행상태]
          ,IPI.ExtinctionReason AS [소멸이유]
          ,IPI.PublicNo AS [공개번호]
          ,IPI.PublicDate AS [공개일]
          ,IPI.SurvivalExpirationDate AS [존속기간 만료일]
          ,IPI.PublicRegistrationNo AS [공개/등록번호]
          ,IPI.PublicRegistrationDate AS [공개/등록일자]
	  FROM STB_IntellectualPropertyInfo IPI
END