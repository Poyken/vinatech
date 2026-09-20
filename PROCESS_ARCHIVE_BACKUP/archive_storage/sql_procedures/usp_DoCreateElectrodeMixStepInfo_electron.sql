CREATE PROC [dbo].[usp_DoCreateElectrodeMixStepInfo_electron]
	@pElectrodeLotNumber VARCHAR(20)
   ,@pElectrodeStep VARCHAR(100)
   ,@pSeq VARCHAR(100)
   ,@pInputQty1 VARCHAR(100)
   ,@pInputQty2 VARCHAR(100)
   ,@pBinderInputDateTime VARCHAR(100)
   ,@pBinderOutputDateTime VARCHAR(100)
   ,@pMaterialLotNumber VARCHAR(100)
AS
BEGIN
	Declare @ElectrodeLotNumber VARCHAR(20) = @pElectrodeLotNumber
		   ,@ElectrodeStep VARCHAR(100) = @pElectrodeStep
		   ,@Seq VARCHAR(100) = @pSeq
		   ,@InputQty1 VARCHAR(100) = CASE WHEN @pInputQty1 = '' THEN '0' ELSE @pInputQty1 END
		   ,@InputQty2 VARCHAR(100) = CASE WHEN @pInputQty2 = '' THEN '0' ELSE @pInputQty2 END
		   ,@BinderInputDateTime VARCHAR(100) = @pBinderInputDateTime
		   ,@BinderOutputDateTime VARCHAR(100) = @pBinderOutputDateTime
		   ,@MaterialLotNumber VARCHAR(100) = @pMaterialLotNumber
		   ,@MaterialCode VARCHAR(20)
		   ,@ElectrodeMaterialCode VARCHAR(20)
		   ,@ccount int=0;

		   
		   -- add by Mr.Tung on 2022-June-07  for  auto fill Empty Mixing in Vietnam, prepared for  Viscosity Software read automatically
		   select @ccount = count(*) from STB_ElectrodeMixInfo where electrodelotnumber=@ElectrodeLotNumber
		   if(@ElectrodeLotNumber like 'VV%' and @ccount=0)  
		   begin
                    INSERT INTO STB_ElectrodeMixInfo ( ElectrodeLotNumber,  ViscosityValue )
						VALUES ( @ElectrodeLotNumber,  NULL );
		   end
		   -- end by Mr.Tung



	-- 코팅롤 품목코드
	SELECT @MaterialCode = MaterialCode
	  FROM STB_SetInfo
	 WHERE Barcode = @ElectrodeLotNumber

	-- 전극원자재코드
	SELECT @ElectrodeMaterialCode = MaterialCode
	  FROM STB_ElectrodeStep
	 WHERE ProdCode = @MaterialCode
	   AND Seq = @Seq
	   AND ElectrodeStepCode = @ElectrodeStep

	   declare @createuser varchar(30)='eai';
	   
	   	 -- add by Mr.Tung on 2022-August-12  for  auto change K-15 to PVP raw Material		 
		   if(@ElectrodeLotNumber like 'VV%' and @ElectrodeMaterialCode='GAJSCB-001')  
		   begin
				  set @createuser='eaivvt'
				  if(upper(@MaterialLotNumber) not like '%'+upper(@ElectrodeMaterialCode)+'%' )
						set @ElectrodeMaterialCode = 
								case when @ElectrodeMaterialCode='GAJSCB-001' then 'GAADCB-001' else @ElectrodeMaterialCode end
		   end
		   -- end by Mr.Tung
		   

	 INSERT INTO STB_ElectrodeMixStepInfo (ElectrodeLotNumber, ElectrodeStep, Seq, ElectrodeMaterialCode, InputQty1
	                                      ,InputQty2, MaterialLotNumber, BinderInputTime, BinderOutputTime, CreateDateTime
										  ,CreateUserID)
		SELECT @ElectrodeLotNumber, @ElectrodeStep, @Seq, @ElectrodeMaterialCode, CONVERT(NUMERIC(20,5), @InputQty1)
		      ,CONVERT(NUMERIC(20,5), @InputQty2), @MaterialLotNumber, @BinderInputDateTime, @BinderOutputDateTime, GETDATE()
			  ,@createuser
END
