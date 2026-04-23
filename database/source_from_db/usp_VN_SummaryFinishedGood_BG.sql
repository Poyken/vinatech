-- =============================================
-- Author:		DinhManh
-- Create date: 2025-03-19
-- Description: 
-- =============================================
CREATE PROCEDURE [dbo].[usp_VN_SummaryFinishedGood_BG]
	-- Add the parameters for the stored procedure here
			@pFromdate DATE = NULL,
			@pToDate DATE = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	WITH cte AS 
 (
	SELECT 
	 DISTINCT row_number() OVER(partition by A.PublicCode order by A.PublicCode) rn,
		A.Flag,
		A.PublicCode,
		A.PartNo,
		B.QtyInput,
		C.Qtyout,
		D.Qtylocation,
		E.TotalSale,
		b.QtyInput - C.Qtyout AS TotalCurrently
  FROM
		STB_VN_FINISHGOODS_BG A
  
   LEFT OUTER JOIN
  (
	SELECT
			PublicCode,
			sum(PackQty) AS QtyInput
			
    FROM 
			STB_VN_FINISHGOODS_BG 
	WHERE 
			Flag = 1
    GROUP BY PublicCode)B

  ON A.PublicCode= B.PublicCode

    LEFT OUTER JOIN
  (
   SELECT
	PublicCode,sum(PackQty) AS Qtyout
    FROM STB_VN_FINISHGOODS_BG 
	WHERE Statusout = N'Xuất' AND Statusout IS NOT NULL AND  Flag = 1
    GROUP BY PublicCode)C
  ON A.PublicCode=C.PublicCode
  
    INNER JOIN
  (
   SELECT
	PublicCode,PartNo
    FROM STB_VN_FINISHGOODS_BG 
	WHERE Flag = 1 AND StatusSystem = N'Nhập'
    GROUP BY PublicCode,PartNo)T
  ON A.PublicCode=T.PublicCode

    LEFT OUTER JOIN
  (SELECT PublicCode,sum(PackQty) AS Qtylocation
  
    FROM STB_VN_FINISHGOODS_BG 
	WHERE Country IN ( N'Kỹ thuật sản phẩm',N'QA',N'Module',N'Đóng gói (Packing)',N'Sản Xuất (Production)') AND Statusout = N'Xuất' AND Statusout IS NOT NULL AND Flag = 1
    GROUP BY PublicCode)D
  ON A.PublicCode=D.PublicCode

  
    LEFT OUTER JOIN
  (SELECT PublicCode,sum(PackQty) AS TotalSale
    FROM STB_VN_FINISHGOODS_BG 
	WHERE Country IN (
		N'Ấn Độ (India)',
		N'Anh Quốc (English)',
		N'Australia',
		N'Austria',
		N'Bỉ (Belgium)',
		N'Brazil',
		N'Broad Band',
		N'China',
		N'Đài loan (Taiwan)',
		N'Đức (Germany)',
		N'Estonia',
		N'Finland',
		N'France',
		N'Germany',
		N'Hà lan (Netherlands)',
		N'Hàn Quốc (Korea)',
		N'hàn quốc(korea)',
		N'HCM (Việt Nam)',
		N'Hong kong',
		N'Hongkong',
		N'HUNGARY',
		N'INDIA',
		N'Israel',
		N'Italy',
		N'Kazakhstan',
		N'KOREA',
		N'MALAYSIA',
		N'Moldova',
		N'Mỹ (America)',
		N'MYSORE, INDIA',
		N'New Zealand',
		N'Nga (Russia)',
		N'Pháp (France)',
		N'Poland(Phần Lan)',
		N'SATCO(Sweden)',
		N'Shanghai',
		N'Singapore',
		N'SLOVENIA',
		N'South Africa',
		N'Spain',
		N'Special IND(Italy)',
		N'Sweden',
		N'Switzerland',
		N'Taiwan',
		N'Tây Ban Nha (Spain)',
		N'Thái Lan (Thalan)',
		N'Trung Quốc (China)',
		N'TURKEY',
		N'Turkey(Thổ Nhĩ Kỳ)',
		N'UK',
		N'UK (United Kingdom)',
		N'Ukraine',
		N'United Kingdom',
		N'USA'
	) AND Statusout = N'Xuất' AND Statusout IS NOT NULL AND Flag = 1
    GROUP BY PublicCode)E
  ON A.PublicCode=E.PublicCode
)

	SELECT 
	DISTINCT 
		 '' + replace(PublicCode, ' ', '') + '' AS PublicCode,
		'' + replace(PartNo, ' ', '') + '' AS PartNo,
		'PCS' AS UNIT,
		FORMAT(QtyInput, 'N0') AS QtyInput,
		FORMAT(Qtyout, 'N0') AS Qtyout,
		FORMAT(Qtylocation, 'N0') AS Qtylocation,
		FORMAT(TotalSale, 'N0') AS TotalSale,
		CASE	
			WHEN Qtyout IS NULL	THEN FORMAT(QtyInput,'N0')
			ELSE  FORMAT(TotalCurrently,'N0')
		END AS Result,

