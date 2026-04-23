-- =============================================
-- Author: Kangs(kilee@vina.co.kr)
-- Create date: 2020-07-29
-- Browsable : true
-- Group : 제품관리 > 라벨박스처리로직
-- Description:	입고대기창고로 이동처리전에 체크로직입니다.
-- Modified:
-- 실행문 :  usp_DaifukuWarehouse_get '','','',''
-- =============================================
CREATE PROCEDURE [dbo].[usp_TestScreen2]
				@pProcessUserID varchar(20)=NULL,
				@pProcessLanguage varchar(20)=NULL,
				@pLotNo varchar(30) =NULL,

				--@pLotNo varchar(30)  ,
				@pFromDate DATETIME = NULL,
				@pToDate DATETIME = NULL		
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @LotNo VARCHAR(20) = @pLotNo;
	DECLARE @FromDate  DATE =@pFromDate
	DECLARE @ToDate  DATE= @pToDate
	
	
	RAISERROR('fdsf',16,1)
	if (@LotNo <> '')
		begin
			
			SELECT top 10 * From STB_SavePackingTime_VVT  where LotNo =@LotNo 
			--and  PrintTime BETWEEN @pFromDate AND @pToDate;
			
		end
	else
		begin
			
			SELECT  * From STB_SavePackingTime_VVT where CONVERT(DATE, PrintTime)  between @FromDate  AND  @ToDate;
			
		end

END

--exec [dbo].[usp_TestScreen2] '','','VVOL192R740601','',''
--exec [dbo].[usp_TestScreen2] '','','','2024-03-31','2024-03-31'
