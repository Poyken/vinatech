CREATE PROCEDURE usp_GetElectrodeCommInspectionHistory_jackaroe
						@pProcessUserID VARCHAR(20),
						@pProcessLanguage VARCHAR(20),
						@pCompanyCode VARCHAR(20) = NULL,
						@pWorkCenterCode VARCHAR(20) = NULL,
						@pFromDate DATE = NULL,
						@pToDate DATE = NULL,
						@pCommInspTypeCode VARCHAR(50) = NULL,
						@pIsFinished BIT = NULL,
						@pBarcode VARCHAR(20) = NULL
AS

BEGIN
    DECLARE @CompanyCode VARCHAR(20)    = CASE WHEN ISNULL(@pCompanyCode,'') = '' THEN '*' ELSE @pCompanyCode END
    DECLARE @WorkCenterCode VARCHAR(20) = CASE WHEN ISNULL(@pWorkCenterCode,'') = '' THEN '*' ELSE @pWorkCenterCode END
    DECLARE @FromDate DATE = @pFromDate
	DECLARE @ToDate    DATE = @pToDate
	DECLARE @CommInspTypeCode VARCHAR(50) = CASE WHEN ISNULL(@pCommInspTypeCode,'') = '' THEN '*' ELSE @pCommInspTypeCode END
	DECLARE @IsFinished BIT = @pIsFinished
	DECLARE @Barcode   VARCHAR(20) = CASE WHEN ISNULL(@pBarcode, '') = '' THEN '*' ELSE @pBarcode END                                                             -- 추가사항    

   -- 조회부분
    SELECT A.사업장 
	      ,A.OldCommInspDocNo
		  ,A.CommInspDocNo
		  ,A.CommInspTypeCode
		  ,A.CommInspTypeName
		  ,A.CommInspTypeDesc
		  ,A.CompanyCode
		  ,A.WorkCenterCode
		  ,A.MaterialCode
		  ,A.MaterialName
		  ,A.MaterialTypeCode
		  ,A.ProductGroupCode
		  ,A.RefDocNo
		  ,A.Barcode
		  ,A.PONo
		  ,A.JobDate
		  ,A.ShiftCode
		  ,A.InspTimeCode
		  ,A.CategoryName
		  ,A.ProdNo
		  ,A.IsFinished
		  ,A.IsFix
		  ,A.DocDesc
		  ,A.InspUserID
		  ,A.CreateDateTime
		  ,A.CreateUserID
		  ,A.ChangeDateTime
		  ,A.ChangeUserID
		  ,A.CIDHExtText02                            -- 비고내용     
		  --,dbo.fnGetElectrodeDensity (A.CommInspDocNo, 1)  AS Thickness_Left              
		  --,dbo.fnGetElectrodeDensity (A.CommInspDocNo, 2)  AS  Thickness_Center         
		  --,dbo.fnGetElectrodeDensity (A.CommInspDocNo, 3)  AS Thickness_Right         
		  ,A.WorkerCode
		  ,A.WorkerName
		  ,A.RollingDensityMin
		  ,A.RollingDensityMax
		  --,dbo.fnGetElectrodeThickness01(A.CommInspDocNo) AS ElectrodeThickness01           -- 전극두께부분 (Funtion으로 구성함)
		  --,dbo.fnGetElectrodeThickness02(A.CommInspDocNo) AS ElectrodeThickness02
		  --,dbo.fnGetElectrodeThickness03(A.CommInspDocNo) AS ElectrodeThickness03
	  FROM (
			SELECT
					CASE WHEN CIDH.ComPanyCode = 'VNT' THEN '전주본사'
						 WHEN CIDH.ComPanyCode = 'VVT' THEN '베트남'     ELSE '기타' END   AS 사업장,
					CIDH.CommInspDocNo AS OldCommInspDocNo,
					CIDH.CommInspDocNo,
					CIDH.CommInspTypeCode,
					CITI.CommInspTypeName,
					CITI.CommInspTypeDesc,
					CIDH.CompanyCode,
					CIDH.WorkCenterCode,
					CIDH.MaterialCode,
					M.MaterialName,
					M.MaterialTypeCode,
					M.ProductGroupCode,
					CIDH.RefDocNo,
					ISNULL(SI.Barcode, CIDH.ElectrodeLotNumber) AS Barcode, --#201006
					SI.PONo,
					CIDH.JobDate,
					CIDH.ShiftCode,
					CIDH.InspTimeCode,
					CIDH.CategoryName,
					CIDH.ProdNo,
					ISNULL(CIDH.IsFinished,0) AS IsFinished,
					ISNULL(SI.IsFinalInspection,0) AS IsFix,
					CIDH.DocDesc,
					CIDH.InspUserID,
					CIDH.CreateDateTime,
					CIDH.CreateUserID,
					CIDH.ChangeDateTime,
					CIDH.ChangeUserID,
					CIDH.CIDHExtText02                            -- 비고내용     
					, CIMH.InspWorkerCode AS WorkerCode
					, PWI.WorkerName
					, Max(EC.RollingDensityMin) AS RollingDensityMin   --압연밀도하한
					, Max(EC.RollingDensityMax) AS RollingDensityMax  --압연밀도상한
			FROM    STB_CommInspDocHistory  CIDH WITH(NOLOCK)
					LEFT OUTER JOIN STB_CommInspTypeInfo      CITI  WITH(NOLOCK)	  ON CITI.CommInspTypeCode = CIDH.CommInspTypeCode
					LEFT OUTER JOIN STB_MaterialMaster               M  WITH(NOLOCK) ON M.MaterialCode = CIDH.MaterialCode
					LEFT OUTER JOIN STB_SetInfo                         SI  WITH(NOLOCK)  ON SI.ControlNo = CIDH.ProdNo			
	     
					LEFT OUTER JOIN  ( 
											   SELECT CommInspDocNo, CommInspDocItemNo, CommInspInputType
														, CommInspItemCode
												 FROM STB_CommInspDocItem
												 WHERE CommInspItemCode IN ('REQ_A01','REQ_A02','REQ_A03') 											  
											  ) CIDI ON CIDH.CommInspDocNo = CIDI.CommInspDocNo
					
					LEFT OUTER JOIN (SELECT A.CommInspDocItemNo, MAX(InspWorkerCode) AS InspWorkerCode
									  FROM STB_CommInspMeasureHist A
									  INNER JOIN ( 
													SELECT CommInspDocNo, CommInspDocItemNo, CommInspInputType
															, CommInspItemCode
														FROM STB_CommInspDocItem
														WHERE CommInspItemCode IN ('REQ_A01','REQ_A02','REQ_A03') 											  
													) B
										ON B.CommInspDocItemNo = A.CommInspDocItemNo
									 GROUP BY A.CommInspDocItemNo
									) CIMH   ON CIDI.CommInspDocItemNo = CIMH.CommInspDocItemNo           -- 작업자정보 가져오기 위함 JOIN함 											
					LEFT OUTER JOIN STB_ElectrodeCommon EC             ON CIDH.MaterialCode = EC.ProdCode
					LEFT OUTER JOIN VW_CommInspInputType VIEW_CIIT 	ON VIEW_CIIT.CommInspInputType = CIDI.CommInspInputType
					LEFT OUTER JOIN STB_ProdWorkerInfo PWI ON PWI.WorkerCode = CIMH.InspWorkerCode
			WHERE 1=1
			   AND (@CompanyCode = '*' OR CIDH.CompanyCode = @CompanyCode)
			   AND (@WorkCenterCode = '*' OR CIDH.WorkCenterCode = @WorkCenterCode) 
			   AND CIDH.CommInspTypeCode = @CommInspTypeCode
			   AND CIDH.JobDate BETWEEN @FromDate AND @ToDate
			   AND CIDH.IsFinished = @IsFinished
			   AND (@Barcode = '*' OR SI.Barcode = @Barcode)				  

			GROUP BY CIDH.CompanyCode ,
							CIDH.CommInspDocNo,			
							CIDH.CommInspTypeCode,
							CITI.CommInspTypeName,
							CITI.CommInspTypeDesc,
							CIDH.CompanyCode,
							CIDH.WorkCenterCode,
							CIDH.MaterialCode,
							M.MaterialName,
							M.MaterialTypeCode,
							M.ProductGroupCode,
							CIDH.RefDocNo,
							ISNULL(SI.Barcode, CIDH.ElectrodeLotNumber), --#201006
							SI.PONo,
							CIDH.JobDate,
							CIDH.ShiftCode,
							CIDH.InspTimeCode,
							CIDH.CategoryName,
							CIDH.ProdNo,
							CIDH.IsFinished,
							SI.IsFinalInspection,
							CIDH.DocDesc,
							CIDH.InspUserID,
							CIDH.CreateDateTime,
							CIDH.CreateUserID,
							CIDH.ChangeDateTime,
							CIDH.ChangeUserID,
							CIDH.CIDHExtText02     
						  , CIMH.InspWorkerCode 
						  , PWI.WorkerName                      
						  , VIEW_CIIT.CommInspInputTypeName     -- 두께산술부분 
		) A							
END