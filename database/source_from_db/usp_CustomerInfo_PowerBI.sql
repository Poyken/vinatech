
-- =============================================
-- Author:	    Kangs (kilee@vina.co.kr)
-- Create date: 2020-11-20
-- Browsable : True
-- Group : 공통
-- Description:	거래처정보 조회
-- Modified:
-- =============================================
-- usp_CustomerInfo_PowerBI ''

CREATE PROCEDURE [dbo].[usp_CustomerInfo_PowerBI]
AS

BEGIN
	SET NOCOUNT ON;
    
	SELECT
			CI.CustomerCode as 거래선코드,
			CI.CustomerName as 거래선명,
			CI.CIExtText01 as 거래선지역
	FROM
			STB_CustomerInfo CI WITH(NOLOCK)
	WHERE 1=1
    ORDER BY CI.CustomerName

END
