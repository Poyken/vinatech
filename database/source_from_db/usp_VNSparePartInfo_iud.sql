-- =============================================
-- Author: Park Jong Hoon(jhpark@awoo.co.kr)
-- Create date: 2016-05-17
-- Browsable : true
-- Group : 설비관리
-- Description:	스페어파트정보 IUD
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_VNSparePartInfo_iud]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
    @pProcessViewName VARCHAR(50),
	@pXml NVARCHAR(MAX) = null
AS
BEGIN
	SET NOCOUNT ON;

    DECLARE @ProcessUserID VARCHAR(20) = @pProcessUserID
	DECLARE @ProcessLanguage VARCHAR(20) = @pProcessLanguage
	DECLARE @WorkCenterCodeTable VARCHAR(20)
	DECLARE @setTableName VARCHAR(50) -- Chia ra cho các nhà máy để có thể bắt đầu lại số thứ tự

	SELECT @WorkCenterCodeTable = WorkCenterCode 
	  FROM STB_UserInfo
	 WHERE UserID = @pProcessUserID

	 if(@WorkCenterCodeTable ='VVT_F1' or @WorkCenterCodeTable ='VVT_F2' or @WorkCenterCodeTable ='VVT_F4') --nhà máy bắc giang bắc ninh gộp lại
	 begin
		set @setTableName='STB_VNSparePartInfo'
	 end
	 else if(@WorkCenterCodeTable ='VVT_F3')
	  begin
		set @setTableName='STB_VNSparePartInfo_HN'
	end

    DECLARE @ProcessViewName VARCHAR(50) = @pProcessViewName
    DECLARE @InsertTableName VARCHAR(100) = '/DataSet/' + @ProcessViewName + '_INSERT'
    DECLARE @UpdateTableName VARCHAR(100) = '/DataSet/' + @ProcessViewName + '_UPDATE'
    DECLARE @DeleteTableName VARCHAR(100) = '/DataSet/' + @ProcessViewName + '_DELETE'
	DECLARE @ERROR_MSG NVARCHAR(MAX)
    DECLARE @IUD_FLAG VARCHAR(10)
	DECLARE @IsAutoKey BIT
	DECLARE @IsLoopIUD BIT
	DECLARE @PrefixString VARCHAR(20)
	DECLARE @SerialLen INT
    DECLARE @MaxKeyField VARCHAR(20)

    -- Declare Columns Variable
	DECLARE @OldSparePartCode VARCHAR(20)
	DECLARE @SparePartCode VARCHAR(20)
	DECLARE @SparePartName NVARCHAR(100)
	DECLARE @SparePartSpec01 NVARCHAR(100)
	DECLARE @SparePartSpec02 NVARCHAR(100)
	DECLARE @SparePartSpec03 NVARCHAR(100)
	DECLARE @SparePartSpec04 NVARCHAR(100)
	DECLARE @SparePartSpec05 NVARCHAR(100)
	DECLARE @BasicUnitPrice NUMERIC(15,2)
	DECLARE @BasicDeliveryDay INT
	DECLARE @BasicUnit VARCHAR(20)
	DECLARE @SafeQty NUMERIC(20,5)
	DECLARE @LastDeliveryVendor VARCHAR(20)
	DECLARE @CompatibilityGroup NVARCHAR(50)
	DECLARE @IsUsed BIT
	DECLARE @IsSpecial BIT
	DECLARE @CreateDateTime DATETIME
	DECLARE @CreateUserID VARCHAR(20)
	DECLARE @ChangeDateTime DATETIME
	DECLARE @ChangeUserID VARCHAR(20)
	DECLARE @MaxSafeQty numeric(20, 5)
	DECLARE @TypeCode nvarchar(50)
	DECLARE @Attribute nvarchar(200)
	DECLARE @Attribute1 nvarchar(200)
	DECLARE @Attribute2 nvarchar(200)
	DECLARE @Attribute3 nvarchar(200)
	DECLARE @Attribute4 nvarchar(200)
	DECLARE @Attribute5 nvarchar(200)
	DECLARE @Position nvarchar(200)
	DECLARE @WorkCenterCode varchar(20)
	DECLARE @PositionBG  nvarchar(200)
  
	DECLARE @SparePartImage BIGINT
	DECLARE @FileName NVARCHAR(255)
	DECLARE @FileSize BIGINT
	DECLARE @FileData VARBINARY(MAX)
	DECLARE @CurrentStock NUMERIC

	DECLARE @iDoc INT

    EXEC SmartFramework.dbo.usp_GetSerialRule 
			@pTableName = @setTableName,
			@pIsAutoKey = @IsAutoKey OUTPUT,
			@pIsLoopIUD = @IsLoopIUD OUTPUT,
			@pPrefixData = @PrefixString OUTPUT,
			@pSerialLen = @SerialLen OUTPUT
    
    IF @IsAutoKey = 0 AND @IsLoopIUD = 0 BEGIN
   
	    EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
	
	    BEGIN TRY
			-- Process Insert Table
            MERGE STB_VNSparePartInfo AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN XMLData.OldSparePartCode IS NULL THEN XMLData.SparePartCode
							    ELSE XMLData.OldSparePartCode
							END AS OldSparePartCode,
							XMLData.SparePartCode,
							XMLData.SparePartName,
							XMLData.SparePartSpec01,
							XMLData.SparePartSpec02,
							XMLData.SparePartSpec03,
							XMLData.SparePartSpec04,
							XMLData.SparePartSpec05,
							dbo.fnBase64ToBinary(XMLData.SparePartImage) as SparePartImage,
							XMLData.BasicUnitPrice,
							XMLData.BasicDeliveryDay,
							XMLData.BasicUnit,
							XMLData.SafeQty,
							XMLData.LastDeliveryVendor,
							XMLData.CompatibilityGroup,
							XMLData.IsUsed,
							XMLData.IsSpecial,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							XMLData.ChangeUserID,
							XMLData.MaxSafeQty,
							XMLData.TypeCode,
							XMLData.Attribute1,
							XMLData.Attribute2,
							XMLData.Attribute3,
							XMLData.Attribute4,
							XMLData.Attribute5,
							XMLData.Position,
							XMLData.WorkCenterCode,
							XMLData.PositionBG,
							XMLData.CurrentStock
					FROM
							OPENXML(@idoc , @InsertTableName , 2)
							WITH  (
										OldSparePartCode VARCHAR(20),
										SparePartCode VARCHAR(20),
										SparePartName NVARCHAR(100),
										SparePartSpec01 NVARCHAR(100),
										SparePartSpec02 NVARCHAR(100),
										SparePartSpec03 NVARCHAR(100),
										SparePartSpec04 NVARCHAR(100),
										SparePartSpec05 NVARCHAR(100),
										SparePartImage BIGINT,
										BasicUnitPrice NUMERIC(15,2),
										BasicDeliveryDay INT,
										BasicUnit VARCHAR(20),
										SafeQty NUMERIC(20,5),
										LastDeliveryVendor VARCHAR(20),
										CompatibilityGroup NVARCHAR(50),
										IsUsed BIT,
										IsSpecial BIT,
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20),
										MaxSafeQty numeric(20, 5),
										TypeCode nvarchar(50),
										Attribute nvarchar(200),
										Attribute1 nvarchar(200),
										Attribute2 nvarchar(200),
										Attribute3 nvarchar(200),
										Attribute4 nvarchar(200),
										Attribute5 nvarchar(200),
										Position nvarchar(200),
										WorkCenterCode varchar(20),
										PositionBG nvarchar(200),
										CurrentStock NUMERIC
									) XMLData
				) AS SourceTable
			ON
				(
					TargetTable.SparePartCode = SourceTable.SparePartCode
				)

			WHEN MATCHED THEN
				UPDATE SET
					SparePartCode = SourceTable.SparePartCode,
					SparePartName = SourceTable.SparePartName,
					SparePartSpec01 = SourceTable.SparePartSpec01,
					SparePartSpec02 = SourceTable.SparePartSpec02,
					SparePartSpec03 = SourceTable.SparePartSpec03,
					SparePartSpec04 = SourceTable.SparePartSpec04,
					SparePartSpec05 = SourceTable.SparePartSpec05,
					SparePartImage = SourceTable.SparePartImage,
					BasicUnitPrice = SourceTable.BasicUnitPrice,
					BasicDeliveryDay = SourceTable.BasicDeliveryDay,
					BasicUnit = SourceTable.BasicUnit,
					SafeQty = SourceTable.SafeQty,
					LastDeliveryVendor = SourceTable.LastDeliveryVendor,
					CompatibilityGroup = SourceTable.CompatibilityGroup,
					IsUsed = SourceTable.IsUsed,
					IsSpecial = SourceTable.IsSpecial,
					ChangeDateTime = SourceTable.ChangeDateTime,
					ChangeUserID = SourceTable.ChangeUserID,
					MaxSafeQty = SourceTable.MaxSafeQty,
					TypeCode = SourceTable.TypeCode,
					Attribute1 = SourceTable.Attribute1,
					Attribute2 = SourceTable.Attribute2,
					Attribute3 = SourceTable.Attribute3,
					Attribute4 = SourceTable.Attribute4,
					Attribute5 = SourceTable.Attribute5,
					Position = SourceTable.Position,
					WorkCenterCode = SourceTable.WorkCenterCode,
					PositionBG = SourceTable.PositionBG,
					CurrentStock=SourceTable.CurrentStock
			WHEN NOT MATCHED THEN
				INSERT
					(
						SparePartCode,
						SparePartName,
						SparePartSpec01,
						SparePartSpec02,
						SparePartSpec03,
						SparePartSpec04,
						SparePartSpec05,
						SparePartImage,
						BasicUnitPrice,
						BasicDeliveryDay,
						BasicUnit,
						SafeQty,
						LastDeliveryVendor,
						CompatibilityGroup,
						IsUsed,
						IsSpecial,
						CreateDateTime,
						CreateUserID,
						ChangeUserID,
						MaxSafeQty,
						TypeCode,
						Attribute1,
						Attribute2,
						Attribute3,
						Attribute4,
						Attribute5,
						Position,
						WorkCenterCode,
						PositionBG,
						CurrentStock
					)
				VALUES
					(
							SourceTable.SparePartCode,
							SourceTable.SparePartName,
							SourceTable.SparePartSpec01,
							SourceTable.SparePartSpec02,
							SourceTable.SparePartSpec03,
							SourceTable.SparePartSpec04,
							SourceTable.SparePartSpec05,
							SourceTable.SparePartImage,
							SourceTable.BasicUnitPrice,
							SourceTable.BasicDeliveryDay,
							SourceTable.BasicUnit,
							SourceTable.SafeQty,
							SourceTable.LastDeliveryVendor,
							SourceTable.CompatibilityGroup,
							SourceTable.IsUsed,
							SourceTable.IsSpecial,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID,
							SourceTable.ChangeUserID,
							SourceTable.MaxSafeQty,
							SourceTable.TypeCode,
							SourceTable.Attribute1,
							SourceTable.Attribute2,
							SourceTable.Attribute3,
							SourceTable.Attribute4,
							SourceTable.Attribute5,
							SourceTable.Position,
							SourceTable.WorkCenterCode,
							SourceTable.PositionBG,
							SourceTable.CurrentStock
					);


			-- Process Update Table
            MERGE STB_VNSparePartInfo AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN XMLData.OldSparePartCode IS NULL THEN XMLData.SparePartCode
							    ELSE XMLData.OldSparePartCode
							END AS OldSparePartCode,
							XMLData.SparePartCode,
							XMLData.SparePartName,
							XMLData.SparePartSpec01,
							XMLData.SparePartSpec02,
							XMLData.SparePartSpec03,
							XMLData.SparePartSpec04,
							XMLData.SparePartSpec05,
							dbo.fnBase64ToBinary(XMLData.SparePartImage) as SparePartImage,
							XMLData.BasicUnitPrice,
							XMLData.BasicDeliveryDay,
							XMLData.BasicUnit,
							XMLData.SafeQty,
							XMLData.LastDeliveryVendor,
							XMLData.CompatibilityGroup,
							XMLData.IsUsed,
							XMLData.IsSpecial,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							XMLData.ChangeUserID,
							XMLData.MaxSafeQty,
							XMLData.TypeCode,
							XMLData.Attribute1,
							XMLData.Attribute2,
							XMLData.Attribute3,
							XMLData.Attribute4,
							XMLData.Attribute5,
							XMLData.Position,
							XMLData.WorkCenterCode,
							XMLData.PositionBG,
							XMLData.CurrentStock
					FROM
							OPENXML(@idoc , @UpdateTableName , 2)
							WITH  (
										OldSparePartCode VARCHAR(20),
										SparePartCode VARCHAR(20),
										SparePartName NVARCHAR(100),
										SparePartSpec01 NVARCHAR(100),
										SparePartSpec02 NVARCHAR(100),
										SparePartSpec03 NVARCHAR(100),
										SparePartSpec04 NVARCHAR(100),
										SparePartSpec05 NVARCHAR(100),
										SparePartImage BIGINT,
										BasicUnitPrice NUMERIC(15,2),
										BasicDeliveryDay INT,
										BasicUnit VARCHAR(20),
										SafeQty NUMERIC(20,5),
										LastDeliveryVendor VARCHAR(20),
										CompatibilityGroup NVARCHAR(50),
										IsUsed BIT,
										IsSpecial BIT,
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20),
										MaxSafeQty numeric(20, 5),
										TypeCode nvarchar(50),
										Attribute nvarchar(200),
										Attribute1 nvarchar(200),
										Attribute2 nvarchar(200),
										Attribute3 nvarchar(200),
										Attribute4 nvarchar(200),
										Attribute5 nvarchar(200),
										Position nvarchar(200),
										WorkCenterCode varchar(20),
										PositionBG nvarchar(200),
										CurrentStock NUMERIC
									) XMLData
				) AS SourceTable
			ON
				(
					TargetTable.SparePartCode = SourceTable.OldSparePartCode
				)

			WHEN MATCHED THEN
				UPDATE SET
					SparePartCode = SourceTable.SparePartCode,
					SparePartName = SourceTable.SparePartName,
					SparePartSpec01 = SourceTable.SparePartSpec01,
					SparePartSpec02 = SourceTable.SparePartSpec02,
					SparePartSpec03 = SourceTable.SparePartSpec03,
					SparePartSpec04 = SourceTable.SparePartSpec04,
					SparePartSpec05 = SourceTable.SparePartSpec05,
					SparePartImage = SourceTable.SparePartImage,
					BasicUnitPrice = SourceTable.BasicUnitPrice,
					BasicDeliveryDay = SourceTable.BasicDeliveryDay,
					BasicUnit = SourceTable.BasicUnit,
					SafeQty = SourceTable.SafeQty,
					LastDeliveryVendor = SourceTable.LastDeliveryVendor,
					CompatibilityGroup = SourceTable.CompatibilityGroup,
					IsUsed = SourceTable.IsUsed,
					IsSpecial = SourceTable.IsSpecial,
					ChangeDateTime = SourceTable.ChangeDateTime,
					ChangeUserID = SourceTable.ChangeUserID,
					MaxSafeQty = SourceTable.MaxSafeQty,
					TypeCode = SourceTable.TypeCode,
					Attribute1 = SourceTable.Attribute1,
					Attribute2 = SourceTable.Attribute2,
					Attribute3 = SourceTable.Attribute3,
					Attribute4 = SourceTable.Attribute4,
					Attribute5 = SourceTable.Attribute5,
					Position = SourceTable.Position,
					WorkCenterCode = SourceTable.WorkCenterCode,
					PositionBG = SourceTable.PositionBG,
					CurrentStock=SourceTable.CurrentStock
			WHEN NOT MATCHED THEN
				INSERT
					(
						SparePartCode,
						SparePartName,
						SparePartSpec01,
						SparePartSpec02,
						SparePartSpec03,
						SparePartSpec04,
						SparePartSpec05,
						SparePartImage,
						BasicUnitPrice,
						BasicDeliveryDay,
						BasicUnit,
						SafeQty,
						LastDeliveryVendor,
						CompatibilityGroup,
						IsUsed,
						IsSpecial,
						CreateDateTime,
						CreateUserID,
						ChangeUserID,
						MaxSafeQty,
						TypeCode,
						Attribute1,
						Attribute2,
						Attribute3,
						Attribute4,
						Attribute5,
						Position,
						WorkCenterCode,
						PositionBG,
						CurrentStock
					)
				VALUES
					(
							SourceTable.SparePartCode,
							SourceTable.SparePartName,
							SourceTable.SparePartSpec01,
							SourceTable.SparePartSpec02,
							SourceTable.SparePartSpec03,
							SourceTable.SparePartSpec04,
							SourceTable.SparePartSpec05,
							SourceTable.SparePartImage,
							SourceTable.BasicUnitPrice,
							SourceTable.BasicDeliveryDay,
							SourceTable.BasicUnit,
							SourceTable.SafeQty,
							SourceTable.LastDeliveryVendor,
							SourceTable.CompatibilityGroup,
							SourceTable.IsUsed,
							SourceTable.IsSpecial,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID,
							SourceTable.ChangeUserID,
							SourceTable.MaxSafeQty,
							SourceTable.TypeCode,
							SourceTable.Attribute1,
							SourceTable.Attribute2,
							SourceTable.Attribute3,
							SourceTable.Attribute4,
							SourceTable.Attribute5,
							SourceTable.Position,
							SourceTable.WorkCenterCode,
							SourceTable.PositionBG,
							SourceTable.CurrentStock
					);


			-- Process Delete Table
            MERGE STB_VNSparePartInfo AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN XMLData.OldSparePartCode IS NULL THEN XMLData.SparePartCode
							    ELSE XMLData.OldSparePartCode
							END AS OldSparePartCode,
							XMLData.SparePartCode,
							XMLData.SparePartName,
							XMLData.SparePartSpec01,
							XMLData.SparePartSpec02,
							XMLData.SparePartSpec03,
							XMLData.SparePartSpec04,
							XMLData.SparePartSpec05,
							dbo.fnBase64ToBinary(XMLData.SparePartImage) as SparePartImage,
							XMLData.BasicUnitPrice,
							XMLData.BasicDeliveryDay,
							XMLData.BasicUnit,
							XMLData.SafeQty,
							XMLData.LastDeliveryVendor,
							XMLData.CompatibilityGroup,
							XMLData.IsUsed,
							XMLData.IsSpecial,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							XMLData.ChangeUserID,
							XMLData.MaxSafeQty,
							XMLData.TypeCode,
							XMLData.Attribute1,
							XMLData.Attribute2,
							XMLData.Attribute3,
							XMLData.Attribute4,
							XMLData.Attribute5,
							XMLData.Position,
							XMLData.WorkCenterCode,
							XMLData.PositionBG,
							XMLData.CurrentStock
					FROM
							OPENXML(@idoc , @DeleteTableName , 2)
							WITH  (
										OldSparePartCode VARCHAR(20),
										SparePartCode VARCHAR(20),
										SparePartName NVARCHAR(100),
										SparePartSpec01 NVARCHAR(100),
										SparePartSpec02 NVARCHAR(100),
										SparePartSpec03 NVARCHAR(100),
										SparePartSpec04 NVARCHAR(100),
										SparePartSpec05 NVARCHAR(100),
										SparePartImage BIGINT,
										BasicUnitPrice NUMERIC(15,2),
										BasicDeliveryDay INT,
										BasicUnit VARCHAR(20),
										SafeQty NUMERIC(20,5),
										LastDeliveryVendor VARCHAR(20),
										CompatibilityGroup NVARCHAR(50),
										IsUsed BIT,
										IsSpecial BIT,
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20),
										MaxSafeQty numeric(20, 5),
										TypeCode nvarchar(50),
										Attribute nvarchar(200),
										Attribute1 nvarchar(200),
										Attribute2 nvarchar(200),
										Attribute3 nvarchar(200),
										Attribute4 nvarchar(200),
										Attribute5 nvarchar(200),
										Position nvarchar(200),
										WorkCenterCode varchar(20),
										PositionBG nvarchar(200),
										CurrentStock NUMERIC
									) XMLData
				) AS SourceTable
			ON
				(
					TargetTable.SparePartCode = SourceTable.SparePartCode
				)

			WHEN MATCHED THEN
				DELETE;

        END TRY
	    BEGIN CATCH
            SET @ERROR_MSG = ERROR_MESSAGE()
			RAISERROR( @ERROR_MSG ,16, 1)
	    END CATCH
		
	    EXEC sp_xml_removedocument @idoc

    END ELSE BEGIN
        EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
        BEGIN TRY
		    DECLARE SourceData CURSOR FOR
                SELECT
                        'INSERT' AS IUD_FLAG,
									XMLData.OldSparePartCode,
									XMLData.SparePartCode,
									XMLData.SparePartName,
									XMLData.SparePartSpec01,
									XMLData.SparePartSpec02,
									XMLData.SparePartSpec03,
									XMLData.SparePartSpec04,
									XMLData.SparePartSpec05,	
									XMLData.[FileName],
									XMLData.FileSize,
									dbo.fnBase64ToBinary(XMLData.FileData) as FileData,
									XMLData.SparePartImage,
									XMLData.BasicUnitPrice,
									XMLData.BasicDeliveryDay,
									XMLData.BasicUnit,
									XMLData.SafeQty,
									XMLData.LastDeliveryVendor,
									XMLData.CompatibilityGroup,
									XMLData.IsUsed,
									XMLData.IsSpecial,
									XMLData.CreateDateTime,
									XMLData.CreateUserID,
									XMLData.ChangeDateTime,
									XMLData.ChangeUserID,
									XMLData.MaxSafeQty,
									XMLData.TypeCode,
									XMLData.Attribute1,
									XMLData.Attribute2,
									XMLData.Attribute3,
									XMLData.Attribute4,
									XMLData.Attribute5,
									XMLData.Position,
									XMLData.WorkCenterCode,
									XMLData.PositionBG,
									XMLData.CurrentStock
							FROM
									OPENXML(@idoc , @InsertTableName , 2)
							        WITH  (
											 OldSparePartCode VARCHAR(20),
											 SparePartCode VARCHAR(20),
											 SparePartName NVARCHAR(100),
											 SparePartSpec01 NVARCHAR(100),
											 SparePartSpec02 NVARCHAR(100),
											 SparePartSpec03 NVARCHAR(100),
											 SparePartSpec04 NVARCHAR(100),
											 SparePartSpec05 NVARCHAR(100),
											 [FileName] NVARCHAR(255),
											 FileSize BIGINT,
											 FileData VARCHAR(MAX),
											 SparePartImage BIGINT,
											 BasicUnitPrice NUMERIC(15,2),
											 BasicDeliveryDay INT,
											 BasicUnit VARCHAR(20),
											 SafeQty NUMERIC(20,5),
											 LastDeliveryVendor VARCHAR(20),
											 CompatibilityGroup NVARCHAR(50),
											 IsUsed BIT,
											 IsSpecial BIT,
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20),
											 MaxSafeQty numeric(20, 5),
											TypeCode nvarchar(50),
											Attribute nvarchar(200),
											Attribute1 nvarchar(200),
											Attribute2 nvarchar(200),
											Attribute3 nvarchar(200),
											Attribute4 nvarchar(200),
											Attribute5 nvarchar(200),
											Position nvarchar(200),
											WorkCenterCode varchar(20),
											PositionBG nvarchar(200),
											CurrentStock NUMERIC
											) XMLData
							UNION ALL
							SELECT
									'UPDATE' AS IUD_FLAG,
									CASE 
										WHEN XMLData.OldSparePartCode IS NULL THEN XMLData.SparePartCode
										ELSE XMLData.OldSparePartCode
									END AS OldSparePartCode,
									XMLData.SparePartCode,
									XMLData.SparePartName,
									XMLData.SparePartSpec01,
									XMLData.SparePartSpec02,
									XMLData.SparePartSpec03,
									XMLData.SparePartSpec04,
									XMLData.SparePartSpec05,
									XMLData.[FileName],
									XMLData.FileSize,
									dbo.fnBase64ToBinary(XMLData.FileData) as FileData,
									XMLData.SparePartImage,
									XMLData.BasicUnitPrice,
									XMLData.BasicDeliveryDay,
									XMLData.BasicUnit,
									XMLData.SafeQty,
									XMLData.LastDeliveryVendor,
									XMLData.CompatibilityGroup,
									XMLData.IsUsed,
									XMLData.IsSpecial,
									XMLData.CreateDateTime,
									XMLData.CreateUserID,
									XMLData.ChangeDateTime,
									XMLData.ChangeUserID,
									XMLData.MaxSafeQty,
									XMLData.TypeCode,
									XMLData.Attribute1,
									XMLData.Attribute2,
									XMLData.Attribute3,
									XMLData.Attribute4,
									XMLData.Attribute5,
									XMLData.Position,
									XMLData.WorkCenterCode,
									 XMLData.PositionBG,
									 XMLData.CurrentStock
							FROM
									OPENXML(@idoc , @UpdateTableName , 2)
							        WITH  (
											 OldSparePartCode VARCHAR(20),
											 SparePartCode VARCHAR(20),
											 SparePartName NVARCHAR(100),
											 SparePartSpec01 NVARCHAR(100),
											 SparePartSpec02 NVARCHAR(100),
											 SparePartSpec03 NVARCHAR(100),
											 SparePartSpec04 NVARCHAR(100),
											 SparePartSpec05 NVARCHAR(100),
											 [FileName] NVARCHAR(255),
											 FileSize BIGINT,
											 FileData VARCHAR(MAX),
											 SparePartImage BIGINT,
											 BasicUnitPrice NUMERIC(15,2),
											 BasicDeliveryDay INT,
											 BasicUnit VARCHAR(20),
											 SafeQty NUMERIC(20,5),
											 LastDeliveryVendor VARCHAR(20),
											 CompatibilityGroup NVARCHAR(50),
											 IsUsed BIT,
											 IsSpecial BIT,
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20),
											 MaxSafeQty numeric(20, 5),
											TypeCode nvarchar(50),
											Attribute nvarchar(200),
											Attribute1 nvarchar(200),
											Attribute2 nvarchar(200),
											Attribute3 nvarchar(200),
											Attribute4 nvarchar(200),
											Attribute5 nvarchar(200),
											Position nvarchar(200),
											WorkCenterCode varchar(20),
											PositionBG nvarchar(200),
											CurrentStock NUMERIC
											) XMLData
							UNION ALL
							SELECT
									'DELETE' AS IUD_FLAG,
									CASE 
										WHEN XMLData.OldSparePartCode IS NULL THEN XMLData.SparePartCode
										ELSE XMLData.OldSparePartCode
									END AS OldSparePartCode,
									XMLData.SparePartCode,
									XMLData.SparePartName,
									XMLData.SparePartSpec01,
									XMLData.SparePartSpec02,
									XMLData.SparePartSpec03,
									XMLData.SparePartSpec04,
									XMLData.SparePartSpec05,
									XMLData.[FileName],
									XMLData.FileSize,
									dbo.fnBase64ToBinary(XMLData.FileData) as FileData,
									XMLData.SparePartImage,
									XMLData.BasicUnitPrice,
									XMLData.BasicDeliveryDay,
									XMLData.BasicUnit,
									XMLData.SafeQty,
									XMLData.LastDeliveryVendor,
									XMLData.CompatibilityGroup,
									XMLData.IsUsed,
									XMLData.IsSpecial,
									XMLData.CreateDateTime,
									XMLData.CreateUserID,
									XMLData.ChangeDateTime,
									XMLData.ChangeUserID,
									XMLData.MaxSafeQty,
									XMLData.TypeCode,
									XMLData.Attribute1,
									XMLData.Attribute2,
									XMLData.Attribute3,
									XMLData.Attribute4,
									XMLData.Attribute5,
									XMLData.Position,
									XMLData.WorkCenterCode,
									XMLData.PositionBG,
									XMLData.CurrentStock
							FROM
									OPENXML(@idoc , @DeleteTableName , 2)
							        WITH  (
											 OldSparePartCode VARCHAR(20),
											 SparePartCode VARCHAR(20),
											 SparePartName NVARCHAR(100),
											 SparePartSpec01 NVARCHAR(100),
											 SparePartSpec02 NVARCHAR(100),
											 SparePartSpec03 NVARCHAR(100),
											 SparePartSpec04 NVARCHAR(100),
											 SparePartSpec05 NVARCHAR(100),
											 [FileName] NVARCHAR(255),
											 FileSize BIGINT,
											 FileData VARCHAR(MAX),
											 SparePartImage BIGINT,
											 BasicUnitPrice NUMERIC(15,2),
											 BasicDeliveryDay INT,
											 BasicUnit VARCHAR(20),
											 SafeQty NUMERIC(20,5),
											 LastDeliveryVendor VARCHAR(20),
											 CompatibilityGroup NVARCHAR(50),
											 IsUsed BIT,
											 IsSpecial BIT,
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20),
											 MaxSafeQty numeric(20, 5),
											TypeCode nvarchar(50),
											Attribute nvarchar(200),
											Attribute1 nvarchar(200),
											Attribute2 nvarchar(200),
											Attribute3 nvarchar(200),
											Attribute4 nvarchar(200),
											Attribute5 nvarchar(200),
											Position nvarchar(200),
											WorkCenterCode varchar(20),
											PositionBG nvarchar(200),
											CurrentStock NUMERIC
											) XMLData


            OPEN SourceData

            WHILE 1 = 1 BEGIN

                FETCH NEXT FROM SourceData INTO
								 @IUD_FLAG,
								 @OldSparePartCode,
								 @SparePartCode,
								 @SparePartName,
								 @SparePartSpec01,
								 @SparePartSpec02,
								 @SparePartSpec03,
								 @SparePartSpec04,
								 @SparePartSpec05,
								 @FileName,
								 @FileSize,
								 @FileData,
								 @SparePartImage,
								 @BasicUnitPrice,
								 @BasicDeliveryDay,
								 @BasicUnit,
								 @SafeQty,
								 @LastDeliveryVendor,
								 @CompatibilityGroup,
								 @IsUsed,
								 @IsSpecial,
								 @CreateDateTime,
								 @CreateUserID,
								 @ChangeDateTime,
								 @ChangeUserID,
								 @MaxSafeQty,
								 @TypeCode,
								 @Attribute1,
								 @Attribute2,
								 @Attribute3,
								 @Attribute4,
								 @Attribute5,
								 @Position,
								 @WorkCenterCode,
								 @PositionBG,
								 @CurrentStock

                IF @@FETCH_STATUS <> 0 BEGIN
					BREAK
				END
                IF @IUD_FLAG = 'INSERT' BEGIN

                    IF EXISTS (SELECT 1 FROM STB_VNSparePartInfo WHERE SparePartCode = @SparePartCode) BEGIN
						RAISERROR('Duplicate Data : KeyField = %s', 16, 1, @SparePartCode)
					END

                    IF @IsAutoKey = 1 BEGIN
						EXEC SmartFramework.dbo.usp_DoCreateSerial @setTableName, @SparePartCode OUTPUT
                    END

                    EXEC SmartFramework.dbo.usp_DoSaveFile 
							@pSystemName = @setTableName,
							@pFileContents = @FileData,
							@pFileName = @FileName,
							@pFileSize = @FileSize,
							@pUserID = @ProcessUserID,
							@pFileID = @SparePartImage OUTPUT


                    INSERT INTO STB_VNSparePartInfo
						(
						    SparePartCode,
						    SparePartName,
						    SparePartSpec01,
						    SparePartSpec02,
						    SparePartSpec03,
						    SparePartSpec04,
						    SparePartSpec05,
						    SparePartImage,
						    BasicUnitPrice,
						    BasicDeliveryDay,
						    BasicUnit,
						    SafeQty,
						    LastDeliveryVendor,
						    CompatibilityGroup,
						    IsUsed,
							IsSpecial,
						    CreateDateTime,
						    CreateUserID,
						    ChangeDateTime,
						    ChangeUserID,
							MaxSafeQty,
							TypeCode,
							Attribute1,
							Attribute2,
							Attribute3,
							Attribute4,
							Attribute5,
							Position,
							WorkCenterCode,
							PositionBG,
							CurrentStock
						)
						VALUES
						(
						    @SparePartCode,
						    @SparePartName,
						    @SparePartSpec01,
						    @SparePartSpec02,
						    @SparePartSpec03,
						    @SparePartSpec04,
						    @SparePartSpec05,
						    @SparePartImage,
						    @BasicUnitPrice,
						    @BasicDeliveryDay,
						    @BasicUnit,
						    @SafeQty,
						    @LastDeliveryVendor,
						    @CompatibilityGroup,
						    @IsUsed,
							@IsSpecial,
						    GETDATE(),
						    @pProcessUserID,
						    @ChangeDateTime,
						    @ChangeUserID,
							@MaxSafeQty,
							@TypeCode,
							@Attribute1,
							@Attribute2,
							@Attribute3,
							@Attribute4,
							@Attribute5,
							@Position,
							@WorkCenterCode,
							@PositionBG,
							@CurrentStock
						)

				END ELSE IF @IUD_FLAG = 'UPDATE' BEGIN
					
					EXEC SmartFramework.dbo.usp_DoSaveFile 
							@pSystemName = 'STB_VNSparePartInfo',
							@pFileContents = @FileData,
							@pFileName = @FileName,
							@pFileSize = @FileSize,
							@pUserID = @ProcessUserID,
							@pFileID = @SparePartImage OUTPUT	
							
                    UPDATE STB_VNSparePartInfo
						SET
						    SparePartCode =   CASE
						                WHEN @SparePartCode IS NOT NULL THEN @SparePartCode
						                ELSE SparePartCode
						            END,
						    SparePartName =   CASE
						                WHEN @SparePartName IS NOT NULL THEN @SparePartName
						                ELSE SparePartName
						            END,
						    SparePartSpec01 =   CASE
						                WHEN @SparePartSpec01 IS NOT NULL THEN @SparePartSpec01
						                ELSE SparePartSpec01
						            END,
						    SparePartSpec02 =   CASE
						                WHEN @SparePartSpec02 IS NOT NULL THEN @SparePartSpec02
						                ELSE SparePartSpec02
						            END,
						    SparePartSpec03 =   CASE
						                WHEN @SparePartSpec03 IS NOT NULL THEN @SparePartSpec03
						                ELSE SparePartSpec03
						            END,
						    SparePartSpec04 =   CASE
						                WHEN @SparePartSpec04 IS NOT NULL THEN @SparePartSpec04
						                ELSE SparePartSpec04
						            END,
						    SparePartSpec05 =   CASE
						                WHEN @SparePartSpec05 IS NOT NULL THEN @SparePartSpec05
						                ELSE SparePartSpec05
						            END,
						    SparePartImage =   CASE
						                WHEN @SparePartImage IS NOT NULL THEN @SparePartImage
						                ELSE SparePartImage
						            END,
						    BasicUnitPrice =   CASE
						                WHEN @BasicUnitPrice IS NOT NULL THEN @BasicUnitPrice
						                ELSE BasicUnitPrice
						            END,
						    BasicDeliveryDay =   CASE
						                WHEN @BasicDeliveryDay IS NOT NULL THEN @BasicDeliveryDay
						                ELSE BasicDeliveryDay
						            END,
						    BasicUnit =   CASE
						                WHEN @BasicUnit IS NOT NULL THEN @BasicUnit
						                ELSE BasicUnit
						            END,
						    SafeQty =   CASE
						                WHEN @SafeQty IS NOT NULL THEN @SafeQty
						                ELSE SafeQty
						            END,
						    LastDeliveryVendor =   CASE
						                WHEN @LastDeliveryVendor IS NOT NULL THEN @LastDeliveryVendor
						                ELSE LastDeliveryVendor
						            END,
						    CompatibilityGroup =   CASE
						                WHEN @CompatibilityGroup IS NOT NULL THEN @CompatibilityGroup
						                ELSE CompatibilityGroup
						            END,
						    IsUsed =   CASE
						                WHEN @IsUsed IS NOT NULL THEN @IsUsed
						                ELSE IsUsed
						            END,
							IsSpecial =   CASE
						                WHEN @IsSpecial IS NOT NULL THEN @IsSpecial
						                ELSE IsSpecial
						            END,
						    CreateDateTime =   CASE
						                WHEN @CreateDateTime IS NOT NULL THEN @CreateDateTime
						                ELSE CreateDateTime
						            END,
						    CreateUserID =   CASE
						                WHEN @CreateUserID IS NOT NULL THEN @CreateUserID
						                ELSE CreateUserID
						            END,
						    ChangeDateTime = GETDATE(),
						    ChangeUserID =   CASE
						                WHEN @ChangeUserID IS NOT NULL THEN @ChangeUserID
						                ELSE ChangeUserID
						            END,
							 MaxSafeQty =   CASE
						                WHEN @MaxSafeQty IS NOT NULL THEN @MaxSafeQty
						                ELSE MaxSafeQty
						            END,
							 TypeCode =   CASE
						                WHEN @TypeCode IS NOT NULL THEN @TypeCode
						                ELSE TypeCode
						            END,
							 Attribute1 =   CASE
						                WHEN @Attribute1 IS NOT NULL THEN @Attribute1
						                ELSE Attribute1
						            END,
							 Attribute2 =   CASE
						                WHEN @Attribute2 IS NOT NULL THEN @Attribute2
						                ELSE Attribute2
						            END,
							 Attribute3 =   CASE
						                WHEN @Attribute3 IS NOT NULL THEN @Attribute3
						                ELSE Attribute3
						            END,
							 Attribute4 =   CASE
						                WHEN @Attribute4 IS NOT NULL THEN @Attribute4
						                ELSE Attribute4
						            END,
							 Attribute5 =   CASE
						                WHEN @Attribute5 IS NOT NULL THEN @Attribute5
						                ELSE Attribute5
						            END,
							 Position   = CASE
										 WHEN @Position IS NOT NULL THEN @Position
						                ELSE Position
						            END,
							PositionBG   = CASE
								WHEN @PositionBG IS NOT NULL THEN @PositionBG
									 ELSE PositionBG
								END,
							CurrentStock =CASE 
							    WHEN @CurrentStock IS NOT NULL THEN @CurrentStock
								   ELSE CurrentStock
							END
						WHERE
						    SparePartCode = @OldSparePartCode
                END ELSE IF @IUD_FLAG = 'DELETE' BEGIN
					DELETE FROM SmartFramework_File.dbo.STB_AttachedFileMaster
					WHERE
							FileID = @SparePartImage
							
                    DELETE FROM STB_VNSparePartInfo
					WHERE
						   SparePartCode = @SparePartCode
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

