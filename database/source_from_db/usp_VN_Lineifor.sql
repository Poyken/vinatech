CREATE PROC [dbo].[usp_VN_Lineifor] -- EXEC usp_VN_Lineifor '',''
 --   @pProcessUserID VARCHAR(20),
	--@pProcessLanguage VARCHAR(20)
AS
BEGIN
--declare @workCenterCode varchar(20)
--select @workCenterCode = WorkCenterCode from STB_UserInfo where UserID=@pProcessUserID

SELECT

		LineCode,
		LineName--,
		--LineDesc,
		--LineType
FROM
		STB_LineInfo WITH(NOLOCK)
WHERE
		CompanyCode = 'VVT' AND IsUsed = 1 AND WorkCenterCode = 'VVT_F1' --@workCenterCode
		AND LineCode != 'XCDMDSD' AND LineCode != 'XK' AND LineCode != 'XTH' AND LineCode != 'XK'
		AND LineCode != 'KTSP'
		AND LineCode != 'R-KR'
		AND LineCode != 'SB202211300954' AND LineName <>''
		
END

--SELECT * FROM STB_LineInfo

--SELECT

--		LineCode,
--		LineName,
--		LineDesc,
--		LineType
--FROM
--		STB_LineInfo WITH(NOLOCK)
--WHERE
--		CompanyCode = 'VVT' AND IsUsed = 1 AND WorkCenterCode = 'VVT_F2' 