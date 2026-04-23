-- =============================================
-- Author:		Mr.Duy
-- Create date: 2024-10-08
-- Description:	Thêm dữ liệu giá hoặc mã việt nam cho hàng
-- =============================================
CREATE PROCEDURE [dbo].[usp_VNStagePrices_iud]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
    @pProcessViewName VARCHAR(50),
	@pXml NVARCHAR(MAX) = null
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
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
    DECLARE @MaxKeyField VARCHAR(20)
-- khai báo biến  cho bảng
declare @model		varchar(50),
		@Oldmodel		varchar(50),
		@RouteV22	varchar(50),
		@PriceV22	varchar(50),
		@RouteV23	varchar(50),
		@PriceV23	varchar(50),
		@RouteV24	varchar(50),
		@PriceV24	varchar(50),
		@RouteV25	varchar(50),
		@PriceV25	varchar(50),
		@RouteV26	varchar(50),
		@PriceV26	varchar(50),
		@RouteV27	varchar(50),
		@PriceV27	varchar(50),
		@RouteV28	varchar(50),
		@PriceV28	varchar(50),
		@RouteV29	varchar(50),
		@PriceV29	varchar(50),
		@RouteV30	varchar(50),
		@PriceV30	varchar(50),
		@RouteV31	varchar(50),
		@PriceV31	varchar(50),
		@RouteV32	varchar(50),
		@PriceV32	varchar(50),
		@RouteV33	varchar(50),
		@PriceV33	varchar(50),
		@RouteV34	varchar(50),
		@PriceV34	varchar(50),
		@CreateDate	datetime,
		@MaterialCodeVN_V22	varchar(50),
		@MaterialCodeVN_V23	varchar(50),
		@MaterialCodeVN_V24	varchar(50),
		@MaterialCodeVN_V25	varchar(50),
		@MaterialCodeVN_V26	varchar(50),
		@MaterialCodeVN_V27	varchar(50),
		@MaterialCodeVN_V28	varchar(50),
		@MaterialCodeVN_V29	varchar(50),
		@MaterialCodeVN_V30	varchar(50),
		@MaterialCodeVN_V31	varchar(50),
		@MaterialCodeVN_V32	varchar(50),
		@MaterialCodeVN_V33	varchar(50),
		@MaterialCodeVN_V34	varchar(50),
		@WorkCenterCode varchar(50),
		@RouteVE01 varchar(50),
		@RouteVE02 varchar(50),
		@RouteVE03 varchar(50),
		@RouteVE04 varchar(50),
		@RouteVE05 varchar(50),
		@RouteVE06 varchar(50),
		@RouteVE07 varchar(50),
		@RouteVE08 varchar(50),
		@RouteVE09 varchar(50),
		@RouteVE10 varchar(50),
		@PriceVE01 varchar(50),
		@PriceVE02 varchar(50),
		@PriceVE03 varchar(50),
		@PriceVE04 varchar(50),
		@PriceVE05 varchar(50),
		@PriceVE06 varchar(50),
		@PriceVE07 varchar(50),
		@PriceVE08 varchar(50),
		@PriceVE09 varchar(50),
		@PriceVE10 varchar(50)

