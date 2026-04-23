-- =============================================
-- Author: Kangs(yjyu@vina.co.kr)
-- Create date: 2020.09.18
-- Browsable : true
-- Group : 팝업
-- Description: 코드유형의 테이블을 쿼리하는 공용 프로시저
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_ElectrodeDivision_popup]
								@pProcessUserID varchar(20),
								@pProcessLanguage varchar(20)
AS

BEGIN

	Select ItemCode
	       , Description
	 From SmartFramework.dbo.STB_BaseCode
  	 Where 1=1
	    And CodeGroup = 'ElectrodeDivision'
	
END