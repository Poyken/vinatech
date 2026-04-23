CREATE PROC [dbo].[usp_vn_showproductionerror] -- exec [usp_vn_showproductionerror] '2023-11-01','2023-11-30','','','VVT_F1'
	@pFromdate DATE = NULL,
	@pToDate DATE = NULL,
	@pLine VARCHAR(100) = NULL,
	@pModel VARCHAR(100) = NULL,
	@pWorkCenterCode VARCHAR(100) = NULL
--WITH encryption
--WITH RECOMPILE	
AS
BEGIN

	SET NOCOUNT ON;

		DECLARE @Line VARCHAR(100) = CASE WHEN ISNULL(@pLine,'') = '' THEN '%' ELSE @pLine END,
				@Model VARCHAR(100)= CASE WHEN ISNULL (@pModel, '') = '' THEN '%' ELSE @pModel END
		DECLARE @FromDate DATEtime = convert(varchar(10),isnull(@pFromdate,dateadd(month,-3,getdate()) ),120) + ' 10:00:00'
		DECLARE @ToDate DATEtime =  convert(varchar(10),dateadd(day,1,isnull(@pToDate,getdate() )),120) + ' 10:00:00'
		DECLARE @WorkCenterCode VARCHAR(20) = CASE WHEN ISNULL(@pWorkCenterCode,'') = '' THEN '%' ELSE @pWorkCenterCode END

		CREATE TABLE #Tbl1
		(
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
			UNIT NVARCHAR(20) NULL,
			LINENAME NVARCHAR(50) NULL,
			createdatetime datetime,
			MaLotCapThu VARCHAR(50) NULL,
			MaLotNguyenLieu VARCHAR(50) NULL,
			WorkCenterCode NVARCHAR(50) NULL
		)

		INSERT INTO #Tbl1 (Model,Item,NG,Weights,UNIT,StatusError,NameShift,Dates,Times,CreateUserID,IDPE,LINENAME,createdatetime, MaLotCapThu, MaLotNguyenLieu,WorkCenterCode) 

				SELECT 
					 VNSHOW.Model,
					 VNSHOW.Item,
					 VNSHOW.NG,
					 VNSHOW.Weights,
					 UNIT,
					 VNSHOW.StatusError,
					 VNSHOW.NameShift,
					 CreateDateTime AS Dates,
					 RIGHT(VNSHOW.CreateDateTime,8) AS Times,
					 CreateUserID,
					 VNSHOW.IDPE,
					 VNSHOW.LINENAME,
					VNSHOW.createdatetime,
					VNSHOW.MaLotCapThu,
					VNSHOW.MaLotNguyenLieu,
					VNSHOW.WorkCenterCode
				FROM

					STB_VN_PRODUCTION_ERROR VNSHOW WITH(NOLOCK)

				
				WHERE  
						Flag='False'
	
			UPDATE #Tbl1
			SET
					UNIT = 'KG'
			WHERE 
					Item =N'DUNG DỊCH - 2.3V' AND CONVERT(DATE,CreateDateTime) >= '2021-11-01'


					UPDATE #Tbl1
			SET
					UNIT = 'KG'
			WHERE 
					Item =N'DUNG DỊCH -2.7V' AND CONVERT(DATE,CreateDateTime) >= '2021-11-01'


				UPDATE #Tbl1
			SET
					UNIT = 'KG'
			WHERE 
					Item =N'DUNG DỊCH -3.0V' AND CONVERT(DATE,CreateDateTime) >= '2021-11-01'

								UPDATE #Tbl1
			SET
					UNIT = 'KG'
			WHERE 
					Item =N'MODULE_THIẾC PHẾ ( 99.3+99.9)' AND CONVERT(DATE,CreateDateTime) >= '2021-11-01'

			
			SELECT
				    Item,
					NG,
				    Weights,
				    UNIT,
					StatusError,
					NameShift,
					Dates AS Dates,
					Times,
					CreateUserID,
					LINENAME,
					IDPE,
					Model,
					createdatetime,
					MaLotCapThu,
					MaLotNguyenLieu,
					WorkCenterCode,

CASE 				
WHEN MaLotNguyenLieu = 'GBNKSP-054'  THEN  CAST(Weights AS FLOAT)/ 25.7
WHEN MaLotNguyenLieu = 'GBNKSP-057'  THEN  CAST(Weights AS FLOAT)/ 25.7
WHEN MaLotNguyenLieu = 'GBNKSP-063'  THEN  CAST(Weights AS FLOAT)/ 15.3
WHEN MaLotNguyenLieu = 'GBNKSP-059'  THEN  CAST(Weights AS FLOAT)/ 15.3
WHEN MaLotNguyenLieu = 'GBNKSP-065'  THEN  CAST(Weights AS FLOAT)/ 15.3
WHEN MaLotNguyenLieu = 'GBNKSP-066'  THEN  CAST(Weights AS FLOAT)/ 15.3
WHEN MaLotNguyenLieu = 'GBNKSP-074'  THEN  CAST(Weights AS FLOAT)/ 15.3
WHEN MaLotNguyenLieu = 'GBNKSP-060'  THEN  CAST(Weights AS FLOAT)/ 15.3
WHEN MaLotNguyenLieu = 'GBNKSP-061'  THEN  CAST(Weights AS FLOAT)/ 15.3
WHEN MaLotNguyenLieu = 'GBNKSP-067'  THEN  CAST(Weights AS FLOAT)/ 15.3
WHEN MaLotNguyenLieu = 'GBNKSP-068'  THEN  CAST(Weights AS FLOAT)/ 15.3
WHEN MaLotNguyenLieu = 'GBNKSP-S02'  THEN  CAST(Weights AS FLOAT)/ 15.3
WHEN MaLotNguyenLieu = 'GBNKSP-069'  THEN  CAST(Weights AS FLOAT)/ 15.3
WHEN MaLotNguyenLieu = 'GBNKSP-070'  THEN  CAST(Weights AS FLOAT)/ 15.3
WHEN MaLotNguyenLieu = 'GBNKSP-072'  THEN  CAST(Weights AS FLOAT)/ 15.3
WHEN MaLotNguyenLieu = 'GBNKSP-071'  THEN  CAST(Weights AS FLOAT)/ 15.3
WHEN MaLotNguyenLieu = 'GBNKSP-058'  THEN  CAST(Weights AS FLOAT)/ 15.3
WHEN MaLotNguyenLieu = 'GBNKSP-062'  THEN  CAST(Weights AS FLOAT)/ 15.3
WHEN MaLotNguyenLieu = 'GBEC00-002'  THEN  CAST(Weights AS FLOAT)/ NULLIF(0.000,0)
WHEN MaLotNguyenLieu = 'GBCP00-004'  THEN  (CAST(Weights AS FLOAT)/ 1)
WHEN MaLotNguyenLieu = 'GBCP00-001'  THEN  CAST(Weights AS FLOAT)/ 1
WHEN MaLotNguyenLieu = 'GBCP00-001'  THEN  CAST(Weights AS FLOAT)/ 1
WHEN MaLotNguyenLieu = 'GBEC00-008'  THEN  CAST(Weights AS FLOAT)/1      ----------------------
WHEN MaLotNguyenLieu = 'GBSN00-005'  THEN  CAST(Weights AS FLOAT)/ 0.2
WHEN MaLotNguyenLieu = 'GBSN00-005'  THEN  CAST(Weights AS FLOAT)/ 0.2
WHEN MaLotNguyenLieu = 'GBSN00-004'  THEN  CAST(Weights AS FLOAT)/ 0.4
WHEN MaLotNguyenLieu = 'GBSN00-001'  THEN  CAST(Weights AS FLOAT)/ 0.9
WHEN MaLotNguyenLieu = 'GBSN00-002'  THEN  CAST(Weights AS FLOAT)/ 1.3
WHEN MaLotNguyenLieu = 'GBSN00-006'  THEN  CAST(Weights AS FLOAT)/ 1.8
WHEN MaLotNguyenLieu = 'GBSN00-003'  THEN  CAST(Weights AS FLOAT)/ 1.8
WHEN MaLotNguyenLieu = 'GCMTTT-012'  THEN  CAST(Weights AS FLOAT)/ 2.077
WHEN MaLotNguyenLieu = 'GCTN00-S01'  THEN  CAST(Weights AS FLOAT)/ 2.077
WHEN MaLotNguyenLieu = 'GCMTTT-013'  THEN  CAST(Weights AS FLOAT)/ 2.11
WHEN MaLotNguyenLieu = 'GCMTTT-002'  THEN  CAST(Weights AS FLOAT)/ 2.581
WHEN MaLotNguyenLieu = 'GCTN00-002'  THEN  CAST(Weights AS FLOAT)/ 6.15
WHEN MaLotNguyenLieu = 'GCMTTT-023'  THEN  CAST(Weights AS FLOAT)/ 61.5
WHEN MaLotNguyenLieu = 'GCMTTT-024'  THEN  CAST(Weights AS FLOAT)/ 6.15
WHEN MaLotNguyenLieu = 'GBHB00-036'  THEN  CAST(Weights AS FLOAT)/ 0.1
WHEN MaLotNguyenLieu = 'GBHB00-035'  THEN  CAST(Weights AS FLOAT)/ 0.09
WHEN MaLotNguyenLieu = 'GBHB00-033'  THEN  CAST(Weights AS FLOAT)/ 0.1
WHEN MaLotNguyenLieu = 'GBHB00-034'  THEN  CAST(Weights AS FLOAT)/ 0.09
WHEN MaLotNguyenLieu = 'GBHB00-031'  THEN  CAST(Weights AS FLOAT)/ 0.14
WHEN MaLotNguyenLieu = 'GBHB00-032'  THEN  CAST(Weights AS FLOAT)/ 0.13
WHEN MaLotNguyenLieu = 'GBYCTT-002' THEN  CAST(Weights AS FLOAT)/ 0.13
WHEN MaLotNguyenLieu = 'GBYCTT-003' THEN  CAST(Weights AS FLOAT)/ 0.13
WHEN MaLotNguyenLieu = 'GBHB00-043' THEN  CAST(Weights AS FLOAT)/ 0.19
WHEN MaLotNguyenLieu = 'GBHB00-042'  THEN  CAST(Weights AS FLOAT)/ 0.17
--WHEN MaLotNguyenLieu = 'GCSAAT-001'  THEN  CAST(Weights AS FLOAT)/ 0.196
WHEN MaLotNguyenLieu = 'GCSAAT-001'  THEN  CAST(Weights AS FLOAT)/ 2.78
WHEN MaLotNguyenLieu = 'GCSN00-001' THEN  CAST(Weights AS FLOAT)/ 0.172
WHEN MaLotNguyenLieu = 'GCSN00-003' THEN  CAST(Weights AS FLOAT)/ 0.223
WHEN MaLotNguyenLieu = 'GCSN00-002' THEN  CAST(Weights AS FLOAT)/ 0.421
WHEN MaLotNguyenLieu = 'GBAKAC-062'  THEN  CAST(Weights AS FLOAT)/ 0.306
WHEN MaLotNguyenLieu = 'GBAKAC-S06' THEN  CAST(Weights AS FLOAT)/ 0.161
WHEN MaLotNguyenLieu = 'GBAKAC-059'  THEN  CAST(Weights AS FLOAT)/ 0.2
WHEN MaLotNguyenLieu = 'GBAKAC-060'  THEN  CAST(Weights AS FLOAT)/ 0.4
WHEN MaLotNguyenLieu = 'GBAKAC-052'  THEN  CAST(Weights AS FLOAT)/ 0.4
WHEN MaLotNguyenLieu = 'GRAKAC-065'  THEN  CAST(Weights AS FLOAT)/ 0.4
WHEN MaLotNguyenLieu = 'GBAKAC-032'  THEN  CAST(Weights AS FLOAT)/ 0.4
WHEN MaLotNguyenLieu = 'GBAKAC-051'  THEN  CAST(Weights AS FLOAT)/ 0.4

