CREATE PROC [dbo].[usp_VN_Show_DeviceMachines]
@pBarCode NVARCHAR(50) = NULL,
@pNAMESTORE NVARCHAR(50) = NULL,
@pNAMELOCATION NVARCHAR(50) = NULL,
@pNAMESTATUS NVARCHAR(50) = NULL,
@pEnglish NVARCHAR(50) = NULL,
@pVietnamese NVARCHAR(50) = NULL
AS
BEGIN
				DECLARE @NAMESTORE NVARCHAR(100) = CASE WHEN ISNULL(@pNAMESTORE,'') = '' THEN '%' ELSE @pNAMESTORE END,
			    @NAMELOCATION NVARCHAR(100)= CASE WHEN ISNULL (@pNAMELOCATION, '') = '' THEN '%' ELSE @pNAMELOCATION END,
				@Barcode NVARCHAR(100)= CASE WHEN ISNULL (@pBarCode, '') = '' THEN '%' ELSE @pBarCode END,
			    @NAMESTATUS NVARCHAR(100) = CASE WHEN ISNULL (@pNAMESTATUS, '') = '' THEN '%' ELSE @pNAMESTATUS END,
				@Vietnamese NVARCHAR(50) = CASE WHEN ISNULL (@pVietnamese, '') = '' THEN '%' ELSE @pVietnamese END,
				@English NVARCHAR(50) = CASE WHEN ISNULL (@pEnglish, '') = '' THEN '%' ELSE @pEnglish END

				--select * from STB_VN_STOREMACHINES
				--select * from STB_VN_LOCATIONMACHINES
				--select * from STB_VN_STATUSMACHINES

			SELECT
					T1.ID,
					T1.BARCODESYSTEM,
					T1.CODEDEVICEMACHINES,
					T1.CODEEXPENSE,
					T1.CODELOCATIONMACHINES,
					T2.NAMELOCATION,
					T1.CODESTOREMACHINES,
					T3.NAMESTORE,
					T1.CODESTATUSMACHINES,
					T4.NAMESTATUS,
					T1.Classifications,
					T1.BPSDPM,
					T1.BPDETAIL,
					T1.Seller,
					T1.English,
					T1.Vietnamese,
					T1.Model,
					T1.Specifications,
					T1.Korean,
					T1.DocumentNo,
					T1.Quantiy,
					T1.PurchaseDate,
					T1.CODE,
					T1.IsUsed,
					T1.CreateDateTime AS Dates,
					RIGHT(T1.CreateDateTime,8) AS Times,
					T1.CreateUserID,
					T1.ChangeDateTime AS DateChanges,
					RIGHT(T1.ChangeDateTime,8) AS TimesChange,
					T1.ChangeUserID,
					T1.Pictures,
					T1.BasePriceVND,
					T1.BasePriceUSD,
					T1.CodeB250,
					'Report' AS CommandType
			FROM 
					STB_VN_DEVICEMACHINES T1 WITH (NOLOCK)
				
			LEFT JOIN STB_VN_LOCATIONMACHINES T2 WITH (NOLOCK)
					  ON T1.CODELOCATIONMACHINES = T2.CODELOCATIONMACHINES
					  
			LEFT JOIN STB_VN_STOREMACHINES T3  WITH (NOLOCK)
					  ON T1.CODESTOREMACHINES = T3.CODESTOREMACHINES

			LEFT JOIN STB_VN_STATUSMACHINES T4  WITH (NOLOCK)
					  ON T1.CODESTATUSMACHINES = T4.CODESTATUSMACHINES
		WHERE
		(
				(T1.BARCODESYSTEM LIKE @Barcode)
		)
		order by t1.CreateDateTime asc
		--OR
		--(
		--		(T3.NAMESTORE LIKE @NAMESTORE)
		--)
		--OR
		--(
		--		(T2.NAMELOCATION LIKE @NAMELOCATION)
		--)
		--OR
		--(
		--		(T4.NAMESTATUS LIKE @NAMESTATUS)
		--)
		--OR
		--(
		--		(T1.English LIKE @English)
		--)
		--OR
		--(
		--		(T1.Vietnamese LIKE @Vietnamese)
		--)

END

	---- select * from STB_VN_DEVICEMACHINES
	--			--select * from STB_VN_LOCATIONMACHINES
	--			--select * from STB_VN_STATUSMACHINES

	--			-- SELECT * FROM STB_VN_DEVICEMACHINES where ID=4