-- =============================================
-- Author:		Nguyễn Hải Triều
-- Create date: 2025-09-19
-- Description:	Chọn danh sách công ty
-- =============================================
CREATE PROCEDURE [dbo].[usp_SelectedCompany_PopUp] 
	-- Add the parameters for the stored procedure here

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	  -- Tạo bảng tạm
    CREATE TABLE #CompanyList
    (
        CompanyId INT IDENTITY(1,1),
        CompanyName NVARCHAR(200)
    );

    -- Insert 2 công ty mẫu
    INSERT INTO #CompanyList (CompanyName)
    VALUES (N'VINA ENESOL'),
           (N'VINATECH'),
		    (N'VINA ENESOL VINA');

    -- Trả dữ liệu ra ngoài
    SELECT CompanyId, CompanyName
    FROM #CompanyList;
END
