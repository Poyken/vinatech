CREATE PROC [dbo].[usp_DoSendSlackMessage]
	@pMessage NVARCHAR(MAX)
AS
BEGIN
	Declare @Message NVARCHAR(MAX) = @pMessage
	       ,@SlackUrl VARCHAR(200) = 'https://hooks.slack.com/services/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'

	Declare @rtn NVARCHAR(4000) = 'powershell.exe -Command "[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; $json = @{text = ''' + @Message + '''} | ConvertTo-Json; Invoke-RestMethod -Uri '''+ @SlackUrl +''' -Method POST -Body $json -ContentType ''application/json;charset=utf-8''"'

	EXEC xp_cmdshell @rtn
END