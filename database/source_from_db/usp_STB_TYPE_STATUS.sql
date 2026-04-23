create proc usp_STB_TYPE_STATUS
@pProcessUserID VARCHAR(20),
@pProcessLanguage VARCHAR(20)
as
begin
select IDTS,NameStatus from STB_TYPE_STATUS  WITH(NOLOCK)
end