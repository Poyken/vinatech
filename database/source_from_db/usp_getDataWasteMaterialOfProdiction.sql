-- =============================================
-- Author:		Mr.Duy
-- Create date: 2025-02-20
-- Description:	Lấy dữ liệu phế của nhà máy
-- =============================================
CREATE PROCEDURE [dbo].[usp_getDataWasteMaterialOfProdiction]
	@pFromdate DATE = NULL,
	@pToDate DATE = NULL,
	@pLine VARCHAR(100) = NULL,
	@pModel VARCHAR(100) = NULL,
	@pWorkCenterCode VARCHAR(100) = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
		DECLARE @Line VARCHAR(100) = CASE WHEN ISNULL(@pLine,'') = '' THEN '*' ELSE @pLine END
		DECLARE	@Model VARCHAR(100)= CASE WHEN ISNULL (@pModel, '') = '' THEN '*' ELSE @pModel END
		DECLARE @FromDate DATEtime = convert(varchar(10),isnull(@pFromdate,dateadd(month,-3,getdate()) ),120) + ' 10:00:00'
		DECLARE @ToDate DATEtime =  convert(varchar(10),dateadd(day,1,isnull(@pToDate,getdate() )),120) + ' 10:00:00'
		DECLARE @WorkCenterCode VARCHAR(20) = CASE WHEN ISNULL(@pWorkCenterCode,'') = '' THEN '*' ELSE @pWorkCenterCode END
		declare @psagemcom varchar(10) = isnull('sagemcom','')
		,@LabelType varchar(50)='BoxLabel'

	/* CREATE TABLE #Temp
		(
			Model NVARCHAR(100) NULL,
		    Item  NVARCHAR(100) NULL,
			NG NVARCHAR(100) NULL,
			Weights FLOAT NULL,
			StatusError NVARCHAR(100) NULL,
			NameShift NVARCHAR(100) NULL,
			Dates NVARCHAR(50) NULL,
			Times NVARCHAR(50) NULL,
			CreateUserID NVARCHAR(50) NULL, 
			IDPE INT NOT NULL PRIMARY KEY(IDPE),
			UNIT NVARCHAR(20) NULL,
			LINENAME NVARCHAR(50) NULL,
			createdatetime datetime,
			MaLotCapThu VARCHAR(50) NULL,
			MaLotNguyenLieu VARCHAR(50) NULL,
			WorkCenterCode NVARCHAR(50) NULL
		)
	INSERT INTO #Tbl1 (Model,Item,NG,Weights,UNIT,StatusError,NameShift,Dates,Times,CreateUserID,IDPE,LINENAME,createdatetime, MaLotCapThu, MaLotNguyenLieu,WorkCenterCode) 
	*/			;WITH LabelInfo AS
						(
						SELECT
						RANK() OVER (PARTITION BY LI.LabelType,LI.FormatName ORDER BY LI.FormatVersion DESC) AS RankIndex,
						LI.LabelType,
						LI.FormatName,
						LI.CommandType,
						LI.Dpi,
						LI.PrinterName
						FROM
								SmartFramework.dbo.STB_LabelInfo LI WITH(NOLOCK)
						WHERE
								LI.IsApproval = 1 AND
								LI.ApplyDate <= GETDATE()
				
						)

				SELECT 
					 IDPE,
					 MM.MaterialName as Model,
					 Item as Item,
					 TW.NameTypeWaste,
					 VNSHOW.LotNo,
					 VNSHOW.NG,
					 VNSHOW.Weights,
					 (VNSHOW.Weights*UC.ConvertRate) AS WeightsConvert,
					 'Gram' as UNITDEFAUT,
					 MM.MaterialUnit as UNIT,
					 VNSHOW.StatusError,
					 VNSHOW.NameShift,
					 VNSHOW.Decs,
					 VNSHOW.CreateDateTime AS Dates,
					 --RIGHT(VNSHOW.CreateDateTime,8) AS Times,
					 FORMAT(VNSHOW.CreateDateTime, 'HH:mm:ss') AS Times,
							 (case  when   (DATEPART(HOUR, VNSHOW.createdatetime)>10)   or  (DATEPART(HOUR, VNSHOW.createdatetime)=10 and DATEPART(MINUTE, VNSHOW.createdatetime)>30)     
						then     convert(varchar(10),VNSHOW.createdatetime,120)    
						else    convert(varchar(10),DATEADD(DAY, -1,  VNSHOW.createdatetime),120)       
						end 
					)    
				  as  JobDate,
					VNSHOW.CreateUserID,
					VNSHOW.LINENAME,
					VNSHOW.createdatetime,
					VNSHOW.MaLotCapThu,
					VNSHOW.MaLotNguyenLieu,
					VNSHOW.WorkCenterCode,
					VNSHOW.MachineCode,
					--CAST((MCAPW.PRICES*VNSHOW.Weights) AS DECIMAL(18,10))  as   PRICES,
					CAST((MCAPW.PRICES*(VNSHOW.Weights*UC.ConvertRate)) AS DECIMAL(18,10))  as   PRICES,
					 isnull(LI.LabelType,'BoxLabel')  + (case when @psagemcom<>'' then 'VVT' else '' end)  as LabelType,
					 '포장라벨NewVietNam_HN_Phe' as FormatName,
					isnull(LI.CommandType,'Report')  as CommandType,
					isnull(LI.Dpi,'200')  as Dpi,
					isnull(LI.PrinterName,'') PrinterName,
					CodeInputWarehouse
				FROM
					STB_VN_PRODUCTION_ERROR VNSHOW WITH(NOLOCK)
					LEFT OUTER JOIN STB_TypeWaste TW WITH(NOLOCK)  ON VNSHOW.Item = TW.ID
					LEFT OUTER JOIN STB_MaterialCodeAndPriceWWaste MCAPW WITH(NOLOCK) ON VNSHOW.MaLotNguyenLieu = MCAPW.MaterialCode
					LEFT OUTER JOIN STB_MaterialMaster MM WITH(NOLOCK) ON VNSHOW.MaLotNguyenLieu = MM.MaterialCode
					LEFT OUTER JOIN STB_ModelLabelInfo MLBI WITH(NOLOCK)	ON MLBI.ModelCode = VNSHOW.MaLotNguyenLieu AND MLBI.LabelType = @LabelType
					LEFT OUTER JOIN LabelInfo LI	 WITH(NOLOCK) 			                            ON LI.LabelType = MLBI.LabelType          AND LI.FormatName = MLBI.FormatName  AND	LI.RankIndex = 1
					LEFT OUTER JOIN STB_UnitConversion UC WITH(NOLOCK) ON VNSHOW.MaLotNguyenLieu = UC.MaterialCode
					
					where 
					1=1 
					AND Flag=0
					AND CONVERT(DATE,VNSHOW.createdatetime) >= @FromDate
					AND CONVERT(DATE,VNSHOW.createdatetime) <= @ToDate
					AND VNSHOW.WorkCenterCode = @pWorkCenterCode
					AND VNSHOW.StatusError=N'Báo phế'

END

--select * from STB_VN_PRODUCTION_ERROR where CreateUserID='anhduy157'
	