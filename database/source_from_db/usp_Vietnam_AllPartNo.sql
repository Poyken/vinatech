CREATE PROC [dbo].[usp_Vietnam_AllPartNo] 
AS
BEGIN
		select 
			distinct ModelName,
			 RIGHT('0' + CONVERT(VARCHAR, CONVERT(INT, MBI.MBISizeW)), 2) + RIGHT('0' + CONVERT(VARCHAR, CONVERT(INT, MBI.MBISizeH)), 2) as size--,
			-- case when MaterialTypeCode like 'MDL%' then N'Mô đun' else 'Cell' end as modeltype
		from STB_ModelBasicInfo	MBI with(nolock) 
		where  MBISizeW is not null
		order by    --case when MaterialTypeCode like 'MDL%' then N'Mô đun' else 'Cell' end ,
					RIGHT('0' + CONVERT(VARCHAR, CONVERT(INT, MBI.MBISizeW)), 2) + RIGHT('0' + CONVERT(VARCHAR, CONVERT(INT, MBI.MBISizeH)), 2) 
END
