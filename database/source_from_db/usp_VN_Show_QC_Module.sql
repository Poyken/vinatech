CREATE PROC [dbo].[usp_VN_Show_QC_Module]
@pSize NVARCHAR(20) = NULL,
@pFdate DATETIME = NULL,
@pTdate DATETIME = NULL,
@pBarcode NVARCHAR(50) = NULL,
@pType NVARCHAR(20) = NULL
AS
BEGIN
	
		DECLARE @Bar NVARCHAR(50) = @pBarcode
		DECLARE @Size NVARCHAR(20) = @pSize
		DECLARE @Type NVARCHAR(20) = @pType
		DECLARE @Froms DATETIME = @pFdate
		DECLARE @Tos DATETIME = @pTdate

		--IF @Bar IS NOT NULL
		--BEGIN
			 SELECT
		      CONVERT(DATE,T1.DATEBASIC) AS DATEBASIC,
			  T1.LOTNO,
			  T1.PARTNO,
			  T1.Size,
			  T1.Voltage,
			  T1.Farad,
			  T1.LotQty,
			  T1.STATUSPSS,
			  T1.Person,
			  T2.NAMETYPE,
			  T2.NUMBERID,
			  CASE
					WHEN NAMETYPE = 'ESR' AND VALUESCHECK IS NOT NULL THEN CAST(VALUESCHECK AS FLOAT) 
					WHEN NAMETYPE = 'SD' AND VALUESCHECK IS NOT NULL THEN CAST(VALUESCHECK AS FLOAT) 
					WHEN NAMETYPE = 'Dien Dung' AND VALUESCHECK IS NOT NULL THEN CAST(VALUESCHECK AS FLOAT) 
			  ELSE ''

			  END AS Categories,
			  T1.CreateUserID,
			  CONVERT(DATE,T1.CreateDateTime) AS CreateDateTime,
			  RIGHT(T1.CreateDateTime,8) AS TimeIn,
			  PersonCheck
			  
		FROM 
			STB_QC_LOTNO_MODULE T1 WITH(NOLOCK)
			LEFT OUTER JOIN STB_QC_LOTNO_MODULE_VALUES T2 ON T1.LOTNO = T2.LOTNO
		WHERE 1=1
		 and (Size = @Size or @Size ='' or @Size is null)
		 and (DATEBASIC BETWEEN @Froms AND @Tos) 
		 and (T1.LOTNO =@Bar or @Bar is null or @Bar ='')
		 and (NAMETYPE =@Type or @Type is null or @Type ='')
		--END

	 --   SELECT
		--      CONVERT(DATE,T1.DATEBASIC) AS DATEBASIC,
		--	  T1.LOTNO,
		--	  T1.PARTNO,
		--	  T1.Size,
		--	  T1.Voltage,
		--	  T1.Farad,
		--	  T1.LotQty,
		--	  T1.STATUSPSS,
		--	  T1.Person,
		--	  T2.NAMETYPE,
		--	  T2.NUMBERID,
		--	  CASE
		--			WHEN NAMETYPE = 'ESR' AND VALUESCHECK IS NOT NULL THEN CAST(VALUESCHECK AS FLOAT) 
		--			WHEN NAMETYPE = 'SD' AND VALUESCHECK IS NOT NULL THEN CAST(VALUESCHECK AS FLOAT) 
		--			WHEN NAMETYPE = 'Dien Dung' AND VALUESCHECK IS NOT NULL THEN CAST(VALUESCHECK AS FLOAT) 
		--	  ELSE ''

		--	  END AS Categories,
		--	  T1.CreateUserID,
		--	  CONVERT(DATE,T1.CreateDateTime) AS CreateDateTime,
		--	  RIGHT(T1.CreateDateTime,8) AS TimeIn
			  
		--FROM
		
		--	STB_QC_LOTNO_MODULE T1

		--	LEFT OUTER JOIN STB_QC_LOTNO_MODULE_VALUES T2 ON T1.LOTNO = T2.LOTNO

		--WHERE 1 = 1

		--	AND T1.LOTNO = @Bar
		--	AND T1.DATEBASIC BETWEEN @Froms AND @Tos
		--	AND T2.NAMETYPE = @Type
		--	AND T1.Size = @Size

		--ORDER BY T2.NUMBERID,T2.NAMETYPE
			
END
	--select * from STB_QC_LOTNO_MODULE