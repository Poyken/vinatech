-- =============================================
-- Author:		Mr.Duy
-- Create date: 2025-02-06
-- Description:	QC đánh giá các nguyên liệu được cắt trong phòng Slitting Hà Nam
-- =============================================
CREATE PROCEDURE [dbo].[usp_QCReview_Poil_HaNamFactory]
		@pProcessUserID varchar(20),
		@pProcessLanguage varchar(20),
		@pLotID varchar(20),
		@pMaterialCode varchar(50)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	--RAISERROR(@pMaterialCode,16,1)
	--return
		DECLARE @checkIsSlit  nvarchar(200)


		select @checkIsSlit=IsSlitting from STB_MaterialLotInfo  where Lotid=@pLotID
		IF(@checkIsSlit<>1)
		BEGIN
			DECLARE @errNullData  nvarchar(200)
			set @errNullData = N'Dữ liệu chưa được chốt slitting!...';
			RAISERROR(@errNullData,16,1)
		END
		-- update luôn pass
		update STB_MaterialLotInfo
		set  ischeck='Pass',CheckTime=GETDATE(),CheckUserID=@pProcessUserID
		where Lotid=@pLotID

		--kiểm tra xem nếu là nguyên vật liệu bắt đầu bằng NG thì sẽ udpate lại là không về kho mà chuyển đến kho NG
	  IF(@pMaterialCode like 'NG%')
		BEGIN
			update STB_MaterialLotInfo
			set  ischeck='Reject',CheckTime=GETDATE()/*,ChangeDateTime=GETDATE(),ChangeUserID=@pProcessUserID*/,CheckUserID=@pProcessUserID ,MaterialWarehouseCode='NG_RAW_VN_WH' , MaterialLocationCode='NG_RAW_VN_WH_01' 
			where Lotid=@pLotID

		END

	  	
END
