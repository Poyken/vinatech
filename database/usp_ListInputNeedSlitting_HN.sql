Text
----
-- =============================================

-- Author:		Mr.Duy

-- Create date: 2025-02-10

-- Description:	L?y danh sách c?n c?t khi kho nguyên v?t li?u chuy?n sang kho c?t

-- ============================================= exec usp_ListInputNeedSlitting_HN 'anhduy157','vi','VVT','VVT_F3','','SLITTING_HN_WH'

CREATE PROCEDURE [dbo].[usp_ListInputNeedSlitting_HN] 

	@pProcessUserID VARCHAR(20),

	@pProcessLanguage VARCHAR(20),

	@pCompanyCode VARCHAR(20)=NULL,

	@pWorkCenterCode VARCHAR(20)=NULL,

	@pMaterialCode VARCHAR(50)=NULL,

	@pMaterialWarehouseCode VARCHAR(20) = NULL

AS

BEGIN

	-- SET NOCOUNT ON added to prevent extra result sets from

	-- interfering with SELECT statements.

	SET NOCOUNT ON;



  SET NOCOUNT ON;

	





	DECLARE @CompanyCode VARCHAR(20) = CASE WHEN ISNULL(@pCompanyCode,'') = '' THEN '*' ELSE @pCompanyCode END

	DECLARE @WorkCenterCode VARCHAR(20) =CASE WHEN ISNULL(@pWorkCenterCode,'') = '' THEN '*' ELSE @pWorkCenterCode END 

	DECLARE @MaterialCode VARCHAR(50) = CASE WHEN ISNULL(@pMaterialCode,'') = '' THEN '*' ELSE @pMaterialCode END 

	DECLARE @PackingID varchar(50) 











	DECLARE @LotID VARCHAR(50) = CASE WHEN ISNULL('*','') = '' THEN '*' ELSE '*' END 



	--	select @LotID=packingid from stb_materiallotinfo where lotid = (select packingid from STB_MaterialLotInfo where LotID=@pLotID)



	--DECLARE @LotNo VARCHAR(50) = @pLotNo

	DECLARE @MaterialWarehouseCode VARCHAR(20) = CASE WHEN ISNULL(@pMaterialWarehouseCode,'') = '' THEN '*' ELSE @pMaterialWarehouseCode END



	Declare @SumCurrentQty NUMERIC(20,5)	,@remaQty NUMERIC(20,5)

	declare @sumTotalTem int

	Declare @ActualExportQuantity NUMERIC(20,5)





	select @SumCurrentQty =SUM(CurrentQty),@sumTotalTem=COUNT(*) from STB_MaterialLotInfo where PackingIdParent=@LotID and lotid <> PackingID -- l?y ra t?ng s? lu?ng dã chia

	select @remaQty = ActualExportQuantity - isnull(@SumCurrentQty,0) ,@ActualExportQuantity= ActualExportQuantity from STB_MaterialWarehouseInOutHist where lotID=@LotID  and SourceMaterialWarehouseCode='ROH_HN_WH' and TargetMaterialWarehouseCode='SLITTING_H
