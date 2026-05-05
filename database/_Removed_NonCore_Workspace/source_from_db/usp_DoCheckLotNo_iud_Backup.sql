-- =============================================
-- Author:	    Kangs (kilee@vina.co.kr)
-- Create date: 2020-09-05
-- Browsable : true
-- Group : 품질관리 > Lot상세조회 > 검사Lot등록 Button클릭시
-- Description:	검사를 한 Lot정보를 업데이트 합니다.
-- Modified:  
-- =============================================
Create PROCEDURE [dbo].[usp_DoCheckLotNo_iud_Backup]
						@pProcessUserID VARCHAR(20),
						@pProcessLanguage VARCHAR(20),
						@pLotNo  VARCHAR(20),
						@pIsIQCSampleLot BIT = NULL,
						@pMaterialQcNo VARCHAR(20) = NULL
AS

BEGIN
	Declare @LotNo               VARCHAR(20) = @pLotNo
	         , @IsIQCSampleLot   BIT = ISNULL(@pIsIQCSampleLot, CONVERT(BIT,0))
			 , @IQCSampleLotList NVARCHAR(Max) 

	DECLARE @MaterialQcNo VARCHAR(20) = CASE WHEN ISNULL(@pMaterialQcNo,'') = '' THEN '' ELSE @pMaterialQcNo END

    -- 1. 업데이트
			UPDATE STB_MaterialDocLotInfo
				  SET IsIQCSampleLot = @IsIQCSampleLot
			 WHERE 1=1	   	   	   
				AND ((LotNo = @LotNo ))

	
	----- 2. LotNo를 구분자(,)이용하여 입력후 저장	   
	       SELECT @IQCSampleLotList = IQCSampleLotList   FROM STB_MaterialQcInfo  WHERE MaterialQcNo = @MaterialQcNo
		   --  SELECT  IQCSampleLotList   FROM STB_MaterialQcInfo  WHERE MaterialQcNo = '20090900004'

	
	   			IF @IQCSampleLotList IS NULL

					BEGIN

						UPDATE STB_MaterialQcInfo
						   SET IQCSampleLotList = @LotNo                
						 WHERE MaterialQcNo = @MaterialQcNo

					END 

				ELSE

				   BEGIN

						UPDATE STB_MaterialQcInfo
							 SET IQCSampleLotList = IQCSampleLotList + ',' + @LotNo
						WHERE MaterialQcNo = @MaterialQcNo

					END


								
END


--SELECT MDLI.LotNo		   		   
--		, IsNull(MDLI.IsIQCSampleLot, 0) AS IsIQCSampleLot
--FROM  STB_MaterialDocLotInfo MDLI
--			LEFT OUTER JOIN STB_MaterialDocDetail MDD	ON MDLI.MaterialDocDetailNo = MDD.MaterialDocDetailNo             -- 두번째화면 Table			
--			LEFT OUTER JOIN STB_MaterialQcInfo  SMQ		ON MDD.MaterialIqcNo = SMQ.MaterialQcNo                       
--WHERE 1=1	   	   	   
--	AND ((SMQ.MaterialQcNo = '20090900002'))


--	Select VendorLotNo, * from STB_MaterialDocLotInfo where VendorLotNo is not null

--Select VendorLotNo, * from STB_MaterialDocLotInfo where MaterialDocDetailNo =  '20090900003'


----ALTER TABLE STB_MaterialQcInfo ADD IQCSampleLotList NVARCHAR(Max) Null

---- Select IQCSampleLotList, * from STB_MaterialQcInfo



--select IQCSampleLotList, * from  STB_MaterialQcInfo 
--where 1=1
--and MaterialQcNo = '20090900004'