-- =============================================
-- Author:		DinhManh
-- Create date: 2025-04-22
-- Description:	separate Lot for OQC
-- =============================================
CREATE PROCEDURE [dbo].[usp_DoProcessOQCrefer_VVT_div]
	-- Add the parameters for the stored procedure here
		@pProcessUserID VARCHAR(20),
		@pProcessLanguage VARCHAR(20),
		@pProcessViewName VARCHAR(50),
		@pXml NVARCHAR(MAX) = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
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
	DECLARE @LevelBx VARCHAR(10)
	DECLARE @iDoc INT
	DECLARE @ccount NUMERIC(20,5)
	DECLARE @MergeID VARCHAR(50)

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
					InProdQty,
					LevelBx
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
								InProdQty NUMERIC(20,5),
								LevelBx varchar(10)
							)
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
								@InProdQty,
								@LevelBx

            IF @@FETCH_STATUS <> 0 BEGIN
				BREAK
			END

			--declare @Barcode1 varchar(60) = @Barcode + @LevelBx;
			--RAISERROR( @Barcode1 ,16, 1);			
			--return;

			IF (CHARINDEX('-', @Barcode) = 0) 
				BEGIN
					select @ccount = count(*)
					from VVT_OQC_REFER
					where lotid = @Barcode and (finished = '1' or finished <> '' or finished is not null)
			

					if(@ccount>0) begin
						declare @errBarcode varchar(60) = 'Ma Lot: ' + @Barcode + ' da duoc Tach lan truoc!';
						RAISERROR( @errBarcode ,16, 1);
						return;
					end


					if @LevelBx is null or @LevelBx='' begin
						declare @errlevel varchar(60) = 'Ma Lot: ' + @Barcode + ' chua chon Level Box!';
						RAISERROR( @errlevel ,16, 1);
						return;
					end


					if @MergeID is null or @MergeID='' begin
						select @MergeID = @Barcode
					end

					insert into VVT_OQC_REFER(lotid,mergeid,mergedate,levelB, finished, isSeparated, CreateUserID) values (@Barcode,@MergeID,getdate(), @LevelBx,NULL, '1', @pProcessUserID);

				END
			ELSE IF (CHARINDEX('-', @Barcode) > 0) 
				BEGIN
					

					select @ccount = count(*)
					from VVT_OQC_REFER
					where lotid = @Barcode and (finished = '1' or finished <> '' or finished is not null)
			

					if(@ccount>0) begin
						declare @errBarcode2 varchar(60) = 'Ma Lot: ' + @Barcode + ' da duoc Tach lan truoc!';
						RAISERROR( @errBarcode2 ,16, 1);
						return;
					end


					if @LevelBx is null or @LevelBx='' begin
						declare @errlevel2 varchar(60) = 'Ma Lot: ' + @Barcode + ' chua chon Level Box!';
						RAISERROR( @errlevel2 ,16, 1);
						return;
					end

					if @MergeID is null or @MergeID='' begin
						select @MergeID = SUBSTRING(@Barcode, 1, CHARINDEX('-', @Barcode) - 1)
					end
					

					insert into VVT_OQC_REFER(lotid,mergeid,mergedate,levelB, finished, isSeparated, CreateUserID) values (@Barcode,@MergeID,getdate(), @LevelBx,NULL, '1', @pProcessUserID);
				END
		END	

		--neu ko co loi gi thi update ket thuc gop box
		update VVT_OQC_REFER
		set finished='1'
		where mergeid=@MergeID;


    END TRY
	BEGIN CATCH
		SET @ERROR_MSG = ERROR_MESSAGE()
		RAISERROR( @ERROR_MSG ,16, 1)
	END CATCH
			
	CLOSE SourceData;
	DEALLOCATE SourceData;
			
	EXEC sp_xml_removedocument @idoc
END
