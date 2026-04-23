CREATE PROCEDURE [dbo].[usp_InformationWaste_get](
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
    @pCodeNVL VARCHAR(50) = NULL

)
as
begin
     DECLARE @ VARCHAR(50) = CASE WHEN ISNULL(@pCodeNVL,'') = '' THEN '%' ELSE @pCodeNVL END
  SELECT 
       WS.LOAIHANG,
       WS.CODENVL,
       WS.NAMESNVL,
       WS.UNIT,
       WS.PRICES,
       WS.NORM,
       WS.DESCPRTIONS,
       WS.CreateDateTime,
       WS.CreateUserID ,
       WS.ChangeDateTime,
       WS.ChangeUserID
  
   from
       STB_VN_B598 WS WHERE (@pCodeNVL IS NULL OR @pCodeNVL = '' OR WS.CODENVL LIKE @pCodeNVL)
end