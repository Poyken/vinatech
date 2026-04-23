
CREATE PROC [dbo].[usp_VN_STB_QC_LOTNO_MODULE] -- EXEC usp_VN_STB_QC_LOTNO_MODULE 'nha','2021-11-03','abc','abx','MVVJU312R710507'
--@pProcessLanguage VARCHAR(20),
@pProcessUserID VARCHAR(20),
@pDateBasic DATETIME = NULL,
@pDesction NVARCHAR(500) = NULL,
@pPersonCheck NVARCHAR(50) = NULL,
@pBarcode NVARCHAR(50) = NULL
AS
BEGIN
		--DECLARE @ProcessLanguage VARCHAR(20) = @pProcessLanguage
		DECLARE @Bar NVARCHAR(100) = @pBarcode 
		DECLARE @Des VARCHAR(100) = @pDesction 
		DECLARE @Date DATETIME = @pDateBasic 
		DECLARE @UserID NVARCHAR(50) = @pProcessUserID
		DECLARE @PersonChecks NVARCHAR(50) = @pPersonCheck
		DECLARE @LotNo NVARCHAR(50)
		DECLARE @LotQty INT
		DECLARE @Voltage NVARCHAR(50)
		DECLARE @Farad NVARCHAR(10)
		DECLARE @Rating NVARCHAR(10)
		DECLARE @PartNo NVARCHAR(50)
		DECLARE @CreateDateTime DATETIME
		DECLARE @CreateUserID NVARCHAR(50)
		DECLARE @LotNoAgain NVARCHAR(50)
		DECLARE @STS NVARCHAR(20)
		DECLARE @MaterialCode NVARCHAR(50)
		DECLARE @MaterialName NVARCHAR(50)

		SELECT 

			   @LotNoAgain = LOTNO--,
			   --@STS = STATUSPSS

		FROM 
			  STB_QC_LOTNO_MODULE
		WHERE 
				LOTNO = @Bar

IF(@LotNoAgain IS NOT NULL)

BEGIN



	SELECT
			  MATERIALCODE,
			  METERIALNAME,
			  LOTNO,
			  DATEBASIC,
			  PARTNO,
			  Size,
			  Voltage,
			  Farad,
			  LotQty,
			  Person,
			  PersonCheck,
			  CONVERT(DATE,CreateDateTimePackge) AS CreateDateTimePackge,
			  Descriptions,
			  RIGHT(CreateDateTimePackge,8) AS TimePackge,
			  CreateUserID,
			  CONVERT(DATE,CreateDateTime) AS CreateDateTime,
			  RIGHT(CreateDateTime,8) AS TimeCreate
	FROM 

					STB_QC_LOTNO_MODULE WITH(NOLOCK) 
	WHERE 
				LOTNO = @LotNoAgain
END

ELSE

BEGIN
		SELECT 
				@LotNo = LOTNO,
				@LotQty = TOTALQTY,
				@Voltage = VOL,
				@Farad = FWAR,
				@Rating = SIZE,
				@PartNo = PARTNO,
				@CreateDateTime = CreateDateTime,
				@CreateUserID = CreateUserID,
				@MaterialCode = MATERIALCODE, 
				@MaterialName = MARTERIALNAME
				
		FROM 
				STB_VN_MASTERMODULES WITH(NOLOCK)
		WHERE
				LOTNO = @Bar AND ISUSED = 1

