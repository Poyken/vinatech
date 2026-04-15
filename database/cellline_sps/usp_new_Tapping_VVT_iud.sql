CREATE PROC [dbo].[usp_new_Tapping_VVT_iud]
@pProcessUserID VARCHAR(20),
@pProcessLanguage VARCHAR(20),
@pCODEPRODUCTION nvarchar(50)=null,
@pLOTNO nvarchar(50),
@pNAMEERROR nvarchar(50)=null,
@pQTYERROR INT=null,
@pTYPESS nvarchar(50)=null,
@pQTYLOTNO INT,
@pCreateUserID  VARCHAR(20),
@pMachineName   NVARCHAR(20),

				 @pmark1 VARCHAR(20),
				 @pmark2 VARCHAR(20),
				 @pmark3 VARCHAR(20),
				 @pmark4 VARCHAR(20),
				 @pmark5 VARCHAR(20),

	@pRÁCH_VỎ INT=null,
	@pXƯỚC_CHÂN INT=null,
	@pTANCHA_BIẾN_SẮC INT=null,
	@pBẸP_VỎ_NHÔM INT=null,
	@pNGƯỢC_CỰC INT=null,
	@pCONG_CHÂN INT=null,
	@pDỊ_VẬT INT=null,
	@pTRÀN_DỊCH INT=null,
	@pBIẾN_SẮC_ĐÁY INT=null,
	@pRÁCH_CAO_SU INT=null,
	@pLỒI_ĐÁY INT=null,
	@pBẸP_ĐÁY INT=null,
	@pNG_MARKING INT=null,
	@pTHIẾU_SỐ_LƯỢNG INT=null,
	@pNG_TAPE INT=null,
	@pLỖI_KHÁC INT=null,
	@pNG_ESR INT=NULL
