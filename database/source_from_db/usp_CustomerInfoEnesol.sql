-- =============================================
-- Author:		Nguyễn Hải Triều
-- Create date: 2025-08-29
-- Description:	Láy ra danh sách khách hàng
-- exec usp_CustomerInfoEnesol
-- =============================================
CREATE PROCEDURE [dbo].[usp_CustomerInfoEnesol]
	-- Add the parameters for the stored procedure here
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT T1.CustomerCode,T1.CustomerName,T2.MaterialCode AS VendorPN from STB_CustomerInfoEnesol T1
	LEFT join STB_MaterialCodeByCustomer T2 on T1.CustomerCode=T2.CustomerCode
	
END
