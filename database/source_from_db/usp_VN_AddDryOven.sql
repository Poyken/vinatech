CREATE PROC [dbo].[usp_VN_AddDryOven]
@pBarCode VARCHAR(100) = NULL
AS
BEGIN
	SET NOCOUNT ON;

		DECLARE @Barcode VARCHAR(100) = CASE WHEN ISNULL(@pBarCode,'') = '' THEN '%' ELSE @pBarCode END
		
		
			SELECT
					MaterialCode,
				    MaterialName,
					BarCode,
				    DryMachines,
				    Qty,
					StatusIn,
					CONVERT(DATE,OvenInputDate) AS DateIn,
					RIGHT(OvenInputDate,8) AS TimeIn,
					StatusOut,
					CONVERT(DATE,OvenOutDate) AS DateOut,
					RIGHT(OvenOutDate,8) AS TimeOuts,
					TotalMinutes,
					TotalHouse,

						CASE 

							WHEN   TotalHouse = 12  THEN N'Đảm bảo tiêu chuẩn sấy'
							WHEN   TotalHouse > 12  THEN  N'Thời gian sấy vượt qua tiêu chuẩn'
							WHEN   TotalHouse < 12  THEN N'Thời gian không nhỏ hơn tiêu chuẩn sấy'
							
							ELSE N'Chưa dõ tiêu chuẩn'

					END AS Result 
				

		  FROM
					STB_VN_DRYOVER WITH(NOLOCK)

		 WHERE 
				
							(BarCode LIKE @Barcode)

			
END