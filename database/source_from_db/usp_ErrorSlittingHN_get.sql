-- =============================================
-- Author:		DinhManh
-- Create date: 2025-02-06
-- Description:	Get all NG Slitting material for Ha Nam Factory
-- =============================================


-- usp_ErrorSlittingHN_get '', '', '2024-01-01', '2025-02-06'

CREATE PROCEDURE [dbo].[usp_ErrorSlittingHN_get]
	-- Add the parameters for the stored procedure here
						@pProcessUserID VARCHAR(20),
						@pProcessLanguage VARCHAR(20),
						--@pCompanyCode VARCHAR(20)=NULL,
						--@pWorkCenterCode VARCHAR(20)=NULL,
						--@pMaterialCode VARCHAR(50)=NULL,
						--@pLotID VARCHAR(100) = NULL,
						--@pMaterialWarehouseCode VARCHAR(20) = NULL,
						@pFromDate DATETIME = NULL,
						@pToDate DATETIME = NULL

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	--cái này để lấy theo thời gian bắt đầu ngày mới 
	DECLARE @FromDate VARCHAR(19) = CONVERT(VARCHAR(10), @pFromDate, 120) + ' 10:00:00'
	DECLARE @ToDate VARCHAR(19) = CONVERT(VARCHAR(10), DATEADD(day, 1, @pToDate), 120) + ' 10:00:00'

	--DECLARE @FromDate DATETIME = @pFromDate
	--DECLARE @ToDate DATETIME = @pToDate


	
	SELECT
			
					MLI.MaterialLotNo AS OldMaterialLotNo,
					MLI.MaterialLotNo,
					MLI.LotID,
					MLI.CompanyCode,
					MLI.WorkCenterCode,
					MLI.MaterialWarehouseCode,
					MLI.MaterialLocationCode,
					MLI.MaterialCode,
					MM.MaterialName,
					(Select		MLI2.MaterialCode 
							from STB_MaterialLotInfo MLI2
							where MLI2.LotID = MLI.PackingID 
					) 	as MaterialCodeFoil,
					(Select		MM2.MaterialName 
							from STB_MaterialMaster MM2
							left join STB_MaterialLotInfo MLI2 on MM2.MaterialCode = MLI2.MaterialCode
							where MLI2.LotID = MLI.PackingID 
					) 	as MaterialNameFoil,
					MLI.MaterialStockAttribute,
					MLI.StockAttrib1,
					MLI.StockAttrib2,
					MLI.StockAttrib3,
					MLI.PackingID,
					MLI.GRDate,
					MLI.MaterialDeliveryNo,
					MLI.MaterialDeliveryDetailNo,
					MLI.InitialQty,
					MLI.CurrentQty as CurrentQty,
					--@ActualExportQuantity as ParentCurrentQty , 
					MLI.PickingQty,
					MLI.VendorLotNo,
					MLI.LifeBasicDate,
					MLI.ProductionDate,
					MLI.EndOfLifeDate,
					MLI.LotNo,
					MLI.IsSplitLot,
					MLI.BefMaterialLotNo,
					MLI.LotAttr01,
					MLI.LotAttr02,
					MLI.LotAttr03,
					MLI.LotAttr04,
					MLI.LotAttr05,
					MLI.LotAttr06,
					MLI.LotAttr07,
					MLI.LotAttr08,
					MLI.LotAttr09,
					MLI.LotAttr10,
					MLI.CreateDateTime,
					MLI.CreateUserID,
					MLI.ChangeDateTime,
					MLI.ChangeUserID,
					MLI.DateConfirmEx,
					MLI.HoldError,
					MLI.Holddate,
					MLI.HoldPeriod,
					MLI.PackingIdParent,
					MLI.IsSlitting,
					MLI.CheckTime,
					MLI.CheckUserID,
					MLI.IsCheck,
					MLI.LengthSlitting,
					(Select		MM2.MaterialUnit
							from STB_MaterialMaster MM2
							left join STB_MaterialLotInfo MLI2 on MM2.MaterialCode = MLI2.MaterialCode
							where MLI2.LotID = MLI.PackingID 
					) 	as MaterialUnit
				
			
	FROM     STB_MaterialLotInfo MLI WITH(NOLOCK)			
			LEFT OUTER JOIN STB_MaterialMaster MM WITH(NOLOCK)			ON	MLI.MaterialCode = MM.MaterialCode
			LEFT OUTER JOIN STB_MaterialType MT WITH(NOLOCK)			ON	MM.MaterialTypeCode = MT.MaterialTypeCode 
			LEFT OUTER JOIN STB_ProductGroup PG WITH(NOLOCK)			ON	PG.ProductGroupCode = MM.ProductGroupCode
			LEFT OUTER JOIN STB_MaterialWarehouse MW WITH(NOLOCK)		ON	MW.MaterialWarehouseCode = MLI.MaterialWarehouseCode
			LEFT OUTER JOIN STB_MaterialLocation ML WITH(NOLOCK)		ON	ML.MaterialLocationCode = MLI.MaterialLocationCode

				
	WHERE 1=1
			AND MLI.LotID LIKE 'SL%'
			AND MLI.MaterialWarehouseCode = 'NG_RAW_VN_WH'	
			AND MLI.IsCheck = 'Reject'

			AND MLI.CheckTime BETWEEN @FromDate AND @ToDate -- thời gian mà QC kiểm tra và đánh giá reject



END
