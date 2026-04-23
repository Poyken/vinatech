-- =============================================

-- =============================================
CREATE  PROCEDURE [dbo].[usp_WarehouseExportReference_get]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pExportReferenceNo int= NULL,
	@pLotNo varchar(50)= NULL
AS
BEGIN
	SET NOCOUNT ON;
    
	DECLARE @MaterialCode varchar(50)
	DECLARE @MaterialReference varchar(50)
	DECLARE @qty nvarchar(50)
	DECLARE @checklotno int
	DECLARE @cnt int 

	DECLARE @aa varchar(50)
	
	if (@pLotNo is not null and @pLotNo !='')
	begin
		select @checklotno = count(*) from stb_ExportReference_Detail where ExportReference_ID = @pExportReferenceNo and lotno = @pLotNo
		select @cnt = count(*) from Stb_Warehouse_ExportReference where ExportReference_ID = @pExportReferenceNo and lotno=@pLotNo
	--	RAISERROR (@aa ,16,1)
		if @checklotno <=0
		BEGIN
				--EXEC usp_RaiseLocalizedError @pProcessLanguage, 'Check again LotID!'
				--RETURN
				RAISERROR('Check again LotID!',16,1)
		END
		if @checklotno > 0
		begin
			select @MaterialCode = MaterialCode from stb_ExportReference_Detail where ExportReference_ID = @pExportReferenceNo and lotno = @pLotNo

			select  @MaterialReference=materialcode, @qty=sum(packqty) from STB_VN_FINISHGOODS where lotno=@pLotNo group by LotNo, materialcode

			if(@MaterialCode = @MaterialReference)
			begin
				
				while (@cnt < @checklotno)
				begin
					insert into Stb_Warehouse_ExportReference(ExportReference_ID,LotNo,MaterialCode,Quatity,CreateDateTime,CreateUserID)
					values(@pExportReferenceNo,@pLotNo,@MaterialCode,@qty,GETDATE(),@pProcessUserID)
					SET @cnt = @cnt + 1;
				end
			end
			else
			begin
				--EXEC usp_RaiseLocalizedError @pProcessLanguage, 'Check again MaterialCode!'
				--RETURN
				RAISERROR('Check again MaterialCode!',16,1)


			end
		
		end
	end


	SELECT distinct
	        ID,
		    ExportReference_ID,
			LotNo,
			MaterialCode,
			Quatity ,
			CreateDateTime ,
			CreateUserID ,
			ChangeDateTime ,
			ChangeUserID 
	FROM  Stb_Warehouse_ExportReference
	WHERE ExportReference_ID=@pExportReferenceNo
END


