
-- =============================================
-- Author: Mr.Tung
-- Create date: 2021-06-07
-- Browsable : true
-- =============================================
CREATE PROCEDURE [dbo].[usp_Vietnam_saveDate_QcDefect_iud]
						--@pDefectReportNo VARCHAR(20),
						--@pProduction_Date datetime=NULL,
						--@pExporting_Date datetime=NULL
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
    --DECLARE @InsertTableName VARCHAR(100) = '/DataSet/' + @ProcessViewName + '_INSERT'
    DECLARE @UpdateTableName VARCHAR(100) = '/DataSet/' + @ProcessViewName + '_UPDATE'
    --DECLARE @DeleteTableName VARCHAR(100) = '/DataSet/' + @ProcessViewName + '_DELETE'
    DECLARE @ERROR_MSG NVARCHAR(MAX)

	DECLARE @IUD_FLAG VARCHAR(20)
	DECLARE @DefectReportNo VARCHAR(20)
	DECLARE @Production_Date datetime
	DECLARE @Exporting_Date datetime
	Declare @QcStrategy varchar(100)
	  DECLARE @iDoc INT
	  declare @count INT = 0

	  --SELECT @ERROR_MSG = SUBSTRING(@pXml,8000,9000)
	  --RAISERROR(@ERROR_MSG,16,1);
	  --RETURN

	   EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
        BEGIN TRY
		    DECLARE SourceData CURSOR FOR
				SELECT
									'UPDATE' AS IUD_FLAG,
									DefectReportNo,								
									Production_Date, --EmpNameVendor, 
									Exporting_Date  --NameVendor        
									,QcStrategy      --NameEmp
							FROM
									OPENXML(@idoc , @UpdateTableName , 2)
							        WITH  (
									
											 DefectReportNo VARCHAR(20),											 
											 Production_Date datetime,
											 Exporting_Date datetime,
											 QcStrategy varchar(100)
											)

			OPEN SourceData
            WHILE 1 = 1 BEGIN
                FETCH NEXT FROM SourceData INTO
								 @IUD_FLAG,								 
								 @DefectReportNo,								 
								 @Production_Date,
								 @Exporting_Date ,
								 @QcStrategy


                IF @@FETCH_STATUS <> 0 BEGIN
					
					--select @ERROR_MSG = @DefectReportNo +'--'+
					--		convert(varchar(19),@Production_Date,120)+'--' + 
					--		convert(varchar(19),@Exporting_Date)
					--RAISERROR(@DefectReportNo,16,1);
					break
					--RETURN
				END

				--select @count=@count+1

				IF(@IUD_FLAG='UPDATE' and @DefectReportNo is not null and @DefectReportNo<>'') BEGIN
					update STB_QcDefectReport
					set EmpNameVendor = convert(varchar(19),@Production_Date,120),
						NameVendor = convert(varchar(19),@Exporting_Date),
						NameEmp = @QcStrategy
					where DefectReportNo=@DefectReportNo
				END
		end


 END TRY
		BEGIN CATCH
			SET @ERROR_MSG = ERROR_MESSAGE()
			RAISERROR( @ERROR_MSG ,16, 1)
		END CATCH
			
		CLOSE SourceData;
		DEALLOCATE SourceData;
			
		EXEC sp_xml_removedocument @idoc	
    
END
