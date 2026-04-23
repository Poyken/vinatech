-- =============================================
-- Author: Jeon Gyeong Ho(khjun@awoo.co.kr)
-- Create date: 2018-08-17
-- Browsable : true
-- Group : 팝업
-- Description:	팝업 작업자코드
-- Modified: 생산 작업자를 가져옵니다  

-- TEST :  exec usp_ProdWorkerInfo_Popup 'kilee','Korean','', '', 'C-08,C-09,C-10,C-19'
--          EXEC usp_ProdWorkerInfo_Popup 'kilee','Korean','', '', '' ,NULL
--          EXEC usp_ProdWorkerInfo_Popup 'kilee','Korean','', '', 'C-21,V-21' ,NULL                            -- 품질관련
--          EXEC usp_ProdWorkerInfo_Popup 'kilee','Korean','', '', 'C-20, V-20' ,NULL 
--          EXEC usp_ProdWorkerInfo_Popup 'kilee','Korean','', '', '' ,NULL 
-- =============================================

Create PROCEDURE [dbo].[usp_ProdWorkerInfo_Popup_20201101]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
    @pCompanyCode VARCHAR(20) = NULL,
    @pWorkCenterCode VARCHAR(20) = NULL,
	@pCostGroupString VARCHAR(MAX) = NULL,
	@pRouteCode VARCHAR(20) = NULL                            -- 2019.12.12 추가 (kilee)

AS
BEGIN
	SET NOCOUNT ON;

  --DECLARE @CompanyCode VARCHAR(20) = CASE WHEN ISNULL(@pCompanyCode,'') = '' THEN '%' ELSE @pCompanyCode END               -- 원본 백업

 	DECLARE @CompanyCode VARCHAR(20) = CASE WHEN ISNULL(@pCompanyCode,'') = '' AND @pRouteCode = ''      THEN '%' 
	                                                            WHEN ISNULL(@pCompanyCode,'') = '' AND @pRouteCode = NULL THEN '%' 
																WHEN ISNULL(@pCompanyCode,'') = '' AND @pRouteCode IS NULL THEN '%' 
	                                                            WHEN @pRouteCode LIKE 'V%' THEN 'VVT'
																WHEN @pRouteCode LIKE 'E%' THEN 'VNT'	ELSE @pCompanyCode END                   -- 2019.12.12 추가 (kilee)


	--DECLARE @CompanyCode VARCHAR(20) = CASE WHEN ISNULL(@pCompanyCode,'') = '' AND @pRouteCode = ''      THEN '%' 	                                                           
	--                                                            WHEN @pRouteCode LIKE 'V-%' THEN 'VVT'
	--															WHEN @pRouteCode LIKE 'E-%' THEN 'VNT'	ELSE @pCompanyCode END                   -- 2019.12.12 추가 (kilee)


	DECLARE @WorkCenterCode VARCHAR(20) = CASE WHEN ISNULL(@pWorkCenterCode,'') = '' THEN '%' ELSE @pWorkCenterCode END
	DECLARE @CostGroupString VARCHAR(MAX) = ISNULL(@pCostGroupString, '')
    
	IF @CostGroupString = '' 
		
		BEGIN
			SELECT
					PWI.WorkerCode,
					PWI.WorkerName,
					PWI.OrgWorkerName,
					PWI.Nationality,
					PWI.EmpNo
			FROM
					STB_ProdWorkerInfo PWI WITH(NOLOCK)
					LEFT OUTER JOIN STB_CompanyInfo CI WITH(NOLOCK)				ON CI.CompanyCode      = PWI.CompanyCode
					LEFT OUTER JOIN STB_WorkCenterInfo WCI WITH(NOLOCK)		ON WCI.WorkCenterCode = PWI.WorkCenterCode
			WHERE 1=1
			   AND PWI.CompanyCode    LIKE @CompanyCode 
			   AND PWI.WorkCenterCode LIKE @WorkCenterCode 
			   AND PWI.IsUsed = 1
			   AND PWI.IsProdWorker = 1
			   --AND PWI.EMPNO IN ('16030206','16101002','18013101','12060501','18040203','18121002','15090101','19040406','17092402', '18052104','14122202','18070901','19032509', '19012101','15031604', '17081601', '19012101', '19040401')       -- 임시적용 kilee (2019-07-11)
			   -- 원가그룹과 상관없이 모든 현장 작업자를 리스트에 표시함. 2019.09.03 김전식 반장님 요청 By Jackaroe
				--AND PWI.WorkerCode  IN (
				--                                       SELECT WorkerCode
				--										FROM STB_CostGroupWorkerMapping 
				--									   WHERE IsAssigned = 1 
				--										AND CostGroupCode IN (SELECT Item FROM dbo.fnSplitToTable(',', @CostGroupString))
				--										) 
		END ELSE 
	
		BEGIN


			SELECT
					PWI.WorkerCode,
					PWI.WorkerName,
					PWI.OrgWorkerName,
					PWI.Nationality,
					PWI.EmpNo
			FROM
									      STB_ProdWorkerInfo PWI WITH(NOLOCK)
					LEFT OUTER JOIN STB_CompanyInfo CI WITH(NOLOCK)				ON CI.CompanyCode = PWI.CompanyCode
					LEFT OUTER JOIN STB_WorkCenterInfo WCI WITH(NOLOCK)		ON WCI.WorkCenterCode = PWI.WorkCenterCode
			WHERE 1=1
			   AND PWI.CompanyCode    LIKE @CompanyCode 
			   AND PWI.WorkCenterCode LIKE @WorkCenterCode 
			   AND PWI.IsUsed = 1
			   AND PWI.IsProdWorker = 1
				AND PWI.WorkerCode  IN (
													   SELECT WorkerCode
														FROM STB_CostGroupWorkerMapping 
													   WHERE IsAssigned = 1 
														AND CostGroupCode IN (SELECT Item FROM dbo.fnSplitToTable(',', @CostGroupString))
										)            

			--AND ((@CompanyCode = '*') OR (PWI.CompanyCode = @CompanyCode))                                                               -- 2019.11.07 추가

	END

END

-- [사용자가 안 나올때 Data검증방법]

-- 1. STB_ProdWorkerInfo 입력후 IsProdWorker를 1로 추가
--  SELECT *	FROM STB_ProdWorkerInfo              WHERE CompanyCode = 'VVT'  AND WorkerName LIKE '엄제식%'             -- 16022301

-- 2. STB_CostGroupWorkerMapping
-- SELECT *	FROM STB_CostGroupWorkerMapping WHERE CostGroupCode = 'V-21'

--3. STB_CostGroupInfo
-- SELECT *	FROM STB_CostGroupInfo                WHERE CostGroupCode = 'V-21'  

-- select * from STB_ProdWorkerInfo where CompanyCode = 'VVT'

CREATE TABLE STB_EMPLOYEES
(
	ID INT IDENTITY(1,1) NOT NULL,
	EmployeesID NVARCHAR(50) NOT NULL PRIMARY KEY(EmployeesID),
	FullName NVARCHAR(100)  NULL,
	BirthDay DATE NULL,
	Gender NVARCHAR(20) NULL,
	StartWork DATE NULL,
	Department NVARCHAR(50) NULL,
	Position NVARCHAR(50) NULL,
	IsUed BIT NULL
)

SELECT top (1000) * FROM STB_SetInfo