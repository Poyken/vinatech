CREATE PROC [dbo].[usp_VN_Temperature_Humidity_VVT] -- EXEC usp_VN_Temperature_Humidity_VVT '2022-03-01','2022-03-03'
@pFdate DATETIME = NULL,
@pTdate DATETIME = NULL
AS
BEGIN

--	select * from STB_IoTMeasureHist where DeviceID like '13%'
--  select * from STB_IoTMeasureHist where DeviceID = '11_ELECTRODE_CUT_MATERIAL'


		--DECLARE @issNull VARCHAR(10)= 'FALSE'
		DECLARE @FromDate DATE = @pFdate
		DECLARE @ToDate DATE = @pTdate

		--IF @FromDate IS NULL AND  @ToDate IS NULL
		--BEGIN
		--	select @issNull='TRUE'			
		--end

SELECT
		DeviceID,
		MeasureItemCode,
		--MeasureValue,
		CreateDateTime,
		RIGHT(CreateDateTime,8) AS Times,

		CASE
				WHEN    DeviceID = N'05_WAREHOUSE_DOOR'  THEN 'The device near warehouse door'
				WHEN    DeviceID = N'06_LINE12_BETWEEN_LI'  THEN 'The device between line 12 and line 13'
				WHEN    DeviceID = N'07_LINE17_BETWEEN_LI'  THEN 'Then device between line 17 and line 18'
				WHEN    DeviceID = N'08_LINE4_BETWEEN_LIN'  THEN 'The device between line 4 and line 5'
				WHEN    DeviceID = N'09_UTILITY_ROOM'       THEN 'The device in utility room'
				WHEN    DeviceID = N'11_ELECTRODE_CUT_MAT'  THEN 'The device electrode cut material'
				WHEN    DeviceID = N'10_MANUALLY_LINE_FAC'  THEN 'The device manually line factory 1'
				WHEN    DeviceID = N'12_MIXING_FACTORY2'     THEN 'The device mixing  factory 2'
				WHEN    DeviceID = N'13WAREHOUSEFACTORY2'  THEN 'The device warehouse  factory 2'
				WHEN    DeviceID = N'14MANUALLINEFACTORY2'  THEN 'The device manually line in  factory 2'
				WHEN    DeviceID =N'13WAREHOUSEFACTORY2' THEN N'Gần điện cực xưởng 2'
				WHEN    DeviceID = N'15WAREHOUSEFACTORY1' THEN N'Trong kho xưởng thành phẩm xưởng 1'
				WHEN    DeviceID = N'16OQCFACTORY1' THEN N'Cửa ra vào xưởng một chỗ QC'
				WHEN    DeviceID = N'17LINE7' THEN N'Gần chuyền 7 và chuyền 8'
				WHEN    DeviceID = N'18ELECTRODEFACTORY1' THEN N'Điện cực xưởng 1'
				WHEN    DeviceID = N'19IQCFACTORY2' THEN N'Kho thành phẩm và IQC xưởng 2'
				WHEN    DeviceID = N'20BIGSIZEFACTORY2' THEN N'Cửa ra vào phòng thiết bị xưởng 2'
				WHEN    DeviceID = N'21MODULEPRODUCTION' THEN N'Chuyền module'
				WHEN    DeviceID = N'22WAREHOUSEFACTORY2' THEN N'Kho thành phẩm hàng againg to và cỡ trung, cỡ nhỏ xưởng 2'
			
		ELSE ''
		END AS Location,

		CASE
		WHEN DeviceID = N'12_MIXING_FACTORY2' AND MeasureItemCode = N'Humidity' THEN MeasureValue + Convert(float, '10.46')
		WHEN DeviceID = N'10_MANUALLY_LINE_FAC' AND MeasureItemCode = N'Humidity' THEN MeasureValue + Convert(float, '9.11') 
		WHEN DeviceID = N'11_ELECTRODE_CUT_MAT' AND MeasureItemCode = N'Humidity' THEN MeasureValue + Convert(float, '10.28') 
		WHEN DeviceID = N'08_LINE4_BETWEEN_LIN' AND MeasureItemCode = N'Humidity' THEN MeasureValue + Convert(float, '7.91')
		WHEN DeviceID = N'06_LINE12_BETWEEN_LI' AND MeasureItemCode = N'Humidity' THEN MeasureValue + Convert(float, '19.1')
		WHEN DeviceID = N'05_WAREHOUSE_DOOR' AND MeasureItemCode = N'Humidity' THEN MeasureValue
		WHEN DeviceID = N'09_UTILITY_ROOM'  AND MeasureItemCode = N'Humidity'  THEN MeasureValue
	    WHEN DeviceID = N'07_LINE17_BETWEEN_LI' AND MeasureItemCode = N'Humidity' THEN MeasureValue
		WHEN DeviceID = N'13WAREHOUSEFACTORY2'  AND MeasureItemCode = N'Humidity' THEN MeasureValue
		WHEN DeviceID = N'14MANUALLINEFACTORY2' AND MeasureItemCode = N'Humidity' THEN MeasureValue

			WHEN DeviceID = N'15WAREHOUSEFACTORY1' AND MeasureItemCode = N'Humidity' THEN MeasureValue
				WHEN DeviceID = N'16OQCFACTORY1' AND MeasureItemCode = N'Humidity' THEN MeasureValue
					WHEN DeviceID = N'17LINE7' AND MeasureItemCode = N'Humidity' THEN MeasureValue
						WHEN DeviceID = N'18ELECTRODEFACTORY1' AND MeasureItemCode = N'Humidity' THEN MeasureValue
							WHEN DeviceID = N'19IQCFACTORY2' AND MeasureItemCode = N'Humidity' THEN MeasureValue
							WHEN DeviceID = N'20BIGSIZEFACTORY2' AND MeasureItemCode = N'Humidity' THEN MeasureValue
								WHEN DeviceID = N'21MODULEPRODUCTION' AND MeasureItemCode = N'Humidity' THEN MeasureValue
									WHEN DeviceID = N'22WAREHOUSEFACTORY2' AND MeasureItemCode = N'Humidity' THEN MeasureValue
							


		WHEN DeviceID = N'12_MIXING_FACTORY2' AND MeasureItemCode = N'Temperature' THEN MeasureValue - 10--Convert(float, '5.86')
		WHEN DeviceID = N'10_MANUALLY_LINE_FAC' AND MeasureItemCode = N'Temperature' THEN MeasureValue - 8--Convert(float, '6.79')
		WHEN DeviceID = N'11_ELECTRODE_CUT_MAT' AND MeasureItemCode = N'Temperature' THEN MeasureValue - 11--Convert(float, '7.42')
		WHEN DeviceID = N'08_LINE4_BETWEEN_LIN' AND MeasureItemCode = N'Temperature' THEN MeasureValue - 6--Convert(float, '7.46')
		WHEN DeviceID = N'06_LINE12_BETWEEN_LI' AND MeasureItemCode = N'Temperature' THEN MeasureValue - 9 -- Convert(float, '5.36')
		WHEN DeviceID = N'05_WAREHOUSE_DOOR' AND MeasureItemCode = N'Temperature' THEN MeasureValue
		WHEN DeviceID = N'09_UTILITY_ROOM'  AND MeasureItemCode = N'Temperature'  THEN MeasureValue - 11
	    WHEN DeviceID = N'07_LINE17_BETWEEN_LI' AND MeasureItemCode = N'Temperature' THEN MeasureValue-8
		WHEN DeviceID = N'13WAREHOUSEFACTORY2' AND MeasureItemCode = N'Temperature' THEN MeasureValue
		WHEN DeviceID = N'14MANUALLINEFACTORY2' AND MeasureItemCode = N'Temperature' THEN MeasureValue-8

			WHEN DeviceID = N'15WAREHOUSEFACTORY1' AND MeasureItemCode = N'Temperature' THEN MeasureValue-10
				WHEN DeviceID = N'16OQCFACTORY1' AND MeasureItemCode = N'Temperature' THEN MeasureValue-10
					WHEN DeviceID = N'18ELECTRODEFACTORY1' AND MeasureItemCode = N'Temperature' THEN MeasureValue-6
						WHEN DeviceID = N'19IQCFACTORY2' AND MeasureItemCode = N'Temperature' THEN MeasureValue-10
							WHEN DeviceID = N'20BIGSIZEFACTORY2' AND MeasureItemCode = N'Temperature' THEN MeasureValue-6
							WHEN DeviceID = N'21MODULEPRODUCTION' AND MeasureItemCode = N'Temperature' THEN MeasureValue-8
								WHEN DeviceID = N'22WAREHOUSEFACTORY2' AND MeasureItemCode = N'Temperature' THEN MeasureValue-11
									WHEN DeviceID = N'17LINE7' AND MeasureItemCode = N'Temperature' THEN MeasureValue-4						


		
		WHEN DeviceID = N'12_MIXING_FACTORY2' AND MeasureItemCode = N'Dewpoint' THEN MeasureValue
		WHEN DeviceID = N'10_MANUALLY_LINE_FAC' AND MeasureItemCode = N'Dewpoint' THEN MeasureValue
		WHEN DeviceID = N'11_ELECTRODE_CUT_MAT' AND MeasureItemCode = N'Dewpoint' THEN MeasureValue 
		WHEN DeviceID = N'08_LINE4_BETWEEN_LIN' AND MeasureItemCode = N'Dewpoint' THEN MeasureValue
		WHEN DeviceID = N'06_LINE12_BETWEEN_LI' AND MeasureItemCode = N'Dewpoint' THEN MeasureValue
		WHEN DeviceID = N'05_WAREHOUSE_DOOR' AND MeasureItemCode = N'Dewpoint' THEN MeasureValue
		WHEN DeviceID = N'09_UTILITY_ROOM'  AND MeasureItemCode = N'Dewpoint'  THEN MeasureValue
	    WHEN DeviceID = N'07_LINE17_BETWEEN_LI' AND MeasureItemCode = N'Dewpoint' THEN MeasureValue
		WHEN DeviceID = N'13WAREHOUSEFACTORY2' AND MeasureItemCode = N'Dewpoint' THEN MeasureValue
		WHEN DeviceID = N'14MANUALLINEFACTORY2' AND MeasureItemCode = N'Dewpoint' THEN MeasureValue

		
			WHEN DeviceID = N'15WAREHOUSEFACTORY1' AND MeasureItemCode = N'Dewpoint' THEN MeasureValue
				WHEN DeviceID = N'16OQCFACTORY1' AND MeasureItemCode = N'Dewpoint' THEN MeasureValue
					WHEN DeviceID = N'17LINE7' AND MeasureItemCode = N'Dewpoint' THEN MeasureValue
						WHEN DeviceID = N'18ELECTRODEFACTORY1' AND MeasureItemCode = N'Dewpoint' THEN MeasureValue
							WHEN DeviceID = N'19IQCFACTORY2' AND MeasureItemCode = N'Dewpoint' THEN MeasureValue
							WHEN DeviceID = N'20BIGSIZEFACTORY2' AND MeasureItemCode = N'Dewpoint' THEN MeasureValue
								WHEN DeviceID = N'21MODULEPRODUCTION' AND MeasureItemCode = N'Dewpoint' THEN MeasureValue
									WHEN DeviceID = N'22WAREHOUSEFACTORY2' AND MeasureItemCode = N'Dewpoint' THEN MeasureValue
							

		ELSE ''
		END AS MeasureValue
		

		--CASE
		--WHEN
		--		DeviceID = N'05_WAREHOUSE_DOOR' AND MeasureItemCode = N'Humidity' THEN  '11.0' 
		--WHEN
		--		DeviceID = N'05_WAREHOUSE_DOOR' AND MeasureItemCode = N'Temperature' THEN '30.5'
	 --   WHEN
		--		DeviceID = N'05_WAREHOUSE_DOOR' AND MeasureItemCode = N'Dewpoint' THEN MeasureValue


		--WHEN
		--		DeviceID = N'06_LINE12_BETWEEN_LI' AND MeasureItemCode = N'Humidity' THEN  '11.0' 
		--WHEN
		--		DeviceID = N'06_LINE12_BETWEEN_LI' AND MeasureItemCode = N'Temperature' THEN '30.5'
		-- WHEN
		--		DeviceID = N'06_LINE12_BETWEEN_LI' AND MeasureItemCode = N'Dewpoint' THEN MeasureValue


		--		WHEN
		--		DeviceID = N'07_LINE17_BETWEEN_LI' AND MeasureItemCode = N'Humidity' THEN  '7.0' 
		--WHEN
		--		DeviceID = N'07_LINE17_BETWEEN_LI' AND MeasureItemCode = N'Temperature' THEN '31.8'

		--		 WHEN
		--		DeviceID = N'07_LINE17_BETWEEN_LI' AND MeasureItemCode = N'Dewpoint' THEN MeasureValue


		-- WHEN
		--		DeviceID = N'08_LINE4_BETWEEN_LIN' AND MeasureItemCode = N'Humidity' THEN  '26.0' 
		--WHEN
		--		DeviceID = N'08_LINE4_BETWEEN_LIN' AND MeasureItemCode = N'Temperature' THEN '27.8'
		--		 WHEN
		--		DeviceID = N'08_LINE4_BETWEEN_LIN' AND MeasureItemCode = N'Dewpoint' THEN MeasureValue


		--		WHEN
		--		DeviceID = N'09_UTILITY_ROOM' AND MeasureItemCode = N'Humidity' THEN  '33.0' 
		--WHEN
		--		DeviceID = N'09_UTILITY_ROOM' AND MeasureItemCode = N'Temperature' THEN '31.7'
		--		 WHEN
		--		DeviceID = N'09_UTILITY_ROOM' AND MeasureItemCode = N'Dewpoint' THEN MeasureValue


		--		WHEN
		--		DeviceID = N'11_ELECTRODE_CUT_MAT' AND MeasureItemCode = N'Humidity' THEN  '33.0' 
		--WHEN
		--		DeviceID = N'11_ELECTRODE_CUT_MAT' AND MeasureItemCode = N'Temperature' THEN '29.0'
		--		 WHEN
		--		DeviceID = N'11_ELECTRODE_CUT_MAT' AND MeasureItemCode = N'Dewpoint' THEN MeasureValue



		--		WHEN
		--		DeviceID = N'10_MANUALLY_LINE_FAC' AND MeasureItemCode = N'Humidity' THEN  '25.0' 
		--WHEN
		--		DeviceID = N'10_MANUALLY_LINE_FAC' AND MeasureItemCode = N'Temperature' THEN '31.0'

		--		 WHEN
		--		DeviceID = N'10_MANUALLY_LINE_FAC' AND MeasureItemCode = N'Dewpoint' THEN MeasureValue



		--				WHEN
		--		DeviceID = N'12_MIXING_FACTORY2' AND MeasureItemCode = N'Humidity' THEN  '53.0' 
		--WHEN
		--		DeviceID = N'12_MIXING_FACTORY2' AND MeasureItemCode = N'Temperature' THEN '23.1'

		--		 WHEN
		--		DeviceID = N'12_MIXING_FACTORY2' AND MeasureItemCode = N'Dewpoint' THEN MeasureValue



		--		WHEN
		--		DeviceID = N'13_WAREHOUSE_FACTORY2' AND MeasureItemCode = N'Humidity' THEN  '38.0' 
		--WHEN
		--		DeviceID = N'13_WAREHOUSE_FACTORY2' AND MeasureItemCode = N'Temperature' THEN '26.7'

		--		 WHEN
		--		DeviceID = N'13_WAREHOUSE_FACTORY2' AND MeasureItemCode = N'Dewpoint' THEN MeasureValue



		--				WHEN
		--		DeviceID = N'14_MANUALLYLINE_FACT' AND MeasureItemCode = N'Humidity' THEN  '38.0' 
		--WHEN
		--		DeviceID = N'14_MANUALLYLINE_FACT' AND MeasureItemCode = N'Temperature' THEN '26.7'

		--		 WHEN
		--		DeviceID = N'14_MANUALLYLINE_FACT' AND MeasureItemCode = N'Dewpoint' THEN MeasureValue

		--ELSE ''

		--END AS MeasureValue
