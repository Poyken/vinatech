
-- =============================================
-- Author: Park Jong Hoon(jhpark@awoo.co.kr)
-- Create date: 2016-02-04
-- Browsable : true
-- Group : 자재관리
-- Description:	자재발주전표 IUD
-- Modified:  usp_DayMaterialOrderAndAdditional_NotExported '','','VVT','VVT_F1','2024-11-26','2024-12-26','','','' 
-- Modified:  usp_DayMaterialOrderAndAdditional_his '','','','','','','','','241023000016' 
-- =============================================
CREATE PROCEDURE [dbo].[usp_DayMaterialOrderAndAdditional_NotExported]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pCompanyCode VARCHAR(20) = NULL,
	@pWorkCenterCode VARCHAR(20) = NULL,
	@pFromDate DATE = NULL,
	@pToDate DATE = NULL,
	@pLineCode VARCHAR(20) = NULL,
	@pMaterialCode VARCHAR(20) = NULL,
	@pPoNo VARCHAR(20) = NULL
AS
BEGIN
	SET NOCOUNT ON;


		 DECLARE @CompanyCode VARCHAR(20) = CASE WHEN ISNULL(@pCompanyCode,'') = '' THEN '%' ELSE @pCompanyCode END
		DECLARE @WorkCenterCode VARCHAR(20) = CASE WHEN ISNULL(@pWorkCenterCode,'') = '' THEN '%' ELSE @pWorkCenterCode END
		DECLARE @LineCode VARCHAR(30) = CASE WHEN ISNULL(@pLineCode,'') = '' THEN '%' ELSE @pLineCode END
		--DECLARE @FromDate DATE = @pFromDate
		--DECLARE @ToDate DATE = @pToDate

		declare @FromDate varchar(19) =   convert(varchar(10),@pFromDate,120) + ' 10:00:00'
		declare @ToDate  varchar(19)  =  case when @pFromDate=@pToDate then convert(varchar(10),dateadd(day,1,@pToDate),120)  + ' 10:00:00' else convert(varchar(10),@pToDate,120) + ' 10:00:00' end
		--raiserror(@ToDate,16,1)
		DECLARE @MaterialCode VARCHAR(30) = CASE WHEN ISNULL(@pMaterialCode,'') = '' THEN '%' ELSE @pMaterialCode END			 
		DECLARE @PoNo VARCHAR(30) = @pPoNo
		 --raiserror(@pPoNo,16,1)
	

		IF (@pPoNo IS NULL OR @pPoNo = '') 
					begin
							
								select
										PONo,
										DayPlanNo,
										ChildMaterialCode,
										MaterialName,
										LineCode,
										CONVERT(DATE, Plandate) AS Plandate,  -- Chuyển đổi Plandate sang kiểu DATE
										CreateDateTime,
										CreateUserID,
										ChangeDateTime,
										ChangeUserID,
										MaterialOrderNo,
										SoLuongKeHoachNgay,
										NVLngay,
										case when PlanShiftCode='1' then N'Ngày' else N'Đêm' end  PlanShiftCode,
										UsedQtyDay,
										IsAdditional,
										OrderDesc,
										CompanyCode,
										WorkCenterCode,
										QtyExp,
										QtyByPO,
										Id,
										ExportDesc,
										ExportDateTime,
										ExportUserID,
										ExportChangeTime,
										ExportChangeUserID
										 from STB_DayMaterialOrder 
							where 
								CAST(CreateDateTime AS DATE) BETWEEN @FromDate AND @ToDate
								AND  WorkCenterCode LIKE @WorkCenterCode 
								AND  LineCode LIKE @LineCode
								AND (QtyExp =0 or QtyExp ='' or QtyExp is null )
							order by createdatetime DESc
					end
		else
					begin
			
								select
										PONo,
										DayPlanNo,
										ChildMaterialCode,
										MaterialName,
										LineCode,
										CONVERT(DATE, Plandate) AS Plandate,  -- Chuyển đổi Plandate sang kiểu DATE
										CreateDateTime,
										CreateUserID,
										ChangeDateTime,
										ChangeUserID,
										MaterialOrderNo,
										SoLuongKeHoachNgay,
										NVLngay,
										case when PlanShiftCode='1' then N'Ngày' else N'Đêm' end  PlanShiftCode,
										UsedQtyDay,
										IsAdditional,
										OrderDesc,
										CompanyCode,
										WorkCenterCode,
										QtyExp,
										QtyByPO,
										Id,
										ExportDesc,
										ExportDateTime,
										ExportUserID,
										ExportChangeTime,
										ExportChangeUserID from STB_DayMaterialOrder 
							where 
								 Pono=@PoNo
								 AND ( QtyExp =0 or QtyExp ='' or QtyExp is null )
							order by createdatetime DESc
					end




				
				 

END
----       usp_DayMaterialOrderAndAdditional_NotExported '','','VVT','VVT_F1','2024-12-02','2024-12-02','','','' 
----       usp_DayMaterialOrderAndAdditional_NotExported '','','VVT','VVT_F1','2024-12-05','2024-12-05','','','' 

-----  update STB_DayMaterialOrder set StatusWarehouseConfirm =0, ExportChangeTime = null  where MaterialOrderNo = '20241203000001'
 -----      StatusWarehouseConfirm


 -- select * from STB_MaterialWarehouseInOutHist where lotId = 'ML20240604000563' linecode='vvc-03' ---and materialcode = 'GCMDPT-380'
 -- and CAST(CreateDateTime  AS DATE)  BETWEEN '2024-12-05' AND'2024-12-05' 

 --select * from STB_DayMaterialOrder  where  CAST(CreateDateTime  AS DATE)  BETWEEN '2024-12-05' AND'2024-12-05'  		 where linecode='vvc-03' 
				 
	--			 and MaterialCode  = 'GCMDPT-380'