CASE

	WHEN PublicCode ='BSECVT30-254' THEN  0.14036
	WHEN PublicCode ='ECVT30-188' THEN  0.14032
	WHEN PublicCode ='ECVT30-215' THEN  0.14032
	WHEN PublicCode ='ECVT30-V02' THEN  0.14036
	WHEN PublicCode ='ECVT30-V08' THEN  0.14036
	WHEN PublicCode ='ECVT30-V03' THEN  0.14036
	WHEN PublicCode ='GW0820335V-02' THEN  0.14032
	WHEN PublicCode ='ECVT30-V297' THEN  0.14036
	WHEN PublicCode ='MVCC54-001' THEN  0.14041
	WHEN PublicCode ='MVCC120-001' THEN  0.14041
	WHEN PublicCode ='MVCC54-002' THEN  0.14041
	WHEN PublicCode ='MVCC54-004' THEN  0.14041
	WHEN PublicCode ='MVCC54-005' THEN  0.14041
	WHEN PublicCode ='MVCC54-006' THEN  0.14041
	WHEN PublicCode ='MVCC54-009' THEN 0.14041
	WHEN PublicCode ='MVCC54-010' THEN  0.14041
	WHEN PublicCode ='MVCC54-011' THEN  0.14041
	WHEN PublicCode ='MVCC54-015' THEN  0.14041
	WHEN PublicCode ='MVCC54-016' THEN  0.14041
	WHEN PublicCode ='MVCC54-017' THEN  0.14041
	WHEN PublicCode ='MVCC54-018' THEN  0.14041
	WHEN PublicCode ='MVCC54-019' THEN  0.14041
	WHEN PublicCode ='MVCC54-020' THEN  0.14041
	WHEN PublicCode ='MVCC54-024' THEN  0.14041
	WHEN PublicCode ='MVCC54-027' THEN  0.14041
	WHEN PublicCode ='MVCC54-029' THEN  0.14041
	WHEN PublicCode ='MVCC54-030' THEN  0.14041
	WHEN PublicCode ='MVCC54-037' THEN  0.14041
	WHEN PublicCode ='MVCC54-041' THEN  0.14041
	WHEN PublicCode ='MVCC54-040' THEN  0.14041
	WHEN PublicCode ='MVCC60-001' THEN  0.14041
	WHEN PublicCode ='MVCC60-002' THEN  0.14041
	WHEN PublicCode ='MVCC60-003' THEN  0.14041
	WHEN PublicCode ='MVCC60-005' THEN  0.14041
	WHEN PublicCode ='MVCC60-006' THEN  0.14041
	WHEN PublicCode ='MVCC60-007' THEN  0.14041
	WHEN PublicCode ='MVCC60-008' THEN  0.14041
	WHEN PublicCode ='MVCC60-009' THEN  0.14041
	WHEN PublicCode ='MVCC60-012' THEN  0.14041 
	WHEN PublicCode ='MVCC60-013' THEN  0.14041 
	WHEN PublicCode ='MVCC60-018' THEN  0.14041
	WHEN PublicCode ='MVCC60-012' THEN  0.14041
	WHEN PublicCode ='MVCC60-013' THEN  0.14041
	WHEN PublicCode ='MVCC60-017' THEN  0.14041
	WHEN PublicCode ='MVCC60-023' THEN  0.14041
	WHEN PublicCode ='MVCC60-019' THEN  0.14041
	WHEN PublicCode ='MVCC60-020' THEN  0.14041
	WHEN PublicCode ='MVCC60-027' THEN  0.14041
	WHEN PublicCode ='MVCC60-029' THEN  0.14041
	WHEN PublicCode ='MVCC60-064' THEN  0.14041
	WHEN PublicCode ='MVCC60-066' THEN  0.14041
	WHEN PublicCode ='MVCC60-063' THEN  0.14041
	WHEN PublicCode ='MVCC60-041' THEN  0.14041
	WHEN PublicCode ='MVCC60-075' THEN 0.14041
	WHEN PublicCode ='MVCC60-080' THEN  3.16011
	WHEN PublicCode ='MVCC60-078' THEN  0.14041
	WHEN PublicCode ='MVCR00-007' THEN  0.14041
	WHEN PublicCode ='MVCR00-006' THEN  0.14041
	WHEN PublicCode ='MVCC60-SJ37' THEN  0.14041
	WHEN PublicCode ='MVCC90-065' THEN  0.14041
	WHEN PublicCode ='MVCC90-067' THEN  0.14041
	WHEN PublicCode ='MVCC60-SJ38' THEN  3.16011
	WHEN PublicCode ='MVCV54-001' THEN  0.14041
	WHEN PublicCode ='MVCV54-003' THEN 0.14041
	WHEN PublicCode ='MVCV54-002' THEN  0.14041
	WHEN PublicCode ='MVCV54-005' THEN  0.14041
	WHEN PublicCode ='MVCV54-004' THEN  0.14041
	WHEN PublicCode ='MVCV54-006' THEN  0.14041
	WHEN PublicCode ='MVCV54-010' THEN  0.14041
	WHEN PublicCode ='MVCV54-009' THEN  0.14041
	WHEN PublicCode ='MVCV54-015' THEN  0.14041
	WHEN PublicCode ='MVCV54-017' THEN  0.14041
	WHEN PublicCode ='MVCV54-016' THEN  0.14041
	WHEN PublicCode ='MVCV54-018' THEN  0.14041
	WHEN PublicCode ='MVCR01-007' THEN  0.14041
	WHEN PublicCode ='MVCR01-006' THEN  0.14041
	WHEN PublicCode ='MVCV54-024' THEN  0.14041
	WHEN PublicCode ='MVCV54-911' THEN  0.14041
	WHEN PublicCode ='MVCV54-031' THEN  0.14041
	WHEN PublicCode ='MVCV54-030' THEN  0.14041
	WHEN PublicCode ='MVCV54-920' THEN  0.14041
	WHEN PublicCode ='MVCV60-001' THEN  0.14041
	WHEN PublicCode ='MVCV60-002' THEN  0.14041
	WHEN PublicCode ='MVCV60-003' THEN  0.14041
	WHEN PublicCode ='MVCV54-940' THEN  0.14041
	WHEN PublicCode ='MVCV54-931' THEN  0.14041
	WHEN PublicCode ='MVCV54-929' THEN  0.14041
	WHEN PublicCode ='MVCV60-005' THEN  0.14041
	WHEN PublicCode ='MVCV60-019' THEN  0.14041
	WHEN PublicCode ='MVCV60-018' THEN  0.14041
	WHEN PublicCode ='MVCV60-020' THEN  0.14041
	WHEN PublicCode ='MVCV60-008' THEN  0.14041
	WHEN PublicCode ='MVCV60-009' THEN  0.14041
	WHEN PublicCode ='MVCV60-011' THEN  0.14041
	WHEN PublicCode ='MVCV60-012' THEN  0.14041
	WHEN PublicCode ='MVCV60-007' THEN  0.14041
	WHEN PublicCode ='MVCV60-063' THEN  0.14041
	WHEN PublicCode ='MVCV60-064' THEN  0.14041
	WHEN PublicCode ='MVCV60-066' THEN  0.14041
	WHEN PublicCode ='MVCV60-030' THEN  0.14041
	WHEN PublicCode ='MVCV60-927' THEN  0.14041
	WHEN PublicCode ='MVCV60-907' THEN  0.14041
	WHEN PublicCode ='MVCV60-071' THEN  0.14041
	WHEN PublicCode ='MVCV60-913' THEN  0.14041
	WHEN PublicCode ='MVCV60-915' THEN  0.14041
	WHEN PublicCode ='MVCV60-914' THEN  0.14041
	WHEN PublicCode ='MVCV60-930' THEN  0.14041
	WHEN PublicCode ='MVCV60-963' THEN  0.14041
	WHEN PublicCode ='MVCV90-065' THEN  0.14041
	WHEN PublicCode ='MVCV60-917' THEN  0.14041
	WHEN PublicCode ='MVCV60-902' THEN  0.14041
	WHEN PublicCode ='MVCV60-SJ36' THEN  0.14041
	WHEN PublicCode ='PSVECWT30-007' THEN  0.14032
	WHEN PublicCode ='PSVECW30-007' THEN  0.14041
	WHEN PublicCode ='PVECW30-012' THEN  0.14036
	WHEN PublicCode ='PSVECW30-35' THEN   0.14036
	WHEN PublicCode ='PECVT30-247' THEN   0.14036
	WHEN PublicCode ='ECVT30-V08' THEN   0.14036
	WHEN PublicCode ='PECVT27-382' THEN  0.14041
	WHEN PublicCode ='PECVT30-261' THEN  0.14036
	WHEN PublicCode ='PSVECW30-036' THEN  0.14036
	WHEN PublicCode ='PECVT30-204' THEN  0.14032
	WHEN PublicCode ='PECVT27-207' THEN  0.14032
	WHEN PublicCode ='PEDVTMD-145' THEN  0.14041
	WHEN PublicCode ='PEDVTMD-095' THEN  0.14041
	WHEN PublicCode ='PEDVTMD-144' THEN  0.14041
	WHEN PublicCode ='PECVT30-246' THEN  0.14039
	WHEN PublicCode ='VECV27-001' THEN  0.06716
	WHEN PublicCode ='VECV27-003' THEN  0.14032
	WHEN PublicCode ='VECV27-004' THEN  0.14032
	WHEN PublicCode ='VECV27-005' THEN  0.06716
	WHEN PublicCode ='VECV27-008' THEN  0.14032
	WHEN PublicCode ='VECV27-011' THEN  0.14363
	WHEN PublicCode ='VECV27-012' THEN  0.09700
	WHEN PublicCode ='VECV27-014' THEN   0.14032
	WHEN PublicCode ='SECVT30-247' THEN  0.14036
	WHEN PublicCode ='VECV27-016' THEN  0.09700
	WHEN PublicCode ='VECV27-020' THEN  0.09700
	WHEN PublicCode ='VECV27-022' THEN  0.09700
	WHEN PublicCode ='VECV27-023' THEN  0.09700
	WHEN PublicCode ='VECV27-024' THEN  0.09700
	WHEN PublicCode ='PVNWEC30-006' THEN  0.14036
	WHEN PublicCode ='PVNVEC30-018' THEN  0.14041
	WHEN PublicCode ='VECV30-001' THEN  0.14032
	WHEN PublicCode ='VECV30-004' THEN  0.14036
	WHEN PublicCode ='VECV30-006' THEN  0.14036
	WHEN PublicCode ='VECV30-007' THEN  0.14036
	WHEN PublicCode ='VECV30-008' THEN  0.14032
	WHEN PublicCode ='VECV30-012' THEN  0.14036
	WHEN PublicCode ='VECV30-013' THEN  0.14036
	WHEN PublicCode ='VECV30-014' THEN  0.14039
	WHEN PublicCode ='VECV30-017' THEN  0.14036
	WHEN PublicCode ='VECV27-W18' THEN  0.09700
	WHEN PublicCode ='VECV30-022' THEN  0.14036
	WHEN PublicCode ='VECV27-032' THEN 0.14032
	WHEN PublicCode ='VECV30-023' THEN  0.14036
	WHEN PublicCode ='VECV30-026' THEN  0.14036
	WHEN PublicCode ='VECV30-024' THEN  0.14032
	WHEN PublicCode ='VECV30-025' THEN  0.14032
	WHEN PublicCode ='VECV30-030' THEN  0.14036
	WHEN PublicCode ='VECV30-031' THEN  0.14036
	WHEN PublicCode ='VECV27-W21' THEN  0.09700
	WHEN PublicCode ='VECVT27-001' THEN  0.14032
	WHEN PublicCode ='VECW27-001' THEN  0.06716
	WHEN PublicCode ='VECW27-003' THEN  0.14032
	WHEN PublicCode ='VECW27-005' THEN  0.09700
	WHEN PublicCode ='VECW27-W15' THEN  0.14032
	WHEN PublicCode ='VECW27-012' THEN  0.09700
	WHEN PublicCode ='VECW27-016' THEN  0.09700
	WHEN PublicCode ='VECW27-020' THEN  0.09700
	WHEN PublicCode ='VECVT30-317' THEN  0.14041
	WHEN PublicCode ='VECV30-051' THEN  0.14036
	WHEN PublicCode ='VECV30-033' THEN  0.14032
	WHEN PublicCode ='VECV30-052' THEN  0.14032
	WHEN PublicCode ='VECV30-037' THEN  0.14032
	WHEN PublicCode ='VECV30-038' THEN  0.14032
	WHEN PublicCode ='VECV30-W37' THEN 0.14032
	WHEN PublicCode ='VECV30-039 ' THEN  0.14032
	WHEN PublicCode ='VECV30-043' THEN  0.14032
	WHEN PublicCode ='VECW30-001' THEN  0.14032
	WHEN PublicCode ='VECW30-0320.6T' THEN  0.14032
	WHEN PublicCode ='VECW30-032' THEN  0.14032
	WHEN PublicCode ='VECW30-004' THEN  0.14036
	WHEN PublicCode ='VECW30-005' THEN  0.14036
	WHEN PublicCode ='VECW30-006' THEN  0.14036
	WHEN PublicCode ='VECW30-007' THEN  0.14041
	WHEN PublicCode ='VECWT30-007' THEN  0.14041
	WHEN PublicCode ='VECW30-008' THEN  0.14032
	WHEN PublicCode ='VECW30-012' THEN  0.14036
	WHEN PublicCode ='VECW30-010' THEN  0.14036
	WHEN PublicCode ='VECW30-010' THEN  0.14036
	WHEN PublicCode ='VECW30-35' THEN  0.14036
	WHEN PublicCode ='VECW30-013' THEN  0.14041
	WHEN PublicCode ='VECW30-033' THEN  0.19914
	WHEN PublicCode ='VECW30-034' THEN  0.14036
	WHEN PublicCode ='VECW30-014' THEN  0.14036
	WHEN PublicCode ='VECW27-W16' THEN  0.09700
	WHEN PublicCode ='VECW30-SW17' THEN  0.14036
	WHEN PublicCode ='VECW30-017' THEN  0.14036
	WHEN PublicCode ='VECW30-022' THEN  0.14041
	WHEN PublicCode ='VECW30-025' THEN  0.14036
	WHEN PublicCode ='VECW30-023' THEN  0.14036
	WHEN PublicCode ='VECW30-029' THEN 0.14036
	WHEN PublicCode ='VECW30-030' THEN  0.14036
	WHEN PublicCode ='VECW30-036' THEN  0.14036
	WHEN PublicCode ='VHCV23-002' THEN  3.16011
	WHEN PublicCode ='VHCV23-006' THEN  0.14041
	WHEN PublicCode ='VHCV23-004' THEN  0.14041
	WHEN PublicCode ='VNVEC27-001' THEN  0.06716
	WHEN PublicCode ='VNVEC27-003' THEN  0.14032
	WHEN PublicCode ='VNVEC27-002' THEN  0.06716
	WHEN PublicCode ='VNVEC27-004' THEN  0.14032
	WHEN PublicCode ='VNVEC27-005' THEN  0.06716
	WHEN PublicCode ='VNVEC27-008' THEN  0.14032
	WHEN PublicCode ='VMVCV120-101' THEN  0.14041
	WHEN PublicCode ='VNVEC27-011' THEN  0.14363
	WHEN PublicCode ='VNVEC27-012' THEN  0.09700
	WHEN PublicCode ='VNVEC27-014' THEN  0.14041
	WHEN PublicCode ='VNVEC27-016' THEN  0.09700
	WHEN PublicCode ='VNVEC27-018' THEN   0.09700
	WHEN PublicCode ='VNVEC27-020' THEN 0.09700
	WHEN PublicCode ='VNVEC27-023' THEN  0.09700
	WHEN PublicCode ='VNVEC27-028' THEN  0.14032
	WHEN PublicCode ='MVCV60-909' THEN  0.14041
	WHEN PublicCode ='VNVEC27-032' THEN  0.14032
	WHEN PublicCode ='VNVEC30-001' THEN  0.14041
	WHEN PublicCode ='VNVEC30-004' THEN  0.14036
	WHEN PublicCode ='VNVEC27-035' THEN  0.14032
	WHEN PublicCode ='VNVEC30-006' THEN  0.14036
	WHEN PublicCode ='VNVEC30-007' THEN  0.14036
	WHEN PublicCode ='VNVEC30-008' THEN  0.14032
	WHEN PublicCode ='VNVEC30-012' THEN  0.14036
	WHEN PublicCode ='VNVEC30-013' THEN  0.14036
	WHEN PublicCode ='VNVEC30-014' THEN  0.14039
	WHEN PublicCode ='VNVEC30-016' THEN  0.14036
	WHEN PublicCode ='VNVEC27-049' THEN  0.09700
	WHEN PublicCode ='VNVEC30-017' THEN  0.14036
	WHEN PublicCode ='VNVEC30-022' THEN  0.14036
	WHEN PublicCode ='VNVEC30-018' THEN  0.14041
	WHEN PublicCode ='VNVEC30-023' THEN  0.14036
	WHEN PublicCode ='VNVEC30-033' THEN  0.14032
	WHEN PublicCode ='VNVECT30-001' THEN  0.14041
	WHEN PublicCode ='VNWEC27-001' THEN  0.06716
	WHEN PublicCode ='VNWEC27-003' THEN  0.14032
	WHEN PublicCode ='VNWEC27-005' THEN  0.09700
	WHEN PublicCode ='VNWEC27-008' THEN  0.14032
	WHEN PublicCode ='VNVHC23-003' THEN  0.14041
	WHEN PublicCode ='VNWEC27-011' THEN  0.14032
	WHEN PublicCode ='VNWEC27-012' THEN  0.09700
	WHEN PublicCode ='VNWEC27-015' THEN  0.14032
	WHEN PublicCode ='VNVEC30-045' THEN  0.14036
	WHEN PublicCode ='VNVEC30-050' THEN  0.14036
	WHEN PublicCode ='VNVHC23-005' THEN  3.16001
	WHEN PublicCode ='VNVEC30-051' THEN  0.14041
	WHEN PublicCode ='VNVEC30-033' THEN  0.14032
	WHEN PublicCode ='VNVEC30-054' THEN  0.14041
	WHEN PublicCode ='VNVEC30-037' THEN  0.14032
	WHEN PublicCode ='VNVEC30-053' THEN  0.14036
	WHEN PublicCode ='VNVEC30-043' THEN  0.14032
	WHEN PublicCode ='VNVEC30-038' THEN  0.14032
	WHEN PublicCode ='VNVEC30-046 ' THEN  0.14032
	WHEN PublicCode ='VNWEC30-941' THEN  0.14041
	WHEN PublicCode ='VNWEC30-001' THEN  0.14032
	WHEN PublicCode ='VNWEC30-004' THEN  0.14036
	WHEN PublicCode ='VNWEC30-005' THEN  0.14036
	WHEN PublicCode ='VNWEC30-032' THEN  0.14032
	WHEN PublicCode ='VNWEC30-006' THEN  0.14036
	WHEN PublicCode ='VNWEC30-007' THEN  0.14041
	WHEN PublicCode ='VNWEC30-008' THEN  0.14032
	WHEN PublicCode ='VNWEC30-012' THEN  0.14036
	WHEN PublicCode ='VNWEC27-011' THEN  0.14032
	WHEN PublicCode ='VNWEC30-013' THEN  0.14041
	WHEN PublicCode ='VNWEC30-035' THEN  0.14036
	WHEN PublicCode ='VNWEC30-014' THEN 0.14036
	WHEN PublicCode ='VNWEC30-034' THEN  0.14036
	WHEN PublicCode ='VNWEC30-037' THEN  0.14041
	WHEN PublicCode ='VNWEC30-017' THEN  0.14036
	WHEN PublicCode ='VNWEC30-018' THEN 0.14036
	WHEN PublicCode ='VNWEC30-022' THEN  0.14041
	WHEN PublicCode ='VNWEC27-020' THEN  0.09700
	WHEN PublicCode ='VNWEC30-023' THEN  0.14036
	WHEN PublicCode ='VNWEC30-025' THEN  0.14036
	WHEN PublicCode ='VNWEC30-040' THEN  0.14041
	WHEN PublicCode ='VNWEC30-030' THEN  0.14036
	WHEN PublicCode ='VNWECT30-001' THEN  0.14041
	WHEN PublicCode ='VVWEC30-004' THEN  0.14036
	WHEN PublicCode ='VNWECT30-004' THEN  0.14036
	WHEN PublicCode ='VNWECT30-007' THEN  0.14036
	WHEN PublicCode ='VNWECT30-013' THEN  0.14041
	WHEN PublicCode ='VVVEC27-012' THEN 0.09700
	WHEN PublicCode ='VNWECT30-014' THEN  0.14041
	WHEN PublicCode ='VNWECT30-914' THEN 0.14041
	WHEN PublicCode ='VNWECT30-022' THEN  0.14041
	WHEN PublicCode ='VNWECT30-922' THEN  0.14041
	WHEN PublicCode ='VVVEC30-033' THEN  0.14032
	WHEN PublicCode ='VVVEC30-037' THEN  0.14032
	WHEN PublicCode ='VVVEC30-053' THEN  0.14036
	
	ELSE 0.000
	END AS Prices,