WHEN MaLotNguyenLieu = 'GBAKAC-048'  THEN  CAST(Weights AS FLOAT)/ 0.6
WHEN MaLotNguyenLieu = 'GBAKAC-004'  THEN  CAST(Weights AS FLOAT)/ 0.6
WHEN MaLotNguyenLieu = 'GBAKAC-054'  THEN  CAST(Weights AS FLOAT)/ 0.76
WHEN MaLotNguyenLieu = 'GBAKAC-039'  THEN  CAST(Weights AS FLOAT)/ 0.88
WHEN MaLotNguyenLieu = 'GBAKAC-064'  THEN  CAST(Weights AS FLOAT)/ 1.627
WHEN MaLotNguyenLieu = 'GBAKAC-005'  THEN  CAST(Weights AS FLOAT)/ 1.33
WHEN MaLotNguyenLieu = 'GBAKAC-S03'  THEN  CAST(Weights AS FLOAT)/ 3.296
WHEN MaLotNguyenLieu = 'GBAKAC-S09'  THEN  CAST(Weights AS FLOAT)/ 1.974
WHEN MaLotNguyenLieu = 'GBAKAC-063'  THEN  CAST(Weights AS FLOAT)/ 2.51
WHEN MaLotNguyenLieu = 'GBAKAC-036'  THEN  CAST(Weights AS FLOAT)/ 3.338
WHEN MaLotNguyenLieu = 'GBAKAC-068'  THEN  CAST(Weights AS FLOAT)/ 3.885
WHEN MaLotNguyenLieu = 'GBAKAC-V01'  THEN  CAST(Weights AS FLOAT)/ 3.602
WHEN MaLotNguyenLieu = 'GBAKAC-066' THEN  CAST(Weights AS FLOAT)/ 6.58
WHEN MaLotNguyenLieu = 'GBAKAC-037' THEN  CAST(Weights AS FLOAT)/ 14.363
WHEN MaLotNguyenLieu = 'GBAKAC-043' THEN  CAST(Weights AS FLOAT)/ 15.156
WHEN MaLotNguyenLieu = 'GBAKAC-038' THEN  CAST(Weights AS FLOAT)/ 16.121
WHEN MaLotNguyenLieu = 'GBAKAC-033' THEN  CAST(Weights AS FLOAT)/ 18.041
WHEN MaLotNguyenLieu = 'GCMDPT-S04'  THEN  CAST(Weights AS FLOAT)/ 3.6
WHEN MaLotNguyenLieu = 'GCMDPT-476'  THEN  CAST(Weights AS FLOAT)/ 3.6
WHEN MaLotNguyenLieu = 'GCMDPT-200'  THEN  CAST(Weights AS FLOAT)/ 3.6
WHEN MaLotNguyenLieu = 'GCMDPT-421'  THEN  CAST(Weights AS FLOAT)/ 3.6
WHEN MaLotNguyenLieu = 'GCMDPT-358'  THEN  CAST(Weights AS FLOAT)/ 3.6
WHEN MaLotNguyenLieu = 'GCMDPT-379'  THEN  CAST(Weights AS FLOAT)/ 3.6
WHEN MaLotNguyenLieu = 'GCMDPT-473'  THEN  CAST(Weights AS FLOAT)/ 3.6
WHEN MaLotNguyenLieu = 'GCMDPT-382'  THEN  CAST(Weights AS FLOAT)/ 3.6
WHEN MaLotNguyenLieu = 'GCMDPT-216'  THEN  CAST(Weights AS FLOAT)/ 3.6
WHEN MaLotNguyenLieu = 'GCMDPT-201'  THEN  CAST(Weights AS FLOAT)/ 3.6
WHEN MaLotNguyenLieu = 'GCMDPT-393'  THEN  CAST(Weights AS FLOAT)/ 3.6
WHEN MaLotNguyenLieu = 'GCMDPT-196'  THEN  CAST(Weights AS FLOAT)/ 3.6
WHEN MaLotNguyenLieu = 'GCMDPT-298'  THEN  CAST(Weights AS FLOAT)/ 3.6
WHEN MaLotNguyenLieu = 'GCMDPT-419'  THEN  CAST(Weights AS FLOAT)/ 3.6
WHEN MaLotNguyenLieu = 'GCMDPT-475'  THEN  CAST(Weights AS FLOAT)/ 3.6
WHEN MaLotNguyenLieu = 'GCMDPT-369'  THEN  CAST(Weights AS FLOAT)/ 3.6
WHEN MaLotNguyenLieu = 'GCMDPT-416'  THEN  CAST(Weights AS FLOAT)/ 3.6
WHEN MaLotNguyenLieu = 'GCMDPT-197'  THEN  CAST(Weights AS FLOAT)/ 5.06
WHEN MaLotNguyenLieu = 'GCMDPT-198'  THEN  CAST(Weights AS FLOAT)/ 5.06
WHEN MaLotNguyenLieu = 'GCMDPT-275'  THEN  CAST(Weights AS FLOAT)/ 5.06
WHEN MaLotNguyenLieu = 'GCMDPT-409'  THEN  CAST(Weights AS FLOAT)/ 5.06
WHEN MaLotNguyenLieu = 'GCMDPT-340'  THEN  CAST(Weights AS FLOAT)/ 5.06
WHEN MaLotNguyenLieu = 'GCMDPT-408'  THEN  CAST(Weights AS FLOAT)/ 5.06
WHEN MaLotNguyenLieu = 'GCMDPT-391'  THEN  CAST(Weights AS FLOAT)/ 5.06
WHEN MaLotNguyenLieu = 'GCMDPT-259'  THEN  CAST(Weights AS FLOAT)/ 5.06
WHEN MaLotNguyenLieu = 'GCMDPT-256'  THEN  CAST(Weights AS FLOAT)/ 5.06
WHEN MaLotNguyenLieu = 'GCMDPT-406'  THEN  CAST(Weights AS FLOAT)/ 5.06
WHEN MaLotNguyenLieu = 'GCMDPT-391'  THEN  CAST(Weights AS FLOAT)/ 5.06
WHEN MaLotNguyenLieu = 'GCMDPT-386'  THEN  CAST(Weights AS FLOAT)/ 5.06
WHEN MaLotNguyenLieu = 'GCMDPT-202' THEN  CAST(Weights AS FLOAT)/ 5.06
WHEN MaLotNguyenLieu = 'GCMDPT-220' THEN  CAST(Weights AS FLOAT)/ 5.06
WHEN MaLotNguyenLieu = 'GCMDPT-265'  THEN  CAST(Weights AS FLOAT)/ 5.06
WHEN MaLotNguyenLieu = 'GCMDPT-399' THEN  CAST(Weights AS FLOAT)/ 5.06
WHEN MaLotNguyenLieu = 'GCMDPT-380'  THEN  CAST(Weights AS FLOAT)/ 5.06
WHEN MaLotNguyenLieu = 'GCMDPT-459' THEN  CAST(Weights AS FLOAT)/ 5.06
WHEN MaLotNguyenLieu = 'GCMDPT-211'  THEN  CAST(Weights AS FLOAT)/ 5.06
WHEN MaLotNguyenLieu = 'GCMDPT-452'  THEN  CAST(Weights AS FLOAT)/ 5.06
WHEN MaLotNguyenLieu = 'GCMDPT-288'  THEN  CAST(Weights AS FLOAT)/ 5.54
WHEN MaLotNguyenLieu = 'GCMDPT-420'  THEN  CAST(Weights AS FLOAT)/ 5.54
WHEN MaLotNguyenLieu = 'GCMDPT-424' THEN  CAST(Weights AS FLOAT)/ 5.54
WHEN MaLotNguyenLieu = 'GCMDPT-223' THEN  CAST(Weights AS FLOAT)/ 5.54
WHEN MaLotNguyenLieu = 'GCMDPT-371' THEN  CAST(Weights AS FLOAT)/ 5.54
WHEN MaLotNguyenLieu = 'GCMDPT-442'  THEN  CAST(Weights AS FLOAT)/ 5.54
WHEN MaLotNguyenLieu = 'GCMDPT-384' THEN  CAST(Weights AS FLOAT)/ 5.54
WHEN MaLotNguyenLieu = 'GCMDPT-392'  THEN  CAST(Weights AS FLOAT)/ 5.54
WHEN MaLotNguyenLieu = 'GCMDPT-227'  THEN  CAST(Weights AS FLOAT)/ 5.54
WHEN MaLotNguyenLieu = 'GCMDPT-204' THEN  CAST(Weights AS FLOAT)/ 5.54
WHEN MaLotNguyenLieu = 'GCMDPT-365' THEN  CAST(Weights AS FLOAT)/ 5.54
WHEN MaLotNguyenLieu = 'GCMDPT-301' THEN  CAST(Weights AS FLOAT)/ 5.54
WHEN MaLotNguyenLieu = 'GCMDPT-320' THEN  CAST(Weights AS FLOAT)/ 5.54
WHEN MaLotNguyenLieu = 'GCMDPT-208'  THEN  CAST(Weights AS FLOAT)/ 6.79
WHEN MaLotNguyenLieu = 'GCMDPT-240' THEN  CAST(Weights AS FLOAT)/ 6.79
WHEN MaLotNguyenLieu = 'GCMDPT-504' THEN  CAST(Weights AS FLOAT)/ 6.79
WHEN MaLotNguyenLieu = 'GCMDPT-471' THEN  CAST(Weights AS FLOAT)/ 6.79
WHEN MaLotNguyenLieu = 'GCMDPT-376' THEN  CAST(Weights AS FLOAT)/ 8.1
WHEN MaLotNguyenLieu = 'GCMDPT-199' THEN  CAST(Weights AS FLOAT)/ 8.1
WHEN MaLotNguyenLieu = 'GCMDPT-404'  THEN CAST(Weights AS FLOAT)/ 8.1 
WHEN MaLotNguyenLieu = 'GCMDPT-388' THEN  CAST(Weights AS FLOAT)/ 8.1
WHEN MaLotNguyenLieu = 'GCMDPT-210' THEN  CAST(Weights AS FLOAT)/ 8.1
WHEN MaLotNguyenLieu = 'GCMDPT-249' THEN  CAST(Weights AS FLOAT)/ 8.1
WHEN MaLotNguyenLieu = 'GCMDPT-276' THEN  CAST(Weights AS FLOAT)/ 8.1
WHEN MaLotNguyenLieu = 'GCMDPT-308'  THEN  CAST(Weights AS FLOAT)/ 8.1
WHEN MaLotNguyenLieu = 'GCMDPT-370'  THEN  CAST(Weights AS FLOAT)/ 8.1
WHEN MaLotNguyenLieu = 'GCMDPT-242'  THEN  CAST(Weights AS FLOAT)/ 9.6
WHEN MaLotNguyenLieu = 'GCMDPT-277'  THEN  CAST(Weights AS FLOAT)/ 9.6
WHEN MaLotNguyenLieu = 'GCMDPT-262'  THEN  CAST(Weights AS FLOAT)/ 9.6
WHEN MaLotNguyenLieu = 'GCMDPT-258'  THEN  CAST(Weights AS FLOAT)/ 9.6
WHEN MaLotNguyenLieu = 'GCMDPT-368' THEN  CAST(Weights AS FLOAT)/ 9.6
WHEN MaLotNguyenLieu = 'GCMDPT-253'  THEN  CAST(Weights AS FLOAT)/ 10.8
WHEN MaLotNguyenLieu = 'GCMDPT-407' THEN  CAST(Weights AS FLOAT)/ 10.8
WHEN MaLotNguyenLieu = 'GCMDPT-218'  THEN  CAST(Weights AS FLOAT)/ 14.8
WHEN MaLotNguyenLieu = 'GCMDPT-285'  THEN  CAST(Weights AS FLOAT)/ 14.8
WHEN MaLotNguyenLieu = 'GCMDPT-243'  THEN  CAST(Weights AS FLOAT)/ 14.8
WHEN MaLotNguyenLieu = 'GCMDPT-435'  THEN  CAST(Weights AS FLOAT)/ 14.8
WHEN MaLotNguyenLieu = 'GCMDPT-427'  THEN  CAST(Weights AS FLOAT)/ 14.8
WHEN MaLotNguyenLieu = 'GCMDPT-353'  THEN  CAST(Weights AS FLOAT)/ 15.7
WHEN MaLotNguyenLieu = 'GCMDPT-443'  THEN  CAST(Weights AS FLOAT)/ 15.7
WHEN MaLotNguyenLieu = 'GCMDPT-362'  THEN  CAST(Weights AS FLOAT)/ 14.5
WHEN MaLotNguyenLieu = 'GCMDPT-465' THEN  CAST(Weights AS FLOAT)/ 14.8
WHEN MaLotNguyenLieu = 'GBRBPL-001'  THEN  CAST(Weights AS FLOAT)/ NULLIF(0.000,0)
WHEN MaLotNguyenLieu = 'GBRBPL-002' THEN  CAST(Weights AS FLOAT)/ NULLIF(0.000,0)
WHEN MaLotNguyenLieu = 'GBRBPL-003' THEN  CAST(Weights AS FLOAT)/ NULLIF(0.000,0)
WHEN MaLotNguyenLieu = 'REELTAPE055T'  THEN  CAST(Weights AS FLOAT)/ NULLIF(0.000,0)
WHEN MaLotNguyenLieu = 'REEL-TAPE'   THEN  CAST(Weights AS FLOAT)/ NULLIF(0.000,0)
WHEN MaLotNguyenLieu = 'REEL-TAPEM'  THEN  CAST(Weights AS FLOAT)/ NULLIF(0.000,0)
WHEN MaLotNguyenLieu = 'GCTN00-003' THEN  CAST(Weights AS FLOAT)/ NULLIF(0.000,0)
WHEN MaLotNguyenLieu = 'GCMDPT-387'  THEN  CAST(Weights AS FLOAT)/ NULLIF(0.000,0)
WHEN MaLotNguyenLieu = 'GCMDPT-205'  THEN  CAST(Weights AS FLOAT)/ NULLIF(0.000,0)
WHEN MaLotNguyenLieu = 'GCMDPT-432'  THEN  CAST(Weights AS FLOAT)/ NULLIF(0.000,0)
WHEN MaLotNguyenLieu = 'GCMDPT-355'  THEN  CAST(Weights AS FLOAT)/ NULLIF(0.000,0)
WHEN MaLotNguyenLieu = 'GCMDPT-254'  THEN  CAST(Weights AS FLOAT)/ NULLIF(0.000,0)
WHEN MaLotNguyenLieu = 'GCMDPT-431'  THEN  CAST(Weights AS FLOAT)/ NULLIF(0.000,0)
WHEN MaLotNguyenLieu = 'GCMDPT-394'  THEN  CAST(Weights AS FLOAT)/ NULLIF(0.000,0)
WHEN MaLotNguyenLieu = 'GCMDPT-348'  THEN  CAST(Weights AS FLOAT)/ NULLIF(0.000,0)
WHEN MaLotNguyenLieu = 'GCMDPT-283'  THEN  CAST(Weights AS FLOAT)/ NULLIF(0.000,0)
WHEN MaLotNguyenLieu = 'GCMDPT-206'  THEN  CAST(Weights AS FLOAT)/ NULLIF(0.000,0)
WHEN MaLotNguyenLieu = 'GCMDPT-434'  THEN  CAST(Weights AS FLOAT)/ NULLIF(0.000,0)
WHEN MaLotNguyenLieu = 'GCMDPT-207'  THEN  CAST(Weights AS FLOAT)/ NULLIF(0.000,0)
WHEN MaLotNguyenLieu = 'GCMDPT-309'  THEN  CAST(Weights AS FLOAT)/ NULLIF(0.000,0)
WHEN MaLotNguyenLieu = 'GCMDPT-245'  THEN  CAST(Weights AS FLOAT)/ NULLIF(0.000,0)
WHEN MaLotNguyenLieu = 'GCMDPT-292'  THEN  CAST(Weights AS FLOAT)/ NULLIF(0.000,0)
WHEN MaLotNguyenLieu = 'GCMDPT-467'  THEN  CAST(Weights AS FLOAT)/ NULLIF(0.000,0)
WHEN MaLotNguyenLieu = 'GCMDPT-413'  THEN  CAST(Weights AS FLOAT)/ NULLIF(0.000,0)
WHEN MaLotNguyenLieu = 'GCMDPT-209'  THEN  CAST(Weights AS FLOAT)/ NULLIF(0.000,0)
WHEN MaLotNguyenLieu = 'GCMDPT-385'  THEN  CAST(Weights AS FLOAT)/ NULLIF(0.000,0)
WHEN MaLotNguyenLieu = 'GCMDPT-292'  THEN  CAST(Weights AS FLOAT)/ NULLIF(0.000,0)
WHEN MaLotNguyenLieu = 'GCMDPT-441'  THEN  CAST(Weights AS FLOAT)/ NULLIF(0.000,0)
WHEN MaLotNguyenLieu = 'GCMDPT-282'  THEN  CAST(Weights AS FLOAT)/ NULLIF(0.000,0)
WHEN MaLotNguyenLieu = 'GCMDPT-381'  THEN  CAST(Weights AS FLOAT)/ NULLIF(0.000,0)
WHEN MaLotNguyenLieu = 'GCMDPT-319'  THEN  CAST(Weights AS FLOAT)/ NULLIF(0.000,0)
WHEN MaLotNguyenLieu = 'GCMDPT-397'  THEN  CAST(Weights AS FLOAT)/ NULLIF(0.000,0)
WHEN MaLotNguyenLieu = 'GCMDPT-445'  THEN  CAST(Weights AS FLOAT)/ NULLIF(0.000,0)
WHEN MaLotNguyenLieu = 'GCMDPT-440'  THEN  CAST(Weights AS FLOAT)/ NULLIF(0.000,0)
WHEN MaLotNguyenLieu = 'GCMDPT-284'  THEN  CAST(Weights AS FLOAT)/ NULLIF(0.000,0)
WHEN MaLotNguyenLieu = 'GCMDPT-279'  THEN  CAST(Weights AS FLOAT)/ NULLIF(0.000,0)
WHEN MaLotNguyenLieu = 'GCMDPT-423'  THEN  CAST(Weights AS FLOAT)/ NULLIF(0.000,0)
WHEN MaLotNguyenLieu = 'GCMDPT-412'  THEN  CAST(Weights AS FLOAT)/ NULLIF(0.000,0)
WHEN MaLotNguyenLieu = 'GCMDPT-425'  THEN  CAST(Weights AS FLOAT)/ NULLIF(0.000,0)
WHEN MaLotNguyenLieu = 'GCMDPT-425'  THEN  CAST(Weights AS FLOAT)/ NULLIF(0.000,0)
WHEN MaLotNguyenLieu = 'GCMDPT-252'  THEN  CAST(Weights AS FLOAT)/ NULLIF(0.000,0)
WHEN MaLotNguyenLieu = 'GCMDPT-345'  THEN  CAST(Weights AS FLOAT)/ NULLIF(0.000,0)
WHEN MaLotNguyenLieu = 'GCMDPT-439'  THEN  CAST(Weights AS FLOAT)/ NULLIF(0.000,0)
WHEN MaLotNguyenLieu = 'GCMDPT-S01' THEN  CAST(Weights AS FLOAT)/ NULLIF(0.000,0)
WHEN MaLotNguyenLieu = 'GCMDPT-250'  THEN  CAST(Weights AS FLOAT)/ NULLIF(0.000,0)
WHEN MaLotNguyenLieu = 'GCMDPT-212'  THEN  CAST(Weights AS FLOAT)/ NULLIF(0.000,0)
WHEN MaLotNguyenLieu = 'GCMDPT-417'  THEN  CAST(Weights AS FLOAT)/ NULLIF(0.000,0)
WHEN MaLotNguyenLieu = 'WRKI00-012'  THEN  CAST(Weights AS FLOAT)/ NULLIF(0.000,0)
WHEN MaLotNguyenLieu = 'WIRE00-002'  THEN  CAST(Weights AS FLOAT)/ NULLIF(0.000,0)
WHEN MaLotNguyenLieu = 'WRHI00-001'  THEN  CAST(Weights AS FLOAT)/ NULLIF(0.000,0)
WHEN MaLotNguyenLieu = 'WRKI00-002'  THEN  CAST(Weights AS FLOAT)/ NULLIF(0.000,0)
WHEN MaLotNguyenLieu = 'WRHI00-002' THEN  CAST(Weights AS FLOAT)/ NULLIF(0.000,0)
WHEN MaLotNguyenLieu = 'WIRE00-003'  THEN  CAST(Weights AS FLOAT)/ NULLIF(0.000,0)
WHEN MaLotNguyenLieu = 'WRKI00-003'  THEN  CAST(Weights AS FLOAT)/ NULLIF(0.000,0)
WHEN MaLotNguyenLieu = 'WRKI00-001'  THEN  CAST(Weights AS FLOAT)/ NULLIF(0.000,0)
WHEN MaLotNguyenLieu = 'WRRA00-007'  THEN  CAST(Weights AS FLOAT)/ NULLIF(0.000,0)
WHEN MaLotNguyenLieu = 'WIRE00-013'  THEN  CAST(Weights AS FLOAT)/ NULLIF(0.000,0)
WHEN MaLotNguyenLieu = 'WRKI00-006'  THEN  CAST(Weights AS FLOAT)/ NULLIF(0.000,0)
WHEN MaLotNguyenLieu = 'CRF4T'  THEN  CAST(Weights AS FLOAT)/ NULLIF(0.000,0)
WHEN MaLotNguyenLieu = 'XX0011-008'  THEN  CAST(Weights AS FLOAT)/ NULLIF(0.000,0)
WHEN MaLotNguyenLieu = 'MDDW00-001'  THEN  CAST(Weights AS FLOAT)/ NULLIF(0.000,0)
WHEN MaLotNguyenLieu = 'VSBMD16-001'  THEN  CAST(Weights AS FLOAT)/ NULLIF(0.000,0)
WHEN MaLotNguyenLieu = 'VSCAN36-005'  THEN  CAST(Weights AS FLOAT)/ NULLIF(0.000,0)
WHEN MaLotNguyenLieu = 'Terminal-001'  THEN  CAST(Weights AS FLOAT)/ NULLIF(0.000,0)
--WHEN MaLotNguyenLieu = 'CRNCA5-002'  THEN  CAST(Weights AS FLOAT)/ 0.12598371777 ----------------------
WHEN MaLotNguyenLieu = 'CRNCA5-002'  THEN  CAST(Weights AS FLOAT)/ 125.98371777 ----------------------

