-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- ============================================= exec usp_VN_LineiforToUserID 'sieusao','vi' 
CREATE PROCEDURE [dbo].[usp_VN_LineiforToUserID]
@pProcessUserID VARCHAR(20) = null,
@pProcessLanguage VARCHAR(20) = null
AS
BEGIN
declare @workCenterCode varchar(20)
select @workCenterCode = WorkCenterCode from STB_UserInfo where UserID=@pProcessUserID
--raiserror (@pProcessUserID,16,1)
SELECT

		LineCode as CODELINE,
		LineName as NAMELINE
		--,LineDesc,
		--LineType
FROM
		STB_LineInfo WITH(NOLOCK)
WHERE
		CompanyCode = 'VVT' AND IsUsed = 1 AND WorkCenterCode = @workCenterCode
		AND LineCode != 'XCDMDSD' AND LineCode != 'XK' AND LineCode != 'XTH' AND LineCode != 'XK'
		AND LineCode != 'KTSP'
		AND LineCode != 'R-KR'
		AND LineCode != 'SB202211300954' AND LineName <>''
End

