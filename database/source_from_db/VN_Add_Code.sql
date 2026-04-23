  
  CREATE proc VN_Add_Code
  @VNcode nvarchar(50),
  @CodeKr nvarchar(50)

  as
	begin
			insert into STB_VN_CODEGOODFINISED 
			(
				CODEACC,
				CODEKR,
				IsUse,
				CreateDateTime,
				CreateUserID
			)
			VALUES
			(
				@VNcode,
				@CodeKr,
				'1',
				DATEADD(HH, -2, GETDATE()),
				'nguyennha'
			)
	end