-- =============================================
-- Author:		Nguyễn Hải Triều
-- Create date: 2025-11-05
-- Description:	Cập nhật lại giá trị cấp của hàng JIANGHAI
-- =============================================
CREATE PROCEDURE [dbo].[usp_UpdateLevelJIANGHAI]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
    @pProcessViewName VARCHAR(50),
	@pXml NVARCHAR(MAX) = null
AS


BEGIN
	SET NOCOUNT ON;

	--set  @pProcessViewName  ='STB_MaterialLotInfo_test'
    DECLARE @ProcessUserID VARCHAR(20) = @pProcessUserID
    DECLARE @ProcessLanguage VARCHAR(20) = @pProcessLanguage
    DECLARE @ProcessViewName VARCHAR(50) = @pProcessViewName
    DECLARE @InsertTableName VARCHAR(100) =   '/DataSet/' +@ProcessViewName-- + '_INSERT'
    DECLARE @UpdateTableName VARCHAR(100) = '/DataSet/' + @ProcessViewName + '_UPDATE'
    DECLARE @DeleteTableName VARCHAR(100) = '/DataSet/' + @ProcessViewName + '_DELETE'
    DECLARE @ERROR_MSG NVARCHAR(MAX)
    DECLARE @IUD_FLAG VARCHAR(10)
    DECLARE @IsAutoKey BIT
    DECLARE @IsLoopIUD BIT
    DECLARE @PrefixString VARCHAR(20)
    DECLARE @SerialLen INT



--     --Declare Columns Variable
DECLARE @OldMaterialLotNo VARCHAR(20)
DECLARE @MaterialLotNo VARCHAR(20)
--DECLARE @LotID VARCHAR(50)
--DECLARE @CompanyCode VARCHAR(20)
--DECLARE @WorkCenterCode VARCHAR(20)
--DECLARE @MaterialWarehouseCode VARCHAR(20)
--DECLARE @MaterialWarehouseName VARCHAR(100)
--DECLARE @MaterialLocationCode VARCHAR(20)
--DECLARE @MaterialLocationName VARCHAR(100)
--DECLARE @MaterialCode VARCHAR(50)
--DECLARE @MaterialName VARCHAR(100)
--DECLARE @MaterialTypeCode VARCHAR(20)
--DECLARE @MaterialTypeName VARCHAR(100)
--DECLARE @ProductGroupCode VARCHAR(20)
--DECLARE @ProductGroupName VARCHAR(100)
--DECLARE @MaterialSpec VARCHAR(100)
--DECLARE @MaterialStockAttribute VARCHAR(20)
--DECLARE @StockAttrib1 VARCHAR(20)
--DECLARE @StockAttrib2 VARCHAR(20)
--DECLARE @StockAttrib3 VARCHAR(20)
--DECLARE @PackingID VARCHAR(50)
--DECLARE @GRDate VARCHAR(10)
--DECLARE @MaterialDeliveryNo VARCHAR(20)
--DECLARE @MaterialDeliveryDetailNo VARCHAR(20)
--DECLARE @InitialQty NUMERIC(20,5)
--DECLARE @CurrentQty NUMERIC(20,5)
--DECLARE @StockQty NUMERIC(20,5)
--DECLARE @PickingQty NUMERIC(20,5)
--DECLARE @AvailableQty NUMERIC(20,5)
--DECLARE @VendorLotNo VARCHAR(100)
--DECLARE @LifeBasicDate DATE
--DECLARE @ProductionDate DATE
--DECLARE @EndOfLifeDate DATE
--DECLARE @LotNo VARCHAR(500)
--DECLARE @IsSplitLot BIT
--DECLARE @SplitQty NUMERIC(20,5)
--DECLARE @BefMaterialLotNo VARCHAR(20)
--DECLARE @CreateDateTime DATETIME
--DECLARE @CreateUserID VARCHAR(20)
--DECLARE @ChangeDateTime DATETIME
--DECLARE @ChangeUserID VARCHAR(20)
--DECLARE @LabelType VARCHAR(50)
--DECLARE @LabelFormatName VARCHAR(100)
--DECLARE @CommandType VARCHAR(50)
--DECLARE @MaterialUnit VARCHAR(20)
--DECLARE @MMExtText02 VARCHAR(255)
--DECLARE @MMExtText03 VARCHAR(255)
--DECLARE @LotAttr10 NVARCHAR(100)
--DECLARE @PackDate DATE
--DECLARE @PackingIdParent VARCHAR(50)
			DECLARE @LotID VARCHAR(100) 
			DECLARE @LevelJIANGHAI VARCHAR(50)
			DECLARE @MaterialDocDetailNo VARCHAR(50) 

  
	
	DECLARE @iDoc INT

    EXEC SmartFramework.dbo.usp_GetSerialRule 
			@pTableName = 'STB_MaterialLotInfo',
			@pIsAutoKey = @IsAutoKey OUTPUT,
			@pIsLoopIUD = @IsLoopIUD OUTPUT,
			@pPrefixData = @PrefixString OUTPUT,
			@pSerialLen = @SerialLen OUTPUT





--	---------------------------------------------------------------------------------------------------------------------------------
--EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml

--		SELECT
--					@LotID=	LotID,
--					@StartPeriod =	StartPeriod
--		FROM
--				OPENXML(@idoc , @UpdateTableName , 2)
--				WITH  (
				
--					StartPeriod VARCHAR(100) ,
--					LotID VARCHAR(100) 		
--						) 
--				INSERT INTO test1234 (LotID)
--				VALUES (@LotID) 
					
