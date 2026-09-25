HƯỚNG DẪN XỬ LÝ HỆ THỐNG POP KHI GẶP LỖI

      PHẦN I: CÁC BẢNG CƠ BẢN TRONG MES, POP

·   STB_SetInfo (Bảng thông tin LotNo) -> Ở bảng này chú ý các cột sau: Barcode,IsProdFinish(Khi đóng gói đủ số lượng thì sẽ chuyển thành 1 còn không mặc định sẽ là 0), ProdQty, SIExtText07(Lưu thông tin mã Marking ở công đoạn bọc vỏ).

·   STB_DayProdPlan (Bảng thông tin kế hoạch ngày) -> Ở bảng này cần chú ý các cột sau: LineCode,PONo,MaterialCode,IsFixed( Phải là 1 thì mới có thể tạo được Lot)

·   STB_MaterialMater( Bảng thông tin nguyên vật liệu) -> Ở bảng này cần chú ý các cột sau: MaterialCode,MaterialName,MaterialTypeCode,ProductGroupCode(Đặc biệt quan trọng nếu muốn setting việc nguyên vật liệu theo công đoạn

·   Các bảng vè sau em sẽ tiếp tục cập nhật tiếp

      PHẦN II: CÁC LỖI THƯỜNG GẶP VÀ CÁC XỬ LÝ

1.      Khi cắt đóng gói điện cực báo lỗi như này

        Câu lệnh query để kiểm tra:

        select * from STB_SetInfo where Barcode='VVQP1420001E08' -- Lấy ra cái số DayPlanNo của mã lot để kiểm tra xem mã lot đó đang được set ở line nào

ð Vì hệ thống POP mặc định yêu cầu chọn line Cắt là ElectrodeBN với nhà máy Bắc Ninh, nên cần cập nhật lại nếu mà đang thiết lập sai.

2.      Chưa được thêm mã lỗi ứng với từng công đoạn

 

 

ð   Ở đây có 2 bảng cần quan tâm là STB_DefectInfo(Thông tin chi tiết lỗi), STB_DefectGroup(Bảng đăng kí thiết lập công đoạn lỗi)

Câu lệnh query tham khảo :

 INSERT INTO STB_DefectGroup(DefectGroupCode,BasicDefectGroupName,IsUsed,CreateUserID,CreateDateTime)

values ('V-11_HY','SLTTING',1,'HaiTrieu',GETDATE())

 

select * from STB_DefectGroup where DefectGroupCode='V-11'

select * from STB_DefectInfo where DefectGroupCode='V-11_HY'

 

INSERT INTO STB_DefectInfo (

DefectCode, BasicDefectName, DefectDesc, DefectGroupCode, UseGroup, DisplayIndex,

IsRealDefect, IsUsed, DefectImage, CreateDateTime, CreateUserID, ChangeDateTime, ChangeUserID,

DirectlyUnder, WorkCenterCode, DefectCause, DefectEnglishName

)

SELECT

REPLACE(DefectCode, 'V-11_', 'V-11_HY_'),

BasicDefectName,

DefectDesc,

'V-11_HY',

UseGroup,

DisplayIndex,

IsRealDefect,

IsUsed,

DefectImage,

GETDATE(),

'HaiTrieu',

NULL,

NULL,

DirectlyUnder,

WorkCenterCode,

DefectCause,

DefectEnglishName

FROM STB_DefectInfo

WHERE DefectGroupCode = 'V-11'

3.      Lỗi khi khi sử dụng MES rồi quay sang sử dụng POP

ð Giải thích nguyên nhân tại sao lại bị vấn đề này: Vì khi sử dụng hệ thống MES thì khi hoàn thành 1 công doạn thì trong bảng STB_ProdRouteHist sẽ mặc định sinh ra 1 dòng ở công đoạn tiếp theo và trạng thái công đoạn hoàn thành là 1 (tức cột CompleteRoute). Còn khi sử dụng hệ thống POP thì khi hoàn thành 1 công đoạn thì sẽ chỉ sinh ra 1 dòng hoàn thành công đoạn ở bảng STB_ProdRouteHist và cột CompleteRoute có trạng thái là NULL.

ð Cách xử lý vấn đề này câu lệnh query tham khảo:

select * FROM STB_ProdRouteHist WHERE ControlNo=(select ControlNo from STB_SetInfo where barcode='vvqq283r072712') AND RouteCode='V-23'

è Lấy ra cái ProdRouteHistNo cần xoá và xoá

select * from STB_ProdRouteWorkerHist where ProdRouteHistNo='2026082900006

è Găn ProdRouteHistNo láy được và xoá

4.      Lỗi không thể nhập được 2 mã cắt điện cực từ 2 Lot trở lên

ð Hiện tại đang cấu hình chỉ cho phép nhập tối đa 1 mã cắt vào 2 LOTNO. Trong tương lai sẽ yêu cầu cho nhạp tối đa 1 mã cắt có thể nhập được vào 3 LOTNO.

5.      Không thể đóng gói được khi đang báo không có kho

ð Để giải quyết vấn đề này thì vào hệ thống MES vào màn B230 thiết lập việc gắn công đoạn cho CellLine là được.

Tham khảo việc thiết lập ở line Thủ công TX1

6.      Ở hạng mục tự kiệm thì hạng mục kiểm tra thiết lập đang nhầm công đoạn

ð Cách xử lý: Đầu tiên phải vào C141 để cập nhật lại công đoạn

 => Thứ hai sau khi cập nhật xong thì sẽ chạy câu lệnh Query sau:

SELECT DH.CommInspDocNo, DI.CommInspDocItemNo, DI.CommInspItemCode, DI.RouteCode, DI.ItemTargetQty, DI.ItemQty FROM STB_CommInspDocHistory DH WITH(NOLOCK) INNER JOIN STB_SetInfo SI WITH(NOLOCK) ON SI.ControlNo = DH.ProdNo INNER JOIN STB_CommInspDocItem DI WITH(NOLOCK) ON DI.CommInspDocNo = DH.CommInspDocNo WHERE SI.Barcode = 'VVQR163R825713' AND DI.CommInspItemCode in ('V_H1_HY','V_H2_HY','V_WA_HY') UPDATE DI SET DI.RouteCode = 'V-24_HY' FROM STB_CommInspDocItem DI INNER JOIN STB_CommInspDocHistory DH ON DH.CommInspDocNo = DI.CommInspDocNo INNER JOIN STB_SetInfo SI ON SI.ControlNo = DH.ProdNo WHERE SI.Barcode = 'VVQR163R825713' AND DI.CommInspItemCode IN ('V_H1_HY', 'V_H2_HY', 'V_WA_HY') => Dùng khi thiết lập lại hạng mục kiểm tra sai công đoạn

7.      Lỗi báo hết tồn kho nguyên vật liệu

 

ð Ở đây có rất nhiều trường hợp có thể xảy ra:

TH1: Nếu có nguyên vật liệu thay thế thì có thể ấn icon để thay đổi luôn

TH2: Nếu con hàng đó được sản xuất ở cả Bắc Ninh, Hưng Yên thì sẽ tiến hành đổi kho

TH3: Nếu không thoả mãi hết hai điều kiện trên thì sẽ vào bảng STB_MaterialLotInfo để kiểm tra

Câu lệnh query: select * from STB_MaterialLotInfo where lotid='ML20260331000035'

Ở câu lệnh này chú ý 2 cột là InitialQty,CurrentQty => Nếu CurrentQty là 0 thì sẽ là không có tồn kho=> Ở đây nếu mà là 0 thì phải cập nhật lại hoặc phải vào MES xem lại đoạn code xuất NVL trên F430

8.      Tìm kiếm tồn kho điện cực nếu không quét được mã điện cực

Note: Hiện tại chỉ cho phép 1 mã cắt điện cực cho phép nhập tối đã 3 mã LOT

 

ð Đây là quy trình tìm kiếm tồn kho điện cực nếu không thể quét mã điện cực

 

9.      Tạo cưỡng chế tồn kho điện cực với các mã hàng chưa được đăng kí tồn kho

/* 1=====================================================================

   STEP 0) 대상 식별 — 라벨이 안 읽히므로 베이스 전극 LOT로 실적 롤 전체를 나열.

 베이스 LOT 확보 경로: 롤 라벨 잔존부 / 작업지시·불출 전표 / 같은 파렛 이웃 롤 라벨.

 소거법: AlreadyInMLI='Y'(이미 재고) 또는 InputHist='Y'(이미 투입) 제외 → 남는 롤이

 훼손 롤 후보. 폭·두께·길이를 현물 실측과 대조해 최종 확정.

   ===================================================================== */

DECLARE @baseLot varchar(50) = 'VWQO2720001E03';   -- ★베이스 전극 LOT (롤 바코드 = {베이스LOT}-{Seq})

 

SELECT ESR.Barcode, ESR.Seq,

   ESR.SlittingWidth  AS WidthMm,    /* 폭   — 실적 */

   ESR.ElectrodeThick AS ThickUm,    /* 두께 — 실적 */

   ESR.GoodQtyLength  AS LengthM,    /* 길이 — 실적 = 재고 수량 */

   DPP.MaterialCode AS BaseCoatingCode, RTRIM(ISNULL(BaseMM.PlusMinus,'')) AS BasePM,

   ESR.SlittingMaterialCode, RTRIM(ISNULL(SlitMM.PlusMinus,'')) AS SlitPM,

   /* 극성 정합 자재코드 — 스캔 경로 getSlittingResultForStock와 동일 규칙 */

   CASE WHEN SlitMM.MaterialCode IS NOT NULL

             AND NULLIF(RTRIM(SlitMM.PlusMinus),'') = NULLIF(RTRIM(BaseMM.PlusMinus),'')

        THEN ESR.SlittingMaterialCode ELSE DPP.MaterialCode END AS ResolvedMaterialCode,

   CASE WHEN EXISTS (SELECT 1 FROM STB_MaterialLotInfo M2 WITH(NOLOCK)

                     WHERE M2.LotID = ESR.Barcode) THEN 'Y' ELSE 'N' END AS AlreadyInMLI,

   CASE WHEN EXISTS (SELECT 1 FROM STB_RawMaterialInputHist H WITH(NOLOCK)

                     WHERE H.RawMaterialInputHistNo >= CONVERT(varchar(8), DATEADD(MONTH, -3, GETDATE()), 112) + '000000'

                       AND H.Status = 'ACTIVE'

                       AND (H.LotMaterialCode = ESR.Barcode

                            OR (H.InputType = 'MES' AND H.RawMaterialBarcode LIKE '%' + ESR.Barcode + '%')))

        THEN 'Y' ELSE 'N' END AS InputHist

FROM STB_ElectrodeSlittingResult ESR WITH(NOLOCK)

INNER JOIN STB_SetInfo SI WITH(NOLOCK)    ON SI.Barcode = ESR.ElectrodeLotNumber

INNER JOIN STB_DayProdPlan DPP WITH(NOLOCK)   ON DPP.DayPlanNo = SI.DayPlanNo

LEFT  JOIN STB_MaterialMaster BaseMM WITH(NOLOCK) ON BaseMM.MaterialCode = DPP.MaterialCode

LEFT  JOIN STB_MaterialMaster SlitMM WITH(NOLOCK) ON SlitMM.MaterialCode = ESR.SlittingMaterialCode

WHERE ESR.ElectrodeLotNumber = @baseLot

  AND ESR.CompanyCode = 'VVT'

ORDER BY ESR.Seq;

 

 

/* =====================================================================

   STEP 1) 강제 등록 — STEP 0에서 특정한 바코드로 실행.

 해석·INSERT 전부 스캔 온디맨드(getSlittingResultForStock → insertOnDemandRollLot)와 동일.

 길이=실적 GoodQtyLength 그대로 — 수기 보정 없음. 실적 길이가 0/NULL이면 중단

 (스캔 경로 NO_LENGTH와 동일 정책 — 실적 정정이 선행).

   ===================================================================== */

DECLARE @rollBarcode   varchar(50) = 'VWQO2720001E03-001';  -- ★STEP 0에서 특정한 롤 바코드

DECLARE @warehouseCode varchar(20) = 'ROUTE_VN_WH';     -- 투입 화면 창고 (기본 ROUTE_VN_WH)

 

BEGIN TRAN;

 

/* --- 실적 1건 해석 — getSlittingResultForStock 동일 (TransferDateTime IS NULL 포함) --- */

DECLARE @matCode varchar(50), @lengthM numeric(13,3), @electrodeLot varchar(50), @wcCode varchar(20);

SELECT TOP 1

@matCode = CASE WHEN SlitMM.MaterialCode IS NOT NULL

                     AND NULLIF(RTRIM(SlitMM.PlusMinus),'') = NULLIF(RTRIM(BaseMM.PlusMinus),'')

                THEN ESR.SlittingMaterialCode ELSE DPP.MaterialCode END,

@lengthM = ISNULL(ESR.GoodQtyLength, 0),

@electrodeLot = ESR.ElectrodeLotNumber,

@wcCode = ISNULL(W.WorkCenterCode, 'VVT_F1')

FROM STB_ElectrodeSlittingResult ESR WITH(NOLOCK)

INNER JOIN STB_SetInfo SI WITH(NOLOCK)    ON SI.Barcode = ESR.ElectrodeLotNumber

INNER JOIN STB_DayProdPlan DPP WITH(NOLOCK)   ON DPP.DayPlanNo = SI.DayPlanNo

LEFT  JOIN STB_MaterialMaster BaseMM WITH(NOLOCK) ON BaseMM.MaterialCode = DPP.MaterialCode

LEFT  JOIN STB_MaterialMaster SlitMM WITH(NOLOCK) ON SlitMM.MaterialCode = ESR.SlittingMaterialCode

LEFT  JOIN STB_MaterialWarehouse W WITH(NOLOCK)   ON W.MaterialWarehouseCode = @warehouseCode AND W.CompanyCode = 'VVT'

WHERE ESR.Barcode = @rollBarcode

  AND ESR.CompanyCode = 'VVT'

  AND ESR.TransferDateTime IS NULL

ORDER BY ESR.Seq DESC;

 

/* --- 안전 가드 (스캔 경로 판정과 동일 정책) --- */

IF @matCode IS NULL

BEGIN RAISERROR('슬리팅 실적(ESR) 없음 — 등록 불가. 실적 확인/등록이 선행돼야 함', 16, 1); ROLLBACK; RETURN; END

IF ISNULL(@lengthM, 0) <= 0

BEGIN RAISERROR('실적 길이 0/NULL — 등록 불가(NO_LENGTH). ESR.GoodQtyLength 실적 정정 선행', 16, 1); ROLLBACK; RETURN; END

IF EXISTS (SELECT 1 FROM STB_MaterialLotInfo WITH(NOLOCK) WHERE LotID = @rollBarcode)

BEGIN RAISERROR('이미 MLI 재고 존재 — 중단 (소진 롤이면 화면 재장착 재활성 경로 사용)', 16, 1); ROLLBACK; RETURN; END

 

/* --- 채번: STB_SerialRule 예약 (createSerialBatch 재현, 1건 — MAX+1 금지) --- */

DECLARE @curDate varchar(8) = CONVERT(varchar(8), GETDATE(), 112);

DECLARE @prefix varchar(12), @serialLen int, @lastNo int, @lastPrefix varchar(12);

 

SELECT @prefix = REPLACE(REPLACE(REPLACE(REPLACE(PrefixData,

    'YYYY', SUBSTRING(@curDate,1,4)), 'YY', SUBSTRING(@curDate,3,2)),

    'MM', SUBSTRING(@curDate,5,2)), 'DD', SUBSTRING(@curDate,7,2)),

   @serialLen = SerialLen, @lastNo = LastSerialNo, @lastPrefix = ISNULL(LastPrefixData, '')

FROM SmartFramework.dbo.STB_SerialRule WITH(ROWLOCK, UPDLOCK)

WHERE TableName = 'STB_MaterialLotInfo';

 

IF @prefix IS NULL BEGIN RAISERROR('STB_SerialRule 행 없음 — 중단', 16, 1); ROLLBACK; RETURN; END

 

IF @prefix != @lastPrefix

BEGIN

UPDATE SmartFramework.dbo.STB_SerialRule

SET LastPrefixData = @prefix, LastSerialNo = 1

WHERE TableName = 'STB_MaterialLotInfo';

SET @lastNo = 0;

END

ELSE

BEGIN

UPDATE SmartFramework.dbo.STB_SerialRule

SET LastSerialNo = LastSerialNo + 1

WHERE TableName = 'STB_MaterialLotInfo';

END

 

DECLARE @materialLotNo varchar(20) =

@prefix + RIGHT(REPLICATE('0', @serialLen) + CAST(@lastNo + 1 AS varchar(10)), @serialLen);

 

/* --- INSERT — insertOnDemandRollLot(=슬리팅 insertSlittingRollLots 구성) 그대로 ---

   LotAttr01='SLITTING'(전극롤 지문) / StockAttrib2·3=''(트리거 MERGE NULL≠'' 함정)

   IsSlitting=1 / LengthSlitting=실적 길이 / LotID=롤바코드 / LotNo=베이스LOT */

INSERT INTO STB_MaterialLotInfo (

MaterialLotNo, LotID, CompanyCode, WorkCenterCode,

MaterialWarehouseCode, MaterialLocationCode, MaterialCode, MaterialStockAttribute,

StockAttrib2, StockAttrib3,

GRDate, InitialQty, CurrentQty, PickingQty,

LotNo, IsSplitLot, LotAttr01,

IsSlitting, LengthSlitting,

CreateDateTime, CreateUserID

)

VALUES (

@materialLotNo, @rollBarcode, 'VVT', @wcCode,

@warehouseCode, '', @matCode, 'NORMAL',

'', '',

CONVERT(VARCHAR(10), GETDATE(), 23), @lengthM, @lengthM, 0,

@electrodeLot, 0, 'SLITTING',

1, @lengthM,

GETDATE(), 'POP_SLIT_STOCK'

);

 

/* =====================================================================

   STEP 2) 검증 — ModalVisible='Y'여야 수동 검색 모달에 노출됨

 (getRollStockList 필터 재현: VVT + IsSlitting=1 + LotAttr01='SLITTING'

  + CurrentQty>0 + 창고 일치 + 마스터 극성 존재)

 폭·두께·길이는 ESR 조인으로 실적값 그대로 확인.

   ===================================================================== */

SELECT MLI.MaterialLotNo, MLI.LotID, MLI.LotNo, MLI.MaterialCode,

   MLI.CurrentQty, MLI.LengthSlitting, MLI.MaterialWarehouseCode,

   ESR.SlittingWidth AS WidthMm, ESR.ElectrodeThick AS ThickUm, ESR.GoodQtyLength AS LengthM,

       RTRIM(ISNULL(MM.PlusMinus,'')) AS Polarity,

   CASE WHEN MLI.CompanyCode = 'VVT' AND MLI.IsSlitting = 1

             AND RTRIM(ISNULL(MLI.LotAttr01,'')) = 'SLITTING'

             AND MLI.CurrentQty > 0

             AND MLI.MaterialWarehouseCode = @warehouseCode

             AND NULLIF(RTRIM(ISNULL(MM.PlusMinus,'')), '') IS NOT NULL

        THEN 'Y' ELSE 'N' END AS ModalVisible

FROM STB_MaterialLotInfo MLI WITH(NOLOCK)

LEFT JOIN STB_MaterialMaster MM WITH(NOLOCK) ON MM.MaterialCode = MLI.MaterialCode

LEFT JOIN STB_ElectrodeSlittingResult ESR WITH(NOLOCK) ON ESR.Barcode = MLI.LotID

WHERE MLI.LotID = @rollBarcode;

 

COMMIT;   -- 이상 시 ROLLBACK

ð Ở đây sao khi tạo cưỡng chế tồn kho điên cực xong chỉ cần báo lại là người dung tìm kiếm lại theo đúng vấn đề số 8.

TH2: Nếu mà đã tạo điện cưỡng chế mã cắt điện cực rồi mà tìm kiếm người dùng vẫn báo không có thì hãy quay lại kiểm tra xem mã điện cực tạo cưỡng chế đó là điện cực âm hay điện cực dương

Câu lệnh Query để kiểm tra:

SELECT MaterailCode from STB_SetInfo where Barcode=’’

SELECT MaterialName from STB_MaterialMaster where MaterialCode=’’

ð Tại sao cần phải lấy ra tên vì ở đây sẽ có (+) hay (-) vì khi tìm kiếm tồn kho diện cực có phân biệt mã điện cực âm hay điện cực dương

10.                             Hướng dẫn thiết lập Nguyên vật liệu theo từng CellLine

Cái này thì cần phải sử dụng DATABASE VINATECH_POP

SELECT * FROM VINA_ASSEMBLY_GROUP_MODE

ORDER BY LINE_CODE

SELECT

LINE_CODE, SLOT_CODE, SLOT_NAME, ROUTE_CODE,

   IS_REQUIRED, DISPLAY_ORDER

FROM VINA_GROUP_INPUT_ROUTE

ORDER BY LINE_CODE, DISPLAY_ORDER

SELECT * FROM VINA_GROUP_INPUT_ROUTE

WHERE LINE_CODE = 'VVHYC-13'

ORDER BY DISPLAY_ORDER

Mapping theo group về cơ bản sẽ tuân theo tiêu chuẩn nhóm mặt hàng được thiết lập trong BOM anh ạ. Là ProductGroupCode trong bảng STB_MaterialMaster.

        

Các bước thiết lập trên giao điện

Lưu ý chỉ ai có tài khoản admin mới có thể vào được

             => Nhập tên CellLine muốn thiết lập nguyên vật liệu

Đoạn này như trên em có giải thích sẽ dưa vào BOM và dựa vào ProductGroupCode trong bảng STB_MaterialMater

11.  Huỷ đóng gói và huỷ hoàn thành công đoạn(tức là RollBack lại dữ liệu)

ð Hiện tại chỉ có tài khoản của em và a Kim có quyền huỷ đóng gói và huỷ hoàn thành kết quả sản xuất. Cài này cần được phân quyền.

ð Cái này sau Anh Nha chỉ định 1 bạn nữa thì em sẽ đào tạo riêng ạ.

12.              Nguyên vật liệu thay thế

Ví Nguyên vật liệu trong BOM thường sẽ 1 nguyên vật liệu thay thế,có thể là 1, or 2, or nhiều cái này phụ thuộc vào Code nhà cung cấp cách xử lý vấn đề ở đây

 

 

 

ð Lấy ra nguyên vật liệu thay thế, Như ở trên ảnh BOM đang thừa NVL thì có thể xoá ở trong BOM và thiết lập NVL thay thế với 1 trong hai để có thể chuyển đổi.

ð Hoặc là thêm NVL thay thế nữa ở DelegateMaterialCode1, DelegateMaterialCode2….

13.              Lỗi khi ấn sang chế độ nhập lượng hoàn thành

   Nếu người dung ấn vào dấu (+) ở bên nhập lỗi sẽ chuyển sang nhập số lượng hoàn thành thì sau khi ấn hoàn thành sản xuất sẽ bị lỗi. => Các xử lý là RollBack lại cho nhập lại và chuyển sang dâu (-)

14.              Lỗi công đoạn hoàn thành trên MES rồi và tự sinh một công đoạn mà trên POP chưa chốt đã nhảy sang công đoạn tiếp theo

ð Cách xử lý là sẽ Rollback về công đoạn chưa nhập trên POP để tiến hành nhâp

15.              Lỗi chưa lưu độ Nhớt ở công đoạn Trộn

ð Cấu query để kiểm tra, cái lỗi này là người dung chưa lưu.

16.              Lỗi sửa tên máy

Cách kiểm tra và update:

 

select * from STB_ProdRouteHist where ControlNo=(select ControlNo from STB_SetInfo where Barcode='VVQR193R072730')

--VVMHY136 -> VVMHY130

select * from MongoToMesPerformance where Barcode='VVQR193R072730' and RouteCode='V-22_HY'

 

--Winding C#10-01(VVMHY143)

  --(VVMHY21) -> Winding C#1-01)

 

  UPDATE STB_ProdRouteHist

  SET MachineCode='VVMHY130'

  where ControlNo=(select ControlNo from STB_SetInfo where Barcode='VVQR193R072730') and RouteCode='V-22_HY'

 

 

  UPDATE MongoToMesPerformance

   SET MachineCode='VVMHY130'

  where Barcode='VVQR193R072730' and RouteCode='V-22_HY'

 

Lưu ý: Có thể vào màn hình B270 để check Mã máy (MachineCode) theo Tên máy (MachineName) mà người dùng cung cấp

17.              Nút Button Cắt điện cực không thể sáng để tiến hành cắt

ð Hiện tại hệ thống đang giới hạn viẹc chặn nếu độ dày điện cực <100 thì sẽ không cho cắt điện cực

ð Cấu lệnh Query tham khảo để lấy độ dày:

select * from STB_SetInfo where Barcode='VWQQ2609501E13'

--CRPSC5-005

SELECT MaterialCode, MaterialName, MaterialThickness, MaterialTypeCode

FROM STB_MaterialMaster

WHERE MaterialCode = 'CRPSC5-005'

 

 

 