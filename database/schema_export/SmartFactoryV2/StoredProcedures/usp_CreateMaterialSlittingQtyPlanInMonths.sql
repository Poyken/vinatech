-- Procedure: usp_CreateMaterialSlittingQtyPlanInMonths
-- Author:		Mr.Duy
-- Create date: 2025-02-11
-- Description:	Thêm dữ liệu từ file excel để tính số lượng nguyên liệu poil trong tháng
-- =============================================
-- exec usp_CreateMaterialSlittingQtyPlanInMonths '63RHHL120ME11XT001','6000','2025','2'
create PROCEDURE usp_CreateMaterialSlittingQtyPlanInMonths 
	@Materialcode varchar(50),
	@Qty int,
	@Yearr varchar(4),
	@Months varchar(2)
AS
BEGIN

	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	BEGIN TRY
    -- Insert statements for procedure here
	IF EXISTS (SELECT 1 FROM STB_MaterialSlittingQtyPlanInMonths WHERE Materialcode = @Materialcode and Yearr=@Yearr and Months=@Months)
        BEGIN
		declare @err nvarchar(200)=N'Mã này của tháng đã tồn tại trong hệ thống!'+@Materialcode
            RAISERROR(@err,16, 1);
        END

		INSERT INTO STB_MaterialSlittingQtyPlanInMonths (MaterialCode, Qty,Yearr,Months,CreateDatetime) VALUES (@MaterialCode, @Qty,@Yearr,@Months,GETDATE())
	END TRY
	BEGIN CATCH

		DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        THROW 50002, @ErrorMessage, 1;
	END CATCH
END

GO

