-- =============================================
-- Author: 유영종 (yjyu@vina.co.kr)
-- Create date: 2018-07-06
-- Browsable : true
-- Group : 인사
-- Description:	자격증정보 조회
-- Modified:
-- =============================================
create PROCEDURE [dbo].[usp_LicenseInfo_get]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pLcode VARCHAR(10) = NULL,
	@pDcode VARCHAR(10) = NULL,
	@pLicNm VARCHAR(100) = NULL
AS
BEGIN
	SET NOCOUNT ON;

	Declare @lCode varchar(10), @dCode varchar(10), @licNm varchar(100)

	SET @lCode = isnull(@pLcode, '')
	SET @dCode = isnull(@pDcode, '')
	SET @licNm = isnull(@pLicNm, '')
    
	SELECT
			 LI.LIC_NO
            ,LI.EMPID
			,EMP.EMPNM
            ,LI.LCODE
			,LC.LNAME
            ,LI.DCODE
			,LCD.DNAME
            ,LI.LIC_NM
            ,LI.LIC_START_DATE
            ,LI.LIC_END_DATE
            ,LI.REMARK
            ,LI.REG_DATE
            ,LI.REG_YMS
            ,LI.UDT_DATE
            ,LI.UDT_YMS
	FROM    STB_LICENSE_INFO LI
	INNER JOIN STB_EMPMST EMP
	   ON LI.EMPID = EMP.EMPCD
	INNER JOIN STB_LICENSE_CODE LC
	   ON LI.LCODE = LC.LCODE
	INNER JOIN STB_LICENSE_CODE_DETAIL LCD
	   ON LI.LCODE = LCD.LCODE
	  AND LI.DCODE = LCD.DCODE
	WHERE	1=1
	  AND   LI.LCODE LIKE '%' + @lCode + '%'
	  AND   LI.DCODE LIKE '%' + @dCode + '%'
	  AND   LI.LIC_NM LIKE '%' + @licNm + '%'


END