
-- =============================================
-- Author: Park Jong Hoon(jhpark@awoo.co.kr)
-- Create date: 2016-06-18
-- Browsable : true
-- Group : 금형관리
-- Description:	금형수정수리정보 다이어로그
-- =============================================
CREATE PROCEDURE [dbo].[usp_GetMoldRepairHistDlg]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	--@pXml NVARCHAR(MAX) = NULL
	@pRepairHistNo VARCHAR(20) = NULL
AS
BEGIN
	
	SET NOCOUNT ON;
	
	
	/*
    DECLARE @ProcessUserID VARCHAR(20) = @pProcessUserID
	DECLARE @ProcessLanguage VARCHAR(20) = @pProcessLanguage
    DECLARE @TableName VARCHAR(200) = '/DataSet/MoldRepairHistory'
 
	DECLARE @ERROR_MSG NVARCHAR(MAX)
	DECLARE @iDoc INT
	DECLARE	@RepairHistNo VARCHAR(20)
	
	
	EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
	
	BEGIN TRY
		SELECT
				@RepairHistNo = XMLData.RepairHistNo
		FROM
				OPENXML(@idoc, @TableName, 2)
				WITH(
						RepairHistNo VARCHAR(20)
					) XMLData
	END TRY
	BEGIN CATCH
		SET @ERROR_MSG = ERROR_MESSAGE()
		RAISERROR(@ERROR_MSG,16,1)
	END CATCH
	
	EXEC sp_xml_removedocument @idoc
	*/
	
	DECLARE @RepairHistNo VARCHAR(20) = @pRepairHistNo
	
	SELECT
			MRH.RepairHistNo AS OldRepairHistNo,
			MRH.RepairHistNo,
			
			--금형 수정/수리 구분--------------------------------------------
			MRH.RepairType,										--수정/수리
			MRT.RepairTypeName,
			MRH.ProblemText,									--문제점 입력
			-----------------------------------------------------------------
			
			--기본정보-------------------------------------------------------
			MBI.MoldCategory1,									--차종
			MBI.MoldCategory2,									--품명
			MRH.MaterialType,									--재질
			MBI.MakeVendor,										--제작처
			MBI.MakeDate,										--제작년도
			MRH.TotalProdQty,									--총생산수량
			MRH.ProductionWorkCenter,							--생산처코드
			PWCI.WorkCenterName AS ProductionWorkCenterName,	--생산처
			MRH.RequestWorkCenter,								--의뢰부서코드
			RWCI.WorkCenterName AS RequestWorkCenterName,		--의뢰부서
			MRH.RequestUser,									--의뢰자
			MRH.RequestDate,									--의뢰일자
			MRH.DemandDate,										--완료요구일
			MRH.DeliveryQty,									--1일 납품량
			------------------------------------------------------------------
			
			--의뢰정보--------------------------------------------------------------
			MRH.DevUser,										--개발담당
			MRH.GIDate,											--금형 출고일자
			MRH.RepairTerm,										--금형 수리기간
			MRH.GRDate,											--금형 입고일자
			MRH.TestDate,										--확인 시사출
			MRH.RepairVendor,									--금형 수리, 수정업체
			--------------------------------------------------------------------------
			
			--재고 현황---------------------------------------------------------------
			MRH.StockProdQtyPerDay,								--1일 생산량
			MRH.StockWipQty,									--공정재고
			MRH.StockTotalQty,									--총재고량
			MRH.StockCompleteDate,								--재고 확보 유무(예정일)
			---------------------------------------------------------------------------
			
			--완료통보------------------------------------------------------------------
			MRH.CompleteDate,									--금형수리 완료일
			MRH.CompleteCheckUser,								--확인
			----------------------------------------------------------------------------
			
			--스프레드 시트--------------------------------------------------------------
			ISNULL(MRH.DocFileID,0) AS DocFileID,
			AFM.FileName,
	        AFM.FileExt,
	        AFM.FileSize,
			--CONVERT(VARBINARY(MAX), NULL) AS FileData,
			AFM.FileName AS DocFileName,
			AFM.FileContents AS FileData,
			
			-----------------------------------------------------------------------------
			
			MBI.CompanyCode,
			CI.CompanyName,
			MRH.WorkCenterCode,
			WCI.WorkCenterName,
			MRH.MoldNumber,
			MBI.MoldTypeCode,		
			MTI.MoldTypeName,	
			MBI.MoldCategory3,
			MRH.ApprovalDate1,
			MRH.ApprovalUser1,
			MRH.ApprovalDate2,
			MRH.ApprovalUser2,
			MRH.ApprovalDate3,
			MRH.ApprovalUser3,
			MRH.ApprovalDate4,
			MRH.ApprovalUser4,
			MRH.CauseImageID,
			MRH.CauseText,
			MRH.MeasureText,
			MRH.StockProdWorkCenter,
			MRH.EONO,
			MRH.EONOFileID,
			MRH.RepairText,
			MRH.Relations,
			CONVERT(BIT,ISNULL(MRH.IsComplete,0)) AS IsComplete,
			MRH.EtcText,
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
			LEFT OUTER JOIN STB_WorkCenterInfo PWCI WITH(NOLOCK)
				ON PWCI.WorkCenterCode = MRH.ProductionWorkCenter
			LEFT OUTER JOIN STB_WorkCenterInfo RWCI WITH(NOLOCK)
				ON RWCI.WorkCenterCode = MRH.RequestWorkCenter
			LEFT OUTER JOIN SmartFramework_File.dbo.STB_AttachedFileMaster AFM WITH (NOLOCK)
				ON (AFM.FileID = MRH.DocFileID)
			LEFT OUTER JOIN VW_MoldRepairType MRT
				ON MRT.RepairType = MRH.RepairType
	WHERE
			MRH.RepairHistNo = @RepairHistNo
END

