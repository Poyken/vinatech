-- =============================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Create date: 2022-08-11
-- Browsable : true
-- Group : MEA > 도면관리 > MEA구분코드(팝업)
-- Description:
-- ================================================================================================
CREATE PROCEDURE usp_MEAClassInfo_popup
						@pProcessUserID VARCHAR(20),
						@pProcessLanguage VARCHAR(20)
AS
BEGIN
	SELECT MEAClassCode
	      ,MEAClassName
	  FROM STB_MEAClassInfo
	 ORDER BY MEAClassCode
END