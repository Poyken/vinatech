CREATE PROC [dbo].[usp_VN_TappingBennding]
@pFromDate DATE = NULL,
@pTodate  DATE = NULL
AS
BEGIN
		DECLARE @FromDate DATE = @pFromDate
		DECLARE @Todate DATE = @pTodate

IF @FromDate IS NOT NULL AND @Todate IS NOT NULL

BEGIN

	select * from 
	(  SELECT
		ISNULL(LOTNO, 'Total') AS LotNo,
		'ZSubTotal' NAMEERROR,
		SUM(QTYERROR) as QTYERROR,
		SUM(QTYLOTNO) AS QTYLOTNO,
		'' CODEPRODUCTION,
		'' TYPESS,
		'' MachineName,
		'' CreateUserID,
		'' Dates,
		'' Times
		
	FROM	
		STB_VN_BENDING_TAPPING WITH(NOLOCK)
	WHERE
		CONVERT(DATE,CreateDateTime) BETWEEN @FromDate AND @Todate
		GROUP BY LotNo,TYPESS
	UNION ALL
	SELECT
		LOTNO,
		NAMEERROR,
		QTYERROR,
		QTYLOTNO,
		CODEPRODUCTION,
		TYPESS,
		MachineName,
		CreateUserID,
		CONVERT(VARCHAR(10),CreateDateTime,101)  as dates,
		RIGHT(CreateDateTime,8) AS Times
		
	FROM	
		STB_VN_BENDING_TAPPING WITH(NOLOCK)
	WHERE
		CONVERT(DATE,CreateDateTime) BETWEEN @FromDate AND @Todate) a1
	UNION ALL 
	select 'ZSUBTOTAL' lotno, 
		   'ZSUBTOTAL' nameerror, 
		   sum(qtyerror) as qtyerror, 
		   sum(qtylotno) ,
		   null CODEPRODUCTION,
		   NULL	TYPESS,
		   NULL MachineName,
		   NULL CreateUserID, 
		   NULL dates,
		   NULL Times
		  
	FROM	
			STB_VN_BENDING_TAPPING WITH(NOLOCK)
	WHERE
		CONVERT(DATE,CreateDateTime) BETWEEN @FromDate AND @Todate
		GROUP BY LotNo
		ORDER BY A1.LotNo,NAMEERROR
 END
 ELSE
	BEGIN
					select * from 
		(  SELECT
				ISNULL(LOTNO, 'Total') AS LotNo,
				'ZSubTotal' NAMEERROR,
				SUM(QTYERROR) as QTYERROR,
				SUM(QTYLOTNO) AS QTYLOTNO,
				'' CODEPRODUCTION,
				'' TYPESS,
				'' MachineName,
				'' CreateUserID,
				'' Dates,
				'' Times
				
		FROM	
			STB_VN_BENDING_TAPPING WITH(NOLOCK)
			GROUP BY LotNo
		UNION ALL
		SELECT
			LOTNO,
			NAMEERROR,
			QTYERROR,
			QTYLOTNO,
			CODEPRODUCTION,
			TYPESS,
			MachineName,
			CreateUserID,
			CONVERT(VARCHAR(10),CreateDateTime,101)  as dates,
			RIGHT(CreateDateTime,8) AS Times
			
		FROM	
			STB_VN_BENDING_TAPPING WITH(NOLOCK) ) a1

	UNION ALL 
	select 'ZSUBTOTAL' lotno, 
		   'ZSUBTOTAL' nameerror, 
		   sum(qtyerror) as qtyerror, 
		   sum(qtylotno) ,
		   NULL CODEPRODUCTION,
		   NULL TYPESS,
		   NULL MachineName,
		   NULL CreateUserID, 
		   NULL dates,
		   NULL Times
		   
	FROM	
			STB_VN_BENDING_TAPPING WITH(NOLOCK)
			--GROUP BY LotNo
			ORDER BY A1.LotNo,NAMEERROR
	END
END			


-- select * from STB_VN_BENDING_TAPPING