DECLARE @iDoc INT

    EXEC SmartFramework.dbo.usp_GetSerialRule 
			@pTableName = 'STB_VVT_StagePrices',
			@pIsAutoKey = @IsAutoKey OUTPUT,
			@pIsLoopIUD = @IsLoopIUD OUTPUT,
			@pPrefixData = @PrefixString OUTPUT,
			@pSerialLen = @SerialLen OUTPUT

	IF @IsAutoKey = 0 AND @IsLoopIUD = 0 BEGIN
   
	    EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
	
	    BEGIN TRY
			-- Process Insert Table
            MERGE STB_VVT_StagePrices AS TargetTable
			USING
				(
					SELECT
								CASE
							    WHEN XMLData.Oldmodel IS NULL THEN XMLData.model
							    ELSE XMLData.Oldmodel
							END AS Oldmode,
							XMLData.model,
							XMLData.RouteV22,
							XMLData.PriceV22,
							XMLData.RouteV23,
							XMLData.PriceV23,
							XMLData.RouteV24,
							XMLData.PriceV24,
							XMLData.RouteV25,
							XMLData.PriceV25,
							XMLData.RouteV26,
							XMLData.PriceV26,
							XMLData.RouteV27,
							XMLData.PriceV27,
							XMLData.RouteV28,
							XMLData.PriceV28,
							XMLData.RouteV29,
							XMLData.PriceV29,
							XMLData.RouteV30,
							XMLData.PriceV30,
							XMLData.RouteV31,
							XMLData.PriceV31,
							XMLData.RouteV32,
							XMLData.PriceV32,
							XMLData.RouteV33,
							XMLData.PriceV33,
							XMLData.RouteV34,
							XMLData.PriceV34,
							GETDATE() AS CreateDate,
							XMLData.MaterialCodeVN_V22,
							XMLData.MaterialCodeVN_V23,
							XMLData.MaterialCodeVN_V24,
							XMLData.MaterialCodeVN_V25,
							XMLData.MaterialCodeVN_V26,
							XMLData.MaterialCodeVN_V27,
							XMLData.MaterialCodeVN_V28,
							XMLData.MaterialCodeVN_V29,
							XMLData.MaterialCodeVN_V30,
							XMLData.MaterialCodeVN_V31,
							XMLData.MaterialCodeVN_V32,
							XMLData.MaterialCodeVN_V33,
							XMLData.MaterialCodeVN_V34,
							XMLData.RouteVE01,
							XMLData.RouteVE02,
							XMLData.RouteVE03,
							XMLData.RouteVE04,
							XMLData.RouteVE05,
							XMLData.RouteVE06,
							XMLData.RouteVE07,
							XMLData.RouteVE08,
							XMLData.RouteVE09,
							XMLData.RouteVE10,
							XMLData.PriceVE01,
							XMLData.PriceVE02,
							XMLData.PriceVE03,
							XMLData.PriceVE04,
							XMLData.PriceVE05,
							XMLData.PriceVE06,
							XMLData.PriceVE07,
							XMLData.PriceVE08,
							XMLData.PriceVE09,
							XMLData.PriceVE10,
							XMLData.WorkCenterCode
					FROM
							OPENXML(@idoc , @InsertTableName , 2)
							WITH  (
										model		varchar(50),
										Oldmodel	varchar(50),
										RouteV22	varchar(50),
										PriceV22	varchar(50),
										RouteV23	varchar(50),
										PriceV23	varchar(50),
										RouteV24	varchar(50),
										PriceV24	varchar(50),
										RouteV25	varchar(50),
										PriceV25	varchar(50),
										RouteV26	varchar(50),
										PriceV26	varchar(50),
										RouteV27	varchar(50),
										PriceV27	varchar(50),
										RouteV28	varchar(50),
										PriceV28	varchar(50),
										RouteV29	varchar(50),
										PriceV29	varchar(50),
										RouteV30	varchar(50),
										PriceV30	varchar(50),
										RouteV31	varchar(50),
										PriceV31	varchar(50),
										RouteV32	varchar(50),
										PriceV32	varchar(50),
										RouteV33	varchar(50),
										PriceV33	varchar(50),
										RouteV34	varchar(50),
										PriceV34	varchar(50),
										CreateDate	datetime,
										MaterialCodeVN_V22	varchar(50),
										MaterialCodeVN_V23	varchar(50),
										MaterialCodeVN_V24	varchar(50),
										MaterialCodeVN_V25	varchar(50),
										MaterialCodeVN_V26	varchar(50),
										MaterialCodeVN_V27	varchar(50),
										MaterialCodeVN_V28	varchar(50),
										MaterialCodeVN_V29	varchar(50),
										MaterialCodeVN_V30	varchar(50),
										MaterialCodeVN_V31	varchar(50),
										MaterialCodeVN_V32	varchar(50),
										MaterialCodeVN_V33	varchar(50),
										MaterialCodeVN_V34	varchar(50),
										RouteVE01 varchar(50),
										RouteVE02 varchar(50),
										RouteVE03 varchar(50),
										RouteVE04 varchar(50),
										RouteVE05 varchar(50),
										RouteVE06 varchar(50),
										RouteVE07 varchar(50),
										RouteVE08 varchar(50),
										RouteVE09 varchar(50),
										RouteVE10 varchar(50),
										PriceVE01 varchar(50),
										PriceVE02 varchar(50),
										PriceVE03 varchar(50),
										PriceVE04 varchar(50),
										PriceVE05 varchar(50),
										PriceVE06 varchar(50),
										PriceVE07 varchar(50),
										PriceVE08 varchar(50),
										PriceVE09 varchar(50),
										PriceVE10 varchar(50),
										WorkCenterCode varchar(50)
									) XMLData
				) AS SourceTable
			ON
				(
					TargetTable.model = SourceTable.model
				)

			WHEN MATCHED THEN
				UPDATE SET
					model = SourceTable.model,
					RouteV22 = SourceTable.RouteV22,
					PriceV22 = SourceTable.PriceV22,
					RouteV23 = SourceTable.RouteV23,
					PriceV23 = SourceTable.PriceV23,
					RouteV24 = SourceTable.RouteV24,
					PriceV24 = SourceTable.PriceV24,
					RouteV25 = SourceTable.RouteV25,
					PriceV25 = SourceTable.PriceV25,
					RouteV26 = SourceTable.RouteV26,
					PriceV26 = SourceTable.PriceV26,
					RouteV27 = SourceTable.RouteV27,
					PriceV27 = SourceTable.PriceV27,
					RouteV28 = SourceTable.RouteV28,
					PriceV28 = SourceTable.PriceV28,
					RouteV29 = SourceTable.RouteV29,
					PriceV29 = SourceTable.PriceV29,
					RouteV30 = SourceTable.RouteV30,
					PriceV30 = SourceTable.PriceV30,
					RouteV31 = SourceTable.RouteV31,
					PriceV31 = SourceTable.PriceV31,
					RouteV32 = SourceTable.RouteV32,
					PriceV32 = SourceTable.PriceV32,
					RouteV33 = SourceTable.RouteV33,
					PriceV33 = SourceTable.PriceV33,
					RouteV34 = SourceTable.RouteV34,
					PriceV34 = SourceTable.PriceV34,
					CreateDate = SourceTable.CreateDate,
					MaterialCodeVN_V22 = SourceTable.MaterialCodeVN_V22,
					MaterialCodeVN_V23 = SourceTable.MaterialCodeVN_V23,
					MaterialCodeVN_V24 = SourceTable.MaterialCodeVN_V24,
					MaterialCodeVN_V25 = SourceTable.MaterialCodeVN_V25,
					MaterialCodeVN_V26 = SourceTable.MaterialCodeVN_V26,
					MaterialCodeVN_V27 = SourceTable.MaterialCodeVN_V27,
					MaterialCodeVN_V28 = SourceTable.MaterialCodeVN_V28,
					MaterialCodeVN_V29 = SourceTable.MaterialCodeVN_V29,
					MaterialCodeVN_V30 = SourceTable.MaterialCodeVN_V30,
					MaterialCodeVN_V31 = SourceTable.MaterialCodeVN_V31,
					MaterialCodeVN_V32 = SourceTable.MaterialCodeVN_V32,
					MaterialCodeVN_V33 = SourceTable.MaterialCodeVN_V33,
					MaterialCodeVN_V34 = SourceTable.MaterialCodeVN_V34,
					WorkCenterCode	   = SourceTable.WorkCenterCode,
					RouteVE01=SourceTable.RouteVE01,
					RouteVE02=SourceTable.RouteVE02,
					RouteVE03=SourceTable.RouteVE03,
					RouteVE04=SourceTable.RouteVE04,
					RouteVE05=SourceTable.RouteVE05,
					RouteVE06=SourceTable.RouteVE06,
					RouteVE07=SourceTable.RouteVE07,
					RouteVE08=SourceTable.RouteVE08,
					RouteVE09=SourceTable.RouteVE09,
					RouteVE10=SourceTable.RouteVE10,
					PriceVE01=SourceTable.PriceVE01,
					PriceVE02=SourceTable.PriceVE02,
					PriceVE03=SourceTable.PriceVE03,
					PriceVE04=SourceTable.PriceVE04,
					PriceVE05=SourceTable.PriceVE05,
					PriceVE06=SourceTable.PriceVE06,
					PriceVE07=SourceTable.PriceVE07,
					PriceVE08=SourceTable.PriceVE08,
					PriceVE09=SourceTable.PriceVE09,
					PriceVE10=SourceTable.PriceVE10
			WHEN NOT MATCHED THEN
				INSERT
					(
						model,
						RouteV22,	
						PriceV22,	
						RouteV23,	
						PriceV23,	
						RouteV24,	
						PriceV24,	
						RouteV25,	
						PriceV25,	
						RouteV26,	
						PriceV26,	
						RouteV27,	
						PriceV27,	
						RouteV28,	
						PriceV28,	
						RouteV29,	
						PriceV29,	
						RouteV30,	
						PriceV30,	
						RouteV31,	
						PriceV31,	
						RouteV32,	
						PriceV32,	
						RouteV33,	
						PriceV33,	
						RouteV34,	
						PriceV34,	
						CreateDate,
						MaterialCodeVN_V22,
						MaterialCodeVN_V23,
						MaterialCodeVN_V24,
						MaterialCodeVN_V25,
						MaterialCodeVN_V26,
						MaterialCodeVN_V27,
						MaterialCodeVN_V28,
						MaterialCodeVN_V29,
						MaterialCodeVN_V30,
						MaterialCodeVN_V31,
						MaterialCodeVN_V32,
						MaterialCodeVN_V33,
						MaterialCodeVN_V34,
						WorkCenterCode,
						RouteVE01,
						RouteVE02,
						RouteVE03,
						RouteVE04,
						RouteVE05,
						RouteVE06,
						RouteVE07,
						RouteVE08,
						RouteVE09,
						RouteVE10,
						PriceVE01,
						PriceVE02,
						PriceVE03,
						PriceVE04,
						PriceVE05,
						PriceVE06,
						PriceVE07,
						PriceVE08,
						PriceVE09,
						PriceVE10
					)
				VALUES
					(
							SourceTable.model,
							SourceTable.RouteV22,
							SourceTable.PriceV22,
							SourceTable.RouteV23,
							SourceTable.PriceV23,
							SourceTable.RouteV24,
							SourceTable.PriceV24,
							SourceTable.RouteV25,
							SourceTable.PriceV25,
							SourceTable.RouteV26,
							SourceTable.PriceV26,
							SourceTable.RouteV27,
							SourceTable.PriceV27,
							SourceTable.RouteV28,
							SourceTable.PriceV28,
							SourceTable.RouteV29,
							SourceTable.PriceV29,
							SourceTable.RouteV30,
							SourceTable.PriceV30,
							SourceTable.RouteV31,
							SourceTable.PriceV31,
							SourceTable.RouteV32,
							SourceTable.PriceV32,
							SourceTable.RouteV33,
							SourceTable.PriceV33,
							SourceTable.RouteV34,
							SourceTable.PriceV34,
							SourceTable.CreateDate,
							SourceTable.MaterialCodeVN_V22,
							SourceTable.MaterialCodeVN_V23,
							SourceTable.MaterialCodeVN_V24,
							SourceTable.MaterialCodeVN_V25,
							SourceTable.MaterialCodeVN_V26,
							SourceTable.MaterialCodeVN_V27,
							SourceTable.MaterialCodeVN_V28,
							SourceTable.MaterialCodeVN_V29,
							SourceTable.MaterialCodeVN_V30,
							SourceTable.MaterialCodeVN_V31,
							SourceTable.MaterialCodeVN_V32,
							SourceTable.MaterialCodeVN_V33,
							SourceTable.MaterialCodeVN_V34,
							SourceTable.WorkCenterCode,
							SourceTable.RouteVE01,
							SourceTable.RouteVE02,
							SourceTable.RouteVE03,
							SourceTable.RouteVE04,
							SourceTable.RouteVE05,
							SourceTable.RouteVE06,
							SourceTable.RouteVE07,
							SourceTable.RouteVE08,
							SourceTable.RouteVE09,
							SourceTable.RouteVE10,
							SourceTable.PriceVE01,
							SourceTable.PriceVE02,
							SourceTable.PriceVE03,
							SourceTable.PriceVE04,
							SourceTable.PriceVE05,
							SourceTable.PriceVE06,
							SourceTable.PriceVE07,
							SourceTable.PriceVE08,
							SourceTable.PriceVE09,
							SourceTable.PriceVE10
					);




			-- Process Update Table
            MERGE STB_VVT_StagePrices AS TargetTable
			USING
				(
					SELECT
					CASE
							    WHEN XMLData.Oldmodel IS NULL THEN XMLData.model
							    ELSE XMLData.Oldmodel
							END AS Oldmodel,
							XMLData.model,
							XMLData.RouteV22,
							XMLData.PriceV22,
							XMLData.RouteV23,
							XMLData.PriceV23,
							XMLData.RouteV24,
							XMLData.PriceV24,
							XMLData.RouteV25,
							XMLData.PriceV25,
							XMLData.RouteV26,
							XMLData.PriceV26,
							XMLData.RouteV27,
							XMLData.PriceV27,
							XMLData.RouteV28,
							XMLData.PriceV28,
							XMLData.RouteV29,
							XMLData.PriceV29,
							XMLData.RouteV30,
							XMLData.PriceV30,
							XMLData.RouteV31,
							XMLData.PriceV31,
							XMLData.RouteV32,
							XMLData.PriceV32,
							XMLData.RouteV33,
							XMLData.PriceV33,
							XMLData.RouteV34,
							XMLData.PriceV34,
							GETDATE() AS CreateDate,
							XMLData.MaterialCodeVN_V22,
							XMLData.MaterialCodeVN_V23,
							XMLData.MaterialCodeVN_V24,
							XMLData.MaterialCodeVN_V25,
							XMLData.MaterialCodeVN_V26,
							XMLData.MaterialCodeVN_V27,
							XMLData.MaterialCodeVN_V28,
							XMLData.MaterialCodeVN_V29,
							XMLData.MaterialCodeVN_V30,
							XMLData.MaterialCodeVN_V31,
							XMLData.MaterialCodeVN_V32,
							XMLData.MaterialCodeVN_V33,
							XMLData.MaterialCodeVN_V34,
							XMLData.WorkCenterCode,
							XMLData.RouteVE01,
							XMLData.RouteVE02,
							XMLData.RouteVE03,
							XMLData.RouteVE04,
							XMLData.RouteVE05,
							XMLData.RouteVE06,
							XMLData.RouteVE07,
							XMLData.RouteVE08,
							XMLData.RouteVE09,
							XMLData.RouteVE10,
							XMLData.PriceVE01,
							XMLData.PriceVE02,
							XMLData.PriceVE03,
							XMLData.PriceVE04,
							XMLData.PriceVE05,
							XMLData.PriceVE06,
							XMLData.PriceVE07,
							XMLData.PriceVE08,
							XMLData.PriceVE09,
							XMLData.PriceVE10
					FROM
							OPENXML(@idoc , @UpdateTableName , 2)
							WITH  (
										model varchar(50),
										Oldmodel varchar(50),
										RouteV22	varchar(50),
										PriceV22	varchar(50),
										RouteV23	varchar(50),
										PriceV23	varchar(50),
										RouteV24	varchar(50),
										PriceV24	varchar(50),
										RouteV25	varchar(50),
										PriceV25	varchar(50),
										RouteV26	varchar(50),
										PriceV26	varchar(50),
										RouteV27	varchar(50),
										PriceV27	varchar(50),
										RouteV28	varchar(50),
										PriceV28	varchar(50),
										RouteV29	varchar(50),
										PriceV29	varchar(50),
										RouteV30	varchar(50),
										PriceV30	varchar(50),
										RouteV31	varchar(50),
										PriceV31	varchar(50),
										RouteV32	varchar(50),
										PriceV32	varchar(50),
										RouteV33	varchar(50),
										PriceV33	varchar(50),
										RouteV34	varchar(50),
										PriceV34	varchar(50),
										CreateDate	datetime,
										MaterialCodeVN_V22	varchar(50),
										MaterialCodeVN_V23	varchar(50),
										MaterialCodeVN_V24	varchar(50),
										MaterialCodeVN_V25	varchar(50),
										MaterialCodeVN_V26	varchar(50),
										MaterialCodeVN_V27	varchar(50),
										MaterialCodeVN_V28	varchar(50),
										MaterialCodeVN_V29	varchar(50),
										MaterialCodeVN_V30	varchar(50),
										MaterialCodeVN_V31	varchar(50),
										MaterialCodeVN_V32	varchar(50),
										MaterialCodeVN_V33	varchar(50),
										MaterialCodeVN_V34	varchar(50),
										RouteVE01 varchar(50),
										RouteVE02 varchar(50),
										RouteVE03 varchar(50),
										RouteVE04 varchar(50),
										RouteVE05 varchar(50),
										RouteVE06 varchar(50),
										RouteVE07 varchar(50),
										RouteVE08 varchar(50),
										RouteVE09 varchar(50),
										RouteVE10 varchar(50),
										PriceVE01 varchar(50),
										PriceVE02 varchar(50),
										PriceVE03 varchar(50),
										PriceVE04 varchar(50),
										PriceVE05 varchar(50),
										PriceVE06 varchar(50),
										PriceVE07 varchar(50),
										PriceVE08 varchar(50),
										PriceVE09 varchar(50),
										PriceVE10 varchar(50),
										WorkCenterCode		varchar(50)
									) XMLData
				) AS SourceTable
			ON
				(
					TargetTable.model = SourceTable.model
				)

			WHEN MATCHED THEN
				UPDATE SET
					model = SourceTable.model,
					RouteV22 = SourceTable.RouteV22,
					PriceV22 = SourceTable.PriceV22,
					RouteV23 = SourceTable.RouteV23,
					PriceV23 = SourceTable.PriceV23,
					RouteV24 = SourceTable.RouteV24,
					PriceV24 = SourceTable.PriceV24,
					RouteV25 = SourceTable.RouteV25,
					PriceV25 = SourceTable.PriceV25,
					RouteV26 = SourceTable.RouteV26,
					PriceV26 = SourceTable.PriceV26,
					RouteV27 = SourceTable.RouteV27,
					PriceV27 = SourceTable.PriceV27,
					RouteV28 = SourceTable.RouteV28,
					PriceV28 = SourceTable.PriceV28,
					RouteV29 = SourceTable.RouteV29,
					PriceV29 = SourceTable.PriceV29,
					RouteV30 = SourceTable.RouteV30,
					PriceV30 = SourceTable.PriceV30,
					RouteV31 = SourceTable.RouteV31,
					PriceV31 = SourceTable.PriceV31,
					RouteV32 = SourceTable.RouteV32,
					PriceV32 = SourceTable.PriceV32,
					RouteV33 = SourceTable.RouteV33,
					PriceV33 = SourceTable.PriceV33,
					RouteV34 = SourceTable.RouteV34,
					PriceV34 = SourceTable.PriceV34,
					CreateDate = SourceTable.CreateDate,
					MaterialCodeVN_V22 = SourceTable.MaterialCodeVN_V22,
					MaterialCodeVN_V23 = SourceTable.MaterialCodeVN_V23,
					MaterialCodeVN_V24 = SourceTable.MaterialCodeVN_V24,
					MaterialCodeVN_V25 = SourceTable.MaterialCodeVN_V25,
					MaterialCodeVN_V26 = SourceTable.MaterialCodeVN_V26,
					MaterialCodeVN_V27 = SourceTable.MaterialCodeVN_V27,
					MaterialCodeVN_V28 = SourceTable.MaterialCodeVN_V28,
					MaterialCodeVN_V29 = SourceTable.MaterialCodeVN_V29,
					MaterialCodeVN_V30 = SourceTable.MaterialCodeVN_V30,
					MaterialCodeVN_V31 = SourceTable.MaterialCodeVN_V31,
					MaterialCodeVN_V32 = SourceTable.MaterialCodeVN_V32,
					MaterialCodeVN_V33 = SourceTable.MaterialCodeVN_V33,
					MaterialCodeVN_V34 = SourceTable.MaterialCodeVN_V34,
					RouteVE01=SourceTable.RouteVE01,
					RouteVE02=SourceTable.RouteVE02,
					RouteVE03=SourceTable.RouteVE03,
					RouteVE04=SourceTable.RouteVE04,
					RouteVE05=SourceTable.RouteVE05,
					RouteVE06=SourceTable.RouteVE06,
					RouteVE07=SourceTable.RouteVE07,
					RouteVE08=SourceTable.RouteVE08,
					RouteVE09=SourceTable.RouteVE09,
					RouteVE10=SourceTable.RouteVE10,
					PriceVE01=SourceTable.PriceVE01,
					PriceVE02=SourceTable.PriceVE02,
					PriceVE03=SourceTable.PriceVE03,
					PriceVE04=SourceTable.PriceVE04,
					PriceVE05=SourceTable.PriceVE05,
					PriceVE06=SourceTable.PriceVE06,
					PriceVE07=SourceTable.PriceVE07,
					PriceVE08=SourceTable.PriceVE08,
					PriceVE09=SourceTable.PriceVE09,
					PriceVE10=SourceTable.PriceVE10,
					WorkCenterCode = SourceTable.WorkCenterCode
			WHEN NOT MATCHED THEN
				INSERT
					(
					model,
						RouteV22,	
						PriceV22,	
						RouteV23,	
						PriceV23,	
						RouteV24,	
						PriceV24,	
						RouteV25,	
						PriceV25,	
						RouteV26,	
						PriceV26,	
						RouteV27,	
						PriceV27,	
						RouteV28,	
						PriceV28,	
						RouteV29,	
						PriceV29,	
						RouteV30,	
						PriceV30,	
						RouteV31,	
						PriceV31,	
						RouteV32,	
						PriceV32,	
						RouteV33,	
						PriceV33,	
						RouteV34,	
						PriceV34,	
						CreateDate,
						MaterialCodeVN_V22,
						MaterialCodeVN_V23,
						MaterialCodeVN_V24,
						MaterialCodeVN_V25,
						MaterialCodeVN_V26,
						MaterialCodeVN_V27,
						MaterialCodeVN_V28,
						MaterialCodeVN_V29,
						MaterialCodeVN_V30,
						MaterialCodeVN_V31,
						MaterialCodeVN_V32,
						MaterialCodeVN_V33,
						MaterialCodeVN_V34,
						RouteVE01,
						RouteVE02,
						RouteVE03,
						RouteVE04,
						RouteVE05,
						RouteVE06,
						RouteVE07,
						RouteVE08,
						RouteVE09,
						RouteVE10,
						PriceVE01,
						PriceVE02,
						PriceVE03,
						PriceVE04,
						PriceVE05,
						PriceVE06,
						PriceVE07,
						PriceVE08,
						PriceVE09,
						PriceVE10,
						WorkCenterCode
					)
				VALUES
					(
							SourceTable.model,
							SourceTable.RouteV22,
							SourceTable.PriceV22,
							SourceTable.RouteV23,
							SourceTable.PriceV23,
							SourceTable.RouteV24,
							SourceTable.PriceV24,
							SourceTable.RouteV25,
							SourceTable.PriceV25,
							SourceTable.RouteV26,
							SourceTable.PriceV26,
							SourceTable.RouteV27,
							SourceTable.PriceV27,
							SourceTable.RouteV28,
							SourceTable.PriceV28,
							SourceTable.RouteV29,
							SourceTable.PriceV29,
							SourceTable.RouteV30,
							SourceTable.PriceV30,
							SourceTable.RouteV31,
							SourceTable.PriceV31,
							SourceTable.RouteV32,
							SourceTable.PriceV32,
							SourceTable.RouteV33,
							SourceTable.PriceV33,
							SourceTable.RouteV34,
							SourceTable.PriceV34,
							SourceTable.CreateDate,
							SourceTable.MaterialCodeVN_V22,
							SourceTable.MaterialCodeVN_V23,
							SourceTable.MaterialCodeVN_V24,
							SourceTable.MaterialCodeVN_V25,
							SourceTable.MaterialCodeVN_V26,
							SourceTable.MaterialCodeVN_V27,
							SourceTable.MaterialCodeVN_V28,
							SourceTable.MaterialCodeVN_V29,
							SourceTable.MaterialCodeVN_V30,
							SourceTable.MaterialCodeVN_V31,
							SourceTable.MaterialCodeVN_V32,
							SourceTable.MaterialCodeVN_V33,
							SourceTable.MaterialCodeVN_V34,
							SourceTable.RouteVE01,
							SourceTable.RouteVE02,
							SourceTable.RouteVE03,
							SourceTable.RouteVE04,
							SourceTable.RouteVE05,
							SourceTable.RouteVE06,
							SourceTable.RouteVE07,
							SourceTable.RouteVE08,
							SourceTable.RouteVE09,
							SourceTable.RouteVE10,
							SourceTable.PriceVE01,
							SourceTable.PriceVE02,
							SourceTable.PriceVE03,
							SourceTable.PriceVE04,
							SourceTable.PriceVE05,
							SourceTable.PriceVE06,
							SourceTable.PriceVE07,
							SourceTable.PriceVE08,
							SourceTable.PriceVE09,
							SourceTable.PriceVE10,
							SourceTable.WorkCenterCode
					);


			-- Process Delete Table
            MERGE STB_VVT_StagePrices AS TargetTable
			USING
				(
						SELECT
						CASE
							    WHEN XMLData.Oldmodel IS NULL THEN XMLData.model
							    ELSE XMLData.Oldmodel
							END AS Oldmodel,
							XMLData.model,
							XMLData.RouteV22,
							XMLData.PriceV22,
							XMLData.RouteV23,
							XMLData.PriceV23,
							XMLData.RouteV24,
							XMLData.PriceV24,
							XMLData.RouteV25,
							XMLData.PriceV25,
							XMLData.RouteV26,
							XMLData.PriceV26,
							XMLData.RouteV27,
							XMLData.PriceV27,
							XMLData.RouteV28,
							XMLData.PriceV28,
							XMLData.RouteV29,
							XMLData.PriceV29,
							XMLData.RouteV30,
							XMLData.PriceV30,
							XMLData.RouteV31,
							XMLData.PriceV31,
							XMLData.RouteV32,
							XMLData.PriceV32,
							XMLData.RouteV33,
							XMLData.PriceV33,
							XMLData.RouteV34,
							XMLData.PriceV34,
							GETDATE() AS CreateDate,
							XMLData.MaterialCodeVN_V22,
							XMLData.MaterialCodeVN_V23,
							XMLData.MaterialCodeVN_V24,
							XMLData.MaterialCodeVN_V25,
							XMLData.MaterialCodeVN_V26,
							XMLData.MaterialCodeVN_V27,
							XMLData.MaterialCodeVN_V28,
							XMLData.MaterialCodeVN_V29,
							XMLData.MaterialCodeVN_V30,
							XMLData.MaterialCodeVN_V31,
							XMLData.MaterialCodeVN_V32,
							XMLData.MaterialCodeVN_V33,
							XMLData.MaterialCodeVN_V34,
							XMLData.WorkCenterCode,
							XMLData.RouteVE01,
							XMLData.RouteVE02,
							XMLData.RouteVE03,
							XMLData.RouteVE04,
							XMLData.RouteVE05,
							XMLData.RouteVE06,
							XMLData.RouteVE07,
							XMLData.RouteVE08,
							XMLData.RouteVE09,
							XMLData.RouteVE10,
							XMLData.PriceVE01,
							XMLData.PriceVE02,
							XMLData.PriceVE03,
							XMLData.PriceVE04,
							XMLData.PriceVE05,
							XMLData.PriceVE06,
							XMLData.PriceVE07,
							XMLData.PriceVE08,
							XMLData.PriceVE09,
							XMLData.PriceVE10
					FROM
							OPENXML(@idoc , @DeleteTableName , 2)
							WITH  (
										model		varchar(50),
										Oldmodel	varchar(50),
										RouteV22	varchar(50),
										PriceV22	varchar(50),
										RouteV23	varchar(50),
										PriceV23	varchar(50),
										RouteV24	varchar(50),
										PriceV24	varchar(50),
										RouteV25	varchar(50),
										PriceV25	varchar(50),
										RouteV26	varchar(50),
										PriceV26	varchar(50),
										RouteV27	varchar(50),
										PriceV27	varchar(50),
										RouteV28	varchar(50),
										PriceV28	varchar(50),
										RouteV29	varchar(50),
										PriceV29	varchar(50),
										RouteV30	varchar(50),
										PriceV30	varchar(50),
										RouteV31	varchar(50),
										PriceV31	varchar(50),
										RouteV32	varchar(50),
										PriceV32	varchar(50),
										RouteV33	varchar(50),
										PriceV33	varchar(50),
										RouteV34	varchar(50),
										PriceV34	varchar(50),
										CreateDate	datetime,
										MaterialCodeVN_V22	varchar(50),
										MaterialCodeVN_V23	varchar(50),
										MaterialCodeVN_V24	varchar(50),
										MaterialCodeVN_V25	varchar(50),
										MaterialCodeVN_V26	varchar(50),
										MaterialCodeVN_V27	varchar(50),
										MaterialCodeVN_V28	varchar(50),
										MaterialCodeVN_V29	varchar(50),
										MaterialCodeVN_V30	varchar(50),
										MaterialCodeVN_V31	varchar(50),
										MaterialCodeVN_V32	varchar(50),
										MaterialCodeVN_V33	varchar(50),
										MaterialCodeVN_V34	varchar(50),
										RouteVE01 varchar(50),
										RouteVE02 varchar(50),
										RouteVE03 varchar(50),
										RouteVE04 varchar(50),
										RouteVE05 varchar(50),
										RouteVE06 varchar(50),
										RouteVE07 varchar(50),
										RouteVE08 varchar(50),
										RouteVE09 varchar(50),
										RouteVE10 varchar(50),
										PriceVE01 varchar(50),
										PriceVE02 varchar(50),
										PriceVE03 varchar(50),
										PriceVE04 varchar(50),
										PriceVE05 varchar(50),
										PriceVE06 varchar(50),
										PriceVE07 varchar(50),
										PriceVE08 varchar(50),
										PriceVE09 varchar(50),
										PriceVE10 varchar(50),
										WorkCenterCode		varchar(50)
									) XMLData
				) AS SourceTable
			ON
				(
					TargetTable.model = SourceTable.model
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
							XMLData.model,
							XMLData.RouteV22,
							XMLData.PriceV22,
							XMLData.RouteV23,
							XMLData.PriceV23,
							XMLData.RouteV24,
							XMLData.PriceV24,
							XMLData.RouteV25,
							XMLData.PriceV25,
							XMLData.RouteV26,
							XMLData.PriceV26,
							XMLData.RouteV27,
							XMLData.PriceV27,
							XMLData.RouteV28,
							XMLData.PriceV28,
							XMLData.RouteV29,
							XMLData.PriceV29,
							XMLData.RouteV30,
							XMLData.PriceV30,
							XMLData.RouteV31,
							XMLData.PriceV31,
							XMLData.RouteV32,
							XMLData.PriceV32,
							XMLData.RouteV33,
							XMLData.PriceV33,
							XMLData.RouteV34,
							XMLData.PriceV34,
							GETDATE() AS CreateDate,
							XMLData.MaterialCodeVN_V22,
							XMLData.MaterialCodeVN_V23,
							XMLData.MaterialCodeVN_V24,
							XMLData.MaterialCodeVN_V25,
							XMLData.MaterialCodeVN_V26,
							XMLData.MaterialCodeVN_V27,
							XMLData.MaterialCodeVN_V28,
							XMLData.MaterialCodeVN_V29,
							XMLData.MaterialCodeVN_V30,
							XMLData.MaterialCodeVN_V31,
							XMLData.MaterialCodeVN_V32,
							XMLData.MaterialCodeVN_V33,
							XMLData.MaterialCodeVN_V34,
							XMLData.RouteVE01,
							XMLData.RouteVE02,
							XMLData.RouteVE03,
							XMLData.RouteVE04,
							XMLData.RouteVE05,
							XMLData.RouteVE06,
							XMLData.RouteVE07,
							XMLData.RouteVE08,
							XMLData.RouteVE09,
							XMLData.RouteVE10,
							XMLData.PriceVE01,
							XMLData.PriceVE02,
							XMLData.PriceVE03,
							XMLData.PriceVE04,
							XMLData.PriceVE05,
							XMLData.PriceVE06,
							XMLData.PriceVE07,
							XMLData.PriceVE08,
							XMLData.PriceVE09,
							XMLData.PriceVE10,
							XMLData.WorkCenterCode
							FROM
									OPENXML(@idoc , @InsertTableName , 2)
							        WITH  (
										model		varchar(50),
										RouteV22	varchar(50),
										PriceV22	varchar(50),
										RouteV23	varchar(50),
										PriceV23	varchar(50),
										RouteV24	varchar(50),
										PriceV24	varchar(50),
										RouteV25	varchar(50),
										PriceV25	varchar(50),
										RouteV26	varchar(50),
										PriceV26	varchar(50),
										RouteV27	varchar(50),
										PriceV27	varchar(50),
										RouteV28	varchar(50),
										PriceV28	varchar(50),
										RouteV29	varchar(50),
										PriceV29	varchar(50),
										RouteV30	varchar(50),
										PriceV30	varchar(50),
										RouteV31	varchar(50),
										PriceV31	varchar(50),
										RouteV32	varchar(50),
										PriceV32	varchar(50),
										RouteV33	varchar(50),
										PriceV33	varchar(50),
										RouteV34	varchar(50),
										PriceV34	varchar(50),
										CreateDate	datetime,
										MaterialCodeVN_V22	varchar(50),
										MaterialCodeVN_V23	varchar(50),
										MaterialCodeVN_V24	varchar(50),
										MaterialCodeVN_V25	varchar(50),
										MaterialCodeVN_V26	varchar(50),
										MaterialCodeVN_V27	varchar(50),
										MaterialCodeVN_V28	varchar(50),
										MaterialCodeVN_V29	varchar(50),
										MaterialCodeVN_V30	varchar(50),
										MaterialCodeVN_V31	varchar(50),
										MaterialCodeVN_V32	varchar(50),
										MaterialCodeVN_V33	varchar(50),
										MaterialCodeVN_V34	varchar(50),
										RouteVE01 varchar(50),
										RouteVE02 varchar(50),
										RouteVE03 varchar(50),
										RouteVE04 varchar(50),
										RouteVE05 varchar(50),
										RouteVE06 varchar(50),
										RouteVE07 varchar(50),
										RouteVE08 varchar(50),
										RouteVE09 varchar(50),
										RouteVE10 varchar(50),
										PriceVE01 varchar(50),
										PriceVE02 varchar(50),
										PriceVE03 varchar(50),
										PriceVE04 varchar(50),
										PriceVE05 varchar(50),
										PriceVE06 varchar(50),
										PriceVE07 varchar(50),
										PriceVE08 varchar(50),
										PriceVE09 varchar(50),
										PriceVE10 varchar(50),
										WorkCenterCode		varchar(50)
											) XMLData
							UNION ALL
							SELECT
									'UPDATE' AS IUD_FLAG,
									XMLData.model,
							XMLData.RouteV22,
							XMLData.PriceV22,
							XMLData.RouteV23,
							XMLData.PriceV23,
							XMLData.RouteV24,
							XMLData.PriceV24,
							XMLData.RouteV25,
							XMLData.PriceV25,
							XMLData.RouteV26,
							XMLData.PriceV26,
							XMLData.RouteV27,
							XMLData.PriceV27,
							XMLData.RouteV28,
							XMLData.PriceV28,
							XMLData.RouteV29,
							XMLData.PriceV29,
							XMLData.RouteV30,
							XMLData.PriceV30,
							XMLData.RouteV31,
							XMLData.PriceV31,
							XMLData.RouteV32,
							XMLData.PriceV32,
							XMLData.RouteV33,
							XMLData.PriceV33,
							XMLData.RouteV34,
							XMLData.PriceV34,
							GETDATE() AS CreateDate,
							XMLData.MaterialCodeVN_V22,
							XMLData.MaterialCodeVN_V23,
							XMLData.MaterialCodeVN_V24,
							XMLData.MaterialCodeVN_V25,
							XMLData.MaterialCodeVN_V26,
							XMLData.MaterialCodeVN_V27,
							XMLData.MaterialCodeVN_V28,
							XMLData.MaterialCodeVN_V29,
							XMLData.MaterialCodeVN_V30,
							XMLData.MaterialCodeVN_V31,
							XMLData.MaterialCodeVN_V32,
							XMLData.MaterialCodeVN_V33,
							XMLData.MaterialCodeVN_V34,
							XMLData.RouteVE01,
							XMLData.RouteVE02,
							XMLData.RouteVE03,
							XMLData.RouteVE04,
							XMLData.RouteVE05,
							XMLData.RouteVE06,
							XMLData.RouteVE07,
							XMLData.RouteVE08,
							XMLData.RouteVE09,
							XMLData.RouteVE10,
							XMLData.PriceVE01,
							XMLData.PriceVE02,
							XMLData.PriceVE03,
							XMLData.PriceVE04,
							XMLData.PriceVE05,
							XMLData.PriceVE06,
							XMLData.PriceVE07,
							XMLData.PriceVE08,
							XMLData.PriceVE09,
							XMLData.PriceVE10,
							XMLData.WorkCenterCode
							FROM
									OPENXML(@idoc , @UpdateTableName , 2)
							        WITH  (
										model		varchar(50),
										RouteV22	varchar(50),
										PriceV22	varchar(50),
										RouteV23	varchar(50),
										PriceV23	varchar(50),
										RouteV24	varchar(50),
										PriceV24	varchar(50),
										RouteV25	varchar(50),
										PriceV25	varchar(50),
										RouteV26	varchar(50),
										PriceV26	varchar(50),
										RouteV27	varchar(50),
										PriceV27	varchar(50),
										RouteV28	varchar(50),
										PriceV28	varchar(50),
										RouteV29	varchar(50),
										PriceV29	varchar(50),
										RouteV30	varchar(50),
										PriceV30	varchar(50),
										RouteV31	varchar(50),
										PriceV31	varchar(50),
										RouteV32	varchar(50),
										PriceV32	varchar(50),
										RouteV33	varchar(50),
										PriceV33	varchar(50),
										RouteV34	varchar(50),
										PriceV34	varchar(50),
										CreateDate	datetime,
										MaterialCodeVN_V22	varchar(50),
										MaterialCodeVN_V23	varchar(50),
										MaterialCodeVN_V24	varchar(50),
										MaterialCodeVN_V25	varchar(50),
										MaterialCodeVN_V26	varchar(50),
										MaterialCodeVN_V27	varchar(50),
										MaterialCodeVN_V28	varchar(50),
										MaterialCodeVN_V29	varchar(50),
										MaterialCodeVN_V30	varchar(50),
										MaterialCodeVN_V31	varchar(50),
										MaterialCodeVN_V32	varchar(50),
										MaterialCodeVN_V33	varchar(50),
										MaterialCodeVN_V34	varchar(50),
										RouteVE01 varchar(50),
										RouteVE02 varchar(50),
										RouteVE03 varchar(50),
										RouteVE04 varchar(50),
										RouteVE05 varchar(50),
										RouteVE06 varchar(50),
										RouteVE07 varchar(50),
										RouteVE08 varchar(50),
										RouteVE09 varchar(50),
										RouteVE10 varchar(50),
										PriceVE01 varchar(50),
										PriceVE02 varchar(50),
										PriceVE03 varchar(50),
										PriceVE04 varchar(50),
										PriceVE05 varchar(50),
										PriceVE06 varchar(50),
										PriceVE07 varchar(50),
										PriceVE08 varchar(50),
										PriceVE09 varchar(50),
										PriceVE10 varchar(50),
										WorkCenterCode		varchar(50)
											) XMLData
							UNION ALL
							SELECT
									'DELETE' AS IUD_FLAG,
									XMLData.model,
							XMLData.RouteV22,
							XMLData.PriceV22,
							XMLData.RouteV23,
							XMLData.PriceV23,
							XMLData.RouteV24,
							XMLData.PriceV24,
							XMLData.RouteV25,
							XMLData.PriceV25,
							XMLData.RouteV26,
							XMLData.PriceV26,
							XMLData.RouteV27,
							XMLData.PriceV27,
							XMLData.RouteV28,
							XMLData.PriceV28,
							XMLData.RouteV29,
							XMLData.PriceV29,
							XMLData.RouteV30,
							XMLData.PriceV30,
							XMLData.RouteV31,
							XMLData.PriceV31,
							XMLData.RouteV32,
							XMLData.PriceV32,
							XMLData.RouteV33,
							XMLData.PriceV33,
							XMLData.RouteV34,
							XMLData.PriceV34,
							GETDATE() AS CreateDate,
							XMLData.MaterialCodeVN_V22,
							XMLData.MaterialCodeVN_V23,
							XMLData.MaterialCodeVN_V24,
							XMLData.MaterialCodeVN_V25,
							XMLData.MaterialCodeVN_V26,
							XMLData.MaterialCodeVN_V27,
							XMLData.MaterialCodeVN_V28,
							XMLData.MaterialCodeVN_V29,
							XMLData.MaterialCodeVN_V30,
							XMLData.MaterialCodeVN_V31,
							XMLData.MaterialCodeVN_V32,
							XMLData.MaterialCodeVN_V33,
							XMLData.MaterialCodeVN_V34,
							XMLData.RouteVE01,
							XMLData.RouteVE02,
							XMLData.RouteVE03,
							XMLData.RouteVE04,
							XMLData.RouteVE05,
							XMLData.RouteVE06,
							XMLData.RouteVE07,
							XMLData.RouteVE08,
							XMLData.RouteVE09,
							XMLData.RouteVE10,
							XMLData.PriceVE01,
							XMLData.PriceVE02,
							XMLData.PriceVE03,
							XMLData.PriceVE04,
							XMLData.PriceVE05,
							XMLData.PriceVE06,
							XMLData.PriceVE07,
							XMLData.PriceVE08,
							XMLData.PriceVE09,
							XMLData.PriceVE10,
							XMLData.WorkCenterCode
							FROM
									OPENXML(@idoc , @DeleteTableName , 2)
							        WITH  (
										model		varchar(50),
										RouteV22	varchar(50),
										PriceV22	varchar(50),
										RouteV23	varchar(50),
										PriceV23	varchar(50),
										RouteV24	varchar(50),
										PriceV24	varchar(50),
										RouteV25	varchar(50),
										PriceV25	varchar(50),
										RouteV26	varchar(50),
										PriceV26	varchar(50),
										RouteV27	varchar(50),
										PriceV27	varchar(50),
										RouteV28	varchar(50),
										PriceV28	varchar(50),
										RouteV29	varchar(50),
										PriceV29	varchar(50),
										RouteV30	varchar(50),
										PriceV30	varchar(50),
										RouteV31	varchar(50),
										PriceV31	varchar(50),
										RouteV32	varchar(50),
										PriceV32	varchar(50),
										RouteV33	varchar(50),
										PriceV33	varchar(50),
										RouteV34	varchar(50),
										PriceV34	varchar(50),
										CreateDate	datetime,
										MaterialCodeVN_V22	varchar(50),
										MaterialCodeVN_V23	varchar(50),
										MaterialCodeVN_V24	varchar(50),
										MaterialCodeVN_V25	varchar(50),
										MaterialCodeVN_V26	varchar(50),
										MaterialCodeVN_V27	varchar(50),
										MaterialCodeVN_V28	varchar(50),
										MaterialCodeVN_V29	varchar(50),
										MaterialCodeVN_V30	varchar(50),
										MaterialCodeVN_V31	varchar(50),
										MaterialCodeVN_V32	varchar(50),
										MaterialCodeVN_V33	varchar(50),
										MaterialCodeVN_V34	varchar(50),
										RouteVE01 varchar(50),
										RouteVE02 varchar(50),
										RouteVE03 varchar(50),
										RouteVE04 varchar(50),
										RouteVE05 varchar(50),
										RouteVE06 varchar(50),
										RouteVE07 varchar(50),
										RouteVE08 varchar(50),
										RouteVE09 varchar(50),
										RouteVE10 varchar(50),
										PriceVE01 varchar(50),
										PriceVE02 varchar(50),
										PriceVE03 varchar(50),
										PriceVE04 varchar(50),
										PriceVE05 varchar(50),
										PriceVE06 varchar(50),
										PriceVE07 varchar(50),
										PriceVE08 varchar(50),
										PriceVE09 varchar(50),
										PriceVE10 varchar(50),
										WorkCenterCode		varchar(50)
											) XMLData


            OPEN SourceData

            WHILE 1 = 1 BEGIN

                FETCH NEXT FROM SourceData INTO
								 @IUD_FLAG,
								 @model,	
								 @RouteV22,
								 @PriceV22,
								 @RouteV23,
								 @PriceV23,
								 @RouteV24,
								 @PriceV24,
								 @RouteV25,
								 @PriceV25,
								 @RouteV26,
								 @PriceV26,
								 @RouteV27,
								 @PriceV27,
								 @RouteV28,
								 @PriceV28,
								 @RouteV29,
								 @PriceV29,
								 @RouteV30,
								 @PriceV30,
								 @RouteV31,
								 @PriceV31,
								 @RouteV32,
								 @PriceV32,
								 @RouteV33,
								 @PriceV33,
								 @RouteV34,
								 @PriceV34,
								 @CreateDate,
								 @MaterialCodeVN_V22,	
								 @MaterialCodeVN_V23,	
								 @MaterialCodeVN_V24,	
								 @MaterialCodeVN_V25,	
								 @MaterialCodeVN_V26,	
								 @MaterialCodeVN_V27,	
								 @MaterialCodeVN_V28,	
								 @MaterialCodeVN_V29,	
								 @MaterialCodeVN_V30,	
								 @MaterialCodeVN_V31,	
								 @MaterialCodeVN_V32,	
								 @MaterialCodeVN_V33,	
								 @MaterialCodeVN_V34,
								 @RouteVE01, 
								 @RouteVE02, 
								 @RouteVE03, 
								 @RouteVE04, 
								 @RouteVE05, 
								 @RouteVE06, 
								 @RouteVE07, 
								 @RouteVE08, 
								 @RouteVE09, 
								 @RouteVE10, 
								 @PriceVE01, 
								 @PriceVE02, 
								 @PriceVE03, 
								 @PriceVE04, 
								 @PriceVE05, 
								 @PriceVE06, 
								 @PriceVE07, 
								 @PriceVE08, 
								 @PriceVE09, 
								 @PriceVE10, 
								 @WorkCenterCode
								 
                IF @@FETCH_STATUS <> 0 BEGIN
					BREAK
				END
			RAISERROR(@IUD_FLAG, 16, 1)
			return;
                IF @IUD_FLAG = 'INSERT' BEGIN

                    IF EXISTS (SELECT 1 FROM STB_VVT_StagePrices WHERE model = @model) BEGIN
						RAISERROR('Duplicate Data : KeyField = %s', 16, 1, @model)
					END
					/*
                    IF @IsAutoKey = 1 BEGIN
						EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_VVT_StagePrices', @model OUTPUT
                    END
					*/

                    INSERT INTO STB_VVT_StagePrices
						(
						model,
						RouteV22,	
						PriceV22,	
						RouteV23,	
						PriceV23,	
						RouteV24,	
						PriceV24,	
						RouteV25,	
						PriceV25,	
						RouteV26,	
						PriceV26,	
						RouteV27,	
						PriceV27,	
						RouteV28,	
						PriceV28,	
						RouteV29,	
						PriceV29,	
						RouteV30,	
						PriceV30,	
						RouteV31,	
						PriceV31,	
						RouteV32,	
						PriceV32,	
						RouteV33,	
						PriceV33,	
						RouteV34,	
						PriceV34,	
						CreateDate,
						MaterialCodeVN_V22,
						MaterialCodeVN_V23,
						MaterialCodeVN_V24,
						MaterialCodeVN_V25,
						MaterialCodeVN_V26,
						MaterialCodeVN_V27,
						MaterialCodeVN_V28,
						MaterialCodeVN_V29,
						MaterialCodeVN_V30,
						MaterialCodeVN_V31,
						MaterialCodeVN_V32,
						MaterialCodeVN_V33,
						MaterialCodeVN_V34,
						RouteVE01,
						RouteVE02,
						RouteVE03,
						RouteVE04,
						RouteVE05,
						RouteVE06,
						RouteVE07,
						RouteVE08,
						RouteVE09,
						RouteVE10,
						PriceVE01,
						PriceVE02,
						PriceVE03,
						PriceVE04,
						PriceVE05,
						PriceVE06,
						PriceVE07,
						PriceVE08,
						PriceVE09,
						PriceVE10,
						WorkCenterCode,
						CreateDateTime,
						CreateUserID
						)
						VALUES
						(
						   @model,	
								 @RouteV22,
								 @PriceV22,
								 @RouteV23,
								 @PriceV23,
								 @RouteV24,
								 @PriceV24,
								 @RouteV25,
								 @PriceV25,
								 @RouteV26,
								 @PriceV26,
								 @RouteV27,
								 @PriceV27,
								 @RouteV28,
								 @PriceV28,
								 @RouteV29,
								 @PriceV29,
								 @RouteV30,
								 @PriceV30,
								 @RouteV31,
								 @PriceV31,
								 @RouteV32,
								 @PriceV32,
								 @RouteV33,
								 @PriceV33,
								 @RouteV34,
								 @PriceV34,
								 @CreateDate,
								 @MaterialCodeVN_V22,	
								 @MaterialCodeVN_V23,	
								 @MaterialCodeVN_V24,	
								 @MaterialCodeVN_V25,	
								 @MaterialCodeVN_V26,	
								 @MaterialCodeVN_V27,	
								 @MaterialCodeVN_V28,	
								 @MaterialCodeVN_V29,	
								 @MaterialCodeVN_V30,	
								 @MaterialCodeVN_V31,	
								 @MaterialCodeVN_V32,	
								 @MaterialCodeVN_V33,	
								 @MaterialCodeVN_V34,
								 @RouteVE01,
								 @RouteVE02,
								 @RouteVE03,
								 @RouteVE04,
								 @RouteVE05,
								 @RouteVE06,
								 @RouteVE07,
								 @RouteVE08,
								 @RouteVE09,
								 @RouteVE10,
								 @PriceVE01,
								 @PriceVE02,
								 @PriceVE03,
								 @PriceVE04,
								 @PriceVE05,
								 @PriceVE06,
								 @PriceVE07,
								 @PriceVE08,
								 @PriceVE09,
								 @PriceVE10,
								 @WorkCenterCode,
								 getdate(),
								 @ProcessUserID
						)

				END ELSE IF @IUD_FLAG = 'UPDATE' BEGIN

                    UPDATE STB_VVT_StagePrices
						SET
						    model =   CASE
						                WHEN @model IS NOT NULL THEN @model
						                ELSE model
						            END,
						    RouteV22 =   CASE
						                WHEN @RouteV22 IS NOT NULL THEN @RouteV22
						                ELSE RouteV22
						            END,
						    PriceV22 =   CASE
						                WHEN @PriceV22 IS NOT NULL THEN @PriceV22
						                ELSE PriceV22
						            END,
						    RouteV23 =   CASE
						                WHEN @RouteV23 IS NOT NULL THEN @RouteV23
						                ELSE RouteV23
						            END,
						    PriceV23 =   CASE
						                WHEN @PriceV23 IS NOT NULL THEN @PriceV23
						                ELSE PriceV23
						            END,
						    RouteV24 =   CASE
						                WHEN @RouteV24 IS NOT NULL THEN @RouteV24
						                ELSE RouteV24
						            END,
						    PriceV24 =   CASE
						                WHEN @PriceV24 IS NOT NULL THEN @PriceV24
						                ELSE PriceV24
						            END,
						    RouteV25 =   CASE
						                WHEN @RouteV25 IS NOT NULL THEN @RouteV25
						                ELSE RouteV25
						            END,
						    PriceV25 =   CASE
						                WHEN @PriceV25 IS NOT NULL THEN @PriceV25
						                ELSE PriceV25
						            END,
						    RouteV26 =   CASE
						                WHEN @RouteV26 IS NOT NULL THEN @RouteV26
						                ELSE RouteV26
						            END,
						    PriceV26 =   CASE
						                WHEN @PriceV26 IS NOT NULL THEN @PriceV26
						                ELSE PriceV26
						            END,
						    RouteV27 =   CASE
						                WHEN @RouteV27 IS NOT NULL THEN @RouteV27
						                ELSE RouteV27
						            END,
						    PriceV27 =   CASE
						                WHEN @PriceV27 IS NOT NULL THEN @PriceV27
						                ELSE PriceV27
						            END,
						    RouteV28 =   CASE
						                WHEN @RouteV28 IS NOT NULL THEN @RouteV28
						                ELSE RouteV28
						            END,
						    PriceV28 =   CASE
						                WHEN @PriceV28 IS NOT NULL THEN @PriceV28
						                ELSE PriceV28
						            END,
						    RouteV29 =   CASE
						                WHEN @RouteV29 IS NOT NULL THEN @RouteV29
						                ELSE RouteV29
						            END,
						    PriceV29 =   CASE
						                WHEN @PriceV29 IS NOT NULL THEN @PriceV29
						                ELSE PriceV29
						            END,
						    RouteV30 =   CASE
						                WHEN @RouteV30 IS NOT NULL THEN @RouteV30
						                ELSE RouteV30
						            END,
						    PriceV30 =   CASE
						                WHEN @PriceV30 IS NOT NULL THEN @PriceV30
						                ELSE PriceV30
						            END,
						    RouteV31 =   CASE
						                WHEN @RouteV31 IS NOT NULL THEN @RouteV31
						                ELSE RouteV31
						            END,
						    PriceV31 =   CASE
						                WHEN @PriceV31 IS NOT NULL THEN @PriceV31
						                ELSE PriceV31
						            END,
						    RouteV32 =   CASE
						                WHEN @RouteV32 IS NOT NULL THEN @RouteV32
						                ELSE RouteV32
						            END,
						    PriceV32 =   CASE
						                WHEN @PriceV32 IS NOT NULL THEN @PriceV32
						                ELSE PriceV32
						            END,
						    RouteV33 =   CASE
						                WHEN @RouteV33 IS NOT NULL THEN @RouteV33
						                ELSE RouteV33
						            END,
						    PriceV33 =   CASE
						                WHEN @PriceV33 IS NOT NULL THEN @PriceV33
						                ELSE PriceV33
						            END,
						    RouteV34 =   CASE
						                WHEN @RouteV34 IS NOT NULL THEN @RouteV34
						                ELSE RouteV34
						            END,
						    PriceV34 =   CASE
						                WHEN @PriceV34 IS NOT NULL THEN @PriceV34
						                ELSE PriceV34
						            END,
						    MaterialCodeVN_V22 =   CASE
						                WHEN @MaterialCodeVN_V22 IS NOT NULL THEN @MaterialCodeVN_V22
						                ELSE MaterialCodeVN_V22
						            END,
						    MaterialCodeVN_V23 =   CASE
						                WHEN @MaterialCodeVN_V23 IS NOT NULL THEN @MaterialCodeVN_V23
						                ELSE MaterialCodeVN_V23
						            END,
						    MaterialCodeVN_V24 =   CASE
						                WHEN @MaterialCodeVN_V24 IS NOT NULL THEN @MaterialCodeVN_V24
						                ELSE MaterialCodeVN_V24
						            END,
						    MaterialCodeVN_V25 =   CASE
						                WHEN @MaterialCodeVN_V25 IS NOT NULL THEN @MaterialCodeVN_V25
						                ELSE MaterialCodeVN_V25
						            END,
						    MaterialCodeVN_V26 =   CASE
						                WHEN @MaterialCodeVN_V26 IS NOT NULL THEN @MaterialCodeVN_V26
						                ELSE MaterialCodeVN_V26
						            END,
						    MaterialCodeVN_V27 =   CASE
						                WHEN @MaterialCodeVN_V27 IS NOT NULL THEN @MaterialCodeVN_V27
						                ELSE MaterialCodeVN_V27
						            END,
						    MaterialCodeVN_V28 =   CASE
						                WHEN @MaterialCodeVN_V28 IS NOT NULL THEN @MaterialCodeVN_V28
						                ELSE MaterialCodeVN_V28
						            END,
						    MaterialCodeVN_V29 =   CASE
						                WHEN @MaterialCodeVN_V29 IS NOT NULL THEN @MaterialCodeVN_V29
						                ELSE MaterialCodeVN_V29
						            END,
						    MaterialCodeVN_V30 =   CASE
						                WHEN @MaterialCodeVN_V30 IS NOT NULL THEN @MaterialCodeVN_V30
						                ELSE MaterialCodeVN_V30
						            END,
						    MaterialCodeVN_V31 =   CASE
						                WHEN @MaterialCodeVN_V31 IS NOT NULL THEN @MaterialCodeVN_V31
						                ELSE MaterialCodeVN_V31
						            END,
						    MaterialCodeVN_V32 =   CASE
						                WHEN @MaterialCodeVN_V32 IS NOT NULL THEN @MaterialCodeVN_V32
						                ELSE MaterialCodeVN_V32
						            END,
						    MaterialCodeVN_V33 =   CASE
						                WHEN @MaterialCodeVN_V33 IS NOT NULL THEN @MaterialCodeVN_V33
						                ELSE MaterialCodeVN_V33
						            END,
						    MaterialCodeVN_V34 =   CASE
						                WHEN @MaterialCodeVN_V34 IS NOT NULL THEN @MaterialCodeVN_V34
						                ELSE MaterialCodeVN_V34
						            END,
						    WorkCenterCode =   CASE
						                WHEN @WorkCenterCode IS NOT NULL THEN @WorkCenterCode
						                ELSE WorkCenterCode
						            END,
							RouteVE01 =   CASE
						                WHEN @RouteVE01 IS NOT NULL THEN @RouteVE01
						                ELSE RouteVE01
										END,
							RouteVE02 =   CASE
						                WHEN @RouteVE02 IS NOT NULL THEN @RouteVE02
						                ELSE RouteVE02
										END,
							RouteVE03 =   CASE
						                WHEN @RouteVE03 IS NOT NULL THEN @RouteVE03
						                ELSE RouteVE03
										END,
							RouteVE04 =   CASE
						                WHEN @RouteVE04 IS NOT NULL THEN @RouteVE04
						                ELSE RouteVE04
										END,
							RouteVE05 =   CASE
						                WHEN @RouteVE05 IS NOT NULL THEN @RouteVE05
						                ELSE RouteVE05
										END,
							RouteVE06 =   CASE
						                WHEN @RouteVE06 IS NOT NULL THEN @RouteVE06
						                ELSE RouteVE06
										END,
							RouteVE07 =   CASE
						                WHEN @RouteVE07 IS NOT NULL THEN @RouteVE07
						                ELSE RouteVE07
										END,
							RouteVE08 =   CASE
						                WHEN @RouteVE08 IS NOT NULL THEN @RouteVE08
						                ELSE RouteVE08
										END,
							RouteVE09 =   CASE
						                WHEN @RouteVE09 IS NOT NULL THEN @RouteVE09
						                ELSE RouteVE09
										END,
							RouteVE10 =   CASE
						                WHEN @RouteVE10 IS NOT NULL THEN @RouteVE10
						                ELSE RouteVE10
										END,
							PriceVE01 =   CASE
						                WHEN @PriceVE01 IS NOT NULL THEN @PriceVE01
						                ELSE PriceVE01
										END,
							PriceVE02 =   CASE
						                WHEN @PriceVE02 IS NOT NULL THEN @PriceVE02
						                ELSE PriceVE02
										END,
							PriceVE03 =   CASE
						                WHEN @PriceVE03 IS NOT NULL THEN @PriceVE03
						                ELSE PriceVE03
										END,
							PriceVE04 =   CASE
						                WHEN @PriceVE04 IS NOT NULL THEN @PriceVE04
						                ELSE PriceVE04
										END,
							PriceVE05 =   CASE
						                WHEN @PriceVE05 IS NOT NULL THEN @PriceVE05
						                ELSE PriceVE05
										END,
							PriceVE06 =   CASE
						                WHEN @PriceVE06 IS NOT NULL THEN @PriceVE06
						                ELSE PriceVE06
										END,
							PriceVE07 =   CASE
						                WHEN @PriceVE07 IS NOT NULL THEN @PriceVE07
						                ELSE PriceVE07
										END,
							PriceVE08 =   CASE
						                WHEN @PriceVE08 IS NOT NULL THEN @PriceVE08
						                ELSE PriceVE08
										END,
							PriceVE09 =   CASE
						                WHEN @PriceVE09 IS NOT NULL THEN @PriceVE09
						                ELSE PriceVE09
										END,
						  PriceVE10 =   CASE
						                WHEN @PriceVE10 IS NOT NULL THEN @PriceVE10
						                ELSE PriceVE10
										END,
							ChangeDateTime = getdate(),
							ChangeUserID=@ProcessUserID
						WHERE
						    model = @model
                END ELSE IF @IUD_FLAG = 'DELETE' BEGIN
                    DELETE FROM STB_VVT_StagePrices
					WHERE
						   model = @model
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
