-- =============================================
-- Author:		Mr.Duy
-- Create date: 2025-02-06
-- Description:	Reject lot nguyên liệu trong kho cắt
-- =============================================
CREATE PROCEDURE [dbo].[usp_QCReview_Poil_HaNamFactory_Reject]
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

			update STB_MaterialLotInfo
			set  ischeck='Reject',CheckTime=GETDATE(),CheckUserID=@pProcessUserID,MaterialWarehouseCode='NG_RAW_VN_WH' , MaterialLocationCode='NG_RAW_VN_WH_01' 
			where Lotid=@pLotID
		

END