--					--UPDATE STB_MaterialDocLotInfo  
--					--	 SET   LotAttr10 = @StartPeriod
--					--	 where  LotID = @LotID 
							  
						
--				 --UPDATE STB_MaterialLotInfo  
--				 --SET      LotAttr10 = @StartPeriod
--					-- where  LotID = @LotID 
				 

--EXEC sp_xml_removedocument @idoc
--return

--select * from test1234


	---------------------------------------------------------------------------------------------------------------------------
       DECLARE @NewLotID VARCHAR(50)
    IF @IsAutoKey = 0 AND @IsLoopIUD = 0 BEGIN

	print '123'
--		EXEC SmartFramework.dbo.usp_DoCreateSerial	'STB_MaterialDocLotInfo', @NewLotID OUTPUT
		
--		set @LotID ='SL' + SUBSTRING(@NewLotID, 3, LEN(@NewLotID) - 2) 	
--		set @PackingID ='SL' + SUBSTRING(@NewLotID, 3, LEN(@NewLotID) - 2) 	

--	    EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
	
--	    BEGIN TRY
--		-- Process Insert Table
--			MERGE STB_MaterialLotInfo_test AS TargetTable
--USING
--	(
--		SELECT
--				CASE
--				    WHEN OldMaterialLotNo IS NULL THEN MaterialLotNo
--				    ELSE OldMaterialLotNo
--				END AS OldMaterialLotNo,
--				MaterialLotNo,
--				LotID,
--				CompanyCode,
--				WorkCenterCode,
--				MaterialWarehouseCode,
--				MaterialWarehouseName,
--				MaterialLocationCode,
--				MaterialLocationName,
--				MaterialCode,
--				MaterialName,
--				MaterialTypeCode,
--				MaterialTypeName,
--				ProductGroupCode,
--				ProductGroupName,
--				MaterialSpec,
--				MaterialStockAttribute,
--				StockAttrib1,
--				StockAttrib2,
--				StockAttrib3,
--				PackingID,
--				GRDate,
--				MaterialDeliveryNo,
--				MaterialDeliveryDetailNo,
--				InitialQty,
--				CurrentQty,
--				StockQty,
--				PickingQty,
--				AvailableQty,
--				VendorLotNo,
--				LifeBasicDate,
--				ProductionDate,
--				EndOfLifeDate,
--				LotNo,
--				IsSplitLot,
--				SplitQty,
--				BefMaterialLotNo,
--				GETDATE() AS CreateDateTime,
--				@pProcessUserID AS CreateUserID,
--				GETDATE() AS ChangeDateTime,
--				@pProcessUserID AS ChangeUserID,
--				LabelType,
--				LabelFormatName,
--				CommandType,
--				MaterialUnit,
--				MMExtText02,
--				MMExtText03,
--				LotAttr10,
--				PackDate,
--				PackingIdParent
--		FROM
--				OPENXML(@idoc , @InsertTableName , 2)
--				WITH  (
--							OldMaterialLotNo VARCHAR(20),
--							MaterialLotNo VARCHAR(20),
--							LotID VARCHAR(50),
--							CompanyCode VARCHAR(20),
--							WorkCenterCode VARCHAR(20),
--							MaterialWarehouseCode VARCHAR(20),
--							MaterialWarehouseName VARCHAR(100),
--							MaterialLocationCode VARCHAR(20),
--							MaterialLocationName VARCHAR(100),
--							MaterialCode VARCHAR(50),
--							MaterialName VARCHAR(100),
--							MaterialTypeCode VARCHAR(20),
--							MaterialTypeName VARCHAR(100),
--							ProductGroupCode VARCHAR(20),
--							ProductGroupName VARCHAR(100),
--							MaterialSpec VARCHAR(100),
--							MaterialStockAttribute VARCHAR(20),
--							StockAttrib1 VARCHAR(20),
--							StockAttrib2 VARCHAR(20),
--							StockAttrib3 VARCHAR(20),
--							PackingID VARCHAR(50),
--							GRDate VARCHAR(10),
--							MaterialDeliveryNo VARCHAR(20),
--							MaterialDeliveryDetailNo VARCHAR(20),
--							InitialQty NUMERIC(20,5),
--							CurrentQty NUMERIC(20,5),
--							StockQty NUMERIC(20,5),
--							PickingQty NUMERIC(20,5),
--							AvailableQty NUMERIC(20,5),
--							VendorLotNo VARCHAR(100),
--							LifeBasicDate DATETIMEOFFSET,
--							ProductionDate DATETIMEOFFSET,
--							EndOfLifeDate DATETIMEOFFSET,
--							LotNo VARCHAR(500),
--							IsSplitLot BIT,
--							SplitQty NUMERIC(20,5),
--							BefMaterialLotNo VARCHAR(20),
--							CreateDateTime DATETIMEOFFSET,
--							CreateUserID VARCHAR(20),
--							ChangeDateTime DATETIMEOFFSET,
--							ChangeUserID VARCHAR(20),
--							LabelType VARCHAR(50),
--							LabelFormatName VARCHAR(100),
--							CommandType VARCHAR(50),
--							MaterialUnit VARCHAR(20),
--							MMExtText02 VARCHAR(255),
--							MMExtText03 VARCHAR(255),
--							LotAttr10 NVARCHAR(100),
--							PackDate DATE,
--							PackingIdParent VARCHAR(50)
--						) 
--	) AS SourceTable
--ON
--	(
--		TargetTable.MaterialLotNo = SourceTable.MaterialLotNo
--	)

