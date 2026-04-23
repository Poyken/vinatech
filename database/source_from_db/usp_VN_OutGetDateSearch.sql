-- =============================================
-- Author:		Mr.Duy
-- Create date: 2024-05-08
-- Description:	Convert và trả về ngày tháng cần thiết để tìm kiếm trong tồn nvl trên line
-- =============================================
CREATE PROCEDURE [dbo].[usp_VN_OutGetDateSearch]
	@pParamGetDate date,
	@outFromDateExportNVL varchar(50) Output,
	@outToDateExportNVL varchar(50) Output ,
	@outFromDateTotalQtyProduct varchar(50) Output,
	@outToDateTotalQtyProduct varchar(50) Output
AS
BEGIN

	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	-- set @pParamGetDate = DATEADD(month, -1, GETDATE()) nếu muốn lấy tháng bé hơn hiện tại 1 thì mở cái này ra
	SET NOCOUNT ON;
	declare @GetDate varchar(20)
  
	select @GetDate= DATEADD(d,-1, DATEADD(mm, DATEDIFF(mm, 0 ,@pParamGetDate)+1, 0)) -- ngày cuối tháng ví dụ : 2024-05-31 00:00:00


	select @outFromDateExportNVL =   convert(varchar(7), dateadd(month,0, @pParamGetDate) , 120 ) +'-01' -- ngày đầu tháng của tháng truyền vào
	select @outToDateExportNVL   = CONVERT(VARCHAR(10), DATEADD(DAY, 0, CONVERT(smalldatetime, @GetDate)), 120) + ' 23:59:59'-- ngày cuối của tháng convert 2024-05-31 23:59:59
	/*
	select @outFromDateExportNVL =   convert(varchar(7), dateadd(month,0, @pParamGetDate) , 120 ) +'-21 ' + ' 10:00:00' -- ngày đầu tháng của tháng truyền vào
	select @outToDateExportNVL   = convert(varchar(7), dateadd(month,0, @pParamGetDate) , 120 ) +'-23' + ' 10:00:00'
	*/
    select @outFromDateTotalQtyProduct   = CONVERT(VARCHAR(10), @outFromDateExportNVL, 120) + ' 10:00:00'  -- ngày đầu của tháng convert   2024-05-01 00:00:00
	select @outToDateTotalQtyProduct = CONVERT(VARCHAR(10), DATEADD(DAY, 1, CONVERT(smalldatetime, @GetDate)), 120) + ' 10:00:00'  --ngày đầu tháng của tháng tiếp theo để tìm kiếm tổng số lượng hàng đã cho vào line trong 1 tháng
	
	--select @outFromDateTotalQtyProduct =   convert(varchar(7), dateadd(month,0, @pParamGetDate) , 120 ) +'-21 ' + ' 10:00:00' -- ngày đầu tháng của tháng truyền vào
	--select @outToDateTotalQtyProduct   = convert(varchar(7), dateadd(month,0, @pParamGetDate) , 120 ) +'-24' + ' 10:00:00'

	--print @outToDateExportNVL
	
END

