-- =============================================
-- Author:	    Mr.Tung
-- Create date: 2021-05-27
-- =============================================
CREATE PROCEDURE [dbo].[usp_Vietnam_hodlReason_popup]
AS
BEGIN
	SET NOCOUNT ON;

		select N'Rách điện cực' as Reason, N'Rách điện cực' as "ReasonName"
	union all
		select N'Bẩn đáy' as Reason, N'Bẩn đáy' as "ReasonName"
	union all
		select N'Tràn Dịch' as Reason, N'Tràn Dịch' as "ReasonName"
	union all
		select N'NG ESR' as Reason, N'NG ESR' as "ReasonName"
	union all
		select N'NG ESR Lưu kho dài hạn' as Reason, N'NG ESR Lưu kho dài hạn' as "ReasonName"
	union all
		select N'Rách xô cha' as Reason, N'Rách xô cha' as "ReasonName"
	union all
		select N'NG chiều dày vết dập' as Reason, N'NG chiều dày vết dập' as "ReasonName"
	union all
		select N'NG gập chân pin' as Reason, N'NG gập chân pin' as "ReasonName"
	union all
		select N'NG dung lượng' as Reason, N'NG dung lượng' as "ReasonName"
	union all
		select N'NG PPM' as Reason, N'NG PPM' as "ReasonName"
	union all
		select N'Other' as Reason, N'Other' as "ReasonName"
	
END
