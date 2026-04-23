-- =============================================
-- Author: Kangs(kilee@vina.co.kr)
-- Create date: 2020-08-05
-- Browsable : true
-- Group : 제품관리 > 단독출고처리
-- Description:	단독출고처리 (정상포장 -> 박스꺼내서 다시 입고처리)
-- Modified:
-- 실행문 :  usp_RCV_ASN_SingleShipment_get '','','',''
-- =============================================
CREATE PROCEDURE [dbo].[usp_RCV_ASN_SingleShipment_get]
				@pProcessUserID VARCHAR(20),
				@pProcessLanguage VARCHAR(20),
				@pLotID VARCHAR(20) = NULL,
				@pPackingID VARCHAR(20) = NULL			
AS

BEGIN
	Declare @PackingID VARCHAR(20) = CASE WHEN ISNULL(@pPackingID, '') = '' THEN '%' ELSE @pPackingID END    
		     , @LotID       VARCHAR(20) = CASE WHEN ISNULL(@pLotID, '') = ''       THEN '%' ELSE @pLotID       END       --추가		   		
             , @RCV_ORD_NO  BIGINT

   -- 가장 Max번호
   SELECT   @RCV_ORD_NO = CONVERT(BIGINT, (MAX(RCV_ORD_NO))) +1    
     FROM RCV_ASN

   -- TEST : SELECT  CONVERT(BIGINT, (MAX(RCV_ORD_NO))) +1  FROM RCV_ASN                     --조회예 : 20200805000210

	  -- I/F 테이블
   SELECT @RCV_ORD_NO AS RCV_ORD_NO
   --SELECT  RCV_ORD_NO
           , PACK_ID
		   , RCV_TYPE
		   , ITM_CD
		   , ITM_NM
		   , ITM_QTY
		   , STATUS
		   , getdate()  AS CRT_DT
	FROM RCV_ASN
 WHERE 1=1
    AND Status <> '1'
  --  AND LotID Like @LotID
	 --AND PackingID Like @PackingID
	
END