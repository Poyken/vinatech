Text
----
-- =============================================

-- Author:		Mr.Duy

-- Create date: 2024-07-11

-- Description:	L?y danh sách xu?t nvl nhung chua dùng trên line

-- exec usp_ListElectronNotImported

-- =============================================

CREATE PROCEDURE [dbo].[usp_ListElectronNotImported]

	@pProcessUserID VARCHAR(20)=NULL,

	@pProcessLanguage VARCHAR(20)=NULL,

	@pFromDate DATETIME = NULL,

	@pToDate DATETIME = NULL

AS

BEGIN

	SET NOCOUNT ON;

	/*

		;with MaterialWarehouseInOutHist as(

			

			select * from Stb_SlittingStock_VVT b where b.listdate is not null and b.listdate >= '2024-07-20' and WarehouseCode in ('ROUTE_VN_WH')

		),

		RawMaterialInputHist as(

			select * from STB_RawMaterialInputHist b where b.CreateDateTime >= '2024-07-20'

		),

		ouput as (

		select aa.*,bb.Barcode as barcode1 from MaterialWarehouseInOutHist aa

		LEFT JOIN RawMaterialInputHist bb on aa.Barcode = bb.LotMaterialCode

		where bb.LotMaterialCode is null

		)

		select * from ouput

		*/

	DECLARE @FromDate DATETIME  = @pFromDate

	DECLARE @ToDate DATETIME    = @pToDate





	select ESR.*,MM.MaterialCode,MM.MaterialName

	  FROM STB_ElectrodeSlittingResult ESR WITH(NOLOCK) 

	  left outer join STB_RawMaterialInputHist ss WITH(NOLOCK)  on ESR.Barcode = ss.LotMaterialCode

	  LEFT OUTER JOIN STB_SetInfo SI WITH(NOLOCK)   ON ESR.ElectrodeLotNumber = SI.Barcode

	  LEFT OUTER JOIN STB_MaterialMaster MM WITH(NOLOCK)  ON MM.MaterialCode = SI.MaterialCode

	  where 

	  1=1

	  and ss.LotMaterialCode is null -- l?y ra danh sách chua nh?p trên B597

	 -- and ESR.WorkCenterCode='VVT_F1'

	  and	ESR.CreateDateTime>=@FromDate

	  and ESR.CreateDateTime<=@ToDate

END

