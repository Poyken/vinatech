-- =============================================
-- Author:		Mr.Manh
-- Create date: 2025-11-26
-- Description:	To search measure result multi lot
-- =============================================

-- exec usp_GetCommInspectionHist_VVT '' ,'' ,'VVT' ,'VVT_F2' ,'' ,'', '' ,'VVPT253R072749'
-- exec usp_GetCommInspectionHist_VVT '' ,'' ,'VVT' ,'VVT_F2' ,'2025-11-28' ,'2025-11-28' ,'VVBGC-13', ''


CREATE PROCEDURE [dbo].[usp_GetCommInspectionHist_VVT]		
	-- Add the parameters for the stored procedure here
		@pProcessUserID VARCHAR(20),
		@pProcessLanguage VARCHAR(20),
		@pCompanyCode VARCHAR(20) = NULL,
		@pWorkCenterCode VARCHAR(20) = NULL,
		@pFromDate DATETIME = NULL,
		@pToDate DATETIME = NULL,
		@pLineCode VARCHAR(20) = NULL,
		@pBarcode VARCHAR(20) = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	DECLARE @CompanyCode VARCHAR(20)    = CASE WHEN ISNULL(@pCompanyCode,'') = '' THEN '%' ELSE @pCompanyCode END
    DECLARE @WorkCenterCode VARCHAR(20) = CASE WHEN ISNULL(@pWorkCenterCode,'') = '' THEN '%' ELSE @pWorkCenterCode END
 --   DECLARE @FromDate DATEtime = CONVERT(VARCHAR(10), @pFromDate, 120) + ' 00:00:00' 
	--DECLARE @ToDate DATEtime = CONVERT(VARCHAR(10), DATEADD(DAY, 1, CONVERT(smalldatetime, @pToDate)), 120) + ' 00:00:00' 

	DECLARE @FromDate VARCHAR(19) = CONVERT(VARCHAR(10), @pFromDate, 120) + ' 00:00:00'
	DECLARE @ToDate VARCHAR(19) = CONVERT(VARCHAR(10), DATEADD(day, 1, @pToDate), 120) + ' 00:00:00'

	DECLARE @LineCode VARCHAR(20) = CASE WHEN ISNULL(@pLineCode, '') = '' THEN '%' ELSE @pLineCode END     

	--DECLARE @Barcode VARCHAR(20) = CASE WHEN ISNULL(@pBarcode, '') = '' THEN '%' ELSE @pBarcode END                                                             -- 추가사항

	
	DECLARE @CommInspDocNo VARCHAR(20)
	--DECLARE @CompanyCode VARCHAR(20)
	--DECLARE @WorkCenterCode VARCHAR(20)
	DECLARE @PONo VARCHAR(20)
	DECLARE @ControlNo VARCHAR(20)
	DECLARE @IsFinished BIT
	DECLARE @ProductGroupCode VARCHAR(20)
	DECLARE @MaterialCode VARCHAR(50)
	DECLARE @IsLoss BIT
	DECLARE @IsHolding BIT
	DECLARE @ErrorMessage NVARCHAR(500)
	DECLARE @ProductType INT
	DECLARE @NewBarcode VARCHAR(50)

	


	--select * from STB_CommInspDocHistory where ProdNo = (select ControlNo from STB_SetInfo WHere barcode = 'VVPT253R072749')

	---- lấy CommInspDocNo của bên trên
	--select * from STB_CommInspDocItem where CommInspDocNo = '20251126000056'


	--select * from STB_CommInspMeasureHist where CommInspDocItemNo In (select CommInspDocItemNo from STB_CommInspDocItem where CommInspDocNo = '20251126000056')

	--raiserror(@pBarcode, 16, 1)
	--return;

	IF (@pBarcode <> '' AND @pBarcode IS NOT NULL)
		BEGIN
			
			--Print('*' + @pBarcode + '*')

			--raiserror(@pBarcode, 16, 1)
			--return;
			SELECT @NewBarcode = NewBarcode
			  FROM STB_LotChangeMaterialHistory WITH(NOLOCK)
			 WHERE OldBarcode = @pBarcode

	
			IF NOT EXISTS (SELECT 1 from STB_SetInfo where Barcode = @pBarcode or Barcode = @NewBarcode)
				BEGIN
					raiserror(N'Mã barcode nhập vào: %s không chính xác. Vui lòng kiểm tra lại!', 16, 1, @pBarcode)
					return;
				END
			

			SELECT
					@CommInspDocNo = CIDH.CommInspDocNo,
					@IsFinished = CIDH.IsFinished,
					@CompanyCode = POI.CompanyCode,
					@WorkCenterCode = POI.WorkCenterCode,
					@PONo = SI.PONo,
					@ControlNo = SI.ControlNo,
					@MaterialCode = SI.MaterialCode,
					@ProductGroupCode = MM.ProductGroupCode,
					@IsLoss = SI.IsLoss,
					@IsHolding = ISNULL(SI.SIExtInt01,0),
					@ProductType = MBI.MBISizeW	
			
			FROM
					STB_SetInfo SI
					LEFT OUTER JOIN STB_ProductionOrderInfo POI		ON POI.PONo = SI.PONo
					LEFT OUTER JOIN STB_CommInspDocHistory CIDH	ON 	CIDH.ProdNo = SI.ControlNo
					LEFT OUTER JOIN STB_MaterialMaster MM			ON MM.MaterialCode = SI.MaterialCode
					LEFT OUTER JOIN STB_ModelBasicInfo MBI		    ON MM.MaterialCode = MBI.ModelCode
			WHERE 1=1                                                                                                                                             -- 원본백업
				   AND (SI.Barcode = @pBarcode OR SI.Barcode = @NewBarcode   ) 
				   AND CIDH.CommInspTypeCode LIKE '%TEST%'
			
			;with measure1 as (
				select * from STB_CommInspMeasureHist 
				where CommInspDocItemNo In (select CommInspDocItemNo from STB_CommInspDocItem where CommInspDocNo = @CommInspDocNo)
				and MeasureSeq = 1
			),
			measure2 as (
				select * from STB_CommInspMeasureHist 
				where CommInspDocItemNo In (select CommInspDocItemNo from STB_CommInspDocItem where CommInspDocNo = @CommInspDocNo)
				and MeasureSeq = 2
			),
			measure3 as (
				select * from STB_CommInspMeasureHist 
				where CommInspDocItemNo In (select CommInspDocItemNo from STB_CommInspDocItem where CommInspDocNo = @CommInspDocNo)
				and MeasureSeq = 3
			),
			measure4 as (
				select * from STB_CommInspMeasureHist 
				where CommInspDocItemNo In (select CommInspDocItemNo from STB_CommInspDocItem where CommInspDocNo = @CommInspDocNo)
				and MeasureSeq = 4
			),
			measure5 as (
				select * from STB_CommInspMeasureHist 
				where CommInspDocItemNo In (select CommInspDocItemNo from STB_CommInspDocItem where CommInspDocNo = @CommInspDocNo)
				and MeasureSeq = 5
			),
			measure6 as (
				select * from STB_CommInspMeasureHist 
				where CommInspDocItemNo In (select CommInspDocItemNo from STB_CommInspDocItem where CommInspDocNo = @CommInspDocNo)
				and MeasureSeq = 6
			),
			measure7 as (
				select * from STB_CommInspMeasureHist 
				where CommInspDocItemNo In (select CommInspDocItemNo from STB_CommInspDocItem where CommInspDocNo = @CommInspDocNo)
				and MeasureSeq = 7
			),
			measure8 as (
				select * from STB_CommInspMeasureHist 
				where CommInspDocItemNo In (select CommInspDocItemNo from STB_CommInspDocItem where CommInspDocNo = @CommInspDocNo)
				and MeasureSeq = 8
			),
			measure9 as (
				select * from STB_CommInspMeasureHist 
				where CommInspDocItemNo In (select CommInspDocItemNo from STB_CommInspDocItem where CommInspDocNo = @CommInspDocNo)
				and MeasureSeq = 9
			)

			SELECT
				@pBarcode AS Barcode,
				@CommInspDocNo AS CommInspDocNo,
				CIDI.CommInspDocItemNo,
				CIDI.CommInspDocNo,
				CIDI.CommInspItemCode, 
				CII.CommInspItemName,
				CIDI.RouteCode,
				RI.RouteName,
				CIDI.CommInspUnit,
				CIDI.CommInspItemDesc,                                -- 한국어 항목설명 
				CIDI.CommInspInputType,
				VIEW_CIIT.CommInspInputTypeName,
				CIDI.CommInspItemSpec,    
				CIDI.CommInspUpper,
				CIDI.CommInspLower,
				CIDI.ItemTargetQty,  
				CASE WHEN ISNULL(CIDI.ItemQty,0)	>= CIDI.ItemTargetQty     THEN CIDI.ItemTargetQty 
					 when CIDI.CommInspItemCode in ('v_DryColor','v_SleveWrongD') and CIDI.ItemTargetQty=3  AND CIDI.ItemQty <> 3 then 3 --ad by Mr.Tung on 19-09-2022
					 WHEN CIDI.ItemTargetQty = '20' AND CIDI.ItemQty <> '0' THEN '20'
					 ELSE ISNULL(CIDI.ItemQty,0) END   AS ItemQty, 

				CII.CommInspSelectGroupCode,
				''                                       AS MeasureResult,
				0.0 AS NumericMeasure,
				CIMH1.NumericMeasure AS FirstMeasureValue,
				CIMH2.NumericMeasure AS SecondMeasureValue,
				CIMH3.NumericMeasure AS ThirdMeasureValue,
				CIMH4.NumericMeasure AS FourthMeasureValue,
				CIMH5.NumericMeasure AS FifthMeasureValue,
				CIMH6.NumericMeasure AS SixthMeasureValue,
				CIMH7.NumericMeasure AS SeventhMeasureValue,
				CIMH8.NumericMeasure AS EightMeasureValue,
				CIMH9.NumericMeasure AS NineMeasureValue,
				CIDI.CreateDateTime
				




			FROM STB_CommInspDocItem CIDI WITH (NOLOCK)
			LEFT OUTER JOIN STB_CommInspDocHistory CIDH  ON CIDH.CommInspDocNo = CIDI.CommInspDocNo
			LEFT OUTER JOIN STB_CommInspItem CII ON CII.CommInspItemCode = CIDI.CommInspItemCode
			LEFT OUTER JOIN VW_CommInspInputType VIEW_CIIT ON VIEW_CIIT.CommInspInputType = CIDI.CommInspInputType
			--LEFT OUTER JOIN STB_CommInspSelectItem CISI WITH(NOLOCK)				             ON CISI.CommInspSelectResult = CIMH.MeasureResult				AND CISI.CommInspSelectGroupCode = CII.CommInspSelectGroupCode
			LEFT OUTER JOIN measure1 CIMH1 ON CIMH1.CommInspDocItemNo = CIDI.CommInspDocItemNo  
			LEFT OUTER JOIN measure2 CIMH2 ON CIMH2.CommInspDocItemNo = CIDI.CommInspDocItemNo
			LEFT OUTER JOIN measure3 CIMH3 ON CIMH3.CommInspDocItemNo = CIDI.CommInspDocItemNo       -- 2020.01.13 추가
			LEFT OUTER JOIN measure4 CIMH4 ON CIMH4.CommInspDocItemNo = CIDI.CommInspDocItemNo
			LEFT OUTER JOIN measure5 CIMH5 ON CIMH5.CommInspDocItemNo = CIDI.CommInspDocItemNo
			LEFT OUTER JOIN measure6 CIMH6 ON CIMH6.CommInspDocItemNo = CIDI.CommInspDocItemNo
			LEFT OUTER JOIN measure7 CIMH7 ON CIMH7.CommInspDocItemNo = CIDI.CommInspDocItemNo
			LEFT OUTER JOIN measure8 CIMH8 ON CIMH8.CommInspDocItemNo = CIDI.CommInspDocItemNo
			LEFT OUTER JOIN measure9 CIMH9 ON CIMH9.CommInspDocItemNo = CIDI.CommInspDocItemNo
			LEFT OUTER JOIN STB_CommInspDocHistory SCH WITH(NOLOCK)				         ON SCH.CommInspDocNo = CIDI.CommInspDocNo
			LEFT OUTER JOIN STB_RouteInfo RI WITH(NOLOCK)	ON RI.RouteCode = CIDI.RouteCode
			WHERE 1=1
			AND CIDH.CommInspDocNo = @CommInspDocNo


		END

	ELSE
		BEGIN
			
			Print('2')

			;with rdata as (
				SELECT 
					CIDH.CommInspDocNo,
					
					SI.Barcode
					FROM STB_CommInspDocHistory CIDH WITH(NOLOCK)
					LEFT OUTER JOIN STB_SetInfo SI ON CIDH.ProdNo = SI.ControlNo
					WHERE CIDH.CreateDateTime BETWEEN @FromDate AND @ToDate
					and SI.InputLineCode LIKE @LineCode
					and CIDH.CommInspTypeCode LIKE '%TEST%'

			),
			--rmeasure as(
			--	--SELECT * FROM STB_CommInspMeasureHist WHERE MeasureSeq = 
			--	-- select * from STB_CommInspMeasureHist where CommInspDocItemNo In (select CommInspDocItemNo from STB_CommInspDocItem where CommInspDocNo = '20251126000056')
			--	select 
				
			--	CIMH.* 
			--	from   rdata
			--	left join STB_CommInspDocItem CIDI ON  CIDI.CommInspDocNo = rdata.CommInspDocNo
			--	left join STB_CommInspMeasureHist CIMH ON CIDI.CommInspDocItemNo = CIMH.CommInspDocItemNo
			
			--),
			listCommInspDocItem as (
				Select CommInspDocItemNo from STB_CommInspDocItem
				where CommInspDocNo IN (Select CommInspDocNo from rdata)
			),
			measure1 as (
				select * from STB_CommInspMeasureHist CIMH
				where CIMH.MeasureSeq = 1
				and CommInspDocItemNo In (select CommInspDocItemNo from listCommInspDocItem)
			),
			measure2 as (
				select * from STB_CommInspMeasureHist CIMH
				where CIMH.MeasureSeq = 2
				and CommInspDocItemNo In (select CommInspDocItemNo from listCommInspDocItem)
			),
			measure3 as (
				select * from STB_CommInspMeasureHist CIMH
				where CIMH.MeasureSeq = 3
				and CommInspDocItemNo In (select CommInspDocItemNo from listCommInspDocItem)
			),
			measure4 as (
				select * from STB_CommInspMeasureHist CIMH
				where CIMH.MeasureSeq = 4
				and CommInspDocItemNo In (select CommInspDocItemNo from listCommInspDocItem)
			),
			measure5 as (
				select * from STB_CommInspMeasureHist CIMH
				where CIMH.MeasureSeq = 5
				and CommInspDocItemNo In (select CommInspDocItemNo from listCommInspDocItem)
			),
			measure6 as (
				select * from STB_CommInspMeasureHist CIMH
				where CIMH.MeasureSeq = 6
				and CommInspDocItemNo In (select CommInspDocItemNo from listCommInspDocItem)
			),
			measure7 as (
				select * from STB_CommInspMeasureHist CIMH
				where CIMH.MeasureSeq = 7
				and CommInspDocItemNo In (select CommInspDocItemNo from listCommInspDocItem)
			),
			measure8 as (
				select * from STB_CommInspMeasureHist CIMH
				where CIMH.MeasureSeq = 8
				and CommInspDocItemNo In (select CommInspDocItemNo from listCommInspDocItem)
			),
			measure9 as (
				select * from STB_CommInspMeasureHist CIMH
				where CIMH.MeasureSeq = 9
				and CommInspDocItemNo In (select CommInspDocItemNo from listCommInspDocItem)
			)



			SELECT
				r.Barcode AS Barcode,
				r.CommInspDocNo AS CommInspDocNo,
				CIDI.CommInspDocItemNo,
				CIDI.CommInspDocNo,
				CIDI.CommInspItemCode, 
				CII.CommInspItemName,
				CIDI.RouteCode,
				RI.RouteName,
				CIDI.CommInspUnit,
				CIDI.CommInspItemDesc,                                -- 한국어 항목설명 
				CIDI.CommInspInputType,
				VIEW_CIIT.CommInspInputTypeName,
				CIDI.CommInspItemSpec,    
				CIDI.CommInspUpper,
				CIDI.CommInspLower,
				CIDI.ItemTargetQty,  
				CASE WHEN ISNULL(CIDI.ItemQty,0)	>= CIDI.ItemTargetQty     THEN CIDI.ItemTargetQty 
					 when CIDI.CommInspItemCode in ('v_DryColor','v_SleveWrongD') and CIDI.ItemTargetQty=3  AND CIDI.ItemQty <> 3 then 3 --ad by Mr.Tung on 19-09-2022
					 WHEN CIDI.ItemTargetQty = '20' AND CIDI.ItemQty <> '0' THEN '20'
					 ELSE ISNULL(CIDI.ItemQty,0) END   AS ItemQty, 

				CII.CommInspSelectGroupCode,
				''                                       AS MeasureResult,
				0.0 AS NumericMeasure,
				CIMH1.NumericMeasure AS FirstMeasureValue,
				CIMH2.NumericMeasure AS SecondMeasureValue,
				CIMH3.NumericMeasure AS ThirdMeasureValue,
				CIMH4.NumericMeasure AS FourthMeasureValue,
				CIMH5.NumericMeasure AS FifthMeasureValue,
				CIMH6.NumericMeasure AS SixthMeasureValue,
				CIMH7.NumericMeasure AS SeventhMeasureValue,
				CIMH8.NumericMeasure AS EightMeasureValue,
				CIMH9.NumericMeasure AS NineMeasureValue,

				

				CIDI.CreateDateTime
				




			FROM rdata r
			LEFT JOIN STB_CommInspDocItem CIDI ON CIDI.CommInspDocNo = r.CommInspDocNo
			LEFT OUTER JOIN STB_CommInspDocHistory CIDH  ON CIDH.CommInspDocNo = CIDI.CommInspDocNo
			LEFT OUTER JOIN STB_CommInspItem CII ON CII.CommInspItemCode = CIDI.CommInspItemCode
			LEFT OUTER JOIN VW_CommInspInputType VIEW_CIIT ON VIEW_CIIT.CommInspInputType = CIDI.CommInspInputType
			--LEFT OUTER JOIN STB_CommInspSelectItem CISI WITH(NOLOCK)				             ON CISI.CommInspSelectResult = CIMH.MeasureResult				AND CISI.CommInspSelectGroupCode = CII.CommInspSelectGroupCode
			LEFT OUTER JOIN measure1 CIMH1 ON CIMH1.CommInspDocItemNo = CIDI.CommInspDocItemNo  
			LEFT OUTER JOIN measure2 CIMH2 ON CIMH2.CommInspDocItemNo = CIDI.CommInspDocItemNo
			LEFT OUTER JOIN measure3 CIMH3 ON CIMH3.CommInspDocItemNo = CIDI.CommInspDocItemNo       -- 2020.01.13 추가
			LEFT OUTER JOIN measure4 CIMH4 ON CIMH4.CommInspDocItemNo = CIDI.CommInspDocItemNo
			LEFT OUTER JOIN measure5 CIMH5 ON CIMH5.CommInspDocItemNo = CIDI.CommInspDocItemNo
			LEFT OUTER JOIN measure6 CIMH6 ON CIMH6.CommInspDocItemNo = CIDI.CommInspDocItemNo
			LEFT OUTER JOIN measure7 CIMH7 ON CIMH7.CommInspDocItemNo = CIDI.CommInspDocItemNo
			LEFT OUTER JOIN measure8 CIMH8 ON CIMH8.CommInspDocItemNo = CIDI.CommInspDocItemNo
			LEFT OUTER JOIN measure9 CIMH9 ON CIMH9.CommInspDocItemNo = CIDI.CommInspDocItemNo

			--LEFT OUTER JOIN rmeasure rm ON rm.CommInspDocItemNo = CIDI.CommInspDocItemNo
			LEFT OUTER JOIN STB_CommInspDocHistory SCH WITH(NOLOCK)				         ON SCH.CommInspDocNo = CIDI.CommInspDocNo

			LEFT OUTER JOIN STB_RouteInfo RI WITH(NOLOCK)	ON RI.RouteCode = CIDI.RouteCode

			order by CreateDateTime
				 
		END



END
