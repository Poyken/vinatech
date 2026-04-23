-- =============================================
-- Author: Mr.Tung (nguyentung@vina.co.kr)
-- Create date: 2021-11-18
-- Browsable : true
-- =============================================
CREATE PROCEDURE [dbo].[usp_DoSetLabelRePrint_VVT]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pPackageID VARCHAR(20) 
AS
BEGIN
	SET NOCOUNT ON;

	Declare @PackageID VARCHAR(20) = STUFF(@pPackageID,1,1,'2')
	Declare @CreateUserCount VARCHAR(20) = ''
	Declare @IsPrinted BIT


		SELECT  @IsPrinted = count(*), 
				@CreateUserCount=CreateUserID
		  FROM STB_HelaBarcode
		  WHERE PackageID = @PackageID	and PrintYn=1
		GROUP BY CreateUserID


	-- if the PackageID has printed, allow reprinting. Else Nothing to do
	IF @IsPrinted>convert(BIT,0) BEGIN
		
		select @CreateUserCount = isnull(@CreateUserCount,'0')
		IF(LEN(@CreateUserCount)>2) BEGIN
			select @CreateUserCount = '0'  --if @CreateUserID is Null or have length > 2 , change to 0
		END

		declare @count INT = 0
		IF(LEN(@CreateUserCount)=1) BEGIN					
				begin try
						select @count = convert(INT,@CreateUserCount)+1 --if @CreateUserCount have length = 1 (mean 0,1,2,3,4,5,6,7,9) then convert @CreateUserCount to INT and plus 1
				end try
				begin catch
				end catch
		END

		if(@count>0) 
				begin try
						select @CreateUserCount = CONVERT(VARCHAR(10),@count) --convert @CreateUserCount Back VARCHAR after plus 1 (if @count>0)
				end try
				begin catch
				end catch

		UPDATE STB_HelaBarcode
		  SET PrintYn=0,
		   CreateUserID = @CreateUserCount,
		   ChangeDateTime=getdate(),
		   ChangeUserID=@pProcessUserID
		WHERE PackageID = @PackageID	
		commit;
	END


	 SELECT  @IsPrinted = isnull(PrintYn,0)
		  FROM STB_HelaBarcode
		  WHERE PackageID = @PackageID

	if(convert(BIT,@IsPrinted) = convert(BIT,0))
		RAISERROR ('Ban da thuc hien cho phep in lai xong, bay gio, ban co the bam nut INBOX LABEL PRINT de in lai tem Tray',16,1)

END


--select*from STB_HelaBarcode
--where batchid='VJLT122R750639'


--select top 10 
--SIExtInt01, *
--from STB_SetInfo