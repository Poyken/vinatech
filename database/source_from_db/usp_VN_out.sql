--SELECT * FROM STB_VN_FINISHGOODS

CREATE proc [dbo].[usp_VN_out]  -- EXEC  usp_VN_out 'PKMU1400187','Nha'
@PackingID NVARCHAR(50),
@UserID NVARCHAR(50)
AS
BEGIN



		SELECT
				 IDCODE 
				,PackingID
				,MaterialCode
				,MaterialName
				,Partno
				,LotNo
				,PackQty
				,N'Xuất vào kho tạm, chờ xuất' as Outteam
				,USERID
				,LOCATIONS
				,@UserID AS Personout
		FROM
			 STB_VN_FINISHGOODS WITH(NOLOCK)
		WHERE
			  PackingID = @PackingID AND Statusout IS NULL

		GROUP BY 
				 IDCODE 
				,PackingID
				,MaterialCode
				,MaterialName
				,Partno
				,LotNo
				,PackQty
				,CreateDate
				,USERID
				,LOCATIONS
				
END