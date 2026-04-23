-- =============================================
-- Author: Park Jong Hoon(jhpark@awoo.co.kr)
-- Create date: 2016-06-17
-- Browsable : true
-- Group : 금형관리
-- Description:	금형수정수리정보 조회
-- Modified:의신정밀->2018 스마트 공장으로 복사 
-- =============================================
CREATE PROCEDURE [dbo].[usp_MoldRepairHistory_get]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pCompanyCode VARCHAR(20) = NULL,
	@pCompanyName NVARCHAR(50) = NULL,
	@pWorkCenterCode VARCHAR(20) = NULL,
	@pWorkCenterName NVARCHAR(50) = NULL,
	@pMoldNumber VARCHAR(50) = NULL,
	@pFromDate DATE = NULL,
	@pToDate DATE = NULL

AS
BEGIN
	SET NOCOUNT ON;
	
	DECLARE @CompanyCode VARCHAR(20) = CASE WHEN ISNULL(@pCompanyCode,'') = '' THEN '*' ELSE @pCompanyCode END
	DECLARE @WorkCenterCode VARCHAR(20) = CASE WHEN ISNULL(@pWorkCenterCode,'') = '' THEN '*' ELSE @pWorkCenterCode END
	DECLARE @MoldNumber VARCHAR(50) = CASE WHEN ISNULL(@pMoldNumber,'') = '' THEN '*' ELSE @pMoldNumber END
	DECLARE @FromDate DATE = CASE WHEN ISNULL(@pFromDate,'') = '' THEN GETDATE() ELSE @pFromDate END
	DECLARE @ToDate DATE = CASE WHEN ISNULL(@pToDate,'') = '' THEN GETDATE() ELSE @pToDate END
    
	SELECT
			MRH.RepairHistNo AS OldRepairHistNo,
			MRH.RepairHistNo,
			MBI.CompanyCode,
			CI.CompanyName,
			CI.CompanyNameL,
			MRH.WorkCenterCode,
			WCI.WorkCenterName,
			WCI.WorkCenterNameL,
			MRH.MoldNumber,
			MBI.MoldTypeCode,		--금형구분코드
			MTI.MoldTypeName,		--금형구분명
			MBI.MoldCategory1,		--차종
			MBI.MoldCategory2,		--품명
			MBI.MoldCategory3,		--규격
			MBI.MakeVendor,			--제작처
			MBI.MakeDate,			--제작년도
			MRH.RepairType,
			MRH.MaterialType,
			MRH.ApprovalDate1,
			MRH.ApprovalUser1,
			MRH.ApprovalDate2,
			MRH.ApprovalUser2,
			MRH.ApprovalDate3,
			MRH.ApprovalUser3,
			MRH.ApprovalDate4,
			MRH.ApprovalUser4,
			MRH.ProductionWorkCenter,
			MRH.RequestWorkCenter,
			MRH.RequestUser,
			MRH.RequestDate,
			MRH.DemandDate,
			MRH.TotalProdQty,
			MRH.DeliveryQty,
			MRH.CauseImageID,
			MRH.CauseText,
			MRH.MeasureText,
			MRH.DevUser,
			MRH.GIDate,
			MRH.RepairTerm,
			MRH.GRDate,
			MRH.TestDate,
			MRH.RepairVendor,
			MRH.CompleteDate,
			MRH.CompleteCheckUser,
			MRH.StockProdQtyPerDay,
			MRH.StockProdWorkCenter,
			MRH.StockWipQty,
			MRH.StockTotalQty,
			MRH.StockCompleteDate,
			MRH.ProblemText,
			MRH.EONO,
			MRH.EONOFileID,
			MRH.RepairText,
			MRH.Relations,
			CONVERT(BIT,ISNULL(MRH.IsComplete,0)) AS IsComplete,
			
			MRH.EtcText,
			ISNULL(MRH.DocFileID,0) AS DocFileID,
			AFM.FileName AS DocFileName,
			AFM.FileContents AS FileData,
			
			MRH.CreateDateTime,
			MRH.CreateUserID,
			MRH.ChangeDateTime,
			MRH.ChangeUserID
	FROM
			STB_MoldRepairHistory MRH WITH(NOLOCK)
			LEFT OUTER JOIN STB_MoldBasicInfo MBI WITH(NOLOCK)
				ON MBI.MoldNumber = MRH.MoldNumber
			LEFT OUTER JOIN STB_MoldTypeInfo MTI WITH(NOLOCK)
				ON MTI.MoldTypeCode = MBI.MoldTypeCode 
			LEFT OUTER JOIN STB_WorkCenterInfo WCI WITH(NOLOCK)
				ON WCI.WorkCenterCode = MRH.WorkCenterCode
			LEFT OUTER JOIN STB_CompanyInfo CI WITH(NOLOCk)
				ON CI.CompanyCode = MBI.CompanyCode
			LEFT OUTER JOIN SmartFramework_File.dbo.STB_AttachedFileMaster AFM WITH (NOLOCK)
				ON (AFM.FileID = MRH.DocFileID)
			
	WHERE
			((@FromDate <= MRH.RequestDate) AND (MRH.RequestDate <= @ToDate)) AND
			((@CompanyCode = '*') OR (MBI.CompanyCode = @CompanyCode)) AND
			((@WorkCenterCode = '*') OR (MRH.WorkCenterCode = @WorkCenterCode)) 

END


