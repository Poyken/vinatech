
-- =========================================================================================
-- Author : Kilee@vina.co.kr
-- Create date: 2020-09-03
-- Browsable : true
-- Group : 품질관리 > 해당 LotNo
-- Description:	
-- Modified: 
--               2020.12.16 SQL문 수정

--  EXEC usp_SearchLotNo_get 'kilee','Korean','20121000004'
-- =========================================================================================
CREATE  PROCEDURE [dbo].[usp_SearchLotNo_get]
 							@pProcessUserID VARCHAR(20),
							@pProcessLanguage VARCHAR(20),
							@pMaterialQcNo VARCHAR(20) = NULL						
AS

BEGIN

	SET NOCOUNT ON;

	DECLARE @MaterialQcNo VARCHAR(20) = CASE WHEN ISNULL(@pMaterialQcNo,'') = '' THEN '' ELSE @pMaterialQcNo END
	DECLARE @LotNo           VARCHAR(500)

   SELECT Case when MDLI.LotNo = '' Then MDLI.LotID Else  	MDLI.LotNo End  As LotNo                               -- 2020.12.16수정 (업체바코드 우선순위)
		    , IsNull(MDLI.IsIQCSampleLot, 0)                                                 As IsIQCSampleLot
	FROM  STB_MaterialDocLotInfo MDLI
			  LEFT OUTER JOIN STB_MaterialDocDetail MDD	ON MDLI.MaterialDocDetailNo = MDD.MaterialDocDetailNo      -- 두번째화면 Table			
			  LEFT OUTER JOIN STB_MaterialQcInfo  SMQ		ON MDD.MaterialIqcNo = SMQ.MaterialQcNo                       
	WHERE 1=1	   	   	   
	   AND ((SMQ.MaterialQcNo = @MaterialQcNo))             
	  -- AND SMQ.MaterialQcNo = '20121600002'                            -- 수입검사번호!!
        
END

/*

select * from STB_MaterialQcInfo       where MaterialQcNo=  '20121000004'
select * from STB_MaterialDocDetail   where MaterialIqcNo=  '20121000004'
select * from STB_MaterialDocLotInfo where MaterialDocDetailNo =  '201216000127'

*/