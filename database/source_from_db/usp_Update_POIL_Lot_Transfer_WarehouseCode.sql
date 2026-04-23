-- =============================================
-- Author:		MR.Duy
-- Create date: 2025-01-22
-- Description:	Chuyển đổi từ sliiting về kho nvl
-- =============================================
CREATE PROCEDURE [dbo].[usp_Update_POIL_Lot_Transfer_WarehouseCode] 
		@pProcessUserID varchar(20),
		@pProcessLanguage varchar(20),
		@pCompanyCode VARCHAR(20) = NULL,
		@pWorkCenterCode VARCHAR(20) = NULL,
		@pLotID varchar(20)
AS
BEGIN
	--RAISERROR(N'Chưa nên xử dụng ' ,16, 1)           
		--	RETURN	
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
		declare @checkQC varchar(20)
		declare @isSliting bit
		declare	@ActualExportQuantity numeric(20,5)
		Declare @MaterialWarehouseInOutHistNo VARCHAR(20)


		select @checkQC = ischeck ,@ActualExportQuantity =  CurrentQty , @isSliting=IsSlitting  from stb_materiallotinfo where lotid = @pLotID
		if( @checkQC <>'pass' or  @checkQC is null)
		begin
								 RAISERROR(N'^Lot này QC chưa kiểm tra hoặc lot này QC đã  Reject^ ' ,16, 1)           
									RETURN	
		end
		if( @isSliting <>1 or  @isSliting is null)
		begin
								 RAISERROR(N'^Lot chưa chốt slitting.Vui lòng kiểm tra lại !^ ' ,16, 1)           
									RETURN	
		end
		
	
	--update STB_MaterialWarehouseInOutHist set ProcessedLotID = NULL where lotid=@pLotID

		--RAISERROR(@pLotID ,16, 1)    
		--RETURN	

	--EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_MaterialWarehouseInOutHist',@MaterialWarehouseInOutHistNo OUTPUT

	--		-- INSERT문
	--		INSERT INTO STB_MaterialWarehouseInOutHist (
	--			MaterialWarehouseInOutHistNo
	--			,CompanyCode
	--			,WorkCenterCode
	--			,SourceMaterialWarehouseCode
	--			,TargetMaterialWarehouseCode
	--			,WarehouseInOutCode
	--			,LotID
	--			,WorkerCode
	--			,LineCode
	--			,CreateUserID
	--			,Status_Confirm_Export
	--			,ActualExportQuantity
	--			) VALUES  (
	--				@MaterialWarehouseInOutHistNo
	--			   ,@pCompanyCode
	--			   ,@pWorkCenterCode
	--			   ,'SLITTING_HN_WH'
	--			   ,'ROH_HN_WH'
	--			   ,'I'
	--			   ,@pLotID
	--			   ,@pProcessUserID
	--			   ,'SLITTING'
	--			   ,@pProcessUserID
	--			   ,0
	--				,@ActualExportQuantity
	--				)

			--update stb_materiallotinfo
			--set MaterialWarehouseCode='ROH_HN_WH',MaterialLocationCode='ROH_HN_WH_01',isSlitting = 1
			--where lotid = @pLotID

		declare @getMaterialcode varchar(50)
		SELECT @getMaterialcode=MaterialCode FROM STB_MaterialLotInfo WHERE LotID = @pLotID
		
		IF @checkQC = 'Pass' and @getMaterialcode NOT LIKE 'NG%'
			BEGIN 

				EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_MaterialWarehouseInOutHist',@MaterialWarehouseInOutHistNo OUTPUT

				-- INSERT문
				INSERT INTO STB_MaterialWarehouseInOutHist (
					MaterialWarehouseInOutHistNo
					,CompanyCode
					,WorkCenterCode
					,SourceMaterialWarehouseCode
					,TargetMaterialWarehouseCode
					,WarehouseInOutCode
					,LotID
					,WorkerCode
					,LineCode
					,CreateDateTime
					,CreateUserID
					,Status_Confirm_Export
					,ActualExportQuantity
					) VALUES  (
						@MaterialWarehouseInOutHistNo
					   ,@pCompanyCode
					   ,@pWorkCenterCode
					   ,'SLITTING_HN_WH'
					   ,'ROH_HN_WH'
					   ,'I'
					   ,@pLotID
					   ,@pProcessUserID
					   ,'SLITTING'
					   ,GETDATE()
					   ,@pProcessUserID
					   ,0
						,@ActualExportQuantity
						)

					update stb_materiallotinfo
					set MaterialWarehouseCode='ROH_HN_WH',MaterialLocationCode='ROH_HN_WH_01',isSlitting = 1
					where lotid = @pLotID
				
				--RAISERROR(@pLotID ,16, 1)    
				--RETURN	

			END
		ELSE 
		    BEGIN
				EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_MaterialWarehouseInOutHist',@MaterialWarehouseInOutHistNo OUTPUT

				-- INSERT문
				/*INSERT INTO STB_MaterialWarehouseInOutHist (
					MaterialWarehouseInOutHistNo
					,CompanyCode
					,WorkCenterCode
					,SourceMaterialWarehouseCode
					,TargetMaterialWarehouseCode
					,WarehouseInOutCode
					,LotID
					,WorkerCode
					,LineCode
					,CreateDateTime
					,CreateUserID
					,Status_Confirm_Export
					,ActualExportQuantity
					) VALUES  (
						@MaterialWarehouseInOutHistNo
					   ,@pCompanyCode
					   ,@pWorkCenterCode
					   ,'SLITTING_HN_WH'
					   ,'NG_RAW_VN_WH'
					   ,'O'
					   ,@pLotID
					   ,@pProcessUserID
					   ,'XTH_HN'
					   ,GETDATE()
					   ,@pProcessUserID
					   ,0
						,@ActualExportQuantity
						)

				update STB_MaterialLotInfo
				set  ChangeDateTime=GETDATE(),ChangeUserID=@pProcessUserID
				where Lotid=@pLotID
				*/
			END
END
