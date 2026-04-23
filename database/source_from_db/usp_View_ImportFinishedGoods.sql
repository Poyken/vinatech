	   CREATE proc usp_View_ImportFinishedGoods
	   as
	   begin

	   SELECT 
			  
				'' + replace(PublicCode, ' ', '') + '' AS PublicCode, 
				SUBSTRING('' + REPLACE(PartNo, ' ', ''),1,33) + '' AS PartNo,
		        --SUBSTRING(PartNo,1,33) AS PartNo,
				SUM(Packqty) AS Qty,
				'PCS' AS 'UNIT', 
				ISUSED_IMPORTS

		FROM
				STB_VN_FINISHGOODS T1 WITH(NOLOCK) 

		WHERE
			   StatusSystem = N'Nhập'
			   AND Statusout IS NULL
			   AND ISUSED_IMPORTS IS NULL

		GROUP BY PublicCode,PartNo,ISUSED_IMPORTS

END
