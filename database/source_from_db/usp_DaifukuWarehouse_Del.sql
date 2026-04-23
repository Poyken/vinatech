-- =============================================
-- Author: Kangs(kilee@vina.co.kr)
-- Create date: 2020-11-20
-- Browsable : true
-- Group : 제품관리 > 삭제
-- Description:	입고대기창고에 걸려있는 데이터 삭제를 합니다.
-- Modified:
-- 실행문 :  usp_DaifukuWarehouse_Del 
-- =============================================
Create PROCEDURE [dbo].[usp_DaifukuWarehouse_Del]
				@pProcessUserID VARCHAR(20),
				@pProcessLanguage VARCHAR(20)
				--@pLotID VARCHAR(20) = NULL,
				--@pPackingID VARCHAR(20) = NULL			
AS

BEGIN
	--Declare @PackingID VARCHAR(20) = CASE WHEN ISNULL(@pPackingID, '') = '' THEN '%' ELSE @pPackingID END    
	--	     , @LotID       VARCHAR(20) = CASE WHEN ISNULL(@pLotID, '') = ''       THEN '%' ELSE @pLotID       END       --추가		   		
   
	  -- 2. MES 정보
  Delete
	From STB_WareHouseTemp
  Where 1=1
    And Isnull(IsCheck, 0) <> CONVERT(BIT, 1)   -- 처리안된것


END