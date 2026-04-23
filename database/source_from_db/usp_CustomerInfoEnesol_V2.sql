-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[usp_CustomerInfoEnesol_V2]
	-- Add the parameters for the stored procedure here
		@pProcessUserID VARCHAR(20)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DECLARE @CompanyCode VARCHAR(20)
	DECLARE @WorkCenterCode VARCHAR(20)

	SELECT  @CompanyCode = CompanyCode,
			@WorkCenterCode = WorkCenterCode  
	FROM  STB_UserInfo 
	where UserID=@pProcessUserID 

	-- Mr.Manh update 2025-10-07 chia Vinatech riêng, Enesol riêng
	IF (@CompanyCode='VVT' and @WorkCenterCode in ('VVT_F1', 'VVT_F2') ) 
		BEGIN
			SELECT '4739181' AS CustomerCode, 'Farnell' AS CustomerName, 'WEC3R0105QG' AS Supplier union all
			select '4739182', 'Farnell', 'WEC3R0335QG' union all
			select '4739183', 'Farnell', 'WEC3R0505QG' union all
			select '4739184', 'Farnell', 'WEC3R0106QG' union all
			select '4739185', 'Farnell', 'WEC3R0156QG' union all
			select '4739186', 'Farnell', 'WEC3R0256QG' union all
			select '4739187', 'Farnell', 'WEC3R0506QG' union all
			select '4739189', 'Farnell', 'VEC3R0107QG' union all
			select '4739191', 'Farnell', 'VEC3R0227QG' union all
			select '4739192', 'Farnell', 'VEC3R0367QG' union all
			select '4739193', 'Farnell', 'VEC3R0507QG' union all
			select '4739194', 'Farnell', 'WEC6R0504QG-I' union all
			select '4739195', 'Farnell', 'WEC6R0155QG-I' union all
			select '4739196', 'Farnell', 'WEC6R0255QG-I' union all
			select '4739197', 'Farnell', 'WEC6R0505QG-I' union all
			select '4739198', 'Farnell', 'WEC6R0504QG-O' union all
			select '4739199', 'Farnell', 'WEC6R0155QG-O' union all
			select '4739200', 'Farnell', 'WEC6R0255QG-O' union all
			select '4739201', 'Farnell', 'WEC6R0505QG-O' union all
			select '4739202', 'Farnell', 'VEC3R0105QG' union all
			select '4739203', 'Farnell', 'VEC3R0335QG' union all
			select '4739204', 'Farnell', 'VEC3R0505QG' union all
			select '4739205', 'Farnell', 'VEC3R0106QG' union all
			select '4739208', 'Farnell', 'VEC3R0256QG' union all
			select '4739212', 'Farnell', 'VEC6R0255QG-I' union all
			select '4739215', 'Farnell', 'VEL08253R8506G' union all
			select '4739216', 'Farnell', 'VEL10303R8107G' union all
			select '4739217', 'Farnell', 'VEL10403R8157G' union all
			select '4739219', 'Farnell', 'VEL13253R8157G' union all
			select '4739221', 'Farnell', 'VEL13353R8257G' 

		END

	ELSE --IF (@CompanyCode='VVT' and @WorkCenterCode in ('VVT_F3',) )
		BEGIN
			
			SELECT T1.CustomerCode,T1.CustomerName,T2.MaterialCode AS Supplier from STB_CustomerInfoEnesol T1
			LEFT join STB_MaterialCodeByCustomer T2 on T1.CustomerCode=T2.CustomerCode
		END
	

	
END