--WHEN MaLotNguyenLieu = 'CRPSC0-002'  THEN  CAST(Weights AS FLOAT)/ 0.11033668044
WHEN MaLotNguyenLieu = 'CRPSC0-002'  THEN  CAST(Weights AS FLOAT)/ 110.33668044

WHEN MaLotNguyenLieu = 'SRECL85'  THEN  CAST(Weights AS FLOAT)/ NULLIF(0.000,0)
WHEN MaLotNguyenLieu = 'SRFCL85' THEN  CAST(Weights AS FLOAT)/ NULLIF(0.000,0)
WHEN MaLotNguyenLieu = 'SRECL85'  THEN  CAST(Weights AS FLOAT)/ NULLIF(0.000,0)
WHEN MaLotNguyenLieu = 'SRFCL85'  THEN  CAST(Weights AS FLOAT)/ NULLIF(0.000,0)
WHEN MaLotNguyenLieu = 'SRFCL85'  THEN  CAST(Weights AS FLOAT)/ NULLIF(0.000,0)
WHEN MaLotNguyenLieu = 'SRECL85'  THEN  CAST(Weights AS FLOAT)/ NULLIF(0.000,0)
WHEN MaLotNguyenLieu = 'CRLMA0-256'  THEN  CAST(Weights AS FLOAT)/ NULLIF(0.000,0)
WHEN MaLotNguyenLieu = 'CRLMA0-256'  THEN  CAST(Weights AS FLOAT)/ NULLIF(0.000,0)
WHEN MaLotNguyenLieu = 'CRLMA0-256'  THEN  CAST(Weights AS FLOAT)/ NULLIF(0.000,0)
WHEN MaLotNguyenLieu = 'CRLMA0-256'  THEN  CAST(Weights AS FLOAT)/ NULLIF(0.000,0)
--WHEN MaLotNguyenLieu = 'SRFMO83'  THEN  CAST(Weights AS FLOAT)/ NULLIF(0.000,0)
WHEN MaLotNguyenLieu = 'CRLMA0-256'  THEN  CAST(Weights AS FLOAT)/ NULLIF(0.000,0)
WHEN MaLotNguyenLieu = 'SREMO75'  THEN  (CAST(Weights AS FLOAT)/ 1000) * (400 /34)
--WHEN MaLotNguyenLieu = 'SRFMO83'  THEN  CAST(Weights AS FLOAT)/ NULLIF(0.000,0)
WHEN MaLotNguyenLieu = 'SREYO86'  THEN  CAST(Weights AS FLOAT)/ NULLIF(0.000,0)
WHEN MaLotNguyenLieu = 'CRECO85'  THEN  (CAST(Weights AS FLOAT)/ 1000) * (400 /33)
WHEN MaLotNguyenLieu = 'CRFCO85'  THEN  (CAST(Weights AS FLOAT)/ 1000) * (400 /33)
WHEN MaLotNguyenLieu = 'SRFYO85'  THEN  (CAST(Weights AS FLOAT)/ 1000) * (400 /35)
WHEN MaLotNguyenLieu = 'SRECO85'  THEN  CAST(Weights AS FLOAT)/ 1000 * (400 /33)
WHEN MaLotNguyenLieu = 'SRFCO85'  THEN  (CAST(Weights AS FLOAT)/ 1000) * (400 /33)
WHEN MaLotNguyenLieu = 'SRECL85'  THEN  (CAST(Weights AS FLOAT)/ 1000) * (400 /22)
WHEN MaLotNguyenLieu = 'SRFCL85'  THEN  (CAST(Weights AS FLOAT)/ 1000) * (400 /22)
WHEN MaLotNguyenLieu = 'SRFYK85' THEN  CAST(Weights AS FLOAT)/ 1000 * (400 /23)