--WHEN MATCHED THEN
--	UPDATE SET
--		MaterialLotNo = ISNULL(SourceTable.MaterialLotNo,TargetTable.MaterialLotNo),
--		LotID = ISNULL(SourceTable.LotID,TargetTable.LotID),
--		CompanyCode = ISNULL(SourceTable.CompanyCode,TargetTable.CompanyCode),
--		WorkCenterCode = ISNULL(SourceTable.WorkCenterCode,TargetTable.WorkCenterCode),
--		MaterialWarehouseCode = ISNULL(SourceTable.MaterialWarehouseCode,TargetTable.MaterialWarehouseCode),
--		MaterialWarehouseName = ISNULL(SourceTable.MaterialWarehouseName,TargetTable.MaterialWarehouseName),
--		MaterialLocationCode = ISNULL(SourceTable.MaterialLocationCode,TargetTable.MaterialLocationCode),
--		MaterialLocationName = ISNULL(SourceTable.MaterialLocationName,TargetTable.MaterialLocationName),
--		MaterialCode = ISNULL(SourceTable.MaterialCode,TargetTable.MaterialCode),
--		MaterialName = ISNULL(SourceTable.MaterialName,TargetTable.MaterialName),
--		MaterialTypeCode = ISNULL(SourceTable.MaterialTypeCode,TargetTable.MaterialTypeCode),
--		MaterialTypeName = ISNULL(SourceTable.MaterialTypeName,TargetTable.MaterialTypeName),
--		ProductGroupCode = ISNULL(SourceTable.ProductGroupCode,TargetTable.ProductGroupCode),
--		ProductGroupName = ISNULL(SourceTable.ProductGroupName,TargetTable.ProductGroupName),
--		MaterialSpec = ISNULL(SourceTable.MaterialSpec,TargetTable.MaterialSpec),
--		MaterialStockAttribute = ISNULL(SourceTable.MaterialStockAttribute,TargetTable.MaterialStockAttribute),
--		StockAttrib1 = ISNULL(SourceTable.StockAttrib1,TargetTable.StockAttrib1),
--		StockAttrib2 = ISNULL(SourceTable.StockAttrib2,TargetTable.StockAttrib2),
--		StockAttrib3 = ISNULL(SourceTable.StockAttrib3,TargetTable.StockAttrib3),
--		PackingID = ISNULL(SourceTable.PackingID,TargetTable.PackingID),
--		GRDate = ISNULL(SourceTable.GRDate,TargetTable.GRDate),
--		MaterialDeliveryNo = ISNULL(SourceTable.MaterialDeliveryNo,TargetTable.MaterialDeliveryNo),
--		MaterialDeliveryDetailNo = ISNULL(SourceTable.MaterialDeliveryDetailNo,TargetTable.MaterialDeliveryDetailNo),
--		InitialQty = ISNULL(SourceTable.InitialQty,TargetTable.InitialQty),
--		CurrentQty = ISNULL(SourceTable.CurrentQty,TargetTable.CurrentQty),
--		StockQty = ISNULL(SourceTable.StockQty,TargetTable.StockQty),
--		PickingQty = ISNULL(SourceTable.PickingQty,TargetTable.PickingQty),
--		AvailableQty = ISNULL(SourceTable.AvailableQty,TargetTable.AvailableQty),
--		VendorLotNo = ISNULL(SourceTable.VendorLotNo,TargetTable.VendorLotNo),
--		LifeBasicDate = ISNULL(SourceTable.LifeBasicDate,TargetTable.LifeBasicDate),
--		ProductionDate = ISNULL(SourceTable.ProductionDate,TargetTable.ProductionDate),
--		EndOfLifeDate = ISNULL(SourceTable.EndOfLifeDate,TargetTable.EndOfLifeDate),
--		LotNo = ISNULL(SourceTable.LotNo,TargetTable.LotNo),
--		IsSplitLot = ISNULL(SourceTable.IsSplitLot,TargetTable.IsSplitLot),
--		SplitQty = ISNULL(SourceTable.SplitQty,TargetTable.SplitQty),
--		BefMaterialLotNo = ISNULL(SourceTable.BefMaterialLotNo,TargetTable.BefMaterialLotNo),
--		LabelType = ISNULL(SourceTable.LabelType,TargetTable.LabelType),
--		LabelFormatName = ISNULL(SourceTable.LabelFormatName,TargetTable.LabelFormatName),
--		CommandType = ISNULL(SourceTable.CommandType,TargetTable.CommandType),
--		MaterialUnit = ISNULL(SourceTable.MaterialUnit,TargetTable.MaterialUnit),
--		MMExtText02 = ISNULL(SourceTable.MMExtText02,TargetTable.MMExtText02),
--		MMExtText03 = ISNULL(SourceTable.MMExtText03,TargetTable.MMExtText03),
--		LotAttr10 = ISNULL(SourceTable.LotAttr10,TargetTable.LotAttr10),
--		ChangeDateTime = ISNULL(SourceTable.ChangeDateTime,TargetTable.ChangeDateTime),
--		ChangeUserID = ISNULL(SourceTable.ChangeUserID,TargetTable.ChangeUserID),
--		PackingIdParent = ISNULL(SourceTable.PackingIdParent,TargetTable.PackingIdParent)

