-- =============================================
-- Author:		Nguyen Hai Trieu
-- Create date: 2025-05-07
-- Description:	Viet Nam print label Mr.Tha
-- =============================================
CREATE PROCEDURE [dbo].[usp_Printer_Label_new]
	@pProcessUserID VARCHAR(20) = NULL,
	@pProcessLanguage VARCHAR(20) = NULL,
	@pPO VARCHAR(50) = NULL,
	@pInvoiceNo VARCHAR(100) = NULL,
	@pNumber INT = 1,
	@TypeInput NVARCHAR(50) = NULL -- Chọn kiểu in chọn theo Popup
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @Input NVARCHAR(50) = @TypeInput

    -- Insert statements for procedure here
	CREATE TABLE #tmp (Num INT)
	-- TAO LIST TU 1 - NUMBEROFTOTAL
	-- Tạo dòng vòng lặp while lặp các giá trị từ 1-n
	DECLARE @i INT=1
	WHILE @i<=@pNumber
	BEGIN
	    INSERT INTO #tmp VALUES(@i)
		SET @i=@i+1
	END
	SELECT
	-- Company Name
	CASE 
		WHEN @TypeInput = N'In tem Foxconn' THEN 'Foxconn' 
		ELSE NULL 
	END AS CompanyName,
	-- PO
	CASE 
		WHEN @TypeInput = N'In tem Foxconn' THEN @pPO 
		ELSE NULL 
	END AS PO,
	-- CT (for Foxconn)
	CASE 
		WHEN @TypeInput = N'In tem Foxconn' THEN
		CASE 
            WHEN @pNumber < 10 THEN '0' + CAST(@pNumber AS VARCHAR)
            ELSE CAST(@pNumber AS VARCHAR)
        END
        + '-' + 
        CASE 
            WHEN Num < 10 THEN '0' + CAST(Num AS VARCHAR)
            ELSE CAST(Num AS VARCHAR)
        END
    ELSE NULL
	END AS CT,
	-- NoCT (for xuất C/T)
	CASE 
		WHEN @TypeInput = N'In tem xuất C/T' THEN
		CASE 
            WHEN @pNumber < 10 THEN '0' + CAST(@pNumber AS VARCHAR)
            ELSE CAST(@pNumber AS VARCHAR)
        END
        + '/' + 
        CASE 
            WHEN Num < 10 THEN '0' + CAST(Num AS VARCHAR)
            ELSE CAST(Num AS VARCHAR)
        END
    ELSE NULL
	END AS NoCT,
	CASE 
		WHEN @TypeInput = N'In tem Foxconn' THEN N'Made in Viet Nam'
		ELSE NULL 
	END AS MadeIn,
	CASE 
		WHEN @TypeInput = N'In tem xuất C/T' THEN  @pInvoiceNo
		ELSE NULL 
	END AS DateOfInvoice,
	CASE 
		WHEN @TypeInput = N'In tem PAC' THEN   
		 CASE 
            WHEN @pNumber < 10 THEN '0' + CAST(@pNumber AS VARCHAR)
            ELSE CAST(@pNumber AS VARCHAR)
        END
        + '/' + 
        CASE 
            WHEN Num < 10 THEN '0' + CAST(Num AS VARCHAR)
            ELSE CAST(Num AS VARCHAR)
        END
    ELSE NULL
	END AS PAC,
	-- Static fix cứng dữ liệu kiểu in
	'Report' AS CommandType
	
	--Num AS ID

FROM #tmp

END
