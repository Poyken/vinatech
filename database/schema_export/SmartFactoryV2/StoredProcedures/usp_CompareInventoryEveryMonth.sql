-- Procedure: usp_CompareInventoryEveryMonth
-- =============================================
-- Author:		Mr.Duy
-- Create date: 2024-08-19
-- Description:	So sánh tồn tay và tồn tự động
-- ============================================ exec usp_CompareInventoryEveryMonth '2024-10-07'
CREATE PROCEDURE [dbo].[usp_CompareInventoryEveryMonth]
	@pDate date = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements. 
	SET NOCOUNT ON;

 
declare @month int = Month(@pDate) , @year int = Year(@pDate) -- lấy ra tháng và năm để tìm kiếm trong kỳ trước đó


declare @pStart datetime,@pEnd datetime
set @pStart = convert(varchar(7), dateadd(month,-1,@pDate) , 120 ) +'-25'
set @pEnd = convert(varchar(7), dateadd(month,0,@pDate) , 120 )+'-24'


	DECLARE	@LotNo          VARCHAR(15) = CASE WHEN ISNULL('', '') = ''         THEN '*' ELSE ''         END

declare @kiemtra int
select  @kiemtra = COUNT(*) from Stb_InventoryUpLine where Months = @month and Years=@year 
;with
					tonkiemke as( --Tồn đầu kỳ lấy ở màn hình B723 do kiểm kê cuối tháng
						
						--Đây là lấy từ bảng tồn thực tế
					select Codeline as InputLineCode,Nameline,sum(Qty) as InventoryNvl,Typeinput,input as MaterialName,Unit as BomUnit,Codename as ChildMaterialCode from STB_VN_ITEM_CHECK      WHERE
								 CreateDateTime BETWEEN  @pStart AND @pEnd
					 group by Codeline,Nameline,Typeinput,input,Unit,Codename

					 --đây là lấy từ bảng tự động
					 --select * from Stb_InventoryUpLine where Months = @month and Years=@year
					),
					tonauto as 
					(
					select InputLineCode,sum(InventoryNvl) as InventoryNvl,MaterialName,BomUnit,ChildMaterialCode from Stb_InventoryUpLine where Months = @month and Years=@year
					 group by InputLineCode,MaterialName,BomUnit,ChildMaterialCode
					)
					,tonghop as (
					select  ttk.InputLineCode,tat.InputLineCode as InputLineCode1,ttk.ChildMaterialCode,tat.ChildMaterialCode as ChildMaterialCode1
					,ttk.InventoryNvl as Tonkiemketay
					,tat.InventoryNvl as Tontudong
					,(ttk.InventoryNvl-tat.InventoryNvl) as chenhlech
					 from tonkiemke ttk 
					left join tonauto tat on ttk.InputLineCode = tat.InputLineCode and ttk.ChildMaterialCode = tat.ChildMaterialCode and ttk.MaterialName = tat.MaterialName
					  -- group by ttk.InputLineCode,ttk.MaterialName,tat.InputLineCode,tat.MaterialName,ttk.ChildMaterialCode,tat.ChildMaterialCode
					)

					select * from tonghop
					
END

GO

