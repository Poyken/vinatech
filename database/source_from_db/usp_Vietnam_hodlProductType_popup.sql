-- =============================================
-- Author:	    Mr.Tung
-- Create date: 2021-05-27
-- =============================================
CREATE PROCEDURE [dbo].[usp_Vietnam_hodlProductType_popup]
AS
BEGIN
	SET NOCOUNT ON;

			select N'Thành phẩm' as ProductType, N'Thành phẩm' as "ProductTypeName"
	union all
		select N'Module Thành phẩm' as ProductType, N'Module Thành phẩm' as "ProductTypeName"
	union all
		select N'Xô cha' as ProductType, N'Xô cha' as "ProductTypeName"
	union all
	select N'Lỗi công đoạn của TQC' as ProductType, N'Lỗi công đoạn của TQC' as "ProductTypeName"
	union all
		select N'Lỗi công đoạn của sản xuất' as ProductType, N'Lỗi công đoạn của sản xuất' as "ProductTypeName"
	union all
		select N'Lỗi OQC, FOQC' as ProductType, N'Lỗi OQC, FOQC' as "ProductTypeName"
	union all
		select N'Lỗi khách hàng' as ProductType, N'Lỗi khách hàng' as "ProductTypeName"
	union all
		select N'Hàng trong kho return' as ProductType, N'Hàng trong kho return' as "ProductTypeName"
	union all
		select N'Hàng chưa xử lý' as ProductType, N'Hàng chưa xử lý' as "ProductTypeName"
	union all
		select N'Hàng từ công ty mẹ' as ProductType, N'Hàng từ công ty mẹ' as "ProductTypeName"
	union all
		select N'Other' as ProductType, N'Other' as "ProductTypeName"
	
END
