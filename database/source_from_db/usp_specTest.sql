create proc usp_specTest @barcode varchar(20), @volt varchar(10) output, @farad varchar(10) output
AS
begin
	select @volt = MBIExtText04
      ,@farad = MBIExtText05
  from STB_ModelBasicInfo
 where ModelCode = (
					select top 1 MaterialCode
					  from STB_SetInfo
					 where barcode = @barcode
					)
end