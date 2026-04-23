
-- =============================================
-- Author:	    kilee
-- Create date: 2019-12-27
-- Browsable : true
-- Group : 품질관리 > [C391] 베트남 불량수량 입력
-- Description:	
-- Modified: 실적입력을 위한 신규화면개발
-- =============================================
-- EXEC [usp_VVT_BadList_get] '','','2020-01-04'

CREATE PROCEDURE [dbo].[usp_VVT_BadList_get]
	@pProcessUserID      VARCHAR(20),
	@pProcessLanguage  VARCHAR(20),	
	@pToMonth            Datetime = NULL
AS

BEGIN
	SET NOCOUNT ON;

    DECLARE @ProcessUserID      VARCHAR(20) = @pProcessUserID
	DECLARE @ProcessLanguage  VARCHAR(20) = @pProcessLanguage    				
	DECLARE @ToMonth             VARCHAR(10) = REPLACE(SUBSTRING(CONVERT(VARCHAR(10), @pToMonth, 121), 1, 10), '-', '')                    -- 금일 6자리           SELECT  REPLACE(SUBSTRING(CONVERT(VARCHAR(12), '2019-12-27 08:30:00', 121), 1, 10), '-', '')     --> '20191228'



SELECT standardDate
      , BAD_KIND 
	  , Qty
	  , GETDATE()
FROM STB_BAD_LIST2 SBL
WHERE 1=1
    --AND standardDate = '20200105'
   AND StandardDate LIKE @ToMonth + '%'  
  ORDER BY StandardDate DESC

END