N_WH'  -- l?y ra t?ng s? lu?ng còn l?i dã chia

	--print @sumTotalTem

	declare @sumCurentVarcha varchar(20)=isnull(@SumCurrentQty,0) --chuy?n s? lu?ng sang d?ng varchar

	declare @remaQtyVarcha varchar(20)=isnull(@remaQty,0) 

	;

	WITH Lot AS

	(

		SELECT

				MLI.MaterialLotNo,Lotid

		FROM

				STB_MaterialLotInfo MLI WITH(NOLOCK)

		WHERE

				(@CompanyCode = '*' OR MLI.CompanyCode = @CompanyCode) AND

				(@WorkCenterCode = '*' OR  MLI.WorkCenterCode = @WorkCenterCode) AND

				(@MaterialCode = '*' OR  MLI.MaterialCode = @MaterialCode) AND

				((@MaterialWarehouseCode = '*') OR (MLI.MaterialWarehouseCode = @MaterialWarehouseCode))

				And (MLI.IsParrent ='1' or MLI.IsParrent is not null) -- l?y các lot có IsParrent là lot cha d? c?t

				and (MLI.IsSlitting = 0 or MLI.IsSlitting is null) -- ch? l?y các lot chua du?c c?t

				and (@LotID = '*' OR MLI.Lotid = @LotID)

	)    

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

			@sumCurentVarcha as PickingQty,

			@sumTotalTem as sumTotalTem,

			@remaQtyVarcha as remaQty,

			MLI.CurrentQty - MLI.PickingQty AS AvailableQty,

			MLI.VendorLotNo,

			MLI.LifeBasicDate,

			MLI.ProductionDate,

			MLI.EndOfLifeDate,

			MLI.LotNo,

			MLI.IsSplitLot,

			CONVERT(NUMERIC(20,5), NULL) AS SplitQty,	-- ????? ?? DUMMY ??

			MLI.BefMaterialLotNo,

			MLI.CreateDateTime,

			MLI.CreateUserID,

			MLI.ChangeDateTime,

			MLI.ChangeUserID,

			--'MATERIAL_LABEL' AS LabelType,

			--'MATERIAL' AS LabelType,

			--'MaterialLabel' AS LabelFormatName,



			'PartLabel' AS LabelType,                        --2020.04.08

			'????' AS LabelFormatName,			

			'Report' AS CommandType,

			MM.MaterialUnit,

			MM.MMExtText02,

			MM.MMExtText03 



			-- ????

			,  ISNULL(MDLI.Lotattr10, MLI.LotAttr10)          AS LotAttr10    --????

			, CONVERT(VARCHAR(10), DATEADD(DAY, -1, CONVERT(VARCHAR(10), DATEADD(MM,  MM.MMExtInt01, MLI.Lotattr10), 121)), 121)  AS PackDate	  --Mr.Duy s?a 2023-12-12 l?y ngày dóng gói	 c?a lot m?i tách

			--, CONVERT(VARCHAR(10), DATEADD(DAY, -1, CONVERT(VARCHAR(10), DATEADD(MM,  MM.MMExtInt01, MDLI.Lotattr10), 121)), 121)  AS PackDate	  --????	

			,MLI.isSlitting	

			,@ActualExportQuantity as ActualExportQuantity

			,MWIOH.CreateUserID as CreateUserIDOut	 

			,MWIOH.CreateDateTime as CreateDateTimeOut

	FROM

			Lot L

			LEFT OUTER JOIN STB_MaterialLotInfo MLI WITH(NOLOCK)				ON	MLI.MaterialLotNo = L.MaterialLotNo

			LEFT OUTER JOIN STB_MaterialWarehouseInOutHist MWIOH WITH(NOLOCK)				ON	MWIOH.Lotid = MLI.Lotid

				-- DinhManh update 2025-04-10

				AND MWIOH.TargetMaterialWarehouseCode = 'SLITTING_HN_WH' 

				AND MWIOH.CreateDateTime = (SELECT MAX(MWIO2.CreateDateTime) FROM STB_MaterialWarehouseInOutHist MWIO2 where MWIO2.LotID = MWIOH.LotID)

			LEFT OUTER JOIN STB_MaterialMaster MM WITH(NOLOCK)		ON	MLI.MaterialCode = MM.MaterialCode

			LEFT OUTER JOIN STB_MaterialType MT WITH(NOLOCK)			ON	MM.MaterialTypeCode = MT.MaterialTypeCode 

			LEFT OUTER JOIN STB_ProductGroup PG WITH(NOLOCK)			ON	PG.ProductGroupCode = MM.ProductGroupCode

			LEFT OUTER JOIN STB_MaterialWarehouse MW WITH(NOLOCK)	ON	MW.MaterialWarehouseCode = MLI.MaterialWarehouseCode

			LEFT OUTER JOIN STB_MaterialLocation ML WITH(NOLOCK)		ON	ML.MaterialLocationCode = MLI.MaterialLocationCode

						

			LEFT OUTER JOIN STB_MaterialDocLotInfo MDLI  WITH(NOLOCK)				

			ON	MLI.MaterialCode = MDLI.MaterialCode     AND     MLI.LotNo = MDLI.LotNo                    

			AND MLI.LOTID = MDLI.LOTID        -- 2020.06.15

			where MM.ProductGroupCode in ('CON-PAPER','ANODE-FOIL','CATHODE-FOIL')







END

