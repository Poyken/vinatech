CREATE PROC usp_VN_Module_CREATE
@pProcessUserID VARCHAR(20),
@pProcessLanguage VARCHAR(20),
@pProcessViewName VARCHAR(50),
@pLotNoOld NVARCHAR(50) ='ABCD000',
@pQty INT = 3000,
@pXml NVARCHAR(MAX) = NULL
AS
BEGIN
			SET NOCOUNT ON;

    DECLARE @ProcessUserID VARCHAR(30) = @pProcessUserID
	DECLARE @ProcessLanguage VARCHAR(20) = @pProcessLanguage
    DECLARE @ProcessViewName VARCHAR(50) = @pProcessViewName
    DECLARE @TableName VARCHAR(100) = '/DataSet/' + @ProcessViewName

	DECLARE @LOTNOINCLUDE NVARCHAR(50) = @pLotNoOld
	DECLARE @QTY INT = @pQty
	DECLARE @TOPNEW NVARCHAR(50)
	DECLARE @ERROR_MSG NVARCHAR(MAX)
	DECLARE @iDoc INT

	EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml

		    
	BEGIN TRY

		DECLARE SourceData CURSOR FOR
            SELECT
						LOTNOINCLUDE,
						QTY
						
			FROM
					OPENXML(@idoc , @TableName , 2)
					WITH (
								LOTNOINCLUDE NVARCHAR(50),
								QTY INT
						 )

        OPEN SourceData
        WHILE 1 = 1 BEGIN
            FETCH NEXT FROM SourceData INTO
								@LOTNOINCLUDE,
								@QTY

            IF @@FETCH_STATUS <> 0 BEGIN 
				BREAK 
			END 
			
		IF  @LOTNOINCLUDE IS NOT NULL
			BEGIN

				IF(@QTY IS NOT NULL) BEGIN


						 DECLARE SourceData1 CURSOR FOR
						
						SELECT
								LOTNOINCLUDE,
								QTY
						FROM 
								STB_VN_MODULES  with(nolock)  
							
						WHERE 
								LOTNOINCLUDE = @LOTNOINCLUDE

							SELECT TOP(1) @TOPNEW =LOTNOINCLUDE FROM  STB_VN_MODULES WITH(NOLOCK) ORDER BY CreateDateTime DESC

						 OPEN SourceData1
							WHILE 1 = 1 BEGIN
								FETCH NEXT FROM SourceData1 INTO
												 @LOTNOINCLUDE, 
												 @QTY			
											
						            IF @@FETCH_STATUS <> 0 BEGIN
									BREAK
									END
									
									INSERT INTO STB_VN_MODULES (LOTNOINCLUDE,QTY,LOTNOMAIN,CreateDateTime) VALUES (@LOTNOINCLUDE,@QTY,@TOPNEW,GETDATE())
							
							END

						CLOSE SourceData1; 
						DEALLOCATE SourceData1; 

					END
				ELSE
					BEGIN

						DECLARE SourceData2 CURSOR FOR

						SELECT 
								LOTNOINCLUDE, 
								QTY
						FROM  
								STB_VN_MODULES  WITH(NOLOCK) 
						
						WHERE
								LOTNOINCLUDE =@LOTNOINCLUDE 

						SELECT TOP(1) @TOPNEW =LOTNOINCLUDE FROM  STB_VN_MODULES WITH(NOLOCK) ORDER BY CreateDateTime DESC

						OPEN SourceData2
							WHILE 1 = 1 BEGIN
								FETCH NEXT FROM SourceData2 INTO
												 @LOTNOINCLUDE, 
												 @QTY
												

						            IF @@FETCH_STATUS <> 0 BEGIN
									BREAK
									END

								INSERT INTO STB_VN_MODULES (LOTNOINCLUDE,QTY,LOTNOMAIN,CreateDateTime) VALUES (@LOTNOINCLUDE,@QTY,@TOPNEW,GETDATE())
							
							END

						CLOSE SourceData2; 
						DEALLOCATE SourceData2; 

					END
			END
		
		END			
    END TRY

	BEGIN CATCH

		SET @ERROR_MSG = ERROR_MESSAGE() 
		RAISERROR( @ERROR_MSG ,16, 1) 
	END CATCH
			
	CLOSE SourceData; 
	DEALLOCATE SourceData; 	EXEC sp_xml_removedocument @idoc 
END