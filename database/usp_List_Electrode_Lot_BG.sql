Text
----
-- =============================================

-- Author:		Mr.Duy

-- Create date: 2024-08-08

-- Description:	L?y danh sách lot di?n c?c dã c?t chua b?n lên h? th?ng. exec usp_List_Electrode_Lot_BG '','','2024-11-20','2024-11-28'

-- =============================================

CREATE PROCEDURE [dbo].[usp_List_Electrode_Lot_BG]

		@pProcessUserID varchar(20),

		@pProcessLanguage varchar(20),

		@pFromDate DATETIME = NULL,

		@pToDate DATETIME = NULL

AS

BEGIN

	SET NOCOUNT ON;



	DECLARE @FromDate DATETIME  = @pFromDate

	DECLARE @ToDate DATETIME    = @pToDate



	SELECT ESR.*, 

       MM.MaterialCode, 

       MM.MaterialName, 

       slt.Location, 

       slt.WarehouseCode,

       CASE 

           WHEN DATEDIFF(day, ESR.Createdatetime, GETDATE()) > 90 THEN 'Exprired'

           WHEN DATEDIFF(day, ESR.Createdatetime, GETDATE()) BETWEEN 87 AND 90 THEN 'Warning'

           ELSE 'Normal'

       END AS Duration

FROM STB_ElectrodeSlittingResult ESR WITH (NOLOCK)

LEFT OUTER JOIN STB_SetInfo SI WITH (NOLOCK) ON ESR.ElectrodeLotNumber = SI.Barcode

LEFT OUTER JOIN STB_MaterialMaster MM WITH (NOLOCK) ON MM.MaterialCode = SI.MaterialCode

LEFT OUTER JOIN Stb_SlittingStock_VVT slt ON ESR.Barcode = slt.Barcode

LEFT OUTER JOIN STB_RawMaterialInputHist ss WITH (NOLOCK) 

    ON ESR.Barcode = ss.LotMaterialCode 

       --AND ss.ProductGroupCode IN ('Electrolyte','ElectrodeM') 

       AND ss.Createdatetime >= '2024-05-01'

WHERE ss.LotMaterialCode IS NULL

  AND ESR.WorkCenterCode = 'VVT_F2'

  and	ESR.TransferDateTime>=@FromDate

  and	ESR.TransferDateTime<=@ToDate

  AND (slt.WarehouseCode NOT IN ('ROUTE_VN_WH', 'HOLDING_BG_WH') OR slt.WarehouseCode IS NULL);



  /*

	select ESR.*,MM.MaterialCode,MM.MaterialName,slt.Location,slt.WarehouseCode,

	case 

		when DATEDIFF(day,ESR.Createdatetime,getdate()) >90

		then 'Exprired'

		when DATEDIFF(day,ESR.Createdatetime,getdate()) >=87 And DATEDIFF(day,ESR.Createdatetime,getdate()) <=90

		then 'Warning'

		else

		'Normal'

		end as Duration



	  FROM STB_ElectrodeSlittingResult ESR WITH(NOLOCK) 

	  --left outer join STB_RawMaterialInputHist ss WITH(NOLOCK)  on ESR.Barcode = ss.LotMaterialCode

	  LEFT OUTER JOIN STB_SetInfo SI WITH(NOLOCK)   ON ESR.ElectrodeLotNumber = SI.Barcode

	  LEFT OUTER JOIN STB_MaterialMaster MM WITH(NOLOCK)  ON MM.MaterialCode = SI.MaterialCode

	  LEFT OUTER JOIN Stb_SlittingStock_VVT slt on esr.Barcode = slt.Barcode

	  where 

	 -- ss.LotMaterialCode is null -- l?y ra danh sách không thu?c b?ng STB_RawMaterialInputHist nh?p ? B597

	  NOT EXISTS 

	  (select LotMaterialCode from STB_RawMaterialInputHist ss where ESR.Barcode = ss.LotMaterialCode and ss.LotMaterialCode is not null and ProductGroupCode in ('Electrolyte')

	  and createdatetime >='2024-05-01'

	  ) 

	  and ESR.WorkCenterCode='VVT_F2'

	  --and	ESR.CreateDateTime>=@FromDate

	  --and ESR.CreateDateTime<=@ToDate

	  and (slt.WarehouseCode not in ('ROUTE_VN_WH','HOLDING_BG_WH') or slt.WarehouseCode is null)*/

END

--select * from Stb_SlittingStock_VVT where  barcode='VJOQ2710501E01-001'

-- select * from STB_SlittingLocationConfig_VVT where PArtno='2245'



