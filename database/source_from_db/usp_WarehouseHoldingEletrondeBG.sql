-- =============================================
-- Author:		Mr.Duy
-- Create date: 2024-10-04
-- Description:	Kho holding điện cực bắc giang 
-- exec usp_WarehouseHoldingEletrondeBG '','','',''
-- =============================================
CREATE PROCEDURE [dbo].[usp_WarehouseHoldingEletrondeBG]
		@pProcessUserID varchar(20),
		@pProcessLanguage varchar(20),
		@pFromDate DATETIME = NULL,
		@pToDate DATETIME = NULL
AS
BEGIN
SET NOCOUNT ON;

	DECLARE @FromDate DATETIME  = @pFromDate
	DECLARE @ToDate DATETIME    = @pToDate


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
	  LEFT OUTER JOIN STB_SetInfo SI WITH(NOLOCK)   ON ESR.ElectrodeLotNumber = SI.Barcode
	  LEFT OUTER JOIN STB_MaterialMaster MM WITH(NOLOCK)  ON MM.MaterialCode = SI.MaterialCode
	  LEFT OUTER JOIN Stb_SlittingStock_VVT slt on esr.Barcode = slt.Barcode
	  where 
	  1=1
	  and ESR.WorkCenterCode='VVT_F2'
	  --and	ESR.CreateDateTime>=@FromDate
	  --and ESR.CreateDateTime<=@ToDate
	  and slt.WarehouseCode in ('HOLDING_BG_WH')
END