--WHEN MaLotNguyenLieu = 'SREMO75'  THEN  CAST(Weights AS FLOAT)/ NULLIF(0.000,0)
WHEN MaLotNguyenLieu = 'SREMM75'  THEN  CAST(Weights AS FLOAT)/ NULLIF(0.000,0)
WHEN MaLotNguyenLieu = 'CRLMA0-256'  THEN  CAST(Weights AS FLOAT)/ NULLIF(0.000,0)
WHEN MaLotNguyenLieu = 'CRLMA0-256'  THEN  CAST(Weights AS FLOAT)/ NULLIF(0.000,0)
WHEN MaLotNguyenLieu = 'SREYK85'  THEN  (CAST(Weights AS FLOAT)/ 1000) * (350 /23) 
WHEN MaLotNguyenLieu = 'SREYO85'  THEN  (CAST(Weights AS FLOAT)/ 1000) * (400 /33)
WHEN MaLotNguyenLieu = 'CRECL85'  THEN  (CAST(Weights AS FLOAT)/ 1000) * (350 /22)
WHEN MaLotNguyenLieu = 'CRFCL85'  THEN  (CAST(Weights AS FLOAT)/ 1000) * (350 /22)
WHEN MaLotNguyenLieu = 'GCMDPT-383'  THEN  CAST(Weights AS FLOAT)/ 6.79
WHEN MaLotNguyenLieu = 'GCMDPT-218'  THEN  CAST(Weights AS FLOAT)/ 14.8
WHEN MaLotNguyenLieu = 'GBEC00-005'  THEN  CAST(Weights AS FLOAT)
WHEN MaLotNguyenLieu = 'GCMDPT-422'  THEN  CAST(Weights AS FLOAT)/ 6.79
WHEN MaLotNguyenLieu = 'GBAKAC-029'  THEN  CAST(Weights AS FLOAT)/ 3.885
WHEN MaLotNguyenLieu = 'GBAKAC-068'  THEN  CAST(Weights AS FLOAT)/ 3.885
WHEN MaLotNguyenLieu = 'GBAKAC-071'  THEN  CAST(Weights AS FLOAT)/ 0.6



-- theo c sao 29/06/24
WHEN MaLotNguyenLieu = 'CRFYN85'  THEN  CAST(Weights AS FLOAT)/ 73.6
WHEN MaLotNguyenLieu = 'CREBO85'  THEN  CAST(Weights AS FLOAT)/ 82.43
WHEN MaLotNguyenLieu = 'GBCP00-S06'  THEN  CAST(Weights AS FLOAT)/ 1
WHEN MaLotNguyenLieu = 'GBCP00-004'  THEN  (CAST(Weights AS FLOAT)/ 1)
WHEN MaLotNguyenLieu = 'GCMDPT-479'  THEN  CAST(Weights AS FLOAT)/ 5.06
WHEN MaLotNguyenLieu = 'GBRLAC-004'  THEN  CAST(Weights AS FLOAT)/ 0.6
WHEN MaLotNguyenLieu = 'GCMDPT-330'  THEN  CAST(Weights AS FLOAT)/ 5.06
WHEN MaLotNguyenLieu = 'GBNKSP-081'  THEN  CAST(Weights AS FLOAT)/ 15.3
WHEN MaLotNguyenLieu = 'GBNKSP-080'  THEN  CAST(Weights AS FLOAT)/ 15.3
WHEN MaLotNguyenLieu = 'GCMDPT-450'  THEN  CAST(Weights AS FLOAT)/ 5.06
WHEN MaLotNguyenLieu = 'GBHB00-S05'  THEN  CAST(Weights AS FLOAT)/ 0.19
WHEN MaLotNguyenLieu = 'GBNKSP-079'  THEN  CAST(Weights AS FLOAT)/ 25.7
WHEN MaLotNguyenLieu = 'GBAKAC-053'  THEN  CAST(Weights AS FLOAT)/ 0.6

----------------
WHEN MaLotNguyenLieu = 'SRFMO83' and Dates < '2024-06-01'  THEN  (CAST(Weights AS FLOAT)/ 1000) * (400 /34)
WHEN MaLotNguyenLieu = 'SREMO83' and Dates < '2024-06-01'   THEN  (CAST(Weights AS FLOAT)/1000) * (400 /34)
WHEN MaLotNguyenLieu = 'GBAKAC-071' and Dates < '2024-06-01'  THEN  CAST(Weights AS FLOAT)/ 0.6
-------------


WHEN MaLotNguyenLieu = 'GBAKAC-071'  and Dates >= '2024-06-01'  THEN  CAST(Weights AS FLOAT)/ 0.88
WHEN MaLotNguyenLieu = 'SREMO83'  and Dates >= '2024-06-01'  THEN  CAST(Weights AS FLOAT)/ 85.5
WHEN MaLotNguyenLieu = 'SRFMO83'  and Dates >= '2024-06-01'  THEN  CAST(Weights AS FLOAT)/ 84.5

-- theo yêu cầu chị phương
WHEN MaLotNguyenLieu = 'GCMDPT-469' then CAST(Weights AS FLOAT)/ 0.1240
WHEN MaLotNguyenLieu = 'GCMDPT-449'  THEN CAST(Weights AS FLOAT)/ 0.1240

-- 2025-07-30
WHEN MaLotNguyenLieu = 'GBNKSP-083' then CAST(Weights AS FLOAT)/ 12.02
WHEN MaLotNguyenLieu = 'GBRLAC-005'  THEN CAST(Weights AS FLOAT)/ 20.7
WHEN MaLotNguyenLieu = 'GCMDPT-507'  THEN CAST(Weights AS FLOAT)/ 15.11

-- 2025-08-22 - following Ms.Phương's request
WHEN MaLotNguyenLieu = 'GBCP00-002'  THEN 0


-- 2025-09-01 - following Ms.Phương's request
WHEN MaLotNguyenLieu = 'GBRLAC-004'  THEN (CAST(Weights AS FLOAT)/ 0.689)
WHEN MaLotNguyenLieu = 'GBLYAC-002'  THEN (CAST(Weights AS FLOAT)/ 0.5852) 
WHEN MaLotNguyenLieu = 'GBRLAC-006'  THEN 0
WHEN MaLotNguyenLieu = 'GBRLAC-007'  THEN (CAST(Weights AS FLOAT)/ 0.4989) 
WHEN MaLotNguyenLieu = 'GBRLAC-009'  THEN (CAST(Weights AS FLOAT)/ 1.335)
WHEN MaLotNguyenLieu = 'GBRLAC-012'  THEN (CAST(Weights AS FLOAT)/ 2.1206) 

-- 2026-01-06 - following Ms.Phương's request
WHEN MaLotNguyenLieu = 'GBNKSP-082'  THEN (CAST(Weights AS FLOAT)/ 36.39)

-- 20260407 -Nguyenduc dev by Mr Huan req
WHEN MaLotNguyenLieu = 'ECVT30-357'  THEN (CAST(Weights AS FLOAT)/ 20.7)


ELSE 0.000

END AS Can_Nang_Moi,
					
CASE

