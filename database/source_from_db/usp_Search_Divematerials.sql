 CREATE PROC [dbo].[usp_Search_Divematerials]
AS
BEGIN

SET NOCOUNT ON;


SELECT
		DISTINCT T2.LOTID

FROM
		STB_MaterialDocLotInfo T2 WITH(NOLOCK)


WHERE 
T2.LotID <>'' AND

 T2.LOTID IS NOT NULL  AND T2.Isused IS NULL AND T2.CreateUserID NOT IN ('hmkang','hjjo','dyseo','bgkoos3','bgkoos2','assy_packing','jcsong','jcsong2','jcsong','yjyu','yjyu2','yjyu3','yjjoo','ucJo2','ucJo','twkim','mhlee','mklee','khjeon','kilee','kilee3','kilee2','hrwoo','bgkoos','assy_worker2','jykim','bgkoos')

 -- 
 --  
--SELECT * FROM STB_MaterialDocLotInfo




--SELECT DISTINCT
--		T2.CreateUserID

--FROM
--		STB_MaterialDocLotInfo T2 WITH(NOLOCK)

END