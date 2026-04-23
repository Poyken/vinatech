-- =============================================
-- Author: nguyentung@vina.co.kr
-- Create date: 2021-10-20
-- Browsable : true
-- =============================================
CREATE PROCEDURE [dbo].[usp_HelaPackingReScanHist_iud]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pLotNo VARCHAR(20) = NULL,
	@pEmployee VARCHAR(50) = NULL,
	@pResetScanningLot BIT = 0
AS
BEGIN
	Declare @LotNo VARCHAR(20) = @pLotNo
			,@Employee VARCHAR(50) =@pEmployee
	        ,@ResetScanningLot BIT = @pResetScanningLot
			,@MaxSeqNo INT = 0
			,@cCountEmp int = 0

		   
		   if(@pResetScanningLot = 0 or @pResetScanningLot is null) return;
		   if(@LotNo = '' or @LotNo is null) return;

		   SELECT @cCountEmp = COUNT(*) 
			FROM STB_ProdWorkerInfo
			WHERE CompanyCode='VVT' and WorkerCode=@pEmployee 

		   if(@cCountEmp=0)  BEGIN
				EXEC usp_RaiseLocalizedError @pProcessLanguage, 'IUD: Ma Nhan Vien khong dung hoac khong phai Ma Nhan Vien Viet Nam. The Employee ID is wrong or invalid.'
				RETURN
			END

			--Save history of every Scanning
			select @MaxSeqNo = max(CheckSeqNo) 
			from  STB_HelaPackingCheckHist_Detail 
			WHERE LotNo = @LotNo 


			--select @ChangeUserID=convert(varchar(10),@MaxSeqNo);
			--raiserror (@ChangeUserID,16,1)

			if(@MaxSeqNo>=100) 
				select @MaxSeqNo = @MaxSeqNo+100
			else 
				select @MaxSeqNo = 100
				

			insert into STB_HelaPackingCheckHist_Detail 
				(LotNo,PackageID,IsChecked,CheckSeqNo,CreateDateTime,CreateUserID,ChangeDateTime,ChangeUserID) 
			select 
				LotNo,PackageID,IsChecked,@MaxSeqNo,CreateDateTime,CreateUserID,getdate(),isnull(@Employee,@pProcessUserID) 
			from STB_HelaPackingCheckHist 
			WHERE LotNo = @LotNo 



			--DELETE all current status in Main History
			delete STB_HelaPackingCheckHist where LotNo = @LotNo
END

--select*from
--STB_HelaPackingCheckHist_detail where LotNo =
--'VJLQ102R750621'