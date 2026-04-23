-- =============================================
-- Author:		Nguyen Hai Trieu	
-- Create date: 26-05-2025
-- Description:	Danh sách các hiện tượng NG
-- =============================================
CREATE PROCEDURE [dbo].[usp_getDefectCause_Popup_C132]

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	-- interfering with SELECT statements.
	CREATE TABLE #DefectCauseTemp (
        DefectCause NVARCHAR(255),
		IsUsed BIT
    );
	INSERT INTO #DefectCauseTemp (DefectCause,IsUsed)
    VALUES 
    ( N'Bẹp, méo case',1),
    ( N'Cong, xước chân tancha',1),
    ( N'Kiểm tra cố định sản xuất',1),
    ( N'Lỗi rơi sản phẩm',1),
    ( N'Lỗi tính năng SD, ESR, Short',1),
    ( N'NG bằng dính đồ',1),
    ( N'NG Biến dạng, kích thước',1),
    ( N'NG Repair',1),
    (N'NG Setup',1),
    ( N'Other',1),
    ( N'PQC check',1),
    ( N'Test điều kiện máy',1),
    ( N'Tràn dịch, dị vật',1);
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	   SELECT DefectCause
    FROM #DefectCauseTemp
	  where IsUsed=1
END
