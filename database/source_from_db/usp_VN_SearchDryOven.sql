CREATE PROC [dbo].[usp_VN_SearchDryOven]
@pFromdate DATE = NULL,
@pToDate DATE = NULL,
@pBarCode VARCHAR(100) = NULL
AS
BEGIN
	SET NOCOUNT ON;

		DECLARE @Barcode VARCHAR(100) = CASE WHEN ISNULL(@pBarCode,'') = '' THEN '%' ELSE @pBarCode END
	DECLARE @FromDate   VARCHAR(19) = CONVERT(VARCHAR(10), @pFromDate, 120) + ' 10:00:00'                                                            -- SELECT  CONVERT(VARCHAR(10), '2019-09-16', 121) + ' 08:30:00' 
	DECLARE @ToDate      VARCHAR(19) = CONVERT(VARCHAR(10), DATEADD(DAY, 1, CONVERT(smalldatetime, @pToDate)), 120) + ' 10:00:00'  
		
			SELECT
					MaterialCode,
				    MaterialName,
					BarCode,
				    DryMachines,
				    Qty,
					StatusIn,
					dateadd(day,1,CONVERT(DATE,OvenInputDate)) AS DateIn,--lệch 1 ngày, sửa ngày 4.4.2023 yêu cầu của chị Kiều Nguyệt Nga
					RIGHT(OvenInputDate,8) AS TimeIn,
					StatusOut,
					dateadd(day,1,CONVERT(DATE,OvenOutDate)) AS DateOut,--lệch 1 ngày, sửa ngày 4.4.2023 yêu cầu của chị Kiều Nguyệt Nga
					RIGHT(OvenOutDate,8) AS TimeOuts,
					TotalMinutes,
					TotalHouse,
					 Pressure, 
                         DryTemperature, 
						 OutTemperature,

						CASE 

							WHEN   TotalHouse = 12  THEN N'Đảm bảo tiêu chuẩn sấy'
							WHEN   TotalHouse > 12  THEN  N'Thời gian sấy vượt qua tiêu chuẩn'
							WHEN   TotalHouse < 12  THEN N'Thời gian không nhỏ hơn tiêu chuẩn sấy'
							
							ELSE N'Chưa dõ tiêu chuẩn'

					END AS Result 
				

		 FROM
					STB_VN_DRYOVER WITH(NOLOCK)

		 WHERE 
					(
							((@FromDate IS NULL) OR CONVERT(datetime,CreateDateTime) >= @FromDate)
						AND
							((@ToDate IS NULL) OR CONVERT(datetime,CreateDateTime) <= @ToDate)
					)

					AND 
							(BarCode LIKE @Barcode)

			
END

-- SELECT * FROM STB_VN_DRYOVER
-- EXEC usp_VN_SearchDryOven '',''