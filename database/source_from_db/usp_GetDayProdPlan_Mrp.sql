

-- =============================================
-- Author:	Jeon Gyeong Ho(khjun@awoo.co.kr)
-- Create date: 2018-10-01
-- Browsable : true
-- Group : 선택대화상자
-- Description:	일일 생산계획정보를 가져옵니다
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_GetDayProdPlan_Mrp]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pCompanyCode VARCHAR(20) = NULL,
	@pFromDate DATE = NULL,
	@pToDate DATE = NULL,
	@pBarcode VARCHAR(20) = NULL
AS
BEGIN
	SET NOCOUNT ON;

	--declare @pSize VARCHAR(20) = NULL

	--select 
	--@pSize=RIGHT('0' + CONVERT(VARCHAR, CONVERT(INT, MBI.MBISizeW)), 2) + RIGHT('0' + CONVERT(VARCHAR, CONVERT(INT, MBI.MBISizeH)), 2) 
	--from STB_ModelBasicInfo mbi with(nolock) 
	--where ModelCode = ( select MaterialCode from STB_SetInfo  with(nolock) where Barcode=@pBarcode)


	--if(isnull(@pBarcode,'')<>''  and len(isnull(@pSize,''))<4  ) begin
	--	raiserror(N'Not yet setup Model Size in A410 Screen / Chưa thiết lập Kích thước ở màn A410',16,1)
	--	return
	--end


	DECLARE @CompanyCode VARCHAR(20) = @pCompanyCode,
			@FromDate DATE = @pFromDate,
			@ToDate DATE = @pToDate

	SELECT
			DPP.CompanyCode,
			DPP.WorkCenterCode,
			DPP.PONo,
			DPP.LineCode,
			LI.LineName,
			DPP.MaterialCode,
			MM.MaterialName,
			DPP.BomVersion,
			DPP.PlanDate,
			DPP.PlanShiftCode,
			SC.Shift,
			DPP.PlanQty
	FROM 
			STB_DayProdPlan DPP WITH(NOLOCK)
			INNER JOIN STB_LineInfo LI WITH(NOLOCK)
				ON LI.LineCode = DPP.LineCode
			INNER JOIN STB_MaterialMaster MM WITH(NOLOCK)
				ON MM.MaterialCode = DPP.MaterialCode
			left outer join STB_ModelBasicInfo mbi  WITH(NOLOCK)
				on mbi.ModelCode = DPP.MaterialCode
			LEFT OUTER JOIN VW_ShiftCode SC
				ON SC.ShiftCode = DPP.PlanShiftCode
	WHERE
			DPP.CompanyCode = @CompanyCode AND
			DPP.PlanDate >= @FromDate AND
			DPP.PlanDate <= @ToDate AND
			DPP.IsFixed = 1 AND
			DPP.IsCancel = 0	
			--and (RIGHT('0' + CONVERT(VARCHAR, CONVERT(INT, MBI.MBISizeW)), 2) + 
			--	 RIGHT('0' + CONVERT(VARCHAR, CONVERT(INT, MBI.MBISizeH)), 2) = @pSize  or  isnull(@pSize,'') = '' )
END


