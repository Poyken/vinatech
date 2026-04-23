-- =============================================
-- Author:		Nguyễn Hải Triêu
-- Create date: 2025-06-26
-- Description:	In tem cho khách hàng Solma
-- =============================================
CREATE PROCEDURE [dbo].[usp_getLabelSolma]
	-- Add the parameters for the stored procedure here
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pPO                VARCHAR(50)=null,  -- VD: VP0202504170112
    @pQty               INT=1,          -- VD: 1000
    @pNgayIntem         DATETIME,     -- VD: 2025-06-19
    @pCustomer        VARCHAR(50)=null,  -- VD: 2409A0200099
    @pMaterialCode      VARCHAR(50)=null,  -- VD: 25RSC470ME11XXT001
    @pNumberOfLabel     INT =2000          -- số lượng nhãn cần in


AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	DECLARE @TotalLabel INT;
	SET @TotalLabel = @pNumberOfLabel + 1999;
    -- Insert statements for procedure here
	CREATE TABLE #tmpLabel (Num INT);
    DECLARE @i INT = 2000;
    WHILE @i <= @TotalLabel
    BEGIN
        INSERT INTO #tmpLabel VALUES(@i);
        SET @i = @i + 1;
    END

    SELECT
        N'SOLUM_VINA ENESOL' AS CompanyName,
        @pPO AS PO,
        FORMAT(@pNgayIntem, 'yyyy-MM-dd') AS DatePrint,
		FORMAT(@pNgayIntem, 'yyMMdd') AS DateCode,
        @pQty AS Qty,
        @pCustomer AS Customer,
        @pMaterialCode AS MaterialCodeSolMa,
        N'MADE IN VIETNAM' AS MadeInText,
        Num AS LabelNo,
		'Report' AS CommandType
    FROM #tmpLabel;
END
