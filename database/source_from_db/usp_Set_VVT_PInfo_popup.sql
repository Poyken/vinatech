

CREATE PROCEDURE [dbo].[usp_Set_VVT_PInfo_popup]
				@pProcessUserID VARCHAR(20),
				@pProcessLanguage VARCHAR(20),
				@pLotNo VARCHAR(20) = NULL
AS
BEGIN
	SET NOCOUNT ON;

	--raiserror(@pLotNo,16,1)
	--return
		
			select PONo, MaterialCode, @pLotNo as Barcode
			from  STB_ProductionOrderInfo
			where  CreateDateTime >= dateadd(DAY,-31,getdate()) and CreateDateTime <= dateadd(DAY,31,getdate()) 
			and case when DATEPART(DAY,getdate())>25 then DATEPART(MONTH,getdate())+1 else DATEPART(MONTH,getdate()) end
			 =  case when DATEPART(DAY,CreateDateTime)>25 then DATEPART(MONTH,CreateDateTime)+1 else DATEPART(MONTH,CreateDateTime) end	  
			and MaterialCode = (select MaterialCode from STB_SetInfo  where Barcode = @pLotNo) 
			and CompanyCode='VVT'
end
