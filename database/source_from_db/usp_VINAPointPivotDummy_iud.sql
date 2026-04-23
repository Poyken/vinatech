
-- =============================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Create date: 2020-03-23
-- Browsable : true
-- Group : 인사관리
-- Description:	
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_VINAPointPivotDummy_iud]
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
    DECLARE @InsertTableName VARCHAR(100) = '/DataSet/' + @ProcessViewName
    DECLARE @ERROR_MSG NVARCHAR(MAX)
    DECLARE @IUD_FLAG VARCHAR(10)
    DECLARE @IsAutoKey BIT
    DECLARE @IsLoopIUD BIT
    DECLARE @PrefixString VARCHAR(20)
    DECLARE @SerialLen INT

    -- Declare Columns Variable
  DECLARE @OldWorkerCode VARCHAR(20)
  DECLARE @WorkerCode VARCHAR(20)
  DECLARE @WorkerName VARCHAR(20)
  DECLARE @EventCode VARCHAR(20)
  DECLARE @EventName VARCHAR(100)
  DECLARE @totPoint NUMERIC(5,1)


	DECLARE @iDoc INT
   
	EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
	
	SELECT  WorkerCode
	FROM
			OPENXML(@idoc , @InsertTableName , 2)
			WITH  (
						OldWorkerCode VARCHAR(20),
						WorkerCode VARCHAR(20),
						WorkerName VARCHAR(20),
						EventCode VARCHAR(20),
						EventName VARCHAR(100),
						totPoint NUMERIC(5,1)
					) 
			
	EXEC sp_xml_removedocument @idoc	
END
