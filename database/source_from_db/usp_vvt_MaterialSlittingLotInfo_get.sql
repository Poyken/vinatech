
-- =========================================================================
-- Author:	    MR.Duy
-- Create date: 2025-02-06
-- Description:	Lấy dữ liệu đã cắt ở phòng slitting hà nam để QC duyệt

-- =========================================================================
CREATE PROCEDURE [dbo].[usp_vvt_MaterialSlittingLotInfo_get]
						@pProcessUserID VARCHAR(20),
						@pProcessLanguage VARCHAR(20),
						@pCompanyCode VARCHAR(30) = NULL,
						@pWorkCenterCode VARCHAR(30) = NULL,
						@pFromDate datetime = NULL,
						@pToDate datetime = NULL,
						@pMaterialCode VARCHAR(50) = NULL,                                         
						@pLotID varchar(50) = Null                                                

					--	@pLabelType NVARCHAR(60) = NULL                                     -- 2020.06.16 추가 (구보겸)
AS
BEGIN
	SET NOCOUNT ON;


		select 
				mli.LotID,
				mli.PackingID,
				mli.MaterialWarehouseCode,
				mli.MaterialCode,
				MM.MaterialName,
				MM.MaterialUnit,
				mli.InitialQty,
				mli.CurrentQty,
				mli.LengthSlitting,
				case 
				when mli.IsSlitting=1
				then N'Đã chốt'
				else N'Chưa chốt'
				end
				as IsSlitting,
				mli.IsCheck,
				MLI.LotAttr10,
				mli.createDAtetime,
				mli.Createuserid

		 from  STB_MaterialLotInfo mli  with(nolock)
		--left outer join STB_MaterialDocDetail mdd  with(nolock) on mdd.MaterialDocDetailNo = mli.MaterialDocDetailNo
		LEFT OUTER jOIN STB_MaterialMaster MM WITH(NOLOCK)			ON	mli.MaterialCode = MM.MaterialCode
		where
		1=1
		and   mli.MaterialWarehouseCode='SLITTING_HN_WH'
		and   mli.IsCheck is null   -- chưa được kiểm tra
		and   mli.IsParrent is null -- phải là th được cắt
		and	  (mli.IsSlitting is not null or mli.IsSlitting =1)  --đã được chốt
		and   mli.lotid like '%SL%' -- chỉ lấy mã là SL
			
	
		   					      
END
