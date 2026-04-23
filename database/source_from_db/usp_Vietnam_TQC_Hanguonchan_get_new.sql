-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE usp_Vietnam_TQC_Hanguonchan_get_new
@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pInspectionItems nvarchar(200)  = NULL,
	@pSampleQty int = NULL,
	@pLSL numeric(20, 5) = NULL,
	@pUSL numeric(20, 5) = NULL,
	@pFirst numeric(20, 5) = NULL,
	@pMiddle numeric(20, 5) = NULL,
	@pLast numeric(20, 5) = NULL,
	@pResult varchar(50) = NULL,
	@pRemark nvarchar(max) = NULL,
	@pCreateDateTime datetime = NULL,
	@pCreateUserId varchar(50) = NULL,
	@pChangeDateTime datetime = NULL,
	@pChangeUserId varchar(50) = NULL,
	@pLotNo varchar(20) = NULL,
	@pFromDate datetime = NULL,
	@pToDate datetime = NULL,
	@pisUID varchar(20)=NULL
AS
BEGIN
	DECLARE @LotNonew6 VARCHAR(20) = ''
END