--WHEN NOT MATCHED THEN
--	INSERT
--		(
--			MaterialLotNo,
--			LotID,
--			CompanyCode,
--			WorkCenterCode,
--			MaterialWarehouseCode,
--			MaterialWarehouseName,
--			MaterialLocationCode,
--			MaterialLocationName,
--			MaterialCode,
--			MaterialName,
--			MaterialTypeCode,
--			MaterialTypeName,
--			ProductGroupCode,
--			ProductGroupName,
--			MaterialSpec,
--			MaterialStockAttribute,
--			StockAttrib1,
--			StockAttrib2,
--			StockAttrib3,
--			PackingID,
--			GRDate,
--			MaterialDeliveryNo,
--			MaterialDeliveryDetailNo,
--			InitialQty,
--			CurrentQty,
--			StockQty,
--			PickingQty,
--			AvailableQty,
--			VendorLotNo,
--			LifeBasicDate,
--			ProductionDate,
--			EndOfLifeDate,
--			LotNo,
--			IsSplitLot,
--			SplitQty,
--			BefMaterialLotNo,
--			LabelType,
--			LabelFormatName,
--			CommandType,
--			MaterialUnit,
--			MMExtText02,
--			MMExtText03,
--			LotAttr10,
--			CreateDateTime,
--			CreateUserID,
--			PackingIdParent
--		)
--	VALUES
--		(
--			SourceTable.MaterialLotNo,
--			SourceTable.LotID,
--			SourceTable.CompanyCode,
--			SourceTable.WorkCenterCode,
--			SourceTable.MaterialWarehouseCode,
--			SourceTable.MaterialWarehouseName,
--			SourceTable.MaterialLocationCode,
--			SourceTable.MaterialLocationName,
--			SourceTable.MaterialCode,
--			SourceTable.MaterialName,
--			SourceTable.MaterialTypeCode,
--			SourceTable.MaterialTypeName,
--			SourceTable.ProductGroupCode,
--			SourceTable.ProductGroupName,
--			SourceTable.MaterialSpec,
--			SourceTable.MaterialStockAttribute,
--			SourceTable.StockAttrib1,
--			SourceTable.StockAttrib2,
--			SourceTable.StockAttrib3,
--			SourceTable.PackingID,
--			SourceTable.GRDate,
--			SourceTable.MaterialDeliveryNo,
--			SourceTable.MaterialDeliveryDetailNo,
--			SourceTable.InitialQty,
--			SourceTable.CurrentQty,
--			SourceTable.StockQty,
--			SourceTable.PickingQty,
--			SourceTable.AvailableQty,
--			SourceTable.VendorLotNo,
--			SourceTable.LifeBasicDate,
--			SourceTable.ProductionDate,
--			SourceTable.EndOfLifeDate,
--			SourceTable.LotNo,
--			SourceTable.IsSplitLot,
--			SourceTable.SplitQty,
--			SourceTable.BefMaterialLotNo,
--			SourceTable.LabelType,
--			SourceTable.LabelFormatName,
--			SourceTable.CommandType,
--			SourceTable.MaterialUnit,
--			SourceTable.MMExtText02,
--			SourceTable.MMExtText03,
--			SourceTable.LotAttr10,
--			SourceTable.CreateDateTime,
--			SourceTable.CreateUserID,
--			SourceTable.PackingIdParent
--		);