AS
BEGIN
	SET NOCOUNT ON;

		--DECLARE @Barcode NVARCHAR(50) = @pLOTNO

		--if(@pProcessUserID='nguyentung') begin
		--	raiserror(@pmark2,16,1);
		--	return;
		--end

		set @pmark1 = case when len(@pmark1)>3 then @pmark1 else '' end
		set @pmark2 = case when len(@pmark2)>3 then '-' + @pmark2 else '' end
		set @pmark3 = case when len(@pmark3)>3 then '-' + @pmark3 else '' end
		set @pmark4 = case when len(@pmark4)>3 then '-' + @pmark4 else '' end
		set @pmark5 = case when len(@pmark5)>3 then '-' + @pmark5 else '' end
		
		declare @MarkingLetters varchar(50) =  @pmark1 + replace(@pmark2,@pmark1,'') 
												+ replace(replace(@pmark3,@pmark1,''),@pmark2,'')
												+ replace(replace(replace(@pmark4,@pmark1,''),@pmark2,''),@pmark3,'')
												+ @pmark5
													
		set @MarkingLetters= replace(replace(@MarkingLetters, '--','-'), '--','-')

		set @MarkingLetters = case when right(@MarkingLetters,1)='-' then substring(@MarkingLetters,1,len(@MarkingLetters)-1) else @MarkingLetters end

		Declare @BendingCurrentData TABLE (
			LOTNO NVARCHAR(100)
		   ,CreateDateTime DATETIME
		   ,QTYLOTNO INT
		);
				

		
		if(@pTYPESS='BENNDING' or @pTYPESS='bennding') set @pTYPESS='BENDING' 
				
		if(@pRÁCH_VỎ is not null and @pRÁCH_VỎ>0 )
		INSERT INTO STB_VN_BENDING_TAPPING ( CODEPRODUCTION, LOTNO, NAMEERROR, QTYERROR, TYPESS,machinename, QTYLOTNO, CreateDateTime, CreateUserID, ChangeDateTime, ChangeUserID, MarkingLetters ) VALUES ( @pCODEPRODUCTION, @pLOTNO, N'RÁCH VỎ', @pRÁCH_VỎ, @pTYPESS, @pMachineName, @pQTYLOTNO, DATEADD(HH, 0, GETDATE()), @pCreateUserID, null, null, @MarkingLetters  )



		if(@pXƯỚC_CHÂN is not null and @pXƯỚC_CHÂN>0)
		INSERT INTO STB_VN_BENDING_TAPPING ( CODEPRODUCTION, LOTNO, NAMEERROR, QTYERROR, TYPESS,machinename, QTYLOTNO, CreateDateTime, CreateUserID, ChangeDateTime, ChangeUserID, MarkingLetters ) VALUES ( @pCODEPRODUCTION, @pLOTNO, N'XƯỚC CHÂN', @pXƯỚC_CHÂN, @pTYPESS, @pMachineName, @pQTYLOTNO, DATEADD(HH, 0, GETDATE()), @pCreateUserID, null, null, @MarkingLetters  )
		


		if(@pTANCHA_BIẾN_SẮC is not null and @pTANCHA_BIẾN_SẮC>0)
		INSERT INTO STB_VN_BENDING_TAPPING ( CODEPRODUCTION, LOTNO, NAMEERROR, QTYERROR, TYPESS,machinename, QTYLOTNO, CreateDateTime, CreateUserID, ChangeDateTime, ChangeUserID, MarkingLetters ) VALUES ( @pCODEPRODUCTION, @pLOTNO, N'TANCHA BIẾN SẮC', @pTANCHA_BIẾN_SẮC, @pTYPESS, @pMachineName, @pQTYLOTNO, DATEADD(HH, 0, GETDATE()), @pCreateUserID, null, null, @MarkingLetters  )
		


		if(@pBẸP_VỎ_NHÔM is not null and @pBẸP_VỎ_NHÔM>0)
		INSERT INTO STB_VN_BENDING_TAPPING ( CODEPRODUCTION, LOTNO, NAMEERROR, QTYERROR, TYPESS,machinename, QTYLOTNO, CreateDateTime, CreateUserID, ChangeDateTime, ChangeUserID, MarkingLetters ) VALUES ( @pCODEPRODUCTION, @pLOTNO, N'BẸP VỎ NHÔM', @pBẸP_VỎ_NHÔM, @pTYPESS, @pMachineName, @pQTYLOTNO, DATEADD(HH, 0, GETDATE()), @pCreateUserID, null, null, @MarkingLetters  )


		
		if(@pNGƯỢC_CỰC is not null and @pNGƯỢC_CỰC>0)
		INSERT INTO STB_VN_BENDING_TAPPING ( CODEPRODUCTION, LOTNO, NAMEERROR, QTYERROR, TYPESS,machinename, QTYLOTNO, CreateDateTime, CreateUserID, ChangeDateTime, ChangeUserID, MarkingLetters ) VALUES ( @pCODEPRODUCTION, @pLOTNO, N'NGƯỢC CỰC', @pNGƯỢC_CỰC, @pTYPESS, @pMachineName, @pQTYLOTNO, DATEADD(HH, 0, GETDATE()), @pCreateUserID, null, null, @MarkingLetters  )
		


		if(@pCONG_CHÂN is not null and @pCONG_CHÂN>0)
		INSERT INTO STB_VN_BENDING_TAPPING ( CODEPRODUCTION, LOTNO, NAMEERROR, QTYERROR, TYPESS,machinename, QTYLOTNO, CreateDateTime, CreateUserID, ChangeDateTime, ChangeUserID, MarkingLetters ) VALUES ( @pCODEPRODUCTION, @pLOTNO, N'CONG CHÂN', @pCONG_CHÂN, @pTYPESS, @pMachineName, @pQTYLOTNO, DATEADD(HH, 0, GETDATE()), @pCreateUserID, null, null, @MarkingLetters  )
				


		if(@pDỊ_VẬT is not null and @pDỊ_VẬT>0)
		INSERT INTO STB_VN_BENDING_TAPPING ( CODEPRODUCTION, LOTNO, NAMEERROR, QTYERROR, TYPESS,machinename, QTYLOTNO, CreateDateTime, CreateUserID, ChangeDateTime, ChangeUserID, MarkingLetters ) VALUES ( @pCODEPRODUCTION, @pLOTNO, N'DỊ VẬT', @pDỊ_VẬT, @pTYPESS, @pMachineName, @pQTYLOTNO, DATEADD(HH, 0, GETDATE()), @pCreateUserID, null, null, @MarkingLetters  )

		

		if(@pTRÀN_DỊCH is not null and @pTRÀN_DỊCH>0)
		INSERT INTO STB_VN_BENDING_TAPPING ( CODEPRODUCTION, LOTNO, NAMEERROR, QTYERROR, TYPESS,machinename, QTYLOTNO, CreateDateTime, CreateUserID, ChangeDateTime, ChangeUserID, MarkingLetters ) VALUES ( @pCODEPRODUCTION, @pLOTNO, N'TRÀN DỊCH', @pTRÀN_DỊCH, @pTYPESS, @pMachineName, @pQTYLOTNO, DATEADD(HH, 0, GETDATE()), @pCreateUserID, null, null, @MarkingLetters  )


		
		if(@pBIẾN_SẮC_ĐÁY is not null and @pBIẾN_SẮC_ĐÁY>0)
		INSERT INTO STB_VN_BENDING_TAPPING ( CODEPRODUCTION, LOTNO, NAMEERROR, QTYERROR, TYPESS,machinename, QTYLOTNO, CreateDateTime, CreateUserID, ChangeDateTime, ChangeUserID, MarkingLetters ) VALUES ( @pCODEPRODUCTION, @pLOTNO, N'BIẾN SẮC ĐÁY', @pBIẾN_SẮC_ĐÁY, @pTYPESS, @pMachineName, @pQTYLOTNO, DATEADD(HH, 0, GETDATE()), @pCreateUserID, null, null, @MarkingLetters  )
				


		if(@pRÁCH_CAO_SU is not null and @pRÁCH_CAO_SU>0)
		INSERT INTO STB_VN_BENDING_TAPPING ( CODEPRODUCTION, LOTNO, NAMEERROR, QTYERROR, TYPESS,machinename, QTYLOTNO, CreateDateTime, CreateUserID, ChangeDateTime, ChangeUserID, MarkingLetters ) VALUES ( @pCODEPRODUCTION, @pLOTNO, N'RÁCH CAO SU', @pRÁCH_CAO_SU, @pTYPESS, @pMachineName, @pQTYLOTNO, DATEADD(HH, 0, GETDATE()), @pCreateUserID, null, null, @MarkingLetters  )

		

		if(@pLỒI_ĐÁY is not null and @pLỒI_ĐÁY>0)
		INSERT INTO STB_VN_BENDING_TAPPING ( CODEPRODUCTION, LOTNO, NAMEERROR, QTYERROR, TYPESS,machinename, QTYLOTNO, CreateDateTime, CreateUserID, ChangeDateTime, ChangeUserID, MarkingLetters ) VALUES ( @pCODEPRODUCTION, @pLOTNO, N'LỒI ĐÁY', @pLỒI_ĐÁY, @pTYPESS, @pMachineName, @pQTYLOTNO, DATEADD(HH, 0, GETDATE()), @pCreateUserID, null, null, @MarkingLetters  )

		

		if(@pBẸP_ĐÁY is not null and @pBẸP_ĐÁY>0) 
		INSERT INTO STB_VN_BENDING_TAPPING ( CODEPRODUCTION, LOTNO, NAMEERROR, QTYERROR, TYPESS,machinename, QTYLOTNO, CreateDateTime, CreateUserID, ChangeDateTime, ChangeUserID, MarkingLetters ) VALUES ( @pCODEPRODUCTION, @pLOTNO, N'BẸP ĐÁY', @pBẸP_ĐÁY, @pTYPESS, @pMachineName, @pQTYLOTNO, DATEADD(HH, 0, GETDATE()), @pCreateUserID, null, null, @MarkingLetters  )

		

		if(@pNG_MARKING is not null and @pNG_MARKING>0) 
		INSERT INTO STB_VN_BENDING_TAPPING ( CODEPRODUCTION, LOTNO, NAMEERROR, QTYERROR, TYPESS,machinename, QTYLOTNO, CreateDateTime, CreateUserID, ChangeDateTime, ChangeUserID, MarkingLetters ) VALUES ( @pCODEPRODUCTION, @pLOTNO, N'NG MARKING', @pNG_MARKING, @pTYPESS, @pMachineName, @pQTYLOTNO, DATEADD(HH, 0, GETDATE()), @pCreateUserID, null, null, @MarkingLetters  )

		

		if(@pTHIẾU_SỐ_LƯỢNG is not null and @pTHIẾU_SỐ_LƯỢNG>0) 
		INSERT INTO STB_VN_BENDING_TAPPING ( CODEPRODUCTION, LOTNO, NAMEERROR, QTYERROR, TYPESS,machinename, QTYLOTNO, CreateDateTime, CreateUserID, ChangeDateTime, ChangeUserID, MarkingLetters ) VALUES ( @pCODEPRODUCTION, @pLOTNO, N'THIẾU SỐ LƯỢNG', @pTHIẾU_SỐ_LƯỢNG, @pTYPESS, @pMachineName, @pQTYLOTNO, DATEADD(HH, 0, GETDATE()), @pCreateUserID, null, null, @MarkingLetters  )

		

		if(@pNG_TAPE is not null and @pNG_TAPE>0) 
		INSERT INTO STB_VN_BENDING_TAPPING ( CODEPRODUCTION, LOTNO, NAMEERROR, QTYERROR, TYPESS,machinename, QTYLOTNO, CreateDateTime, CreateUserID, ChangeDateTime, ChangeUserID, MarkingLetters ) VALUES ( @pCODEPRODUCTION, @pLOTNO, N'NG TAPE', @pNG_TAPE, @pTYPESS, @pMachineName, @pQTYLOTNO, DATEADD(HH, 0, GETDATE()), @pCreateUserID, null, null, @MarkingLetters  )
		


		if(@pLỖI_KHÁC is not null and @pLỖI_KHÁC>0) 
		INSERT INTO STB_VN_BENDING_TAPPING ( CODEPRODUCTION, LOTNO, NAMEERROR, QTYERROR, TYPESS,machinename, QTYLOTNO, CreateDateTime, CreateUserID, ChangeDateTime, ChangeUserID, MarkingLetters ) VALUES ( @pCODEPRODUCTION, @pLOTNO, N'LỖI KHÁC', @pLỖI_KHÁC, @pTYPESS, @pMachineName, @pQTYLOTNO, DATEADD(HH, 0, GETDATE()), @pCreateUserID, null, null, @MarkingLetters  )

			if(@pNG_ESR is not null and @pNG_ESR>0) 
		INSERT INTO STB_VN_BENDING_TAPPING ( CODEPRODUCTION, LOTNO, NAMEERROR, QTYERROR, TYPESS,machinename, QTYLOTNO, CreateDateTime, CreateUserID, ChangeDateTime, ChangeUserID, MarkingLetters ) VALUES ( @pCODEPRODUCTION, @pLOTNO, N'ESR NG',@pNG_ESR, @pTYPESS, @pMachineName, @pQTYLOTNO, DATEADD(HH, 0, GETDATE()), @pCreateUserID, null, null, @MarkingLetters  )


		-- Table val..
		INSERT INTO @BendingCurrentData
		SELECT TOP 50 LOTNO, CreateDateTime, QTYLOTNO
		  FROM STB_VN_BENDING_TAPPING
		 ORDER BY ID DESC
				
		
		declare @ccount int=0 


		select 
			@ccount = count(*) 
		from @BendingCurrentData 
		where LOTNO=@pLOTNO and createdatetime >= dateadd(second,-5,getdate()) and QTYLOTNO>0  


		if(@ccount=0  and @pQTYLOTNO>0 ) 
			INSERT INTO STB_VN_BENDING_TAPPING ( CODEPRODUCTION, LOTNO, NAMEERROR, QTYERROR, TYPESS,machinename, QTYLOTNO, CreateDateTime, CreateUserID, ChangeDateTime, ChangeUserID, MarkingLetters ) VALUES ( @pCODEPRODUCTION, @pLOTNO, N'', isnull(@pQTYERROR,0), @pTYPESS, @pMachineName, @pQTYLOTNO, DATEADD(HH, 0, GETDATE()), @pCreateUserID, null, null,@MarkingLetters )


			
		select 
			@ccount = count(*) 
		from @BendingCurrentData 
		where LOTNO=@pLOTNO and createdatetime>=dateadd(second,-5,getdate()) and QTYLOTNO>0 


		if (@ccount>0)  begin 
			--raiserror('Luu du lieu Thanh Cong',0,1);
			select  'LUU THANH CONG_'+convert(varchar(19),dateadd(hour,-2,getdate()),120)  as ModelCode 
		end 
		
END