WHEN MaLotNguyenLieu = 'GBNKSP-054'  THEN  (CAST(Weights AS FLOAT)/ 25.7) * 1.31
WHEN MaLotNguyenLieu = 'GBNKSP-057'  THEN  (CAST(Weights AS FLOAT)/ 25.7) * 1.31
WHEN MaLotNguyenLieu = 'GBNKSP-063'  THEN  (CAST(Weights AS FLOAT)/ 15.3) * 1.31
WHEN MaLotNguyenLieu = 'GBNKSP-059'  THEN  (CAST(Weights AS FLOAT)/ 15.3) * 0.8
WHEN MaLotNguyenLieu = 'GBNKSP-065'  THEN  (CAST(Weights AS FLOAT)/ 15.3) * 0.8
WHEN MaLotNguyenLieu = 'GBNKSP-066' THEN  (CAST(Weights AS FLOAT)/ 15.3) * 0.8
WHEN MaLotNguyenLieu = 'GBNKSP-074'  THEN  (CAST(Weights AS FLOAT)/ 15.3) * 1.517692
WHEN MaLotNguyenLieu = 'GBNKSP-060'  THEN  (CAST(Weights AS FLOAT)/ 15.3) * 0.8
WHEN MaLotNguyenLieu = 'GBNKSP-061'  THEN  (CAST(Weights AS FLOAT)/ 15.3) * 0.8
WHEN MaLotNguyenLieu = 'GBNKSP-067'  THEN  (CAST(Weights AS FLOAT)/ 15.3) * 0.8
WHEN MaLotNguyenLieu = 'GBNKSP-068'  THEN  (CAST(Weights AS FLOAT)/ 15.3) * 0.8
WHEN MaLotNguyenLieu = 'GBNKSP-S02'  THEN  (CAST(Weights AS FLOAT)/ 15.3) * 1.1
WHEN MaLotNguyenLieu = 'GBNKSP-069' THEN  (CAST(Weights AS FLOAT)/ 15.3) * 0.8
WHEN MaLotNguyenLieu = 'GBNKSP-070'  THEN  (CAST(Weights AS FLOAT)/ 15.3) * 0.8
WHEN MaLotNguyenLieu = 'GBNKSP-072'  THEN  (CAST(Weights AS FLOAT)/ 15.3) * 0.8
WHEN MaLotNguyenLieu = 'GBNKSP-071'  THEN  (CAST(Weights AS FLOAT)/ 15.3) * 0.8
WHEN MaLotNguyenLieu = 'GBNKSP-058' THEN  (CAST(Weights AS FLOAT)/ 15.3) * 1.31
WHEN MaLotNguyenLieu = 'GBNKSP-062'  THEN  (CAST(Weights AS FLOAT)/ 15.3) * 0.8
WHEN MaLotNguyenLieu = 'GBEC00-002'  THEN  (CAST(Weights AS FLOAT)/ NULLIF(0.000,0)) * 23.91
WHEN MaLotNguyenLieu = 'GBCP00-002'  THEN  (CAST(Weights AS FLOAT)/ NULLIF(0.000,0)) * 9 
WHEN MaLotNguyenLieu = 'GBCP00-001'  THEN  (CAST(Weights AS FLOAT)/ 1) * 11.32       
--WHEN MaLotNguyenLieu = 'GBEC00-008' THEN  (CAST(Weights AS FLOAT)/ NULLIF(0.000,0)) * 11.63  --------------------------
WHEN MaLotNguyenLieu = 'GBEC00-008' THEN  (CAST(Weights AS FLOAT)/ 1) *  12.80  --------------------------
WHEN MaLotNguyenLieu = 'GBSN00-005'  THEN  (CAST(Weights AS FLOAT)/ 0.2) * 0.00288
WHEN MaLotNguyenLieu = 'GBSN00-005'  THEN  (CAST(Weights AS FLOAT)/ 0.2) * 0.00273
WHEN MaLotNguyenLieu = 'GBSN00-004'  THEN  (CAST(Weights AS FLOAT)/ 0.4) * 0.0044
WHEN MaLotNguyenLieu = 'GBSN00-001'  THEN  (CAST(Weights AS FLOAT)/ 0.9) * 0.00736
WHEN MaLotNguyenLieu = 'GBSN00-002'  THEN  (CAST(Weights AS FLOAT)/ 1.3) * 0.01472
WHEN MaLotNguyenLieu = 'GBSN00-006'  THEN  (CAST(Weights AS FLOAT)/ 1.8) * 0.01579
WHEN MaLotNguyenLieu = 'GBSN00-003'  THEN  (CAST(Weights AS FLOAT)/ 1.8) * 0.01579
WHEN MaLotNguyenLieu = 'GCMTTT-012'  THEN  (CAST(Weights AS FLOAT)/ 2.077) * 0.1306
WHEN MaLotNguyenLieu = 'GCTN00-S01'  THEN  (CAST(Weights AS FLOAT)/ 2.077) * 0.113624
WHEN MaLotNguyenLieu = 'GCMTTT-013'  THEN  (CAST(Weights AS FLOAT)/ 2.11) * 0.184
WHEN MaLotNguyenLieu = 'GCMTTT-002'  THEN  (CAST(Weights AS FLOAT)/ 2.581) * 0.1669
WHEN MaLotNguyenLieu = 'GCTN00-002'  THEN  (CAST(Weights AS FLOAT)/ 6.15) * 0.276759
WHEN MaLotNguyenLieu = 'GCMTTT-023'  THEN  (CAST(Weights AS FLOAT)/ 61.5) * 0.3893
WHEN MaLotNguyenLieu = 'GCMTTT-024'  THEN  (CAST(Weights AS FLOAT)/ 6.15) * 0.43897
WHEN MaLotNguyenLieu = 'GBHB00-036'  THEN  (CAST(Weights AS FLOAT)/ 0.1) * 0.00191
WHEN MaLotNguyenLieu = 'GBHB00-035'  THEN  (CAST(Weights AS FLOAT)/ 0.09) * 0.00175
WHEN MaLotNguyenLieu = 'GBHB00-033'  THEN  (CAST(Weights AS FLOAT)/ 0.1) * 0.00224
WHEN MaLotNguyenLieu = 'GBHB00-034'  THEN  (CAST(Weights AS FLOAT)/ 0.09) * 0.00209
WHEN MaLotNguyenLieu = 'GBHB00-031'  THEN  (CAST(Weights AS FLOAT)/ 0.14) * 0.00271
WHEN MaLotNguyenLieu = 'GBHB00-032'  THEN  (CAST(Weights AS FLOAT)/ 0.13) * 0.00262
WHEN MaLotNguyenLieu = 'GBYCTT-002'  THEN  (CAST(Weights AS FLOAT)/ 0.13) * 0.013056615
WHEN MaLotNguyenLieu = 'GBYCTT-003'  THEN  (CAST(Weights AS FLOAT)/ 0.13) * 0.00338843
WHEN MaLotNguyenLieu = 'GBHB00-043'  THEN  (CAST(Weights AS FLOAT)/ 0.19) * 0.00363
WHEN MaLotNguyenLieu = 'GBHB00-042'  THEN  (CAST(Weights AS FLOAT)/ 0.17) * 0.00338
--WHEN MaLotNguyenLieu = 'GCSAAT-001'  THEN  (CAST(Weights AS FLOAT)/ 0.196) * 0.038933
WHEN MaLotNguyenLieu = 'GCSAAT-001'  THEN  (CAST(Weights AS FLOAT)/ 2.78) * 0.038933
WHEN MaLotNguyenLieu = 'GCSN00-001'  THEN  (CAST(Weights AS FLOAT)/ 0.172) * 0.00471
WHEN MaLotNguyenLieu = 'GCSN00-003'  THEN  (CAST(Weights AS FLOAT)/ 0.223) * 0.00938
WHEN MaLotNguyenLieu = 'GCSN00-002'  THEN  (CAST(Weights AS FLOAT)/ 0.421) * 0.00941
WHEN MaLotNguyenLieu = 'GBAKAC-062'  THEN  (CAST(Weights AS FLOAT)/ 0.306) * 0.00251596
WHEN MaLotNguyenLieu = 'GBAKAC-S06' THEN  (CAST(Weights AS FLOAT)/ 0.161) * 0.001876825
WHEN MaLotNguyenLieu = 'GBAKAC-059'  THEN  (CAST(Weights AS FLOAT)/ 0.2) * 0.00209
WHEN MaLotNguyenLieu = 'GBAKAC-060'  THEN  (CAST(Weights AS FLOAT)/ 0.4) *  0.00252
WHEN MaLotNguyenLieu = 'GBAKAC-052'  THEN  (CAST(Weights AS FLOAT)/ 0.4) * 0.00418
WHEN MaLotNguyenLieu = 'GRAKAC-065'  THEN  (CAST(Weights AS FLOAT)/ 0.4) * 0.00432
WHEN MaLotNguyenLieu = 'GBAKAC-032'  THEN  (CAST(Weights AS FLOAT)/ 0.4) * 0.00698
WHEN MaLotNguyenLieu = 'GBAKAC-051'  THEN  (CAST(Weights AS FLOAT)/ 0.4) * 0.00347

