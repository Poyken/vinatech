-- Procedure: usp_BoxCheckSetupValueTwo
-- =============================================
-- Author: Kangs(kilee@vina.co.kr)
-- Create date: 2020-10-25
-- Browsable : true
-- Group : 박스포장
-- Description:	
-- Modified:
-- =============================================

------------------------------------------
-- Modified: Kevin
-- Group: EA Vietnam team
-- Purpose: Get actual amount on the stamp of Vietnam box
-- Modified date: 2020-11-20
------------------------------------------
   
CREATE PROCEDURE [dbo].[usp_BoxCheckSetupValueTwo]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pProcessViewName VARCHAR(50),
	--@pVinylBagQty INT,
	--@pInnerBoxQty INT,
	--@pOutBoxQty INT,
	--@pInputValue INT,
	@pXml NVARCHAR(MAX) = NULL
AS
BEGIN

	SET NOCOUNT ON;

    DECLARE @ProcessUserID VARCHAR(30) = @pProcessUserID
	DECLARE @ProcessLanguage VARCHAR(20) = @pProcessLanguage
    DECLARE @ProcessViewName VARCHAR(50) = @pProcessViewName
    DECLARE @TableName VARCHAR(100) = '/DataSet/' + @ProcessViewName

	DECLARE @ERROR_MSG NVARCHAR(MAX)
	DECLARE @iDoc INT

	DECLARE @PackID VARCHAR(30)
	DECLARE @LotQty NUMERIC
	--DECLARE @LotQty VarChar(20)
	--DECLARE @LotQtyTwo VARCHAR(20)

	DECLARE @LabelQty NUMERIC
	--DECLARE @LabelQty VarChar(20)

	DECLARE	@PackingID VARCHAR(30)  
	DECLARE @PackQty   NUMERIC(18, 0) 
	DECLARE @PCID INT
	declare @LotNo			varchar(30)  
	declare @MaterialCode	varchar(30) 
	declare @MaterialName	varchar(30) 
	declare @PrintTime		datetime 
	declare @EmpNo			varchar(30)  
	declare @isPrinted		bit
	declare @isModule		bit	
	declare @partNo			varchar(30) 

	EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml

		    
	BEGIN TRY

		DECLARE SourceData CURSOR FOR
            SELECT
						PackingID,
						--LotQtyTwo,
						LotQty,
						LotNo,
						LabelQty
						
			FROM
					OPENXML(@idoc , @TableName , 2)
					WITH (
								PackingID VARCHAR(30),
								LotQty NUMERIC,
								--LotQty VarChar(20),
								LotQtyTwo VarChar(20),
								LotNo VARCHAR(30) ,

								LabelQty NUMERIC
								--LabelQty VarChar(20)
								
						 )

        OPEN SourceData
        WHILE 1 = 1 BEGIN
            FETCH NEXT FROM SourceData INTO
								@PackID,
								@LotQty,
								--@LotQtyTwo,
								@LotNo,
								@LabelQty
							


            IF @@FETCH_STATUS <> 0 BEGIN 
				BREAK 
			END 
			
	
			if  @PackID is not null   and   @PackID <> '' 
			begin

				--if(@LotQtyTwo='') 
				if(@LabelQty=0)
				begin


						 DECLARE SourceData1 CURSOR FOR
						select PackingID, LotNo, a.MaterialCode, b.materialname
						,'Q' + @LotQty
						,getdate(),@ProcessUserID,0 as isPrinted,0 as isModule,
						 (RTRIM(LTRIM(SUBSTRING(b.materialname, CHARINDEX(' ', b.materialname), 12))) + CASE WHEN CHARINDEX('-L', b.materialname) > 0 THEN '-L' ELSE '' END) AS PartNo
						
						from 
							STB_MaterialLotInfo a with(nolock) join 
							STB_MaterialMaster  b with(nolock)  on a.MaterialCode=b.MaterialCode 
						where LotNo = @LotNo


						 OPEN SourceData1
							WHILE 1 = 1 BEGIN
								FETCH NEXT FROM SourceData1 INTO
												 @PackingID		, 
												 @LotNo			,
												 @MaterialCode	,
												 @MaterialName	, 
												 @PackQty		,
												 @PrintTime		,
												 @EmpNo			,
												 @isPrinted		,
												 @isModule		,
												 @partNo		

						            IF @@FETCH_STATUS <> 0 BEGIN
									BREAK
									END
									
								--UPDATE [SmartFactoryIncubator].[dbo].[RCV_ASN]
								--SET
									--ITM_QTY = @PackQty

								--WHERE
										--PACK_ID = @PackingID
							END

						CLOSE SourceData1; 
						DEALLOCATE SourceData1; 

					end
				else
					begin

						DECLARE SourceData2 CURSOR FOR
						select PackingID, LotNo, a.MaterialCode, b.materialname
						,'Q' + @LotQty
						,getdate(),@ProcessUserID,1 as isPrinted,0 as isModule,
						(RTRIM(LTRIM(SUBSTRING(b.materialname, CHARINDEX(' ', b.materialname), 12))) + CASE WHEN CHARINDEX('-L', b.materialname) > 0 THEN '-L' ELSE '' END) AS PartNo

						from 
							STB_MaterialLotInfo a  with(nolock) join 
							STB_MaterialMaster  b  with(nolock) on a.MaterialCode=b.MaterialCode 
						where PackingID=@PackID 


						OPEN SourceData2
							WHILE 1 = 1 BEGIN
								FETCH NEXT FROM SourceData2 INTO
												 @PackingID		, 
												 @LotNo			,
												 @MaterialCode	,
												 @MaterialName	, 
												 @PackQty		,
												 @PrintTime		,
												 @EmpNo			,
												 @isPrinted		,
												 @isModule		,
												 @partNo		

						            IF @@FETCH_STATUS <> 0 BEGIN
									BREAK
									END

								--UPDATE [SmartFactoryIncubator].[dbo].[RCV_ASN]
								--SET
									--ITM_QTY = @PackQty

								--WHERE
										--PACK_ID = @PackingID
							END

						CLOSE SourceData2; 
						DEALLOCATE SourceData2; 

					end
			end
		
		END			
    END TRY

	BEGIN CATCH

		SET @ERROR_MSG = ERROR_MESSAGE() 
		RAISERROR( @ERROR_MSG ,16, 1) 
	END CATCH
			
	CLOSE SourceData; 
	DEALLOCATE SourceData; 	EXEC sp_xml_removedocument @idoc 

END
GO

