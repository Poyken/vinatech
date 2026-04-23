CREATE PROC [dbo].[usp_VN_Eletrode_Show]
	@pFromDate date=null,
	@pToDate date=null,
	@pLine nvarchar(50)=null
AS
BEGIN
		DECLARE @GROUPID NVARCHAR(50) = 'VNE'
		DECLARE @PUBLICCODE NVARCHAR(50)
		DECLARE @Srt INT

						SELECT 
								@Srt = ISNULL(MAX(ID),0) + 1
						FROM 
								STB_VN_ELECTRODE_REQUESTFORM WITH(NOLOCK)

		SET @PUBLICCODE = @GROUPID + CONVERT(VARCHAR(10),@Srt)

		SELECT
				--GROUPID = @PUBLICCODE,
				ID,
				convert(varchar, DateOutPut, 120) as DateOutPut, 
				Materialcode,
				MaterialName,
				ElectrodeThick,
				SlittingWidth,
				GoodQtyLength,
				ActuallyQtyRequest,
				Line,
				Description
		FROM 
				STB_VN_ELECTRODE_REQUESTFORM WITH(NOLOCK)
		WHERE
				(@pLine is null or @pLine='' or Line =@pLine)
				and(DateOutPut between @pFromDate and @pToDate)
END


