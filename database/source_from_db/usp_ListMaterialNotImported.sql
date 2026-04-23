-- =============================================
-- Author:		Mr.Duy
-- Create date: 2024-07-11
-- Description:	Lấy danh sách xuất nvl nhưng chưa dùng trên line
-- exec usp_ListMaterialNotImported
CREATE PROCEDURE [dbo].[usp_ListMaterialNotImported]
		@pProcessUserID VARCHAR(20)=NULL,
	@pProcessLanguage VARCHAR(20)=NULL,
	@pFromDate DATETIME = NULL,
	@pToDate DATETIME = NULL
AS
BEGIN

	SET NOCOUNT ON;
		DECLARE @FromDate DATETIME  = @pFromDate
		DECLARE @ToDate DATETIME    = @pToDate

		;with MaterialWarehouseInOutHist as(
		select a.*,b.MaterialCode from STB_MaterialWarehouseInOutHist a 
		left join STB_MaterialDocLotInfo b  on a.LotID = b.LotID
		where a.CreateDateTime >= @pFromDate and a.CreateDateTime <= @pToDate
		and SourceMaterialWarehouseCode in ('ROH_VN_WH','ROH_BG_WH')
		and TargetMaterialWarehouseCode in ('ROUTE_VN_WH','ROUTE_BG_WH')
		and WarehouseInOutCode ='O' 
		),
		RawMaterialInputHist as(
	
			select * from STB_RawMaterialInputHist b where b.CreateDateTime >= '2024-07-20'
		),
		ouput as (
		select aa.*,bb.Barcode,bb.LotMaterialCode  from MaterialWarehouseInOutHist aa
		LEFT JOIN RawMaterialInputHist bb on aa.LotID = bb.LotMaterialCode
		where bb.LotMaterialCode is null
		)
		select * from ouput
END


