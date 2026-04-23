
-- =============================================
-- Author:	    Kim Han Young(hykim@awoo.co.kr)
-- Create date: 2018-07-23
-- Browsable : true
-- Group : 공통
-- Description:	거래처정보 IUD
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_CustomerInfo_iud]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
    @pProcessViewName VARCHAR(50),
	@pXml NVARCHAR(MAX) = null
AS
BEGIN
	SET NOCOUNT ON;

    DECLARE @ProcessUserID VARCHAR(20) = @pProcessUserID
    DECLARE @ProcessLanguage VARCHAR(20) = @pProcessLanguage
    DECLARE @ProcessViewName VARCHAR(50) = @pProcessViewName
    DECLARE @InsertTableName VARCHAR(100) = '/DataSet/' + @ProcessViewName + '_INSERT'
    DECLARE @UpdateTableName VARCHAR(100) = '/DataSet/' + @ProcessViewName + '_UPDATE'
    DECLARE @DeleteTableName VARCHAR(100) = '/DataSet/' + @ProcessViewName + '_DELETE'
    DECLARE @ERROR_MSG NVARCHAR(MAX)
    DECLARE @IUD_FLAG VARCHAR(10)
    DECLARE @IsAutoKey BIT
    DECLARE @IsLoopIUD BIT
    DECLARE @PrefixString VARCHAR(20)
    DECLARE @SerialLen INT

    -- Declare Columns Variable
  DECLARE @OldCustomerCode VARCHAR(20)
  DECLARE @CustomerCode VARCHAR(20)
  DECLARE @CustomerName NVARCHAR(50)
  DECLARE @CustomerNameL NVARCHAR(50)
  DECLARE @IsCustomer BIT
  DECLARE @IsVendor BIT
  DECLARE @IsSourcing BIT
  DECLARE @BusinessCondition NVARCHAR(50)
  DECLARE @BusinessType NVARCHAR(50)
  DECLARE @BusinessNo VARCHAR(20)
  DECLARE @ZipCode VARCHAR(10)
  DECLARE @AddressText NVARCHAR(100)
  DECLARE @CeoName NVARCHAR(30)
  DECLARE @TelNo VARCHAR(20)
  DECLARE @FaxNo VARCHAR(20)
  DECLARE @ContactName1 NVARCHAR(50)
  DECLARE @ContactTel1 VARCHAR(20)
  DECLARE @ContactName2 NVARCHAR(50)
  DECLARE @ContactTel2 VARCHAR(20)
  DECLARE @ContactName3 NVARCHAR(50)
  DECLARE @ContactTel3 VARCHAR(20)
  DECLARE @OrderToName NVARCHAR(50)
  DECLARE @OrderToTel VARCHAR(20)
  DECLARE @OrderToEmail VARCHAR(50)
  DECLARE @CustomerDesc NVARCHAR(MAX)
  DECLARE @IsUsed BIT
  DECLARE @MaterialWarehouseCode VARCHAR(20)
  DECLARE @CIExtText01 NVARCHAR(200)
  DECLARE @CIExtText02 NVARCHAR(200)
  DECLARE @CIExtText03 NVARCHAR(200)
  DECLARE @CreateDateTime DATETIME
  DECLARE @CreateUserID VARCHAR(20)
  DECLARE @ChangeDateTime DATETIME
  DECLARE @ChangeUserID VARCHAR(20)


	DECLARE @iDoc INT

    EXEC SmartFramework.dbo.usp_GetSerialRule 
			@pTableName = 'STB_CustomerInfo',
			@pIsAutoKey = @IsAutoKey OUTPUT,
			@pIsLoopIUD = @IsLoopIUD OUTPUT,
			@pPrefixData = @PrefixString OUTPUT,
			@pSerialLen = @SerialLen OUTPUT
    
    IF @IsAutoKey = 0 AND @IsLoopIUD = 0 BEGIN
   
	    EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
	
	    BEGIN TRY
			-- Process Insert Table
            MERGE STB_CustomerInfo AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldCustomerCode IS NULL THEN CustomerCode
							    ELSE OldCustomerCode
							END AS OldCustomerCode,
							CustomerCode,
							CustomerName,
							CustomerNameL,
							IsCustomer,
							IsVendor,
							IsSourcing,
							BusinessCondition,
							BusinessType,
							BusinessNo,
							ZipCode,
							AddressText,
							CeoName,
							TelNo,
							FaxNo,
							ContactName1,
							ContactTel1,
							ContactName2,
							ContactTel2,
							ContactName3,
							ContactTel3,
							OrderToName,
							OrderToTel,
							OrderToEmail,
							CustomerDesc,
							IsUsed,
							MaterialWarehouseCode,
							CIExtText01,
							CIExtText02,
							CIExtText03,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @InsertTableName , 2)
							WITH  (
										OldCustomerCode VARCHAR(20),
										CustomerCode VARCHAR(20),
										CustomerName NVARCHAR(50),
										CustomerNameL NVARCHAR(50),
										IsCustomer BIT,
										IsVendor BIT,
										IsSourcing BIT,
										BusinessCondition NVARCHAR(50),
										BusinessType NVARCHAR(50),
										BusinessNo VARCHAR(20),
										ZipCode VARCHAR(10),
										AddressText NVARCHAR(100),
										CeoName NVARCHAR(30),
										TelNo VARCHAR(20),
										FaxNo VARCHAR(20),
										ContactName1 NVARCHAR(50),
										ContactTel1 VARCHAR(20),
										ContactName2 NVARCHAR(50),
										ContactTel2 VARCHAR(20),
										ContactName3 NVARCHAR(50),
										ContactTel3 VARCHAR(20),
										OrderToName NVARCHAR(50),
										OrderToTel VARCHAR(20),
										OrderToEmail VARCHAR(50),
										CustomerDesc NVARCHAR(MAX),
										IsUsed BIT,
										MaterialWarehouseCode VARCHAR(20),
										CIExtText01 NVARCHAR(200),
										CIExtText02 NVARCHAR(200),
										CIExtText03 NVARCHAR(200),
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.CustomerCode = SourceTable.CustomerCode
				)

			WHEN MATCHED THEN
				UPDATE SET
					CustomerCode = ISNULL(SourceTable.CustomerCode,TargetTable.CustomerCode),
					CustomerName = ISNULL(SourceTable.CustomerName,TargetTable.CustomerName),
					CustomerNameL = ISNULL(SourceTable.CustomerNameL,TargetTable.CustomerNameL),
					IsCustomer = ISNULL(SourceTable.IsCustomer,TargetTable.IsCustomer),
					IsVendor = ISNULL(SourceTable.IsVendor,TargetTable.IsVendor),
					IsSourcing = ISNULL(SourceTable.IsSourcing,TargetTable.IsSourcing),
					BusinessCondition = ISNULL(SourceTable.BusinessCondition,TargetTable.BusinessCondition),
					BusinessType = ISNULL(SourceTable.BusinessType,TargetTable.BusinessType),
					BusinessNo = ISNULL(SourceTable.BusinessNo,TargetTable.BusinessNo),
					ZipCode = ISNULL(SourceTable.ZipCode,TargetTable.ZipCode),
					AddressText = ISNULL(SourceTable.AddressText,TargetTable.AddressText),
					CeoName = ISNULL(SourceTable.CeoName,TargetTable.CeoName),
					TelNo = ISNULL(SourceTable.TelNo,TargetTable.TelNo),
					FaxNo = ISNULL(SourceTable.FaxNo,TargetTable.FaxNo),
					ContactName1 = ISNULL(SourceTable.ContactName1,TargetTable.ContactName1),
					ContactTel1 = ISNULL(SourceTable.ContactTel1,TargetTable.ContactTel1),
					ContactName2 = ISNULL(SourceTable.ContactName2,TargetTable.ContactName2),
					ContactTel2 = ISNULL(SourceTable.ContactTel2,TargetTable.ContactTel2),
					ContactName3 = ISNULL(SourceTable.ContactName3,TargetTable.ContactName3),
					ContactTel3 = ISNULL(SourceTable.ContactTel3,TargetTable.ContactTel3),
					OrderToName = ISNULL(SourceTable.OrderToName,TargetTable.OrderToName),
					OrderToTel = ISNULL(SourceTable.OrderToTel,TargetTable.OrderToTel),
					OrderToEmail = ISNULL(SourceTable.OrderToEmail,TargetTable.OrderToEmail),
					CustomerDesc = ISNULL(SourceTable.CustomerDesc,TargetTable.CustomerDesc),
					IsUsed = ISNULL(SourceTable.IsUsed,TargetTable.IsUsed),
					MaterialWarehouseCode = ISNULL(SourceTable.MaterialWarehouseCode,TargetTable.MaterialWarehouseCode),
					CIExtText01 = ISNULL(SourceTable.CIExtText01,TargetTable.CIExtText01),
					CIExtText02 = ISNULL(SourceTable.CIExtText02,TargetTable.CIExtText02),
					CIExtText03 = ISNULL(SourceTable.CIExtText03,TargetTable.CIExtText03),
					ChangeDateTime = ISNULL(SourceTable.ChangeDateTime,TargetTable.ChangeDateTime),
					ChangeUserID = ISNULL(SourceTable.ChangeUserID,TargetTable.ChangeUserID)
			WHEN NOT MATCHED THEN
				INSERT
					(
						CustomerCode,
						CustomerName,
						CustomerNameL,
						IsCustomer,
						IsVendor,
						IsSourcing,
						BusinessCondition,
						BusinessType,
						BusinessNo,
						ZipCode,
						AddressText,
						CeoName,
						TelNo,
						FaxNo,
						ContactName1,
						ContactTel1,
						ContactName2,
						ContactTel2,
						ContactName3,
						ContactTel3,
						OrderToName,
						OrderToTel,
						OrderToEmail,
						CustomerDesc,
						IsUsed,
						MaterialWarehouseCode,
						CIExtText01,
						CIExtText02,
						CIExtText03,
						CreateDateTime,
						CreateUserID
					)
				VALUES
					(
							SourceTable.CustomerCode,
							SourceTable.CustomerName,
							SourceTable.CustomerNameL,
							SourceTable.IsCustomer,
							SourceTable.IsVendor,
							SourceTable.IsSourcing,
							SourceTable.BusinessCondition,
							SourceTable.BusinessType,
							SourceTable.BusinessNo,
							SourceTable.ZipCode,
							SourceTable.AddressText,
							SourceTable.CeoName,
							SourceTable.TelNo,
							SourceTable.FaxNo,
							SourceTable.ContactName1,
							SourceTable.ContactTel1,
							SourceTable.ContactName2,
							SourceTable.ContactTel2,
							SourceTable.ContactName3,
							SourceTable.ContactTel3,
							SourceTable.OrderToName,
							SourceTable.OrderToTel,
							SourceTable.OrderToEmail,
							SourceTable.CustomerDesc,
							SourceTable.IsUsed,
							SourceTable.MaterialWarehouseCode,
							SourceTable.CIExtText01,
							SourceTable.CIExtText02,
							SourceTable.CIExtText03,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID
					);


			-- Process Update Table
            MERGE STB_CustomerInfo AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldCustomerCode IS NULL THEN CustomerCode
							    ELSE OldCustomerCode
							END AS OldCustomerCode,
							CustomerCode,
							CustomerName,
							CustomerNameL,
							IsCustomer,
							IsVendor,
							IsSourcing,
							BusinessCondition,
							BusinessType,
							BusinessNo,
							ZipCode,
							AddressText,
							CeoName,
							TelNo,
							FaxNo,
							ContactName1,
							ContactTel1,
							ContactName2,
							ContactTel2,
							ContactName3,
							ContactTel3,
							OrderToName,
							OrderToTel,
							OrderToEmail,
							CustomerDesc,
							IsUsed,
							MaterialWarehouseCode,
							CIExtText01,
							CIExtText02,
							CIExtText03,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @UpdateTableName , 2)
							WITH  (
										OldCustomerCode VARCHAR(20),
										CustomerCode VARCHAR(20),
										CustomerName NVARCHAR(50),
										CustomerNameL NVARCHAR(50),
										IsCustomer BIT,
										IsVendor BIT,
										IsSourcing BIT,
										BusinessCondition NVARCHAR(50),
										BusinessType NVARCHAR(50),
										BusinessNo VARCHAR(20),
										ZipCode VARCHAR(10),
										AddressText NVARCHAR(100),
										CeoName NVARCHAR(30),
										TelNo VARCHAR(20),
										FaxNo VARCHAR(20),
										ContactName1 NVARCHAR(50),
										ContactTel1 VARCHAR(20),
										ContactName2 NVARCHAR(50),
										ContactTel2 VARCHAR(20),
										ContactName3 NVARCHAR(50),
										ContactTel3 VARCHAR(20),
										OrderToName NVARCHAR(50),
										OrderToTel VARCHAR(20),
										OrderToEmail VARCHAR(50),
										CustomerDesc NVARCHAR(MAX),
										IsUsed BIT,
										MaterialWarehouseCode VARCHAR(20),
										CIExtText01 NVARCHAR(200),
										CIExtText02 NVARCHAR(200),
										CIExtText03 NVARCHAR(200),
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.CustomerCode = SourceTable.OldCustomerCode
				)

			WHEN MATCHED THEN
				UPDATE SET
					CustomerCode = ISNULL(SourceTable.CustomerCode,TargetTable.CustomerCode),
					CustomerName = ISNULL(SourceTable.CustomerName,TargetTable.CustomerName),
					CustomerNameL = ISNULL(SourceTable.CustomerNameL,TargetTable.CustomerNameL),
					IsCustomer = ISNULL(SourceTable.IsCustomer,TargetTable.IsCustomer),
					IsVendor = ISNULL(SourceTable.IsVendor,TargetTable.IsVendor),
					IsSourcing = ISNULL(SourceTable.IsSourcing,TargetTable.IsSourcing),
					BusinessCondition = ISNULL(SourceTable.BusinessCondition,TargetTable.BusinessCondition),
					BusinessType = ISNULL(SourceTable.BusinessType,TargetTable.BusinessType),
					BusinessNo = ISNULL(SourceTable.BusinessNo,TargetTable.BusinessNo),
					ZipCode = ISNULL(SourceTable.ZipCode,TargetTable.ZipCode),
					AddressText = ISNULL(SourceTable.AddressText,TargetTable.AddressText),
					CeoName = ISNULL(SourceTable.CeoName,TargetTable.CeoName),
					TelNo = ISNULL(SourceTable.TelNo,TargetTable.TelNo),
					FaxNo = ISNULL(SourceTable.FaxNo,TargetTable.FaxNo),
					ContactName1 = ISNULL(SourceTable.ContactName1,TargetTable.ContactName1),
					ContactTel1 = ISNULL(SourceTable.ContactTel1,TargetTable.ContactTel1),
					ContactName2 = ISNULL(SourceTable.ContactName2,TargetTable.ContactName2),
					ContactTel2 = ISNULL(SourceTable.ContactTel2,TargetTable.ContactTel2),
					ContactName3 = ISNULL(SourceTable.ContactName3,TargetTable.ContactName3),
					ContactTel3 = ISNULL(SourceTable.ContactTel3,TargetTable.ContactTel3),
					OrderToName = ISNULL(SourceTable.OrderToName,TargetTable.OrderToName),
					OrderToTel = ISNULL(SourceTable.OrderToTel,TargetTable.OrderToTel),
					OrderToEmail = ISNULL(SourceTable.OrderToEmail,TargetTable.OrderToEmail),
					CustomerDesc = ISNULL(SourceTable.CustomerDesc,TargetTable.CustomerDesc),
					IsUsed = ISNULL(SourceTable.IsUsed,TargetTable.IsUsed),
					MaterialWarehouseCode = ISNULL(SourceTable.MaterialWarehouseCode,TargetTable.MaterialWarehouseCode),
					CIExtText01 = ISNULL(SourceTable.CIExtText01,TargetTable.CIExtText01),
					CIExtText02 = ISNULL(SourceTable.CIExtText02,TargetTable.CIExtText02),
					CIExtText03 = ISNULL(SourceTable.CIExtText03,TargetTable.CIExtText03),
					ChangeDateTime = ISNULL(SourceTable.ChangeDateTime,TargetTable.ChangeDateTime),
					ChangeUserID = ISNULL(SourceTable.ChangeUserID,TargetTable.ChangeUserID)
			WHEN NOT MATCHED THEN
				INSERT
					(
						CustomerCode,
						CustomerName,
						CustomerNameL,
						IsCustomer,
						IsVendor,
						IsSourcing,
						BusinessCondition,
						BusinessType,
						BusinessNo,
						ZipCode,
						AddressText,
						CeoName,
						TelNo,
						FaxNo,
						ContactName1,
						ContactTel1,
						ContactName2,
						ContactTel2,
						ContactName3,
						ContactTel3,
						OrderToName,
						OrderToTel,
						OrderToEmail,
						CustomerDesc,
						IsUsed,
						MaterialWarehouseCode,
						CIExtText01,
						CIExtText02,
						CIExtText03,
						CreateDateTime,
						CreateUserID
					)
				VALUES
					(
							SourceTable.CustomerCode,
							SourceTable.CustomerName,
							SourceTable.CustomerNameL,
							SourceTable.IsCustomer,
							SourceTable.IsVendor,
							SourceTable.IsSourcing,
							SourceTable.BusinessCondition,
							SourceTable.BusinessType,
							SourceTable.BusinessNo,
							SourceTable.ZipCode,
							SourceTable.AddressText,
							SourceTable.CeoName,
							SourceTable.TelNo,
							SourceTable.FaxNo,
							SourceTable.ContactName1,
							SourceTable.ContactTel1,
							SourceTable.ContactName2,
							SourceTable.ContactTel2,
							SourceTable.ContactName3,
							SourceTable.ContactTel3,
							SourceTable.OrderToName,
							SourceTable.OrderToTel,
							SourceTable.OrderToEmail,
							SourceTable.CustomerDesc,
							SourceTable.IsUsed,
							SourceTable.MaterialWarehouseCode,
							SourceTable.CIExtText01,
							SourceTable.CIExtText02,
							SourceTable.CIExtText03,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID
					);


			-- Process Delete Table
            MERGE STB_CustomerInfo AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldCustomerCode IS NULL THEN CustomerCode
							    ELSE OldCustomerCode
							END AS OldCustomerCode,
							CustomerCode,
							CustomerName,
							CustomerNameL,
							IsCustomer,
							IsVendor,
							IsSourcing,
							BusinessCondition,
							BusinessType,
							BusinessNo,
							ZipCode,
							AddressText,
							CeoName,
							TelNo,
							FaxNo,
							ContactName1,
							ContactTel1,
							ContactName2,
							ContactTel2,
							ContactName3,
							ContactTel3,
							OrderToName,
							OrderToTel,
							OrderToEmail,
							CustomerDesc,
							IsUsed,
							MaterialWarehouseCode,
							CIExtText01,
							CIExtText02,
							CIExtText03,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @DeleteTableName , 2)
							WITH  (
										OldCustomerCode VARCHAR(20),
										CustomerCode VARCHAR(20),
										CustomerName NVARCHAR(50),
										CustomerNameL NVARCHAR(50),
										IsCustomer BIT,
										IsVendor BIT,
										IsSourcing BIT,
										BusinessCondition NVARCHAR(50),
										BusinessType NVARCHAR(50),
										BusinessNo VARCHAR(20),
										ZipCode VARCHAR(10),
										AddressText NVARCHAR(100),
										CeoName NVARCHAR(30),
										TelNo VARCHAR(20),
										FaxNo VARCHAR(20),
										ContactName1 NVARCHAR(50),
										ContactTel1 VARCHAR(20),
										ContactName2 NVARCHAR(50),
										ContactTel2 VARCHAR(20),
										ContactName3 NVARCHAR(50),
										ContactTel3 VARCHAR(20),
										OrderToName NVARCHAR(50),
										OrderToTel VARCHAR(20),
										OrderToEmail VARCHAR(50),
										CustomerDesc NVARCHAR(MAX),
										IsUsed BIT,
										MaterialWarehouseCode VARCHAR(20),
										CIExtText01 NVARCHAR(200),
										CIExtText02 NVARCHAR(200),
										CIExtText03 NVARCHAR(200),
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.CustomerCode = SourceTable.CustomerCode
				)

			WHEN MATCHED THEN
				DELETE;

        END TRY
	    BEGIN CATCH
            SET @ERROR_MSG = ERROR_MESSAGE()
			RAISERROR( @ERROR_MSG ,16, 1)
	    END CATCH
		
	    EXEC sp_xml_removedocument @idoc

    END ELSE BEGIN
        EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
        BEGIN TRY
		    DECLARE SourceData CURSOR FOR
                SELECT
                        'INSERT' AS IUD_FLAG,
									OldCustomerCode,
									CustomerCode,
									CustomerName,
									CustomerNameL,
									IsCustomer,
									IsVendor,
									IsSourcing,
									BusinessCondition,
									BusinessType,
									BusinessNo,
									ZipCode,
									AddressText,
									CeoName,
									TelNo,
									FaxNo,
									ContactName1,
									ContactTel1,
									ContactName2,
									ContactTel2,
									ContactName3,
									ContactTel3,
									OrderToName,
									OrderToTel,
									OrderToEmail,
									CustomerDesc,
									IsUsed,
									MaterialWarehouseCode,
									CIExtText01,
									CIExtText02,
									CIExtText03,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID
							FROM
									OPENXML(@idoc , @InsertTableName , 2)
							        WITH  (
											 OldCustomerCode VARCHAR(20),
											 CustomerCode VARCHAR(20),
											 CustomerName NVARCHAR(50),
											 CustomerNameL NVARCHAR(50),
											 IsCustomer BIT,
											 IsVendor BIT,
											 IsSourcing BIT,
											 BusinessCondition NVARCHAR(50),
											 BusinessType NVARCHAR(50),
											 BusinessNo VARCHAR(20),
											 ZipCode VARCHAR(10),
											 AddressText NVARCHAR(100),
											 CeoName NVARCHAR(30),
											 TelNo VARCHAR(20),
											 FaxNo VARCHAR(20),
											 ContactName1 NVARCHAR(50),
											 ContactTel1 VARCHAR(20),
											 ContactName2 NVARCHAR(50),
											 ContactTel2 VARCHAR(20),
											 ContactName3 NVARCHAR(50),
											 ContactTel3 VARCHAR(20),
											 OrderToName NVARCHAR(50),
											 OrderToTel VARCHAR(20),
											 OrderToEmail VARCHAR(50),
											 CustomerDesc NVARCHAR(MAX),
											 IsUsed BIT,
											 MaterialWarehouseCode VARCHAR(20),
											 CIExtText01 NVARCHAR(200),
											 CIExtText02 NVARCHAR(200),
											 CIExtText03 NVARCHAR(200),
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											)
							UNION ALL
							SELECT
									'UPDATE' AS IUD_FLAG,
									CASE 
										WHEN OldCustomerCode IS NULL THEN CustomerCode
										ELSE OldCustomerCode
									END AS OldCustomerCode,
									CustomerCode,
									CustomerName,
									CustomerNameL,
									IsCustomer,
									IsVendor,
									IsSourcing,
									BusinessCondition,
									BusinessType,
									BusinessNo,
									ZipCode,
									AddressText,
									CeoName,
									TelNo,
									FaxNo,
									ContactName1,
									ContactTel1,
									ContactName2,
									ContactTel2,
									ContactName3,
									ContactTel3,
									OrderToName,
									OrderToTel,
									OrderToEmail,
									CustomerDesc,
									IsUsed,
									MaterialWarehouseCode,
									CIExtText01,
									CIExtText02,
									CIExtText03,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID
							FROM
									OPENXML(@idoc , @UpdateTableName , 2)
							        WITH  (
											 OldCustomerCode VARCHAR(20),
											 CustomerCode VARCHAR(20),
											 CustomerName NVARCHAR(50),
											 CustomerNameL NVARCHAR(50),
											 IsCustomer BIT,
											 IsVendor BIT,
											 IsSourcing BIT,
											 BusinessCondition NVARCHAR(50),
											 BusinessType NVARCHAR(50),
											 BusinessNo VARCHAR(20),
											 ZipCode VARCHAR(10),
											 AddressText NVARCHAR(100),
											 CeoName NVARCHAR(30),
											 TelNo VARCHAR(20),
											 FaxNo VARCHAR(20),
											 ContactName1 NVARCHAR(50),
											 ContactTel1 VARCHAR(20),
											 ContactName2 NVARCHAR(50),
											 ContactTel2 VARCHAR(20),
											 ContactName3 NVARCHAR(50),
											 ContactTel3 VARCHAR(20),
											 OrderToName NVARCHAR(50),
											 OrderToTel VARCHAR(20),
											 OrderToEmail VARCHAR(50),
											 CustomerDesc NVARCHAR(MAX),
											 IsUsed BIT,
											 MaterialWarehouseCode VARCHAR(20),
											 CIExtText01 NVARCHAR(200),
											 CIExtText02 NVARCHAR(200),
											 CIExtText03 NVARCHAR(200),
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											)
							UNION ALL
							SELECT
									'DELETE' AS IUD_FLAG,
									CASE 
										WHEN OldCustomerCode IS NULL THEN CustomerCode
										ELSE OldCustomerCode
									END AS OldCustomerCode,
									CustomerCode,
									CustomerName,
									CustomerNameL,
									IsCustomer,
									IsVendor,
									IsSourcing,
									BusinessCondition,
									BusinessType,
									BusinessNo,
									ZipCode,
									AddressText,
									CeoName,
									TelNo,
									FaxNo,
									ContactName1,
									ContactTel1,
									ContactName2,
									ContactTel2,
									ContactName3,
									ContactTel3,
									OrderToName,
									OrderToTel,
									OrderToEmail,
									CustomerDesc,
									IsUsed,
									MaterialWarehouseCode,
									CIExtText01,
									CIExtText02,
									CIExtText03,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID
							FROM
									OPENXML(@idoc , @DeleteTableName , 2)
							        WITH  (
											 OldCustomerCode VARCHAR(20),
											 CustomerCode VARCHAR(20),
											 CustomerName NVARCHAR(50),
											 CustomerNameL NVARCHAR(50),
											 IsCustomer BIT,
											 IsVendor BIT,
											 IsSourcing BIT,
											 BusinessCondition NVARCHAR(50),
											 BusinessType NVARCHAR(50),
											 BusinessNo VARCHAR(20),
											 ZipCode VARCHAR(10),
											 AddressText NVARCHAR(100),
											 CeoName NVARCHAR(30),
											 TelNo VARCHAR(20),
											 FaxNo VARCHAR(20),
											 ContactName1 NVARCHAR(50),
											 ContactTel1 VARCHAR(20),
											 ContactName2 NVARCHAR(50),
											 ContactTel2 VARCHAR(20),
											 ContactName3 NVARCHAR(50),
											 ContactTel3 VARCHAR(20),
											 OrderToName NVARCHAR(50),
											 OrderToTel VARCHAR(20),
											 OrderToEmail VARCHAR(50),
											 CustomerDesc NVARCHAR(MAX),
											 IsUsed BIT,
											 MaterialWarehouseCode VARCHAR(20),
											 CIExtText01 NVARCHAR(200),
											 CIExtText02 NVARCHAR(200),
											 CIExtText03 NVARCHAR(200),
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											) 


            OPEN SourceData

            WHILE 1 = 1 BEGIN
                FETCH NEXT FROM SourceData INTO
								 @IUD_FLAG,
								 @OldCustomerCode,
								 @CustomerCode,
								 @CustomerName,
								 @CustomerNameL,
								 @IsCustomer,
								 @IsVendor,
								 @IsSourcing,
								 @BusinessCondition,
								 @BusinessType,
								 @BusinessNo,
								 @ZipCode,
								 @AddressText,
								 @CeoName,
								 @TelNo,
								 @FaxNo,
								 @ContactName1,
								 @ContactTel1,
								 @ContactName2,
								 @ContactTel2,
								 @ContactName3,
								 @ContactTel3,
								 @OrderToName,
								 @OrderToTel,
								 @OrderToEmail,
								 @CustomerDesc,
								 @IsUsed,
								 @MaterialWarehouseCode,
								 @CIExtText01,
								 @CIExtText02,
								 @CIExtText03,
								 @CreateDateTime,
								 @CreateUserID,
								 @ChangeDateTime,
								 @ChangeUserID


                IF @@FETCH_STATUS <> 0 BEGIN
					BREAK
				END
                IF @IUD_FLAG = 'INSERT' BEGIN

                    IF EXISTS (SELECT 1 FROM STB_CustomerInfo WHERE CustomerCode = @CustomerCode) BEGIN
						RAISERROR('Duplicate Data : KeyField = %s', 16, 1, @CustomerCode)
					END

                    IF @IsAutoKey = 1 BEGIN
                        EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_CustomerInfo',@CustomerCode OUTPUT
                    END

                    INSERT INTO STB_CustomerInfo
						(
						    CustomerCode,
						    CustomerName,
						    CustomerNameL,
						    IsCustomer,
						    IsVendor,
						    IsSourcing,
						    BusinessCondition,
						    BusinessType,
						    BusinessNo,
						    ZipCode,
						    AddressText,
						    CeoName,
						    TelNo,
						    FaxNo,
						    ContactName1,
						    ContactTel1,
						    ContactName2,
						    ContactTel2,
						    ContactName3,
						    ContactTel3,
						    OrderToName,
						    OrderToTel,
						    OrderToEmail,
						    CustomerDesc,
						    IsUsed,
						    MaterialWarehouseCode,
						    CIExtText01,
						    CIExtText02,
						    CIExtText03,
						    CreateDateTime,
						    CreateUserID,
						    ChangeDateTime,
						    ChangeUserID
						)
						VALUES
						(
						    @CustomerCode,
						    @CustomerName,
						    @CustomerNameL,
						    @IsCustomer,
						    @IsVendor,
						    @IsSourcing,
						    @BusinessCondition,
						    @BusinessType,
						    @BusinessNo,
						    @ZipCode,
						    @AddressText,
						    @CeoName,
						    @TelNo,
						    @FaxNo,
						    @ContactName1,
						    @ContactTel1,
						    @ContactName2,
						    @ContactTel2,
						    @ContactName3,
						    @ContactTel3,
						    @OrderToName,
						    @OrderToTel,
						    @OrderToEmail,
						    @CustomerDesc,
						    @IsUsed,
						    @MaterialWarehouseCode,
						    @CIExtText01,
						    @CIExtText02,
						    @CIExtText03,
						    GETDATE(),
						    @pProcessUserID,
						    @ChangeDateTime,
						    @ChangeUserID
						)

				END ELSE IF @IUD_FLAG = 'UPDATE' BEGIN
                    UPDATE STB_CustomerInfo
						SET
						    CustomerCode =   ISNULL(@CustomerCode,CustomerCode),
						    CustomerName =   ISNULL(@CustomerName,CustomerName),
						    CustomerNameL =   ISNULL(@CustomerNameL,CustomerNameL),
						    IsCustomer =   ISNULL(@IsCustomer,IsCustomer),
						    IsVendor =   ISNULL(@IsVendor,IsVendor),
						    IsSourcing =   ISNULL(@IsSourcing,IsSourcing),
						    BusinessCondition =   ISNULL(@BusinessCondition,BusinessCondition),
						    BusinessType =   ISNULL(@BusinessType,BusinessType),
						    BusinessNo =   ISNULL(@BusinessNo,BusinessNo),
						    ZipCode =   ISNULL(@ZipCode,ZipCode),
						    AddressText =   ISNULL(@AddressText,AddressText),
						    CeoName =   ISNULL(@CeoName,CeoName),
						    TelNo =   ISNULL(@TelNo,TelNo),
						    FaxNo =   ISNULL(@FaxNo,FaxNo),
						    ContactName1 =   ISNULL(@ContactName1,ContactName1),
						    ContactTel1 =   ISNULL(@ContactTel1,ContactTel1),
						    ContactName2 =   ISNULL(@ContactName2,ContactName2),
						    ContactTel2 =   ISNULL(@ContactTel2,ContactTel2),
						    ContactName3 =   ISNULL(@ContactName3,ContactName3),
						    ContactTel3 =   ISNULL(@ContactTel3,ContactTel3),
						    OrderToName =   ISNULL(@OrderToName,OrderToName),
						    OrderToTel =   ISNULL(@OrderToTel,OrderToTel),
						    OrderToEmail =   ISNULL(@OrderToEmail,OrderToEmail),
						    CustomerDesc =   ISNULL(@CustomerDesc,CustomerDesc),
						    IsUsed =   ISNULL(@IsUsed,IsUsed),
						    MaterialWarehouseCode =   ISNULL(@MaterialWarehouseCode,MaterialWarehouseCode),
						    CIExtText01 =   ISNULL(@CIExtText01,CIExtText01),
						    CIExtText02 =   ISNULL(@CIExtText02,CIExtText02),
						    CIExtText03 =   ISNULL(@CIExtText03,CIExtText03),
						    CreateDateTime =   ISNULL(@CreateDateTime,CreateDateTime),
						    CreateUserID =   ISNULL(@CreateUserID,CreateUserID),
						    ChangeDateTime = GETDATE(),
						    ChangeUserID = @pProcessUserID
						WHERE
						    CustomerCode = @OldCustomerCode
                END ELSE IF @IUD_FLAG = 'DELETE' BEGIN
                    DELETE FROM STB_CustomerInfo
						WHERE
						    CustomerCode = @OldCustomerCode
                END
            END
        END TRY
		BEGIN CATCH
			SET @ERROR_MSG = ERROR_MESSAGE()
			RAISERROR( @ERROR_MSG ,16, 1)
		END CATCH
			
		CLOSE SourceData;
		DEALLOCATE SourceData;
			
		EXEC sp_xml_removedocument @idoc	
    END
END
