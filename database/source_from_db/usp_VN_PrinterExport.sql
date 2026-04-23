CREATE proc [dbo].[usp_VN_PrinterExport]  -- exec '2021-05-01','2021-05-08',N'Xuất',''
@pFrdate DATE = NULL,
@pTodate DATE = NULL,
@pSoPhieuXuatKho NVARCHAR(50) = NULL
--@pGROUPID NVARCHAR(50) = NULL
AS
BEGIN

		DECLARE @FromDate DATE = @pFrdate
		DECLARE @ToDate DATE = @pTodate
		--DECLARE @INPUT  NVARCHAR(20) = @pTypeInput
		--DECLARE @GROUPID NVARCHAR(50) = @pGROUPID
		DECLARE @Year NVARCHAR(10)
		DECLARE @Moth  NVARCHAR(10)
		DECLARE @Days NVARCHAR(10)
		SET @Year= YEAR(GETDATE())
		SET @Moth = MONTH(GETDATE())
		SET @Days = DAY(GETDATE())

		--SELECT * FROM STB_VN_FINISHGOODS

		SELECT

				'' + replace(PublicCode, ' ', '') + '' AS PublicCode, 
				'' + replace(PartNo, ' ', '') + '' AS PartNo,
				SUM(PackQty) AS PackQty,
				Statusout,
				CONVERT(DATE,DateExport) AS Datee,
				SoPhieuXuatKho,
				'PCS'AS UNIT,
				@Year AS Years,
				@Moth AS Months,
				@Days AS Dayx

		FROM 
				STB_VN_FINISHGOODS WITH(NOLOCK)
		WHERE   

			    CONVERT(DATE,DATEEXPORT) BETWEEN @FromDate AND @ToDate AND Statusout IS NOT NULL AND Flag = 1 AND SoPhieuXuatKho = @pSoPhieuXuatKho
			 
				GROUP BY PublicCode,PartNo,Statusout,SoPhieuXuatKho,CONVERT(DATE,DateExport)
				ORDER BY SUM(PackQty)
END

--select * from STB_VN_FINISHGOODS

--SELECT * FROM STB_VN_IssueReceipt
-- delete STB_VN_IssueReceipt
--WHERE   
--				CONVERT(DATE,CreateDate) BETWEEN @FromDate AND @ToDate AND
--				--(
--				--	((@FromDate IS NULL) OR CONVERT(DATE,CreateDate) >= @FromDate)
--				--AND
--				--	((@ToDate IS NULL) OR CONVERT(DATE,CreateDate) <= @ToDate)
--				--)
--				--AND
--			    StatusSystem = N'Nhập' AND StatusSystem IS NOT NULL 
--				AND Flag = 1 AND SoPhieuNhapKho = @pSoPhieuNhapKho


