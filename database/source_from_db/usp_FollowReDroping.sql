-- =============================================
-- Author : Ha Nguyen
-- Group : 
-- Browsable : true
-- Create date : 2014-07-04
-- Description :
-- Modified :
--               
-- 프로시저실행 : 
-- ======================================================================================
-- usp_ProductReDroping_get'2024-07-04','2024-07-04'

--EXEC usp_FollowReDroping '',''
 
CREATE PROCEDURE [dbo].[usp_FollowReDroping]
						@pFromDate DATE = NULL,
						@pToDate DATE = NULL
						
AS

BEGIN
						DECLARE @FromDate DATETIME                   = @pFromDate
						DECLARE @ToDate DATETIME                      = @pToDate
			
						;with Table1  as (
						select
						PO.DefectSummaryNoBeforeDroping as OldDefectSummaryNo,
						PO.LotBeforeReDroping as OldLotNo,
						SI.PONo as OldPoNo,
						PO.PONo as NewPoNo
						 from STB_ProductionOrderInfo PO 
						left join  STB_SetInfo SI  on  Po.LotBeforeReDroping =SI.Barcode
						where  PO.DefectSummaryNoBeforeDroping is not null and  PO.LotBeforeReDroping is not null
				), table2 as (
						select 
						tb1.OldPoNo,
						tb1.OldDefectSummaryNo, 
						tb1.OldLotNo,
						tb1.NewPoNo,
						SI.Barcode as Newbarcode,
						SI.CreateDateTime as CreateDateTime
						from table1 tb1
								left join  STB_SetInfo SI  on  tb1.NewPoNo =SI.PONo 
						
				) select * from table2 
				 --where CONVERT(date, CreateDateTime) >=@FromDate and CONVERT(date, CreateDateTime) <=@ToDate

				
END

--select * from STB_ProductionOrderInfo where Pono = 240708000019