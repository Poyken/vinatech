
-- =============================================
-- Author:	   kilee
-- Create date: 2019-04-16
-- Browsable : true
-- Group : 생산관리 > 실적등록 > 베트남생산실적입력
-- Description:	
-- Modified: 
-- =============================================

-- exec [usp_Medium_TEST] '','',''

Create PROCEDURE [dbo].[usp_Medium_TEST]
	@pProcessUserID     VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pToDay                datetime
AS
BEGIN
	SET NOCOUNT ON;
    
Declare  @SqlString VARCHAR(MAX) = ''
		,@AllColumn VARCHAR(1000) = ''
		,@AllColumn2 VARCHAR(1000) = ''
		,@AllColumn3 VARCHAR(MAX) = ''

Declare  @cnt INT = 1
		,@cnt2 INT = 1
		,@cnt3 INT = 1

WHILE @cnt <= 31 BEGIN
	SET @AllColumn = @AllColumn + ',Day' + RIGHT('000' + CONVERT(VARCHAR(10), @cnt), 2)
	SET @cnt = @cnt + 1
END

SET @cnt = 1

WHILE @cnt <= 31 BEGIN
	SET @AllColumn2 = @AllColumn2 + ',A.Day'+RIGHT('000' + CONVERT(VARCHAR(10), @cnt), 2)
	                              + '-B.Day'+ RIGHT('000' + CONVERT(VARCHAR(10), @cnt), 2)
	SET @cnt = @cnt + 1
END

SET @cnt = 1

WHILE @cnt <= 31 BEGIN
	SET  @cnt2 = 1
	SET  @cnt3 = 1

	SET @AllColumn3 = @AllColumn3 + CASE WHEN @cnt2 = 1 THEN ',' ELSE '' END
	
	WHILE @cnt2 <= @cnt BEGIN
		SET @AllColumn3 = @AllColumn3 + CASE WHEN @cnt2 = 1 THEN '(' ELSE '' END 
									  + 'A.Day'+RIGHT('000' + CONVERT(VARCHAR(10), @cnt2), 2)
									  + CASE WHEN @cnt2 <> @cnt THEN '+' ELSE ')' END
		SET @cnt2 = @cnt2 + 1
	END

	SET @AllColumn3 = @AllColumn3 + ' - '

	WHILE @cnt3 <= @cnt BEGIN
		SET @AllColumn3 = @AllColumn3 + CASE WHEN @cnt3 = 1 THEN '(' ELSE '' END 
									  + 'B.Day'+RIGHT('000' + CONVERT(VARCHAR(10), @cnt3), 2)
									  + CASE WHEN @cnt3 <> @cnt THEN '+' ELSE ')' END
		SET @cnt3 = @cnt3 + 1
	END
	SET @cnt = @cnt + 1
END

SET @SqlString = 'SELECT 사이즈, 용도 ' + @AllColumn + ' 
                    FROM ( 
							SELECT 사이즈, ''일일실적'' AS 용도 ' + @AllColumn + ' 
							  FROM MEDIUM_PROD 
							 WHERE 기준년월 = CONVERT(VARCHAR(6), GETDATE(), 112) 
							UNION ALL
							SELECT 사이즈, ''목표(A)'' AS 용도 ' + @AllColumn + ' 
							  FROM MEDIUM_PLAN 
							 WHERE 기준년월 = CONVERT(VARCHAR(6), GETDATE(), 112) 
							UNION ALL
							SELECT A.사이즈, ''차이(B-A)'' AS 용도 ' + @AllColumn2 + ' 
							  FROM MEDIUM_PLAN A 
							  LEFT JOIN  MEDIUM_PROD B 
								ON A.사이즈 = B.사이즈 
							 WHERE A.기준년월 = CONVERT(VARCHAR(6), GETDATE(), 112)
							UNION ALL
							SELECT A.사이즈, ''Balance''  AS 용도 ' + @AllColumn3 + ' 
							  FROM MEDIUM_PLAN A 
							  LEFT JOIN  MEDIUM_PROD B 
								ON A.사이즈 = B.사이즈 
							 WHERE A.기준년월 = CONVERT(VARCHAR(6), GETDATE(), 112) 
					)  AA 
			     WHERE 사이즈 = ''1840'' 
				 ORDER BY 사이즈, 용도'

EXEC (@SqlString)

END