--		-- Process Update Table
--MERGE STB_MaterialLotInfo_test AS TargetTable
--USING
--    (
--        SELECT
--            CASE
--                WHEN OldMaterialLotNo IS NULL THEN MaterialLotNo
--                ELSE OldMaterialLotNo
--            END AS OldMaterialLotNo,
--            MaterialLotNo,
--            LotID,
--            CompanyCode,
--            WorkCenterCode,
--            MaterialWarehouseCode,
--            MaterialWarehouseName,
--            MaterialLocationCode,
--            MaterialLocationName,
--            MaterialCode,
--            MaterialName,
--            MaterialTypeCode,
--            MaterialTypeName,
--            ProductGroupCode,
--            ProductGroupName,
--            MaterialSpec,
--            MaterialStockAttribute,
--            StockAttrib1,
--            StockAttrib2,
--            StockAttrib3,
--            PackingID,
--            GRDate,
--            MaterialDeliveryNo,
--            MaterialDeliveryDetailNo,
--            InitialQty,
--            CurrentQty,
--            StockQty,
--            PickingQty,
--            AvailableQty,
--            VendorLotNo,
--            LifeBasicDate,
--            ProductionDate,
--            EndOfLifeDate,
--            LotNo,
--            IsSplitLot,
--            SplitQty,
--            BefMaterialLotNo,
--            CreateDateTime,
--            CreateUserID,
--            ChangeDateTime,
--            ChangeUserID,
--            LabelType,
--            LabelFormatName,
--            CommandType,
--            MaterialUnit,
--            MMExtText02,
--            MMExtText03,
--            LotAttr10,
--            PackDate,
--            PackingIdParent,
--            GETDATE() AS CreateDateTime,
--            @pProcessUserID AS CreateUserID,
--            GETDATE() AS ChangeDateTime,
--            @pProcessUserID AS ChangeUserID
--        FROM
--            OPENXML(@idoc , @UpdateTableName , 2)
--            WITH (
--                OldMaterialLotNo VARCHAR(20),
--                MaterialLotNo VARCHAR(20),
--                LotID VARCHAR(50),
--                CompanyCode VARCHAR(20),
--                WorkCenterCode VARCHAR(20),
--                MaterialWarehouseCode VARCHAR(20),
--                MaterialWarehouseName VARCHAR(100),
--                MaterialLocationCode VARCHAR(20),
--                MaterialLocationName VARCHAR(100),
--                MaterialCode VARCHAR(50),
--                MaterialName VARCHAR(100),
--                MaterialTypeCode VARCHAR(20),
--                MaterialTypeName VARCHAR(100),
--                ProductGroupCode VARCHAR(20),
--                ProductGroupName VARCHAR(100),
--                MaterialSpec VARCHAR(100),
--                MaterialStockAttribute VARCHAR(20),
--                StockAttrib1 VARCHAR(20),
--                StockAttrib2 VARCHAR(20),
--                StockAttrib3 VARCHAR(20),
--                PackingID VARCHAR(50),
--                GRDate VARCHAR(10),
--                MaterialDeliveryNo VARCHAR(20),
--                MaterialDeliveryDetailNo VARCHAR(20),
--                InitialQty NUMERIC(20,5),
--                CurrentQty NUMERIC(20,5),
--                StockQty NUMERIC(20,5),
--                PickingQty NUMERIC(20,5),
--                AvailableQty NUMERIC(20,5),
--                VendorLotNo VARCHAR(100),
--                LifeBasicDate DATETIMEOFFSET,
--                ProductionDate DATETIMEOFFSET,
--                EndOfLifeDate DATETIMEOFFSET,
--                LotNo VARCHAR(500),
--                IsSplitLot BIT,
--                SplitQty NUMERIC(20,5),
--                BefMaterialLotNo VARCHAR(20),
--                CreateDateTime DATETIMEOFFSET,
--                CreateUserID VARCHAR(20),
--                ChangeDateTime DATETIMEOFFSET,
--                ChangeUserID VARCHAR(20),
--                LabelType VARCHAR(50),
--                LabelFormatName VARCHAR(100),
--                CommandType VARCHAR(50),
--                MaterialUnit VARCHAR(20),
--                MMExtText02 VARCHAR(255),
--                MMExtText03 VARCHAR(255),
--                LotAttr10 NVARCHAR(100),
--                PackDate DATE,
--                PackingIdParent VARCHAR(50)
--            )
--    ) AS SourceTable
--ON
--    (
--        TargetTable.MaterialLotNo = SourceTable.OldMaterialLotNo
--    )

--WHEN MATCHED THEN
--    UPDATE SET
--        MaterialLotNo = ISNULL(SourceTable.MaterialLotNo, TargetTable.MaterialLotNo),
--        LotID = ISNULL(SourceTable.LotID, TargetTable.LotID),
--        CompanyCode = ISNULL(SourceTable.CompanyCode, TargetTable.CompanyCode),
--        WorkCenterCode = ISNULL(SourceTable.WorkCenterCode, TargetTable.WorkCenterCode),
--        MaterialWarehouseCode = ISNULL(SourceTable.MaterialWarehouseCode, TargetTable.MaterialWarehouseCode),
--        MaterialWarehouseName = ISNULL(SourceTable.MaterialWarehouseName, TargetTable.MaterialWarehouseName),
--        MaterialLocationCode = ISNULL(SourceTable.MaterialLocationCode, TargetTable.MaterialLocationCode),
--        MaterialLocationName = ISNULL(SourceTable.MaterialLocationName, TargetTable.MaterialLocationName),
--        MaterialCode = ISNULL(SourceTable.MaterialCode, TargetTable.MaterialCode),
--        MaterialName = ISNULL(SourceTable.MaterialName, TargetTable.MaterialName),
--        MaterialTypeCode = ISNULL(SourceTable.MaterialTypeCode, TargetTable.MaterialTypeCode),
--        MaterialTypeName = ISNULL(SourceTable.MaterialTypeName, TargetTable.MaterialTypeName),
--        ProductGroupCode = ISNULL(SourceTable.ProductGroupCode, TargetTable.ProductGroupCode),
--        ProductGroupName = ISNULL(SourceTable.ProductGroupName, TargetTable.ProductGroupName),
--        MaterialSpec = ISNULL(SourceTable.MaterialSpec, TargetTable.MaterialSpec),
--        MaterialStockAttribute = ISNULL(SourceTable.MaterialStockAttribute, TargetTable.MaterialStockAttribute),
--        StockAttrib1 = ISNULL(SourceTable.StockAttrib1, TargetTable.StockAttrib1),
--        StockAttrib2 = ISNULL(SourceTable.StockAttrib2, TargetTable.StockAttrib2),
--        StockAttrib3 = ISNULL(SourceTable.StockAttrib3, TargetTable.StockAttrib3),
--        PackingID = ISNULL(SourceTable.PackingID, TargetTable.PackingID),
--        GRDate = ISNULL(SourceTable.GRDate, TargetTable.GRDate),
--        MaterialDeliveryNo = ISNULL(SourceTable.MaterialDeliveryNo, TargetTable.MaterialDeliveryNo),
--        MaterialDeliveryDetailNo = ISNULL(SourceTable.MaterialDeliveryDetailNo, TargetTable.MaterialDeliveryDetailNo),
--        InitialQty = ISNULL(SourceTable.InitialQty, TargetTable.InitialQty),
--        CurrentQty = ISNULL(SourceTable.CurrentQty, TargetTable.CurrentQty),
--        StockQty = ISNULL(SourceTable.StockQty, TargetTable.StockQty),
--        PickingQty = ISNULL(SourceTable.PickingQty, TargetTable.PickingQty),
--        AvailableQty = ISNULL(SourceTable.AvailableQty, TargetTable.AvailableQty),
--        VendorLotNo = ISNULL(SourceTable.VendorLotNo, TargetTable.VendorLotNo),
--        LifeBasicDate = ISNULL(SourceTable.LifeBasicDate, TargetTable.LifeBasicDate),
--        ProductionDate = ISNULL(SourceTable.ProductionDate, TargetTable.ProductionDate),
--        EndOfLifeDate = ISNULL(SourceTable.EndOfLifeDate, TargetTable.EndOfLifeDate),
--        LotNo = ISNULL(SourceTable.LotNo, TargetTable.LotNo),
--        IsSplitLot = ISNULL(SourceTable.IsSplitLot, TargetTable.IsSplitLot),
--        SplitQty = ISNULL(SourceTable.SplitQty, TargetTable.SplitQty),
--        BefMaterialLotNo = ISNULL(SourceTable.BefMaterialLotNo, TargetTable.BefMaterialLotNo),
--        CreateDateTime = ISNULL(SourceTable.CreateDateTime, TargetTable.CreateDateTime),
--        CreateUserID = ISNULL(SourceTable.CreateUserID, TargetTable.CreateUserID),
--        ChangeDateTime = ISNULL(SourceTable.ChangeDateTime, TargetTable.ChangeDateTime),
--        ChangeUserID = ISNULL(SourceTable.ChangeUserID, TargetTable.ChangeUserID),
--        LabelType = ISNULL(SourceTable.LabelType, TargetTable.LabelType),
--        LabelFormatName = ISNULL(SourceTable.LabelFormatName, TargetTable.LabelFormatName),
--        CommandType = ISNULL(SourceTable.CommandType, TargetTable.CommandType),
--        MaterialUnit = ISNULL(SourceTable.MaterialUnit, TargetTable.MaterialUnit),
--        MMExtText02 = ISNULL(SourceTable.MMExtText02, TargetTable.MMExtText02),
--        MMExtText03 = ISNULL(SourceTable.MMExtText03, TargetTable.MMExtText03),
--        LotAttr10 = ISNULL(SourceTable.LotAttr10, TargetTable.LotAttr10),
--        PackDate = ISNULL(SourceTable.PackDate, TargetTable.PackDate),
--        PackingIdParent = ISNULL(SourceTable.PackingIdParent, TargetTable.PackingIdParent)

