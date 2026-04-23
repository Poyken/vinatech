-- =============================================
-- Author:	    HaNguyen
-- Create date: 2024-04-11
-- Browsable : true
-- Group : 공통
-- Description:	finished product box barcode information
-- Modified:
-- =============================================

-- usp_BarrelBarcodeSmallInfo_get '2024-06-11','2024-06-11','VVON233R010626'
CREATE PROCEDURE [dbo].[usp_BarrelBarcodeSmallInfo_get]
		--@pFromDate DATETIME = NULL,
		--@pToDate DATETIME = NULL,
		@pBarcode nvarchar(20) = NULL
AS
BEGIN
	SET NOCOUNT ON;

		--DECLARE @FromDate   VARCHAR(19) = CONVERT(VARCHAR(10), @pFromDate, 120) + ' 10:00:00'                                                            -- SELECT  CONVERT(VARCHAR(10), '2019-09-16', 121) + ' 08:30:00' 
		--DECLARE @ToDate      VARCHAR(19) = CONVERT(VARCHAR(10), DATEADD(DAY, 1, CONVERT(smalldatetime, @pToDate)), 120) + ' 10:00:00'         -- 다음날 SELECT CONVERT(VARCHAR(10), DATEADD(DAY, 1, CONVERT(smalldatetime, '2019-09-17 00:01:09')), 121) + ' 08:30:00'    
		DECLARE	@Barcode   VARCHAR(20) = CASE WHEN ISNULL(@pBarcode, '') = ''     THEN '*' ELSE @pBarcode     END
		--DECLARE	@Barcode   VARCHAR(20)=  @pBarcode   
		

	--RAISERROR(@Barcode, 16, 1);
	select * from  STB_VietNam_CheckBarcode_2624 where LotNo = @Barcode 
	--and  (CreateDateTime>=@FromDate  and CreateDateTime<@ToDate) 
	and 
	levels =2
	
    
END
