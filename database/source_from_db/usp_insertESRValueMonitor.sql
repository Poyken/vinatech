create proc usp_insertESRValueMonitor
	@pdatemonittor date,
	@plotno nvarchar(50),
	@pnames nvarchar(50),
	@pnote nvarchar(100),
	@pvalues nvarchar(50),
	@pAttribute1 nvarchar(200)
as
begin
	INSERT INTO stb_ESRValueMonitor (date,lotno, employee, value, note,Attribute1, createdate) 
	values(@pdatemonittor,@plotno,@pnames,@pnote,@pvalues,@pAttribute1,DATEADD(HH, -2, GETDATE()))
end