--WHEN NOT MATCHED THEN
--    INSERT
--        (
--            MaterialLotNo,
--            LotID,
--            CompanyCode,
--            WorkCenterCode,
--            MaterialWarehouseCode,
--            MaterialWarehouseName,
--            MaterialLocationCode,
--            MaterialLocationName,
--            MaterialCode,
--            MaterialName,
--            MaterialTypeCode,
--            MaterialTypeName,
--            ProductGroupCode,
--            ProductGroupName,
--            MaterialSpec,
--            MaterialStockAttribute,
--            StockAttrib1,
--            StockAttrib2,
--            StockAttrib3,
--            PackingID,
--            GRDate,
--            MaterialDeliveryNo,
--            MaterialDeliveryDetailNo,
--            InitialQty,
--            CurrentQty,
--            StockQty,
--            PickingQty,
--            AvailableQty,
--            VendorLotNo,
--            LifeBasicDate,
--            ProductionDate,
--            EndOfLifeDate,
--            LotNo,
--            IsSplitLot,
--            SplitQty,
--            BefMaterialLotNo,
--            CreateDateTime,
--            CreateUserID,
--            ChangeDateTime,
--            ChangeUserID,
--            LabelType,
--            LabelFormatName,
--            CommandType,
--            MaterialUnit,
--            MMExtText02,
--            MMExtText03,
--            LotAttr10,
--            PackDate,
--            PackingIdParent
--        )
--    VALUES
--        (
--            SourceTable.MaterialLotNo,
--            SourceTable.LotID,
--            SourceTable.CompanyCode,
--            SourceTable.WorkCenterCode,
--            SourceTable.MaterialWarehouseCode,
--            SourceTable.MaterialWarehouseName,
--            SourceTable.MaterialLocationCode,
--            SourceTable.MaterialLocationName,
--            SourceTable.MaterialCode,
--            SourceTable.MaterialName,
--            SourceTable.MaterialTypeCode,
--            SourceTable.MaterialTypeName,
--            SourceTable.ProductGroupCode,
--            SourceTable.ProductGroupName,
--            SourceTable.MaterialSpec,
--            SourceTable.MaterialStockAttribute,
--            SourceTable.StockAttrib1,
--            SourceTable.StockAttrib2,
--            SourceTable.StockAttrib3,
--            SourceTable.PackingID,
--            SourceTable.GRDate,
--            SourceTable.MaterialDeliveryNo,
--            SourceTable.MaterialDeliveryDetailNo,
--            SourceTable.InitialQty,
--            SourceTable.CurrentQty,
--            SourceTable.StockQty,
--            SourceTable.PickingQty,
--            SourceTable.AvailableQty,
--            SourceTable.VendorLotNo,
--            SourceTable.LifeBasicDate,
--            SourceTable.ProductionDate,
--            SourceTable.EndOfLifeDate,
--            SourceTable.LotNo,
--            SourceTable.IsSplitLot,
--            SourceTable.SplitQty,
--            SourceTable.BefMaterialLotNo,
--            SourceTable.CreateDateTime,
--            SourceTable.CreateUserID,
--            SourceTable.ChangeDateTime,
--            SourceTable.ChangeUserID,
--            SourceTable.LabelType,
--            SourceTable.LabelFormatName,
--            SourceTable.CommandType,
--            SourceTable.MaterialUnit,
--            SourceTable.MMExtText02,
--            SourceTable.MMExtText03,
--            SourceTable.LotAttr10,
--            SourceTable.PackDate,
--            SourceTable.PackingIdParent
--        );



