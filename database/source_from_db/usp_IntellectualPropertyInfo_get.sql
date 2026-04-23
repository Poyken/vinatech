-- =============================================
-- Author : Jackaroe(yjyu@vina.co.kr)
-- Group : 지적재산권관리
-- Browsable : true
-- Create date : 2022-03-31
-- Description : 
-- Modified :
-- =============================================
CREATE PROCEDURE [dbo].[usp_IntellectualPropertyInfo_get]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pApplicationYear VARCHAR(20) = NULL
AS
BEGIN
	Declare @ApplicationYear VARCHAR(4) = CASE WHEN ISNULL(@pApplicationYear, '') = '' THEN '*' ELSE @pApplicationYear END

	SELECT IPI.IntellectualPropertyNo
          ,IPI.IsDomestic
          ,IPI.NationCode
          ,IPI.InventionName
          ,IPI.ApplicationNo
          ,IPI.TechnologyClass
          ,IPI.TechnologyDetailClass
          ,IPI.IsCore
		  ,Year(IPI.ApplicationDate) AS ApplicationYear
          ,IPI.ApplicationDate
          ,IPI.RegistrationNo
		  ,Year(IPI.RegistrationDate) AS RegistrationYear
          ,IPI.RegistrationDate
          ,IPI.PatentStatus
          ,IPI.LegalStatus
          ,IPI.ApplicationOwner
          ,IPI.InventorNames
          ,IPI.RightStatus
          ,IPI.ClaimNumber
          ,IPI.ExaminationProgressStatus
          ,IPI.ExtinctionReason
          ,IPI.PublicNo
          ,IPI.PublicDate
          ,IPI.SurvivalExpirationDate
          ,IPI.PublicRegistrationNo
          ,IPI.PublicRegistrationDate
          ,IPI.CreateDateTime
          ,IPI.CreateUserID
          ,IPI.ChangeDateTime
          ,IPI.ChangeUserID
	  FROM STB_IntellectualPropertyInfo IPI
	 WHERE (@ApplicationYear = '*' OR @ApplicationYear = 0 OR CONVERT(CHAR(4), Year(IPI.ApplicationDate)) >= @ApplicationYear)
END