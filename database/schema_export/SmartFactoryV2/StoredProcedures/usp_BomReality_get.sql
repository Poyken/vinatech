-- Procedure: usp_BomReality_get

CREATE PROCEDURE [dbo].[usp_BomReality_get]          ---  [usp_BomReality_get]
    @pFromDate Date = NULL,
    @pToDate Date = NULL
AS
BEGIN 

	DECLARE @FromDate    VARCHAR(19)  =  CONVERT(VARCHAR(10),  @pFromDate )               +  ' 10:00:00'  
	DECLARE @ToDate      VARCHAR(19)  =  CONVERT(VARCHAR(10),  dateadd(day,1,@pToDate) )  +  ' 10:00:00'  

    select 
			t1.PublicCode,
			si.MaterialCode,
			t1.LotNo,
			t1.MaterialName,
			N'Cái / Chiếc ' as Materialinit

	
			FROM
						STB_VN_FINISHGOODS T1 WITH(NOLOCK)
						left outer join STB_SetInfo si WITH(NOLOCK) on t1.LotNo=si.Barcode
						--- left outer join STB_MaterialMaster
				WHERE 
			Flag = 1
END


GO

