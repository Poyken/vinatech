-- =============================================
-- Author:		DinhManh
-- Create date: 2025-04-11
-- Description:	Show tmp finish good for QC Audit
-- =============================================
CREATE PROCEDURE [dbo].[usp_VN_WaitingCheckBeforeExport_forQCAudit_get]
	-- Add the parameters for the stored procedure here
	@pFromDate DATE = NULL,
	@pToDate DATE = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	DECLARE @FromDate DATE = @pFromDate
	DECLARE @ToDate DATE = @pToDate


	SELECT
				T1.ID,
				IDCODE,
				Country,
			    PackingID,
				LotNo,
				T1.MaterialCode,
				MaterialName,
				ProductionSize,
				PackQty,
				EmpNo,
				CreatDatePacked AS PackedDate,
				RIGHT(CreatDatePacked,8) AS TimePacked,
				'' + replace(PartNo, ' ', '') + '' AS PartNo,
				TypeProduction,
				StatusSystem,
				CreateDate,
				RIGHT(CreateDate,8) AS TimeIn,
				USERID AS PersonIn,
				Descrption,
				INPUTFROM
				  ,LOCATIONS
				  ,TYPEEXPORT
	,(select count(*) from dbo.fn_VVT_PartnoModel()   where partno=T1.partno and modelname=T1.MaterialName) as CheckPartno
	--,case when DATEDIFF(day,isnull(si.InputJobDate,getdate()-366),getdate()) > 365 then 1 else 0 end BackLog_Inventory
	, FGLocation
	, StatusCheck

		FROM
				STB_VN_FINISHGOODS_forQCAudit T1 WITH(NOLOCK)
				--left outer join STB_SetInfo si WITH(NOLOCK) on t1.LotNo=si.Barcode
	    WHERE 
			Flag = 1
			AND FGLocation LIKE N'Bắc Giang'
			AND (StatusCheck IS NULL  OR StatusCheck LIKE 'Reject')
			AND 
			(
					((@FromDate IS NULL) OR CONVERT(DATE,CreateDate) >= @FromDate)
				AND
					((@ToDate IS NULL) OR CONVERT(DATE,CreateDate) <= @ToDate)
			)
			
		order by CreateDate desc
			
END
