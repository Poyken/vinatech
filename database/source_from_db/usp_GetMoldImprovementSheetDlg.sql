
-- =============================================
-- Author: Park Jong Hoon(jhpark@awoo.co.kr)
-- Create date: 2016-06-19
-- Browsable : true
-- Group : 금형관리
-- Description:	금형문제점개선시트 다이어로그
-- =============================================
CREATE PROCEDURE [dbo].[usp_GetMoldImprovementSheetDlg]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	--@pXml NVARCHAR(MAX) = NULL
	@pImproveHistNo VARCHAR(20) = NULL,
	@pMoldNumber VARCHAR(50) = NULL
AS
BEGIN
	
	SET NOCOUNT ON;
	
	/*
    DECLARE @ProcessUserID VARCHAR(20) = @pProcessUserID
	DECLARE @ProcessLanguage VARCHAR(20) = @pProcessLanguage
    DECLARE @TableName VARCHAR(200) = '/DataSet/MoldImprovementSheet'
 
	DECLARE @ERROR_MSG NVARCHAR(MAX)
	DECLARE @iDoc INT
	DECLARE @ImproveHistNo VARCHAR(20)
	DECLARE @MoldNumber VARCHAR(50)
	
	
	DECLARE @MoldProductMapping TABLE(
										IDX INT IDENTITY,
										MaterialCode VARCHAR(50)
									)
	DECLARE @initRow INT = 1
	DECLARE @rowCnt INT
	DECLARE @MaterialCode VARCHAR(50)	
	DECLARE @MoldMappingMaterialCode VARCHAR(50)
	
	
	EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
	
	BEGIN TRY
		SELECT
				@ImproveHistNo = XMLData.ImproveHistNo,
				@MoldNumber = XMLData.MoldNumber
		FROM
				OPENXML(@idoc, @TableName, 2)
				WITH(
						ImproveHistNo VARCHAR(20),
						MoldNumber VARCHAR(50)
					) XMLData
	END TRY
	BEGIN CATCH
		SET @ERROR_MSG = ERROR_MESSAGE()
		RAISERROR(@ERROR_MSG,16,1)
	END CATCH
	
	EXEC sp_xml_removedocument @idoc
	
	*/
	DECLARE @ImproveHistNo VARCHAR(20) = @pImproveHistNo
	DECLARE @MoldNumber VARCHAR(50) = @pMoldNumber
	
	DECLARE @MoldProductMapping TABLE(
										IDX INT IDENTITY,
										MaterialCode VARCHAR(50)
									)
	DECLARE @initRow INT = 1
	DECLARE @rowCnt INT
	DECLARE @MaterialCode VARCHAR(50)	
	DECLARE @MoldMappingMaterialCode VARCHAR(50)
	
	--금형 매핑된 품목들을 ','로 연결해서 금형문제점개선시트의 특정셀에 넣어주기 위한 데이터 생성
	INSERT @MoldProductMapping
	SELECT		
			MPM.MaterialCode
	FROM
			STB_MoldProductMapping MPM WITH(NOLOCK)
	WHERE
			MPM.MoldNumber = @MoldNumber
	
	SET @rowCnt = (SELECT COUNT(*) FROM @MoldProductMapping)
	
	WHILE @initRow <= @rowCnt BEGIN
	
		SELECT
				@MaterialCode = MaterialCode
		FROM
				@MoldProductMapping
		WHERE
				IDX = @initRow
				
		IF @initRow = 1 BEGIN
			SET @MoldMappingMaterialCode = @MaterialCode
		END
		ELSE BEGIN
			SET @MoldMappingMaterialCode = @MoldMappingMaterialCode + ',' + @MaterialCode
		END
		
		SET @initRow = @initRow + 1
	END
	--------------------------------------------------------------------------------------------------
	
	SELECT
			MIS.ImproveHistNo AS OldImproveHistNo,
			MIS.ImproveHistNo,
			MIS.MoldSeqNo,
			MIS.MoldNumber,							--금형번호
			MBI.MoldCategory1,						--차종
			MBI.MoldCategory2,						--품명
			MBI.MoldCategory3,						--규격
			@MoldMappingMaterialCode AS MaterialCode,		-- 금형 매핑 품목들
			MBI.MoldCategory1 AS VendorMoldCategory1,	--차종
			MBI.MoldCategory2 AS VendorMoldCategory2,	--품명
			MBI.CompanyCode,
			CI.CompanyName,							--사업장명
			MIS.WorkCenterCode,
			WCI.WorkCenterName,						--작업장명
			MIS.ImprovementStep,					--문제점단계
			VIS.ImprovementStepName,				--문제점단계명
			MIS.ImprovementType,					--금형문제점유형
			MIS.MoldType,							--금형유형
			VMT.MoldTypeName,						--금형유형명
			MIS.MoldGrade,
			MIS.MoldRoute,
			MIS.RegistDate,
			MIS.CompleteDate,
			
			ISNULL(MIS.DocFileID,0) AS DocFileID,
			MIS.DocFileName,
			AFM.FileContents AS FileData
	FROM
			STB_MoldImprovementSheet MIS WITH(NOLOCK)
			LEFT OUTER JOIN STB_MoldBasicInfo MBI WITH(NOLOCK)
				ON MBI.MoldNumber = MIS.MoldNumber
			LEFT OUTER JOIN STB_WorkCenterInfo WCI WITH(NOLOCK)
				ON WCI.WorkCenterCode = MIS.WorkCenterCode
			LEFT OUTER JOIN STB_CompanyInfo CI WITH(NOLOCK)
				ON CI.CompanyCode = MBI.CompanyCode
			LEFT OUTER JOIN VW_ImprovementStep VIS WITH(NOLOCK)
				ON VIS.ImprovementStep = MIS.ImprovementStep
			LEFT OUTER JOIN VW_MoldType VMT WITH(NOLOCK)
				ON VMT.MoldType = MIS.MoldType
			LEFT OUTER JOIN SmartFramework_File.dbo.STB_AttachedFileMaster AFM WITH (NOLOCK)
				ON (AFM.FileID = MIS.DocFileID)
				
	WHERE
			MIS.ImproveHistNo = @ImproveHistNo
END

