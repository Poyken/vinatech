-- Procedure: test_vn
CREATE proc [dbo].[test_vn]
	@pMaterialTypeCode VARCHAR(20) = NULL,
	@pMaterialTypeName VARCHAR(20) = NULL
as
begin
		select * from STB_VNSparePartIOHistory where BasicDate is not null
end
GO

