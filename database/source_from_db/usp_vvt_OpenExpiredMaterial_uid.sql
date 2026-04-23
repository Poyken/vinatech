

CREATE PROCEDURE [dbo].[usp_vvt_OpenExpiredMaterial_uid]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pLotID VARCHAR(20)=null,
	@pOpenExpired Bit=0
AS
BEGIN
	SET NOCOUNT ON;

	if(len(@pLotID)>10)
		insert into stb_vvt_OpenExpiredMaterial(LotID,CreateUserID,OpenExpired) 
		values(@pLotID,@pProcessUserID,convert(BIT,@pOpenExpired))
		
END