CASE

	WHEN PublicCode ='BSECVT30-254' THEN TotalCurrently * 0.14036
	WHEN PublicCode ='ECVT30-188' THEN TotalCurrently * 0.14032
	WHEN PublicCode ='ECVT30-215' THEN TotalCurrently * 0.14032
	WHEN PublicCode ='ECVT30-V02' THEN TotalCurrently * 0.14036
	WHEN PublicCode ='ECVT30-V08' THEN TotalCurrently * 0.14036
	WHEN PublicCode ='ECVT30-V03' THEN TotalCurrently * 0.14036
	WHEN PublicCode ='GW0820335V-02' THEN TotalCurrently * 0.14032
	WHEN PublicCode ='ECVT30-V297' THEN TotalCurrently * 0.14036
	WHEN PublicCode ='MVCC54-001' THEN TotalCurrently * 0.14041
	WHEN PublicCode ='MVCC120-001' THEN TotalCurrently * 0.14041
	WHEN PublicCode ='MVCC54-002' THEN TotalCurrently * 0.14041
	WHEN PublicCode ='MVCC54-004' THEN TotalCurrently * 0.14041
	WHEN PublicCode ='MVCC54-005' THEN TotalCurrently * 0.14041
	WHEN PublicCode ='MVCC54-006' THEN TotalCurrently * 0.14041
	WHEN PublicCode ='MVCC54-009' THEN TotalCurrently * 0.14041
	WHEN PublicCode ='MVCC54-010' THEN TotalCurrently * 0.14041
	WHEN PublicCode ='MVCC54-011' THEN TotalCurrently * 0.14041
	WHEN PublicCode ='MVCC54-015' THEN TotalCurrently * 0.14041
	WHEN PublicCode ='MVCC54-016' THEN TotalCurrently * 0.14041
	WHEN PublicCode ='MVCC54-017' THEN TotalCurrently * 0.14041
	WHEN PublicCode ='MVCC54-018' THEN TotalCurrently * 0.14041
	WHEN PublicCode ='MVCC54-019' THEN TotalCurrently * 0.14041
	WHEN PublicCode ='MVCC54-020' THEN TotalCurrently * 0.14041
	WHEN PublicCode ='MVCC54-024' THEN TotalCurrently * 0.14041
	WHEN PublicCode ='MVCC54-027' THEN TotalCurrently * 0.14041
	WHEN PublicCode ='MVCC54-029' THEN TotalCurrently * 0.14041
	WHEN PublicCode ='MVCC54-030' THEN TotalCurrently * 0.14041
	WHEN PublicCode ='MVCC54-037' THEN TotalCurrently * 0.14041
	WHEN PublicCode ='MVCC54-041' THEN TotalCurrently * 0.14041
	WHEN PublicCode ='MVCC54-040' THEN TotalCurrently * 0.14041
	WHEN PublicCode ='MVCC60-001' THEN TotalCurrently * 0.14041
	WHEN PublicCode ='MVCC60-002' THEN TotalCurrently * 0.14041
	WHEN PublicCode ='MVCC60-003' THEN TotalCurrently * 0.14041
	WHEN PublicCode ='MVCC60-005' THEN TotalCurrently * 0.14041
	WHEN PublicCode ='MVCC60-006' THEN TotalCurrently * 0.14041
	WHEN PublicCode ='MVCC60-007' THEN TotalCurrently * 0.14041
	WHEN PublicCode ='MVCC60-008' THEN TotalCurrently * 0.14041
	WHEN PublicCode ='MVCC60-009' THEN TotalCurrently * 0.14041
	WHEN PublicCode ='MVCC60-012' THEN TotalCurrently * 0.14041 
	WHEN PublicCode ='MVCC60-013' THEN TotalCurrently * 0.14041 
	WHEN PublicCode ='MVCC60-018' THEN TotalCurrently * 0.14041
	WHEN PublicCode ='MVCC60-012' THEN TotalCurrently * 0.14041
	WHEN PublicCode ='MVCC60-013' THEN TotalCurrently * 0.14041
	WHEN PublicCode ='MVCC60-017' THEN TotalCurrently * 0.14041
	WHEN PublicCode ='MVCC60-023' THEN TotalCurrently * 0.14041
	WHEN PublicCode ='MVCC60-019' THEN TotalCurrently * 0.14041
	WHEN PublicCode ='MVCC60-020' THEN TotalCurrently * 0.14041
	WHEN PublicCode ='MVCC60-027' THEN TotalCurrently * 0.14041
	WHEN PublicCode ='MVCC60-029' THEN TotalCurrently * 0.14041
	WHEN PublicCode ='MVCC60-064' THEN TotalCurrently * 0.14041
	WHEN PublicCode ='MVCC60-066' THEN TotalCurrently * 0.14041
	WHEN PublicCode ='MVCC60-063' THEN TotalCurrently * 0.14041
	WHEN PublicCode ='MVCC60-041' THEN TotalCurrently * 0.14041
	WHEN PublicCode ='MVCC60-075' THEN TotalCurrently * 0.14041
	WHEN PublicCode ='MVCC60-080' THEN TotalCurrently * 3.16011
	WHEN PublicCode ='MVCC60-078' THEN TotalCurrently * 0.14041
	WHEN PublicCode ='MVCR00-007' THEN TotalCurrently * 0.14041
	WHEN PublicCode ='MVCR00-006' THEN TotalCurrently * 0.14041
	WHEN PublicCode ='MVCC60-SJ37' THEN TotalCurrently * 0.14041
	WHEN PublicCode ='MVCC90-065' THEN TotalCurrently * 0.14041
	WHEN PublicCode ='MVCC90-067' THEN TotalCurrently * 0.14041
	WHEN PublicCode ='MVCC60-SJ38' THEN TotalCurrently * 3.16011
	WHEN PublicCode ='MVCV54-001' THEN TotalCurrently * 0.14041
	WHEN PublicCode ='MVCV54-003' THEN TotalCurrently * 0.14041
	WHEN PublicCode ='MVCV54-002' THEN TotalCurrently * 0.14041
	WHEN PublicCode ='MVCV54-005' THEN TotalCurrently * 0.14041
	WHEN PublicCode ='MVCV54-004' THEN TotalCurrently * 0.14041
	WHEN PublicCode ='MVCV54-006' THEN TotalCurrently * 0.14041
	WHEN PublicCode ='MVCV54-010' THEN TotalCurrently * 0.14041
	WHEN PublicCode ='MVCV54-009' THEN TotalCurrently * 0.14041
	WHEN PublicCode ='MVCV54-015' THEN TotalCurrently * 0.14041
	WHEN PublicCode ='MVCV54-017' THEN TotalCurrently * 0.14041
	WHEN PublicCode ='MVCV54-016' THEN TotalCurrently * 0.14041
	WHEN PublicCode ='MVCV54-018' THEN TotalCurrently * 0.14041
	WHEN PublicCode ='MVCR01-007' THEN TotalCurrently * 0.14041
	WHEN PublicCode ='MVCR01-006' THEN TotalCurrently * 0.14041
	WHEN PublicCode ='MVCV54-024' THEN TotalCurrently * 0.14041
	WHEN PublicCode ='MVCV54-911' THEN TotalCurrently * 0.14041
	WHEN PublicCode ='MVCV54-031' THEN TotalCurrently * 0.14041
	WHEN PublicCode ='MVCV54-030' THEN TotalCurrently * 0.14041
	WHEN PublicCode ='MVCV54-920' THEN TotalCurrently * 0.14041
	WHEN PublicCode ='MVCV60-001' THEN TotalCurrently * 0.14041
	WHEN PublicCode ='MVCV60-002' THEN TotalCurrently * 0.14041
	WHEN PublicCode ='MVCV60-003' THEN TotalCurrently * 0.14041
	WHEN PublicCode ='MVCV54-940' THEN TotalCurrently * 0.14041
	WHEN PublicCode ='MVCV54-931' THEN TotalCurrently * 0.14041
	WHEN PublicCode ='MVCV54-929' THEN TotalCurrently * 0.14041
	WHEN PublicCode ='MVCV60-005' THEN TotalCurrently * 0.14041
	WHEN PublicCode ='MVCV60-019' THEN TotalCurrently * 0.14041
	WHEN PublicCode ='MVCV60-018' THEN TotalCurrently * 0.14041
	WHEN PublicCode ='MVCV60-020' THEN TotalCurrently * 0.14041
	WHEN PublicCode ='MVCV60-008' THEN TotalCurrently * 0.14041
	WHEN PublicCode ='MVCV60-009' THEN TotalCurrently * 0.14041
	WHEN PublicCode ='MVCV60-011' THEN TotalCurrently * 0.14041
	WHEN PublicCode ='MVCV60-012' THEN TotalCurrently * 0.14041
	WHEN PublicCode ='MVCV60-007' THEN TotalCurrently * 0.14041
	WHEN PublicCode ='MVCV60-063' THEN TotalCurrently * 0.14041
	WHEN PublicCode ='MVCV60-064' THEN TotalCurrently * 0.14041
	WHEN PublicCode ='MVCV60-066' THEN TotalCurrently * 0.14041
	WHEN PublicCode ='MVCV60-030' THEN TotalCurrently * 0.14041
	WHEN PublicCode ='MVCV60-927' THEN TotalCurrently * 0.14041
	WHEN PublicCode ='MVCV60-907' THEN TotalCurrently * 0.14041
	WHEN PublicCode ='MVCV60-071' THEN TotalCurrently * 0.14041
	WHEN PublicCode ='MVCV60-913' THEN TotalCurrently * 0.14041
	WHEN PublicCode ='MVCV60-915' THEN TotalCurrently * 0.14041
	WHEN PublicCode ='MVCV60-914' THEN TotalCurrently * 0.14041
	WHEN PublicCode ='MVCV60-930' THEN TotalCurrently * 0.14041
	WHEN PublicCode ='MVCV60-963' THEN TotalCurrently * 0.14041
	WHEN PublicCode ='MVCV90-065' THEN TotalCurrently * 0.14041
	WHEN PublicCode ='MVCV60-917' THEN TotalCurrently * 0.14041
	WHEN PublicCode ='MVCV60-902' THEN TotalCurrently * 0.14041
	WHEN PublicCode ='MVCV60-SJ36' THEN TotalCurrently * 0.14041
	WHEN PublicCode ='PSVECWT30-007' THEN TotalCurrently * 0.14032
	WHEN PublicCode ='PSVECW30-007' THEN TotalCurrently * 0.14041
	WHEN PublicCode ='PVECW30-012' THEN TotalCurrently * 0.14036
	WHEN PublicCode ='PSVECW30-35' THEN TotalCurrently *  0.14036
	WHEN PublicCode ='PECVT30-247' THEN TotalCurrently *  0.14036
	WHEN PublicCode ='ECVT30-V08' THEN TotalCurrently *  0.14036
	WHEN PublicCode ='PECVT27-382' THEN TotalCurrently * 0.14041
	WHEN PublicCode ='PECVT30-261' THEN TotalCurrently * 0.14036
	WHEN PublicCode ='PSVECW30-036' THEN TotalCurrently * 0.14036
	WHEN PublicCode ='PECVT30-204' THEN TotalCurrently * 0.14032
	WHEN PublicCode ='PECVT27-207' THEN TotalCurrently * 0.14032
	WHEN PublicCode ='PEDVTMD-145' THEN TotalCurrently * 0.14041
	WHEN PublicCode ='PEDVTMD-095' THEN TotalCurrently * 0.14041
	WHEN PublicCode ='PEDVTMD-144' THEN TotalCurrently * 0.14041
	WHEN PublicCode ='PECVT30-246' THEN TotalCurrently * 0.14039
	WHEN PublicCode ='VECV27-001' THEN TotalCurrently * 0.06716
	WHEN PublicCode ='VECV27-003' THEN TotalCurrently * 0.14032
	WHEN PublicCode ='VECV27-004' THEN TotalCurrently * 0.14032
	WHEN PublicCode ='VECV27-005' THEN TotalCurrently * 0.06716
	WHEN PublicCode ='VECV27-008' THEN TotalCurrently * 0.14032
	WHEN PublicCode ='VECV27-011' THEN TotalCurrently * 0.14363
	WHEN PublicCode ='VECV27-012' THEN TotalCurrently * 0.09700
	WHEN PublicCode ='VECV27-014' THEN TotalCurrently *  0.14032
	WHEN PublicCode ='SECVT30-247' THEN TotalCurrently * 0.14036
	WHEN PublicCode ='VECV27-016' THEN TotalCurrently * 0.09700
	WHEN PublicCode ='VECV27-020' THEN TotalCurrently * 0.09700
	WHEN PublicCode ='VECV27-022' THEN TotalCurrently * 0.09700
	WHEN PublicCode ='VECV27-023' THEN TotalCurrently * 0.09700
	WHEN PublicCode ='VECV27-024' THEN TotalCurrently * 0.09700
	WHEN PublicCode ='PVNWEC30-006' THEN TotalCurrently * 0.14036
	WHEN PublicCode ='PVNVEC30-018' THEN TotalCurrently * 0.14041
	WHEN PublicCode ='VECV30-001' THEN TotalCurrently * 0.14032
	WHEN PublicCode ='VECV30-004' THEN TotalCurrently * 0.14036
	WHEN PublicCode ='VECV30-006' THEN TotalCurrently * 0.14036
	WHEN PublicCode ='VECV30-007' THEN TotalCurrently * 0.14036
	WHEN PublicCode ='VECV30-008' THEN TotalCurrently * 0.14032
	WHEN PublicCode ='VECV30-012' THEN TotalCurrently * 0.14036
	WHEN PublicCode ='VECV30-013' THEN TotalCurrently * 0.14036
	WHEN PublicCode ='VECV30-014' THEN TotalCurrently * 0.14039
	WHEN PublicCode ='VECV30-017' THEN TotalCurrently * 0.14036
	WHEN PublicCode ='VECV27-W18' THEN TotalCurrently * 0.09700
	WHEN PublicCode ='VECV30-022' THEN TotalCurrently * 0.14036
	WHEN PublicCode ='VECV27-032' THEN TotalCurrently * 0.14032
	WHEN PublicCode ='VECV30-023' THEN TotalCurrently * 0.14036
	WHEN PublicCode ='VECV30-026' THEN TotalCurrently * 0.14036
	WHEN PublicCode ='VECV30-024' THEN TotalCurrently * 0.14032
	WHEN PublicCode ='VECV30-025' THEN TotalCurrently * 0.14032
	WHEN PublicCode ='VECV30-030' THEN TotalCurrently * 0.14036
	WHEN PublicCode ='VECV30-031' THEN TotalCurrently * 0.14036
	WHEN PublicCode ='VECV27-W21' THEN TotalCurrently * 0.09700
	WHEN PublicCode ='VECVT27-001' THEN TotalCurrently * 0.14032
	WHEN PublicCode ='VECW27-001' THEN TotalCurrently * 0.06716
	WHEN PublicCode ='VECW27-003' THEN TotalCurrently * 0.14032
	WHEN PublicCode ='VECW27-005' THEN TotalCurrently * 0.09700
	WHEN PublicCode ='VECW27-W15' THEN TotalCurrently * 0.14032
	WHEN PublicCode ='VECW27-012' THEN TotalCurrently * 0.09700
	WHEN PublicCode ='VECW27-016' THEN TotalCurrently * 0.09700
	WHEN PublicCode ='VECW27-020' THEN TotalCurrently * 0.09700
	WHEN PublicCode ='VECVT30-317' THEN TotalCurrently * 0.14041
	WHEN PublicCode ='VECV30-051' THEN TotalCurrently * 0.14036
	WHEN PublicCode ='VECV30-033' THEN TotalCurrently * 0.14032
	WHEN PublicCode ='VECV30-052' THEN TotalCurrently * 0.14032
	WHEN PublicCode ='VECV30-037' THEN TotalCurrently * 0.14032
	WHEN PublicCode ='VECV30-038' THEN TotalCurrently * 0.14032
	WHEN PublicCode ='VECV30-W37' THEN TotalCurrently * 0.14032
	WHEN PublicCode ='VECV30-039 ' THEN TotalCurrently * 0.14032
	WHEN PublicCode ='VECV30-043' THEN TotalCurrently * 0.14032
	WHEN PublicCode ='VECW30-001' THEN TotalCurrently * 0.14032
	WHEN PublicCode ='VECW30-0320.6T' THEN TotalCurrently * 0.14032
	WHEN PublicCode ='VECW30-032' THEN TotalCurrently * 0.14032
	WHEN PublicCode ='VECW30-004' THEN TotalCurrently * 0.14036
	WHEN PublicCode ='VECW30-005' THEN TotalCurrently * 0.14036
	WHEN PublicCode ='VECW30-006' THEN TotalCurrently * 0.14036
	WHEN PublicCode ='VECW30-007' THEN TotalCurrently * 0.14041
	WHEN PublicCode ='VECWT30-007' THEN TotalCurrently * 0.14041
	WHEN PublicCode ='VECW30-008' THEN TotalCurrently * 0.14032
	WHEN PublicCode ='VECW30-012' THEN TotalCurrently * 0.14036
	WHEN PublicCode ='VECW30-010' THEN TotalCurrently * 0.14036
	WHEN PublicCode ='VECW30-010' THEN TotalCurrently * 0.14036
	WHEN PublicCode ='VECW30-35' THEN TotalCurrently * 0.14036
	WHEN PublicCode ='VECW30-013' THEN TotalCurrently * 0.14041
	WHEN PublicCode ='VECW30-033' THEN TotalCurrently * 0.19914
	WHEN PublicCode ='VECW30-034' THEN TotalCurrently * 0.14036
	WHEN PublicCode ='VECW30-014' THEN TotalCurrently * 0.14036
	WHEN PublicCode ='VECW27-W16' THEN TotalCurrently * 0.09700
	WHEN PublicCode ='VECW30-SW17' THEN TotalCurrently * 0.14036
	WHEN PublicCode ='VECW30-017' THEN TotalCurrently * 0.14036
	WHEN PublicCode ='VECW30-022' THEN TotalCurrently * 0.14041
	WHEN PublicCode ='VECW30-025' THEN TotalCurrently * 0.14036
	WHEN PublicCode ='VECW30-023' THEN TotalCurrently * 0.14036
	WHEN PublicCode ='VECW30-029' THEN TotalCurrently * 0.14036
	WHEN PublicCode ='VECW30-030' THEN TotalCurrently * 0.14036
	WHEN PublicCode ='VECW30-036' THEN TotalCurrently * 0.14036
	WHEN PublicCode ='VHCV23-002' THEN TotalCurrently * 3.16011
	WHEN PublicCode ='VHCV23-006' THEN TotalCurrently * 0.14041
	WHEN PublicCode ='VHCV23-004' THEN TotalCurrently * 0.14041
	WHEN PublicCode ='VNVEC27-001' THEN TotalCurrently * 0.06716
	WHEN PublicCode ='VNVEC27-003' THEN TotalCurrently * 0.14032
	WHEN PublicCode ='VNVEC27-002' THEN TotalCurrently * 0.06716
	WHEN PublicCode ='VNVEC27-004' THEN TotalCurrently * 0.14032
	WHEN PublicCode ='VNVEC27-005' THEN TotalCurrently * 0.06716
	WHEN PublicCode ='VNVEC27-008' THEN TotalCurrently * 0.14032
	WHEN PublicCode ='VMVCV120-101' THEN TotalCurrently * 0.14041
	WHEN PublicCode ='VNVEC27-011' THEN TotalCurrently * 0.14363
	WHEN PublicCode ='VNVEC27-012' THEN TotalCurrently * 0.09700
	WHEN PublicCode ='VNVEC27-014' THEN TotalCurrently * 0.14041
	WHEN PublicCode ='VNVEC27-016' THEN TotalCurrently * 0.09700
	WHEN PublicCode ='VNVEC27-018' THEN TotalCurrently *  0.09700
	WHEN PublicCode ='VNVEC27-020' THEN TotalCurrently * 0.09700
	WHEN PublicCode ='VNVEC27-023' THEN TotalCurrently * 0.09700
	WHEN PublicCode ='VNVEC27-028' THEN TotalCurrently * 0.14032
	WHEN PublicCode ='MVCV60-909' THEN TotalCurrently * 0.14041
	WHEN PublicCode ='VNVEC27-032' THEN TotalCurrently * 0.14032
	WHEN PublicCode ='VNVEC30-001' THEN TotalCurrently * 0.14041
	WHEN PublicCode ='VNVEC30-004' THEN TotalCurrently * 0.14036
	WHEN PublicCode ='VNVEC27-035' THEN TotalCurrently * 0.14032
	WHEN PublicCode ='VNVEC30-006' THEN TotalCurrently * 0.14036
	WHEN PublicCode ='VNVEC30-007' THEN TotalCurrently * 0.14036
	WHEN PublicCode ='VNVEC30-008' THEN TotalCurrently * 0.14032
	WHEN PublicCode ='VNVEC30-012' THEN TotalCurrently * 0.14036
	WHEN PublicCode ='VNVEC30-013' THEN TotalCurrently * 0.14036
	WHEN PublicCode ='VNVEC30-014' THEN TotalCurrently * 0.14039
	WHEN PublicCode ='VNVEC30-016' THEN TotalCurrently * 0.14036
	WHEN PublicCode ='VNVEC27-049' THEN TotalCurrently * 0.09700
	WHEN PublicCode ='VNVEC30-017' THEN TotalCurrently * 0.14036
	WHEN PublicCode ='VNVEC30-022' THEN TotalCurrently * 0.14036
	WHEN PublicCode ='VNVEC30-018' THEN TotalCurrently * 0.14041
	WHEN PublicCode ='VNVEC30-023' THEN TotalCurrently * 0.14036
	WHEN PublicCode ='VNVEC30-033' THEN TotalCurrently * 0.14032
	WHEN PublicCode ='VNVECT30-001' THEN TotalCurrently * 0.14041
	WHEN PublicCode ='VNWEC27-001' THEN TotalCurrently * 0.06716
	WHEN PublicCode ='VNWEC27-003' THEN TotalCurrently * 0.14032
	WHEN PublicCode ='VNWEC27-005' THEN TotalCurrently * 0.09700
	WHEN PublicCode ='VNWEC27-008' THEN TotalCurrently * 0.14032
	WHEN PublicCode ='VNVHC23-003' THEN TotalCurrently * 0.14041
	WHEN PublicCode ='VNWEC27-011' THEN TotalCurrently * 0.14032
	WHEN PublicCode ='VNWEC27-012' THEN TotalCurrently * 0.09700
	WHEN PublicCode ='VNWEC27-015' THEN TotalCurrently * 0.14032
	WHEN PublicCode ='VNVEC30-045' THEN TotalCurrently * 0.14036
	WHEN PublicCode ='VNVEC30-050' THEN TotalCurrently * 0.14036
	WHEN PublicCode ='VNVHC23-005' THEN TotalCurrently * 3.16001
	WHEN PublicCode ='VNVEC30-051' THEN TotalCurrently * 0.14041
	WHEN PublicCode ='VNVEC30-033' THEN TotalCurrently * 0.14032
	WHEN PublicCode ='VNVEC30-054' THEN TotalCurrently * 0.14041
	WHEN PublicCode ='VNVEC30-037' THEN TotalCurrently * 0.14032
	WHEN PublicCode ='VNVEC30-053' THEN TotalCurrently * 0.14036
	WHEN PublicCode ='VNVEC30-043' THEN TotalCurrently * 0.14032
	WHEN PublicCode ='VNVEC30-038' THEN TotalCurrently * 0.14032
	WHEN PublicCode ='VNVEC30-046 ' THEN TotalCurrently * 0.14032
	WHEN PublicCode ='VNWEC30-941' THEN TotalCurrently * 0.14041
	WHEN PublicCode ='VNWEC30-001' THEN TotalCurrently * 0.14032
	WHEN PublicCode ='VNWEC30-004' THEN TotalCurrently * 0.14036
	WHEN PublicCode ='VNWEC30-005' THEN TotalCurrently * 0.14036
	WHEN PublicCode ='VNWEC30-032' THEN TotalCurrently * 0.14032
	WHEN PublicCode ='VNWEC30-006' THEN TotalCurrently * 0.14036
	WHEN PublicCode ='VNWEC30-007' THEN TotalCurrently * 0.14041
	WHEN PublicCode ='VNWEC30-008' THEN TotalCurrently * 0.14032
	WHEN PublicCode ='VNWEC30-012' THEN TotalCurrently * 0.14036
	WHEN PublicCode ='VNWEC27-011' THEN TotalCurrently * 0.14032
	WHEN PublicCode ='VNWEC30-013' THEN TotalCurrently * 0.14041
	WHEN PublicCode ='VNWEC30-035' THEN TotalCurrently * 0.14036
	WHEN PublicCode ='VNWEC30-014' THEN TotalCurrently * 0.14036
	WHEN PublicCode ='VNWEC30-034' THEN TotalCurrently * 0.14036
	WHEN PublicCode ='VNWEC30-037' THEN TotalCurrently * 0.14041
	WHEN PublicCode ='VNWEC30-017' THEN TotalCurrently * 0.14036
	WHEN PublicCode ='VNWEC30-018' THEN TotalCurrently * 0.14036
	WHEN PublicCode ='VNWEC30-022' THEN TotalCurrently * 0.14041
	WHEN PublicCode ='VNWEC27-020' THEN TotalCurrently * 0.09700
	WHEN PublicCode ='VNWEC30-023' THEN TotalCurrently * 0.14036
	WHEN PublicCode ='VNWEC30-025' THEN TotalCurrently * 0.14036
	WHEN PublicCode ='VNWEC30-040' THEN TotalCurrently * 0.14041
	WHEN PublicCode ='VNWEC30-030' THEN TotalCurrently * 0.14036
	WHEN PublicCode ='VNWECT30-001' THEN TotalCurrently * 0.14041
	WHEN PublicCode ='VVWEC30-004' THEN TotalCurrently * 0.14036
	WHEN PublicCode ='VNWECT30-004' THEN TotalCurrently * 0.14036
	WHEN PublicCode ='VNWECT30-007' THEN TotalCurrently * 0.14036
	WHEN PublicCode ='VNWECT30-013' THEN TotalCurrently * 0.14041
	WHEN PublicCode ='VVVEC27-012' THEN TotalCurrently * 0.09700
	WHEN PublicCode ='VNWECT30-014' THEN TotalCurrently * 0.14041
	WHEN PublicCode ='VNWECT30-914' THEN TotalCurrently * 0.14041
	WHEN PublicCode ='VNWECT30-022' THEN TotalCurrently * 0.14041
	WHEN PublicCode ='VNWECT30-922' THEN TotalCurrently * 0.14041
	WHEN PublicCode ='VVVEC30-033' THEN TotalCurrently * 0.14032
	WHEN PublicCode ='VVVEC30-037' THEN TotalCurrently * 0.14032
	WHEN PublicCode ='VVVEC30-053' THEN TotalCurrently * 0.14036
	
	ELSE 0.000
	END AS Price
--,

--CASE
--	--WHEN CAST(Qtylocation  AS NVARCHAR(50)) IS NULL AND CAST(TotalSale AS NVARCHAR(50)) IS NULL THEN N'Vẫn ở trong kho'
--	--WHEN CAST(Qtylocation  AS NVARCHAR(50)) IS NOT NULL AND CAST(TotalSale AS NVARCHAR(50)) IS NOT NULL THEN N'Xuất nội bộ, và xuất bán hàng'
--	WHEN CAST(Qtylocation AS NVARCHAR(50)) IS NOT NULL  THEN N'Xuất nội bộ'
--	WHEN CAST(TotalSale AS NVARCHAR(50)) IS NOT NULL THEN N'Xuất bán hàng'
--	ELSE CAST(QtyInput AS NVARCHAR(50))  
--	END AS StatusSale

FROM CTE
WHERE Flag = 1


END
