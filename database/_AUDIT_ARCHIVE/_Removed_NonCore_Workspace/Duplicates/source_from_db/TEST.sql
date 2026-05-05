create PROC [dbo].[TEST] -- exec usp_vn_showproductionerror 'MÁY CUỘN THỦ CÔNG CỠ TRUNG_WI','','','','Báo phế','','2020-06-20','2020-06-20'
	@pFromdate DATE = NULL,
	@pToDate DATE = NULL,
	@pLine VARCHAR(100) = NULL,
	@pModel VARCHAR(100) = NULL
--WITH encryption
--WITH RECOMPILE	
AS
BEGIN

	SET NOCOUNT ON;

		DECLARE @Line VARCHAR(100) = CASE WHEN ISNULL(@pLine,'') = '' THEN '%' ELSE @pLine END,
				@Model VARCHAR(100)= CASE WHEN ISNULL (@pModel, '') = '' THEN '%' ELSE @pModel END
		DECLARE @FromDate DATE = @pFromdate
		DECLARE @ToDate DATE = @pToDate
				
		CREATE TABLE #Tbl1
		(
			Line NVARCHAR(100)  NULL,
			Model NVARCHAR(100) NULL,
		    Item  NVARCHAR(100) NULL,
			NG NVARCHAR(100) NULL,
			Weights NVARCHAR(100) NULL,
			StatusError NVARCHAR(100) NULL,
			NameShift NVARCHAR(100) NULL,
			Dates NVARCHAR(50) NULL,
			Times NVARCHAR(50) NULL,
			CreateUserID NVARCHAR(50) NULL, 
			IDPE INT NOT NULL PRIMARY KEY(IDPE)
		)

		INSERT INTO #Tbl1 (Line,Model,Item,NG,Weights,UNIT,StatusError,NameShift,Dates,Times,CreateUserID,IDPE) 

				SELECT 
					 VNSHOW.Line,
					 VNSHOW.Model,
					 VNSHOW.Item,
					 VNSHOW.NG,
					 VNSHOW.Weights,
					 UNIT,
					 VNSHOW.StatusError,
					 VNSHOW.NameShift,
					 CONVERT(DATE,VNSHOW.InputDate) AS Dates,
					 RIGHT(VNSHOW.CreateDateTime,8) AS Times,
					 CreateUserID,
					 VNSHOW.IDPE
					
				FROM
					STB_VN_PRODUCTION_ERROR VNSHOW WITH(NOLOCK)
				
				WHERE  
						Flag='False' 

			SELECT
					Line,
				    Item,
					NG,
					Weights,
				    UNIT,
					StatusError,
					NameShift,
					CONVERT(DATE,Dates) AS Dates,
					Times,
					CreateUserID,
					IDPE,
					Model,
					(
						CASE Model
							WHEN    N'0813'  THEN CONVERT(FLOAT,Weights) / 0.354 
							WHEN    N'0813'  THEN CONVERT(FLOAT,Weights) / 0.58 
							WHEN    N'0813'  THEN CONVERT(FLOAT,Weights) / 1.003
							ELSE 'Dont understand'
					END) AS Result

			FROM 
				#Tbl1


				---AND Item  N'BÁN THÀNH PHẨM CHƯA LẮP CAO SU (권취 소자)'
				--- AND Item  N'BÁN THÀNH PHẨM ĐÃ LẮP CAO SU, CHƯA LẮP VỎ NHÔM'
				--- AND Item  N'BÁN THÀNH PHẨM ĐÃ LẮP VỎ NHÔM, TỪ SAU CÔNG ĐOẠN BEADING (소자 - 비딩 후)'

			--WHERE 
				
			--		(
			--				((@FromDate IS NULL) OR CONVERT(DATE,Dates) >= @FromDate)
			--			AND
			--				((@ToDate IS NULL) OR CONVERT(DATE,Dates) <= @ToDate)
			--		)

			--		AND 
			--				(Model LIKE @Model)


					
END


--select * from STB_VN_PRODUCTION_ERROR