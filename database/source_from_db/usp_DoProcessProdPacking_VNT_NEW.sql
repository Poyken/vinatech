-- =============================================
-- Author:	    kilee@vina.co.kr
-- Create date: 2020-06-09
-- Browsable : true
-- Group : 생산관리 > [B520] PackingID 생성화면 > PackingID 생성 -> 다른 프로시저 호출 : usp_DoProcessProdPackingByOne_VNT
-- Description:	기존 프로시저에서 변경된 사항
-- Modified:

-- EXEC [usp_DoProcessProdPacking_VNT_NEW] 'kilee','Korean','',''
-- =============================================
CREATE PROCEDURE [dbo].[usp_DoProcessProdPacking_VNT_NEW]
						@pProcessUserID VARCHAR(20),
						@pProcessLanguage VARCHAR(20),
						@pProcessViewName VARCHAR(50),
						@pXml NVARCHAR(MAX) = NULL
AS
BEGIN
	SET NOCOUNT ON;

    DECLARE @ProcessUserID VARCHAR(20) = @pProcessUserID
	DECLARE @ProcessLanguage VARCHAR(20) = @pProcessLanguage
    DECLARE @ProcessViewName VARCHAR(50) = @pProcessViewName
    DECLARE @TableName VARCHAR(100) = '/DataSet/' + @ProcessViewName
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
			
			EXEC usp_DoProcessProdPackingByOne_VNT_NEW	@pProcessUserID = @ProcessUserID,
													@pProcessLanguage = @ProcessLanguage,
													@pLineCode = @LineCode,
													@pRouteCode = @RouteCode,
													@pBarcode = @Barcode,
													@pStockAttrib1 = @StockAttrib1,
													@pWorkerCode = @WorkerCode,
													@pMachineID = @MachineID,
													@pInProdQty = @InProdQty,
													@pPackingID = @PackingID OUTPUT
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
