-- Procedure: HttpRequest
CREATE procedure HttpRequest
	@sUrl varchar(MAX)
As
Declare
 @obj int
,@hr int
,@msg varchar(MAX)


exec @hr = sp_OACreate 'MSXML2.ServerXMLHttp', @obj OUT

if @hr <> 0 begin Raiserror('sp_OACreate MSXML2.ServerXMLHttp.3.0 failed', 16,1) return end


exec @hr = sp_OAMethod @obj, 'open', NULL, 'POST', @sUrl, false
if @hr <>0 begin set @msg = 'sp_OAMethod Open failed' goto eh end


exec @hr = sp_OAMethod @obj, 'setRequestHeader', NULL, 'Content-Type','application/x-www-form-urlencoded'

if @hr <>0 begin set @msg = 'sp_OAMethod setRequestHeader failed' goto eh end


exec @hr = sp_OAMethod @obj, send, NULL, ''

if @hr <>0 begin set @msg = 'sp_OAMethod Send failed' goto eh end

 exec @hr = sp_OADestroy @obj
return

eh:
exec @hr = sp_OADestroy @obj
Raiserror(@msg, 16, 1)
return

GO

