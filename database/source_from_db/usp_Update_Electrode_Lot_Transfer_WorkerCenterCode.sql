-- =============================================
-- Author:		Mr.Duy
-- Create date: 2024-8-8
-- Description:	Chuyển lot điện cực đi nhà máy
-- =============================================
CREATE PROCEDURE [dbo].[usp_Update_Electrode_Lot_Transfer_WorkerCenterCode] 
		@pProcessUserID varchar(20),
		@pProcessLanguage varchar(20),
		@pElectrodeLotNumber varchar(20),
		@pSeq int,
		@pWorkCenterCode varchar(50)

AS
BEGIN

	SET NOCOUNT ON;
	/*RAISERROR(@pWorkCenterCode,16,1)
	return*/
	declare @count int
	
	select @count= COUNT(*) from STB_ElectrodeSlittingResult where ElectrodeLotNumber = @pElectrodeLotNumber
					and Seq=@pSeq and WorkCenterCode=@pWorkCenterCode
	 if(@count >=1)
			BEGIN
			DECLARE @errNullData1  nvarchar(200)
			set @errNullData1 = N'Bạn đã chuyển lot này rồi!...';
			RAISERROR(@errNullData1,16,1)
		END	
   IF(@pElectrodeLotNumber ='')
		BEGIN
			DECLARE @errNullData  nvarchar(200)
			set @errNullData = N'Bạn chưa chọn dữ liệu để chuyển nhà máy!...';
			RAISERROR(@errNullData,16,1)
		END
	ELSE
		BEGIN
		 
			UPDATE
					STB_ElectrodeSlittingResult
			SET
					WorkCenterCode=@pWorkCenterCode,TransferDateTime=GETDATE(),
					ChangeUserID = @pProcessUserID,
					ChangeDateTime = GETDATE()
			WHERE
					ElectrodeLotNumber = @pElectrodeLotNumber
					and Seq=@pSeq
		
		END
END
