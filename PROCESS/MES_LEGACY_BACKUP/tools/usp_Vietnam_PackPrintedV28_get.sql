-- =============================================
-- Author:		DinhManh
-- Create date: 2025-03-22
-- Description:	Lấy các Lot đã in tem ở công đoạn V-28
-- =============================================
CREATE PROCEDURE [dbo].[usp_Vietnam_PackPrintedV28_get]
	-- Add the parameters for the stored procedure here
		--@pProcessUserID VARCHAR(20)= NULL,
		@pFromDate DATETIME ,
		@pToDate DATETIME, 
		@WorkCenterCode NVARCHAR(10)
AS
	--DECLARE @FromDate   VARCHAR(19) = CONVERT(VARCHAR(10), @pFromDate, 120) + ' 10:00:00'                                                        
	--DECLARE @ToDate      VARCHAR(19) = CONVERT(VARCHAR(10), DATEADD(DAY, 1, CONVERT(smalldatetime, @pToDate)), 120) + ' 10:00:00'  
	--DECLARE	@LotNo VARCHAR(20) = CASE WHEN ISNULL(@pLotNo, '') = ''         THEN '*' ELSE @pLotNo END


	DECLARE @FromDate  VARCHAR(19) = CASE WHEN ISNULL(@pFromDate, '') = ''		THEN CAST(GETDATE() AS DATE) ELSE @pFromDate END 
	DECLARE @ToDate  VARCHAR(19) = CASE WHEN ISNULL(@pFromDate, '') = ''		THEN CAST(GETDATE() AS DATE) ELSE @pToDate END


BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	

	IF @WorkCenterCode = 'VVT_F1'
	BEGIN
	

		-- Tìm thông tin các Lot đã in
		;with getLotNoPrinted as 
		(
			SELECT  
				
				id,
				(select top 1 newbarcode from STB_LotChangeMaterialHistory WITH(NOLOCK) where oldBarcode=LotNo) as newLotno
				,LotNo,
				PackingID,
				MaterialCode,
				MaterialName,
				EmpNo,
				PrintTime,
				PackQty, 
				isPrinted,
				PartNo,
				(ROW_NUMBER() over (partition by LotNo,isPrinted order by PackQty desc,printtime desc) ) as RowPackQty--
				  --ISNULL(DRI.PackQty, 0) * ISNULL(vwup.ProcessUnitPriceEA,0)  as Price
				FROM  [SmartFactoryV2].[dbo].[STB_SavePackingTime_VVT] DRI  WITH(NOLOCK) 

				where 1=1 
				and  EmpNo not in ('test_worker','assy_packing' )
				--and PrintTime between (case when @LotNo is not null and @LotNo<>'*' then '2020-08-15 10:00:00' else @FromDate end) 
				--and (case when @LotNo is not null and @LotNo<>'*' then CONVERT(varchar(19),getdate(),120) else @ToDate end) 
				and PackQty > 1 
				--and ( isPrinted = 0 or isPrinted = (case when @LotNo is not null and @LotNo<>'*' then 1 else 0 end)  )	\
				and isPrinted = 1
				AND (PrintTime BETWEEN @FromDate  AND  @ToDate)
		)
		,

		-- các lot đã in ở công đoạn V-28
		getLotNoV28 as 
		(
			SELECT 
				id,
				newLotno,
				a.LotNo,
				a.PackingID,
				a.MaterialCode,
				MaterialName,
				EmpNo,
				PrintTime,
				PackQty --* (select count(LotNo) from stb_materialLotinfo  WITH(NOLOCK) where LotNo =a.LotNo) as PackQty
				,isPrinted,PartNo
				,b.InputLineCode,c.ProdDateTime,b.ControlNo,
				(ROW_NUMBER() over (partition by a.LotNo,isPrinted order by PackQty desc,printtime desc) ) as RowPackQty2
				FROM getLotNoPrinted a WITH(NOLOCK) 
				join STB_MaterialLotInfo MLI WITH(NOLOCK)  ON (MLI.PackingID = a.PackingID)
				join STB_SetInfo b WITH(NOLOCK)  on  (a.LotNo=b.Barcode or a.newLotno=b.Barcode)
				join STB_ProdRouteHist c  WITH(NOLOCK) on b.ControlNo=c.ControlNo and c.RouteCode= 'V-28'
					--case 
					--	when @pWorkCenterCode = 'VVT_F1'then'V-28'
					--	when @pWorkCenterCode = 'VVT_F2'then'V-28_BG'
					--	when @pWorkCenterCode = 'VVT_F3'then'VE10'
					--	else ''
					--end
				where 1=1 
				   and  EmpNo not in ('test_worker','assy_packing' )
				   and (RowPackQty=1)

		),
		tmp_FinishGood as (
			SELECT * FROM STB_VN_FINISHGOODS
			where CreateDate BETWEEN @FromDate and @ToDate
		)
		SELECT  
			N'Bắc Ninh' as WorkCenterCode,
			DRI.id,
			DRI.newLotno,
			DRI.LotNo,
			DRI.PackingID,
			DRI.MaterialCode,
			DRI.MaterialName,
			DRI.EmpNo,
			DRI.PrintTime,
			DRI.PackQty
			, DRI.PartNo
			, InputLineCode,
			ProdDateTime,
			ControlNo
			FROM getLotNoV28  DRI WITH(NOLOCK) 

			left outer join STB_VVT_StagePrices vwup on vwup.model = DRI.MaterialCode and 'V-28' like '%'+vwup.RouteV28+'%'

			LEFT JOIN tmp_FinishGood FG ON FG.PackingID = DRI.PackingID

			where 1=1 
				and  DRI.EmpNo not in ('test_worker','assy_packing','assy_packing2','roh_worker','electrode_worker','dryroom_worker' )
				and DRI.PackQty>1
				--and NOT EXISTS (SELECT 1 from STB_VN_FINISHGOODS FG where FG.PackingID = DRI.PackingID) -- so sánh vs FG01
				--and NOT EXISTS (SELECT 1 from STB_VN_FINISHGOODS FG where FG.LotNo = DRI.LotNo) -- so sánh vs FG01
				AND FG.PackingID IS NULL
				and YEAR(PrintTime) >= '2025'
				and (RowPackQty2=1)

			
		
			--order by PrintTime desc, LotNo, EmpNo 

	END
	
	ELSE IF @WorkCenterCode = 'VVT_F2'
	BEGIN 
		;with getLotNoPrinted as 
		(
			SELECT  
				id,
				(select top 1 newbarcode from STB_LotChangeMaterialHistory WITH(NOLOCK) where oldBarcode=LotNo) as newLotno
				,LotNo,
				PackingID,
				MaterialCode,
				MaterialName,
				EmpNo,
				PrintTime,
				PackQty, 
				isPrinted,
				PartNo,
				(ROW_NUMBER() over (partition by LotNo,isPrinted order by PackQty desc,printtime desc) ) as RowPackQty--
				  --ISNULL(DRI.PackQty, 0) * ISNULL(vwup.ProcessUnitPriceEA,0)  as Price
				FROM  [SmartFactoryV2].[dbo].[STB_SavePackingTime_VVT] DRI  WITH(NOLOCK) 

				where 1=1 
				and  EmpNo not in ('test_worker','assy_packing' )
				--and PrintTime between (case when @LotNo is not null and @LotNo<>'*' then '2020-08-15 10:00:00' else @FromDate end) 
				--and (case when @LotNo is not null and @LotNo<>'*' then CONVERT(varchar(19),getdate(),120) else @ToDate end) 
				and PackQty > 1 
				--and ( isPrinted = 0 or isPrinted = (case when @LotNo is not null and @LotNo<>'*' then 1 else 0 end)  )	\
				and isPrinted = 1
				AND (PrintTime BETWEEN @FromDate  AND  @ToDate)
		)
		,

		-- các lot đã in ở công đoạn V-28
		getLotNoV28 as 
		(
			SELECT  
				id,
				newLotno,
				a.LotNo,
				a.PackingID,
				a.MaterialCode,
				MaterialName,
				EmpNo,
				PrintTime,
				PackQty --* (select count(LotNo) from stb_materialLotinfo  WITH(NOLOCK) where LotNo =a.LotNo) as PackQty
				,isPrinted,PartNo
				,b.InputLineCode,c.ProdDateTime,b.ControlNo,
				(ROW_NUMBER() over (partition by a.LotNo,isPrinted order by PackQty desc,printtime desc) ) as RowPackQty2
				FROM getLotNoPrinted a WITH(NOLOCK) 
				join STB_MaterialLotInfo MLI WITH(NOLOCK)  ON (MLI.PackingID = a.PackingID)
				join STB_SetInfo b WITH(NOLOCK)  on  (a.LotNo=b.Barcode or a.newLotno=b.Barcode)
				join STB_ProdRouteHist c  WITH(NOLOCK) on b.ControlNo=c.ControlNo and c.RouteCode= 'V-28_BG'
					--case 
					--	when @pWorkCenterCode = 'VVT_F1'then'V-28'
					--	when @pWorkCenterCode = 'VVT_F2'then'V-28_BG'
					--	when @pWorkCenterCode = 'VVT_F3'then'VE10'
					--	else ''
					--end
				where 1=1 
				   and  EmpNo not in ('test_worker','assy_packing' )
				   and (RowPackQty=1)

		),
		tmp_FinishGood as (
			SELECT * FROM STB_VN_FINISHGOODS_BG
			where CreateDate BETWEEN @FromDate and @ToDate
		)
		SELECT
			N'Bắc Giang' as WorkCenterCode,
			DRI.id,
			DRI.newLotno,
			DRI.LotNo,
			DRI.PackingID,
			DRI.MaterialCode,
			DRI.MaterialName,
			DRI.EmpNo,
			DRI.PrintTime,
			DRI.PackQty
			, DRI.PartNo
			, InputLineCode,
			ProdDateTime,
			ControlNo
			FROM getLotNoV28  DRI WITH(NOLOCK) 

			left outer join STB_VVT_StagePrices vwup on vwup.model = DRI.MaterialCode and 'V-28' like '%'+vwup.RouteV28+'%'

			LEFT JOIN tmp_FinishGood FG ON FG.PackingID = DRI.PackingID

			where 1=1 
				and  DRI.EmpNo not in ('test_worker','assy_packing','assy_packing2','roh_worker','electrode_worker','dryroom_worker' )
				and DRI.PackQty>1
				--and NOT EXISTS (SELECT 1 from STB_VN_FINISHGOODS FG where FG.PackingID = DRI.PackingID) -- so sánh vs FG01
				--and NOT EXISTS (SELECT 1 from STB_VN_FINISHGOODS FG where FG.LotNo = DRI.LotNo) -- so sánh vs FG01
				AND FG.PackingID IS NULL
				and YEAR(PrintTime) >= '2025'
				and (RowPackQty2=1)

			
		
			--order by PrintTime desc, LotNo, EmpNo 
	END
END
