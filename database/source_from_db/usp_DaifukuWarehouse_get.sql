-- =============================================
-- Author: Kangs(kilee@vina.co.kr)
-- Create date: 2020-07-29
-- Browsable : true
-- Group : 제품관리 > 라벨박스처리로직
-- Description:	입고대기창고로 이동처리전에 체크로직입니다.
-- Modified:
-- 실행문 :  usp_DaifukuWarehouse_get '','','',''
-- =============================================
CREATE PROCEDURE [dbo].[usp_DaifukuWarehouse_get]
				@pProcessUserID VARCHAR(20),
				@pProcessLanguage VARCHAR(20),
				@pLotID VARCHAR(20) = NULL,
				@pPackingID VARCHAR(20) = NULL			
AS

BEGIN
	Declare @PackingID VARCHAR(20) = CASE WHEN ISNULL(@pPackingID, '') = '' THEN '%' ELSE @pPackingID END    
		     , @LotID       VARCHAR(20) = CASE WHEN ISNULL(@pLotID, '') = ''       THEN '%' ELSE @pLotID       END       --추가		   		
   
	  -- 2. MES 정보
SELECT PackingID
	    , MaterialCode
		, LotID 
		, Qty
		, IsCheck 
	FROM STB_WareHouseTemp
 WHERE 1=1
    AND Isnull(IsCheck, 0) <> CONVERT(BIT, 1)   -- 처리안된것
    AND LotID Like @LotID
	 AND PackingID Like @PackingID
	
END