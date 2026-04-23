CREATE PROC [dbo].[usp_VN_ShowCheckItem]
AS
BEGIN
	
	
				SELECT
						ID,
						CODELINE,
						NAMELINE,
						QTY,
						TYPEINPUT,
						INPUT,
						UNIT,
						REMARK,
						DEPARTMENT,
						CATEGORIESCHECK,
						TYPES,
						CODENAME,
						IDS,
						CONVERT(DATE,CreateDateTime) AS DATES,
						CreateUserID,
						CONVERT(DATE,ChangeDateTime) AS ChageDate,
						ChangeUserID

				FROM
						STB_VN_ITEM_CHECK WITH(NOLOCK)

				WHERE 
			  CODELINE = 'MOTHER'
			ORDER BY CreateDateTime DESC

END


-- SELECT * FROM STB_VN_ITEM_CHECK WITH(NOLOCK)  where createuserid = 'nguyennha'



--DELETE STB_VN_ITEM_CHECK WHERE ID = '3270'  