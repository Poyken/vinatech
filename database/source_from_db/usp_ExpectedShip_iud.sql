-- =============================================
-- Author:	    Anonymous()
-- Create date: 2016-02-15
-- Browsable : true
-- Group : 품질관리
-- Description:	
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_ExpectedShip_iud]
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
    DECLARE @MaxKeyField VARCHAR(20)

    -- Declare Columns Variable
  DECLARE @OldID INT
  DECLARE @ID INT
  DECLARE @Size nvarchar(50)
  DECLARE @Quality Nvarchar(20)
  DECLARE @Customer nvarchar(100)
  DECLARE @ShippingDate date
  DECLARE @ProdSchedule date
  DECLARE @QC_SD nvarchar(20)
  DECLARE @QC_ESR nvarchar(20)
  DECLARE @QC_CAPA nvarchar(20)
  DECLARE @QC_ETC nvarchar(20)
  DECLARE @Status nvarchar(20)
  DECLARE @Date_Meeting date
  DECLARE @Atribute1 varchar(200)
  DECLARE @Attribute2 varchar(200)
  DECLARE @Attribute3 varchar(200)
  DECLARE @CreateDateTime DATETIME
  DECLARE @CreateUserID VARCHAR(20)
  DECLARE @ChangeDateTime DATETIME
  DECLARE @ChangeUserID VARCHAR(20)


	DECLARE @iDoc INT

    EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
    BEGIN TRY
		DECLARE SourceData CURSOR FOR
            SELECT
                    'INSERT' AS IUD_FLAG,
								XMLData.OldID,
								XMLData.ID,
								XMLData.Size,
								XMLData.Quality,
								XMLData.Customer,
								XMLData.ShippingDate,
								XMLData.ProdSchedule,
								XMLData.QC_SD,
								XMLData.QC_ESR,
								XMLData.QC_CAPA,
								XMLData.QC_ETC,
								XMLData.Status,
								XMLData.Atribute1,
								XMLData.Attribute2,
								XMLData.Attribute3,
								XMLData.CreateDateTime,
								XMLData.CreateUserID,
								XMLData.ChangeDateTime,
								XMLData.ChangeUserID
						FROM
								OPENXML(@idoc , @InsertTableName , 2)
							    WITH  (
										OldID int,
										ID int,
										Size nvarchar(50),
										Quality nvarchar(20),
										Customer nvarchar(100),
										ShippingDate date,
										ProdSchedule date,
										QC_SD nvarchar(20),
										QC_ESR nvarchar(20),
										QC_CAPA nvarchar(20),
										QC_ETC nvarchar(20),
										Status nvarchar(20),
										Atribute1 nvarchar(200),
										Attribute2 nvarchar(200),
										Attribute3 nvarchar(200),
										CreateDateTime DATETIME,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIME,
										ChangeUserID VARCHAR(20)
										) XMLData
						UNION ALL
						SELECT
								'UPDATE' AS IUD_FLAG,
								CASE 
									WHEN XMLData.OldID IS NULL THEN XMLData.ID
									ELSE XMLData.OldID
								END AS OldID,
								XMLData.ID,
								XMLData.Size,
								XMLData.Quality,
								XMLData.Customer,
								XMLData.ShippingDate,
								XMLData.ProdSchedule,
								XMLData.QC_SD,
								XMLData.QC_ESR,
								XMLData.QC_CAPA,
								XMLData.QC_ETC,
								XMLData.Status,
								XMLData.Atribute1,
								XMLData.Attribute2,
								XMLData.Attribute3,
								XMLData.CreateDateTime,
								XMLData.CreateUserID,
								XMLData.ChangeDateTime,
								XMLData.ChangeUserID
						FROM
								OPENXML(@idoc , @UpdateTableName , 2)
							    WITH  (
											OldID int,
											ID int,
											Size nvarchar(50),
											Quality nvarchar(20),
											Customer nvarchar(100),
											ShippingDate date,
											ProdSchedule date,
											QC_SD nvarchar(20),
											QC_ESR nvarchar(20),
											QC_CAPA nvarchar(20),
											QC_ETC nvarchar(20),
											Status nvarchar(20),
											Atribute1 nvarchar(200),
											Attribute2 nvarchar(200),
											Attribute3 nvarchar(200),
											CreateDateTime DATETIME,
											CreateUserID VARCHAR(20),
											ChangeDateTime DATETIME,
											ChangeUserID VARCHAR(20)
										) XMLData
						UNION ALL
						SELECT
								'DELETE' AS IUD_FLAG,
								CASE 
									WHEN XMLData.OldID IS NULL THEN XMLData.ID
									ELSE XMLData.OldID
								END AS OldID,
							    XMLData.ID,
								XMLData.Size,
								XMLData.Quality,
								XMLData.Customer,
								XMLData.ShippingDate,
								XMLData.ProdSchedule,
								XMLData.QC_SD,
								XMLData.QC_ESR,
								XMLData.QC_CAPA,
								XMLData.QC_ETC,
								XMLData.Status,
								XMLData.Atribute1,
								XMLData.Attribute2,
								XMLData.Attribute3,
								XMLData.CreateDateTime,
								XMLData.CreateUserID,
								XMLData.ChangeDateTime,
								XMLData.ChangeUserID
						FROM
								OPENXML(@idoc , @DeleteTableName , 2)
							    WITH  (
										OldID int,
											ID int,
											Size nvarchar(50),
											Quality nvarchar(20),
											Customer nvarchar(100),
											ShippingDate date,
											ProdSchedule date,
											QC_SD nvarchar(20),
											QC_ESR nvarchar(20),
											QC_CAPA nvarchar(20),
											QC_ETC nvarchar(20),
											Status nvarchar(20),
											Atribute1 nvarchar(200),
											Attribute2 nvarchar(200),
											Attribute3 nvarchar(200),
											CreateDateTime DATETIME,
											CreateUserID VARCHAR(20),
											ChangeDateTime DATETIME,
											ChangeUserID VARCHAR(20)
										) XMLData


        OPEN SourceData

        WHILE 1 = 1 BEGIN
            FETCH NEXT FROM SourceData INTO
								@IUD_FLAG,
								@OldID,
								@ID,
								@Size,
								@Quality,
								@Customer,
								@ShippingDate,
								@ProdSchedule,
								@QC_SD,
								@QC_ESR,
								@QC_CAPA,
								@QC_ETC,
								@Status,
								@Atribute1,
								@Attribute2,
								@Attribute3,
								@CreateDateTime,
								@CreateUserID,
								@ChangeDateTime,
								@ChangeUserID


            IF @@FETCH_STATUS <> 0 BEGIN
				BREAK
			END
            IF @IUD_FLAG = 'INSERT' BEGIN
				PRINT 'INSERT'
				-- Get Max No and Create Next No
				--Declare @MaxNo INT
				--       ,@NextNo INT

				--SELECT @MaxNo = ISNULL(MAX(No), 0)
				--  FROM stb_ExpectedShip
				-- WHERE Date_Meeting = @Date_Meeting

				--SET @NextNo = @MaxNo + 1

				--PRINT @NextNo

                INSERT INTO stb_ExpectedShip
					(
						Size,
						Quality,
						Customer,
						ShippingDate,
						ProdSchedule,
						QC_SD,
						QC_ESR,
						QC_CAPA,
						QC_ETC,
						Status,
						Atribute1,
						Attribute2,
						Attribute3,
						CreateDateTime,
						CreateUserID,
						ChangeDateTime,
						ChangeUserID
					)
					VALUES
					(
						@Size,
						@Quality,
						@Customer,
						@ShippingDate,
						@ProdSchedule,
						@QC_SD,
						@QC_ESR,
						@QC_CAPA,
					    @QC_ETC,
						@Status,
						@Atribute1,
						@Attribute2,
						@Attribute3,
						GETDATE(),
						@pProcessUserID,
						@ChangeDateTime,
						@ChangeUserID
					)

			END ELSE IF @IUD_FLAG = 'UPDATE' BEGIN
                UPDATE stb_ExpectedShip
					SET
						Size =   CASE
						            WHEN @Size IS NOT NULL THEN @Size
						            ELSE Size
						        END,
						Quality =   CASE
						            WHEN @Quality IS NOT NULL THEN @Quality
						            ELSE Quality
						        END,
						Customer =   CASE
						            WHEN @Customer IS NOT NULL THEN @Customer
						            ELSE Customer
						        END,
						ShippingDate =   CASE
						            WHEN @ShippingDate IS NOT NULL THEN @ShippingDate
						            ELSE ShippingDate
						        END,
						ProdSchedule =   CASE
						            WHEN @ProdSchedule IS NOT NULL THEN @ProdSchedule
						            ELSE ProdSchedule
						        END,
						QC_SD = CASE	
										WHEN @QC_SD IS NOT NULL THEN @QC_SD
										ELSE QC_SD
								END,
						QC_ESR = CASE	
										WHEN @QC_ESR IS NOT NULL THEN @QC_ESR
										ELSE QC_ESR
								END,
						QC_CAPA = CASE	
										WHEN @QC_CAPA IS NOT NULL THEN @QC_CAPA
										ELSE QC_CAPA
								END,
						QC_ETC = CASE	
										WHEN @QC_ETC IS NOT NULL THEN @QC_ETC
										ELSE QC_ETC
								END,
						Status = CASE	
										WHEN @Status IS NOT NULL THEN @Status
										ELSE Status
								END,
						Atribute1 =   CASE
						            WHEN @Atribute1 IS NOT NULL THEN @Atribute1
						            ELSE Atribute1
						        END,
						Attribute2 =   CASE
						            WHEN @Attribute2 IS NOT NULL THEN @Attribute2
						            ELSE Attribute2
						        END,
						Attribute3 =   CASE
						            WHEN @Attribute3 IS NOT NULL THEN @Attribute3
						            ELSE Attribute3
						        END,
						CreateDateTime =   CASE
						            WHEN @CreateDateTime IS NOT NULL THEN @CreateDateTime
						            ELSE CreateDateTime
						        END,
						CreateUserID =   CASE
						            WHEN @CreateUserID IS NOT NULL THEN @CreateUserID
						            ELSE CreateUserID
						        END,
						ChangeDateTime = GETDATE(),
						ChangeUserID = @pProcessUserID
					WHERE
						ID = @OldID
            END ELSE IF @IUD_FLAG = 'DELETE' BEGIN
                DELETE FROM stb_ExpectedShip
					WHERE
						ID = @ID
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

select * from stb_ExpectedShip