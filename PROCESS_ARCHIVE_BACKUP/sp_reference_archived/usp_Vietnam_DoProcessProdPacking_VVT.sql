-- =============================================
-- Author:	    Mr.Tung
-- Create date: 2021-05-27
-- =============================================
CREATE PROCEDURE [dbo].[usp_Vietnam_DoProcessProdPacking_VVT]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
    @pProcessViewName VARCHAR(50),
	@pXml NVARCHAR(MAX) = NULL,
	@pMergeQty INT = NULL
AS
BEGIN
	SET NOCOUNT ON;

    DECLARE @ProcessUserID VARCHAR(20) = @pProcessUserID
	DECLARE @ProcessLanguage VARCHAR(20) = @pProcessLanguage
    DECLARE @ProcessViewName VARCHAR(50) = @pProcessViewName
    DECLARE @TableName VARCHAR(100) = '/DataSet/' + @ProcessViewName
    --DECLARE @UpdateTableName VARCHAR(100) = '/DataSet/' + @ProcessViewName + '_UPDATE'
    --DECLARE @DeleteTableName VARCHAR(100) = '/DataSet/' + @ProcessViewName + '_DELETE'
	DECLARE @ERROR_MSG NVARCHAR(MAX)
    
    DECLARE @ProcessDateTime DATETIME = GETDATE()
	DECLARE @LineCode VARCHAR(20)
	DECLARE @RouteCode VARCHAR(20)
	DECLARE @ControlNo VARCHAR(20)
	DECLARE @Barcode VARCHAR(50)
	DECLARE @StockAttrib1 VARCHAR(20)
	DECLARE @MaterialCode VARCHAR(50)
	DECLARE @WorkerCode VARCHAR(20)
	DECLARE @MachineID VARCHAR(20)
	DECLARE @InProdQty NUMERIC(20,5)
	DECLARE @BoxID VARCHAR(50)
	DECLARE @PackingID VARCHAR(50)
	DECLARE @ProdQty NUMERIC(20,5)
	DECLARE @iDoc INT

	EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml

    BEGIN TRY
		DECLARE SourceData CURSOR FOR
            SELECT
					LineCode,
					RouteCode,
					MaterialCode,
					ControlNo,
					Barcode,
					StockAttrib1,
					WorkerCode,
					MachineID,
					ProdQty,
					InProdQty
			FROM
					OPENXML(@idoc , @TableName , 2)
					WITH  (
								LineCode VARCHAR(20),
								RouteCode VARCHAR(20),
								MaterialCode VARCHAR(50),
								ControlNo VARCHAR(20),
								Barcode VARCHAR(50),
								StockAttrib1 VARCHAR(20),
								WorkerCode VARCHAR(20),
								MachineID VARCHAR(20),
								ProdQty NUMERIC(20,5),
								InProdQty NUMERIC(20,5)
							)




		declare @data1 nvarchar(1000)
		declare @count INT = 0
		declare @total INT = 0
		declare @checkBreak INT = 0

			--raiserror(@data1,16,1)
		if (@pMergeQty is null) begin
				select @data1 = N'Bạn cần chọn SLG BOX từ danh sách số lượng Gộp Box' --bên cạnh Mã BARCODE ở chỗ V Tìm kiếm nhé!'
				raiserror(@data1,16,1)
				return
		end	
								

			--if(@pProcessUserID='nguyentung1234')
			--begin
			
			--		OPEN SourceData
			--		WHILE 1 = 1 BEGIN
			--			FETCH NEXT FROM SourceData INTO
			--								@LineCode,
			--								@RouteCode,
			--								@MaterialCode,
			--								@ControlNo,
			--								@Barcode,
			--								@StockAttrib1,
			--								@WorkerCode,
			--								@MachineID,
			--								@ProdQty,
			--								@InProdQty
											
			--			IF @@FETCH_STATUS <> 0 BEGIN
			--				BREAK
			--			END

			--			if ( (@count >= @@cursor_rows-1)  or  (@pMergeQty < @total + @InProdQty) ) 
			--					begin									
																			
			--								if  (@pMergeQty < @total + @InProdQty)
			--									begin
			--										select @InProdQty = @pMergeQty - @total
			--										select @checkBreak = 1
			--									end
			--								else
			--									begin
			--										select @total = @total + @InProdQty
			--										select @checkBreak = 0
			--									end

			--							--raiserror(@Barcode,16,1)
			--							--return
			--							--if  @checkBreak = 1, break sau khi insert PACKING ONE									
			--					end
			--			else
			--				select @total = @total + @InProdQty
				

			--			select @count=@count+1

			--			if (@checkBreak>0) begin
			--				BREAK
			--			end

			--		end

			--	select @data1 = convert (varchar(20),@InProdQty)
			--	raiserror(@data1,16,1)
			--   return

			--end

			

		select @count  = 0
		select @total  = 0
		select @checkBreak  = 0


        OPEN SourceData
        WHILE 1 = 1 BEGIN
            FETCH NEXT FROM SourceData INTO
								@LineCode,
								@RouteCode,
								@MaterialCode,
								@ControlNo,
								@Barcode,
								@StockAttrib1,
								@WorkerCode,
								@MachineID,
								@ProdQty,
								@InProdQty

            IF @@FETCH_STATUS <> 0 BEGIN
				BREAK
			END
			
			 
				if ( (@count >= @@cursor_rows-1)  or  (@pMergeQty < @total + @InProdQty) )  -- if Sum of Lot (in GridView) is greater than the Merge Qty  / or had FETCH last Lot
						begin									
																			
									if  (@pMergeQty < @total + @InProdQty)
										begin
											select @InProdQty = @pMergeQty - @total
											select @checkBreak = 1
										end
									else
										begin
											select @total = @total + @InProdQty
											select @checkBreak = 0
										end
							
						end
				else
					select @total = @total + @InProdQty  --else if Sum of Lot (in GridView) is less than the Merge Qty   and   not last Lot
				

			select @count=@count+1
		
			--declare @aa varchar(20) = @InProdQty
			--RAISERROR(@Barcode,16,1)
			EXEC usp_DoProcessProdPackingByOne_VNT	@pProcessUserID = @ProcessUserID,
													@pProcessLanguage = @ProcessLanguage,
													@pLineCode = @LineCode,
													@pRouteCode = @RouteCode,
													@pBarcode = @Barcode,
													@pStockAttrib1 = @StockAttrib1,
													@pWorkerCode = @WorkerCode,
													@pMachineID = @MachineID,
													@pInProdQty = @InProdQty,
													@pPackingID = @PackingID OUTPUT

			if (@checkBreak>0) begin
				 BREAK
			end

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
