
-- =============================================
-- Author: kilee
-- Create date: 2020-04-29
-- Browsable : true
-- Group : 품질관리
-- Description:	
-- Modified:  2020-04-29  엄제식부장 요청사항

--  프로시저실행 :   usp_ProcessInspectionHistory_get 'kilee','Korean','VNT','VNT_F1','2020-03-28 00:00:00','2020-04-30  00:00:00','VJKM262R750606'
--                      usp_ProcessInspectionHistory_get_20200429 'kilee','Korean','VNT','VNT_F1','2020-04-26 00:00:00','2020-04-30  00:00:00',''
-- =============================================	
CREATE PROCEDURE [dbo].[usp_ProcessInspectionHistory_get_20200429]
						@pProcessUserID VARCHAR(20),
						@pProcessLanguage VARCHAR(20),
						@pCompanyCode VARCHAR(20) = NULL,
						@pWorkCenterCode VARCHAR(20) = NULL,
						@pFromDate DATE = NULL,
						@pToDate DATE = NULL,						
						@pBarcode VARCHAR(20) = NULL,
						@pSizeCode VARCHAR(20) = NULL
AS

BEGIN
	SET NOCOUNT ON;
	
    DECLARE @CompanyCode    VARCHAR(20) = CASE WHEN ISNULL(@pCompanyCode,'') = '' THEN '*' ELSE @pCompanyCode END
    DECLARE @WorkCenterCode VARCHAR(20) = CASE WHEN ISNULL(@pWorkCenterCode,'') = '' THEN '%' ELSE @pWorkCenterCode END
    DECLARE @FromDate          DATE           = @pFromDate
	DECLARE @ToDate             DATE           = @pToDate	
	DECLARE @Barcode           VARCHAR(20)  = CASE WHEN ISNULL(@pBarcode, '') = '' THEN '*' ELSE @pBarcode END                                                            
	DECLARE @SizeCode          VARCHAR(8)   = CASE WHEN ISNULL(@pSizeCode, '') = '' THEN '*' ELSE @pSizeCode END


		   SELECT	      								
				CIDI.CommInspDocItemNo,
				CIDI.CommInspDocNo,			
				CIDI.CommInspItemCode,			
				CII.CommInspItemName,
				CIDI.CommInspUnit,
				CIDI.CommInspItemDesc,
				CIDI.CommInspInputType,
				CIIT.CommInspInputTypeName,			
				CIDI.CommInspItemSpec,
				CIDI.CommInspUpper,
				CIDI.CommInspLower,
				CIDI.ItemTargetQty,
				CIDI.ItemQty,
				CIDI.ImageFileID,
				CIDI.CommInspRemark,
				CIDI.CreateDateTime,
				CIDI.CreateUserID,
				CIDI.ChangeDateTime,
				CIDI.ChangeUserID,
				SI.Barcode                AS Barcode,			
				CIMH.NumericMeasure AS NumericMeasure,
				SI.MaterialCode          AS MaterialCode,
				VM.ModelName       AS ModelName,
				RIGHT('0'+CONVERT(VARCHAR, FLOOR(MBISizeW)),2) + CONVERT(VARCHAR, FLOOR(MBISizeH)) AS SizeCode				
		FROM
									  STB_CommInspDocItem CIDI WITH(NOLOCK)
				LEFT OUTER JOIN STB_CommInspItem CII WITH(NOLOCK)			ON CIDI.CommInspItemCode = CII.CommInspItemCode
				LEFT OUTER JOIN VW_CommInspInputType CIIT         				ON CIDI.CommInspInputType =  CIIT.CommInspInputType			
				LEFT OUTER JOIN STB_CommInspDocHistory CIDH         			ON CIDI.CommInspDocNo =  CIDH.CommInspDocNo
				LEFT OUTER JOIN STB_SetInfo SI         				                ON SI.ControlNo = CIDH.ProdNo
				LEFT OUTER JOIN STB_CommInspMeasureHist CIMH                 ON CIMH.CommInspDocItemNo = CIDI.CommInspDocItemNo
				LEFT OUTER JOIN VW_ModelBasicInfo           VM                  ON SI.MaterialCode = VM.ModelCode				

		WHERE 1=1	
		   AND CIDI.commInspItemCode in ('V_RQ_THICKP', 'V_RQ_THICKM', 'RQ_THICKP', 'RQ_THICKM' )    -- 전극두께(+)  [RQ가 붙으면 공정검사 / RQ없으면 자주검사]		  			
		 --    AND CIDI.CreateDateTime between  '2020-04-20' And '2020-04-21'		   
		   AND (@Barcode = '*' Or  SI.Barcode  LIKE @Barcode)	
		 --AND (RIGHT('0'+CONVERT(VARCHAR, FLOOR(MBISizeW)),2) + CONVERT(VARCHAR, FLOOR(MBISizeH)) = '*' Or RIGHT('0'+CONVERT(VARCHAR, FLOOR(MBISizeW)),2) + CONVERT(VARCHAR, FLOOR(MBISizeH))  LIKE @SizeCode)
		 AND CIDI.CreateDateTime between  @FromDate And @ToDate				
		 --AND SI.Barcode = 'VJKM262R750606'

END
