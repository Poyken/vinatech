

-- =============================================
-- Author:		<Jeon Gyeong Ho>
-- Browsable : false
-- Group : 시스템
-- Create date: <2016-06-17>
-- Description:	<신규 자재Lot 번호를 생성하여 입출고 합니다.>
-- =============================================
CREATE PROCEDURE [dbo].[usp_DoProcessNewMaterialLotNo]
						@pCompanyCode VARCHAR(20),
						@pWorkCenterCode VARCHAR(20),
						@pLotID VARCHAR(50),
						@pMaterialWarehouseCode VARCHAR(20),
						@pMaterialLocationCode VARCHAR(20),
						@pMaterialStockAttribute VARCHAR(20),
						@pStockAttrib1 VARCHAR(20),
						@pStockAttrib2 VARCHAR(20),
						@pStockAttrib3 VARCHAR(20),
						@pMaterialCode VARCHAR(50),
						@pLotNo VARCHAR(100) = NULL,
						@pVendorLotNo VARCHAR(100) = NULL,		-- 2018-08-28 JGH VendorLotNo 추가
						@pUsedQty NUMERIC(20,5),
						@pProcessUserID VARCHAR(20),
						@pGRDate DATE = NULL,
						@pPackingID VARCHAR(50) = NULL,
						@pLotAttr01 NVARCHAR(100) = NULL,
						@pLotAttr02 NVARCHAR(100) = NULL,
						@pLotAttr03 NVARCHAR(100) = NULL,
						@pLotAttr04 NVARCHAR(100) = NULL,
						@pLotAttr05 NVARCHAR(100) = NULL,
						@pLotAttr06 NVARCHAR(100) = NULL,
						@pLotAttr07 NVARCHAR(100) = NULL,
						@pLotAttr08 NVARCHAR(100) = NULL,
						@pLotAttr09 NVARCHAR(100) = NULL,
						@pLotAttr10 NVARCHAR(100) = NULL,
						@pMaterialLotNo VARCHAR(20) = NULL OUTPUT

AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @IsAutoKey BIT,
			@IsLoopIUD BIT,
			@PrefixString VARCHAR(12),
			@SerialLen INT,
			@MaxKeyField VARCHAR(20),
			@MaterialLotNo VARCHAR(20),
			@IsFIFO BIT,
			@GRDate VARCHAR(10),
			@LotNo VARCHAR(100) = ISNULL(@pLotNo, ''),
			@VendorLotNo VARCHAR(100) = ISNULL(@pVendorLotNo,''),
			@PackingID VARCHAR(50) = ISNULL(@pPackingID, ''),
			@NewSerialNo INT,
			@LotAttr01 NVARCHAR(100) = ISNULL(@pLotAttr01,''),
			@LotAttr02 NVARCHAR(100) = ISNULL(@pLotAttr02,''),
			@LotAttr03 NVARCHAR(100) = ISNULL(@pLotAttr03,''),
			@LotAttr04 NVARCHAR(100) = ISNULL(@pLotAttr04,''),
			@LotAttr05 NVARCHAR(100) = ISNULL(@pLotAttr05,''),
			@LotAttr06 NVARCHAR(100) = ISNULL(@pLotAttr06,''),
			@LotAttr07 NVARCHAR(100) = ISNULL(@pLotAttr07,''),
			@LotAttr08 NVARCHAR(100) = ISNULL(@pLotAttr08,''),
			@LotAttr09 NVARCHAR(100) = ISNULL(@pLotAttr09,''),
			@LotAttr10 NVARCHAR(100) = ISNULL(@pLotAttr10,'')

	DECLARE @IsUseLotID BIT


	
	--EXEC SmartFramework.dbo.usp_GetSerialRule 
	--		@pTableName = 'STB_MaterialLotInfo',
	--		@pIsAutoKey = @IsAutoKey OUTPUT,
	--		@pIsLoopIUD = @IsLoopIUD OUTPUT,
	--		@pPrefixData = @PrefixString OUTPUT,
	--		@pSerialLen = @SerialLen OUTPUT

	
	IF ISNULL(@pMaterialLotNo, '') = '' -- MaterialLotNo 생성.
	BEGIN
	
			SELECT
					@IsFIFO = MSAI.IsFIFO
			FROM
					STB_MaterialStockAttributeInfo MSAI WITH (NOLOCK)
			WHERE
					MSAI.MaterialCode = @pMaterialCode
					
			IF ISNULL(@IsFIFO,0) = 0
			BEGIN
					SET @GRDate = ''
			END ELSE BEGIN
					SET @GRDate = CONVERT(VARCHAR(10), @pGRDate, 120)
			END
			
	


			SELECT
					@IsUseLotID = ISNULL(ML.IsUseLotID, 0)
			FROM
					STB_MaterialLocation ML WITH (NOLOCK)
			WHERE
					ML.MaterialLocationCode = @pMaterialLocationCode


			IF (ISNULL(@pLotID, '') = '') AND (@IsUseLotID = 0)
			BEGIN
					SET @pLotID = @pMaterialCode + ':' + @pMaterialLocationCode
			END

			
			IF ISNULL(@pPackingID,'') = ''
			BEGIN
					SET @PackingID = ISNULL(@pLotID,'')
			END ELSE BEGIN
					SET @PackingID = @pPackingID
			END		

			-- 2020-11-25 추가사항 
			SELECT
					@MaxKeyField = MAX(MaterialLotNo)
			FROM
					STB_MaterialLotInfo 
			WHERE
					MaterialLotNo LIKE @PrefixString + '%'
					
			IF @MaxKeyField IS NULL BEGIN
			    SET @MaterialLotNo = @PrefixString + RIGHT(REPLICATE('0',@SerialLen) + '1', @SerialLen)
			END ELSE BEGIN
			    SET @MaterialLotNo = @PrefixString + RIGHT(REPLICATE('0',@SerialLen) + CONVERT(VARCHAR, CONVERT(BIGINT, RIGHT(@MaxKeyField, LEN(@MaxKeyField) - LEN(@PrefixString))) + 1), @SerialLen)
			END
			-- 추가사항 끝

			EXEC SmartFramework.dbo.usp_DoCreateSerial	'STB_MaterialLotInfo',		@MaterialLotNo OUTPUT

			INSERT INTO STB_MaterialLotInfo
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
				InitialQty,
				CurrentQty,
				PickingQty,
				LotNO,			-- 2018-08-28 JGH VendorLotNo 추가
				VendorLotNo,
				IsSplitLot,
				ProductionDate,
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
				CreateUserID,
				CreateDateTime
			)
			VALUES
			(
				@MaterialLotNo,
				@pLotID,
				@pCompanyCode,
				@pWorkCenterCode,
				@pMaterialWarehouseCode,
				@pMaterialLocationCode,
				@pMaterialCode,
				@pMaterialStockAttribute,
				@pStockAttrib1,
				@pStockAttrib2,
				@pStockAttrib3,
				@PackingID,
				@GRDate,-- GRDate
				@pUsedQty,
				@pUsedQty,
				0,						-- PickingQty
				@LotNo,
				@VendorLotNo,			-- 2018-08-28 JGH VendorLotNo 추가
				0,						-- IsSplitLot
				GETDATE(),
				@LotAttr01,
				@LotAttr02,
				@LotAttr03,
				@LotAttr04,
				@LotAttr05,
				@LotAttr06,
				@LotAttr07,
				@LotAttr08,
				@LotAttr09,
				@LotAttr10,
				@pProcessUserID,
				GETDATE()
			)
			SET @pMaterialLotNo = @MaterialLotNo
			
			-- Cập nhật MarkingCode cho bảng STB_MaterialLotInfo từ bảng STB_MaterialDocLotInfo qua chỉ cho hà nam
			if(@pWorkCenterCode in ('VVT_F3'))
				begin
					update T1
					set T1.MarkingCode = T2.MarkingCode
					From
						STB_MaterialLotInfo T1
						inner join STB_MaterialDocLotInfo T2 on T1.PackingID = T2.PackingID
						where T2.PackingID=@PackingID
				end
			
	END ELSE BEGIN
			IF ISNULL(@pLotID,'') = '' -- 바코드 미사용인 경우
			BEGIN

			-- 2020-11-25 추가사항 
					SELECT
							@MaxKeyField = MAX(MaterialLotNo)
					FROM
							STB_MaterialLotInfo 
					WHERE
							MaterialLotNo LIKE @PrefixString + '%'
							
					IF @MaxKeyField IS NULL BEGIN
					    SET @MaterialLotNo = @PrefixString + RIGHT(REPLICATE('0',@SerialLen) + '1', @SerialLen)
					END ELSE BEGIN
					    SET @MaterialLotNo = @PrefixString + RIGHT(REPLICATE('0',@SerialLen) + CONVERT(VARCHAR, CONVERT(BIGINT, RIGHT(@MaxKeyField, LEN(@MaxKeyField) - LEN(@PrefixString))) + 1), @SerialLen)
					END			
          -- 추가사항 End

					EXEC SmartFramework.dbo.usp_DoCreateSerial	'STB_MaterialLotInfo',			@MaterialLotNo OUTPUT
					
					INSERT INTO [dbo].[STB_MaterialLotInfo]
					           ([MaterialLotNo]
					           ,[LotID]
					           ,[CompanyCode]
					           ,[WorkCenterCode]
					           ,[MaterialWarehouseCode]
					           ,[MaterialLocationCode]
					           ,[MaterialCode]
					           ,[MaterialStockAttribute]
					           ,[StockAttrib1]
					           ,[StockAttrib2]
					           ,[StockAttrib3]
					           ,[PackingID]
					           ,[GRDate]
					           ,[InitialQty]
					           ,[CurrentQty]
					           ,[PickingQty]
					           ,[VendorLotNo]
					           ,[LifeBasicDate]
					           ,[ProductionDate]
					           ,[EndOfLifeDate]
					           ,[LotNo]
					           ,[IsSplitLot]
					           ,[BefMaterialLotNo]
					           ,[CreateDateTime]
					           ,[CreateUserID])
					SELECT
							@MaterialLotNo AS MaterialLotNo
				           ,[LotID]
				           ,[CompanyCode]
				           ,[WorkCenterCode]
				           ,[MaterialWarehouseCode]
				           ,[MaterialLocationCode]
				           ,[MaterialCode]
				           ,[MaterialStockAttribute]
				           ,[StockAttrib1]
				           ,[StockAttrib2]
				           ,[StockAttrib3]
				           ,[PackingID]
				           ,[GRDate]
				           ,[InitialQty]
				           ,@pUsedQty AS [CurrentQty]
				           ,0 AS PickingQty
				           ,[VendorLotNo]
				           ,[LifeBasicDate]
				           ,[ProductionDate]
				           ,[EndOfLifeDate]
				           ,[LotNo]
				           ,1 AS [IsSplitLot]
				           ,@pMaterialLotNo AS [BefMaterialLotNo]
				           ,GETDATE()
				           ,@pProcessUserID
					FROM
							STB_MaterialLotSnapshot MLS
					WHERE
							MLS.MaterialLotNo = @pMaterialLotNo

								
			END ELSE BEGIN -- 바코드 사용 자재(LotID 있는)의 경우 MaterialLotNo 그대로 사용
					INSERT INTO [dbo].[STB_MaterialLotInfo]
					           ([MaterialLotNo]
					           ,[LotID]
					           ,[CompanyCode]
					           ,[WorkCenterCode]
					           ,[MaterialWarehouseCode]
					           ,[MaterialLocationCode]
					           ,[MaterialCode]
					           ,[MaterialStockAttribute]
					           ,[StockAttrib1]
					           ,[StockAttrib2]
					           ,[StockAttrib3]
					           ,[PackingID]
					           ,[GRDate]
					           ,[InitialQty]
					           ,[CurrentQty]
					           ,[PickingQty]
					           ,[VendorLotNo]
					           ,[LifeBasicDate]
					           ,[ProductionDate]
					           ,[EndOfLifeDate]
					           ,[LotNo]
					           ,[IsSplitLot]
					           ,[BefMaterialLotNo]
							   ,LotAttr01
							   ,LotAttr02
							   ,LotAttr03
							   ,LotAttr04
							   ,LotAttr05
							   ,LotAttr06
							   ,LotAttr07
							   ,LotAttr08
							   ,LotAttr09
							   ,LotAttr10
					           ,[CreateDateTime]
					           ,[CreateUserID])
					SELECT
							[MaterialLotNo]
				           ,[LotID]
				           ,[CompanyCode]
				           ,[WorkCenterCode]
				           ,[MaterialWarehouseCode]
				           ,[MaterialLocationCode]
				           ,[MaterialCode]
				           ,[MaterialStockAttribute]
				           ,[StockAttrib1]
				           ,[StockAttrib2]
				           ,[StockAttrib3]
				           ,[PackingID]
				           ,[GRDate]
				           ,[InitialQty]
				           ,@pUsedQty AS [CurrentQty]
				           ,0 AS PickingQty
				           ,[VendorLotNo]
				           ,[LifeBasicDate]
				           ,[ProductionDate]
				           ,[EndOfLifeDate]
				           ,[LotNo]
				           ,[IsSplitLot]
				           ,[BefMaterialLotNo]
							,LotAttr01
							,LotAttr02
							,LotAttr03
							,LotAttr04
							,LotAttr05
							,LotAttr06
							,LotAttr07
							,LotAttr08
							,LotAttr09
							,LotAttr10
				           ,GETDATE()
				           ,@pProcessUserID
					FROM
							STB_MaterialLotSnapshot MLS
					WHERE
							MLS.MaterialLotNo = @pMaterialLotNo 

					DELETE FROM STB_MaterialLotSnapshot
					WHERE 
							MaterialLotNo = @pMaterialLotNo
				
		END

	END
	    
END



