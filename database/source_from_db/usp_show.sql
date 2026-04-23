CREATE PROC [dbo].[usp_show]
@pProcessUserID VARCHAR(20),
@pProcessLanguage VARCHAR(20),
@pCodeLine VARCHAR(50)=NULL,
@pNameLine VARCHAR(50)=NULL,
@pLineDesc VARCHAR(100)=NULL,
@pCreateDateTime datetime=NULL,
@pCreateUserID VARCHAR(20)=NULL,
@pChangeDateTime datetime=NULL,
@pChangeUserID VARCHAR(20)=NULL
AS
BEGIN
SELECT CodeLine,NameLine,LineDesc,CreateDateTime,CreateUserID,ChangeDateTime,ChangeUserID FROM STB_TEST01  WITH(NOLOCK)
END