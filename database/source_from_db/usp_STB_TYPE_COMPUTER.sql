CREATE PROC usp_STB_TYPE_COMPUTER
@pProcessUserID VARCHAR(20),
@pProcessLanguage VARCHAR(20)
as
begin
select IDTC,NameTypes from STB_TYPE_COMPUTER WITH(NOLOCK)
end