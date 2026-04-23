CREATE proc [dbo].[usp_VN_Module_ExportImport]
--@pProcessLanguage VARCHAR(20),
--@pBarcode NVARCHAR(50) = NULL
AS
BEGIN
--		DECLARE @LOTNO VARCHAR(100) = @pBarcode 
--		DECLARE @ProcessLanguage VARCHAR(20) = @pProcessLanguage
--		DECLARE @GROUPID NVARCHAR(50)
--		DECLARE @QTY INT
--		DECLARE @FWAR NVARCHAR(30)
--		DECLARE @PARTNO NVARCHAR(50)
--		DECLARE @SIZE NVARCHAR(50)
--		DECLARE @VOL NVARCHAR(30)
--		DECLARE @CreateUserID  NVARCHAR(30)
--		DECLARE @LOTNOS NVARCHAR(50)

--		SELECT 
--			    @LOTNOS = LOTNO
--		FROM
--			    STB_VN_MODULE_EXPORT_IMPORT
--		WHERE
--				 LOTNO = @LOTNO AND EXPORT = 1

--				 IF @LOTNOS IS NOT NULL

--				 BEGIN

--			SELECT
--				 GROUPID
--				,LOTNO
--				,QTY
--				,VOL
--				,FWAR
--				,PARTNO
--				,SIZE
--				,EXPORT
--				,DESCRIPTIONS_EXPORT
--				,COUNTRY
--				,CreateUserID
--				,CreateDateTime
--			FROM
--				 STB_VN_MODULE_EXPORT_IMPORT 

--				END

--	  ELSE

--	  BEGIN

--	  SELECT
--			  @GROUPID = GROUPID
--			 ,@LOTNO = LOTNO
--			 ,@QTY = QTY
--			 ,@VOL = VOL
--			 ,@FWAR = FWAR
--			 ,@PARTNO = PARTNO
--			 ,@SIZE = SIZE
--			 ,@CreateUserID = CreateUserID
			
--		FROM
--			 STB_VN_MASTERMODULES WITH(NOLOCK)
--		WHERE

--			 LOTNO = @LOTNO AND ISUSED = 1

--		IF @LOTNO IS NULL

--		BEGIN
--		 DECLARE @NotEnoughStockError NVARCHAR(MAX)
--					EXEC usp_GetSystemStringResource	@ProcessLanguage,
--														N'^Mã Lotno này không tồn tại, hoặc chưa sửa dụng được...!^',
--														@NotEnoughStockError OUTPUT

--					RAISERROR(@NotEnoughStockError,16,1)
--					RETURN		
--		END

--		ELSE

--		BEGIN

--		CREATE TABLE #T1
--		(
--			GROUPID NVARCHAR(50),
--			LOTNO NVARCHAR(50),
--			QTY INT,
--			FWAR NVARCHAR(30),
--			PARTNO NVARCHAR(50),
--			SIZE NVARCHAR(50),
--			VOL NVARCHAR(30),
--			CreateDateTime DATETIME,
--			CreateUserID NVARCHAR(30)
--		)

--		INSERT INTO #T1 (GROUPID,LOTNO,QTY,VOL,FWAR,PARTNO,SIZE,CreateUserID,CreateDateTime)
--		VALUES (@GROUPID,@LOTNO,@QTY,@VOL,@FWAR,@PARTNO,@SIZE,@CreateUserID,DATEADD(HH, -2, GETDATE()))
	
--		SELECT
--				 GROUPID
--				,LOTNO
--				,QTY
--				,VOL
--				,FWAR
--				,PARTNO
--				,SIZE
--				,'' AS EXPORT
--				,'' AS TYPEACTION_EXPORT
--				,'' AS DESCRIPTIONS_EXPORT
--				,'' AS COUNTRY
--				,CreateUserID
--				,CreateDateTime
--		FROM
--				#T1
--END
--		END
				SELECT
				T1.GROUPID,
				T1.LOTNO,
				T1.TOTALQTY AS 'QTY',
				T1.VOL,
				T1.FWAR,
				T1.PARTNO,
				T1.SIZE,
				T1.EXPORT,
				T1.TYPEEXPORT,
				T1.IMPORT,
				T1.TYPEIMPORT,
				T1.CreateUserID,
				T1.CreateDateTime
				
		FROM
					STB_VN_MASTERMODULES T1 WITH (NOLOCK)
		
		WHERE
					 ISUSED = 1 AND DIVIDETHENUMBER IS NOT NULL AND TOTALQTY IS NOT NULL AND T1.Flag IS NULL

END


--UPDATE STB_VN_MASTERMODULES
--SET DATEIMPORT = NULL,
--	PERSONIMPORT = NULL,
--	FLAG = NULL
--WHERE ID = ID

-- select * from STB_VN_MODULE_EXPORT_IMPORT
-- delete STB_VN_MODULE_EXPORT_IMPORT
-- delete STB_VN_MODULE_EXPORT_IMPORT
-- select * from STB_VN_MASTERMODULES where GROUPID ='VNM202012240228'
--SELECT * FROM STB_VN_MASTERMODULES