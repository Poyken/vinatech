-- =============================================
-- Author:	    HaNguyen
-- Create date: 2024-04-11
-- Browsable : true
-- Group : 공통
-- Description:	finished product box barcode information
-- Modified:
-- =============================================

-- usp_BarrelBarcodeCartonInfo_get '2024-05-01','2024-07-30','h1'
CREATE PROCEDURE [dbo].[usp_BarrelBarcodeCartonInfo_get]
		@pFromDate DATETIME = NULL,
		@pToDate DATETIME = NULL,
		@pPartNo nvarchar(20) = NULL
AS
BEGIN
	SET NOCOUNT ON;

		DECLARE @FromDate   VARCHAR(19) = CONVERT(VARCHAR(10), @pFromDate, 120) + ' 10:00:00'                                                            -- SELECT  CONVERT(VARCHAR(10), '2019-09-16', 121) + ' 08:30:00' 
		DECLARE @ToDate      VARCHAR(19) = CONVERT(VARCHAR(10), DATEADD(DAY, 1, CONVERT(smalldatetime, @pToDate)), 120) + ' 10:00:00'         -- 다음날 SELECT CONVERT(VARCHAR(10), DATEADD(DAY, 1, CONVERT(smalldatetime, '2019-09-17 00:01:09')), 121) + ' 08:30:00'    
		DECLARE @PartNo      VARCHAR(20) = CASE WHEN ISNULL(@pPartNo,'')    = '' THEN '*'      ELSE @pPartNo   END      -- 2022.01.04 추가 (채민수 요청)
 
	select * from  STB_VietNam_CheckBarcode_2624 where 

	 (CreateDateTime>=@FromDate  and CreateDateTime<@ToDate)
	  AND ((@PartNo = '*') OR (PartNo = @PartNo))   
	 --and levels =1
	
    
END


----         select * from stb_setinfo where  materialcode ='ECVT30-261'
