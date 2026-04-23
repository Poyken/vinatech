-- =============================================
-- Author: Park Jong Hoon(jhpark@awoo.co.kr)
-- Create date: 2016-05-22
-- Browsable : true
-- Group : 설비관리
-- Description:	설비수리자재정보 IUD
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_MachineRepairMaterialHist_iud]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
    @pProcessViewName VARCHAR(50),
	@pXml NVARCHAR(MAX) = null --,
	--@pMachineRepairHistoryNo VARCHAR(20)--,
	--@pOutMachineRepairHistoryNo VARCHAR(20) OUTPUT
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
	
    -- Declare Columns Variable
    DECLARE @OldMachineRepairHistoryNo VARCHAR(20)
    DECLARE @OldMachineRepairMaterialSeq VARCHAR(20)
    DECLARE @MachineRepairHistoryNo VARCHAR(20)
    DECLARE @MachineRepairMaterialSeq VARCHAR(20)
    DECLARE @SparePartChangeHistoryNo VARCHAR(20)
  
   
    DECLARE @CompanyCode VARCHAR(20)
    DECLARE @WorkCenterCode VARCHAR(20)
    DECLARE @SparePartCode VARCHAR(20)
    DECLARE @ChangeQty NUMERIC(20,5)
    DECLARE @SPWarehouseCode VARCHAR(20)
    DECLARE @SPLocationCode VARCHAR(20)
    DECLARE @BasicUnitPrice NUMERIC(20,5)
    DECLARE @MachineCode VARCHAR(20)
	
	--MachineRepairMaterialHist Key Column Create Rule
	DECLARE @MachineRepairMaterialHist_PrefixString VARCHAR(20)
	DECLARE @MachineRepairMaterialHist_SerialLen INT
	
    --SparePartIOHistory Key Column Create Rule
    DECLARE @SparePartIOHist_PrefixString  VARCHAR(20)
    DECLARE @SparePartIOHist_SerialLen INT
  
    --SparePartChangeHistory Key Column Create Rule
    DECLARE @SparePartChangeHist_PrefixString  VARCHAR(20)
    DECLARE @SparePartChangeHist_SerialLen INT
  
  
    DECLARE @SparePartIOHistoryNo VARCHAR(20)
  
	--DECLARE @MachineRepairHistoryNo_Params VARCHAR(20)
	--SET @MachineRepairHistoryNo_Params = @pMachineRepairHistoryNo
	

	DECLARE @iDoc INT
	
	--설비수리자재정보 키생성 Rule
    EXEC SmartFramework.dbo.usp_GetSerialRule 
			@pTableName = 'STB_MachineRepairMaterialHist',
			@pPrefixData = @MachineRepairMaterialHist_PrefixString OUTPUT,
			@pSerialLen = @MachineRepairMaterialHist_SerialLen OUTPUT
			
	--스페어파트입출고이력 키생성 Rule	
	 EXEC SmartFramework.dbo.usp_GetSerialRule 
			@pTableName = 'STB_SparePartIOHistory',
			@pPrefixData = @SparePartIOHist_PrefixString OUTPUT,
			@pSerialLen = @SparePartIOHist_SerialLen OUTPUT
			
	
	--스페어파트교체이력정보 키생성 Rule
	EXEC SmartFramework.dbo.usp_GetSerialRule 
			@pTableName = 'STB_SparePartChangeHistory',
			@pPrefixData = @SparePartChangeHist_PrefixString OUTPUT,
			@pSerialLen = @SparePartChangeHist_SerialLen OUTPUT		
			
    
    
    BEGIN
        EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
        BEGIN TRY
		    DECLARE SourceData CURSOR FOR
                SELECT
                        'INSERT' AS IUD_FLAG,
									XMLData.OldMachineRepairHistoryNo,
									XMLData.OldMachineRepairMaterialSeq,
									XMLData.MachineRepairHistoryNo,
									XMLData.MachineRepairMaterialSeq,
									XMLData.SparePartChangeHistoryNo,
									XMLData.CompanyCode,
									XMLData.WorkCenterCode,
									XMLData.SparePartCode,
									XMLData.ChangeQty,
									XMLData.SPWarehouseCode,
									XMLData.SPLocationCode,
									XMLData.BasicUnitPrice,
									XMLData.SparePartIOHistoryNo,
									XMLData.MachineCode
							FROM
									OPENXML(@idoc , @InsertTableName , 2)
							        WITH  (
											 OldMachineRepairHistoryNo VARCHAR(20),
											 OldMachineRepairMaterialSeq VARCHAR(20),
											 MachineRepairHistoryNo VARCHAR(20),
											 MachineRepairMaterialSeq VARCHAR(20),
											 SparePartChangeHistoryNo VARCHAR(20),
											 CompanyCode VARCHAR(20),
											 WorkCenterCode VARCHAR(20),
											 SparePartCode VARCHAR(20),
											 ChangeQty NUMERIC(20,5),
											 SPWarehouseCode VARCHAR(20),
											 SPLocationCode VARCHAR(20),
											 BasicUnitPrice NUMERIC(20,5),
											 SparePartIOHistoryNo VARCHAR(20),
											 MachineCode VARCHAR(20)
											) XMLData
							UNION ALL
							SELECT
									'UPDATE' AS IUD_FLAG,
									CASE 
										WHEN XMLData.OldMachineRepairHistoryNo IS NULL THEN XMLData.MachineRepairHistoryNo
										ELSE XMLData.OldMachineRepairHistoryNo
									END AS OldMachineRepairHistoryNo,
									CASE 
										WHEN XMLData.OldMachineRepairMaterialSeq IS NULL THEN XMLData.MachineRepairMaterialSeq
										ELSE XMLData.OldMachineRepairMaterialSeq
									END AS OldMachineRepairMaterialSeq,
									XMLData.MachineRepairHistoryNo,
									XMLData.MachineRepairMaterialSeq,
									XMLData.SparePartChangeHistoryNo,
									XMLData.CompanyCode,
									XMLData.WorkCenterCode,
									XMLData.SparePartCode,
									XMLData.ChangeQty,
									XMLData.SPWarehouseCode,
									XMLData.SPLocationCode,
									XMLData.BasicUnitPrice,
									XMLData.SparePartIOHistoryNo,
									XMLData.MachineCode
							FROM
									OPENXML(@idoc , @UpdateTableName , 2)
							        WITH  (
											 OldMachineRepairHistoryNo VARCHAR(20),
											 OldMachineRepairMaterialSeq VARCHAR(20),
											 MachineRepairHistoryNo VARCHAR(20),
											 MachineRepairMaterialSeq VARCHAR(20),
											 SparePartChangeHistoryNo VARCHAR(20),
											 CompanyCode VARCHAR(20),
											 WorkCenterCode VARCHAR(20),
											 SparePartCode VARCHAR(20),
											 ChangeQty NUMERIC(20,5),
											 SPWarehouseCode VARCHAR(20),
											 SPLocationCode VARCHAR(20),
											 BasicUnitPrice NUMERIC(20,5),
											 SparePartIOHistoryNo VARCHAR(20),
											 MachineCode VARCHAR(20)
											) XMLData
							UNION ALL
							SELECT
									'DELETE' AS IUD_FLAG,
									CASE 
										WHEN XMLData.OldMachineRepairHistoryNo IS NULL THEN XMLData.MachineRepairHistoryNo
										ELSE XMLData.OldMachineRepairHistoryNo
									END AS OldMachineRepairHistoryNo,
									CASE 
										WHEN XMLData.OldMachineRepairMaterialSeq IS NULL THEN XMLData.MachineRepairMaterialSeq
										ELSE XMLData.OldMachineRepairMaterialSeq
									END AS OldMachineRepairMaterialSeq,
									XMLData.MachineRepairHistoryNo,
									XMLData.MachineRepairMaterialSeq,
									XMLData.SparePartChangeHistoryNo,
									XMLData.CompanyCode,
									XMLData.WorkCenterCode,
									XMLData.SparePartCode,
									XMLData.ChangeQty,
									XMLData.SPWarehouseCode,
									XMLData.SPLocationCode,
									XMLData.BasicUnitPrice,
									XMLData.SparePartIOHistoryNo,
									XMLData.MachineCode
							FROM
									OPENXML(@idoc , @DeleteTableName , 2)
							        WITH  (
											 OldMachineRepairHistoryNo VARCHAR(20),
											 OldMachineRepairMaterialSeq VARCHAR(20),
											 MachineRepairHistoryNo VARCHAR(20),
											 MachineRepairMaterialSeq VARCHAR(20),
											 SparePartChangeHistoryNo VARCHAR(20),
											 CompanyCode VARCHAR(20),
											 WorkCenterCode VARCHAR(20),
											 SparePartCode VARCHAR(20),
											 ChangeQty NUMERIC(20,5),
											 SPWarehouseCode VARCHAR(20),
											 SPLocationCode VARCHAR(20),
											 BasicUnitPrice NUMERIC(20,5),
											 SparePartIOHistoryNo VARCHAR(20),
											 MachineCode VARCHAR(20)
											) XMLData


            OPEN SourceData

            WHILE 1 = 1 BEGIN
                FETCH NEXT FROM SourceData INTO
								 @IUD_FLAG,
								 @OldMachineRepairHistoryNo,
								 @OldMachineRepairMaterialSeq,
								 @MachineRepairHistoryNo,
								 @MachineRepairMaterialSeq,
								 @SparePartChangeHistoryNo,
								 @CompanyCode,
								 @WorkCenterCode,
								 @SparePartCode,
								 @ChangeQty,
								 @SPWarehouseCode,
								 @SPLocationCode,
								 @BasicUnitPrice,
								 @SparePartIOHistoryNo,
								 @MachineCode
								 
                IF @@FETCH_STATUS <> 0 BEGIN
					BREAK
				END
				
				--IF @MachineRepairHistoryNo IS NULL BEGIN
				--	SET @pMachineRepairHistoryNo = @MachineRepairHistoryNo
				--END
				
				--SET @pOutMachineRepairHistoryNo = @pMachineRepairHistoryNo
				
				EXEC usp_DoMachineRepairMaterialHistSub_iud @pOldMachineRepairHistoryNo = @OldMachineRepairHistoryNo,
															@pOldMachineRepairMaterialSeq = @OldMachineRepairMaterialSeq,
															@pMachineRepairHistoryNo = @MachineRepairHistoryNo,
															@pMachineRepairMaterialSeq = @MachineRepairMaterialSeq,
															@pSparePartChangeHistoryNo = @SparePartChangeHistoryNo,
															@pCompanyCode = @CompanyCode,
															@pWorkCenterCode = @WorkCenterCode,
															@pSparePartCode = @SparePartCode,
															@pChangeQty = @ChangeQty,
															@pSPWarehouseCode = @SPWarehouseCode,
															@pSPLocationCode = @SPLocationCode,
															@pBasicUnitPrice = @BasicUnitPrice,
															@pMachineCode = @MachineCode,
															@pSparePartIOHistoryNo = @SparePartIOHistoryNo,
															@pMachineRepairMaterialHist_PrefixString = @MachineRepairMaterialHist_PrefixString,
															@pMachineRepairMaterialHist_SerialLen = @MachineRepairMaterialHist_SerialLen,
															@pSparePartIOHist_PrefixString = @SparePartIOHist_PrefixString,
															@pSparePartIOHist_SerialLen = @SparePartIOHist_SerialLen,
															@pSparePartChangeHist_PrefixString = @SparePartChangeHist_PrefixString,
															@pSparePartChangeHist_SerialLen = @SparePartChangeHist_SerialLen,
															@pIUD_FLAG = @IUD_FLAG
															
				EXEC usp_DoUpdateMachineRepairHistory @MachineRepairHistoryNo
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