IF(@Bar IS NOT NULL)

	BEGIN

		INSERT INTO STB_QC_LOTNO_MODULE (METERIALNAME,MATERIALCODE,DATEBASIC,LOTNO,LotQty,PARTNO,Size,Voltage,Farad,Person,CreateDateTimePackge,CreateUserID,CreateDateTime,Descriptions,PersonCheck)
		VALUES (@MaterialName,@MaterialCode,@Date,@LotNo,@LotQty,@PartNo,@Rating,@Voltage,@Farad,@CreateUserID,@CreateDateTime,@UserID,DATEADD(HH, -2, GETDATE()),@Des,@PersonChecks)

	    INSERT INTO STB_VN_QC_LOTNO_MODULE_DETAIL (LOTNO,NAMETYPE,NUMBERTYPE,CreateDateTime,CreateUserID) VALUES (@LotNo,'ESR','20',DATEADD(HH, -2, GETDATE()),@UserID)
		INSERT INTO STB_VN_QC_LOTNO_MODULE_DETAIL (LOTNO,NAMETYPE,NUMBERTYPE,CreateDateTime,CreateUserID) VALUES (@LotNo,'SD','20',DATEADD(HH, -2, GETDATE()),@UserID)
		INSERT INTO STB_VN_QC_LOTNO_MODULE_DETAIL (LOTNO,NAMETYPE,NUMBERTYPE,CreateDateTime,CreateUserID) VALUES (@LotNo,N'Dien Dung','3',DATEADD(HH, -2, GETDATE()),@UserID)

		DECLARE @counter INT = 0;

WHILE @counter <= 19
BEGIN

    SET @counter = @counter + 1;
	INSERT INTO STB_QC_LOTNO_MODULE_VALUES(LOTNO,NAMETYPE,NUMBERID,CreateDateTime,CreateUserID) VALUES (@LotNo,'ESR',@counter,DATEADD(HH, -2, GETDATE()),@UserID)
	
	IF(@counter<=10) -- Mr.Tung add to decrease SD value from 20 become 10 value as Email 28.8.2021 of Ms.Hanh
		INSERT INTO STB_QC_LOTNO_MODULE_VALUES(LOTNO,NAMETYPE,NUMBERID,CreateDateTime,CreateUserID) VALUES (@LotNo,'SD',@counter,DATEADD(HH, -2, GETDATE()),@UserID)
END

DECLARE @counters INT = 0;

WHILE @counters <= 2

BEGIN

    SET @counters = @counters + 1;
	INSERT INTO STB_QC_LOTNO_MODULE_VALUES(LOTNO,NAMETYPE,NUMBERID,CreateDateTime,CreateUserID) VALUES (@LotNo,N'Dien Dung',@counters,DATEADD(HH, -2, GETDATE()),@UserID)

END
		SELECT
		      TOP(1)
			  MATERIALCODE,
			  METERIALNAME,
			  LOTNO,
			  DATEBASIC,
			  PARTNO,
			  Size,
			  Voltage,
			  Farad,
			  LotQty,
			  Person,
			  PersonCheck,
			  CONVERT(DATE,CreateDateTimePackge) AS CreateDateTimePackge,
			  RIGHT(CreateDateTimePackge,8) AS TimePackge,
			  CreateUserID,
			  CONVERT(DATE,CreateDateTime) AS CreateDateTime,
			  RIGHT(CreateDateTime,8) AS TimeCreate
		FROM 

					STB_QC_LOTNO_MODULE WITH(NOLOCK) 
		WHERE 
				LOTNO = @Bar
		
		ORDER BY CreateDateTime DESC

END
END
END

-- DELETE STB_QC_LOTNO_MODULE
-- SELECT * FROM STB_QC_LOTNO_MODULE
-- SELECT * FROM STB_VN_MASTERMODULES WHERE LOTNO ='MVVLJ203R010718'

-- select METERIALNAME,MATERIALCODE,DATEBASIC,LOTNO,LotQty,PARTNO,Size,Voltage,Farad,Person,CreateDateTimePackge,CreateUserID,CreateDateTime,Descriptions,PersonCheck  from STB_QC_LOTNO_MODULE 

--delete STB_QC_LOTNO_MODULE  WHERE LOTNO ='MVVLJ203R010718'
--delete STB_QC_LOTNO_MODULE_VALUES WHERE LOTNO ='MVVLJ203R010718'

