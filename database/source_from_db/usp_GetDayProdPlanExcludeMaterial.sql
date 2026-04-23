-- =============================================
-- Author:	Jeon Gyeong Ho(khjun@awoo.co.kr)
-- Browsable : true
-- Group : 생산관리
-- Create date: 2019-10-14
-- Description:	기종변경을 위한 일일계획를 불러옵니다
-- =============================================
CREATE PROCEDURE [dbo].[usp_GetDayProdPlanExcludeMaterial] -- exec usp_GetDayProdPlanExcludeMaterial 'DinhManh', 'vi', 'VVT', 'VVT_F1', '', '2025-08-15', '2025-08-25', '', 'MDL', ''
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pCompanyCode VARCHAR(20) = NULL,
	@pWorkCenterCode VARCHAR(20) = NULL,
	@pLineCode VARCHAR(20) = NULL,
	@pFromDate DATE = NULL,
	@pToDate DATE = NULL,
	@pExcludeMaterialCode VARCHAR(50) = NULL,
	@pPOType VARCHAR(20) = 'FERT',
	@pBarcode VARCHAR(20) = NULL
AS
BEGIN
	SET NOCOUNT ON;


	declare @pSize VARCHAR(20) = NULL

	select 
	@pSize=RIGHT('0' + CONVERT(VARCHAR, CONVERT(INT, MBI.MBISizeW)), 2) + RIGHT('0' + CONVERT(VARCHAR, CONVERT(INT, MBI.MBISizeH)), 2) 
	from STB_ModelBasicInfo mbi with(nolock) 
	where ModelCode = ( select MaterialCode from STB_SetInfo  with(nolock) where Barcode=@pBarcode)


	if(isnull(@pBarcode,'')<>''  and len(isnull(@pSize,''))<4  ) begin
		raiserror(N'Not yet setup Model Size in A410 Screen / Chưa thiết lập Kích thước ở màn A410',16,1)
		return
	end


	DECLARE @CompanyCode VARCHAR(20) = @pCompanyCode,
			@WorkCenterCode VARCHAR(20) = @pWorkCenterCode,
			@LineCode VARCHAR(20) = CASE WHEN ISNULL(@pLineCode,'') = '' THEN '%' ELSE @pLineCode END,
			@FromDate DATE = @pFromDate,
			@ToDate DATE = @pToDate,
			@ExcludeMaterialCode VARCHAR(50) = @pExcludeMaterialCode,
			@POType VARCHAR(20) = @pPOType

			

	SELECT
			DPP.CompanyCode,
			DPP.WorkCenterCode,
			DPP.PONo,
			DPP.DayPlanNo,
			--isnull(DPP.LineCode,Li.LineCode)as LineCode,
		
			DPP.LineCode,
			LI.LineName,
			DPP.MaterialCode,
			MM.MaterialName,
			DPP.PlanDate,
			DPP.PlanQty
	FROM
			STB_DayProdPlan DPP WITH(NOLOCK)
			LEFT OUTER JOIN STB_MaterialMaster MM WITH(NOLOCK)
				ON DPP.MaterialCode = MM.MaterialCode
			INNER JOIN STB_ProductionOrderInfo POI WITH(NOLOCK)
				ON POI.PONo = DPP.PONo AND
				(POI.POType = @POType 
				OR POI.POType = 'MODULE')			----update 2025-08-25 following Ms.Phuong request
			left outer join STB_ModelBasicInfo mbi  WITH(NOLOCK)
				on mbi.ModelCode = DPP.MaterialCode
			--right JOIN STB_LineInfo LI WITH(NOLOCK)
			--	ON LI.LineCode = DPP.LineCode
			LEFT OUTER JOIN STB_LineInfo LI WITH(NOLOCK)
				ON LI.LineCode = DPP.LineCode
	WHERE
			(DPP.CompanyCode = @CompanyCode or DPP.CompanyCode =(select CompanyCode from STB_UserInfo	where UserID=@pProcessUserID) ) AND --Add by Mr.Tung 2022-03-21 for query VVT PO
			(DPP.WorkCenterCode = @WorkCenterCode or  DPP.WorkCenterCode =(select WorkCenterCode from STB_UserInfo	where UserID=@pProcessUserID) ) AND--Add by Mr.Tung 2022-03-21 for query VVT PO
			DPP.LineCode LIKE @LineCode AND
			DPP.PlanDate >= @FromDate AND
			DPP.PlanDate <= @ToDate AND
			DPP.MaterialCode NOT IN (@ExcludeMaterialCode) AND
			isnull(MM.MaterialTypeCode,mbi.MaterialTypeCode) IN ( 'FERT', 'MDL') AND --update 2025-08-23 following Ms.Phuong request
			DPP.IsFixed = 1 AND
			DPP.IsCancel = 0	and
			(RIGHT('0' + CONVERT(VARCHAR, CONVERT(INT, MBI.MBISizeW)), 2) + 
				 RIGHT('0' + CONVERT(VARCHAR, CONVERT(INT, MBI.MBISizeH)), 2) = @pSize  or  isnull(@pSize,'') = '' )
 END

