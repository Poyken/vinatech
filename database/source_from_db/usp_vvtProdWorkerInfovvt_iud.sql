
-- =============================================
-- Author:	    Jeon Gyeong Ho(khjun@awoo.co.kr)
-- Create date: 2018-08-17
-- Browsable : true
-- Group : 생산관리
-- Description:	
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_vvtProdWorkerInfovvt_iud]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
    @pProcessViewName VARCHAR(50),
	@pXml NVARCHAR(MAX) = null
AS
BEGIN
	SET NOCOUNT ON;

	--select top 1 * from STB_VVT_ESRDATA;

    DECLARE @ToDate      VARCHAR(19) ='thu nghiem';
	
	RAISERROR(@ToDate,16,1);

	return;
   
END
