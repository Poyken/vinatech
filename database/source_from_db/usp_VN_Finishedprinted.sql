CREATE PROC usp_VN_Finishedprinted  -- exec usp_VN_Finishedprinted '2021-05-01','2021-05-08',N'Xuất'
@pFdate DATE = NULL,
@pToDate DATE = NULL,
@pInput NVARCHAR(20) = NULL
AS
BEGIN
		DECLARE @FromDate DATE = @pFdate
		DECLARE @ToDate DATE = @pToDate
		DECLARE @Input NVARCHAR(50) = @pInput


		IF @Input = N'Nhập' AND @Input <> N'Xuất'

			BEGIN

				SELECT
			'' + replace(PublicCode, ' ', '') + '' AS PublicCode, 
			'' + replace(PartNo, ' ', '') + '' AS PartNo,
			SUM(PackQty) AS PackQty,
			CONVERT(DATE,CreateDate) as Dates, 
			StatusSystem,
			SoPhieuNhapKho,
			'PCS' AS UNIT

		FROM  STB_VN_FINISHGOODS WITH(NOLOCK)

				WHERE  
				(
					((@FromDate IS NULL) OR CONVERT(DATE,CreateDate) >= @FromDate)
				AND
					((@ToDate IS NULL) OR CONVERT(DATE,CreateDate) <= @ToDate)
				)
				AND
			    StatusSystem = @INPUT AND StatusSystem IS NOT NULL 
				AND Flag = 1

				GROUP BY PublicCode,PartNo,StatusSystem,CONVERT(DATE,CreateDate),SoPhieuNhapKho

			END

			ELSE 
				BEGIN
				
					SELECT
			'' + replace(PublicCode, ' ', '') + '' AS PublicCode, 
			'' + replace(PartNo, ' ', '') + '' AS PartNo,
			SUM(PackQty) AS PackQty,
			CONVERT(DATE,CreateDate) as Dates, 
			StatusSystem,
			SoPhieuNhapKho,
			'PCS' AS UNIT

		FROM  STB_VN_FINISHGOODS WITH(NOLOCK)

				WHERE  
				(
					((@FromDate IS NULL) OR CONVERT(DATE,CreateDate) >= @FromDate)
				AND
					((@ToDate IS NULL) OR CONVERT(DATE,CreateDate) <= @ToDate)
				)
				AND
			    StatusSystem = @INPUT AND StatusSystem IS NOT NULL 
				AND Flag = 1

				GROUP BY PublicCode,PartNo,StatusSystem,CONVERT(DATE,CreateDate),SoPhieuNhapKho

				END
		
  IF @Input = N'Xuất' AND  @Input <> N'Nhập'

			BEGIN
					SELECT

				'' + replace(PublicCode, ' ', '') + '' AS PublicCode, 
				'' + replace(PartNo, ' ', '') + '' AS PartNo,
				SUM(PackQty) AS PackQty,
				Statusout,
				CONVERT(DATE,DateExport) AS Datee,
				SoPhieuXuatKho,
				'PCS'AS UNIT

		FROM 
				STB_VN_FINISHGOODS WITH(NOLOCK)
		WHERE   
				(
					((@FromDate IS NULL) OR CONVERT(DATE,DATEEXPORT) >= @FromDate)
				AND
					((@ToDate IS NULL) OR CONVERT(DATE,DATEEXPORT) <= @ToDate)
				)
				AND
			    Statusout = @INPUT  AND Statusout IS NOT NULL AND Flag = 1

				GROUP BY PublicCode,PartNo,Statusout,SoPhieuXuatKho,CONVERT(DATE,DateExport)
			END
	ELSE
		BEGIN
					SELECT

				'' + replace(PublicCode, ' ', '') + '' AS PublicCode, 
				'' + replace(PartNo, ' ', '') + '' AS PartNo,
				SUM(PackQty) AS PackQty,
				Statusout,
				CONVERT(DATE,DateExport) AS Datee,
				SoPhieuXuatKho,
				'PCS'AS UNIT

		FROM 
				STB_VN_FINISHGOODS WITH(NOLOCK)
		WHERE   
				(
					((@FromDate IS NULL) OR CONVERT(DATE,DATEEXPORT) >= @FromDate)
				AND
					((@ToDate IS NULL) OR CONVERT(DATE,DATEEXPORT) <= @ToDate)
				)
				AND
			    Statusout = @INPUT  AND Statusout IS NOT NULL AND Flag = 1

				GROUP BY PublicCode,PartNo,Statusout,SoPhieuXuatKho,CONVERT(DATE,DateExport)
		END
END