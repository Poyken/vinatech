
-- =============================================
-- Author:	    Kim Han Young(hykim@awoo.co.kr)
-- Create date: 2016-09-26
-- Browsable : true
-- Group : 재고관리 > [F740] 자재 Lot수량조정 > Main조회
-- Description:	분리된 재고정보를 조회합니다.
-- Modified: 
--                2020.06.15 바코드오류 (제조일자, 유효일자 추가)

-- [프로시저 실행문] exec usp_GetMaterialLotInfo '','','VVT','VVT_F1',' ','ML20190414000159'
-- =============================================
CREATE PROCEDURE [dbo].[usp_GetMergeMaterialLot]
						@pProcessUserID VARCHAR(20),
						@pProcessLanguage VARCHAR(20),
						@pWorkerCode VARCHAR(20) = NULL,
						@pLotId VARCHAR(50) = NULL,
						@pFromDate DATETIME= NULL,
						@pToDate DATETIME= NULL
AS
BEGIN
	SET NOCOUNT ON;
	-- Declare necessary variables
	DECLARE @LotId VARCHAR(50) = @pLotId  
	DECLARE @MergeParentId VARCHAR(50) 
	DECLARE @MergeQty INT = 0
	Declare @FromDate DATE = @pFromDate
	, @ToDate DATE = @pToDate

	-- Get MergeParentId if LotId exists
	SELECT @MergeParentId = MergeParentId 
	FROM STB_MaterialLotInfo
	WHERE LotId = @LotId;

	-- Convert dates
	SET @pFromDate = CONVERT(datetime, CONVERT(varchar(10), @pFromDate, 120) + ' 10:00:00', 120);
	SET @pToDate = CONVERT(datetime, CONVERT(varchar(10), DATEADD(day, 1, @pToDate), 120) + ' 10:00:00', 120);
 
	-- Declare Lot CTE
	;WITH Lot AS
	(
		SELECT MLI.MaterialLotNo
		FROM STB_MaterialLotInfo MLI WITH(NOLOCK)
		WHERE 
			-- Check if LotId is provided or not
			(
				(@LotId <>''AND (LotId = @LotId OR LotId = @MergeParentId))  -- If LotId exists, search by LotId or MergeParentId
				OR
				(@LotId ='' And LotId in (select MergeParentId from STB_MaterialLotInfo where  MergeParentId is not null )   AND CreateDateTime BETWEEN @pFromDate AND @pToDate) -- If LotId is NULL, search by Date Range
			)
	)
	-- Main Query
	SELECT
		MLI.MaterialLotNo AS OldMaterialLotNo,
		MLI.MaterialLotNo,
		MLI.LotID,
		MLI.CompanyCode,
		MLI.WorkCenterCode,
		MLI.MaterialWarehouseCode,
		MW.MaterialWarehouseName,
		MLI.MaterialLocationCode,
		ML.MaterialLocationName,
		MLI.MaterialCode,
		MM.MaterialName,
		MM.MaterialTypeCode,
		MT.MaterialTypeName,
		MM.ProductGroupCode,
		PG.ProductGroupName,
		MM.MaterialSpec,
		MLI.MaterialStockAttribute,
		MLI.StockAttrib1,
		MLI.StockAttrib2,
		MLI.StockAttrib3,
		MLI.PackingID,
		MLI.GRDate,
		MLI.MaterialDeliveryNo,
		MLI.MaterialDeliveryDetailNo,
		MLI.InitialQty,
		MLI.CurrentQty,
		MLI.CurrentQty AS StockQty,
		MLI.PickingQty,
		MLI.CurrentQty - MLI.PickingQty AS AvailableQty,
		MLI.VendorLotNo,
		MLI.LifeBasicDate,
		MLI.ProductionDate,
		MLI.EndOfLifeDate,
		MLI.LotNo,
		MLI.IsSplitLot,
		CONVERT(NUMERIC(20,5), NULL) AS SplitQty,	-- Dummy column for stock split
		MLI.BefMaterialLotNo,
		MLI.CreateDateTime,
		MLI.CreateUserID,
		MLI.ChangeDateTime,
		MLI.ChangeUserID,
		MLI.PackingIdParent,

		-- Additional columns
		ISNULL(MDLI.Lotattr10, MLI.LotAttr10) AS LotAttr10,  -- Manufacturing date
		CONVERT(VARCHAR(10), DATEADD(DAY, -1, CONVERT(VARCHAR(10), DATEADD(MM, MM.MMExtInt01, MLI.Lotattr10), 121)), 121) AS PackDate, -- Packaging date
		MLI.isSlitting, 
		@MergeQty as MergeQty
	FROM
		Lot L
		INNER JOIN STB_MaterialLotInfo MLI WITH(NOLOCK) ON MLI.MaterialLotNo = L.MaterialLotNo
		LEFT OUTER JOIN STB_MaterialMaster MM WITH(NOLOCK) ON MLI.MaterialCode = MM.MaterialCode
		LEFT OUTER JOIN STB_MaterialType MT WITH(NOLOCK) ON MM.MaterialTypeCode = MT.MaterialTypeCode 
		LEFT OUTER JOIN STB_ProductGroup PG WITH(NOLOCK) ON PG.ProductGroupCode = MM.ProductGroupCode
		LEFT OUTER JOIN STB_MaterialWarehouse MW WITH(NOLOCK) ON MW.MaterialWarehouseCode = MLI.MaterialWarehouseCode
		LEFT OUTER JOIN STB_MaterialLocation ML WITH(NOLOCK) ON ML.MaterialLocationCode = MLI.MaterialLocationCode
		LEFT OUTER JOIN STB_MaterialDocLotInfo MDLI WITH(NOLOCK) ON MLI.MaterialCode = MDLI.MaterialCode AND MLI.LotNo = MDLI.LotNo AND MLI.LOTID = MDLI.LOTID
	WHERE
		MLI.CurrentQty > 0
END
