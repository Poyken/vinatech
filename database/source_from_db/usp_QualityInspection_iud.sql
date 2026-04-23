-- =============================================
-- Author:	    Anonymous()
-- Create date: 2021-04-06
-- Browsable : true
-- Group : 품질관리
-- Description:	
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_QualityInspection_iud]
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
  DECLARE @No INT
  DECLARE @category nvarchar(200)
  DECLARE @Size nvarchar(50)
  DECLARE @FARAT nvarchar(200)
  DECLARE @HQ bit
  DECLARE @WEC_VEC nvarchar(50)
  DECLARE @Customer nvarchar(100)
  DECLARE @PROD_ESR nvarchar(10)
  DECLARE @PROD_SD nvarchar(10)
  DECLARE @PROD_CAPA nvarchar(10)
  DECLARE @PROD_AGING nvarchar(10)
  DECLARE @QC_ESR nvarchar(10)
  DECLARE @QC_SD nvarchar(10)
  DECLARE @QC_CAPA nvarchar(10)
  DECLARE @QC_ETC nvarchar(10)
  DECLARE @OQC_ExternalAppearance nvarchar(200)
  DECLARE @TQC_ESR nvarchar(200)
  DECLARE @TQC_SD nvarchar(200)
  DECLARE @TQC_CAP nvarchar(200)
  DECLARE @TQC_ExternalAppearance nvarchar(200)
  DECLARE @REMARK nvarchar(200)
  DECLARE @Attribute1 varchar(200)
  DECLARE @Attribute2 varchar(200)
  DECLARE @Attribute3 varchar(200)
  DECLARE @Attribute4 varchar(200)
  DECLARE @Attribute5 varchar(200)
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
								XMLData.No,
								XMLData.Category,
								XMLData.Size,
								XMLData.FARAT,
								XMLData.HQ,
								XMLData.WEC_VEC,
								XMLData.Customer,
								XMLData.PROD_ESR,
								XMLData.PROD_SD,
								XMLData.PROD_CAPA,
								XMLData.PROD_AGING,
								XMLData.QC_ESR,
								XMLData.QC_SD,
								XMLData.QC_CAPA,
								XMLData.QC_ETC,
								XMLData.OQC_ExternalAppearance,
								XMLData.TQC_ESR,
								XMLData.TQC_SD,
								XMLData.TQC_CAP,
								XMLData.TQC_ExternalAppearance,
								XMLData.Remark,
								XMLData.Attribute1,
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
										NO int,
										Category nvarchar(200),
										Size nvarchar(50),
										FARAT nvarchar(200),
										HQ bit,
										WEC_VEC nvarchar(50),
										Customer nvarchar(100),
										PROD_ESR nvarchar(10),
										PROD_SD nvarchar(10),
										PROD_CAPA nvarchar(10),
										PROD_AGING nvarchar(10),
										QC_ESR nvarchar(10),
										QC_SD nvarchar(10),
										QC_CAPA nvarchar(10),
										QC_ETC nvarchar(10),
										OQC_ExternalAppearance nvarchar(200),
										TQC_ESR nvarchar(200),
										TQC_SD nvarchar(200),
										TQC_CAP nvarchar(200),
										TQC_ExternalAppearance nvarchar(200),
										REMARK nvarchar(200),
										Attribute1 nvarchar(200),
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
								XMLData.No,
								XMLData.Category,
								XMLData.Size,
								XMLData.FARAT,
								XMLData.HQ,
								XMLData.WEC_VEC,
								XMLData.Customer,
								XMLData.PROD_ESR,
								XMLData.PROD_SD,
								XMLData.PROD_CAPA,
								XMLData.PROD_AGING,
								XMLData.QC_ESR,
								XMLData.QC_SD,
								XMLData.QC_CAPA,
								XMLData.QC_ETC,
								XMLData.OQC_ExternalAppearance,
								XMLData.TQC_ESR,
								XMLData.TQC_SD,
								XMLData.TQC_CAP,
								XMLData.TQC_ExternalAppearance,
								XMLData.REMARK,
								XMLData.Attribute1,
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
											No int,
											Category nvarchar(200),
											Size nvarchar(50),
											FARAT nvarchar(200),
										    HQ bit,
											WEC_VEC nvarchar(50),
											Customer nvarchar(100),
											PROD_ESR nvarchar(10),
											PROD_SD nvarchar(10),
											PROD_CAPA nvarchar(10),
											PROD_AGING nvarchar(10),
											QC_ESR nvarchar(10),
											QC_SD nvarchar(10),
											QC_CAPA nvarchar(10),
											QC_ETC nvarchar(10),
											OQC_ExternalAppearance nvarchar(200),
										    TQC_ESR nvarchar(200),
											TQC_SD nvarchar(200),
											TQC_CAP nvarchar(200),
											TQC_ExternalAppearance nvarchar(200),
											REMARK nvarchar(200),
											Attribute1 nvarchar(200),
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
								XMLData.No,
								XMLData.Category,
								XMLData.Size,
								XMLData.FARAT,
								XMLData.HQ,
								XMLData.WEC_VEC,
								XMLData.Customer,
								XMLData.PROD_ESR,
								XMLData.PROD_SD,
								XMLData.PROD_CAPA,
								XMLData.PROD_AGING,
								XMLData.QC_ESR,
								XMLData.QC_SD,
								XMLData.QC_CAPA,
								XMLData.QC_ETC,
								XMLData.OQC_ExternalAppearance,
								XMLData.TQC_ESR,
								XMLData.TQC_SD,
								XMLData.TQC_CAP,
								XMLData.TQC_ExternalAppearance,
								XMLData.REMARK,
								XMLData.Attribute1,
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
											No int,
											Category nvarchar(200),
											Size nvarchar(50),
											FARAT nvarchar(200),
										    HQ bit,
											WEC_VEC nvarchar(50),
											Customer nvarchar(100),
											PROD_ESR nvarchar(10),
											PROD_SD nvarchar(10),
											PROD_CAPA nvarchar(10),
											PROD_AGING nvarchar(10),
											QC_ESR nvarchar(10),
											QC_SD nvarchar(10),
											QC_CAPA nvarchar(10),
											QC_ETC nvarchar(10),
											OQC_ExternalAppearance nvarchar(200),
										    TQC_ESR nvarchar(200),
											TQC_SD nvarchar(200),
											TQC_CAP nvarchar(200),
											TQC_ExternalAppearance nvarchar(200),
											REMARK nvarchar(200),
											Attribute1 nvarchar(200),
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
								@No,
								@Category,
								@Size,
								@FARAT,
								@HQ,
								@WEC_VEC,
								@Customer,
								@PROD_ESR,
								@PROD_SD,
								@PROD_CAPA,
								@PROD_AGING,
								@QC_ESR,
								@QC_SD,
								@QC_CAPA,
								@QC_ETC,
								@OQC_ExternalAppearance,
								@TQC_ESR,
								@TQC_SD,
								@TQC_CAP,
								@TQC_ExternalAppearance,
								@REMARK,
								@Attribute1,
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
				Declare @MaxNo INT
				       ,@NextNo INT

				SELECT @MaxNo = ISNULL(MAX(No), 0)
				  FROM stb_QualityInspection
				-- WHERE Date_Meeting = @Date_Meeting

				SET @NextNo = @MaxNo + 1

				PRINT @NextNo

                INSERT INTO stb_QualityInspection
					(
						No,
						Category,
						Size,
						FARAT,
						HQ,
						WEC_VEC,
						Customer,
						PROD_ESR,
						PROD_SD,
						PROD_CAPA,
						PROD_AGING,
						QC_ESR,
						QC_SD,
						QC_CAPA,
						QC_ETC,
						OQC_ExternalAppearance,
						TQC_ESR,
						TQC_SD,
						TQC_CAP,
						TQC_ExternalAppearance,
						REMARK,
						Attribute1,
						Attribute2,
						Attribute3,
						CreateDateTime,
						CreateUserID,
						ChangeDateTime,
						ChangeUserID
					)
					VALUES
					(
						@NextNo,
						@Category,
						@Size,
						@FARAT,
						@HQ,
						@WEC_VEC,
						@Customer,
						@PROD_ESR,
						@PROD_SD,
						@PROD_CAPA,
						@PROD_AGING,
						@QC_ESR,
						@QC_SD,
						@QC_CAPA,
						@QC_ETC,
						@OQC_ExternalAppearance,
						@TQC_ESR,
						@TQC_SD,
						@TQC_CAP,
						@TQC_ExternalAppearance,
						@REMARK,
						@Attribute1,
						@Attribute2,
						@Attribute3,
						GETDATE(),
						@pProcessUserID,
						@ChangeDateTime,
						@ChangeUserID
					)

			END ELSE IF @IUD_FLAG = 'UPDATE' BEGIN
                UPDATE stb_QualityInspection
					SET
						No =   CASE
						            WHEN @No IS NOT NULL THEN @No
						            ELSE No
						        END,
						Category = Case
									WHEN @category IS NOT NULL THEN @category
						            ELSE Category
						        END,
						Size =   CASE
						            WHEN @Size IS NOT NULL THEN @Size
						            ELSE Size
						        END,
						FARAT = CASE
						            WHEN @FARAT IS NOT NULL THEN @FARAT
						            ELSE FARAT
						        END,
						HQ = CASE
						            WHEN @HQ IS NOT NULL THEN @HQ
						            ELSE HQ
						        END,
						WEC_VEC =   CASE
						            WHEN @WEC_VEC IS NOT NULL THEN @WEC_VEC
						            ELSE WEC_VEC
						        END,
						Customer =   CASE
						            WHEN @Customer IS NOT NULL THEN @Customer
						            ELSE Customer
						        END,
						PROD_ESR =   CASE
						            WHEN @PROD_ESR IS NOT NULL THEN @PROD_ESR
						            ELSE PROD_ESR
						        END,
					    PROD_SD =   CASE
						            WHEN @PROD_SD IS NOT NULL THEN @PROD_SD
						            ELSE PROD_SD
						        END,
						PROD_CAPA =   CASE
						            WHEN @PROD_CAPA IS NOT NULL THEN @PROD_CAPA
						            ELSE PROD_CAPA
						        END,
						PROD_AGING =   CASE
						            WHEN @PROD_AGING IS NOT NULL THEN @PROD_AGING
						            ELSE PROD_AGING
						        END,
						QC_ESR =   CASE
						            WHEN @QC_ESR IS NOT NULL THEN @QC_ESR
						            ELSE QC_ESR
						        END,
					    QC_SD =   CASE
						            WHEN @QC_SD IS NOT NULL THEN @QC_SD
						            ELSE QC_SD
						        END,
						QC_CAPA =   CASE
						            WHEN @QC_CAPA IS NOT NULL THEN @QC_CAPA
						            ELSE QC_CAPA
						        END,
						QC_ETC =   CASE
						            WHEN @QC_ETC IS NOT NULL THEN @QC_ETC
						            ELSE QC_ETC
						        END,
						OQC_ExternalAppearance=   CASE
						            WHEN @OQC_ExternalAppearance IS NOT NULL THEN @OQC_ExternalAppearance
						            ELSE OQC_ExternalAppearance
						        END,
						TQC_ESR =   CASE
						            WHEN @TQC_ESR IS NOT NULL THEN @TQC_ESR
						            ELSE TQC_ESR
						        END,
						TQC_SD = CASE
						            WHEN @TQC_SD IS NOT NULL THEN @TQC_SD
						            ELSE TQC_SD
						        END,
						TQC_CAP = CASE
						            WHEN @TQC_CAP IS NOT NULL THEN @TQC_CAP
						            ELSE TQC_CAP
						        END,
						TQC_ExternalAppearance = CASE
						            WHEN @TQC_ExternalAppearance IS NOT NULL THEN @TQC_ExternalAppearance
						            ELSE TQC_ExternalAppearance
						        END,
						REMARK =   CASE
						            WHEN @REMARK IS NOT NULL THEN @REMARK
						            ELSE REMARK
						        END,
						Attribute1 =   CASE
						            WHEN @Attribute1 IS NOT NULL THEN @Attribute1
						            ELSE Attribute1
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
                DELETE FROM stb_QualityInspection
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