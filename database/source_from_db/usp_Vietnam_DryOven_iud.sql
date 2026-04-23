
CREATE proc [dbo].[usp_Vietnam_DryOven_iud]
@pProcessLanguage VARCHAR(20),
@pBarCode NVARCHAR(100) = NULL,
@pPressure float = null,
@pDryTemperature float = null,
@pOutTemperature float = null ,
@pUnit varchar(20) = null,
@pProcessUserID varchar(20) = null
AS
BEGIN			

		update STB_VN_DRYOVER
		set Pressure = isnull(@pPressure,Pressure), 
            DryTemperature = isnull(@pDryTemperature,DryTemperature), 
			OutTemperature = isnull(@pOutTemperature,OutTemperature),
			Unit = isnull(@pUnit,Unit),
			ChangeUserID = ISNULL(@pProcessUserID, ChangeUserID),
			CreateUserID = ISNULL(CreateUserID,@pProcessUserID)
		where BarCode=@pBarCode

END
