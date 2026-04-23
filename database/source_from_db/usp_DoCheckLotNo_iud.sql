-- =============================================
-- Author:	    Kangs (kilee@vina.co.kr)
-- Create date: 2020-09-05
-- Browsable : true
-- Group : 품질관리 > Lot상세조회 > 검사Lot등록 Button클릭시
-- Description:	검사를 한 Lot정보를 업데이트 합니다.
-- Modified:  
-- =============================================
CREATE PROCEDURE [dbo].[usp_DoCheckLotNo_iud]
						@pProcessUserID VARCHAR(20),
						@pProcessLanguage VARCHAR(20),
						@pLotNo  VARCHAR(20),
						@pIsIQCSampleLot BIT = NULL,
						@pMaterialQcNo VARCHAR(20) = NULL
AS

BEGIN
	Declare @LotNo                VARCHAR(20) = @pLotNo
	         , @IsIQCSampleLot   BIT = ISNULL(@pIsIQCSampleLot, CONVERT(BIT,0))
			 , @IQCSampleLotList NVARCHAR(Max) 
            ,  @MaterialQcNo      VARCHAR(20) = CASE WHEN ISNULL(@pMaterialQcNo,'') = '' THEN '' ELSE @pMaterialQcNo END

    -- 1. 체크박스 업데이트 부분
			UPDATE STB_MaterialDocLotInfo
				  SET IsIQCSampleLot = @IsIQCSampleLot
			 WHERE 1=1	   	   	   
				AND ((LotNo = @LotNo OR LotID = @LotNo ))

	
	----- 2. LotNo를 구분자(,)이용하여 입력후 저장	   


	       SELECT @IQCSampleLotList = IQCSampleLotList   
		     FROM STB_MaterialQcInfo  
			 WHERE MaterialQcNo = @MaterialQcNo


		   --  SELECT  IQCSampleLotList,  *   FROM STB_MaterialQcInfo  WHERE MaterialQcNo = '20090900003'

	   			IF @IQCSampleLotList IS Null  And  @IsIQCSampleLot = 1 

					BEGIN

						UPDATE STB_MaterialQcInfo
						   SET IQCSampleLotList = @LotNo                
						 WHERE MaterialQcNo = @MaterialQcNo

					END 

				 IF @IQCSampleLotList Is Not Null  And  @IsIQCSampleLot = 1 

				   BEGIN

						UPDATE STB_MaterialQcInfo
							 SET IQCSampleLotList = IQCSampleLotList + ',' + @LotNo
						WHERE MaterialQcNo = @MaterialQcNo

					END

						
END