WHEN MaLotNguyenLieu = 'GBAKAC-048'  THEN  (CAST(Weights AS FLOAT)/ 0.6) * 0.00683
WHEN MaLotNguyenLieu = 'GBAKAC-004'  THEN  (CAST(Weights AS FLOAT)/ 0.6) * 0.00966
WHEN MaLotNguyenLieu = 'GBAKAC-054'  THEN  (CAST(Weights AS FLOAT)/ 0.76) * 0.00744
WHEN MaLotNguyenLieu = 'GBAKAC-039'  THEN  (CAST(Weights AS FLOAT)/ 0.88) * 0.00825
WHEN MaLotNguyenLieu = 'GBAKAC-064'  THEN  (CAST(Weights AS FLOAT)/ 1.627) * 0.01813
WHEN MaLotNguyenLieu = 'GBAKAC-005'  THEN  (CAST(Weights AS FLOAT)/ 1.33) * 0.01036
WHEN MaLotNguyenLieu = 'GBAKAC-S03'  THEN  (CAST(Weights AS FLOAT)/ 3.296) * 0.00251596
WHEN MaLotNguyenLieu = 'GBAKAC-S09'  THEN  (CAST(Weights AS FLOAT)/ 1.974) * 0.035
WHEN MaLotNguyenLieu = 'GBAKAC-063'  THEN  (CAST(Weights AS FLOAT)/ 2.51) * 0.01682
WHEN MaLotNguyenLieu = 'GBAKAC-036'  THEN  (CAST(Weights AS FLOAT)/ 3.338) * 0.03604
WHEN MaLotNguyenLieu = 'GBAKAC-068' THEN  (CAST(Weights AS FLOAT)/ 3.885)  * 0.02824
WHEN MaLotNguyenLieu = 'GBAKAC-V01'  THEN  (CAST(Weights AS FLOAT)/ 3.602) * 0.0318
WHEN MaLotNguyenLieu = 'GBAKAC-066'  THEN  (CAST(Weights AS FLOAT)/ 6.58) * 0.08459
WHEN MaLotNguyenLieu = 'GBAKAC-037'  THEN  (CAST(Weights AS FLOAT)/ 14.363) * 0.1464
WHEN MaLotNguyenLieu = 'GBAKAC-043'  THEN  (CAST(Weights AS FLOAT)/ 15.156) * 0.16008
WHEN MaLotNguyenLieu = 'GBAKAC-038'  THEN  (CAST(Weights AS FLOAT)/ 16.121) * 0.2257
WHEN MaLotNguyenLieu = 'GBAKAC-033'  THEN  (CAST(Weights AS FLOAT)/ 18.041) * 0.20667
WHEN MaLotNguyenLieu = 'GCMDPT-S04' THEN  (CAST(Weights AS FLOAT)/ 3.6) * 0.061
WHEN MaLotNguyenLieu = 'GCMDPT-476' THEN  (CAST(Weights AS FLOAT)/ 3.6) * 0.061
WHEN MaLotNguyenLieu = 'GCMDPT-200' THEN  (CAST(Weights AS FLOAT)/ 3.6) * 0.094
WHEN MaLotNguyenLieu = 'GCMDPT-421' THEN  (CAST(Weights AS FLOAT)/ 3.6) * 0.094
WHEN MaLotNguyenLieu = 'GCMDPT-358' THEN  (CAST(Weights AS FLOAT)/ 3.6) * 0.094
WHEN MaLotNguyenLieu = 'GCMDPT-379' THEN  (CAST(Weights AS FLOAT)/ 3.6) * 0.094
WHEN MaLotNguyenLieu = 'GCMDPT-473' THEN  (CAST(Weights AS FLOAT)/ 3.6) * 0.089276
WHEN MaLotNguyenLieu = 'GCMDPT-382' THEN  (CAST(Weights AS FLOAT)/ 3.6) * 0.094
WHEN MaLotNguyenLieu = 'GCMDPT-216' THEN  (CAST(Weights AS FLOAT)/ 3.6) * 0.094
WHEN MaLotNguyenLieu = 'GCMDPT-201' THEN  (CAST(Weights AS FLOAT)/ 3.6) * 0.094
WHEN MaLotNguyenLieu = 'GCMDPT-393' THEN  (CAST(Weights AS FLOAT)/ 3.6) * 0.094
WHEN MaLotNguyenLieu = 'GCMDPT-196'  THEN  (CAST(Weights AS FLOAT)/ 3.6) * 0.094
WHEN MaLotNguyenLieu = 'GCMDPT-298'  THEN  (CAST(Weights AS FLOAT)/ 3.6) * 0.094
WHEN MaLotNguyenLieu = 'GCMDPT-419' THEN  (CAST(Weights AS FLOAT)/ 3.6) * 0.094
WHEN MaLotNguyenLieu = 'GCMDPT-475'  THEN  (CAST(Weights AS FLOAT)/ 3.6) * 0.094
WHEN MaLotNguyenLieu = 'GCMDPT-369'  THEN  (CAST(Weights AS FLOAT)/ 3.6) * 0.094
WHEN MaLotNguyenLieu = 'GCMDPT-416'  THEN  (CAST(Weights AS FLOAT)/ 3.6) * 0.094
WHEN MaLotNguyenLieu = 'GCMDPT-197'  THEN  (CAST(Weights AS FLOAT)/ 5.06) * 0.098
WHEN MaLotNguyenLieu = 'GCMDPT-198'  THEN  (CAST(Weights AS FLOAT)/ 5.06) * 0.098
WHEN MaLotNguyenLieu = 'GCMDPT-275'  THEN  (CAST(Weights AS FLOAT)/ 5.06) * 0.098
WHEN MaLotNguyenLieu = 'GCMDPT-409'  THEN  (CAST(Weights AS FLOAT)/ 5.06) * 0.098
WHEN MaLotNguyenLieu = 'GCMDPT-340'  THEN  (CAST(Weights AS FLOAT)/ 5.06) * 0.098
WHEN MaLotNguyenLieu = 'GCMDPT-408'  THEN  (CAST(Weights AS FLOAT)/ 5.06) * 0.13847925
WHEN MaLotNguyenLieu = 'GCMDPT-391'  THEN  (CAST(Weights AS FLOAT)/ 5.06) * 0.098
WHEN MaLotNguyenLieu = 'GCMDPT-259'  THEN  (CAST(Weights AS FLOAT)/ 5.06) * 0.098
WHEN MaLotNguyenLieu = 'GCMDPT-256'  THEN  (CAST(Weights AS FLOAT)/ 5.06) * 0.098
WHEN MaLotNguyenLieu = 'GCMDPT-406'  THEN  (CAST(Weights AS FLOAT)/ 5.06) * 0.098
WHEN MaLotNguyenLieu = 'GCMDPT-391'  THEN  (CAST(Weights AS FLOAT)/ 5.06) * 0.098
WHEN MaLotNguyenLieu = 'GCMDPT-386'  THEN  (CAST(Weights AS FLOAT)/ 5.06) * 0.098
WHEN MaLotNguyenLieu = 'GCMDPT-202' THEN  (CAST(Weights AS FLOAT)/ 5.06) * 0.098
WHEN MaLotNguyenLieu = 'GCMDPT-220' THEN  (CAST(Weights AS FLOAT)/ 5.06) * 0.098
WHEN MaLotNguyenLieu = 'GCMDPT-265'  THEN  (CAST(Weights AS FLOAT)/ 5.06) * 0.098
WHEN MaLotNguyenLieu = 'GCMDPT-399' THEN  (CAST(Weights AS FLOAT)/ 5.06) * 0.098
WHEN MaLotNguyenLieu = 'GCMDPT-380'  THEN  (CAST(Weights AS FLOAT)/ 5.06) * 0.098
WHEN MaLotNguyenLieu = 'GCMDPT-459' THEN  (CAST(Weights AS FLOAT)/ 5.06) * 0.098
WHEN MaLotNguyenLieu = 'GCMDPT-211'  THEN  (CAST(Weights AS FLOAT)/ 5.06) * 0.098
WHEN MaLotNguyenLieu = 'GCMDPT-452'  THEN  (CAST(Weights AS FLOAT)/ 5.06) * 0.093334
WHEN MaLotNguyenLieu = 'GCMDPT-288'  THEN  (CAST(Weights AS FLOAT)/ 5.54) * 0.134
WHEN MaLotNguyenLieu = 'GCMDPT-420'  THEN  (CAST(Weights AS FLOAT)/ 5.54) * 0.134
WHEN MaLotNguyenLieu = 'GCMDPT-424'  THEN  (CAST(Weights AS FLOAT)/ 5.54) * 0.134
WHEN MaLotNguyenLieu = 'GCMDPT-223'  THEN  (CAST(Weights AS FLOAT)/ 5.54) * 0.134
WHEN MaLotNguyenLieu = 'GCMDPT-371'  THEN  (CAST(Weights AS FLOAT)/ 5.54) * 0.1908
WHEN MaLotNguyenLieu = 'GCMDPT-442'  THEN  (CAST(Weights AS FLOAT)/ 5.54) * 0.134
WHEN MaLotNguyenLieu = 'GCMDPT-384'  THEN  (CAST(Weights AS FLOAT)/ 5.54) * 0.134
WHEN MaLotNguyenLieu = 'GCMDPT-392'  THEN  (CAST(Weights AS FLOAT)/ 5.54) * 0.134
WHEN MaLotNguyenLieu = 'GCMDPT-227'  THEN  (CAST(Weights AS FLOAT)/ 5.54) * 0.134
WHEN MaLotNguyenLieu = 'GCMDPT-204'  THEN  (CAST(Weights AS FLOAT)/ 5.54) * 0.134
WHEN MaLotNguyenLieu = 'GCMDPT-365'  THEN  (CAST(Weights AS FLOAT)/ 5.54) * 0.134
WHEN MaLotNguyenLieu = 'GCMDPT-301'  THEN  (CAST(Weights AS FLOAT)/ 5.54) * 0.134
WHEN MaLotNguyenLieu = 'GCMDPT-320' THEN  (CAST(Weights AS FLOAT)/ 5.54) * 0.152175
WHEN MaLotNguyenLieu = 'GCMDPT-208'  THEN  (CAST(Weights AS FLOAT)/ 6.79) * 0.168
WHEN MaLotNguyenLieu = 'GCMDPT-240'  THEN  (CAST(Weights AS FLOAT)/ 6.79) * 0.168
WHEN MaLotNguyenLieu = 'GCMDPT-504'  THEN  (CAST(Weights AS FLOAT)/ 6.79) * 0.190726
WHEN MaLotNguyenLieu = 'GCMDPT-471'  THEN  (CAST(Weights AS FLOAT)/ 6.79) * 0.170436
WHEN MaLotNguyenLieu = 'GCMDPT-376'  THEN  (CAST(Weights AS FLOAT)/ 8.1) * 0.2369
WHEN MaLotNguyenLieu = 'GCMDPT-199'  THEN  (CAST(Weights AS FLOAT)/ 8.1) * 0.182
WHEN MaLotNguyenLieu = 'GCMDPT-404'  THEN (CAST(Weights AS FLOAT)/ 8.1) * 0.182
WHEN MaLotNguyenLieu = 'GCMDPT-388'  THEN  (CAST(Weights AS FLOAT)/ 8.1) * 0.182
WHEN MaLotNguyenLieu = 'GCMDPT-210'  THEN  (CAST(Weights AS FLOAT)/ 8.1) * 0.182
WHEN MaLotNguyenLieu = 'GCMDPT-249'  THEN  (CAST(Weights AS FLOAT)/ 8.1) * 0.182
WHEN MaLotNguyenLieu = 'GCMDPT-276'  THEN  (CAST(Weights AS FLOAT)/ 8.1) * 0.182
WHEN MaLotNguyenLieu = 'GCMDPT-308'  THEN  (CAST(Weights AS FLOAT)/ 8.1) * 0.182
WHEN MaLotNguyenLieu = 'GCMDPT-370'  THEN  (CAST(Weights AS FLOAT)/ 8.1) * 0.182
WHEN MaLotNguyenLieu = 'GCMDPT-242'  THEN  (CAST(Weights AS FLOAT)/ 9.6) * 0.261
WHEN MaLotNguyenLieu = 'GCMDPT-277'  THEN  (CAST(Weights AS FLOAT)/ 9.6) * 0.261
WHEN MaLotNguyenLieu = 'GCMDPT-262'  THEN  (CAST(Weights AS FLOAT)/ 9.6) * 0.261
WHEN MaLotNguyenLieu = 'GCMDPT-258'  THEN  (CAST(Weights AS FLOAT)/ 9.6) * 0.261
WHEN MaLotNguyenLieu = 'GCMDPT-368'  THEN  (CAST(Weights AS FLOAT)/ 9.6) * 0.261
WHEN MaLotNguyenLieu = 'GCMDPT-253'  THEN  (CAST(Weights AS FLOAT)/ 10.8) * 0.3967
WHEN MaLotNguyenLieu = 'GCMDPT-407'  THEN  (CAST(Weights AS FLOAT)/ 10.8) * 0.281
WHEN MaLotNguyenLieu = 'GCMDPT-218'  THEN  (CAST(Weights AS FLOAT)/ 14.8) * 0.339
WHEN MaLotNguyenLieu = 'GCMDPT-285' THEN  (CAST(Weights AS FLOAT)/ 14.8) * 0.38551
WHEN MaLotNguyenLieu = 'GCMDPT-243'  THEN  (CAST(Weights AS FLOAT)/ 14.8) * 0.339
WHEN MaLotNguyenLieu = 'GCMDPT-435'  THEN  (CAST(Weights AS FLOAT)/ 14.8) * 0.339
WHEN MaLotNguyenLieu = 'GCMDPT-427'  THEN  (CAST(Weights AS FLOAT)/ 14.8) * 0.339
WHEN MaLotNguyenLieu = 'GCMDPT-353'  THEN  (CAST(Weights AS FLOAT)/ 15.7) * 0.339
WHEN MaLotNguyenLieu = 'GCMDPT-443'  THEN  (CAST(Weights AS FLOAT)/ 15.7) * 0.339
WHEN MaLotNguyenLieu = 'GCMDPT-362'  THEN  (CAST(Weights AS FLOAT)/ 14.5) * 0.339
WHEN MaLotNguyenLieu = 'GCMDPT-465' THEN  (CAST(Weights AS FLOAT)/ 14.8) * 0.38
WHEN MaLotNguyenLieu = 'GBRBPL-001'  THEN  (CAST(Weights AS FLOAT)/ NULLIF(0.000,0)) * 0.018261
WHEN MaLotNguyenLieu = 'GBRBPL-002' THEN  (CAST(Weights AS FLOAT)/ NULLIF(0.000,0)) * 0.0273915
WHEN MaLotNguyenLieu = 'GBRBPL-003' THEN  (CAST(Weights AS FLOAT)/ NULLIF(0.000,0)) * 0.052754
WHEN MaLotNguyenLieu = 'REELTAPE055T' THEN  (CAST(Weights AS FLOAT)/ NULLIF(0.000,0)) * 0.0164
WHEN MaLotNguyenLieu = 'REEL-TAPE'  THEN  (CAST(Weights AS FLOAT)/ NULLIF(0.000,0)) * 0.0109
WHEN MaLotNguyenLieu = 'REEL-TAPEM' THEN  (CAST(Weights AS FLOAT)/ NULLIF(0.000,0)) * 0.0175
WHEN MaLotNguyenLieu = 'GCTN00-003' THEN  (CAST(Weights AS FLOAT)/ NULLIF(0.000,0)) * 0.0015
WHEN MaLotNguyenLieu = 'GCMDPT-387'  THEN  (CAST(Weights AS FLOAT)/ NULLIF(0.000,0))  * 0.135
WHEN MaLotNguyenLieu = 'GCMDPT-205'  THEN  (CAST(Weights AS FLOAT)/ NULLIF(0.000,0))  * 0.135
WHEN MaLotNguyenLieu = 'GCMDPT-432'  THEN  (CAST(Weights AS FLOAT)/ NULLIF(0.000,0))  * 0.135
WHEN MaLotNguyenLieu = 'GCMDPT-355'  THEN  (CAST(Weights AS FLOAT)/ NULLIF(0.000,0))  * 0.135
WHEN MaLotNguyenLieu = 'GCMDPT-254'  THEN  (CAST(Weights AS FLOAT)/ NULLIF(0.000,0))  * 0.135
WHEN MaLotNguyenLieu = 'GCMDPT-431'  THEN  (CAST(Weights AS FLOAT)/ NULLIF(0.000,0))  * 0.135
WHEN MaLotNguyenLieu = 'GCMDPT-394'  THEN  (CAST(Weights AS FLOAT)/ NULLIF(0.000,0))  * 0.135
WHEN MaLotNguyenLieu = 'GCMDPT-348'  THEN  (CAST(Weights AS FLOAT)/ NULLIF(0.000,0))  * 0.3393
WHEN MaLotNguyenLieu = 'GCMDPT-283'  THEN  (CAST(Weights AS FLOAT)/ NULLIF(0.000,0))  * 0.3174
WHEN MaLotNguyenLieu = 'GCMDPT-206'  THEN  (CAST(Weights AS FLOAT)/ NULLIF(0.000,0))  * 0.135
WHEN MaLotNguyenLieu = 'GCMDPT-434'  THEN  (CAST(Weights AS FLOAT)/ NULLIF(0.000,0))  * 0.135
WHEN MaLotNguyenLieu = 'GCMDPT-207'  THEN  (CAST(Weights AS FLOAT)/ NULLIF(0.000,0))  * 0.135
WHEN MaLotNguyenLieu = 'GCMDPT-309'  THEN  (CAST(Weights AS FLOAT)/ NULLIF(0.000,0))  * 0.168
WHEN MaLotNguyenLieu = 'GCMDPT-245'  THEN  (CAST(Weights AS FLOAT)/ NULLIF(0.000,0))  * 0.168
WHEN MaLotNguyenLieu = 'GCMDPT-292'  THEN  (CAST(Weights AS FLOAT)/ NULLIF(0.000,0))  * 0.168
WHEN MaLotNguyenLieu = 'GCMDPT-467'  THEN  (CAST(Weights AS FLOAT)/ NULLIF(0.000,0))  * 0.2425
WHEN MaLotNguyenLieu = 'GCMDPT-413'  THEN  (CAST(Weights AS FLOAT)/ NULLIF(0.000,0))  * 0.2429
WHEN MaLotNguyenLieu = 'GCMDPT-209'  THEN  (CAST(Weights AS FLOAT)/ NULLIF(0.000,0))  * 0.168
WHEN MaLotNguyenLieu = 'GCMDPT-385'  THEN  (CAST(Weights AS FLOAT)/ NULLIF(0.000,0))  * 0.168
WHEN MaLotNguyenLieu = 'GCMDPT-292'  THEN  (CAST(Weights AS FLOAT)/ NULLIF(0.000,0))  * 0.168
WHEN MaLotNguyenLieu = 'GCMDPT-441'  THEN  (CAST(Weights AS FLOAT)/ NULLIF(0.000,0))  * 0.168
WHEN MaLotNguyenLieu = 'GCMDPT-282'  THEN  (CAST(Weights AS FLOAT)/ NULLIF(0.000,0))  * 0.168
WHEN MaLotNguyenLieu = 'GCMDPT-381'  THEN  (CAST(Weights AS FLOAT)/ NULLIF(0.000,0))  * 0.168
WHEN MaLotNguyenLieu = 'GCMDPT-319'  THEN  (CAST(Weights AS FLOAT)/ NULLIF(0.000,0))  * 0.168
WHEN MaLotNguyenLieu = 'GCMDPT-397'  THEN  (CAST(Weights AS FLOAT)/ NULLIF(0.000,0))  * 0.2374
WHEN MaLotNguyenLieu = 'GCMDPT-445'  THEN  (CAST(Weights AS FLOAT)/ NULLIF(0.000,0))  * 0.168
WHEN MaLotNguyenLieu = 'GCMDPT-440'  THEN  (CAST(Weights AS FLOAT)/ NULLIF(0.000,0))  * 0.168
WHEN MaLotNguyenLieu = 'GCMDPT-284'  THEN  (CAST(Weights AS FLOAT)/ NULLIF(0.000,0))  * 0.168
WHEN MaLotNguyenLieu = 'GCMDPT-279'  THEN  (CAST(Weights AS FLOAT)/ NULLIF(0.000,0))  * 0.168
WHEN MaLotNguyenLieu = 'GCMDPT-423'  THEN  (CAST(Weights AS FLOAT)/ NULLIF(0.000,0))  * 0.281
WHEN MaLotNguyenLieu = 'GCMDPT-412'  THEN  (CAST(Weights AS FLOAT)/ NULLIF(0.000,0))  * 0.168
WHEN MaLotNguyenLieu = 'GCMDPT-425'  THEN  (CAST(Weights AS FLOAT)/ NULLIF(0.000,0))  * 0.226
WHEN MaLotNguyenLieu = 'GCMDPT-425'  THEN  (CAST(Weights AS FLOAT)/ NULLIF(0.000,0))  * 0.226
WHEN MaLotNguyenLieu = 'GCMDPT-252'  THEN  (CAST(Weights AS FLOAT)/ NULLIF(0.000,0))  * 0.226
WHEN MaLotNguyenLieu = 'GCMDPT-345'  THEN  (CAST(Weights AS FLOAT)/ NULLIF(0.000,0))  * 0.226
WHEN MaLotNguyenLieu = 'GCMDPT-439'  THEN  (CAST(Weights AS FLOAT)/ NULLIF(0.000,0))  * 0.226
WHEN MaLotNguyenLieu = 'GCMDPT-S01' THEN  (CAST(Weights AS FLOAT)/ NULLIF(0.000,0))	  * 0.3642055
WHEN MaLotNguyenLieu = 'GCMDPT-250'  THEN  (CAST(Weights AS FLOAT)/ NULLIF(0.000,0))  * 0.391
WHEN MaLotNguyenLieu = 'GCMDPT-212'  THEN  (CAST(Weights AS FLOAT)/ NULLIF(0.000,0))  * 0.438
WHEN MaLotNguyenLieu = 'GCMDPT-417'  THEN  (CAST(Weights AS FLOAT)/ NULLIF(0.000,0))  * 0.32
WHEN MaLotNguyenLieu = 'WRKI00-012'  THEN  (CAST(Weights AS FLOAT)/ NULLIF(0.000,0)) * 0.5873955
WHEN MaLotNguyenLieu = 'WIRE00-002'  THEN  (CAST(Weights AS FLOAT)/ NULLIF(0.000,0)) * 0.1876825
WHEN MaLotNguyenLieu = 'WRHI00-001' THEN  (CAST(Weights AS FLOAT)/ NULLIF(0.000,0)) * 0.1002326
WHEN MaLotNguyenLieu = 'WRKI00-002' THEN  (CAST(Weights AS FLOAT)/ NULLIF(0.000,0)) * 0.197
WHEN MaLotNguyenLieu = 'WRHI00-002'  THEN  (CAST(Weights AS FLOAT)/ NULLIF(0.000,0)) * 0.09810215
WHEN MaLotNguyenLieu = 'WIRE00-003'  THEN  (CAST(Weights AS FLOAT)/ NULLIF(0.000,0)) * 0.1998565
WHEN MaLotNguyenLieu = 'WRKI00-003'  THEN  (CAST(Weights AS FLOAT)/ NULLIF(0.000,0)) * 0.579
WHEN MaLotNguyenLieu = 'WRKI00-001'  THEN  (CAST(Weights AS FLOAT)/ NULLIF(0.000,0)) * 0.197
WHEN MaLotNguyenLieu = 'WRRA00-007'  THEN  (CAST(Weights AS FLOAT)/ NULLIF(0.000,0)) * 0.232
WHEN MaLotNguyenLieu = 'WIRE00-013'  THEN  (CAST(Weights AS FLOAT)/ NULLIF(0.000,0)) * 0.257
WHEN MaLotNguyenLieu = 'WRKI00-006'  THEN  (CAST(Weights AS FLOAT)/ NULLIF(0.000,0)) * 0.22319
WHEN MaLotNguyenLieu = 'CRF4T'  THEN  (CAST(Weights AS FLOAT)/ NULLIF(0.000,0)) * 0.0958
WHEN MaLotNguyenLieu = 'XX0011-008'  THEN  (CAST(Weights AS FLOAT)/ NULLIF(0.000,0))  * 0.51304347826087
WHEN MaLotNguyenLieu = 'MDDW00-001'  THEN  (CAST(Weights AS FLOAT)/ NULLIF(0.000,0)) * 1.08764545
WHEN MaLotNguyenLieu = 'VSBMD16-001' THEN  (CAST(Weights AS FLOAT)/ NULLIF(0.000,0))  * 0.364565217391304
WHEN MaLotNguyenLieu = 'VSCAN36-005' THEN  (CAST(Weights AS FLOAT)/ NULLIF(0.000,0))  * 0.0717391304347826
WHEN MaLotNguyenLieu = 'Terminal-001' THEN  (CAST(Weights AS FLOAT)/ NULLIF(0.000,0))  * 0.118
--WHEN MaLotNguyenLieu = 'CRNCA5-002'   THEN  (CAST(Weights AS FLOAT)/ 0.12598371777)  * 8.2 ------------------------
WHEN MaLotNguyenLieu = 'CRNCA5-002'   THEN  (CAST(Weights AS FLOAT)/ 125.98371777)  * 8.2 ------------------------
--WHEN MaLotNguyenLieu = 'CRPSC0-002'   THEN  (CAST(Weights AS FLOAT)/ 0.11033668044)  * 5 -----------------------
WHEN MaLotNguyenLieu = 'CRPSC0-002'   THEN  (CAST(Weights AS FLOAT)/ 110.33668044)  * 5 -----------------------

