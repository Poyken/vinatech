-- =============================================
-- Author:	
-- Create date: 
-- Description:	Hiển thị danh sách xuất kho thành phẩm RD
-- exec usp_VN_ShowAllFinishGoodMES_RD_HN_Export '2026-03-01','2026-03-31'
-- =============================================
CREATE PROCEDURE [dbo].[usp_VN_ShowAllFinishGoodMES_RD_HN_Export]
	-- Add the parameters for the stored procedure here
	@pFromdateinput DATE = NULL,
	@pTodateinput DATE = NULL

AS
BEGIN
  --select top 2 * from STB_VN_FINISHGOODS_HN_Export
	--select top 2 * from stb_materialLotinfo
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
    -- Insert statements for procedure here
	-- Assign fromdate and todate 
	DECLARE @Fromdateinput DATE = @pFromdateinput
	DECLARE @Todateinput DATE = @pTodateinput

	  	-- Lấy marking mới nhất theo LotNo
	;WITH Marking_CTE AS (
		SELECT *
		FROM (
			SELECT *,
				ROW_NUMBER() OVER (PARTITION BY Barcode ORDER BY CreateDateTime DESC) AS rn
			FROM STB_CreateMarkingLetterAndQtyForBarcode
		) T
		WHERE rn = 1
	),

	-- Lấy 1 MaterialCode duy nhất theo PackingID
	Material_CTE AS (
		SELECT *
		FROM (
			SELECT *,
				ROW_NUMBER() OVER (PARTITION BY PackingID ORDER BY CreateDateTime DESC) AS rn
			FROM stb_materialLotinfo
		) T
		WHERE rn = 1
	)

	SELECT
		T2.CodeExport,
		T2.LotNo,
		T2.PackingID,
		T2.PackingID_Divide,
		/*
		CASE 
		WHEN T6.MergeParentID IS NOT NULL THEN T6.MergeParentID
		ELSE T5.MergeParentID
	    END AS MergeParentID,
		*/
		COALESCE( T6.MergeParentID, T5.MergeParentID) AS MergeParentID, 	
		SUM(T2.Qty) AS Qty,
		/*
		CASE 
		WHEN T6.MaterialCode IS NOT NULL THEN T6.MaterialCode
		ELSE T5.MaterialCode
	END AS MaterialCode,
	*/    COALESCE( T6.MaterialCode, T5.MaterialCode) AS MaterialCode,
		T3.MarkingCode,
		T3.MarkingName,
		T2.Country,
		T2.SoPhieuXuatKho,
		T2.SoInVoice,
		T2.SoToKhaiHaiQuan,
		T2.TypeExport,
		T2.TRANSPORT,
		T2.CustomerName,
		T2.LevelOut,
		T2.DateRequestExport,
		T2.CreateUserID,
		ISNULL(T8.MBIExtText04, '') + 'V ' +
		ISNULL(T8.MBIExtText05, '') + 'µF, Ø' +
		CONVERT(VARCHAR, CONVERT(DECIMAL(10,1), T8.MBISizeW)) + '*' +
		CONVERT(VARCHAR, CONVERT(DECIMAL(10,1), T8.MBISizeH)) + 'L' AS FullSpec

	FROM STB_VN_RND_FINISHGOODS_HN_Export T2
	LEFT JOIN Material_CTE T5 ON T2.PackingID = T5.PackingID
	LEFT JOIN Marking_CTE T3 ON T2.LotNo = T3.Barcode
	LEFT JOIN STB_ModelBasicInfo T8 ON T8.ModelCode = T5.MaterialCode
	LEFT JOIN STB_DividePackaging  T6 WITH(NOLOCK) ON T2.PackingID=T6.PackingID

	WHERE
		(@Fromdateinput IS NULL OR CONVERT(DATE, T2.CreateDateTime) >= @Fromdateinput)
		AND 
		(@Todateinput IS NULL OR CONVERT(DATE, T2.CreateDateTime) <= @Todateinput)

	GROUP BY
		T2.CodeExport,
		T2.LotNo,
		T2.PackingID,
		T2.PackingID_Divide,
		/*
		CASE 
        WHEN T6.MergeParentID IS NOT NULL THEN T6.MergeParentID
        ELSE T5.MergeParentID
    END,
		CASE 
		WHEN T6.MaterialCode IS NOT NULL THEN T6.MaterialCode
		ELSE T5.MaterialCode
	END,
	*/  COALESCE( T6.MergeParentID, T5.MergeParentID), 	
    COALESCE( T6.MaterialCode, T5.MaterialCode), 	
		T3.MarkingCode,
		T3.MarkingName,
		T2.Country,
		T2.SoPhieuXuatKho,
		T2.SoInVoice,
		T2.SoToKhaiHaiQuan,
		T2.TypeExport,
		T2.TRANSPORT,
		T2.CustomerName,
		T2.LevelOut,
		T2.DateRequestExport,
		T2.CreateUserID,
		T8.MBIExtText04,
		T8.MBIExtText05,
		T8.MBISizeW,
		T8.MBISizeH




END