INTO  #newTAble1
FROM 
		STB_IoTMeasureHist WITH(NOLOCK)
		

WHERE CreateDateTime >=@FromDate and  CreateDateTime  <= @ToDate
and DeviceID in  ('05_WAREHOUSE_DOOR','06_LINE12_BETWEEN_LI' ,
'07_LINE17_BETWEEN_LI' ,
'08_LINE4_BETWEEN_LIN' ,
'09_UTILITY_ROOM'      ,
'11_ELECTRODE_CUT_MAT' ,
'10_MANUALLY_LINE_FAC' ,
'12_MIXING_FACTORY2'   ,
'13WAREHOUSEFACTORY2',
'14MANUALLINEFACTORY2',
'15WAREHOUSEFACTORY1',
'16OQCFACTORY1',
'17LINE7',
'18ELECTRODEFACTORY1',
'20BIGSIZEFACTORY2',
'19IQCFACTORY2',
'21MODULEPRODUCTION',
'22WAREHOUSEFACTORY2'
)
ORDER BY CreateDateTime DESC





select *,
case when MeasureItemCode in ( N'Dewpoint',N'Temperature') then '' else (case when MeasureItemCode = N'Humidity' and MeasureValue between 0 and 70 then 'NO' else 'YES' end) end as IsOverHumidity,
case when MeasureItemCode in ( N'Dewpoint',N'Humidity')    then '' else (case when MeasureItemCode = N'Temperature' and MeasureValue between 5 and 30 then 'NO' else 'YES' end) end as IsOverTemperature
,
case when MeasureItemCode = N'Dewpoint' then '' 
	when MeasureItemCode = N'Humidity'  then 0 
	when MeasureItemCode = N'Temperature'  then 5 end as LSL,
case when MeasureItemCode = N'Dewpoint' then '' 
	when MeasureItemCode = N'Humidity'  then 70 
	when MeasureItemCode = N'Temperature'  then 30 end as USL

from #newTAble1 ;



drop table #newTAble1 ;


END

-- SELECT * FROM STB_IoTMeasureHist WHERE DeviceID LIKE 'ELECTRODE_FACTORY1' AND CreateDateTime >= '2021-12-01' 
--ORDER BY CreateDateTime DESC 