WHEN MaLotNguyenLieu = 'SRECL85'  THEN  (CAST(Weights AS FLOAT)/ NULLIF(0.000,0))  * 1.94074243384809
WHEN MaLotNguyenLieu = 'SRFCL85'  THEN  (CAST(Weights AS FLOAT)/ NULLIF(0.000,0))  * 1.79693705884809
WHEN MaLotNguyenLieu = 'SRECL85'  THEN  (CAST(Weights AS FLOAT)/ NULLIF(0.000,0))  * 1.94074243384809
WHEN MaLotNguyenLieu = 'SRFCL85'  THEN  (CAST(Weights AS FLOAT)/ NULLIF(0.000,0))  * 1.79693705884809
WHEN MaLotNguyenLieu = 'SRFCL85'  THEN  (CAST(Weights AS FLOAT)/ NULLIF(0.000,0))  * 1.79693705884809
WHEN MaLotNguyenLieu = 'SRECL85'  THEN  (CAST(Weights AS FLOAT)/ NULLIF(0.000,0))  * 1.89331599047119
WHEN MaLotNguyenLieu = 'CRLMA0-256' THEN  (CAST(Weights AS FLOAT)/ 104)  * 3.150


--WHEN MaLotNguyenLieu = 'SREMO83'  THEN  ((CAST(Weights AS FLOAT)/1000) * (400 /34))  * 4.30845842151965


