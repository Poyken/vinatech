-- =============================================
-- Author: Park Jong Hoon(jhpark@awoo.co.kr)
-- Create date: 2016-05-06
-- Browsable : true
-- Group : 공통정보
-- Description:	품목스펙이력조회
-- Modified:
-- =============================================
CREATE PROCEDURE usp_ModelSpecHist_get
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
    @pModelCode VARCHAR(20) = NULL

AS
BEGIN
	Declare @ModelCode VARCHAR(20) = CASE WHEN ISNULL(@pModelCode, '') = '' THEN '*' ELSE @pModelCode END

	SELECT MSH.ModelCode
	      ,MM.MaterialName AS ModelName
          ,MSH.SpecItemCode
		  ,SI.SpecItemName
          ,MSH.ChangeMode
		  ,CASE MSH.ChangeMode WHEN 'I' THEN '생성'
		                       WHEN 'U' THEN '변경'
							   WHEN 'D' THEN '삭제'
							   ELSE NULL END AS ChangeModeName
          ,MSH.Seq
          ,MSH.SpecValue
          ,MSH.UpperSpec
          ,MSH.LowerSpec
          ,MSH.CreateDateTime
          ,MSH.CreateUserID
          ,UI.UserName AS CreateUserName
	  FROM STB_ModelSpecHist MSH
	  LEFT OUTER JOIN STB_MaterialMaster MM
	    ON MSH.ModelCode = MM.MaterialCode
	  LEFT OUTER JOIN STB_SpecItem SI
	    ON MSH.SpecItemCode = SI.SpecItemCode
	  LEFT OUTER JOIN SmartFramework.dbo.STB_UserInfo UI
	    ON MSH.CreateUserID = UI.UserID
	 WHERE (@ModelCode = '*' OR ModelCode = @ModelCode)
	 ORDER BY MSH.ModelCode, MSH.SpecItemCode, MSH.Seq
END