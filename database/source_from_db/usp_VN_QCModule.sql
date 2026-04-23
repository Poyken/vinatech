CREATE PROC [dbo].[usp_VN_QCModule]
AS
BEGIN
SELECT
		ID,
		LotNo,
		Species,
		ValuesESR,
		TypeSpecies,
		DateInput,
		Descriptions,
		CreateDateTime,
		RIGHT(CreateDateTime,8) AS TimeIn,
		CreateUserID,
		ChangeDateTime,
		RIGHT(ChangeDateTime,8) AS TimeOuts,
		ChangeUserID
		
FROM 
		STB_VN_QCModule WITH(NOLOCK)
END

--DELETE STB_VN_QCModule
--WHERE ID = ID