
-- =============================================
-- Author: Park Jong Hoon(jhpark@awoo.co.kr)
-- Create date: 2016-02-04
-- Browsable : true
-- Group : 자재관리
-- Description:	자재발주전표 IUD
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_DayMaterialOrderAndAdditional_his_iud]
	@pProcessUserID VARCHAR(20) = null,
	@pProcessLanguage VARCHAR(20) = null,
    @pProcessViewName VARCHAR(50) = null,
    @pIsChangeProduct VARCHAR(50) = null,
	@pXml NVARCHAR(MAX) = null
AS


BEGIN
	SET NOCOUNT ON;

	

    DECLARE @ProcessUserID VARCHAR(20) = @pProcessUserID
	DECLARE @ProcessLanguage VARCHAR(20) = @pProcessLanguage
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
	DECLARE @OldId VARCHAR(20)
	DECLARE @Id VARCHAR(20)
	DECLARE @PONo VARCHAR(20)
	DECLARE @DayPlanNo VARCHAR(20)
	DECLARE @ChildMaterialCode VARCHAR(50)
	DECLARE @MaterialName NVARCHAR(50)            -- Mã dòng sản xuất
	DECLARE @LineCode NVARCHAR(20)        -- Mã vật liệu
	DECLARE @Plandate DATETIME             -- Số lượng đơn hàng
	DECLARE @MaterialOrderNo  VARCHAR(20)         -- Trạng thái đơn hàng
	DECLARE @SoLuongKeHoachNgay INT               -- Ngày tạo đơn hàng
	DECLARE @NVLngay INT               -- Ngày tạo đơn hàng
	DECLARE @UsedQtyDay DECIMAL                     -- Trạng thái hoàn thành
	DECLARE @IsAdditional Bit                     -- Trạng thái hoàn thành
	DECLARE @OrderDesc NVARCHAR(100)                 -- Trạng thái hoàn thành
	DECLARE @CompanyCode VARCHAR(20)                  -- Trạng thái hoàn thành
	DECLARE @WorkCenterCode VARCHAR(20)                  -- Trạng thái hoàn thành
	DECLARE @QtyExp int              -- Trạng thái hoàn thành
	DECLARE @QtyByPO  int              -- Trạng thái hoàn thành
	DECLARE @CreateDateTime DATETIME         -- Thời gian tạo bản ghi
	DECLARE @CreateUserID NVARCHAR(50)       -- Người tạo bản ghi
	DECLARE @ChangeDateTime DATETIME         -- Thời gian thay đổi bản ghi
	DECLARE @ChangeUserID NVARCHAR(50)      -- Người thay đổi bản ghi




	DECLARE @iDoc INT

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

    EXEC SmartFramework.dbo.usp_GetSerialRule 
			@pTableName = 'STB_DayMaterialOrder',
			@pIsAutoKey = @IsAutoKey OUTPUT,
			@pIsLoopIUD = @IsLoopIUD OUTPUT,
			@pPrefixData = @PrefixString OUTPUT,
			@pSerialLen = @SerialLen OUTPUT
    --raiserror ('check',16,1)
    IF @IsAutoKey = 0 AND @IsLoopIUD = 0 BEGIN
   
	    EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
	
	    BEGIN TRY
		raiserror('aa',16,1)
		select * from STB_DayMaterialOrder
			-- Process Insert Table
            MERGE STB_DayMaterialOrder  AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN XMLData.OldId IS NULL THEN XMLData.Id
							    ELSE XMLData.OldId
							END AS OldId,
							XMLData.Id ,
							XMLData.PONo ,
							XMLData.DayPlanNo ,
							XMLData.ChildMaterialCode ,
							XMLData.MaterialName ,            -- Mã dòng sản xuất
							XMLData.LineCode ,        -- Mã vật liệu
							XMLData.Plandate ,             -- Số lượng đơn hàng
							MaterialOrderNo ,         -- Trạng thái đơn hàng
							XMLData.SoLuongKeHoachNgay ,               -- Ngày tạo đơn hàng
							XMLData.NVLngay,               -- Ngày tạo đơn hàng
							XMLData.UsedQtyDay  ,                    -- Trạng thái hoàn thành
							XMLData.IsAdditional,                    -- Trạng thái hoàn thành
							XMLData.OrderDesc  ,                -- Trạng thái hoàn thành
							XMLData.CompanyCode  ,                 -- Trạng thái hoàn thành
							XMLData.WorkCenterCode ,                  -- Trạng thái hoàn thành
							XMLData.QtyExp  ,             -- Trạng thái hoàn thành
							XMLData.QtyByPO ,            -- Trạng thái hoàn thành
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @InsertTableName , 2)
							WITH  (
											OldId VARCHAR(20),
											Id VARCHAR(20),
											PONo VARCHAR(20),
											DayPlanNo VARCHAR(20),
											ChildMaterialCode VARCHAR(50),
											MaterialName NVARCHAR(50),            -- Mã dòng sản xuất
											LineCode NVARCHAR(20),        -- Mã vật liệu
											Plandate DATETIME,             -- Số lượng đơn hàng
											MaterialOrderNo  VARCHAR(20),         -- Trạng thái đơn hàng
											SoLuongKeHoachNgay INT,               -- Ngày tạo đơn hàng
											NVLngay INT,               -- Ngày tạo đơn hàng
											UsedQtyDay DECIMAL ,                    -- Trạng thái hoàn thành
											IsAdditional Bit ,                    -- Trạng thái hoàn thành
											OrderDesc NVARCHAR(100) ,                -- Trạng thái hoàn thành
											CompanyCode VARCHAR(20) ,                 -- Trạng thái hoàn thành
											WorkCenterCode VARCHAR(20),                  -- Trạng thái hoàn thành
											QtyExp int ,             -- Trạng thái hoàn thành
											QtyByPO  int,            -- Trạng thái hoàn thành
											CreateDateTime DATETIME,        -- Thời gian tạo bản ghi
											CreateUserID NVARCHAR(50),       -- Người tạo bản ghi
											ChangeDateTime DATETIME,         -- Thời gian thay đổi bản ghi
											ChangeUserID NVARCHAR(50)      -- Người thay đổi bản ghi
									) XMLData
				) AS SourceTable
			ON
				(
					TargetTable.Id = SourceTable.Id
				)

			WHEN MATCHED THEN
				UPDATE SET
					PONo = SourceTable.PONo,
					DayPlanNo = SourceTable.DayPlanNo,
					ChildMaterialCode = SourceTable.ChildMaterialCode,
					MaterialName = SourceTable.MaterialName,
					LineCode = SourceTable.LineCode,
					Plandate = SourceTable.Plandate,
					MaterialOrderNo = SourceTable.MaterialOrderNo,
					SoLuongKeHoachNgay = SourceTable.SoLuongKeHoachNgay,
					NVLngay = SourceTable.NVLngay,
					UsedQtyDay = SourceTable.UsedQtyDay,
					IsAdditional = SourceTable.IsAdditional,
					OrderDesc = SourceTable.OrderDesc,
					CompanyCode = SourceTable.CompanyCode,
					WorkCenterCode = SourceTable.WorkCenterCode,
					QtyExp = SourceTable.QtyExp,
					QtyByPO = SourceTable.QtyByPO
				
				


			WHEN NOT MATCHED THEN
				INSERT
					(
						PONo ,
						DayPlanNo ,
						ChildMaterialCode ,
						MaterialName ,
						LineCode ,
						Plandate ,
						MaterialOrderNo,
						SoLuongKeHoachNgay ,
						NVLngay,
						UsedQtyDay ,
						IsAdditional ,
						OrderDesc ,
						CompanyCode ,
						WorkCenterCode ,
						QtyExp ,
						QtyByPO,
						CreateDateTime,
						CreateUserID
					)
				VALUES
					(
							SourceTable.PONo,
							SourceTable.DayPlanNo,
							SourceTable.ChildMaterialCode,
							SourceTable.MaterialName,
							SourceTable.LineCode,
							SourceTable.Plandate,
							SourceTable.MaterialOrderNo,
							SourceTable.SoLuongKeHoachNgay,
							SourceTable.NVLngay,
							SourceTable.UsedQtyDay,
							SourceTable.IsAdditional,
							SourceTable.OrderDesc,
							SourceTable.CompanyCode,
							SourceTable.WorkCenterCode,
							SourceTable.QtyExp,
							SourceTable.QtyByPO,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID

					);


			-- Process Update Table
            MERGE STB_DayMaterialOrder  AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN XMLData.OldId IS NULL THEN XMLData.Id
							    ELSE XMLData.OldId
							END AS OldId,
							XMLData.Id ,
							XMLData.PONo ,
							XMLData.DayPlanNo ,
							XMLData.ChildMaterialCode ,
							XMLData.MaterialName ,            -- Mã dòng sản xuất
							XMLData.LineCode ,        -- Mã vật liệu
							XMLData.Plandate ,             -- Số lượng đơn hàng
							MaterialOrderNo ,         -- Trạng thái đơn hàng
							XMLData.SoLuongKeHoachNgay ,               -- Ngày tạo đơn hàng
							XMLData.NVLngay,               -- Ngày tạo đơn hàng
							XMLData.UsedQtyDay  ,                    -- Trạng thái hoàn thành
							XMLData.IsAdditional,                    -- Trạng thái hoàn thành
							XMLData.OrderDesc  ,                -- Trạng thái hoàn thành
							XMLData.CompanyCode  ,                 -- Trạng thái hoàn thành
							XMLData.WorkCenterCode ,                  -- Trạng thái hoàn thành
							XMLData.QtyExp  ,             -- Trạng thái hoàn thành
							XMLData.QtyByPO ,            -- Trạng thái hoàn thành
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @UpdateTableName , 2)
							WITH  (
											OldId VARCHAR(20),
											Id VARCHAR(20),
											PONo VARCHAR(20),
											DayPlanNo VARCHAR(20),
											ChildMaterialCode VARCHAR(50),
											MaterialName NVARCHAR(50),            -- Mã dòng sản xuất
											LineCode NVARCHAR(20),        -- Mã vật liệu
											Plandate DATETIME,             -- Số lượng đơn hàng
											MaterialOrderNo  VARCHAR(20),         -- Trạng thái đơn hàng
											SoLuongKeHoachNgay INT,               -- Ngày tạo đơn hàng
											NVLngay INT,               -- Ngày tạo đơn hàng
											UsedQtyDay DECIMAL ,                    -- Trạng thái hoàn thành
											IsAdditional Bit ,                    -- Trạng thái hoàn thành
											OrderDesc NVARCHAR(100) ,                -- Trạng thái hoàn thành
											CompanyCode VARCHAR(20) ,                 -- Trạng thái hoàn thành
											WorkCenterCode VARCHAR(20),                  -- Trạng thái hoàn thành
											QtyExp int ,             -- Trạng thái hoàn thành
											QtyByPO  int,            -- Trạng thái hoàn thành
											CreateDateTime DATETIME,        -- Thời gian tạo bản ghi
											CreateUserID NVARCHAR(50),       -- Người tạo bản ghi
											ChangeDateTime DATETIME,         -- Thời gian thay đổi bản ghi
											ChangeUserID NVARCHAR(50)      -- Người thay đổi bản ghi
									) XMLData
				) AS SourceTable
			ON
				(
				 
					TargetTable.Id = SourceTable.OldId
				)

			WHEN MATCHED THEN
				UPDATE SET
					PONo = SourceTable.PONo,
					DayPlanNo = SourceTable.DayPlanNo,
					ChildMaterialCode = SourceTable.ChildMaterialCode,
					MaterialName = SourceTable.MaterialName,
					LineCode = SourceTable.LineCode,
					Plandate = SourceTable.Plandate,
					MaterialOrderNo = SourceTable.MaterialOrderNo,
					SoLuongKeHoachNgay = SourceTable.SoLuongKeHoachNgay,
					NVLngay = SourceTable.NVLngay,
					UsedQtyDay = SourceTable.UsedQtyDay,
					IsAdditional = SourceTable.IsAdditional,
					OrderDesc = SourceTable.OrderDesc,
					CompanyCode = SourceTable.CompanyCode,
					WorkCenterCode = SourceTable.WorkCenterCode,
					QtyExp = SourceTable.QtyExp,
					QtyByPO = SourceTable.QtyByPO
			WHEN NOT MATCHED THEN
				INSERT
					(
							PONo ,
						DayPlanNo ,
						ChildMaterialCode ,
						MaterialName ,
						LineCode ,
						Plandate ,
						MaterialOrderNo,
						SoLuongKeHoachNgay ,
						NVLngay,
						UsedQtyDay ,
						IsAdditional ,
						OrderDesc ,
						CompanyCode ,
						WorkCenterCode ,
						QtyExp ,
						QtyByPO,
						CreateDateTime,
						CreateUserID
					)
				VALUES
					(
							SourceTable.PONo,
							SourceTable.DayPlanNo,
							SourceTable.ChildMaterialCode,
							SourceTable.MaterialName,
							SourceTable.LineCode,
							SourceTable.Plandate,
							SourceTable.MaterialOrderNo,
							SourceTable.SoLuongKeHoachNgay,
							SourceTable.NVLngay,
							SourceTable.UsedQtyDay,
							SourceTable.IsAdditional,
							SourceTable.OrderDesc,
							SourceTable.CompanyCode,
							SourceTable.WorkCenterCode,
							SourceTable.QtyExp,
							SourceTable.QtyByPO,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID
					);


			-- Process Delete Table
            MERGE STB_DayMaterialOrder  AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN XMLData.OldId IS NULL THEN XMLData.Id
							    ELSE XMLData.OldId
							END AS OldId,
							XMLData.Id ,
							XMLData.PONo ,
							XMLData.DayPlanNo ,
							XMLData.ChildMaterialCode ,
							XMLData.MaterialName ,            -- Mã dòng sản xuất
							XMLData.LineCode ,        -- Mã vật liệu
							XMLData.Plandate ,             -- Số lượng đơn hàng
							MaterialOrderNo ,         -- Trạng thái đơn hàng
							XMLData.SoLuongKeHoachNgay ,               -- Ngày tạo đơn hàng
							XMLData.NVLngay,               -- Ngày tạo đơn hàng
							XMLData.UsedQtyDay  ,                    -- Trạng thái hoàn thành
							XMLData.IsAdditional,                    -- Trạng thái hoàn thành
							XMLData.OrderDesc  ,                -- Trạng thái hoàn thành
							XMLData.CompanyCode  ,                 -- Trạng thái hoàn thành
							XMLData.WorkCenterCode ,                  -- Trạng thái hoàn thành
							XMLData.QtyExp  ,             -- Trạng thái hoàn thành
							XMLData.QtyByPO ,            -- Trạng thái hoàn thành
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @DeleteTableName , 2)
							WITH  (
											OldId VARCHAR(20),
											Id VARCHAR(20),
											PONo VARCHAR(20),
											DayPlanNo VARCHAR(20),
											ChildMaterialCode VARCHAR(50),
											MaterialName NVARCHAR(50),            -- Mã dòng sản xuất
											LineCode NVARCHAR(20),        -- Mã vật liệu
											Plandate DATETIME,             -- Số lượng đơn hàng
											MaterialOrderNo  VARCHAR(20),         -- Trạng thái đơn hàng
											SoLuongKeHoachNgay INT,               -- Ngày tạo đơn hàng
											NVLngay INT,               -- Ngày tạo đơn hàng
											UsedQtyDay DECIMAL ,                    -- Trạng thái hoàn thành
											IsAdditional Bit ,                    -- Trạng thái hoàn thành
											OrderDesc NVARCHAR(100) ,                -- Trạng thái hoàn thành
											CompanyCode VARCHAR(20) ,                 -- Trạng thái hoàn thành
											WorkCenterCode VARCHAR(20),                  -- Trạng thái hoàn thành
											QtyExp int ,             -- Trạng thái hoàn thành
											QtyByPO  int,            -- Trạng thái hoàn thành
											CreateDateTime DATETIME,        -- Thời gian tạo bản ghi
											CreateUserID NVARCHAR(50),       -- Người tạo bản ghi
											ChangeDateTime DATETIME,         -- Thời gian thay đổi bản ghi
											ChangeUserID NVARCHAR(50)      -- Người thay đổi bản ghi
									) XMLData
				) AS SourceTable
			ON
				(
					TargetTable.Id = SourceTable.Id
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
			--raiserror('bb',16,1)
		    DECLARE SourceData CURSOR FOR
                SELECT
                          'INSERT' AS IUD_FLAG,
							XMLData.OldId,
							XMLData.Id,
							XMLData.PONo ,
							XMLData.DayPlanNo ,
							XMLData.ChildMaterialCode ,
							XMLData.MaterialName ,            -- Mã dòng sản xuất
							XMLData.LineCode ,        -- Mã vật liệu
							XMLData.Plandate ,             -- Số lượng đơn hàng
							MaterialOrderNo ,         -- Trạng thái đơn hàng
							XMLData.SoLuongKeHoachNgay ,               -- Ngày tạo đơn hàng
							XMLData.NVLngay,               -- Ngày tạo đơn hàng
							XMLData.UsedQtyDay  ,                    -- Trạng thái hoàn thành
							XMLData.IsAdditional,                    -- Trạng thái hoàn thành
							XMLData.OrderDesc  ,                -- Trạng thái hoàn thành
							XMLData.CompanyCode  ,                 -- Trạng thái hoàn thành
							XMLData.WorkCenterCode ,                  -- Trạng thái hoàn thành
							XMLData.QtyExp  ,             -- Trạng thái hoàn thành
							XMLData.QtyByPO ,            -- Trạng thái hoàn thành
							XMLData.CreateDateTime,
							XMLData.CreateUserID,
							XMLData.ChangeDateTime,
							XMLData.ChangeUserID
							FROM
									OPENXML(@idoc , @InsertTableName , 2)
							        WITH  (
										    OldId VARCHAR(20),
											Id VARCHAR(20),
											PONo VARCHAR(20),
											DayPlanNo VARCHAR(20),
											ChildMaterialCode VARCHAR(50),
											MaterialName NVARCHAR(50),            -- Mã dòng sản xuất
											LineCode NVARCHAR(20),        -- Mã vật liệu
											Plandate DATETIME,             -- Số lượng đơn hàng
											MaterialOrderNo  VARCHAR(20),         -- Trạng thái đơn hàng
											SoLuongKeHoachNgay INT,               -- Ngày tạo đơn hàng
											NVLngay INT,               -- Ngày tạo đơn hàng
											UsedQtyDay DECIMAL ,                    -- Trạng thái hoàn thành
											IsAdditional Bit ,                    -- Trạng thái hoàn thành
											OrderDesc NVARCHAR(100) ,                -- Trạng thái hoàn thành
											CompanyCode VARCHAR(20) ,                 -- Trạng thái hoàn thành
											WorkCenterCode VARCHAR(20),                  -- Trạng thái hoàn thành
											QtyExp int ,             -- Trạng thái hoàn thành
											QtyByPO  int,            -- Trạng thái hoàn thành
											CreateDateTime DATETIME,        -- Thời gian tạo bản ghi
											CreateUserID NVARCHAR(50),       -- Người tạo bản ghi
											ChangeDateTime DATETIME,         -- Thời gian thay đổi bản ghi
											ChangeUserID NVARCHAR(50)      -- Người thay đổi bản ghi
											) XMLData
							UNION ALL
							SELECT
									'UPDATE' AS IUD_FLAG,
												CASE
													WHEN XMLData.OldId IS NULL THEN XMLData.Id
													ELSE XMLData.OldId
												END AS OldId,
												XMLData.Id,
												XMLData.PONo ,
												XMLData.DayPlanNo ,
												XMLData.ChildMaterialCode ,
												XMLData.MaterialName ,            -- Mã dòng sản xuất
												XMLData.LineCode ,        -- Mã vật liệu
												XMLData.Plandate ,             -- Số lượng đơn hàng
												MaterialOrderNo ,         -- Trạng thái đơn hàng
												XMLData.SoLuongKeHoachNgay ,               -- Ngày tạo đơn hàng
												XMLData.NVLngay,               -- Ngày tạo đơn hàng
												XMLData.UsedQtyDay  ,                    -- Trạng thái hoàn thành
												XMLData.IsAdditional,                    -- Trạng thái hoàn thành
												XMLData.OrderDesc  ,                -- Trạng thái hoàn thành
												XMLData.CompanyCode  ,                 -- Trạng thái hoàn thành
												XMLData.WorkCenterCode ,                  -- Trạng thái hoàn thành
												XMLData.QtyExp  ,             -- Trạng thái hoàn thành
												XMLData.QtyByPO ,            -- Trạng thái hoàn thành
												XMLData.CreateDateTime,
												XMLData.CreateUserID,
												XMLData.ChangeDateTime,
												XMLData.ChangeUserID
							FROM
									OPENXML(@idoc , @UpdateTableName , 2)
							        WITH  (
										    OldId VARCHAR(20),
											Id VARCHAR(20),
											PONo VARCHAR(20),
											DayPlanNo VARCHAR(20),
											ChildMaterialCode VARCHAR(50),
											MaterialName NVARCHAR(50),            -- Mã dòng sản xuất
											LineCode NVARCHAR(20),        -- Mã vật liệu
											Plandate DATETIME,             -- Số lượng đơn hàng
											MaterialOrderNo  VARCHAR(20),         -- Trạng thái đơn hàng
											SoLuongKeHoachNgay INT,               -- Ngày tạo đơn hàng
											NVLngay INT,               -- Ngày tạo đơn hàng
											UsedQtyDay DECIMAL ,                    -- Trạng thái hoàn thành
											IsAdditional Bit ,                    -- Trạng thái hoàn thành
											OrderDesc NVARCHAR(100) ,                -- Trạng thái hoàn thành
											CompanyCode VARCHAR(20) ,                 -- Trạng thái hoàn thành
											WorkCenterCode VARCHAR(20),                  -- Trạng thái hoàn thành
											QtyExp int ,             -- Trạng thái hoàn thành
											QtyByPO  int,            -- Trạng thái hoàn thành
											CreateDateTime DATETIME,        -- Thời gian tạo bản ghi
											CreateUserID NVARCHAR(50),       -- Người tạo bản ghi
											ChangeDateTime DATETIME,         -- Thời gian thay đổi bản ghi
											ChangeUserID NVARCHAR(50)      -- Người thay đổi bản ghi
											) XMLData
							UNION ALL
							SELECT
									'DELETE' AS IUD_FLAG,
										CASE
													WHEN XMLData.OldId IS NULL THEN XMLData.Id
													ELSE XMLData.OldId
												END AS OldId,
												XMLData.Id,
												XMLData.PONo ,
												XMLData.DayPlanNo ,
												XMLData.ChildMaterialCode ,
												XMLData.MaterialName ,            -- Mã dòng sản xuất
												XMLData.LineCode ,        -- Mã vật liệu
												XMLData.Plandate ,             -- Số lượng đơn hàng
												MaterialOrderNo ,         -- Trạng thái đơn hàng
												XMLData.SoLuongKeHoachNgay ,               -- Ngày tạo đơn hàng
												XMLData.NVLngay,               -- Ngày tạo đơn hàng
												XMLData.UsedQtyDay  ,                    -- Trạng thái hoàn thành
												XMLData.IsAdditional,                    -- Trạng thái hoàn thành
												XMLData.OrderDesc  ,                -- Trạng thái hoàn thành
												XMLData.CompanyCode  ,                 -- Trạng thái hoàn thành
												XMLData.WorkCenterCode ,                  -- Trạng thái hoàn thành
												XMLData.QtyExp  ,             -- Trạng thái hoàn thành
												XMLData.QtyByPO ,            -- Trạng thái hoàn thành
												XMLData.CreateDateTime,
												XMLData.CreateUserID,
												XMLData.ChangeDateTime,
												XMLData.ChangeUserID
							FROM
									OPENXML(@idoc , @DeleteTableName , 2)
							        WITH  (
										  OldId VARCHAR(20),
											Id VARCHAR(20),
											PONo VARCHAR(20),
											DayPlanNo VARCHAR(20),
											ChildMaterialCode VARCHAR(50),
											MaterialName NVARCHAR(50),            -- Mã dòng sản xuất
											LineCode NVARCHAR(20),        -- Mã vật liệu
											Plandate DATETIME,             -- Số lượng đơn hàng
											MaterialOrderNo  VARCHAR(20),         -- Trạng thái đơn hàng
											SoLuongKeHoachNgay INT,               -- Ngày tạo đơn hàng
											NVLngay INT,               -- Ngày tạo đơn hàng
											UsedQtyDay DECIMAL ,                    -- Trạng thái hoàn thành
											IsAdditional Bit ,                    -- Trạng thái hoàn thành
											OrderDesc NVARCHAR(100) ,                -- Trạng thái hoàn thành
											CompanyCode VARCHAR(20) ,                 -- Trạng thái hoàn thành
											WorkCenterCode VARCHAR(20),                  -- Trạng thái hoàn thành
											QtyExp int ,             -- Trạng thái hoàn thành
											QtyByPO  int,            -- Trạng thái hoàn thành
											CreateDateTime DATETIME,        -- Thời gian tạo bản ghi
											CreateUserID NVARCHAR(50),       -- Người tạo bản ghi
											ChangeDateTime DATETIME,         -- Thời gian thay đổi bản ghi
											ChangeUserID NVARCHAR(50)      -- Người thay đổi bản ghi
											) XMLData


            OPEN SourceData

            WHILE 1 = 1 BEGIN
                FETCH NEXT FROM SourceData INTO
								@IUD_FLAG,
								@OldId ,
								@Id ,
								@PONo ,
								@DayPlanNo,
								@ChildMaterialCode,
								@MaterialName,
								@LineCode ,
								@Plandate ,
								@MaterialOrderNo,
								@SoLuongKeHoachNgay,
								@NVLngay,
								@UsedQtyDay,
								@IsAdditional,
								@OrderDesc,
								@CompanyCode ,
								@WorkCenterCode,
								@QtyExp,
								@QtyByPO,
								@CreateDateTime ,
								@CreateUserID ,
								@ChangeDateTime,
								@ChangeUserID 


                IF @@FETCH_STATUS <> 0 BEGIN
					BREAK
				END
                IF @IUD_FLAG = 'INSERT' BEGIN
						RAISERROR('Neu muon order them NVL su dung man hinh F242 tap 2', 16, 1 )
						RETURN;
     --               IF EXISTS (SELECT 1 FROM STB_DayMaterialOrder  WHERE id = @id) BEGIN
					--	RAISERROR('Duplicate Data : KeyField = %s', 16, 1, @id)
					--END

     --               IF @IsAutoKey = 1 BEGIN
					--	EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_DayMaterialOrder', @MaterialOrderNo OUTPUT
     --               END
                    
					------ 임시SEQUENCE TABLE 사용버젼 : MASTER 처리
					----INSERT INTO #SEQUENCE_TABLE
					----	(KeyValue, UID_KEY)
					----VALUES
					----	(@MaterialOrderNo, @OldMaterialOrderNo)
					----                      

     --               INSERT INTO STB_DayMaterialOrder 
					--	(
					--		PONo ,
					--		DayPlanNo,
					--		ChildMaterialCode,
					--		MaterialName,
					--		LineCode ,
					--		Plandate ,
					--		MaterialOrderNo,
					--		SoLuongKeHoachNgay,
					--		NVLngay,
					--		UsedQtyDay,
					--		IsAdditional,
					--		OrderDesc,
					--		CompanyCode ,
					--		WorkCenterCode,
					--		QtyExp,
					--		QtyByPO,
					--		CreateDateTime,
					--		CreateUserID,
					--		ChangeDateTime,
					--		ChangeUserID
					--	)
					--	VALUES
					--	(
						    
					--		@PONo ,
					--		@DayPlanNo,
					--		@ChildMaterialCode,
					--		@MaterialName,
					--		@LineCode ,
					--		@Plandate ,
					--		@MaterialOrderNo,
					--		@SoLuongKeHoachNgay,
					--		@NVLngay,
					--		@UsedQtyDay,
					--		@IsAdditional,
					--		@OrderDesc,
					--		@CompanyCode ,
					--		@WorkCenterCode,
					--		@QtyExp,
					--		@QtyByPO,
					--	    GETDATE(),
					--	    @pProcessUserID,
					--	    @ChangeDateTime,
					--	    @ChangeUserID
					--	)

				END ELSE IF @IUD_FLAG = 'UPDATE' BEGIN
						--raiserror(@pIsChangeProduct,16,1)
						if(@pIsChangeProduct ='F243' and @QtyExp>=0)
							begin
							 
									raiserror (N'Kho nguyên vật liệu đã xuất rồi, bạn không thể thay đổi số lượng đầu vào ',16,1)
									return;
							end 
					
					--IF @OrderStatus <> 'REQUEST' BEGIN
					--	RAISERROR('CurrentOrderStatus  = %s', 16, 1, @OrderStatus)
					--END
					
                    UPDATE STB_DayMaterialOrder
					SET
						    PONo =   CASE
						                WHEN @PONo IS NOT NULL THEN @PONo
						                ELSE PONo
						            END,
						    DayPlanNo =   CASE
						                WHEN @DayPlanNo IS NOT NULL THEN @DayPlanNo
						                ELSE DayPlanNo
						            END,
						    ChildMaterialCode =   CASE
						                WHEN @ChildMaterialCode IS NOT NULL THEN @ChildMaterialCode
						                ELSE ChildMaterialCode
						            END,
						    MaterialName =   CASE
						                WHEN @MaterialName IS NOT NULL THEN @MaterialName
						                ELSE MaterialName
						            END,
						    LineCode =   CASE
						                WHEN @LineCode IS NOT NULL THEN @LineCode
						                ELSE LineCode
						            END,
						    Plandate =   CASE
						                WHEN @Plandate IS NOT NULL THEN @Plandate
						                ELSE Plandate
						            END,
						    MaterialOrderNo =   CASE
						                WHEN @MaterialOrderNo IS NOT NULL THEN @MaterialOrderNo
						                ELSE MaterialOrderNo
						            END,
						    SoLuongKeHoachNgay =   CASE
						                WHEN @SoLuongKeHoachNgay IS NOT NULL THEN @SoLuongKeHoachNgay
						                ELSE SoLuongKeHoachNgay
						            END,


							    NVLngay =   CASE
						                WHEN @NVLngay IS NOT NULL THEN @NVLngay
						                ELSE NVLngay
						            END,

									    UsedQtyDay =   CASE
						                WHEN @UsedQtyDay IS NOT NULL THEN @UsedQtyDay
						                ELSE UsedQtyDay
						            END,

									    IsAdditional =   CASE
						                WHEN @IsAdditional IS NOT NULL THEN @IsAdditional
						                ELSE IsAdditional
						            END,

									    OrderDesc =   CASE
						                WHEN @OrderDesc IS NOT NULL THEN @OrderDesc
						                ELSE OrderDesc
						            END,

									    CompanyCode =   CASE
						                WHEN @CompanyCode IS NOT NULL THEN @CompanyCode
						                ELSE CompanyCode
						            END,
									  WorkCenterCode =   CASE
						                WHEN @WorkCenterCode IS NOT NULL THEN @WorkCenterCode
						                ELSE WorkCenterCode
						            END,
									  QtyExp =   CASE
						                WHEN @QtyExp IS NOT NULL THEN @QtyExp
						                ELSE QtyExp
						            END,
									  QtyByPO =   CASE
						                WHEN @QtyByPO IS NOT NULL THEN @QtyByPO
						                ELSE QtyByPO
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
						    ChangeUserID = @pProcessUserID
						WHERE
						    Id = @OldId 
                END ELSE IF @IUD_FLAG = 'DELETE' BEGIN
					
					--IF @OrderStatus <> 'REQUEST' BEGIN
					--	RAISERROR('CurrentOrderStatus  = %s', 16, 1, @OrderStatus)
					--END
							if(@pIsChangeProduct ='F243' and @QtyExp>=0)
							begin
							 
									raiserror (N'Kho nguyên vật liệu đã xuất rồi, bạn không thể xóa yêu cầu ',16,1)
									return;
							end 
                    DELETE FROM STB_DayMaterialOrder
						WHERE
						     Id = @Id
					
					--DELETE FROM STB_MaterialOrderItem
					--WHERE
					--		MaterialOrderNo = @MaterialOrderNo
							
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