--			-- Process Delete Table
--MERGE STB_MaterialLotInfo_test AS TargetTable
--USING
--    (
--        SELECT
--            CASE
--                WHEN OldMaterialLotNo IS NULL THEN MaterialLotNo
--                ELSE OldMaterialLotNo
--            END AS OldMaterialLotNo,
--            MaterialLotNo,
--            LotID,
--            CompanyCode,
--            WorkCenterCode,
--            MaterialWarehouseCode,
--            MaterialWarehouseName,
--            MaterialLocationCode,
--            MaterialLocationName,
--            MaterialCode,
--            MaterialName,
--            MaterialTypeCode,
--            MaterialTypeName,
--            ProductGroupCode,
--            ProductGroupName,
--            MaterialSpec,
--            MaterialStockAttribute,
--            StockAttrib1,
--            StockAttrib2,
--            StockAttrib3,
--            PackingID,
--            GRDate,
--            MaterialDeliveryNo,
--            MaterialDeliveryDetailNo,
--            InitialQty,
--            CurrentQty,
--            StockQty,
--            PickingQty,
--            AvailableQty,
--            VendorLotNo,
--            LifeBasicDate,
--            ProductionDate,
--            EndOfLifeDate,
--            LotNo,
--            IsSplitLot,
--            SplitQty,
--            BefMaterialLotNo,
--            CreateDateTime,
--            CreateUserID,
--            ChangeDateTime,
--            ChangeUserID,
--            LabelType,
--            LabelFormatName,
--            CommandType,
--            MaterialUnit,
--            MMExtText02,
--            MMExtText03,
--            LotAttr10,
--            PackDate,
--            PackingIdParent,
--            GETDATE() AS ChangeDateTime,
--            @pProcessUserID AS ChangeUserID
--        FROM
--            OPENXML(@idoc , @DeleteTableName , 2)
--            WITH  (
--                OldMaterialLotNo VARCHAR(20),
--                MaterialLotNo VARCHAR(20),
--                LotID VARCHAR(50),
--                CompanyCode VARCHAR(20),
--                WorkCenterCode VARCHAR(20),
--                MaterialWarehouseCode VARCHAR(20),
--                MaterialWarehouseName VARCHAR(100),
--                MaterialLocationCode VARCHAR(20),
--                MaterialLocationName VARCHAR(100),
--                MaterialCode VARCHAR(50),
--                MaterialName VARCHAR(100),
--                MaterialTypeCode VARCHAR(20),
--                MaterialTypeName VARCHAR(100),
--                ProductGroupCode VARCHAR(20),
--                ProductGroupName VARCHAR(100),
--                MaterialSpec VARCHAR(100),
--                MaterialStockAttribute VARCHAR(20),
--                StockAttrib1 VARCHAR(20),
--                StockAttrib2 VARCHAR(20),
--                StockAttrib3 VARCHAR(20),
--                PackingID VARCHAR(50),
--                GRDate VARCHAR(10),
--                MaterialDeliveryNo VARCHAR(20),
--                MaterialDeliveryDetailNo VARCHAR(20),
--                InitialQty NUMERIC(20,5),
--                CurrentQty NUMERIC(20,5),
--                StockQty NUMERIC(20,5),
--                PickingQty NUMERIC(20,5),
--                AvailableQty NUMERIC(20,5),
--                VendorLotNo VARCHAR(100),
--                LifeBasicDate DATETIMEOFFSET,
--                ProductionDate DATETIMEOFFSET,
--                EndOfLifeDate DATETIMEOFFSET,
--                LotNo VARCHAR(500),
--                IsSplitLot BIT,
--                SplitQty NUMERIC(20,5),
--                BefMaterialLotNo VARCHAR(20),
--                CreateDateTime DATETIMEOFFSET,
--                CreateUserID VARCHAR(20),
--                ChangeDateTime DATETIMEOFFSET,
--                ChangeUserID VARCHAR(20),
--                LabelType VARCHAR(50),
--                LabelFormatName VARCHAR(100),
--                CommandType VARCHAR(50),
--                MaterialUnit VARCHAR(20),
--                MMExtText02 VARCHAR(255),
--                MMExtText03 VARCHAR(255),
--                LotAttr10 NVARCHAR(100),
--                PackDate DATE,
--                PackingIdParent VARCHAR(50)
--            )
--    ) AS SourceTable
--ON
--    (
--        TargetTable.MaterialLotNo = SourceTable.MaterialLotNo
--    )

--WHEN MATCHED THEN
--    DELETE;


--        END TRY
--	    BEGIN CATCH
--            SET @ERROR_MSG = ERROR_MESSAGE()
--			RAISERROR( @ERROR_MSG ,16, 1)
--	    END CATCH
		
