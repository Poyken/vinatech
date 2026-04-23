-- =============================================
-- Author:	    Mr.Tung
-- Create date: 2021-05-27
-- =============================================

--exec usp_stb_MergeBoxReality_531_get 'VVOO152R725671','2024-08-01',''
CREATE PROCEDURE [dbo].[usp_MergeBoxReality_531_get]
    @pBarcode VARCHAR(50) = NULL,
	@pFromDate Date = NULL,
    @pToDate Date = NULL

AS
BEGIN
		DECLARE @FromDate    VARCHAR(19)  =  CONVERT(VARCHAR(10),  @pFromDate )               +  ' 10:00:00'  
		DECLARE @ToDate      VARCHAR(19)  =  CONVERT(VARCHAR(10),  dateadd(day,1,@pToDate) )  +  ' 10:00:00'  
		DECLARE @Barcode VARCHAR(20) = CASE WHEN ISNULL(@pBarcode, '') = '' THEN '*' ELSE @pBarcode END
		
	    DECLARE @MergeNumber VARCHAR(50)
		--raiserror(@pBarcode,16,1)
		if(@pBarcode =' ') 
			begin

					select MBR.*,PWI.WorkerName from stb_MergeBoxReality  MBR
					left join STB_ProdWorkerInfo PWI on MBR.WorkerCode =PWI.WorkerCode
					where (MBR.createdatetime BETWEEN @FromDate AND @ToDate)
			end
		else
			begin
				
					select MBR.*,PWI.WorkerName from stb_MergeBoxReality  MBR
					left join STB_ProdWorkerInfo PWI on MBR.WorkerCode =PWI.WorkerCode
					where MergeNumber in (select MergeNumber from stb_MergeBoxRealityHist where @Barcode = '*' OR ChildLotno LIKE @Barcode) 
			end
	
END

      --select * from stb_MergeBoxReality
	--select * from stb_MergeBoxRealityHist
	--delete from stb_MergeBoxRealityHist

	--select * from STB_ProdWorkerInfo