--WHEN MaLotNguyenLieu = 'SREMO75'  THEN  (CAST(Weights AS FLOAT)/ NULLIF(0.000,0))  * 1.89331599047119
--WHEN MaLotNguyenLieu = 'SRFMO83'  THEN  (CAST(Weights AS FLOAT)/ NULLIF(0.000,0))  * 1.89331599047119
WHEN MaLotNguyenLieu = 'SREYO86' THEN  (CAST(Weights AS FLOAT)/ NULLIF(0.000,0))  * 1.89331599047119
WHEN MaLotNguyenLieu = 'SRFYO85'  THEN  ((CAST(Weights AS FLOAT)/ 1000) * (400 /35))  *  1.7495
--WHEN MaLotNguyenLieu = 'SRFYO85'  THEN  ((CAST(Weights AS FLOAT)/ 1000) * (400 /35))  * 2.94694971592868
WHEN MaLotNguyenLieu = 'SRECO85'  THEN  (CAST(Weights AS FLOAT)/ 1000 * (400 /33))  * 2.80314434092868
WHEN MaLotNguyenLieu = 'SRFCO85'  THEN  ((CAST(Weights AS FLOAT)/ 1000) * (400 /33))  * 2.803144
WHEN MaLotNguyenLieu = 'SRECL85'  THEN  ((CAST(Weights AS FLOAT)/ 1000) * (400 /22))  * 1.79693705884809
WHEN MaLotNguyenLieu = 'SRFCL85'  THEN  ((CAST(Weights AS FLOAT)/ 1000) * (400 /22))  * 1.36876984002831
WHEN MaLotNguyenLieu = 'SRFYK85'  THEN  (CAST(Weights AS FLOAT)/ 1000 * (400 /23))  * 1.2250
--WHEN MaLotNguyenLieu = 'SRFYK85'  THEN  (CAST(Weights AS FLOAT)/ 1000 * (400 /23))  * 4.38889329587645

WHEN MaLotNguyenLieu = 'SREMO75'  THEN (CAST(Weights AS FLOAT)/ 1000 * (400 /34))  * 4.484876122
WHEN MaLotNguyenLieu = 'SREMM75'  THEN  (CAST(Weights AS FLOAT)/ NULLIF(0.000,0))  * 4.4848761219994

WHEN MaLotNguyenLieu = 'SREYK85'  THEN  ((CAST(Weights AS FLOAT)/ 1000) * (350 /23)) * 1.36876984002831
WHEN MaLotNguyenLieu = 'SREYO85'  THEN  ((CAST(Weights AS FLOAT)/ 1000) * (400 /33)) * 1.89331599047119
WHEN MaLotNguyenLieu = 'CRECL85'  THEN  ((CAST(Weights AS FLOAT)/ 1000) * (350 /22)) * 1.94074243384809
WHEN MaLotNguyenLieu = 'CRFCL85'  THEN  ((CAST(Weights AS FLOAT)/ 1000) * (350 /22)) * 1.79693705884809
WHEN MaLotNguyenLieu = 'CRECO85'  THEN  ((CAST(Weights AS FLOAT)/ 1000) * (400 /33)) * 2.9469 	
WHEN MaLotNguyenLieu = 'CRFCO85'  THEN  ((CAST(Weights AS FLOAT)/ 1000) * (400 /33)) * 2.80314434092868	
WHEN MaLotNguyenLieu = 'GCMDPT-383'  THEN  (CAST(Weights AS FLOAT)/ 6.79) * 0.168
WHEN MaLotNguyenLieu = 'GCMDPT-218'  THEN  CAST(Weights AS FLOAT)/ 14.8
WHEN MaLotNguyenLieu = 'GBEC00-005'  THEN  CAST(Weights AS FLOAT) * 0.339
WHEN MaLotNguyenLieu = 'GCMDPT-422'  THEN  (CAST(Weights AS FLOAT)/ 6.79) * 0.168
WHEN MaLotNguyenLieu = 'GBAKAC-029'  THEN  (CAST(Weights AS FLOAT)/ 3.885) * 0.02824
WHEN MaLotNguyenLieu = 'GBAKAC-068'  THEN  (CAST(Weights AS FLOAT)/ 3.885) * 0.02824


-- theo c sao 29/06/24
WHEN MaLotNguyenLieu = 'CRFYN85'  THEN  (CAST(Weights AS FLOAT)/73.6) *1.729116202342
WHEN MaLotNguyenLieu = 'CREBO85'  THEN  (CAST(Weights AS FLOAT)/82.43) *3.08059689671909
WHEN MaLotNguyenLieu = 'GBCP00-S06'  THEN  (CAST(Weights AS FLOAT)/1) *101.45
WHEN MaLotNguyenLieu = 'GCMDPT-479'  THEN  (CAST(Weights AS FLOAT)/5.06) *0.095363
WHEN MaLotNguyenLieu = 'GBRLAC-004'  THEN  (CAST(Weights AS FLOAT)/0.6) *0.00560004
WHEN MaLotNguyenLieu = 'GCMDPT-330'  THEN  (CAST(Weights AS FLOAT)/5.06) *0.095363
WHEN MaLotNguyenLieu = 'GBNKSP-081'  THEN  (CAST(Weights AS FLOAT)/15.3) *1.207255
WHEN MaLotNguyenLieu = 'GBNKSP-080'  THEN  (CAST(Weights AS FLOAT)/15.3) *1.2265305
WHEN MaLotNguyenLieu = 'GCMDPT-450'  THEN  (CAST(Weights AS FLOAT)/5.06) *0.1308705
WHEN MaLotNguyenLieu = 'GBHB00-S05'  THEN  (CAST(Weights AS FLOAT)/0.19) *0.003903796
WHEN MaLotNguyenLieu = 'GBNKSP-079'  THEN  (CAST(Weights AS FLOAT)/25.7) *1.2265305
WHEN MaLotNguyenLieu = 'GBAKAC-053'  THEN  (CAST(Weights AS FLOAT)/ 0.6) * 0.00487
WHEN MaLotNguyenLieu = 'GBCP00-004'  THEN  (CAST(Weights AS FLOAT)/ 1)*10.95

------------------
WHEN MaLotNguyenLieu = 'GBAKAC-071' and Dates < '2024-06-01'  THEN  (CAST(Weights AS FLOAT)/1.333) *0.011
WHEN MaLotNguyenLieu = 'SREMO83' and Dates < '2024-06-01'  THEN  ((CAST(Weights AS FLOAT)/1000) * (400 /34))  * 4.3889
WHEN MaLotNguyenLieu = 'SRFMO83' and Dates < '2024-06-01'  THEN  ((CAST(Weights AS FLOAT)/ 1000) * (400 /34))  * 4.308458422

------------------------

WHEN MaLotNguyenLieu = 'GBAKAC-071' and Dates >= '2024-06-01'  THEN  (CAST(Weights AS FLOAT)/0.88) *0.01450735
WHEN MaLotNguyenLieu = 'SREMO83' and Dates >= '2024-06-01'  THEN  (CAST(Weights AS FLOAT)/85.5) *4.01580655442028
WHEN MaLotNguyenLieu = 'SRFMO83' and Dates >= '2024-06-01'  THEN  (CAST(Weights AS FLOAT)/84.5) *3.93854020509564
--- Theo yêu cầu của chị phương 
-- theo yêu cầu chị phương
WHEN MaLotNguyenLieu = 'GCMDPT-469' then 0.1240
WHEN MaLotNguyenLieu = 'GCMDPT-449'  THEN  0.1240
-- 
-- 2025-07-30
WHEN MaLotNguyenLieu = 'GBNKSP-083' then (CAST(Weights AS FLOAT)/ 12.02) * 0.7200
WHEN MaLotNguyenLieu = 'GBRLAC-005'  THEN (CAST(Weights AS FLOAT)/ 20.7) * 0.2557
WHEN MaLotNguyenLieu = 'GCMDPT-507'  THEN (CAST(Weights AS FLOAT)/ 15.11) * 0.3150

-- 2025-08-22 - following Ms.Phương's request
WHEN MaLotNguyenLieu = 'GBCP00-002'  THEN 8.2

-- 2025-09-01 - following Ms.Phương's request
WHEN MaLotNguyenLieu = 'GBRLAC-004'  THEN (CAST(Weights AS FLOAT)/ 0.689) * 0.0060
WHEN MaLotNguyenLieu = 'GBLYAC-002'  THEN (CAST(Weights AS FLOAT)/ 0.5852) * 0.0046
WHEN MaLotNguyenLieu = 'GBRLAC-006'  THEN 0.0061
WHEN MaLotNguyenLieu = 'GBRLAC-007'  THEN (CAST(Weights AS FLOAT)/ 0.4989) * 0.0034
WHEN MaLotNguyenLieu = 'GBRLAC-009'  THEN (CAST(Weights AS FLOAT)/ 1.335) * 0.0088
WHEN MaLotNguyenLieu = 'GBRLAC-012'  THEN (CAST(Weights AS FLOAT)/ 2.1206) * 0.0142


-- 2026-01-06 - following Ms.Phương's request
WHEN MaLotNguyenLieu = 'GBNKSP-082'  THEN (CAST(Weights AS FLOAT)/ 36.39) * 1.206386201

-- 20260407 -Nguyenduc dev by Mr Huan req
WHEN MaLotNguyenLieu = 'ECVT30-357'  THEN (CAST(Weights AS FLOAT)/ 20.7) * 0.2557 

ELSE 0.000

END AS PRICES

		INTO #T1

			FROM 

				#Tbl1

				SELECT 
					LINENAME,
				    Item,
					NG,
				    CAST(Weights AS FLOAT) AS Weights,
				    UNIT,
					StatusError,
					NameShift,
					Dates AS Dates,
					Times,

		(case  when   (DATEPART(HOUR, createdatetime)>10)   or  (DATEPART(HOUR, createdatetime)=10 and DATEPART(MINUTE, createdatetime)>30)     
				then     convert(varchar(10),createdatetime,120)    
				else    convert(varchar(10),DATEADD(DAY, -1,  createdatetime),120)       
				end 
		 )    
		  as  JobDate,   -- add by Mr.Tung on 31-July-2021

					CreateUserID,
					IDPE,
					Model,
					Can_Nang_Moi,
					PRICES,
					MaLotCapThu,
					MaLotNguyenLieu,
					WorkCenterCode,
					CASE 
					WHEN WorkCenterCode = 'VVT_F1' THEN N'Nhà máy Bắc Ninh'
					WHEN WorkCenterCode = 'VVT_F2' THEN N'Nhà máy Bắc Giang'
					ELSE ''
					 END AS NAMEFACTORY
					--t2.matCode,F
					--t2.weighUnit,					
					--t2.matUnit

				FROM #T1
				--left outer join [dbo].[fn_VVT_WeightUnit598_723]() t2 on  #t1.MaLotNguyenLieu=t2.matcode
				--left outer join [dbo].[fn_VVT_WeightUnit598_723_new] () t3 on #t1.Model = t3.myname
			WHERE 
					(
							((@FromDate IS NULL) OR createdatetime >= @FromDate) --updated 2025/08/07
						AND
							((@ToDate IS NULL) OR createdatetime <= @ToDate)  --updated 2025/08/07
					)

					AND 
							(Model LIKE @Model)

					AND 
							(WorkCenterCode LIKE @pWorkCenterCode)

			DROP TABLE #Tbl1
			DROP TABLE #T1
					
END

--SELECT TOP(500) * FROM STB_VN_PRODUCTION_ERROR    ORDER BY CREATEDATETIME DESC