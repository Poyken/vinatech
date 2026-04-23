-- =============================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Create date: 2022-08-11
-- Browsable : true
-- Group : MEA > 도면관리 > MEA구분정보
-- Description:
-- ================================================================================================
CREATE PROCEDURE usp_MEAClassInfo_get
						@pProcessUserID VARCHAR(20),
						@pProcessLanguage VARCHAR(20)
AS
BEGIN
	SELECT MEAClassCode AS OldMEAClassCode
	      ,MEAClassCode
	      ,MEAClassName
		  ,CreateDateTime
		  ,CreateUserID
		  ,ChangeDateTime
		  ,ChangeUserID
	  FROM STB_MEAClassInfo
	 ORDER BY MEAClassCode
END