	CREATE proc VN_Add
					    @UserID NVARCHAR(50),
						@LotNo NVARCHAR(50),
						@PartNo NVARCHAR(50),
						@Qty INT
						as
						begin

DECLARE	@PackingID NVARCHAR(50)
DECLARE @MaterialCode NVARCHAR(50)
DECLARE @MaterialName NVARCHAR(50)
DECLARE @EmpNo NVARCHAR(50)
DECLARE @CreatePacked NVARCHAR(50)

DECLARE @VNCODE NVARCHAR(50)

							select 
							@PackingID= a.PackingID,
							@MaterialCode = A.MaterialCode,
							@MaterialName = b.MaterialName,
							@EmpNo = a.CreateUserID,
							@CreatePacked = a.CreateDateTime
							from 
							STB_MaterialLotInfo a join 
							STB_MaterialMaster  b on a.MaterialCode=b.MaterialCode 
							where LotNo = @LotNo
									

									BEGIN
											INSERT INTO STB_VN_FINISHGOODS
											(
												PackingID,
												LotNo,
												MaterialCode,
												MaterialName,
												PackQty,
												EmpNo,
												CreatDatePacked,
												PartNo,
												StatusSystem,
												ProductionSize,
												CreateDate,
												USERID
											)
											VALUES
											(
												@PackingID,
												@LotNo,
												@MaterialCode,
												@MaterialName,
												@Qty,
												@EmpNo,
												@CreatePacked,
												@PartNo,
												N'Nhập',
												SUBSTRING(@MaterialName,19,14),
												DATEADD(HH, -2, GETDATE()),
												@UserID
											)

											
							SELECT 
									@VNCODE = CODEACC
							FROM
									STB_VN_CODEGOODFINISED WITH (NOLOCK)
							WHERE 
									CODEKR = @PartNo
									
									
							UPDATE 
										STB_VN_FINISHGOODS

							SET 
										PublicCode = @VNCODE

							WHERE 
									PartNo = @PartNo	
									END
					end