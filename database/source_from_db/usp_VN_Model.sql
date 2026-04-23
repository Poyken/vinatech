CREATE PROC [dbo].[usp_VN_Model]
@pProcessUserID VARCHAR(20),
@pProcessLanguage VARCHAR(20),
@pModelType NVARCHAR(200)='*'
AS
BEGIN
SET NOCOUNT ON;
		--DECLARE @Name NVARCHAR(20)='HY-CAP'
		CREATE TABLE #T1
		(
			CodeModel NVARCHAR(50) PRIMARY KEY(CodeModel) NOT NULL,
			NameModel NVARCHAR(50) NULL
		)

		--INSERT INTO #T1 (CodeModel,NameModel) VALUES (N'0813',N'0813')
		--INSERT INTO #T1 (CodeModel,NameModel) VALUES (N'0820-CY',N'0820-CY')
		--INSERT INTO #T1 (CodeModel,NameModel) VALUES (N'0820-MSP',N'0820-MSP')
		----INSERT INTO #T1 (CodeModel,NameModel) VALUES (N'0825',N'0825')
		----INSERT INTO #T1 (CodeModel,NameModel) VALUES (N'0830',N'0830')
		--INSERT INTO #T1 (CodeModel,NameModel) VALUES (N'1020-5F',N'1020-5F')
		--INSERT INTO #T1 (CodeModel,NameModel) VALUES (N'1020-7F',N'1020-7F')
		--INSERT INTO #T1 (CodeModel,NameModel) VALUES (N'1025-7F',N'1025-7F')
		--INSERT INTO #T1 (CodeModel,NameModel) VALUES (N'1025-10F',N'1025-10F')
		----INSERT INTO #T1 (CodeModel,NameModel) VALUES (N'1030',N'1030')
		--INSERT INTO #T1 (CodeModel,NameModel) VALUES (N'1030-22F',N'1030-22F')
		--INSERT INTO #T1 (CodeModel,NameModel) VALUES (N'1320',N'1320')
		--INSERT INTO #T1 (CodeModel,NameModel) VALUES (N'1325-15F',N'1325-15F')
		--INSERT INTO #T1 (CodeModel,NameModel) VALUES (N'1325-18F',N'1325-18F')
		--INSERT INTO #T1 (CodeModel,NameModel) VALUES (N'1625',N'1625')
		--INSERT INTO #T1 (CodeModel,NameModel) VALUES (N'1346',N'1346')
		--INSERT INTO #T1 (CodeModel,NameModel) VALUES (N'1840-50F',N'1840-50F')
		--INSERT INTO #T1 (CodeModel,NameModel) VALUES (N'1840-60F',N'1840-60F')
		--INSERT INTO #T1 (CodeModel,NameModel) VALUES (N'1840-120F',N'1840-120F')
		--INSERT INTO #T1 (CodeModel,NameModel) VALUES (N'1859',N'1859')
		----INSERT INTO #T1 (CodeModel,NameModel) VALUES (N'3562',N'3562')
		--INSERT INTO #T1 (CodeModel,NameModel) VALUES (N'2570',N'2570')
		--INSERT INTO #T1 (CodeModel,NameModel) VALUES (N'2245-L-100F',N'2245-L-100F')
		--INSERT INTO #T1 (CodeModel,NameModel) VALUES (N'2245-300F',N'2245-300F')
		--INSERT INTO #T1 (CodeModel,NameModel) VALUES (N'2245-220F',N'2245-220F')
		----INSERT INTO #T1 (CodeModel,NameModel) VALUES (N'3582',N'3582')
		--INSERT INTO #T1 (CodeModel,NameModel) VALUES (N'ĐIỆN CỰC-YP85-200',N'ĐIỆN CỰC-YP85-200')
		--INSERT INTO #T1 (CodeModel,NameModel) VALUES (N'ĐIỆN CỰC-YP85-116',N'ĐIỆN CỰC-YP85-116')
		--INSERT INTO #T1 (CodeModel,NameModel) VALUES (N'ĐIỆN CỰC-CY(4:6)-120',N'ĐIỆN CỰC-CY(4:6)-120')
		--INSERT INTO #T1 (CodeModel,NameModel) VALUES (N'ĐIỆN CỰC-CY(4:6)-200',N'ĐIỆN CỰC-CY(4:6)-200')
		--INSERT INTO #T1 (CodeModel,NameModel) VALUES (N'ĐIỆN CỰC-MS83-120',N'ĐIỆN CỰC-MS83-120')
		--INSERT INTO #T1 (CodeModel,NameModel) VALUES (N'ĐIỆN CỰC-MS83-200',N'ĐIỆN CỰC-MS83-200')
		--INSERT INTO #T1 (CodeModel,NameModel) VALUES (N'Socha-16.3+',N'Socha-16.3+')
		--INSERT INTO #T1 (CodeModel,NameModel) VALUES (N'Socha-16.3-',N'Socha-16.3-')
		--INSERT INTO #T1 (CodeModel,NameModel) VALUES (N'Socha-9.8+',N'Socha-9.8+')
		--INSERT INTO #T1 (CodeModel,NameModel) VALUES (N'Socha-9.8-',N'Socha-9.8-')
		--INSERT INTO #T1 (CodeModel,NameModel) VALUES (N'Socha-20.5+',N'Socha-20.5+')
		--INSERT INTO #T1 (CodeModel,NameModel) VALUES (N'Socha-20.5-',N'Socha-20.5-')
		--INSERT INTO #T1 (CodeModel,NameModel) VALUES (N'Giấy ngăn-TF4850',N'Giấy ngăn-TF4850')
		--INSERT INTO #T1 (CodeModel,NameModel) VALUES (N'Giấy ngăn-TF4035',N'Giấy ngăn-TF4035')
		--INSERT INTO #T1 (CodeModel,NameModel) VALUES (N'Giấy ngăn-T2B4035',N'Giấy ngăn-T2B4035')
		--INSERT INTO #T1 (CodeModel,NameModel) VALUES (N'YP85-116-plus',N'YP85-116-plus')
		--INSERT INTO #T1 (CodeModel,NameModel) VALUES (N'YP85-200-plus',N'YP85-200-plus')
		--INSERT INTO #T1 (CodeModel,NameModel) VALUES (N'YP85-116-minus',N'YP85-116-minus')
		--INSERT INTO #T1 (CodeModel,NameModel) VALUES (N'YP85-200-minus',N'YP85-200-minus')
		--INSERT INTO #T1 (CodeModel,NameModel) VALUES (N'MS83-120-plus',N'MS83-120-plus')
		--INSERT INTO #T1 (CodeModel,NameModel) VALUES (N'MS83-200-plus',N'MS83-200-plus')
		--INSERT INTO #T1 (CodeModel,NameModel) VALUES (N'MS83-120-minus',N'MS83-120-minus')
		--INSERT INTO #T1 (CodeModel,NameModel) VALUES (N'MS83-200-minus',N'MS83-200-minus')
		--INSERT INTO #T1 (CodeModel,NameModel) VALUES (N'CY(4:6)-120-plus',N'CY(4:6)-120-plus')
		--INSERT INTO #T1 (CodeModel,NameModel) VALUES (N'CY(4:6)-200-plus',N'CY(4:6)-200-plus')
		--INSERT INTO #T1 (CodeModel,NameModel) VALUES (N'CY(4:6)-120-minus',N'CY(4:6)-120-minus')
		--INSERT INTO #T1 (CodeModel,NameModel) VALUES (N'CY(4:6)-200-minus',N'CY(4:6)-200-minus')
		--INSERT INTO #T1 (CodeModel,NameModel) VALUES (N'0820',N'0820')
		--INSERT INTO #T1 (CodeModel,NameModel) VALUES (N'0830',N'0830')
		--INSERT INTO #T1 (CodeModel,NameModel) VALUES (N'1020',N'1020')
		--INSERT INTO #T1 (CodeModel,NameModel) VALUES (N'1025',N'1025')
		--INSERT INTO #T1 (CodeModel,NameModel) VALUES (N'1030',N'1030')
		--INSERT INTO #T1 (CodeModel,NameModel) VALUES (N'1325',N'1325')
		--INSERT INTO #T1 (CodeModel,NameModel) VALUES (N'3582',N'3582')
		--INSERT INTO #T1 (CodeModel,NameModel) VALUES (N'3567',N'3567')
		--INSERT INTO #T1 (CodeModel,NameModel) VALUES (N'2245',N'2245')
		--INSERT INTO #T1 (CodeModel,NameModel) VALUES (N'3562',N'3562')

		--INSERT INTO #T1 (CodeModel,NameModel) VALUES (N'0813',N'0813')
		--INSERT INTO #T1 (CodeModel,NameModel) VALUES (N'0821 CY',N'0821 CY')
		--INSERT INTO #T1 (CodeModel,NameModel) VALUES (N'0821 MSP',N'0821 MSP')
		--INSERT INTO #T1 (CodeModel,NameModel) VALUES (N'0825',N'0825')
		--INSERT INTO #T1 (CodeModel,NameModel) VALUES (N'0830',N'0830')
		--INSERT INTO #T1 (CodeModel,NameModel) VALUES (N'1020-5F',N'1020-5F')
		--INSERT INTO #T1 (CodeModel,NameModel) VALUES (N'1020-7F',N'1020-7F')
		--INSERT INTO #T1 (CodeModel,NameModel) VALUES (N'1025-7F',N'1025-7F')
		--INSERT INTO #T1 (CodeModel,NameModel) VALUES (N'1025-10F',N'1025-10F')
		--INSERT INTO #T1 (CodeModel,NameModel) VALUES (N'1030',N'1030')
		--INSERT INTO #T1 (CodeModel,NameModel) VALUES (N'1320',N'1320')
		--INSERT INTO #T1 (CodeModel,NameModel) VALUES (N'1325',N'1325')
		--INSERT INTO #T1 (CodeModel,NameModel) VALUES (N'1346',N'1346')
		--INSERT INTO #T1 (CodeModel,NameModel) VALUES (N'1625',N'1625')
		--INSERT INTO #T1 (CodeModel,NameModel) VALUES (N'1830',N'1830')
		--INSERT INTO #T1 (CodeModel,NameModel) VALUES (N'1840-50F',N'1840-50F')
		--INSERT INTO #T1 (CodeModel,NameModel) VALUES (N'1840-60F',N'1840-60F')
		--INSERT INTO #T1 (CodeModel,NameModel) VALUES (N'1859',N'1859')
		--INSERT INTO #T1 (CodeModel,NameModel) VALUES (N'2245-220F',N'2245-220F')
		--INSERT INTO #T1 (CodeModel,NameModel) VALUES (N'2245-300F',N'2245-300F')
		--INSERT INTO #T1 (CodeModel,NameModel) VALUES (N'2245',N'2245')
		--INSERT INTO #T1 (CodeModel,NameModel) VALUES (N'2245-L',N'2245-L')
		--INSERT INTO #T1 (CodeModel,NameModel) VALUES (N'2570',N'2570')
		--INSERT INTO #T1 (CodeModel,NameModel) VALUES (N'3562-360F',N'3562-360F')
		--INSERT INTO #T1 (CodeModel,NameModel) VALUES (N'3562-380F',N'3562-380F')
		--INSERT INTO #T1 (CodeModel,NameModel) VALUES (N'3562-VEP',N'3562-VEP')
		--INSERT INTO #T1 (CodeModel,NameModel) VALUES (N'3582',N'3582')
		--INSERT INTO #T1 (CodeModel,NameModel) VALUES (N'ĐIỆN CỰC CEP 120',N'ĐIỆN CỰC CEP 120')
		--INSERT INTO #T1 (CodeModel,NameModel) VALUES (N'ĐIỆN CỰC CEP 200',N'ĐIỆN CỰC CEP 200')
		--INSERT INTO #T1 (CodeModel,NameModel) VALUES (N'ĐIỆN CỰC MSP 162',N'ĐIỆN CỰC MSP 162')
		--INSERT INTO #T1 (CodeModel,NameModel) VALUES (N'ĐIỆN CỰC MSP 200',N'ĐIỆN CỰC MSP 200')
		--INSERT INTO #T1 (CodeModel,NameModel) VALUES (N'ĐIỆN CỰC YP 116',N'ĐIỆN CỰC YP 116')
		--INSERT INTO #T1 (CodeModel,NameModel) VALUES (N'ĐIỆN CỰC YP 200',N'ĐIỆN CỰC YP 200')
		--INSERT INTO #T1 (CodeModel,NameModel) VALUES (N'ĐIỆN CỰC LM0 100',N'ĐIỆN CỰC LM0 100')
		--INSERT INTO #T1 (CodeModel,NameModel) VALUES (N'GIẤY NGĂN TF4850_8.7mm',N'GIẤY NGĂN TF4850_8.7mm')
		--INSERT INTO #T1 (CodeModel,NameModel) VALUES (N'GIẤY NGĂN TF4850_15.7mm',N'GIẤY NGĂN TF4850_15.7mm')
		--INSERT INTO #T1 (CodeModel,NameModel) VALUES (N'GIẤY NGĂN TF4850_16.7mm',N'GIẤY NGĂN TF4850_16.7mm')
		--INSERT INTO #T1 (CodeModel,NameModel) VALUES (N'GIẤY NGĂN T2B40-35_19.7mm',N'GIẤY NGĂN T2B40-35_19.7mm')
		--INSERT INTO #T1 (CodeModel,NameModel) VALUES (N'GIẤY NGĂN T2B4035_20.7',N'GIẤY NGĂN T2B4035_20.7')
		--INSERT INTO #T1 (CodeModel,NameModel) VALUES (N'GIẤY NGĂN T2B4035_21.7mm',N'GIẤY NGĂN T2B4035_21.7mm')
		--INSERT INTO #T1 (CodeModel,NameModel) VALUES (N'GIẤY NGĂN T2B4035_25.7mm',N'GIẤY NGĂN T2B4035_25.7mm')
		--INSERT INTO #T1 (CodeModel,NameModel) VALUES (N'GIẤY NGĂN T2B4035_30.7(1035)',N'GIẤY NGĂN T2B4035_30.7(1035)')
		--INSERT INTO #T1 (CodeModel,NameModel) VALUES (N'GIẤY NGĂN T2B4035_34mm',N'GIẤY NGĂN T2B4035_34mm')
		--INSERT INTO #T1 (CodeModel,NameModel) VALUES (N'GIẤY NGĂN T2B4035_40mm',N'GIẤY NGĂN T2B4035_40mm')
		--INSERT INTO #T1 (CodeModel,NameModel) VALUES (N'GIẤY NGĂN T2B4035_42.7mm',N'GIẤY NGĂN T2B4035_42.7mm')
		--INSERT INTO #T1 (CodeModel,NameModel) VALUES (N'GIẤY NGĂN T2B4035_53.7mm (1859)',N'GIẤY NGĂN T2B4035_53.7mm (1859)')
		--INSERT INTO #T1 (CodeModel,NameModel) VALUES (N'GIẤY NGĂN T2B4035_56mm',N'GIẤY NGĂN T2B4035_56mm')
		--INSERT INTO #T1 (CodeModel,NameModel) VALUES (N'GIẤY NGĂN TF4035_60mm (3567)',N'GIẤY NGĂN TF4035_60mm (3567)')
		--INSERT INTO #T1 (CodeModel,NameModel) VALUES (N'GIẤY NGĂN T2B4035_65mm',N'GIẤY NGĂN T2B4035_65mm')
		--INSERT INTO #T1 (CodeModel,NameModel) VALUES (N'GIẤY NGĂN T2B4035_76mm',N'GIẤY NGĂN T2B4035_76mm')
		--INSERT INTO #T1 (CodeModel,NameModel) VALUES (N'DUNG DỊCH - 2.3V',N'DUNG DỊCH - 2.3V')
		--INSERT INTO #T1 (CodeModel,NameModel) VALUES (N'DUNG DỊCH -2.7V',N'DUNG DỊCH -2.7V')
		--INSERT INTO #T1 (CodeModel,NameModel) VALUES (N'DUNG DỊCH -3.0V',N'DUNG DỊCH -3.0V')
		--INSERT INTO #T1 (CodeModel,NameModel) VALUES (N'Al Case 0813',N'Al Case 0813')
		--INSERT INTO #T1 (CodeModel,NameModel) VALUES (N'Al Case 0813 Flat',N'Al Case 0813 Flat')
		--INSERT INTO #T1 (CodeModel,NameModel) VALUES (N'Al Case 0820',N'Al Case 0820')
		--INSERT INTO #T1 (CodeModel,NameModel) VALUES (N'Al Case 0820 (20.8)',N'Al Case 0820 (20.8)')
		--INSERT INTO #T1 (CodeModel,NameModel) VALUES (N'Al Case 0825',N'Al Case 0825')
		--INSERT INTO #T1 (CodeModel,NameModel) VALUES (N'Al Case 0830',N'Al Case 0830')
		--INSERT INTO #T1 (CodeModel,NameModel) VALUES (N'Al Case 1020',N'Al Case 1020')
		--INSERT INTO #T1 (CodeModel,NameModel) VALUES (N'Al Case 1025',N'Al Case 1025')
		--INSERT INTO #T1 (CodeModel,NameModel) VALUES (N'Al Case 1030',N'Al Case 1030')
		--INSERT INTO #T1 (CodeModel,NameModel) VALUES (N'Al Case 1035',N'Al Case 1035')
		--INSERT INTO #T1 (CodeModel,NameModel) VALUES (N'Al Case 1320',N'Al Case 1320')
		--INSERT INTO #T1 (CodeModel,NameModel) VALUES (N'Al Case 1325',N'Al Case 1325')
		--INSERT INTO #T1 (CodeModel,NameModel) VALUES (N'Al Case 1346',N'Al Case 1346')
		--INSERT INTO #T1 (CodeModel,NameModel) VALUES (N'Al Case 1625',N'Al Case 1625')
		--INSERT INTO #T1 (CodeModel,NameModel) VALUES (N'Al Case 1635',N'Al Case 1635')
		--INSERT INTO #T1 (CodeModel,NameModel) VALUES (N'Al Case 1830',N'Al Case 1830')
		--INSERT INTO #T1 (CodeModel,NameModel) VALUES (N'Al Case 1840',N'Al Case 1840')
		--INSERT INTO #T1 (CodeModel,NameModel) VALUES (N'Al Case 1859',N'Al Case 1859')
		--INSERT INTO #T1 (CodeModel,NameModel) VALUES (N'Al Case 100F 2245 S (48.8mm)',N'Al Case 100F 2245 S (48.8mm)')
		--INSERT INTO #T1 (CodeModel,NameModel) VALUES (N'Al Case 2245 L (48mm 비드)',N'Al Case 2245 L (48mm 비드)')
		--INSERT INTO #T1 (CodeModel,NameModel) VALUES (N'Al Case 2570',N'Al Case 2570')
		--INSERT INTO #T1 (CodeModel,NameModel) VALUES (N'Al Case 3562',N'Al Case 3562')
		--INSERT INTO #T1 (CodeModel,NameModel) VALUES (N'Al Case 3567',N'Al Case 3567')
		--INSERT INTO #T1 (CodeModel,NameModel) VALUES (N'Al Case 3572',N'Al Case 3572')
		--INSERT INTO #T1 (CodeModel,NameModel) VALUES (N'Al Case 3582',N'Al Case 3582')
		--INSERT INTO #T1 (CodeModel,NameModel) VALUES (N'CAO SU 8mm',N'CAO SU 8mm')
		--INSERT INTO #T1 (CodeModel,NameModel) VALUES (N'CAO SU 10mm',N'CAO SU 10mm')
		--INSERT INTO #T1 (CodeModel,NameModel) VALUES (N'CAO SU 12.5mm',N'CAO SU 12.5mm')
		--INSERT INTO #T1 (CodeModel,NameModel) VALUES (N'CAO SU 16mm',N'CAO SU 16mm')
		--INSERT INTO #T1 (CodeModel,NameModel) VALUES (N'CAO SU 18mm',N'CAO SU 18mm')
		
		INSERT INTO #T1 (CodeModel,NameModel) VALUES (N'ĐIỆN CỰC CY 120',N'ĐIỆN CỰC CY 120')
		INSERT INTO #T1 (CodeModel,NameModel) VALUES (N'ĐIỆN CỰC CY 200',N'ĐIỆN CỰC CY 200')
		INSERT INTO #T1 (CodeModel,NameModel) VALUES (N'ĐIỆN CỰC MSP 162',N'ĐIỆN CỰC MSP 162')
		INSERT INTO #T1 (CodeModel,NameModel) VALUES (N'ĐIỆN CỰC MSP 200',N'ĐIỆN CỰC MSP 200')
		INSERT INTO #T1 (CodeModel,NameModel) VALUES (N'ĐIỆN CỰC YP 116',N'ĐIỆN CỰC YP 116')
		INSERT INTO #T1 (CodeModel,NameModel) VALUES (N'ĐIỆN CỰC YP 200',N'ĐIỆN CỰC YP 200')
		INSERT INTO #T1 (CodeModel,NameModel) VALUES (N'GIẤY NGĂN_8.7mm (0813)',N'GIẤY NGĂN_8.7mm (0813)')
		INSERT INTO #T1 (CodeModel,NameModel) VALUES (N'GIẤY NGĂN_15.7mm (0820,1020)',N'GIẤY NGĂN_15.7mm (0820,1020)')
		INSERT INTO #T1 (CodeModel,NameModel) VALUES (N'GIẤY NGĂN_16.7mm (1320)',N'GIẤY NGĂN_16.7mm (1320)')
		INSERT INTO #T1 (CodeModel,NameModel) VALUES (N'GIẤY NGĂN_19mm',N'GIẤY NGĂN_19mm')
		INSERT INTO #T1 (CodeModel,NameModel) VALUES (N'GIẤY NGĂN_19.7mm (1025,1625)',N'GIẤY NGĂN_19.7mm (1025,1625)')
		INSERT INTO #T1 (CodeModel,NameModel) VALUES (N'GIẤY NGĂN_20.7mm (0825)',N'GIẤY NGĂN_20.7mm (0825)')
		INSERT INTO #T1 (CodeModel,NameModel) VALUES (N'GIẤY NGĂN_21.7mm (1325)',N'GIẤY NGĂN_21.7mm (1325)')
		INSERT INTO #T1 (CodeModel,NameModel) VALUES (N'GIẤY NGĂN_25.7mm (L30)',N'GIẤY NGĂN_25.7mm (L30)')
		INSERT INTO #T1 (CodeModel,NameModel) VALUES (N'GIẤY NGĂN_30.7 (1035)',N'GIẤY NGĂN_30.7 (1035)')
		INSERT INTO #T1 (CodeModel,NameModel) VALUES (N'GIẤY NGĂN_34mm (1840)',N'GIẤY NGĂN_34mm (1840)')
		INSERT INTO #T1 (CodeModel,NameModel) VALUES (N'GIẤY NGĂN_40mm (2245)',N'GIẤY NGĂN_40mm (2245)')
		INSERT INTO #T1 (CodeModel,NameModel) VALUES (N'GIẤY NGĂN_42.7mm (1346)',N'GIẤY NGĂN_42.7mm (1346)')
		INSERT INTO #T1 (CodeModel,NameModel) VALUES (N'GIẤY NGĂN_53.7mm (1859)',N'GIẤY NGĂN_53.7mm (1859)')
		INSERT INTO #T1 (CodeModel,NameModel) VALUES (N'GIẤY NGĂN_56mm (3562)',N'GIẤY NGĂN_56mm (3562)')
		INSERT INTO #T1 (CodeModel,NameModel) VALUES (N'GIẤY NGĂN_60mm (3567)',N'GIẤY NGĂN_60mm (3567)')
		INSERT INTO #T1 (CodeModel,NameModel) VALUES (N'GIẤY NGĂN_65mm (2570)',N'GIẤY NGĂN_65mm (2570)')
		INSERT INTO #T1 (CodeModel,NameModel) VALUES (N'GIẤY NGĂN_76mm (3582)',N'GIẤY NGĂN_76mm (3582)')
		INSERT INTO #T1 (CodeModel,NameModel) VALUES (N'DUNG DỊCH -2.3V',N'DUNG DỊCH -2.3V')
		INSERT INTO #T1 (CodeModel,NameModel) VALUES (N'DUNG DỊCH -2.7V',N'DUNG DỊCH -2.7V')
		INSERT INTO #T1 (CodeModel,NameModel) VALUES (N'DUNG DỊCH -3.0V',N'DUNG DỊCH -3.0V')
		INSERT INTO #T1 (CodeModel,NameModel) VALUES (N'DUNG DỊCH 3.8V',N'DUNG DỊCH 3.8V')
		INSERT INTO #T1 (CodeModel,NameModel) VALUES (N'CAO SU 8mm',N'CAO SU 8mm')
		INSERT INTO #T1 (CodeModel,NameModel) VALUES (N'CAO SU 10mm',N'CAO SU 10mm')
		INSERT INTO #T1 (CodeModel,NameModel) VALUES (N'CAO SU 12.5mm',N'CAO SU 12.5mm')
		INSERT INTO #T1 (CodeModel,NameModel) VALUES (N'CAO SU 16mm',N'CAO SU 16mm')
		INSERT INTO #T1 (CodeModel,NameModel) VALUES (N'CAO SU 18mm',N'CAO SU 18mm')
		INSERT INTO #T1 (CodeModel,NameModel) VALUES (N'TANCHA PAN PHI 22',N'TANCHA PAN PHI 22')
		INSERT INTO #T1 (CodeModel,NameModel) VALUES (N'TANCHA PAN PHI 25',N'TANCHA PAN PHI 25')
		INSERT INTO #T1 (CodeModel,NameModel) VALUES (N'TANCHA PAN PHI 35',N'TANCHA PAN PHI 35')
		INSERT INTO #T1 (CodeModel,NameModel) VALUES (N'TANCHA CUỘN ATL 2005',N'TANCHA CUỘN ATL 2005')
		INSERT INTO #T1 (CodeModel,NameModel) VALUES (N'VỎ NHÔM_Al Case 0813 Flat',N'VỎ NHÔM_Al Case 0813 Flat')
		INSERT INTO #T1 (CodeModel,NameModel) VALUES (N'VỎ NHÔM_Al Case 0820',N'VỎ NHÔM_Al Case 0820')
		INSERT INTO #T1 (CodeModel,NameModel) VALUES (N'VỎ NHÔM_Al Case 0825',N'VỎ NHÔM_Al Case 0825')
		INSERT INTO #T1 (CodeModel,NameModel) VALUES (N'VỎ NHÔM_Al Case 0830',N'VỎ NHÔM_Al Case 0830')
		INSERT INTO #T1 (CodeModel,NameModel) VALUES (N'VỎ NHÔM_Al Case 1020',N'VỎ NHÔM_Al Case 1020')
		INSERT INTO #T1 (CodeModel,NameModel) VALUES (N'VỎ NHÔM_Al Case 1025',N'VỎ NHÔM_Al Case 1025')
		INSERT INTO #T1 (CodeModel,NameModel) VALUES (N'VỎ NHÔM_Al Case 1030',N'VỎ NHÔM_Al Case 1030')
		INSERT INTO #T1 (CodeModel,NameModel) VALUES (N'VỎ NHÔM_Al Case 1035',N'VỎ NHÔM_Al Case 1035')
		INSERT INTO #T1 (CodeModel,NameModel) VALUES (N'VỎ NHÔM_Al Case 1320',N'VỎ NHÔM_Al Case 1320')
		INSERT INTO #T1 (CodeModel,NameModel) VALUES (N'VỎ NHÔM_Al Case 1325',N'VỎ NHÔM_Al Case 1325')
		INSERT INTO #T1 (CodeModel,NameModel) VALUES (N'VỎ NHÔM_Al Case 1346',N'VỎ NHÔM_Al Case 1346')
		INSERT INTO #T1 (CodeModel,NameModel) VALUES (N'VỎ NHÔM_Al Case 1625',N'VỎ NHÔM_Al Case 1625')
		INSERT INTO #T1 (CodeModel,NameModel) VALUES (N'VỎ NHÔM_Al Case 1635',N'VỎ NHÔM_Al Case 1635')
		INSERT INTO #T1 (CodeModel,NameModel) VALUES (N'VỎ NHÔM_Al Case 1830',N'VỎ NHÔM_Al Case 1830')
		INSERT INTO #T1 (CodeModel,NameModel) VALUES (N'VỎ NHÔM_Al Case 1840',N'VỎ NHÔM_Al Case 1840')
		INSERT INTO #T1 (CodeModel,NameModel) VALUES (N'VỎ NHÔM_Al Case 1859',N'VỎ NHÔM_Al Case 1859')
		INSERT INTO #T1 (CodeModel,NameModel) VALUES (N'VỎ NHÔM_Al Case 100F 2245 S (48.8mm)',N'VỎ NHÔM_Al Case 100F 2245 S (48.8mm)')
		INSERT INTO #T1 (CodeModel,NameModel) VALUES (N'VỎ NHÔM_Al Case 2245 L (48mm 비드)',N'VỎ NHÔM_Al Case 2245 L (48mm 비드)')
		INSERT INTO #T1 (CodeModel,NameModel) VALUES (N'VỎ NHÔM_Al Case 2570',N'VỎ NHÔM_Al Case 2570')
		INSERT INTO #T1 (CodeModel,NameModel) VALUES (N'VỎ NHÔM_Al Case 3562',N'VỎ NHÔM_Al Case 3562')
		INSERT INTO #T1 (CodeModel,NameModel) VALUES (N'VỎ NHÔM_Al Case 3567',N'VỎ NHÔM_Al Case 3567')
		INSERT INTO #T1 (CodeModel,NameModel) VALUES (N'VỎ NHÔM_Al Case 3572',N'VỎ NHÔM_Al Case 3572')
		INSERT INTO #T1 (CodeModel,NameModel) VALUES (N'VỎ NHÔM_Al Case 3582',N'VỎ NHÔM_Al Case 3582')
		INSERT INTO #T1 (CodeModel,NameModel) VALUES (N'MODULE_THIẾC PHẾ ( 99.3+99.9)',N'MODULE_THIẾC PHẾ ( 99.3+99.9)')
		INSERT INTO #T1 (CodeModel,NameModel) VALUES (N'MODULE_DÂY NG',N'MODULE_DÂY NG')
		INSERT INTO #T1 (CodeModel,NameModel) VALUES (N'MODULE_PCB NG',N'MODULE_PCB NG')


		--INSERT INTO #T1 (CodeModel,NameModel) VALUES (N'VỎ BỌC_CELL ĐƠN',N'VỎ BỌC_CELL ĐƠN')
		--INSERT INTO #T1 (CodeModel,NameModel) VALUES (N'VỎ BỌC_MODULE',N'VỎ BỌC_MODULE')


		INSERT INTO #T1 (CodeModel,NameModel) VALUES (N'VỎ BỌC_1020',            N'VỎ BỌC_1020')
		INSERT INTO #T1 (CodeModel,NameModel) VALUES (N'VỎ BỌC_1025',			 N'VỎ BỌC_1025')
		INSERT INTO #T1 (CodeModel,NameModel) VALUES (N'VỎ BỌC_1030',			 N'VỎ BỌC_1030')
		INSERT INTO #T1 (CodeModel,NameModel) VALUES (N'VỎ BỌC_1035',			 N'VỎ BỌC_1035')
		INSERT INTO #T1 (CodeModel,NameModel) VALUES (N'VỎ BỌC_1320',			 N'VỎ BỌC_1320')
		INSERT INTO #T1 (CodeModel,NameModel) VALUES (N'VỎ BỌC_1325',			 N'VỎ BỌC_1325')
		INSERT INTO #T1 (CodeModel,NameModel) VALUES (N'VỎ BỌC_1346',			 N'VỎ BỌC_1346')
		INSERT INTO #T1 (CodeModel,NameModel) VALUES (N'VỎ BỌC_1625',			 N'VỎ BỌC_1625')
		INSERT INTO #T1 (CodeModel,NameModel) VALUES (N'VỎ BỌC_1635',			 N'VỎ BỌC_1635')
		INSERT INTO #T1 (CodeModel,NameModel) VALUES (N'VỎ BỌC_1840',			 N'VỎ BỌC_1840')
		INSERT INTO #T1 (CodeModel,NameModel) VALUES (N'VỎ BỌC_1859',			 N'VỎ BỌC_1859')
		INSERT INTO #T1 (CodeModel,NameModel) VALUES (N'VỎ BỌC_2245',			 N'VỎ BỌC_2245')
		INSERT INTO #T1 (CodeModel,NameModel) VALUES (N'VỎ BỌC_2570',			 N'VỎ BỌC_2570')
		INSERT INTO #T1 (CodeModel,NameModel) VALUES (N'VỎ BỌC_3562',			 N'VỎ BỌC_3562')
		INSERT INTO #T1 (CodeModel,NameModel) VALUES (N'VỎ BỌC_3567',			 N'VỎ BỌC_3567')
		INSERT INTO #T1 (CodeModel,NameModel) VALUES (N'VỎ BỌC_3571',			 N'VỎ BỌC_3571')
		INSERT INTO #T1 (CodeModel,NameModel) VALUES (N'VỎ BỌC_3582',			 N'VỎ BỌC_3582')
		INSERT INTO #T1 (CodeModel,NameModel) VALUES (N'VỎ BỌC_0612',			 N'VỎ BỌC_0612')
		INSERT INTO #T1 (CodeModel,NameModel) VALUES (N'VỎ BỌC_0813',			 N'VỎ BỌC_0813')
		INSERT INTO #T1 (CodeModel,NameModel) VALUES (N'VỎ BỌC_0816',			 N'VỎ BỌC_0816')
		INSERT INTO #T1 (CodeModel,NameModel) VALUES (N'VỎ BỌC_0820',			 N'VỎ BỌC_0820')
		INSERT INTO #T1 (CodeModel,NameModel) VALUES (N'VỎ BỌC_0825',			 N'VỎ BỌC_0825')
		INSERT INTO #T1 (CodeModel,NameModel) VALUES (N'VỎ BỌC_0830',			 N'VỎ BỌC_0830')
		INSERT INTO #T1 (CodeModel,NameModel) VALUES (N'VỎ BỌC_0813 Module',	 N'VỎ BỌC_0813 Module')
		INSERT INTO #T1 (CodeModel,NameModel) VALUES (N'VỎ BỌC_0820 Module',	 N'VỎ BỌC_0820 Module')
		INSERT INTO #T1 (CodeModel,NameModel) VALUES (N'VỎ BỌC_0825 Module',	 N'VỎ BỌC_0825 Module')
		INSERT INTO #T1 (CodeModel,NameModel) VALUES (N'VỎ BỌC_1020 Module',	 N'VỎ BỌC_1020 Module')
		INSERT INTO #T1 (CodeModel,NameModel) VALUES (N'VỎ BỌC_1025 Module',	 N'VỎ BỌC_1025 Module')
		INSERT INTO #T1 (CodeModel,NameModel) VALUES (N'VỎ BỌC_1030 Module',	 N'VỎ BỌC_1030 Module')
		INSERT INTO #T1 (CodeModel,NameModel) VALUES (N'VỎ BỌC_1320 Module',	 N'VỎ BỌC_1320 Module')
		INSERT INTO #T1 (CodeModel,NameModel) VALUES (N'VỎ BỌC_1325 Module',	 N'VỎ BỌC_1325 Module')
		INSERT INTO #T1 (CodeModel,NameModel) VALUES (N'VỎ BỌC_1840 Module',	 N'VỎ BỌC_1840 Module')
		INSERT INTO #T1 (CodeModel,NameModel) VALUES (N'VỎ BỌC_1859 Module',	 N'VỎ BỌC_1859 Module')
		INSERT INTO #T1 (CodeModel,NameModel) VALUES (N'VỎ BỌC_0816 Module',     N'VỎ BỌC_0816 Module')
		

		INSERT INTO #T1 (CodeModel,NameModel) VALUES (N'ĐIỆN CỰC NCM-105',N'ĐIỆN CỰC NCM-105')
		INSERT INTO #T1 (CodeModel,NameModel) VALUES (N'ĐIỆN CỰC PSCAM-120F',N'ĐIỆN CỰC PSCAM-120F')
		

		--tran sao yeu cau ngay 25 thang 8 , 2022
		INSERT INTO #T1 (CodeModel,NameModel) VALUES (N'Tancha 9.8 (+)'		,N'Tancha 9.8 (+)'		)--	0.1077
		INSERT INTO #T1 (CodeModel,NameModel) VALUES (N'Tancha 9.8 (-)'		,N'Tancha 9.8 (-)'		)--	0.099
		INSERT INTO #T1 (CodeModel,NameModel) VALUES (N'Tancha 16.3 (+)'	,N'Tancha 16.3 (+)'		)--	0.1072
		INSERT INTO #T1 (CodeModel,NameModel) VALUES (N'Tancha 16.3 (-)'	,N'Tancha 16.3 (-)'		)--	0.0965
		INSERT INTO #T1 (CodeModel,NameModel) VALUES (N'Tancha 16.3 (+)-L'	,N'Tancha 16.3 (+)-L'	)--	0.1406
		INSERT INTO #T1 (CodeModel,NameModel) VALUES (N'Tancha 16.3 (-)-L'	,N'Tancha 16.3 (-)-L'	)--	0.13025
		INSERT INTO #T1 (CodeModel,NameModel) VALUES (N'Tancha VPC (+)'		,N'Tancha VPC (+)'		)--	0.1258
		INSERT INTO #T1 (CodeModel,NameModel) VALUES (N'Tancha VPC (-)'		,N'Tancha VPC (-)'		)--	0.1736
		INSERT INTO #T1 (CodeModel,NameModel) VALUES (N'Tancha 20.5 (+)'	,N'Tancha 20.5 (+)'		)--	0.1909
		INSERT INTO #T1 (CodeModel,NameModel) VALUES (N'Tancha 20.5 (-)'	,N'Tancha 20.5 (-)'		)--	0.17
		

		SELECT 
				CodeModel,
				NameModel

		FROM #T1
		where 1=1
		and @pModelType='*' 
		or NameModel like SUBSTRING(@pModelType,1,6) +'%'
		or NameModel like SUBSTRING(replace(@pModelType,' ',''),1,6) +'%'
		ORDER BY CodeModel DESC



--		SELECT CodeModel, COUNT(*)
--FROM #T1
--GROUP BY CodeModel
--HAVING COUNT(*) > 1

		DROP TABLE #T1

		--SELECT DISTINCT  MaterialCode AS CodeModel,
		--	   MaterialName AS NameModel
		--	FROM STB_MaterialMaster
		--	WHERE MaterialName LIKE '%' + @Name + '%'
			--WHERE IsUsed='1'
END
