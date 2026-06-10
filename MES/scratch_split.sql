Text                                                                                                                                                                                                                                                           
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- =============================================
                                                                                                                                                                                                             
-- Author: Jackaroe(yjyu@vina.co.kr)
                                                                                                                                                                                                                         
-- Group : ????
                                                                                                                                                                                                                                              
-- Browsable : true
                                                                                                                                                                                                                                          
-- Create date: 2025-11-08
                                                                                                                                                                                                                                   
-- Description: ???? Split ?? ??? ? ??? ??? LotID? ?? LotID? ??????.
                                                                                                                                                                                         
-- =============================================
                                                                                                                                                                                                             
CREATE PROCEDURE [dbo].[usp_DoSplitRawMaterialAndMove]
                                                                                                                                                                                                       
	@pProcessLanguage VARCHAR(20),
                                                                                                                                                                                                                              
	@pProcessUserID VARCHAR(20),
                                                                                                                                                                                                                                
	@pMaterialLotNo VARCHAR(20),
                                                                                                                                                                                                                                
	@pSplitQty NUMERIC(20,5),
                                                                                                                                                                                                                                   
	@pTargetLocation VARCHAR(20)
                                                                                                                                                                                                                                
AS
                                                                                                                                                                                                                                                           
BEGIN
                                                                                                                                                                                                                                                        
	SET NOCOUNT ON;
                                                                                                                                                                                                                                             

                                                                                                                                                                                                                                                             
    DECLARE @ProcessLanguage VARCHAR(20) = @pProcessLanguage,
                                                                                                                                                                                                
			@ProcessUserID VARCHAR(20) = @pProcessUserID,
                                                                                                                                                                                                             
			@MaterialLotNo VARCHAR(20) = @pMaterialLotNo,
                                                                                                                                                                                                             
			@SplitQty NUMERIC(20,5) = @pSplitQty,
                                                                                                                                                                                                                     
			@TargetLocation VARCHAR(20) = @pTargetLocation,
                                                                                                                                                                                                           
			@LotID VARCHAR(50),
                                                                                                                                                                                                                                       
			@MaterialCode VARCHAR(50),
                                                                                                                                                                                                                                
			@CurrentQty NUMERIC(20,5),
                                                                                                                                                                                                                                
			@PickingQty NUMERIC(20,5),
                                                                                                                                                                                                                                
			@ErrorMessage NVARCHAR(MAX),
                                                                                                                                                                                                                              
			@OriginalPackingID VARCHAR(20)
                                                                                                                                                                                                                            
	
                                                                                                                                                                                                                                                            
	SELECT
                                                                                                                                                                                                                                                      
			@LotID = MLI.LotID,
                                                                                                                                                                                                                                       
			@MaterialCode =  MLI.MaterialCode,
                                                                                                                                                                                                                        
			@CurrentQty = MLI.CurrentQty,
                                                                                                                                                                                                                             
			@PickingQty = ISNULL(MLI.PickingQty,0),
                                                                                                                                                                                                                   
			@OriginalPackingID = MLI.PackingID
                                                                                                                                                                                                                        
	FROM
                                                                                                                                                                                                                                                        
			STB_MaterialLotInfo MLI
                                                                                                                                                                                                                                   
	WHERE
                                                                                                                                                                                                                                                       
			MLI.MaterialLotNo = @MaterialLotNo
                                                                                                                                                                                                                        

                                                                                                                                                                                                                                                             
	IF ISNULL(@MaterialCode,'') = '' BEGIN
                                                                                                                                                                                                                      
		EXEC usp_GetSystemStringResource	@ProcessLanguage,
                                                                                                                                                                                                         
											'^????? ?? ? ????.^',
                                                                                                                                                                                                                             
											@ErrorMessage OUTPUT
                                                                                                                                                                                                                              

                                                                                                                                                                                                                                                             
		RAISERROR(@ErrorMessage,16,1)
                                                                                                                                                                                                                              
		RETURN
                                                                                                                                                                                                                                                     
	END
                                                                                                                                                                                                                                                         

                                                                                                                                                                                                                                                             
	IF ISNULL(@LotID,'') = '' BEGIN
                                                                                                                                                                                                                             
		EXEC usp_GetSystemStringResource	@ProcessLanguage,
                                                                                                                                                                                                         
											'^???? ????.^',
                                                                                                                                                                                                                                   
											@ErrorMessage OUTPUT
                                                                                                                                                                                                                              

                                                                                                                                                                                                                                                             
		RAISERROR(@ErrorMessage,16,1)
                                                                                                                                                                                                                              
		RETURN
                                                                                                                                                                                                                                                     
	END
                                                                                                                                                                                                                                                         

                                                                                                                                                                                                                                                             
	IF @PickingQty > 0 BEGIN
                                                                                                                                                                                                                                    
		EXEC usp_GetSystemStringResource	@ProcessLanguage,
                                                                                                                                                                                                         
											'^???? ??? ??? ? ????.^',
                                                                                                                                                                                                                         
											@ErrorMessage OUTPUT
                                                                                                                                                                                                                              

                                                                                                                                                                                                                                                             
		RAISERROR(@ErrorMessage,16,1)
                                                                                                                                                                                                                              
		RETURN
                                                                                                                                                                                                                                                     
	END
                                                                                                                                                                                                                                                         

                                                                                                                                                                                                                                                             
	IF @SplitQty < 0 BEGIN
                                                                                                                                                                                                                                      
		EXEC usp_GetSystemStringResource	@ProcessLanguage,
                                                                                                                                                                                                         
											'^Disallow minus q''ty^',
                                                                                                                                                                                                                         
											@ErrorMessage OUTPUT
                                                                                                                                                                                                                              

                                                                                                                                                                                                                                                             
		RAISERROR(@ErrorMessage,16,1)
                                                                                                                                                                                                                              
		RETURN
                                                                                                                                                                                                                                                     
	END
                                                                                                                                                                                                                                                         

                                                                                                                                                                                                                                                             
	IF @CurrentQty <= @SplitQty BEGIN
                                                                                                                                                                                                                           
		EXEC usp_GetSystemStringResource	@ProcessLanguage,
                                                                                                                                                                                                         
											'^??? ??? ???? ??? ???.^',
                                                                                                                                                                                                                        
											@ErrorMessage OUTPUT
                                                                                                                                                                                                                              

                                                                                                                                                                                                                                                             
		RAISERROR(@ErrorMessage,16,1)
                                                                                                                                                                                                                              
		RETURN
                                                                                                                                                                                                                                                     
	END
                                                                                                                                                                                                                                                         

                                                                                                                                                                                                                                                             
	/*
                                                                                                                                                                                                                                                          
	IF NOT EXISTS (SELECT 1 FROM STB_PackingLabelPrintHist WHERE PackingID = @OriginalPackingID) BEGIN
                                                                                                                                                          
		EXEC usp_RaiseLocalizedError @pProcessLanguage, '?? ??ID? ?? ??? ???? ????. ??? ??? ??? ? ????.'
                                                                                                                                                           

                                                                                                                                                                                                                                                             
		RETURN
                                                                                                                                                                                                                                                     
	END
                                                                                                                                                                                                                                                         
	*/
                                                                                                                                                                                                                                                          

                                                                                                                                                                                                                                                             
	IF @SplitQty <= 0 BEGIN
                                                                                                                                                                                                                                     
		EXEC usp_RaiseLocalizedError @pProcessLanguage, '?? ??? 0? ? ????.'
                                                                                                                                                                                        

                                                                                                                                                                                                                                                             
		RETURN
                                                                                                                                                                                                                                                     
	END
                                                                                                                                                                                                                                                         

                                                                                                                                                                                                                                                             
	DECLARE @NewMaterialLotNo VARCHAR(20)
                                                                                                                                                                                                                       
	EXEC SmartFramework.dbo.usp_DoCreateSerial @pTableName = 'STB_MaterialLotInfo',
                                                                                                                                                                             
							@pSerialNo = @NewMaterialLotNo OUTPUT
                                                                                                                                                                                                                 

                                                                                                                                                                                                                                                             

                                                                                                                                                                                                                                                             
	INSERT INTO [dbo].[STB_MaterialLotInfo]
                                                                                                                                                                                                                     
	(
                                                                                                                                                                                                                                                           
		MaterialLotNo,
                                                                                                                                                                                                                                             
		LotID,
                                                                                                                                                                                                                                                     
		CompanyCode,
                                                                                                                                                                                                                                               
		WorkCenterCode,
                                                                                                                                                                                                                                            
		MaterialWarehouseCode,
                                                                                                                                                                                                                                     
		MaterialLocationCode,
                                                                                                                                                                                                                                      
		MaterialCode,
                                                                                                                                                                                                                                              
		MaterialStockAttribute,
                                                                                                                                                                                                                                    
		StockAttrib1,
                                                                                                                                                                                                                                              
		StockAttrib2,
                                                                                                                                                                                                                                              
		StockAttrib3,
                                                                                                                                                                                                                                              
		PackingID,
                                                                                                                                                                                                                                                 
		GRDate,
                                                                                                                                                                                                                                                    
		MaterialDeliveryNo,
                                                                                                                                                                                                                                        
		MaterialDeliveryDetailNo,
                                                                                                                                                                                                                                  
		InitialQty,
                                                                                                                                                                                                                                                
		CurrentQty,
                                                                                                                                                                                                                                                
		PickingQty,
                                                                                                                                                                                                                                                
		VendorLotNo,
                                                                                                                                                                                                                                               
		LifeBasicDate,
                                                                                                                                                                                                                                             
		ProductionDate,
                                                                                                                                                                                                                                            
		EndOfLifeDate,
                                                                                                                                                                                                                                             
		LotNo,
                                                                                                                                                                                                                                                     
		IsSplitLot,
                                                                                                                                                                                                                                                
		BefMaterialLotNo,
                                                                                                                                                                                                                                          
		LotAttr01,
                                                                                                                                                                                                                                                 
		LotAttr02,
                                                                                                                                                                                                                                                 
		LotAttr03,
                                                                                                                                                                                                                                                 
		LotAttr04,
                                                                                                                                                                                                                                                 
		LotAttr05,
                                                                                                                                                                                                                                                 
		LotAttr06,
                                                                                                                                                                                                                                                 
		LotAttr07,
                                                                                                                                                                                                                                                 
		LotAttr08,
                                                                                                                                                                                                                                                 
		LotAttr09,
                                                                                                                                                                                                                                                 
		LotAttr10,
                                                                                                                                                                                                                                                 
		CreateDateTime,
                                                                                                                                                                                                                                            
		CreateUserID
                                                                                                                                                                                                                                               
	)
                                                                                                                                                                                                                                                           
	SELECT
                                                                                                                                                                                                                                                      
			@NewMaterialLotNo,
                                                                                                                                                                                                                                        
			@LotID,
                                                                                                                                                                                                                                                   
			CompanyCode,
                                                                                                                                                                                                                                              
			WorkCenterCode,
                                                                                                                                                                                                                                           
			MaterialWarehouseCode,
                                                                                                                                                                                                                                    
			MaterialLocationCode,
                                                                                                                                                                                                                                     
			MaterialCode,
                                                                                                                                                                                                                                             
			MaterialStockAttribute,
                                                                                                                                                                                                                                   
			StockAttrib1,
                                                                                                                                                                                                                                             
			StockAttrib2,
                                                                                                                                                                                                                                             
			StockAttrib3,
                                                                                                                                                                                                                                             
			@LotID,
                                                                                                                                                                                                                                                   
			GRDate,
                                                                                                                                                                                                                                                   
			MaterialDeliveryNo,
                                                                                                                                                                                                                                       
			MaterialDeliveryDetailNo,
                                                                                                                                                                                                                                 
			@SplitQty AS InitialQty,
                                                                                                                                                                                                                                  
			@SplitQty AS CurrentQty,
                                                                                                                                                                                                                                  
			0 AS PickingQty,
                                                                                                                                                                                                                                          
			VendorLotNo,
                                                                                                                                                                                                                                              
			LifeBasicDate,
                                                                                                                                                                                                                                            
			ProductionDate,
                                                                                                                                                                                                                                           
			EndOfLifeDate,
                                                                                                                                                                                                                                            
			LotNo,
                                                                                                                                                                                                                                                    
			1 AS IsSplitLot,
                                                                                                                                                                                                                                          
			CASE 
                                                                                                                                                                                                                                                     
				WHEN ISNULL(BefMaterialLotNo,'') = '' THEN MaterialLotNo
                                                                                                                                                                                                 
				ELSE BefMaterialLotNo
                                                                                                                                                                                                                                    
			END,
                                                                                                                                                                                                                                                      
			LotAttr01,
                                                                                                                                                                                                                                                
			LotAttr02,
                                                                                                                                                                                                                                                
			LotAttr03,
                                                                                                                                                                                                                                                
			LotAttr04,
                                                                                                                                                                                                                                                
			LotAttr05,
                                                                                                                                                                                                                                                
			LotAttr06,
                                                                                                                                                                                                                                                
			LotAttr07,
                                                                                                                                                                                                                                                
			LotAttr08,
                                                                                                                                                                                                                                                
			LotAttr09,
                                                                                                                                                                                                                                                
			LotAttr10,
                                                                                                                                                                                                                                                
			GETDATE(),
                                                                                                                                                                                                                                                
			@ProcessUserID
                                                                                                                                                                                                                                            
	FROM
                                                                                                                                                                                                                                                        
			STB_MaterialLotInfo MLI
                                                                                                                                                                                                                                   
	WHERE
                                                                                                                                                                                                                                                       
			MLI.MaterialLotNo = @MaterialLotNo
                                                                                                                                                                                                                        

                                                                                                                                                                                                                                                             
	-- ?? Lot ?? ??
                                                                                                                                                                                                                                             
	UPDATE
                                                                                                                                                                                                                                                      
			STB_MaterialLotInfo
                                                                                                                                                                                                                                       
	SET
                                                                                                                                                                                                                                                         
			CurrentQty = CurrentQty - @SplitQty,
                                                                                                                                                                                                                      
			ChangeDateTime = GETDATE(),
                                                                                                                                                                                                                               
			ChangeUserID = @ProcessUserID
                                                                                                                                                                                                                             
	WHERE
                                                                                                                                                                                                                                                       
			MaterialLotNo = @MaterialLotNo
                                                                                                                                                                                                                            

                                                                                                                                                                                                                                                             
	-- ???? ??
                                                                                                                                                                                                                                                  
	EXEC usp_PDADoPutaway @pProcessLanguage, @pProcessUserID, @TargetLocation, @NewMaterialLotNo, 'N'
                                                                                                                                                           
END                                                                                                                                                                                                                                                            
