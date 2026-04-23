-- =============================================
-- Author:		Mr.Duy
-- Create date: 2024-05-07
-- Description:	lấy ra ngày đầu tháng , ngày cuối tháng , đầu tháng sau với tham số là ngày tháng truyền vào
-- =============================================  exec usp_VN_OutGetDateCreate '2024-06-07'
CREATE PROCEDURE [dbo].[usp_VN_OutGetDateCreate]
	@pParamGetDate varchar(50),
	@outFromDateExportNVL varchar(50) Output,
	@outToDateExportNVL varchar(50) Output ,
	@outFromDateTotalQtyProduct varchar(50) Output,
	@outToDateTotalQtyProduct varchar(50) Output,
	@month int out,
	@year int out
AS
BEGIN

	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	declare @ParamGetDate varchar(50)
	--nếu muốn lấy tháng bé hơn hiện tại 1 thì mở cái này ra. dùng khi mà chạy tự động thêm dữ liệu đầu tháng
	set @ParamGetDate = DATEADD(month, -1, @pParamGetDate) 
	SET NOCOUNT ON;
	declare @GetDate varchar(20)
	set @month =  Month(@ParamGetDate)
	set @year =  Year(@ParamGetDate)
	select @GetDate= DATEADD(d,-1, DATEADD(mm, DATEDIFF(mm, 0 ,@ParamGetDate)+1, 0)) -- ngày cuối tháng ví dụ : 2024-05-31 00:00:00


	select @outFromDateExportNVL =   convert(varchar(7), dateadd(month,0, @ParamGetDate) , 120 ) +'-01' -- ngày đầu tháng của tháng truyền vào
	select @outToDateExportNVL   = CONVERT(VARCHAR(10), DATEADD(DAY, 0, CONVERT(smalldatetime, @GetDate)), 120) + ' 23:59:59'-- ngày cuối của tháng convert 2024-05-31 23:59:59

    select @outFromDateTotalQtyProduct   = CONVERT(VARCHAR(10), @outFromDateExportNVL, 120) + ' 10:00:00'  -- ngày đầu của tháng convert   2024-05-01 00:00:00
	select @outToDateTotalQtyProduct = CONVERT(VARCHAR(10), DATEADD(DAY, 1, CONVERT(smalldatetime, @GetDate)), 120) + ' 10:00:00'  --ngày đầu tháng của tháng tiếp theo để tìm kiếm tổng số lượng hàng đã cho vào line trong 1 tháng
	
	--print @outToDateExportNVL
	
END


