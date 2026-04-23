
-- =============================================
-- Author:		Kim Han Young(hykim@awoo.co.kr)
-- Create date: 2016-08-19
-- Group : [F123] 자재관리 > 발주서 인쇄용지
-- Description:	발주서 인쇄용 정보를 조회합니다.
--                  항목추가 (2019.06.13, kilee) 
--                  항목수정 Case문 추가 (2019.06.27)
-- =============================================
-- EXEC [usp_GetMaterialOrderReport] '','','20190626000011'


CREATE PROCEDURE [dbo].[usp_GetMaterialOrderReport]
						@pProcessUserID VARCHAR(20),
						@pProcessLanguage VARCHAR(20),
						@pMaterialOrderNo VARCHAR(20) = NULL
AS

BEGIN
	SET NOCOUNT ON;

	DECLARE	 @ProcessUserID     VARCHAR(20) = @pProcessUserID,
			     @ProcessLanguage VARCHAR(20) = @pProcessLanguage,
			     @MaterialOrderNo VARCHAR(20) = @pMaterialOrderNo

	-- [1]  SELECT  * FROM STB_MaterialOrder  WHERE  MaterialOrderNo = '20190610000001'

    SELECT
			MO.MaterialOrderNo,
			CI.CustomerName,
			dbo.fnConvertDateTimeToVarchar('yyyy-mm-dd',MO.DeliveryPlanDate)   AS DeliveryPlanDate,
			CI.OrderToName,
			CI.OrderToTel,
			CI.OrderToEmail,
			CI.FaxNo,
			MO.MOExtText02                                                               AS Remark,	                        -- 비고 / 기타사항
			CI.CustomerName + '_' + MO.MaterialOrderNo                           AS ReportFileName,		
			CI.FaxNo,
			CI.TelNo,
			CI.AddressText,
			CI.ContactTel1,
			CI.ContactName1,
			dbo.fnConvertDateTimeToVarchar('yyyy-mm-dd',MO.OrderDate)   AS OrderDate	,                      -- 날짜추가   
			MO.MOExtText05                                                          AS Payment                          -- ERP [지불조건] 추가 (2019-06-18)
	FROM
			STB_MaterialOrder MO                      WITH(NOLOCK)
			LEFT OUTER JOIN STB_CustomerInfo CI WITH(NOLOCK)	ON	CI.CustomerCode = MO.CustomerCode			
	WHERE
			MO.MaterialOrderNo = @MaterialOrderNo
			--MO.MaterialOrderNo = '20190610000001'

   -- [2] SELECT MOIExtText01, * FROM STB_MaterialOrderItem WHERE MaterialOrderNo = '20190610000001'

	SELECT
			ROW_NUMBER() OVER(ORDER BY MOI.MaterialOrderItemNo) AS [No],			
			MOI.MaterialOrderNo,
			MM.MaterialCode,
			CASE WHEN PG.ProductGroupName IS NULL THEN MM.MaterialName ELSE (PG.ProductGroupName + '  ' + MM.MaterialName)  END  AS MaterialName,    -- 자재그룹 + 품명 (수정 2019.06.26)
		 -- (PG.ProductGroupName + '  ' + MM.MaterialName)                                                                                                     AS MaterialName,    -- 자재그룹 + 품명 (원본백업)
		 -- MM.MaterialName,	                                                                                                              -- 품명 백업
			MM.MaterialSpec,	                                                                                                              -- 규격			
		 -- MM.MaterialUnit,	                                                                                                              -- 단위 백업
		 -- (CONVERT(VARCHAR, MOI.MaterialOrderQty)  + '  ' + MM.MaterialUnit)  AS MaterialOrderQty,	                  -- 수량(Quantity) + 단위
			 MOI.MaterialOrderQty                                                             AS MaterialOrderQty,	                  -- 수량(Quantity)
			'Quantity' + '  ' + MM.MaterialUnit                                               AS Qname,                                -- 컬럼명칭 ( Quantity + 단위)			
			MOI.MaterialOrderUnitPrice,	                                                                                                   -- 단가			
		 -- (CONVERT(VARCHAR, MOI.MaterialOrderUnitPrice) + '  ' + ((SELECT  SCU.Unit  FROM STB_Currency_Unit  SCU WHERE MOI.MOIExtText01 = SCU.UNIT) ) ,     -- 단가 + 화폐단위
			(SELECT  SCU.Unit  FROM STB_Currency_Unit  SCU WHERE SCU.UNIT = MOI.MOIExtText02) AS Unit,               -- 화폐단위
			MOI.MaterialOrderTotalPrice,	                                                                                                   -- 금액
		 -- CONVERT(decimal(6,4), MOI.MaterialOrderTotalPrice) ,
			MOI.MaterialOrderItemDesc,	                                                                                                   -- 비고			
			(MOI.MaterialOrderQty * MOI.MaterialOrderUnitPrice)                           AS Amount,                              -- Amount = 단가 * 수량 
			PG.ProductGroupName,
			MOIExtText03                                                                           AS Comment	                            -- 특이사항
		 -- PG.ProductGroupNameL,
		 -- PG.ProductGroupDesc,
		 -- PG.ProductGroupDescL
		 -- (SELECT CASE WHEN SCU.Unit IS NULL THEN MOI.MOIExtText01 ELSE '원' END AS Unit  FROM STB_Currency_Unit  SCU WHERE SCU.UNIT = MOI.MOIExtText01) AS UNIT
	FROM
			STB_MaterialOrderItem                   MOI WITH(NOLOCK)
			LEFT OUTER JOIN STB_MaterialMaster MM WITH(NOLOCK)	ON MM.MaterialCode = MOI.MaterialCode
            LEFT OUTER JOIN STB_ProductGroup   PG  WITH(NOLOCK)	ON MM.ProductGroupCode = PG.ProductGroupCode						
	WHERE 1=1
	   AND MOI.MaterialOrderNo = @MaterialOrderNo
	  --AND MOI.MaterialOrderNo = '20190610000001'
	  --AND MOI.MaterialOrderNo = '20190617000007'
	ORDER BY
			MOI.MaterialOrderItemNo

END



-- [ERP] 
        -- SELECT 화폐단위 FROM 업체단가 GROUP BY 화폐단위
		--SELECT 화폐단위 FROM ERPSVR.ERPDB.DBO.업체단가 GROUP BY 화폐단위
		--SELECT * FROM ERPSVR.ERPDB.DBO.업체단가 WHERE 품목코드 = 'GBSN00-001'

		--SELECT MOIExtText02 FROM STB_MaterialOrderItem GROUP BY MOIExtText02


		--SELECT 화폐단위 
		--INTO STB_Currency_Unit
		--FROM ERPSVR.ERPDB.DBO.업체단가 GROUP BY 화폐단위

		-- SELECT 화폐단위 FROM STB_Currency_Unit