CREATE PROC [dbo].[usp_VN_PrinterImport] -- exec usp_VN_PrinterImport '2023-05-09','2023-05-10','0003863'
@pFrdate DATE = NULL,
@pTodate DATE = NULL,
@pSoPhieuNhapKho NVARCHAR(50) = NULL
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
	
	-- SELECT * FROM STB_VN_FINISHGOODS

	BEGIN
		SELECT
		--ROW_NUMBER() OVER (PARTITION BY StatusSystem ORDER BY StatusSystem) AS [ID],
			'' + replace(PublicCode, ' ', '') + '' AS PublicCode, 
			'' + replace(PartNo, ' ', '') + '' AS PartNo,
			  SUM(PackQty) AS PackQty,
				CONVERT(DATE,CreateDate) as Dates, 
				StatusSystem,
				SoPhieuNhapKho,
				'PCS' AS UNIT,
				@Year AS Years,
				@Moth AS Months,
				@Days AS Dayx

		FROM 
				STB_VN_FINISHGOODS WITH(NOLOCK) --STB_VN_IssueReceipt 
		WHERE   
				CONVERT(DATE,CreateDate) BETWEEN @FromDate AND @ToDate AND
				--(
				--	((@FromDate IS NULL) OR CONVERT(DATE,CreateDate) >= @FromDate)
				--AND
				--	((@ToDate IS NULL) OR CONVERT(DATE,CreateDate) <= @ToDate)
				--)
				--AND
			    StatusSystem = N'Nhập' AND StatusSystem IS NOT NULL 
				AND Flag = 1 AND SoPhieuNhapKho = @pSoPhieuNhapKho

				GROUP BY PublicCode,PartNo,StatusSystem,CONVERT(DATE,CreateDate),SoPhieuNhapKho

				ORDER BY SUM(PackQty)
	END
	
END

-- SELECT * FROM  STB_VN_IssueReceipt