--	    EXEC sp_xml_removedocument @idoc

    END ELSE BEGIN
        EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
        
        BEGIN TRY
		    DECLARE SourceData CURSOR FOR
     
								
						SELECT
								'UPDATE' AS IUD_FLAG,
								CASE 
									WHEN OldMaterialLotNo IS NULL THEN MaterialLotNo
									ELSE OldMaterialLotNo
								END AS OldMaterialLotNo,
									MaterialLotNo,
									LotID,
									LevelJIANGHAI
								
							FROM
								OPENXML(@idoc, @UpdateTableName, 2)
								WITH  (
									OldMaterialLotNo VARCHAR(20),
									MaterialLotNo VARCHAR(20),
									LotID VARCHAR(50),
									LevelJIANGHAI VARCHAR(50)
								)

							



            OPEN SourceData

           WHILE 1 = 1
				BEGIN
					-- Fetch the next record into the variables
					FETCH NEXT FROM SourceData INTO
						@IUD_FLAG,
									@OldMaterialLotNo,
									@MaterialLotNo,
									@LotID,
									@LevelJIANGHAI

				
			 
		

                IF @@FETCH_STATUS <> 0 BEGIN
					BREAK
				END
                IF @IUD_FLAG = 'INSERT' BEGIN

     --               IF EXISTS (SELECT 1 FROM STB_MaterialLotInfo WHERE MaterialLotNo = @MaterialLotNo) BEGIN
					--	RAISERROR('Duplicate Data : KeyField = %s', 16, 1, @MaterialLotNo)
					--END

     --               IF @IsAutoKey = 1 BEGIN
     --                   EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_MaterialLotInfo',@MaterialLotNo OUTPUT
     --               END
                    
					--EXEC SmartFramework.dbo.usp_DoCreateSerial	'STB_MaterialDocLotInfo', @NewLotID OUTPUT
					--set @LotID ='SL' + SUBSTRING(@NewLotID, 3, LEN(@NewLotID) - 2) 	
					--set @PackingID ='SL' + SUBSTRING(@NewLotID, 3, LEN(@NewLotID) - 2) 	

					--select @LotAttr10 =LotAttr10   from STB_MaterialLotInfo where  PackingID =  @PackingIdParent

					
				------	select * from STB_MaterialLotInfo_test
				--	 --raiserror(@LotAttr10,16,1)
    --              INSERT INTO STB_MaterialLotInfo
				--				(
				--					MaterialLotNo,
				--					LotID,
				--					CompanyCode,
				--					WorkCenterCode,
				--					MaterialWarehouseCode,
				--					MaterialLocationCode,	
				--					MaterialCode,			
				--					MaterialStockAttribute,
				--					StockAttrib1,
				--					StockAttrib2,
				--					StockAttrib3,
				--					PackingID,
				--					GRDate,
				--					MaterialDeliveryNo,
				--					MaterialDeliveryDetailNo,
				--					InitialQty,
				--					CurrentQty,
				--					PickingQty,
				--					VendorLotNo,
				--					LifeBasicDate,
				--					ProductionDate,
				--					EndOfLifeDate,
				--					LotNo,
				--					IsSplitLot,
				--					BefMaterialLotNo,
				--					CreateDateTime,
				--					CreateUserID,
				--					PackingIdParent,
				--					LotAttr10
							
				--				)
				--				VALUES
				--				(
								
				--					@MaterialLotNo,
				--					@LotID,
				--					@CompanyCode,
				--					@WorkCenterCode,
				--					@MaterialWarehouseCode,
				--					@MaterialLocationCode,
				--					@MaterialCode,
				--					@MaterialStockAttribute,
				--					@StockAttrib1,
				--					@StockAttrib2,
				--					@StockAttrib3,
				--					@PackingID,
				--					@GRDate,
				--					@MaterialDeliveryNo,
				--					@MaterialDeliveryDetailNo,
				--					@InitialQty,
				--					@SplitQty,
				--					0,
				--					@VendorLotNo,
				--					@LifeBasicDate,
				--					@ProductionDate,
				--					@EndOfLifeDate,
				--					@LotNo,
				--					@IsSplitLot,
				--					@BefMaterialLotNo,
				--					GETDATE(),
				--					@ProcessUserID,
				--					@PackingIdParent,
				--					@LotAttr10
							
				--				)
					print 'insert'
					END
				 ELSE IF @IUD_FLAG = 'UPDATE' BEGIN
		
	


				UPDATE STB_MaterialDocLotInfo  
						 SET   LevelJIANGHAI = @LevelJIANGHAI
						 where  LotID = @LotID 
							  
						
				 UPDATE STB_MaterialLotInfo  
				 SET      LevelJIANGHAI = @LevelJIANGHAI
					 where  LotID = @LotID 
				 


                END ELSE IF @IUD_FLAG = 'DELETE' BEGIN

					print 'DELETE'
      --              DELETE FROM STB_MaterialLotInfo
						--WHERE
						--    MaterialLotNo = @OldMaterialLotNo
                END
            END
        END TRY
		BEGIN CATCH
			SET @ERROR_MSG = ERROR_MESSAGE()
			RAISERROR( @ERROR_MSG ,16, 1)
		END CATCH
			
		CLOSE SourceData;
		DEALLOCATE SourceData;
			
		EXEC sp_xml_removedocument @idoc	
    END
END

--   select * from STB_MaterialLotInfo_test
-- select * from STB_MaterialdocLotInfo_test1  
--select * from STB_MaterialdocLotInfo  where LOTID like '%SP%'
--   select * from STB_MaterialLotInfo order by CreateDateTime DESC

--   select * from  STB_MaterialLotInfo   where LOTID like '%SP%'
-- from STB_MaterialLotInfo where LotID ='SL20241216000124'

