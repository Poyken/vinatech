CREATE PROC [dbo].[vn_TEST] -- exec [vn_TEST] '2020-06-01','2020-06-30',N'',''
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
			Weights FLOAT NULL,
			StatusError NVARCHAR(100) NULL,
			NameShift NVARCHAR(100) NULL,
			Dates NVARCHAR(50) NULL,
			Times NVARCHAR(50) NULL,
			CreateUserID NVARCHAR(50) NULL, 
			IDPE INT NOT NULL PRIMARY KEY(IDPE),
			UNIT NVARCHAR(20) NULL
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
					
						CASE 

							WHEN    Model = N'0813' AND Item = N'BÁN THÀNH PHẨM CHƯA LẮP CAO SU (권취 소자)'  THEN CAST(Weights AS FLOAT)/0.354
							WHEN    Model = N'0813' AND Item =  N'BÁN THÀNH PHẨM ĐÃ LẮP CAO SU, CHƯA LẮP VỎ NHÔM' THEN  CAST(Weights AS FLOAT)/0.58
							WHEN    Model = N'0813' AND Item = N'BÁN THÀNH PHẨM ĐÃ LẮP VỎ NHÔM, TỪ SAU CÔNG ĐOẠN BEADING (소자 - 비딩 후)' THEN CAST(Weights AS FLOAT)/1.003



							WHEN    Model = N'0820-CY' AND Item = N'BÁN THÀNH PHẨM CHƯA LẮP CAO SU (권취 소자)'  THEN CAST(Weights AS FLOAT)/0.569
							WHEN	Model = N'0820-CY' AND Item =  N'BÁN THÀNH PHẨM ĐÃ LẮP CAO SU, CHƯA LẮP VỎ NHÔM' THEN  CAST(Weights AS FLOAT)/0.801
							WHEN    Model = N'0820-CY' AND Item = N'BÁN THÀNH PHẨM ĐÃ LẮP VỎ NHÔM, TỪ SAU CÔNG ĐOẠN BEADING (소자 - 비딩 후)' THEN CAST(Weights AS FLOAT)/1.45



							WHEN    Model = N'0820-MSP' AND Item = N'BÁN THÀNH PHẨM CHƯA LẮP CAO SU (권취 소자)'  THEN CAST(Weights AS FLOAT)/0.569
							WHEN	Model = N'0820-MSP' AND Item =  N'BÁN THÀNH PHẨM ĐÃ LẮP CAO SU, CHƯA LẮP VỎ NHÔM' THEN  CAST(Weights AS FLOAT)/0.801
							WHEN    Model = N'0820-MSP' AND Item = N'BÁN THÀNH PHẨM ĐÃ LẮP VỎ NHÔM, TỪ SAU CÔNG ĐOẠN BEADING (소자 - 비딩 후)' THEN CAST(Weights AS FLOAT)/1.45


						
							WHEN    Model = N'0825' AND Item = N'BÁN THÀNH PHẨM CHƯA LẮP CAO SU (권취 소자)'  THEN CAST(Weights AS FLOAT)/0.700
							WHEN	Model = N'0825' AND Item =  N'BÁN THÀNH PHẨM ĐÃ LẮP CAO SU, CHƯA LẮP VỎ NHÔM' THEN  CAST(Weights AS FLOAT)/0.920
							WHEN    Model = N'0825' AND Item = N'BÁN THÀNH PHẨM ĐÃ LẮP VỎ NHÔM, TỪ SAU CÔNG ĐOẠN BEADING (소자 - 비딩 후)' THEN CAST(Weights AS FLOAT)/2.404


							WHEN    Model = N'0830' AND Item = N'BÁN THÀNH PHẨM CHƯA LẮP CAO SU (권취 소자)'  THEN CAST(Weights AS FLOAT)/0.815
							WHEN	Model = N'0830' AND Item =  N'BÁN THÀNH PHẨM ĐÃ LẮP CAO SU, CHƯA LẮP VỎ NHÔM' THEN  CAST(Weights AS FLOAT)/1.056
							WHEN    Model = N'0830' AND Item = N'BÁN THÀNH PHẨM ĐÃ LẮP VỎ NHÔM, TỪ SAU CÔNG ĐOẠN BEADING (소자 - 비딩 후)' THEN CAST(Weights AS FLOAT)/2.073


							
							WHEN    Model = N'1020-5F' AND Item = N'BÁN THÀNH PHẨM CHƯA LẮP CAO SU (권취 소자)'  THEN CAST(Weights AS FLOAT)/0.703
							WHEN	Model = N'1020-5F' AND Item =  N'BÁN THÀNH PHẨM ĐÃ LẮP CAO SU, CHƯA LẮP VỎ NHÔM' THEN  CAST(Weights AS FLOAT)/1.105
							WHEN    Model = N'1020-5F' AND Item = N'BÁN THÀNH PHẨM ĐÃ LẮP VỎ NHÔM, TỪ SAU CÔNG ĐOẠN BEADING (소자 - 비딩 후)' THEN CAST(Weights AS FLOAT)/2.031



							WHEN    Model = N'1020-7F' AND Item = N'BÁN THÀNH PHẨM CHƯA LẮP CAO SU (권취 소자)'  THEN CAST(Weights AS FLOAT)/0.703
							WHEN	Model = N'1020-7F' AND Item =  N'BÁN THÀNH PHẨM ĐÃ LẮP CAO SU, CHƯA LẮP VỎ NHÔM' THEN  CAST(Weights AS FLOAT)/1.105
							WHEN    Model = N'1020-7F' AND Item = N'BÁN THÀNH PHẨM ĐÃ LẮP VỎ NHÔM, TỪ SAU CÔNG ĐOẠN BEADING (소자 - 비딩 후)' THEN CAST(Weights AS FLOAT)/2.031


							
							WHEN    Model = N'1025-7F' AND Item = N'BÁN THÀNH PHẨM CHƯA LẮP CAO SU (권취 소자)'  THEN CAST(Weights AS FLOAT)/0.860
							WHEN	Model = N'1025-7F' AND Item =  N'BÁN THÀNH PHẨM ĐÃ LẮP CAO SU, CHƯA LẮP VỎ NHÔM' THEN  CAST(Weights AS FLOAT)/1.260
							WHEN    Model = N'1025-7F' AND Item = N'BÁN THÀNH PHẨM ĐÃ LẮP VỎ NHÔM, TỪ SAU CÔNG ĐOẠN BEADING (소자 - 비딩 후)' THEN CAST(Weights AS FLOAT)/2.460


								
							WHEN    Model = N'1025-10F' AND Item = N'BÁN THÀNH PHẨM CHƯA LẮP CAO SU (권취 소자)'  THEN CAST(Weights AS FLOAT)/0.860
							WHEN	Model = N'1025-10F' AND Item =  N'BÁN THÀNH PHẨM ĐÃ LẮP CAO SU, CHƯA LẮP VỎ NHÔM' THEN  CAST(Weights AS FLOAT)/1.260
							WHEN    Model = N'1025-10F' AND Item = N'BÁN THÀNH PHẨM ĐÃ LẮP VỎ NHÔM, TỪ SAU CÔNG ĐOẠN BEADING (소자 - 비딩 후)' THEN CAST(Weights AS FLOAT)/2.460


							WHEN    Model = N'1030' AND Item = N'BÁN THÀNH PHẨM CHƯA LẮP CAO SU (권취 소자)'  THEN CAST(Weights AS FLOAT)/1.200
							WHEN	Model = N'1030' AND Item =  N'BÁN THÀNH PHẨM ĐÃ LẮP CAO SU, CHƯA LẮP VỎ NHÔM' THEN  CAST(Weights AS FLOAT)/1.600
							WHEN    Model = N'1030' AND Item = N'BÁN THÀNH PHẨM ĐÃ LẮP VỎ NHÔM, TỪ SAU CÔNG ĐOẠN BEADING (소자 - 비딩 후)' THEN CAST(Weights AS FLOAT)/2.978


							
							WHEN    Model = N'1030-22F' AND Item = N'BÁN THÀNH PHẨM CHƯA LẮP CAO SU (권취 소자)'  THEN CAST(Weights AS FLOAT)/1.200
							WHEN	Model = N'1030-22F' AND Item =  N'BÁN THÀNH PHẨM ĐÃ LẮP CAO SU, CHƯA LẮP VỎ NHÔM' THEN  CAST(Weights AS FLOAT)/1.600
							WHEN    Model = N'1030-22F' AND Item = N'BÁN THÀNH PHẨM ĐÃ LẮP VỎ NHÔM, TỪ SAU CÔNG ĐOẠN BEADING (소자 - 비딩 후)' THEN CAST(Weights AS FLOAT)/2.978


							
							WHEN    Model = N'1320' AND Item = N'BÁN THÀNH PHẨM CHƯA LẮP CAO SU (권취 소자)'  THEN CAST(Weights AS FLOAT)/1.375
							WHEN	Model = N'1320' AND Item =  N'BÁN THÀNH PHẨM ĐÃ LẮP CAO SU, CHƯA LẮP VỎ NHÔM' THEN  CAST(Weights AS FLOAT)/2.001
							WHEN    Model = N'1320' AND Item = N'BÁN THÀNH PHẨM ĐÃ LẮP VỎ NHÔM, TỪ SAU CÔNG ĐOẠN BEADING (소자 - 비딩 후)' THEN CAST(Weights AS FLOAT)/3.44


							WHEN    Model = N'1325-15F' AND Item = N'BÁN THÀNH PHẨM CHƯA LẮP CAO SU (권취 소자)'  THEN CAST(Weights AS FLOAT)/1.480
							WHEN	Model = N'1325-15F' AND Item =  N'BÁN THÀNH PHẨM ĐÃ LẮP CAO SU, CHƯA LẮP VỎ NHÔM' THEN  CAST(Weights AS FLOAT)/2.200
							WHEN    Model = N'1325-15F' AND Item = N'BÁN THÀNH PHẨM ĐÃ LẮP VỎ NHÔM, TỪ SAU CÔNG ĐOẠN BEADING (소자 - 비딩 후)' THEN CAST(Weights AS FLOAT)/4.280


							
							WHEN    Model = N'1325-18F' AND Item = N'BÁN THÀNH PHẨM CHƯA LẮP CAO SU (권취 소자)'  THEN CAST(Weights AS FLOAT)/1.480
							WHEN	Model = N'1325-18FF' AND Item =  N'BÁN THÀNH PHẨM ĐÃ LẮP CAO SU, CHƯA LẮP VỎ NHÔM' THEN  CAST(Weights AS FLOAT)/2.200
							WHEN    Model = N'1325-18F' AND Item = N'BÁN THÀNH PHẨM ĐÃ LẮP VỎ NHÔM, TỪ SAU CÔNG ĐOẠN BEADING (소자 - 비딩 후)' THEN CAST(Weights AS FLOAT)/4.280


							WHEN    Model = N'1625' AND Item = N'BÁN THÀNH PHẨM CHƯA LẮP CAO SU (권취 소자)'  THEN CAST(Weights AS FLOAT)/2.377
							WHEN	Model = N'1625' AND Item =  N'BÁN THÀNH PHẨM ĐÃ LẮP CAO SU, CHƯA LẮP VỎ NHÔM' THEN  CAST(Weights AS FLOAT)/3.807
							WHEN    Model = N'1625' AND Item = N'BÁN THÀNH PHẨM ĐÃ LẮP VỎ NHÔM, TỪ SAU CÔNG ĐOẠN BEADING (소자 - 비딩 후)' THEN CAST(Weights AS FLOAT)/6.977

							
							WHEN    Model = N'1346' AND Item = N'BÁN THÀNH PHẨM CHƯA LẮP CAO SU (권취 소자)'  THEN CAST(Weights AS FLOAT)/2.761
							WHEN	Model = N'1346' AND Item =  N'BÁN THÀNH PHẨM ĐÃ LẮP CAO SU, CHƯA LẮP VỎ NHÔM' THEN  CAST(Weights AS FLOAT)/3.357
							WHEN    Model = N'1346' AND Item = N'BÁN THÀNH PHẨM ĐÃ LẮP VỎ NHÔM, TỪ SAU CÔNG ĐOẠN BEADING (소자 - 비딩 후)' THEN CAST(Weights AS FLOAT)/7.798


							WHEN    Model = N'1840-50F' AND Item = N'BÁN THÀNH PHẨM CHƯA LẮP CAO SU (권취 소자)'  THEN CAST(Weights AS FLOAT)/3.900
							WHEN	Model = N'1840-50F' AND Item =  N'BÁN THÀNH PHẨM ĐÃ LẮP CAO SU, CHƯA LẮP VỎ NHÔM' THEN  CAST(Weights AS FLOAT)/5.500
							WHEN    Model = N'1840-50F' AND Item = N'BÁN THÀNH PHẨM ĐÃ LẮP VỎ NHÔM, TỪ SAU CÔNG ĐOẠN BEADING (소자 - 비딩 후)' THEN CAST(Weights AS FLOAT)/12.400

							
							WHEN    Model = N'1840-60F' AND Item = N'BÁN THÀNH PHẨM CHƯA LẮP CAO SU (권취 소자)'  THEN CAST(Weights AS FLOAT)/3.900
							WHEN	Model = N'1840-60F' AND Item =  N'BÁN THÀNH PHẨM ĐÃ LẮP CAO SU, CHƯA LẮP VỎ NHÔM' THEN  CAST(Weights AS FLOAT)/5.500
							WHEN    Model = N'1840-60F' AND Item = N'BÁN THÀNH PHẨM ĐÃ LẮP VỎ NHÔM, TỪ SAU CÔNG ĐOẠN BEADING (소자 - 비딩 후)' THEN CAST(Weights AS FLOAT)/12.400


							WHEN    Model = N'1840-120F' AND Item = N'BÁN THÀNH PHẨM CHƯA LẮP CAO SU (권취 소자)'  THEN CAST(Weights AS FLOAT)/3.900
							WHEN	Model = N'1840-120F' AND Item =  N'BÁN THÀNH PHẨM ĐÃ LẮP CAO SU, CHƯA LẮP VỎ NHÔM' THEN  CAST(Weights AS FLOAT)/5.500
							WHEN    Model = N'1840-120F' AND Item = N'BÁN THÀNH PHẨM ĐÃ LẮP VỎ NHÔM, TỪ SAU CÔNG ĐOẠN BEADING (소자 - 비딩 후)' THEN CAST(Weights AS FLOAT)/12.400


							WHEN    Model = N'1859' AND Item = N'BÁN THÀNH PHẨM CHƯA LẮP CAO SU (권취 소자)'  THEN CAST(Weights AS FLOAT)/3.900
							WHEN	Model = N'1859' AND Item =  N'BÁN THÀNH PHẨM ĐÃ LẮP CAO SU, CHƯA LẮP VỎ NHÔM' THEN  CAST(Weights AS FLOAT)/5.500
							WHEN    Model = N'1859' AND Item = N'BÁN THÀNH PHẨM ĐÃ LẮP VỎ NHÔM, TỪ SAU CÔNG ĐOẠN BEADING (소자 - 비딩 후)' THEN CAST(Weights AS FLOAT)/12.400


							
							WHEN    Model = N'3562' AND Item = N'BÁN THÀNH PHẨM CHƯA LẮP CAO SU (권취 소자)'  THEN CAST(Weights AS FLOAT)/28.307
							WHEN	Model = N'3562' AND Item =  N'BÁN THÀNH PHẨM ĐÃ LẮP CAO SU, CHƯA LẮP VỎ NHÔM' THEN  CAST(Weights AS FLOAT)/48.85
							WHEN    Model = N'3562' AND Item = N'BÁN THÀNH PHẨM ĐÃ LẮP VỎ NHÔM, TỪ SAU CÔNG ĐOẠN BEADING (소자 - 비딩 후)' THEN CAST(Weights AS FLOAT)/70.74


							
							WHEN    Model = N'2570' AND Item = N'BÁN THÀNH PHẨM CHƯA LẮP CAO SU (권취 소자)'  THEN CAST(Weights AS FLOAT)/14.127
							WHEN	Model = N'2570' AND Item =  N'BÁN THÀNH PHẨM ĐÃ LẮP CAO SU, CHƯA LẮP VỎ NHÔM' THEN  CAST(Weights AS FLOAT)/0.000
							WHEN    Model = N'2570' AND Item = N'BÁN THÀNH PHẨM ĐÃ LẮP VỎ NHÔM, TỪ SAU CÔNG ĐOẠN BEADING (소자 - 비딩 후)' THEN CAST(Weights AS FLOAT)/0.000

								
							WHEN    Model = N'2245 L -100F' AND Item = N'BÁN THÀNH PHẨM CHƯA LẮP CAO SU (권취 소자)'  THEN CAST(Weights AS FLOAT)/7.618
							WHEN	Model = N'2245 L -100F' AND Item =  N'BÁN THÀNH PHẨM ĐÃ LẮP CAO SU, CHƯA LẮP VỎ NHÔM' THEN  CAST(Weights AS FLOAT)/0.000
							WHEN    Model = N'2245 L -100F' AND Item = N'BÁN THÀNH PHẨM ĐÃ LẮP VỎ NHÔM, TỪ SAU CÔNG ĐOẠN BEADING (소자 - 비딩 후)' THEN CAST(Weights AS FLOAT)/20.5


									
							WHEN    Model = N'2245 - 300F' AND Item = N'BÁN THÀNH PHẨM CHƯA LẮP CAO SU (권취 소자)'  THEN CAST(Weights AS FLOAT)/0.000
							WHEN	Model = N'2245 - 300F' AND Item =  N'BÁN THÀNH PHẨM ĐÃ LẮP CAO SU, CHƯA LẮP VỎ NHÔM' THEN  CAST(Weights AS FLOAT)/0.000
							WHEN    Model = N'2245 - 300F' AND Item = N'BÁN THÀNH PHẨM ĐÃ LẮP VỎ NHÔM, TỪ SAU CÔNG ĐOẠN BEADING (소자 - 비딩 후)' THEN CAST(Weights AS FLOAT)/0.000


									
							WHEN    Model = N'22245 - 220F' AND Item = N'BÁN THÀNH PHẨM CHƯA LẮP CAO SU (권취 소자)'  THEN CAST(Weights AS FLOAT)/0.000
							WHEN	Model = N'22245 - 220F' AND Item =  N'BÁN THÀNH PHẨM ĐÃ LẮP CAO SU, CHƯA LẮP VỎ NHÔM' THEN  CAST(Weights AS FLOAT)/0.000
							WHEN    Model = N'22245 - 220F' AND Item = N'BÁN THÀNH PHẨM ĐÃ LẮP VỎ NHÔM, TỪ SAU CÔNG ĐOẠN BEADING (소자 - 비딩 후)' THEN CAST(Weights AS FLOAT)/0.000

									
							WHEN    Model = N'3582' AND Item = N'BÁN THÀNH PHẨM CHƯA LẮP CAO SU (권취 소자)'  THEN CAST(Weights AS FLOAT)/40.000
							WHEN	Model = N'3582' AND Item =  N'BÁN THÀNH PHẨM ĐÃ LẮP CAO SU, CHƯA LẮP VỎ NHÔM' THEN  CAST(Weights AS FLOAT)/0.000
							WHEN    Model = N'3582' AND Item = N'BÁN THÀNH PHẨM ĐÃ LẮP VỎ NHÔM, TỪ SAU CÔNG ĐOẠN BEADING (소자 - 비딩 후)' THEN CAST(Weights AS FLOAT)/94.33


							ELSE 0.000
					END AS Result
		INTO #T1
			FROM 
				#Tbl1

				SELECT 
					Line,
				    Item,
					NG,
				    CONVERT (FLOAT,Weights) AS Weights,
				    UNIT,
					StatusError,
					NameShift,
					CONVERT(DATE,Dates) AS Dates,
					Times,
					CreateUserID,
					IDPE,
					Model,
					Result
				FROM #T1

			WHERE 
					(
							((@FromDate IS NULL) OR CONVERT(DATE,Dates) >= @FromDate)
						AND
							((@ToDate IS NULL) OR CONVERT(DATE,Dates) <= @ToDate)
					)

					AND 
							(Model LIKE @Model)

			DROP TABLE #Tbl1
			DROP TABLE #T1
					
END

--CONVERT(FLOAT,Weights) AS

--select Weights * 100.04 AS A from STB_VN_PRODUCTION_ERROR


--SELECT * FROM  STB_VN_PRODUCTION_ERROR WHERE Model= N'0813' AND Item = N'BÁN THÀNH PHẨM CHƯA LẮP CAO SU (권취 소자)'

--alter column Weights FLOAT