-- =============================================
-- Author:		Mr.Duy
-- Create date: 2024-10-07
-- Description:	Lịch sử xuất kho điện cực
-- ============================================= exec usp_HistoryExpportWarehouseElectronde '','','2024-10-06','2024-10-08'
CREATE PROCEDURE usp_HistoryExpportWarehouseElectronde
		@pProcessUserID varchar(20),
		@pProcessLanguage varchar(20),
		@pFromDate DATETIME = NULL,
		@pToDate DATETIME = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

   	DECLARE @FromDate DATETIME  = @pFromDate
	DECLARE @ToDate DATETIME    = @pToDate


	select ESR.*,MM.MaterialCode,MM.MaterialName,slt.Location,slt.WarehouseCode,slt.UpdateDateTimeExportProdution

	  FROM STB_ElectrodeSlittingResult ESR WITH(NOLOCK) 
	  LEFT OUTER JOIN STB_SetInfo SI WITH(NOLOCK)   ON ESR.ElectrodeLotNumber = SI.Barcode
	  LEFT OUTER JOIN STB_MaterialMaster MM WITH(NOLOCK)  ON MM.MaterialCode = SI.MaterialCode
	  LEFT OUTER JOIN Stb_SlittingStock_VVT slt on esr.Barcode = slt.Barcode
	  where 
	  1=1
	  and ESR.WorkCenterCode='VVT_F2'
	  and slt.UpdateDateTimeExportProdution>=@FromDate
	  and slt.UpdateDateTimeExportProdution<=@ToDate
	  and slt.WarehouseCode in ('ROUTE_VN_WH')
	 -- and slt.UpdateDateTimeExportProdution is not null
END
