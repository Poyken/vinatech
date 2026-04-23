
-- =============================================
-- Author:		kilee
-- Create date: 2020-01-03
-- Browsable : true
-- Group : 품질관리
-- Description:	
-- Modified:
-- =============================================
-- EXEC [usp_GetComment_Inspection] 'kilee','Korean','ROUTE_QUALITY','VJJU032R750604','','','','',''

-- EXEC [usp_GetComment_Inspection] 'kilee','Korean','VJJU032R750604'


CREATE PROCEDURE [dbo].[usp_GetComment_Inspection]
						@pProcessUserID     VARCHAR(20),
						@pProcessLanguage VARCHAR(20),
						@pBarcode            VARCHAR(50) = NULL

AS
BEGIN
	SET NOCOUNT ON;
     
	 DECLARE @Barcode VARCHAR(50) = @pBarcode

		


 --   -- [BarodeTable]
	--;WITH BarodeTable AS
	--(
	--				SELECT
	--						CMH.CommInspDocItemNo,
	--						MAX(CMH.MeasureSeq) AS MeasureSeq
	--				FROM  STB_SetInfo SI							
	--						INNER JOIN STB_CommInspMeasureHist CMH								ON	CMH.CommInspDocItemNo = CIDI.CommInspDocItemNo										
	--				WHERE
	--						CIDI.CommInspDocNo = @CommInspDocNo
	--				GROUP BY
	--						CMH.CommInspDocItemNo				
	-- )


	  -- 2.

			SELECT SI.BarCode              AS Barcode			         
			        , SCI.CommInspDocNo  AS CommInspDocNo
			        , SCI.CommInspRemark AS CommInspRemark					
			  FROM 	                      STB_Coment_InspDocItem  SCI
			            LEFT OUTER JOIN STB_SetInfo                    SI	 ON SCI.CommInspDocNo = SI.ControlNo	 
			  WHERE 1=1
			     AND  SI.Barcode =  @Barcode
               --AND  SI.Barcode =  'VJJU033R033502'
			   --AND ControlNo = '20191203000049'

		END

		-- SELECT * FROM STB_Coment_InspDocItem WHERE CommInspDocNo = '20191203000010'
		-- SELECT * FROM STB_SetInfo Where ControlNo = '20191203000010'
		-- SELECT * FROM STB_SetInfo Where Barcode = 'VJJU032R750604'
