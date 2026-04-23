-- =============================================
-- Author:		<Mr.Duy>
-- Create date: <2023-12-25>
-- Description:	<Cần phải xác nhận trước khi chuyển từ kho BN sang bên BG>
-- =============================================
CREATE PROCEDURE [dbo].[usp_Update_ExportNVL]
		@pProcessUserID varchar(20),
		@pProcessLanguage varchar(20),
		@pMaterialWarehouseInOutHistNo varchar(20),
		@pSourceMaterialWarehouseCode VARCHAR(20) = NULL,
		@pTargetMaterialWarehouseCode VARCHAR(20) = NULL,
		@pLotID VARCHAR(500) = NULL

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.

	SET NOCOUNT ON;
		Declare 
			 @SourceMaterialWarehouseCode VARCHAR(20) = @pSourceMaterialWarehouseCode
			 ,@TargetMaterialWarehouseCode VARCHAR(20) = @pTargetMaterialWarehouseCode
			 ,@LotID                                 VARCHAR(500) = ltrim(RTRIM(@pLotID))                                      -- 2020.04.16 RTRIM 추가 


		Declare @MaterialLotNo         VARCHAR(20) 
	         , @ProcessedLotID        VARCHAR(20)
		     , @TargetLocation         VARCHAR(20)
			 , @MaterialCode           VARCHAR(30)          --2020.04.27 추가
			 , @MaterialDocDetailNo VARCHAR(30)          --2020.05.12 추가

	--Tìm ra location
	SELECT TOP 1 @TargetLocation = MaterialLocationCode
	 FROM STB_MaterialLocation
	 WHERE MaterialWarehouseCode = @TargetMaterialWarehouseCode
	 ORDER BY MaterialLocationCode ASC

	 --Lấy MaterialLotNo để cập nhật dữ liệu location
	 SELECT  TOP 1 @MaterialLotNo = SM.MaterialLotNo 
								  , @ProcessedLotID = SM.LotID	
								  , @MaterialCode = SM.MaterialCode									
				  FROM (
							SELECT  SML.MaterialLotNo                                                                        
									 , SML.LotID																						     AS LotID
									 , SML.MaterialCode                                                                               AS MaterialCode
									 , SML.PackingID                                                                                    AS PackingID
									 , CASE WHEN MWIOH.ProcessedLotID IS NULL THEN '미출고' ELSE '정상출고' END AS ProcessedResult	
									 , SML.MaterialLocationCode                                                                     AS MaterialLocationCode				
							FROM                        STB_MaterialLotInfo                  SML
									 LEFT OUTER JOIN STB_MaterialWarehouseInOutHist  MWIOH	 ON SML.LotNo = MWIOH.LotID   AND SML.PackingID = MWIOH.ProcessedLotID
							WHERE 1=1
							AND SML.MaterialLocationCode LIKE @SourceMaterialWarehouseCode + '%'												
							AND (SML.LotID = @LotID OR SML.LotNo = @LotID)  			
													 
						   --AND SML.MaterialLocationCode LIKE  'ROH_WH' + '%'												                                  -- TEST용 주석처리
						  --AND (SML.LotID = 'WEC2R7106QG 2.7 10 2004161104' OR SML.LotNo = 'WEC2R7106QG 2.7 10 2004161104')  	  -- TEST용 주석처리
						    
						  ) SM
					WHERE 1=1
						AND SM.ProcessedResult  = '미출고'         
				  ORDER BY SM.MaterialLotNo  
				  print   @MaterialLotNo

	--Check xong rồi update từ kho cũ sang kho mới
	IF(@pMaterialWarehouseInOutHistNo='')
		BEGIN
			DECLARE @errNullData  nvarchar(200)
			set @errNullData = N'Bạn chưa chọn dữ liệu để xuất NVL';
			RAISERROR(@errNullData,16,1)
		END
	ELSE
		BEGIN
			DECLARE @date_confirm varchar(20) = substring(convert(varchar(20),getdate(),120),1,10);
			EXEC usp_PDADoPutaway_AddDateConfirmEX @pProcessLanguage, @pProcessUserID, @TargetLocation, @MaterialLotNo,@pLotID,@date_confirm, 'N' 
			UPDATE STB_MaterialWarehouseInOutHist
			SET Status_Confirm_Export=1,
				ChangeDateTime = GETDATE(),
				ChangeUserID = @pProcessUserID
			WHERE MaterialWarehouseInOutHistNo = @pMaterialWarehouseInOutHistNo
		
		END
END
--select * from STB_MaterialWarehouseInOutHist