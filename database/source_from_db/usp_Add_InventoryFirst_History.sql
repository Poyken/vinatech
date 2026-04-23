-- =============================================
-- Author:	Kevin Nguyen(nguyennha@vina.co.kr)
-- Create date: 2020.06.23
-- Browsable : true
-- Group : EA VN TEAM
-- Description:	The inventory first stage months function.
-- =============================================
CREATE PROC [dbo].[usp_Add_InventoryFirst_History]
@IDIF INT
AS
BEGIN
--CREATE TABLE  STB_VN_InventoryFirst_History
--(
--	    IFH INT IDENTITY(1,1) NOT NULL PRIMARY KEY(IFH),
--		IDIF INT NULL,
--		CLASSIFY NVARCHAR(50) NULL,
--		STAGE NVARCHAR(50) NULL,
--		STAGENAME NVARCHAR(50) NULL,
--		MODEL NVARCHAR(50) NULL,
--		PRODUCTIONNAME NVARCHAR(50) NULL,
--		UNIT NVARCHAR(20) NULL,
--		STATUSS NVARCHAR(50) NULL,
--		LOCATIONS NVARCHAR(50) NULL,
--		QTYONPAGER FLOAT NULL,
--		ACTUALLYQTY FLOAT NULL,
--		DESCRIPTIONS NVARCHAR(500) NULL,
--		DateInput DATETIME NULL,
--		TYPEACTIONS NVARCHAR(20) NULL,
--		CreateDateTime DATETIME NULL,
--		CreateUserID NVARCHAR(20) NULL,
--		ChangeDateTime DATETIME NULL,
--		ChangeUserID NVARCHAR(20) NULL,
--		CreateDateActions DATETIME NULL
--)
	   DECLARE @HIDIF INT
	   DECLARE @HCLASSIFY NVARCHAR(50)
	   DECLARE @HSTAGE NVARCHAR(50)
	   DECLARE @HSTAGENAME NVARCHAR(50)
	   DECLARE @HMODEL NVARCHAR(50)
	   DECLARE @HPRODUCTIONNAME NVARCHAR(50)
	   DECLARE @HUNIT NVARCHAR(20)
	   DECLARE @HSTATUSS NVARCHAR(50)
	   DECLARE @HLOCATIONS NVARCHAR(50)
	   DECLARE @HQTYONPAGER FLOAT
	   DECLARE @HACTUALLYQTY FLOAT
	   DECLARE @HDESCRIPTIONS NVARCHAR(500)
	   DECLARE @HDateInput DATETIME
	   DECLARE @HCreateDateTime DATETIME
       DECLARE @HCreateUserID NVARCHAR(20)
       DECLARE @HChangeDateTime DATETIME
       DECLARE @HChangeUserID NVARCHAR(20)

	   SELECT 
				@HIDIF = IDIF,
				@HCLASSIFY = CLASSIFY,
				@HSTAGE = STAGE,
				@HSTAGENAME = STAGENAME,
				@HMODEL = MODEL,
				@HPRODUCTIONNAME = PRODUCTIONNAME,
				@HUNIT = UNIT,
				@HSTATUSS = STATUSS,
				@HLOCATIONS = LOCATIONS,
				@HQTYONPAGER = QTYONPAGER,
				@HACTUALLYQTY = ACTUALLYQTY,
				@HDESCRIPTIONS = DESCRIPTIONS,
				@HDateInput = DateInput,
				@HCreateDateTime = CreateDateTime,
				@HCreateUserID = CreateUserID,
				@HChangeDateTime = ChangeDateTime,
				@HChangeUserID = ChangeUserID
	   FROM 
				STB_VN_InventoryFirst
	   WHERE
				IDIF=@IDIF


			INSERT INTO STB_VN_InventoryFirst_History
			(
				IDIF,
				CLASSIFY,
				STAGE,
				STAGENAME,
				MODEL,
			    PRODUCTIONNAME,
				UNIT,
				STATUSS,
				LOCATIONS,
				QTYONPAGER,
				ACTUALLYQTY,
				DESCRIPTIONS,
				DateInput,
				TYPEACTIONS,
				CreateDateTime,
				CreateUserID,
				ChangeDateTime,
				ChangeUserID,
				CreateDateActions
			)
			VALUES
			(
				@HIDIF,
				@HCLASSIFY,
				@HSTAGE,
				@HSTAGENAME,
				@HMODEL,
				@HPRODUCTIONNAME,
				@HUNIT,
				@HSTATUSS,
				@HLOCATIONS,
				@HQTYONPAGER,
				@HACTUALLYQTY,
				@HDESCRIPTIONS,
				@HDateInput,
				'U',
				@HCreateDateTime,
				@HCreateUserID,
				@HChangeDateTime,
				@HChangeUserID,
				GETDATE()
			)

END
