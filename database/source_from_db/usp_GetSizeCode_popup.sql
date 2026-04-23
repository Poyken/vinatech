

-- =============================================
-- Author: kilee
-- Create date: 2019-04-25
-- Browsable : true
-- Group : 시스템관리
-- Description:	사이즈코드 관리 조회_POPUP
-- Modified:

-- 2020.02.27 1830 사이즈 추가
-- =============================================

CREATE PROCEDURE [dbo].[usp_GetSizeCode_popup]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pCodeSize VARCHAR(20) = NULL
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @CodeSize VARCHAR(8) = CASE WHEN ISNULL(@pCodeSize,'') = '' THEN '*' ELSE @pCodeSize END
    
	--SELECT
	--		IsNull(BC.ItemCode,'') AS [ItemCode],
	--		IsNull(BC.Description,'') AS [Description]
	--FROM
	--		STB_BaseCode BC WITH(NOLOCK)
	--WHERE 	
	--		( @CodeGroup = '*') OR (BC.CodeGroup = @CodeGroup)

	-- 예외처리 사이즈 등록

	SELECT '1030L' AS 사이즈  -- ,  '1030L' AS 사이즈1 
	 UNION ALL

	 --SELECT '1840-수동' AS 사이즈    -- , '1840-수동' AS 사이즈1
	 --UNION ALL

	 --SELECT '1840-자동' AS 사이즈    -- , '1840-자동' AS 사이즈1     
	 --UNION ALL

   --  SELECT 사이즈 
	  --FROM ERPSVR.ERPDB.DBO.product 
   --   WHERE 1=1
   --      AND LEN(사이즈) = 4
	  -- --AND 사이즈 IN ('0813', '0820', '1025', '1030', '1320', '1325', '1346', '1840', '1859', '1625')                                                                                             -- 원본백업
		 --AND 사이즈 IN ('0813', '0820', '0825', '0830', '1020', '1025', '1030', '1035', '1320', '1325', '1346', '1625', '1630', '1840', '1859', '2245', '2570','3562', '3567', '3582' )         -- 원본수정 (2019.05.21)
		 --AND ( @CodeSize = '*') OR (사이즈 = @CodeSize)
   --    GROUP BY 사이즈
	  -- ORDER BY 사이즈

	  /*
	SELECT replace(ModelName,'HY-CAP ','')   as "사이즈" , RIGHT('0' + CONVERT(VARCHAR(10), CONVERT(INT, MBISizeW)) + CONVERT(VARCHAR(10), CONVERT(INT, MBISizeH)), 4) AS "사이즈1"
	 FROM STB_ModelBasicInfo
	WHERE modelcode like 'ECVT%'
	  AND RIGHT('0' + CONVERT(VARCHAR(10), CONVERT(INT, MBISizeW)) + CONVERT(VARCHAR(10), CONVERT(INT, MBISizeH)), 4)  IN ('0813', '0820', '0825', '0830', '1020', '1025', '1030', '1035', '1320', '1325', '1346', '1625', '1630', '1830', '1840', '1859', '2245', '2570','3562', '3567', '3582' )         -- 원본수정 (2019.05.21)
    GROUP BY  RIGHT('0' + CONVERT(VARCHAR(10), CONVERT(INT, MBISizeW)) + CONVERT(VARCHAR(10), CONVERT(INT, MBISizeH)), 4) , ModelName
	*/
	

	SELECT distinct  RIGHT('0' + CONVERT(VARCHAR(10), CONVERT(INT, MBISizeW)) + CONVERT(VARCHAR(10), CONVERT(INT, MBISizeH)), 4) AS 사이즈		    
	 FROM STB_ModelBasicInfo
	WHERE (modelcode like 'ECVT%' OR ModelCode LIKE 'LIVT%')
	and RIGHT('0' + CONVERT(VARCHAR(10), CONVERT(INT, MBISizeW)) + CONVERT(VARCHAR(10), CONVERT(INT, MBISizeH)), 4) is not null
	  --AND RIGHT('0' + CONVERT(VARCHAR(10), CONVERT(INT, MBISizeW)) + CONVERT(VARCHAR(10), CONVERT(INT, MBISizeH)), 4)  IN ('0813', '0820', '0825', '0830', '1020', '1025', '1030', '1035', '1320', '1325', '1346', '1625', '1630', '1830', '1840', '1859', '2245', '2570','3562', '3567', '3582' )         -- 원본수정 (2019.05.21)
	   --AND ( @CodeSize = '*') OR (사이즈 = @CodeSize)
    GROUP BY RIGHT('0' + CONVERT(VARCHAR(10), CONVERT(INT, MBISizeW)) + CONVERT(VARCHAR(10), CONVERT(INT, MBISizeH)), 4) 
	--ORDER BY RIGHT('0' + CONVERT(VARCHAR(10), CONVERT(INT, MBISizeW)) + CONVERT(VARCHAR(10), CONVERT(INT, MBISizeH)), 4) 


END




--SELECT 사이즈 FROM ERPSVR.ERPDB.DBO.product 
--WHERE 1=1
--AND LEN(사이즈) = 4
----AND LEN(사이즈) BETWEEN 3 AND 5
--AND 사이즈 IN ('0813', '0820', '0825', '1025', '1026', '1027', '1030', '1035', '1050', '1320', '1325', '1346', '1625', '1630', '1840', '1859', '1860')
----AND NOT 사이즈 = ''
--GROUP BY 사이즈
--ORDER BY 사이즈

--SELECT *
--			--IsNull(BC.ItemCode,'') AS [ItemCode],
--			--IsNull(BC.Description,'') AS [Description]
--	FROM
--			STB_BaseCode BC WITH(NOLOCK)
--	WHERE 	