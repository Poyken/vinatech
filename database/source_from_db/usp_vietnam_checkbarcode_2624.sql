-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>

--- usp_vietnam_checkbarcode_2624 'partno','vvv',1000,'1'


-- =============================================
CREATE PROCEDURE [dbo].[usp_vietnam_checkbarcode_2624] 
@pPartNo Varchar(50),
@pLotNo Varchar(50),
@pQuantity Varchar(50),
@pRemark nVarchar(100),
@pLevel int
AS
BEGIN
	INSERT INTO  STB_VietNam_CheckBarcode_2624 (PartNo,LotNo,Quantity,Remark,Levels)
	VALUES (@pPartNo,@pLotNo,@pQuantity,@pRemark,@pLevel)
	
END


--            delete from  STB_VietNam_CheckBarcode_2624 where partno = 'k123'