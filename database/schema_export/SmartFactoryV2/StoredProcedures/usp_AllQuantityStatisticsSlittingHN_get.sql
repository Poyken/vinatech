-- Procedure: usp_AllQuantityStatisticsSlittingHN_get
-- =============================================
-- Author:		DinhManh
-- Create date: 2025-02-13
-- Description:	Thống kê số lượng cắt từng loại
-- =============================================

-- usp_AllQuantityStatisticsSlittingHN_get '', '', '2025-02-01', '2025-02-28'

CREATE PROCEDURE [dbo].[usp_AllQuantityStatisticsSlittingHN_get]
	-- Add the parameters for the stored procedure here
						@pProcessUserID VARCHAR(20),
						@pProcessLanguage VARCHAR(20),
						@pFromDate DATETIME = NULL,
						@pToDate DATETIME = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	DECLARE @FromDate VARCHAR(19) = CONVERT(VARCHAR(10), @pFromDate, 120) + ' 10:00:00'
	DECLARE @ToDate VARCHAR(19) = CONVERT(VARCHAR(10), DATEADD(day, 1, @pToDate), 120) + ' 10:00:00'


	SELECT 
			N'Foil âm (Cathode Foil) (M2)' AS GroupCode,

			(	-- Số lượng NG
				SELECT ISNULL(SUM(MLI.InitialQty), 0)
				FROM  
					STB_MaterialLotInfo MLI
				WHERE 1=1
					AND MLI.LotID LIKE 'SL%'
					AND (SELECT MM.ProductGroupCode 
						FROM STB_MaterialLotInfo MLI2
						LEFT JOIN STB_MaterialMaster MM ON MLI2.MaterialCode = MM.MaterialCode
						WHERE MLI.PackingIdParent = MLI2.LotID) = 'CATHODE-FOIL'	
					AND MLI.IsCheck = 'Reject'
					AND MLI.IsSlitting = '1'

					AND MLI.CheckTime BETWEEN @FromDate AND @ToDate -- thời gian mà QC kiểm tra và đánh giá
			) AS NGQty,			
			
			(	-- Số lượng đã Pass
				SELECT ISNULL(SUM(MLI.InitialQty), 0)
				FROM  
					STB_MaterialLotInfo MLI
				LEFT JOIN STB_MaterialMaster MM ON MLI.MaterialCode = MM.MaterialCode
				WHERE 1=1
					AND MLI.LotID LIKE 'SL%'
					AND MM.ProductGroupCode  = 'CATHODE-FOIL'
					AND MLI.IsCheck = 'Pass'
					AND MLI.IsSlitting = '1'

					AND MLI.CheckTime BETWEEN @FromDate AND @ToDate -- thời gian mà QC kiểm tra và đánh giá
			) AS OKQty,

			(	-- Tổng số lượng 
				SELECT ISNULL(SUM(MLI.InitialQty), 0)
				FROM  
					STB_MaterialLotInfo MLI
				WHERE 1=1
					AND MLI.LotID LIKE 'SL%'
					AND (SELECT MM.ProductGroupCode 
						FROM STB_MaterialLotInfo MLI2
						LEFT JOIN STB_MaterialMaster MM ON MLI2.MaterialCode = MM.MaterialCode
						WHERE MLI.PackingIdParent = MLI2.LotID) = 'CATHODE-FOIL'
					AND MLI.WorkCenterCode = 'VVT_F3'
					AND MLI.IsCheck IS NOT NULL
					AND IsSlitting = 1

					AND MLI.CheckTime BETWEEN @FromDate AND @ToDate -- thời gian mà QC kiểm tra và đánh giá
			) AS SUMSlittingQty


	UNION ALL

	SELECT 
			N'Foil dương (Anode Foil) (M2)' AS GroupCode,
			(	-- Số lượng NG
				SELECT ISNULL(SUM(MLI.InitialQty), 0)
				FROM  
					STB_MaterialLotInfo MLI
				WHERE 1=1
					AND MLI.LotID LIKE 'SL%'
					AND (SELECT MM.ProductGroupCode 
						FROM STB_MaterialLotInfo MLI2
						LEFT JOIN STB_MaterialMaster MM ON MLI2.MaterialCode = MM.MaterialCode
						WHERE MLI.PackingIdParent = MLI2.LotID) = 'ANODE-FOIL'	
					AND MLI.IsCheck = 'Reject'
					AND MLI.IsSlitting = '1'

					AND MLI.CheckTime BETWEEN @FromDate AND @ToDate -- thời gian mà QC kiểm tra và đánh giá
			) AS NGQty,
			
			(	-- Số lượng đã Pass
				SELECT ISNULL(SUM(MLI.InitialQty), 0)
				FROM  
					STB_MaterialLotInfo MLI
				LEFT JOIN STB_MaterialMaster MM ON MLI.MaterialCode = MM.MaterialCode
				WHERE 1=1
					AND MLI.LotID LIKE 'SL%'
					AND MM.ProductGroupCode = 'ANODE-FOIL'
					AND MLI.IsCheck = 'Pass'
					AND MLI.IsSlitting = '1'

					AND MLI.CheckTime BETWEEN @FromDate AND @ToDate -- thời gian mà QC kiểm tra và đánh giá
			) AS OKQty,

			(	-- Tổng số lượng 
				SELECT ISNULL(SUM(MLI.InitialQty), 0)
				FROM  
					STB_MaterialLotInfo MLI
				WHERE 1=1
					AND MLI.LotID LIKE 'SL%'
					AND (SELECT MM.ProductGroupCode 
						FROM STB_MaterialLotInfo MLI2
						LEFT JOIN STB_MaterialMaster MM ON MLI2.MaterialCode = MM.MaterialCode
						WHERE MLI.PackingIdParent = MLI2.LotID) = 'ANODE-FOIL'
					AND MLI.WorkCenterCode = 'VVT_F3'
					AND MLI.IsCheck IS NOT NULL
					AND IsSlitting = 1

					AND MLI.CheckTime BETWEEN @FromDate AND @ToDate -- thời gian mà QC kiểm tra và đánh giá
			) AS SUMSlittingQty


	UNION ALL

	SELECT 
			N'Giấy (Con-paper) (KG)' AS GroupCode,
			(	-- Số lượng NG	
				SELECT ISNULL(SUM(MLI.InitialQty), 0)
				FROM  
					STB_MaterialLotInfo MLI
				WHERE 1=1
					AND MLI.LotID LIKE 'SL%'
					AND (SELECT MM.ProductGroupCode 
						FROM STB_MaterialLotInfo MLI2
						LEFT JOIN STB_MaterialMaster MM ON MLI2.MaterialCode = MM.MaterialCode
						WHERE MLI.PackingIdParent = MLI2.LotID) = 'CON-PAPER'
					AND MLI.IsCheck = 'Reject'
					AND MLI.IsSlitting = '1'

					AND MLI.CheckTime BETWEEN @FromDate AND @ToDate -- thời gian mà QC kiểm tra và đánh giá
			) AS NGQty,
			
			(	-- Số lượng đã Pass
				SELECT ISNULL(SUM(MLI.InitialQty), 0)
				FROM  
					STB_MaterialLotInfo MLI
				LEFT JOIN STB_MaterialMaster MM ON MLI.MaterialCode = MM.MaterialCode
				WHERE 1=1
					AND MLI.LotID LIKE 'SL%'
					AND MM.ProductGroupCode  = 'CON-PAPER'
					AND MLI.IsCheck = 'Pass'
					AND MLI.IsSlitting = '1'

					AND MLI.CheckTime BETWEEN @FromDate AND @ToDate -- thời gian mà QC kiểm tra và đánh giá
			) AS OKQty,

			(	-- Tổng số lượng 	
				SELECT ISNULL(SUM(MLI.InitialQty), 0)
				FROM  
					STB_MaterialLotInfo MLI
				WHERE 1=1
					AND MLI.LotID LIKE 'SL%'
					AND (SELECT MM.ProductGroupCode 
						FROM STB_MaterialLotInfo MLI2
						LEFT JOIN STB_MaterialMaster MM ON MLI2.MaterialCode = MM.MaterialCode
						WHERE MLI.PackingIdParent = MLI2.LotID) = 'CON-PAPER'
					AND MLI.WorkCenterCode = 'VVT_F3'
					AND MLI.IsCheck IS NOT NULL
					AND IsSlitting = 1

					AND MLI.CheckTime BETWEEN @FromDate AND @ToDate -- thời gian mà QC kiểm tra và đánh giá
			) AS SUMSlittingQty





END

GO

