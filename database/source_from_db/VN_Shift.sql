CREATE PROC VN_Shift
	@pProcessLanguage VARCHAR(20),
	@pProcessUserID VARCHAR(20)
AS
BEGIN
	 SET NOCOUNT ON;
			
			SELECT 
					CodeShift,
					NameShift
			FROM 
					STB_VN_Shift WITH(NOLOCK)
			WHERE 
					IsUsed=1
END