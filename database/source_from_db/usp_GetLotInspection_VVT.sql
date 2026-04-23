-- =============================================
-- Author:		DinhManh
-- Create date: 2025-12-02
-- Description:	Get Lot Inspected 
-- =============================================
CREATE PROCEDURE [dbo].[usp_GetLotInspection_VVT]
	-- Add the parameters for the stored procedure here
			@pProcessUserID VARCHAR(20),
			@pProcessLanguage VARCHAR(20),
			@pCompanyCode VARCHAR(20) = NULL,
			@pWorkCenterCode VARCHAR(20) = NULL,
			@pFromDate DATETIME = NULL,
			@pToDate DATETIME = NULL,
			--@pLineCode VARCHAR(20) = NULL,
			@pBarcode VARCHAR(20) = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

		DECLARE @CompanyCode VARCHAR(20)    = CASE WHEN ISNULL(@pCompanyCode,'') = '' THEN '%' ELSE @pCompanyCode END
    DECLARE @WorkCenterCode VARCHAR(20) = CASE WHEN ISNULL(@pWorkCenterCode,'') = '' THEN '%' ELSE @pWorkCenterCode END

	DECLARE @FromDate VARCHAR(19) = CONVERT(VARCHAR(10), @pFromDate, 120) + ' 00:00:00'
	DECLARE @ToDate VARCHAR(19) = CONVERT(VARCHAR(10), DATEADD(day, 1, @pToDate), 120) + ' 00:00:00'

	--DECLARE @LineCode VARCHAR(20) = CASE WHEN ISNULL(@pLineCode, '') = '' THEN '%' ELSE @pLineCode END     

                                                        -- 추가사항

	
	DECLARE @CommInspDocNo VARCHAR(20)
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

	DECLARE @CommInspTypeCode VARCHAR(30)
	
		if(@WorkCenterCode='VVT_F1')
			begin
				set @CommInspTypeCode='ROUTE_TEST2'
			end
		else if(@WorkCenterCode='VVT_F2')
			begin
				set @CommInspTypeCode='ROUTE_TEST2_BG'
			end
		else
			begin
				set @CommInspTypeCode='VE_ROUTE_TEST'
			end
		


		IF (@pBarcode <> '' AND @pBarcode IS NOT NULL)
			BEGIN
				SELECT @NewBarcode = NewBarcode
				  FROM STB_LotChangeMaterialHistory WITH(NOLOCK)
				 WHERE OldBarcode = @pBarcode

	
				IF NOT EXISTS (SELECT 1 from STB_SetInfo where Barcode = @pBarcode or Barcode = @NewBarcode)
					BEGIN
						raiserror(N'Mã barcode nhập vào: %s không chính xác. Vui lòng kiểm tra lại!', 16, 1, @pBarcode)
						return;
					END

				SELECT
					CIDH.CommInspDocNo,
					SI.Barcode,
					SI.PONo,
					SI.ControlNo,
					SI.MaterialCode,
					MM.MaterialName,
					--MM.ProductGroupCode,
					--SI.IsLoss,
					--ISNULL(SI.SIExtInt01,0),
					--MBI.MBISizeW	
					SI.InputLineCode,
					POI.CompanyCode,
					POI.WorkCenterCode,
					CIDH.CreateDateTime,
					CIDH.CreateUserID
			
				FROM
						STB_SetInfo SI
						LEFT OUTER JOIN STB_ProductionOrderInfo POI		ON POI.PONo = SI.PONo
						LEFT OUTER JOIN STB_CommInspDocHistory CIDH	ON 	CIDH.ProdNo = SI.ControlNo
						LEFT OUTER JOIN STB_MaterialMaster MM			ON MM.MaterialCode = SI.MaterialCode
						LEFT OUTER JOIN STB_ModelBasicInfo MBI		    ON MM.MaterialCode = MBI.ModelCode
				WHERE 1=1                                                                                                                                             -- 원본백업
					   AND (SI.Barcode = @pBarcode OR SI.Barcode = @NewBarcode  )
					   AND CIDH.CommInspTypeCode = @CommInspTypeCode
					   AND POI.CompanyCode = @CompanyCode
					   AND POI.WorkCenterCode = @WorkCenterCode
					   --AND (SI.Barcode = 'VVPT253R072749' OR SI.Barcode = 'VVPT253R072749'  )

			END

		ELSE

			BEGIN
				SELECT
					CIDH.CommInspDocNo,
					SI.Barcode,
					SI.PONo,
					SI.ControlNo,
					SI.MaterialCode,
					MM.MaterialName,
					--MM.ProductGroupCode,
					--SI.IsLoss,
					--ISNULL(SI.SIExtInt01,0),
					--MBI.MBISizeW	
					SI.InputLineCode,
					POI.CompanyCode,
					POI.WorkCenterCode,
					CIDH.CreateDateTime,
					CIDH.CreateUserID
			
				FROM
						STB_SetInfo SI
						LEFT OUTER JOIN STB_ProductionOrderInfo POI		ON POI.PONo = SI.PONo
						LEFT OUTER JOIN STB_CommInspDocHistory CIDH	ON 	CIDH.ProdNo = SI.ControlNo
						LEFT OUTER JOIN STB_MaterialMaster MM			ON MM.MaterialCode = SI.MaterialCode
						LEFT OUTER JOIN STB_ModelBasicInfo MBI		    ON MM.MaterialCode = MBI.ModelCode
				WHERE 1=1                                                                                                                                             -- 원본백업
					   --AND (SI.Barcode = @pBarcode OR SI.Barcode = @NewBarcode  )
					   AND CIDH.CommInspTypeCode = @CommInspTypeCode
					   AND POI.CompanyCode = @CompanyCode
					   AND POI.WorkCenterCode = @WorkCenterCode
					   AND CIDH.CreateDateTime BETWEEN @FromDate AND @ToDate
			END
END
