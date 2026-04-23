-- ===========================================================
-- Author: Kangs (kilee@vina.co.kr)
-- Create date: 2020.09.22
-- Browsable : true
-- Group : 제품창고 > 입고처리내역
-- Description: 코드유형의 테이블을 쿼리하는 공용 프로시저
-- Modified:
-- usp_WarehouseReceipt_get '','','2020-09-01','2020-09-30', 'PKKQ0100150'
-- ============================================================
CREATE PROCEDURE [dbo].[usp_WarehouseReceipt_get]
							@pProcessUserID Varchar(20),
							@pProcessLanguage Varchar(20),
							@pFromDate Date = NULL,
							@pToDate    Date = NULL,
							@pPackingID Varchar(20) = Null
AS

BEGIN

Declare @FromDate  Date = @pFromDate
	     , @ToDate     Date = @pToDate
		 , @PackingID  Varchar(30) = CASE WHEN ISNULL(@pPackingID,'') = '' THEN '%' ELSE @pPackingID END

		SELECT Substring(Convert(Varchar(10), RR.CRT_DT, 121), 0 ,12) AS WorkDate		
			    , RR.ITM_CD  AS Item_Cd
			    , (SELECT SM.MaterialName FROM STB_MaterialMaster SM WHERE SM.MaterialCode = RR.ITM_CD) AS Item_Nm
			    , RR.PACK_ID  AS PackingID
			    , RR.ITM_QTY  AS EnterQty
			  --, Case When RA.STATUS = 1 THEN '처리시도'  ELSE '' End   AS Try_Qty
			    , CONVERT(BIT, 1) AS EnterStatus
		FROM RCV_RSLT RR    --입고처리결과Table
				 LEFT OUTER JOIN RCV_ASN RA ON RR.PACK_ID = RA.PACK_ID     --입고처리시도Table
		WHERE 1=1
		   AND (Substring(Convert(Varchar(10), RR.CRT_DT, 121), 0 ,12)  BETWEEN @FromDate AND @ToDate)
	   -- AND Substring(Convert(Varchar(10), RR.CRT_DT, 121), 0 ,12) BETWEEN '2020-09-01' AND '2020-09-30'          -- 주석처리
		   AND RR.PACK_ID LIKE @PackingID
		 ORDER BY WorkDate

END



--SELECT Substring(Convert(Varchar(10), RR.CRT_DT, 121), 0 ,12) AS WorkDate		
--			  , RR.ITM_CD  AS Item_Cd
--			  , (SELECT SM.MaterialName FROM STB_MaterialMaster SM WHERE SM.MaterialCode = RR.ITM_CD) AS Item_Nm
--			  , RR.PACK_ID  AS PackingID
--			  , RR.ITM_QTY  AS Qty			  
--			  , Case When RA.STATUS = 1 THEN '처리시도'  ELSE '' End   AS Try_Qty
--			  , RR.*
--		FROM RCV_RSLT RR    --입고처리결과Table
--				 LEFT OUTER JOIN RCV_ASN RA ON RR.PACK_ID = RA.PACK_ID     --입고처리시도Table
--		WHERE 1=1
--		  -- AND (Substring(Convert(Varchar(10), RR.CRT_DT, 121), 0 ,12)  BETWEEN @FromDate AND @ToDate)
--	   -- AND Substring(Convert(Varchar(10), RR.CRT_DT, 121), 0 ,12) BETWEEN '2020-09-01' AND '2020-09-30'          -- 주석처리
--		   AND RR.PACK_ID LIKE 'PKKQ0100150'
--		 ORDER BY WorkDate