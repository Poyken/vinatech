-- ==================================================================
-- Author      : Kevin Nguyễn
-- Create date : 2020-07-05
-- Browsable   : true
-- Group       :  EA VN team
--                 Scrap graph function
-- Description :  Development for managment view
-- ==================================================================
CREATE PROC [dbo].[usp_VN_ChoPhe]
	@pFromdate DATE = NULL,
	@pToDate DATE = NULL
AS
BEGIN

SET NOCOUNT ON;

		
		DECLARE @FromDate DATE = @pFromdate
		DECLARE @ToDate DATE = @pToDate

	SELECT
			T1.Model,
			T1.Weights,
			T1.Item,
			CONVERT(DATE,T1.InputDate) AS InputDate
			INTO #Tbl1	
	FROM

			 STB_VN_PRODUCTION_ERROR T1 WITH(NOLOCK)
			
	WHERE 

			 T1.Flag=0 
			 AND
			 T1.StatusError=N'Chờ phế'
			 
			
			SELECT 
					Weights,
					Item,
					InputDate,
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
					InputDate,
				    Model,
					SUM(ISNULL(Result,0)) AS Total
					INTO #TblResult
			FROM 
					 #T1

			GROUP BY
					InputDate,
				    Model
					
			SELECT
					InputDate,
					Model,
					CAST(Total AS INT) AS Results

			FROM 
					#TblResult

		    WHERE
					(
							((@FromDate IS NULL) OR CONVERT(DATE,InputDate) >= @FromDate)
						AND
							((@ToDate IS NULL) OR CONVERT(DATE,InputDate) <= @ToDate)
					)
					 
		   ORDER BY 
					InputDate ASC
		
			DROP TABLE  #T1
			DROP TABLE #Tbl1
			DROP TABLE #TblResult
END

--EXEC usp_VN_ChoPhe '2020-07-02','2020-07-04'