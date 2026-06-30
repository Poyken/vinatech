# KB_02 - Kho WMS Core (NVL & ThÃ nh Pháº©m)

> **MÃ n hÃ¬nh:** F330, F312, F430, F110, F710, F721, F741, C220, HN551, HN866, HN544, FG00
> **Báº£ng chÃ­nh:** `STB_MaterialLotInfo`, `STB_MaterialDocInfo`, `STB_MaterialStock`, `STB_MaterialWarehouse`
> **ðŸ”‘ Keywords:** kho, warehouse, tá»“n kho, nháº­p kho, xuáº¥t kho, FIFO, holding, háº¿t háº¡n, lot, NVL, nguyÃªn váº­t liá»‡u, phiáº¿u nháº­p, phiáº¿u xuáº¥t, chuyá»ƒn kho
> â† [Vá» INDEX](KB_INDEX.md)

---

## 4. ðŸ“¦ Kho NguyÃªn Váº­t Liá»‡u (WMS)

> ðŸ­ **CÆ¡ sá»Ÿ gá»‘c:** VVT_F1 (Báº¯c Ninh) â€” F-series chuáº©n dÃ¹ng chung táº¥t cáº£ cÆ¡ sá»Ÿ
> ðŸ”€ **Biáº¿n thá»ƒ:** HN (HÃ  Nam): HN551/HN866 (kho TP), HN20-HN23 (kho R&D), HN544 (gá»™p tÃºi bÃ³ng) | BG2: K181 (log á»§y quyá»n NVL) â†’ [KB_03 Â§6.14](../KB_03/KB_03_02_CELL_LINE.md#614-nhÃ -mÃ¡y-bg2--cáº¥u-hÃ¬nh-triá»ƒn-khai-há»‡-thá»‘ng-mes)

### 4.0 SÆ¡ Äá»“ Quy TrÃ¬nh Tá»•ng Quan (KHO & IQC -> Sáº¢N XUáº¤T -> PQC & OQC)

> SÆ¡ Ä‘á»“ dÆ°á»›i Ä‘Ã¢y thá»ƒ hiá»‡n luá»“ng quy trÃ¬nh chÃ­nh xuyÃªn suá»‘t 3 khu vá»±c: **Kho & IQC**, **Sáº£n xuáº¥t**, **PQC & OQC**. Má»—i bÆ°á»›c gáº¯n vá»›i Screen ID tÆ°Æ¡ng á»©ng trÃªn há»‡ thá»‘ng MES.

```mermaid
flowchart TD
    subgraph KHO_IQC ["ðŸ“¦ KHO & IQC"]
        direction TB
        K1["F312 - Táº¡o PO vÃ  chi tiáº¿t PO"]
        K2["C220 - IQC kiá»ƒm tra hÃ ng hÃ³a Ä‘áº§u vÃ o"]
        K3["F110 - XÃ¡c nháº­n nháº­p kho"]
        K4["F330 - CÆ° trÃº/Thiáº¿t láº­p cÃ¡c Lot kho"]
        K5["F741 - TÃ¡ch Lot theo sá»‘ lÆ°á»£ng mong muá»‘n"]
        K6["F721 - Kiá»ƒm tra tá»“n kho vÃ  Link vá»‹ trÃ­"]
        K7["F430 - Xuáº¥t hÃ ng vÃ  kiá»ƒm tra lá»‹ch sá»­"]
        K1 --> K2 --> K3 --> K4 --> K5 --> K6 --> K7
    end

    subgraph SAN_XUAT ["âš¡ Sáº¢N XUáº¤T"]
        direction TB
        S1["B310 - Táº¡o PO káº¿ hoáº¡ch thÃ¡ng"]
        S2["K101/B450 - Táº¡o káº¿ hoáº¡ch ngÃ y vÃ  táº¡o Lot"]
        S3["B597 - Nháº­p pháº¿ cÃ´ng Ä‘oáº¡n, kiá»ƒm tra Lot/NVL"]
        S4["B530 - Nháº­p SL/HoÃ n thÃ nh cÃ´ng Ä‘oáº¡n"]
        S5["K110/B597 - Nháº­p NVL, háº¡ng má»¥c kiá»ƒm tra trÃªn cÃ´ng Ä‘oáº¡n"]
        S6["B782 - Kiá»ƒm tra sáº£n lÆ°á»£ng theo cÃ´ng Ä‘oáº¡n"]
        S7["B523 - ÄÃ³ng gÃ³i"]
        S8["B781 - Lá»‹ch sá»­ lÆ°u packing"]
        S9["B598 - BÃ¡o pháº¿"]
        S1 --> S2 --> S3 --> S4 --> S5 --> S6 --> S7 --> S8 --> S9
    end

    subgraph PQC_OQC ["ðŸ”¬ PQC & OQC"]
        direction TB
        Q1["C131 - ÄÄƒng kÃ½ thÃ´ng tin nhÃ³m láº§n"]
        Q2["C132 - Cáº¥u hÃ¬nh láº§n chi tiáº¿t"]
        Q3["C141 - Thiáº¿t láº­p thÃ´ng sá»‘ kiá»ƒm tra chung"]
        Q4["C143 - Thiáº¿t láº­p spec riÃªng cho tá»«ng model"]
        Q5["C443 - Kiá»ƒm tra PQC"]
        Q6["C430 - Lá»‹ch sá»­ kiá»ƒm tra cÃ´ng Ä‘oáº¡n má»—i cell line"]
        Q7["C321 - ThÃ´ng tin pháº¿ cÃ´ng Ä‘oáº¡n trÃªn cell line"]
        Q8["C451 - Táº¡o Lot kiá»ƒm tra OQC"]
        Q9["C560 - Máº«u kiá»ƒm tra OQC"]
        Q10["C540 - Lá»‹ch sá»­ kiá»ƒm tra OQC"]
        Q1 --> Q2 --> Q3 --> Q4 --> Q5 --> Q6 --> Q7
        Q5 -.-> Q8 --> Q9 --> Q10
    end

    K7 -->|"NVL sáºµn sÃ ng"| S2
    S4 -->|"Káº¿t quáº£ SX"| Q5
    S7 -->|"ThÃ nh pháº©m Ä‘Ã³ng gÃ³i"| Q8
```

**Giáº£i thÃ­ch liÃªn káº¿t giá»¯a 3 khu vá»±c:**
- **KHO -> Sáº¢N XUáº¤T:** Sau khi NVL qua IQC (C220) vÃ  nháº­p kho (F330), NVL sáºµn sÃ ng cáº¥p cho sáº£n xuáº¥t qua F430
- **Sáº¢N XUáº¤T -> PQC:** Káº¿t quáº£ sáº£n xuáº¥t táº¡i B530 Ä‘Æ°á»£c kiá»ƒm tra PQC táº¡i C443
- **Sáº¢N XUáº¤T -> OQC:** Sau Ä‘Ã³ng gÃ³i (B523), thÃ nh pháº©m chuyá»ƒn sang OQC Ä‘á»ƒ táº¡o Lot kiá»ƒm tra (C451)
- **ÄÃ³ng gÃ³i (B523):** Bá»™ chuyá»ƒn thÃ´ng tin Lot vÃ  sá»‘ lÆ°á»£ng sang báº£ng `STB_MaterialLotInfo` Ä‘á»ƒ quáº£n lÃ½ vÃ  sá»­ dá»¥ng

---

### 4.1 TÃ¬m kiáº¿m F721 tráº£ vá» cáº£ danh sÃ¡ch (khÃ´ng lá»c Ä‘Æ°á»£c)

**NguyÃªn nhÃ¢n:** Äiá»u kiá»‡n lá»c trong SP bá»‹ sai hoáº·c tham sá»‘ truyá»n vÃ o rá»—ng.

**Debug:**
```sql
SELECT OBJECT_DEFINITION(OBJECT_ID('usp_vvt_MaterialLotInfo_get'))
-- TÃ¬m Ä‘áº¿n pháº§n WHERE -> Kiá»ƒm tra Ä‘iá»u kiá»‡n lá»c theo MaterialCode
```

> âš ï¸ **LÆ°u Ã½ áº©n:** SP `usp_vvt_MaterialLotInfo_get` (tÃªn "_get") thá»±c táº¿ **UPDATE 2 báº£ng** má»—i khi cháº¡y - tá»± Ä‘á»™ng Ä‘iá»n `LotAttr10` cho cÃ¡c Lot bá»‹ thiáº¿u ngÃ y SX báº±ng cÃ¡ch parse mÃ£ Vendor Lot. KhÃ´ng cÃ³ transaction báº£o vá»‡ pháº§n UPDATE nÃ y.

---

### 4.2 KhÃ´ng tÃ¬m tháº¥y mÃ£ lot á»Ÿ mÃ n C512

ðŸ‘‰ **Chi tiáº¿t NguyÃªn nhÃ¢n & CÃ¡ch xá»­ lÃ½:** Xem táº¡i [../KB_05/KB_05_01_QC_OVERVIEW.md Â§ 7.2](../KB_05/KB_05_01_QC_OVERVIEW.md)

---

### 4.3 Chá»‰nh láº¡i Kho bá»‹ nháº­p sai á»Ÿ mÃ n F330

**Triá»‡u chá»©ng:** HÃ ng nháº­p vÃ o Ä‘Ãºng nhÆ°ng kho bá»‹ chá»n sai (VD: nháº­p vÃ o kho BG nhÆ°ng láº½ ra pháº£i vÃ o kho BN).

> âš ï¸ Pháº£i UPDATE Ä‘á»“ng thá»i **3 báº£ng**: `STB_MaterialDocInfo`, `STB_MaterialDocLotInfo`, `STB_MaterialLotInfo`. Thiáº¿u báº£ng nÃ o sáº½ gÃ¢y lá»‡ch dá»¯ liá»‡u.

```sql
-- BÆ°á»›c 1: XÃ¡c Ä‘á»‹nh MaterialDocNo
SELECT * FROM STB_MaterialDocInfo WHERE MaterialDocNo = '250221000220'

-- BÆ°á»›c 2: Sá»­a header phiáº¿u
UPDATE STB_MaterialDocInfo
SET TargetMaterialWarehouseCode = 'ROH_HN_WH'
WHERE MaterialDocNo = '250221000220'

-- BÆ°á»›c 3: TÃ¬m cÃ¡c LotID trong phiáº¿u
SELECT LotID, MaterialLocationCode FROM STB_MaterialDocLotInfo
WHERE MaterialDocNo = '250221000220'

-- BÆ°á»›c 4: Update vá»‹ trÃ­ trong phiáº¿u
UPDATE STB_MaterialDocLotInfo
SET MaterialLocationCode = 'ROH_HN_WH_01'
WHERE LotID IN ('LotID1', 'LotID2', ...)

-- BÆ°á»›c 5: Update tá»“n kho thá»±c táº¿
UPDATE STB_MaterialLotInfo
SET MaterialWarehouseCode = 'ROH_HN_WH',
    MaterialLocationCode = 'ROH_HN_WH_01'
WHERE LotID IN ('LotID1', 'LotID2', ...)
```

**MÃ£ kho hay dÃ¹ng:**

| NhÃ  mÃ¡y | WarehouseCode | LocationCode |
|---------|--------------|-------------|
| Báº¯c Giang | `ROH_BG_WH` | `ROH_BG_WH_01` |
| HÃ  Nam | `ROH_HN_WH` | `ROH_HN_WH_01` |
| Báº¯c Ninh (VVT) | `ROH_VN_WH` | `ROH_VN_WH_01` |

---

### 4.4 Chá»‰nh Code NVL nháº­p sai á»Ÿ mÃ n F312

**Triá»‡u chá»©ng:** Nháº­p nháº§m mÃ£ NVL khi lÃ m phiáº¿u nháº­p kho F312.

```sql
-- Sá»­a Ä‘á»“ng bá»™ 3 báº£ng (Ä‘áº§y Ä‘á»§, bao gá»“m tá»“n kho thá»±c táº¿)
-- BÆ°á»›c 1: Xem phiáº¿u hiá»‡n táº¡i
SELECT * FROM STB_MaterialDocDetail WHERE MaterialDocNo = '250806000399'
SELECT * FROM STB_MaterialDocLotInfo WHERE MaterialDocNo = '250806000399'

-- BÆ°á»›c 2: Sá»­a mÃ£ NVL trong Detail
UPDATE STB_MaterialDocDetail
SET MaterialCode = 'MÃƒ_ÄÃšNG'
WHERE MaterialDocNo = '250806000399' AND MaterialCode = 'MÃƒ_SAI'

-- BÆ°á»›c 3: Sá»­a mÃ£ NVL trong LotInfo
UPDATE STB_MaterialDocLotInfo
SET MaterialCode = 'MÃƒ_ÄÃšNG'
WHERE MaterialDocNo = '250806000399' AND MaterialCode = 'MÃƒ_SAI'

-- BÆ°á»›c 4: Sá»­a tá»“n kho thá»±c táº¿
UPDATE STB_MaterialLotInfo
SET MaterialCode = 'MÃƒ_ÄÃšNG'
WHERE LotID IN (
    SELECT LotID FROM STB_MaterialDocLotInfo WHERE MaterialDocNo = '250806000399'
)
```

---

### 4.5 Sá»­a sá»‘ lÆ°á»£ng mÃ n F312

**Triá»‡u chá»©ng:** Sá»‘ lÆ°á»£ng phiáº¿u nháº­p bá»‹ sai.

```sql
-- Xem sá»‘ lÆ°á»£ng hiá»‡n táº¡i
SELECT * FROM STB_MaterialDocDetail
WHERE MaterialDocNo = '250213000154' AND MaterialCode = '122507G1PT0'

-- Sá»­a táº¥t cáº£ cÃ¡c cá»™t sá»‘ lÆ°á»£ng
UPDATE STB_MaterialDocDetail
SET RequestQty = 200000, AllowQty = 200000, PickingAssignQty = 200000
WHERE MaterialDocNo = '250213000154' AND MaterialCode = '122507G1PT0'
```

---

### 4.6 Sá»­a ngÃ y xuáº¥t kho mÃ n F430

**Triá»‡u chá»©ng:** HÃ ng xuáº¥t kho bá»‹ ghi nháº­n sai ngÃ y.

```sql
-- TÃ¬m báº£n ghi cáº§n sá»­a
SELECT * FROM STB_MaterialWarehouseInOutHist
WHERE LotID IN ('ML20250620000036', 'ML20250520000061')

-- Sá»­a ngÃ y (giá»¯ nguyÃªn giá» phÃºt giÃ¢y)
UPDATE STB_MaterialWarehouseInOutHist
SET CreateDateTime = CAST('2025-06-30' AS DATETIME) + CAST(CreateDateTime AS TIME)
WHERE LotID IN ('ML20250620000036', 'ML20250520000061')
```

---

### 4.7 Chuyá»ƒn Lot tá»« kho Holding ra kho chÃ­nh

> **MÃ£ HOLDING thá»±c táº¿ (xÃ¡c minh DB 2026-05-17):** `HOLDING_VN_WH` (Báº¯c Ninh), `HOLDING_BG_WH` (Báº¯c Giang), `HOLDING_HN_WH` (HÃ  Nam).

```sql
-- BÆ°á»›c 1: Xem tráº¡ng thÃ¡i Lot hiá»‡n táº¡i
SELECT LotID, MaterialWarehouseCode, MaterialLocationCode
FROM STB_MaterialLotInfo WHERE LotID = 'ML20250430000174'

-- BÆ°á»›c 2: Cáº­p nháº­t lá»‹ch sá»­ xuáº¥t nháº­p (náº¿u cÃ³)
UPDATE STB_MaterialWarehouseInOutHist
SET TargetMaterialWarehouseCode = 'ROH_VN_WH'
WHERE LotID = 'ML20250430000174'

-- BÆ°á»›c 3: Cáº­p nháº­t tá»“n kho
UPDATE STB_MaterialLotInfo
SET MaterialWarehouseCode = 'ROH_VN_WH',
    MaterialLocationCode = 'ROH_VN_WH_01'
WHERE LotID = 'ML20250430000174'
```

---

### 4.8 Sá»­a Location váº­t tÆ° (F721 - Thuá»™c tÃ­nh LotAttr09)

```sql
-- Xem location hiá»‡n táº¡i
SELECT LotID, LotAttr09 AS [Location], MaterialLocationCode
FROM STB_MaterialDocLotInfo WHERE LotID = 'ML...'

-- Sá»­a location (pháº£i sá»­a cáº£ 2 báº£ng)
UPDATE STB_MaterialDocLotInfo SET LotAttr09 = 'Vá»‹_TrÃ­_Má»›i' WHERE LotID = 'ML...'
UPDATE STB_MaterialLotInfo SET MaterialLocationCode = 'Vá»‹_TrÃ­_Má»›i' WHERE LotID = 'ML...'
```
> **Xem vá»‹ trÃ­ trá»±c quan:** `192.168.1.234:9000/tv`

---

### 4.9 FIFO & Validation NVL (Táº¯t/Báº­t cháº·n)

- **Táº¯t FIFO cho toÃ n bá»™:** SP `usp_MaterialWarehouseInOutHist_iud` -> Comment out dÃ²ng FIFO check
- **Táº¯t FIFO cho NVL cá»¥ thá»ƒ:** SP `usp_VVTMaterialWarehouse_validFIFO`

> âš ï¸ **Nordex Audit (tá»« 2026-02-05):** Logic cháº·n quÃ©t sai BOM trong SP `usp_RawMaterialInputHist_iud` Ä‘ang bá»‹ **Comment Out táº¡m thá»i**. Há»‡ thá»‘ng hiá»‡n cháº¥p nháº­n NVL khÃ´ng cÃ³ trong BOM - cáº§n báº­t láº¡i sau khi audit xong.

**Bypass NVL háº¿t háº¡n (khi QC Ä‘Ã£ Ä‘á»“ng Ã½):**
```sql
INSERT INTO stb_vvt_OpenExpiredMaterial
    (MaterialCode, LotID, ExpiredDate, OpenDate, OpenUserID, Remark)
VALUES
    ('mÃ£_nvl', 'lot_id', '2026-04-10', GETDATE(), 'admin', 'QC Ä‘Ã£ kiá»ƒm tra OK')

-- Kiá»ƒm tra bypass Ä‘ang active
SELECT * FROM stb_vvt_OpenExpiredMaterial
WHERE MaterialCode = 'mÃ£_nvl' AND OpenDate >= DATEADD(DAY, -30, GETDATE())
```

---

### 4.10 Kiá»ƒm tra Háº¡n sá»­ dá»¥ng NVL (Expiry Date)

- **NgÃ y sáº£n xuáº¥t:** Cá»™t `LotAttr10` trong `STB_MaterialDocLotInfo`
- **Shelf Life:** Cá»™t `MMExtInt01` trong `STB_MaterialMaster`
- **Háº¡n dÃ¹ng = LotAttr10 + MMExtInt01 (thÃ¡ng)**
- **Äáº·c biá»‡t `MDFLUX-002`:** hardcode 179 ngÃ y thay vÃ¬ 180

```sql
-- Tra cá»©u nhanh háº¡n sá»­ dá»¥ng cá»§a 1 Lot
SELECT
    MDLI.LotID,
    MDLI.LotAttr10 AS [NgÃ y_SX],
    MM.MMExtInt01 AS [Háº¡n_ThÃ¡ng],
    DATEADD(MONTH, MM.MMExtInt01, MDLI.LotAttr10) AS [NgÃ y_Háº¿t_Háº¡n],
    CASE WHEN DATEADD(MONTH, MM.MMExtInt01, MDLI.LotAttr10) < GETDATE()
         THEN 'ÄÃƒ Háº¾T Háº N' ELSE 'CÃ’N Háº N' END AS [Tráº¡ng_ThÃ¡i]
FROM STB_MaterialDocLotInfo MDLI
JOIN STB_MaterialMaster MM ON MDLI.MaterialCode = MM.MaterialCode
WHERE MDLI.LotID = 'ML...'
```

**Xá»­ lÃ½ náº¿u háº¿t háº¡n nhÆ°ng hÃ ng váº«n dÃ¹ng Ä‘Æ°á»£c:**
1. BÃ¡o QC xÃ¡c nháº­n gia háº¡n
2. ThÃªm vÃ o `stb_vvt_OpenExpiredMaterial` (xem Â§4.9) hoáº·c sá»­a `LotAttr10` / tÄƒng `MMExtInt01`

**HÆ°á»›ng dáº«n thay Ä‘á»•i háº¡n sá»­ dá»¥ng NVL (VÃ­ dá»¥: tá»« 5 thÃ¡ng lÃªn 6 thÃ¡ng á»Ÿ mÃ n F330):**
- **CÃ¡ch 1 (Qua UI):** VÃ o mÃ n hÃ¬nh **A230 (ThÃ´ng tin NVL Master)** -> TÃ¬m kiáº¿m theo mÃ£ nguyÃªn váº­t liá»‡u -> Táº¡i cá»™t cáº¥u hÃ¬nh háº¡n sá»­ dá»¥ng (**Shelf Life (thÃ¡ng)** hoáº·c **MMExtInt01**) sá»­a Ä‘á»•i giÃ¡ trá»‹ (VD tá»« `5` lÃªn `6`) -> Báº¥m **Save** Ä‘á»ƒ lÆ°u.
- **CÃ¡ch 2 (Qua SQL Query):**
  ```sql
  -- BÆ°á»›c 1: SELECT kiá»ƒm tra trÆ°á»›c
  SELECT MaterialCode, MaterialName, MMExtInt01
  FROM STB_MaterialMaster
  WHERE MaterialCode = 'MÃƒ_NVL'; -- VD: 'MDFLUX-003'

  -- BÆ°á»›c 2: UPDATE qua Transaction
  BEGIN TRAN;
  UPDATE STB_MaterialMaster
  SET MMExtInt01 = 6 -- Sá»‘ thÃ¡ng háº¡n dÃ¹ng má»›i
  WHERE MaterialCode = 'MÃƒ_NVL';
  
  -- SELECT láº¡i xÃ¡c nháº­n
  SELECT MaterialCode, MaterialName, MMExtInt01 FROM STB_MaterialMaster WHERE MaterialCode = 'MÃƒ_NVL';
  
  COMMIT TRAN; -- hoáº·c ROLLBACK TRAN;
  ```
- **LÆ°u Ã½:** Sau khi thay Ä‘á»•i, ngÃ y háº¿t háº¡n má»›i á»Ÿ mÃ n F330 sáº½ tá»± Ä‘á»™ng cáº­p nháº­t real-time theo cáº¥u hÃ¬nh má»›i. Äá»‘i vá»›i cÃ¡c mÃ£ dung mÃ´i Ä‘áº·c biá»‡t (nhÆ° `MDFLUX-002`), há»‡ thá»‘ng Ã¡p dá»¥ng logic `(MMExtInt01 * 30) - 1` ngÃ y (6 thÃ¡ng tÆ°Æ¡ng Ä‘Æ°Æ¡ng 179 ngÃ y).

---

### 4.11 Lá»—i khÃ´ng lÆ°u Ä‘Æ°á»£c F330 - Cáº¥u hÃ¬nh vÃ  sá»­a lá»—i Ä‘á»c "Äáº·c tÃ­nh 10" (Vendor Lot No)

**Triá»‡u chá»©ng:** F330 bÃ¡o lá»—i khi nháº­p mÃ£ Lot nhÃ  cung cáº¥p á»Ÿ "Äáº·c tÃ­nh 10" (hoáº·c Lot tá»± Ä‘á»™ng bá»‹ Ä‘Æ°a vÃ o kho `HOLDING` do thiáº¿u Äáº·c tÃ­nh 10).

**Báº£n cháº¥t:** "Äáº·c tÃ­nh 10" (`LotExtText10` / `LotAttr10`) Ä‘áº¡i diá»‡n cho mÃ£ Vendor Lot cá»§a nhÃ  cung cáº¥p. Máº·c Ä‘á»‹nh há»‡ thá»‘ng sá»­ dá»¥ng hÃ m parse SQL Ä‘á»ƒ tá»± Ä‘á»™ng bÃ³c tÃ¡ch thÃ´ng tin ngÃ y sáº£n xuáº¥t tá»« mÃ£ nÃ y.

CÃ³ **3 cÃ¡ch xá»­ lÃ½/thiáº¿t láº­p** tÃ¹y thuá»™c vÃ o tÃ¬nh huá»‘ng:

#### CÃ¡ch 1: Cáº¥u hÃ¬nh Ä‘á»™ dÃ i quÃ©t tem trÃªn UI F330 (Khi mÃ£ Lot Vendor quÃ¡ dÃ i)
* **Vá»‹ trÃ­ thiáº¿t láº­p:** VÃ o mÃ n hÃ¬nh **F330** -> Tab thá»© 3.
* **Thá»±c hiá»‡n:** Thiáº¿t láº­p cáº¥u hÃ¬nh chiá»u dÃ i quÃ©t cá»§a mÃ£ Ä‘á»ƒ cáº¯t chuá»—i barcode láº¥y pháº§n Lot phÃ¹ há»£p, giÃºp trÃ¡nh lá»—i do chuá»—i barcode truyá»n vÃ o quÃ¡ dÃ i.

#### CÃ¡ch 2: Chá»‰nh sá»­a hÃ m tá»± Ä‘á»™ng parse ngÃ y sáº£n xuáº¥t trong SQL (PhÆ°Æ¡ng phÃ¡p chuáº©n hay dÃ¹ng)
Khi nhÃ  cung cáº¥p thay Ä‘á»•i Ä‘á»‹nh dáº¡ng mÃ£ Lot Vendor, há»‡ thá»‘ng sáº½ khÃ´ng Ä‘á»c Ä‘Æ°á»£c ngÃ y sáº£n xuáº¥t, gÃ¢y lá»—i `Exception occurred` hoáº·c tÃ­nh sai háº¡n dÃ¹ng. Báº¡n cáº§n sá»­a Ä‘á»•i cÃ¡c SQL Function tÆ°Æ¡ng á»©ng.

##### 1. PhÃ¢n biá»‡t 2 Function cá»§a há»‡ thá»‘ng:
* **HÃ m [fn_VVT_getdatebyVendorLot](../KB_10/KB_10_01_ARCHITECTURE.md) (2 tham sá»‘: `@materialcode`, `@vendorlot`):**
  * DÃ¹ng cho cÃ¡c váº­t tÆ° chá»‰ cÃ³ má»™t Ä‘á»‹nh dáº¡ng Vendor Lot duy nháº¥t tá»« má»™t nhÃ  cung cáº¥p, khÃ´ng phÃ¢n biá»‡t nhÃ  cung cáº¥p khÃ¡c nhau.
* **HÃ m [fn_VVT_getdatebyVendorLot_MergeCode](../KB_10/KB_10_01_ARCHITECTURE.md) (3 tham sá»‘: `@materialcode`, `@vendorlot`, `@sourceCustomerCode`):**
  * DÃ¹ng khi **cÃ¹ng má»™t mÃ£ váº­t tÆ°** nhÆ°ng Ä‘Æ°á»£c cung cáº¥p bá»Ÿi **nhiá»u nhÃ  cung cáº¥p khÃ¡c nhau** (`@sourceCustomerCode` vÃ­ dá»¥: `VV033`, `VV040`, `VV034`...) cÃ³ Ä‘á»‹nh dáº¡ng mÃ£ Lot khÃ¡c nhau (Ä‘áº·c biá»‡t lÃ  nhÃ³m Vá» nhÃ´m `GBAKAC-%`, Sleeve `GCMDPT-%`, BÄƒng keo `GBRLAC-%`).

##### 2. Sá»­a á»Ÿ Ä‘Ã¢u vÃ  sá»­a tháº¿ nÃ o?
* **BÆ°á»›c 1: XÃ¡c Ä‘á»‹nh hÃ m cáº§n sá»­a**
  Xem Stored Procedure cá»§a mÃ n hÃ¬nh (vÃ­ dá»¥: `usp_MaterialDocLotInfo_get` hoáº·c `usp_vvt_MaterialLotInfo_get`) Ä‘ang gá»i hÃ m nÃ o. ThÆ°á»ng cÃ¡c nÃ¢ng cáº¥p má»›i cá»§a Vinatech Ä‘á»u Æ°u tiÃªn chuyá»ƒn qua dÃ¹ng hÃ m 3 tham sá»‘ `fn_VVT_getdatebyVendorLot_MergeCode` Ä‘á»ƒ quáº£n lÃ½ theo nhÃ  cung cáº¥p (NCC).
* **BÆ°á»›c 2: Viáº¿t cÃ¢u lá»‡nh `ALTER FUNCTION`**
  ThÃªm má»™t nhÃ¡nh `WHEN` vÃ o khá»‘i `CASE` cá»§a function tÆ°Æ¡ng á»©ng trong database.

##### 3. CÃ¡c máº«u viáº¿t logic parse ngÃ y thÃ´ng dá»¥ng:

* **Máº«u 1: Äá»‹nh dáº¡ng Year-Month-Day dáº¡ng sá»‘ thÃ´ng thÆ°á»ng (vÃ­ dá»¥: `260530...` -> 2026-05-30)**
  ```sql
  when @materialcode in ('MÃƒ_Váº¬T_TÆ¯') then '20'+ substring(@vendorlot,1,2)+'-'+ substring(@vendorlot,3,2)+'-'+ substring(@vendorlot,5,2)
  ```
  *(Náº¿u láº¥y nÄƒm 4 chá»¯ sá»‘ thÃ¬ dÃ¹ng `substring(@vendorlot,1,4)` tÃ¹y vá»‹ trÃ­)*

  *VÃ­ dá»¥ thá»±c táº¿ (`GBCP00-005` vá»›i mÃ£ lot `H226042815` -> `2026-04-28`):*
  NÄƒm (`26`) náº±m tá»« kÃ½ tá»± thá»© 3 (Ä‘á»™ dÃ i 2), ThÃ¡ng (`04`) náº±m tá»« kÃ½ tá»± thá»© 5 (Ä‘á»™ dÃ i 2), NgÃ y (`28`) náº±m tá»« kÃ½ tá»± thá»© 7 (Ä‘á»™ dÃ i 2).
  * **Náº¿u viáº¿t má»›i:**
    ```sql
    when @materialcode = 'GBCP00-005' then '20' + substring(@vendorlot,3,2) + '-' + substring(@vendorlot,5,2) + '-' + substring(@vendorlot,7,2)
    ```
  * **Náº¿u gá»™p vÃ o Case cÃ³ sáºµn (KhuyÃªn dÃ¹ng):** Trong hÃ m `fn_VVT_getdatebyVendorLot_MergeCode` Ä‘Ã£ cÃ³ sáºµn nhÃ³m dÃ¹ng chung logic parse nÃ y. Chá»‰ cáº§n chÃ¨n thÃªm `'GBCP00-005'` vÃ o danh sÃ¡ch `IN` cÃ³ sáºµn:
    ```sql
    when @materialcode in ('GCTN00-003', 'GBCP00-004', 'GBCP00-005') then 
        '20' + substring(@vendorlot,3,2) + '-' + substring(@vendorlot,5,2) + '-' + substring(@vendorlot,7,2)
    ```

* **Máº«u 2: PhÃ¢n biá»‡t theo NhÃ  cung cáº¥p (`@sourceCustomerCode`)** (Chá»‰ dÃ¹ng trong hÃ m `_MergeCode`)
  
  *VÃ­ dá»¥ 1: Vá» nhÃ´m `GBAKAC-005` phÃ¢n biá»‡t giá»¯a NCC `VV033` vÃ  cÃ¡c NCC khÃ¡c:*
  ```sql
  when @materialcode = 'GBAKAC-005' then 
      case 
          when @sourceCustomerCode = 'VV033' then '20'+ substring(@vendorlot,5,2) +'-'+ substring(@vendorlot,7,2) +'-'+ substring(@vendorlot,9,2)
          else '20'+ substring(@vendorlot,5,2) +'-'+ substring(@vendorlot,7,2) +'-'+ substring(@vendorlot,9,2)
      end
  ```

  *VÃ­ dá»¥ 2: BÄƒng keo `GBRLAC-005` tá»« NCC `VV040` (MÃ£ Lot dáº¡ng `062182605230673302` -> parse thÃ nh `2026-05-23`):*
  ```sql
  when @materialcode = 'GBRLAC-005' then 
      case 
          when @sourceCustomerCode = 'VV040' then '20' + substring(@vendorlot,6,2) + '-' + substring(@vendorlot,8,2) + '-' + substring(@vendorlot,10,2)
          else '20' + substring(@vendorlot,5,2) + '-' + substring(@vendorlot,7,2) + '-' + substring(@vendorlot,9,2)
      end
  ```

* **Máº«u 3: Äá»‹nh dáº¡ng mÃ£ hÃ³a ThÃ¡ng báº±ng Chá»¯ cÃ¡i (A=10, B=11, C=12 hoáº·c A=01, B=02...)**
  ```sql
  when @materialcode = 'GBAKAC-039' then '202'+ substring(@vendorlot,2,1) -- NÄƒm
                                         +'-'
                                         + right('0' + case 
                                         when substring(@vendorlot,3,1)='A' then '10'
                                         when substring(@vendorlot,3,1)='B' then '11'
                                         when substring(@vendorlot,3,1)='C' then '12'
                                         else substring(@vendorlot,3,1) end,2) -- ThÃ¡ng
                                         +'-'
                                         + substring(@vendorlot,4,2) -- NgÃ y
  ```

* **Máº«u 4: Äá»‹nh dáº¡ng cá»©ng ngÃ y 15 hÃ ng thÃ¡ng (khi mÃ£ Lot chá»‰ cÃ³ NÄƒm-ThÃ¡ng)**
  ```sql
  when @materialcode='GADPCB-002' then '20'+ substring(@vendorlot,1,2)+'-'+ substring(@vendorlot,3,2) + '-15'
  ```

##### 4. NguyÃªn táº¯c kiá»ƒm tra sau khi sá»­a:
Cháº¡y lá»‡nh `SELECT` kiá»ƒm tra hÃ m trá»±c tiáº¿p trong SSMS trÆ°á»›c khi thá»±c hiá»‡n giao dá»‹ch nháº­p kho:
```sql
SELECT [dbo].[fn_VVT_getdatebyVendorLot_MergeCode]('MÃƒ_Váº¬T_TÆ¯', 'MÃƒ_VENDOR_LOT_TEST', 'MÃƒ_NCC')
-- Káº¿t quáº£ tráº£ vá» pháº£i Ä‘Ãºng Ä‘á»‹nh dáº¡ng YYYY-MM-DD (VÃ­ dá»¥: '2026-05-30')
```

#### CÃ¡ch 3: Sá»­a thá»§ cÃ´ng báº±ng SQL (Workaround bypass nhanh)
Náº¿u cáº§n Ä‘Æ°a Lot ra khá»i kho HOLDING vÃ  bá»• sung Äáº·c tÃ­nh 10 kháº©n cáº¥p:
```sql
-- BÆ°á»›c 1: ThÃªm Äáº·c tÃ­nh 10 (MÃ£ Lot Vendor) vÃ o Lot
UPDATE STB_MaterialLotInfo
SET LotExtText10 = 'MÃƒ_LOT_VENDOR_ÄÃšNG'
WHERE LotID = 'lot_id_cáº§n_sá»­a';

-- BÆ°á»›c 2: KÃ©o Lot ra khá»i kho HOLDING vá» kho chÃ­nh (VÃ­ dá»¥: ROH_BN_WH)
UPDATE STB_MaterialLotInfo
SET MaterialWarehouseCode = 'ROH_BN_WH', 
    MaterialLocationCode = 'ROH_BN_WH_01'
WHERE LotID = 'lot_id_cáº§n_sá»­a';

-- BÆ°á»›c 3: Cáº­p nháº­t Ä‘á»“ng bá»™ NgÃ y sáº£n xuáº¥t (LotAttr10) Ä‘á»ƒ trÃ¡nh lá»—i háº¡n dÃ¹ng (Expiry Date check)
UPDATE STB_MaterialDocLotInfo  
SET LotAttr10 = 'YYYY-MM-DD' -- VÃ­ dá»¥: '2026-04-10'
WHERE LotID = 'lot_id_cáº§n_sá»­a';

UPDATE STB_MaterialLotInfo  
SET LotAttr10 = 'YYYY-MM-DD'
WHERE LotID = 'lot_id_cáº§n_sá»­a';
```

---

### 4.12 Lá»—i "KhÃ´ng tá»“n táº¡i thiáº¿t láº­p Vá» NhÃ´m" (B597)

*   **Triá»‡u chá»©ng:** `"KhÃ´ng tá»“n táº¡i thiáº¿t láº­p Vá» NhÃ´m cá»§a LotNo... vá»›i mÃ£ Vá» NhÃ´m: GBDYAC-004 <> ECVT30-367"`
*   **Chi tiáº¿t & Giáº£i phÃ¡p:** Xem chi tiáº¿t nguyÃªn nhÃ¢n gá»‘c, cÃ¡ch trace vÃ  SQL script kháº¯c phá»¥c táº¡i [../KB_05/KB_05_01_QC_OVERVIEW.md#74-b597-bÃ¡o-lá»—i-khÃ´ng-tá»“n-táº¡i-thiáº¿t-láº­p-vá»-nhÃ´m](../KB_05/KB_05_01_QC_OVERVIEW.md#74-b597-bÃ¡o-lá»—i-khÃ´ng-tá»“n-táº¡i-thiáº¿t-láº­p-vá»-nhÃ´m).
*   **Checklist lá»—i B597 Ä‘áº§y Ä‘á»§:** Xem táº¡i [../KB_05/KB_05_01_QC_OVERVIEW.md#83-checklist-khi-b597-bÃ¡o-lá»—i-khi-lÆ°u-nvl](../KB_05/KB_05_01_QC_OVERVIEW.md#83-checklist-khi-b597-bÃ¡o-lá»—i-khi-lÆ°u-nvl).

---

### 4.13 FIFO Kho thÃ nh pháº©m (FG00)

- **VVT (Báº¯c Ninh):** SP `usp_VN_Update_ExportExcel`
- **Báº¯c Giang:** SP `usp_VN_Update_ExportExcel_BG`
- **Báº­t/táº¯t FIFO cho FG:** VÃ o mÃ n **F110** -> TÃ­ch/bá» tÃ­ch option FIFO

---

### 4.14 XÃ³a mÃ£ Sparepart thá»«a

```sql
SELECT * FROM STB_VNSparePartInfo WHERE sparepartcode = '[MÃ£ cáº§n xÃ³a]'
DELETE FROM STB_VNSparePartInfo WHERE sparepartcode = '[MÃ£ cáº§n xÃ³a]'
```

---

### 4.15 Luá»“ng nháº­p kho Ä‘áº§y Ä‘á»§ (F330)

```
Groupware (Arrival Confirmation duyá»‡t xong)
    â†“
F330 - Nháº­n hÃ ng, in tem NVL, gÃ¡n Lot vÃ o kho
    â†“
C220 - IQC kiá»ƒm tra cháº¥t lÆ°á»£ng -> PASS
    â†“
Groupware (Receiving Confirmation)
    â†“
NVL sáºµn sÃ ng cho sáº£n xuáº¥t
```

> KhÃ´ng nháº­p Ä‘Æ°á»£c F330 -> Groupware chÆ°a duyá»‡t Arrival Confirmation?
> KhÃ´ng lÃ m Ä‘Æ°á»£c Receiving Confirmation -> C220 chÆ°a PASS?

---

### 4.16 Há»§y phiáº¿u nháº­p kho F330 Ä‘Ã£ Confirmed

> âš ï¸ **Chá»‰ lÃ m khi hÃ ng chÆ°a Ä‘Æ°á»£c xuáº¥t kho hoáº·c dÃ¹ng sáº£n xuáº¥t.**

```sql
-- BÆ°á»›c 1: TÃ¬m phiáº¿u cáº§n há»§y
SELECT * FROM STB_MaterialDocInfo WHERE MaterialDocNo = 'Sá»‘_TÃ i_Liá»‡u'

-- BÆ°á»›c 2: Kiá»ƒm tra xem Ä‘Ã£ cÃ³ IQC chÆ°a - náº¿u cÃ³ pháº£i xÃ³a IQC records trÆ°á»›c
SELECT * FROM STB_MaterialQcInfo WHERE MaterialDocNo = 'Sá»‘_TÃ i_Liá»‡u'
-- Náº¿u cÃ³ IQC PASS -> xÃ³a thÃªm:
DELETE FROM STB_IQcDefectReport WHERE MaterialDocNo = 'Sá»‘_TÃ i_Liá»‡u'
DELETE FROM STB_MaterialQcInfo WHERE MaterialDocNo = 'Sá»‘_TÃ i_Liá»‡u'

-- BÆ°á»›c 3: Láº¥y danh sÃ¡ch LotID
SELECT LotID FROM STB_MaterialDocLotInfo WHERE MaterialDocNo = 'Sá»‘_TÃ i_Liá»‡u'

-- BÆ°á»›c 4: XÃ³a theo thá»© tá»± ngÆ°á»£c (trÃ¡nh lá»—i FK)
DELETE FROM STB_MaterialLotInfo WHERE LotID IN (
    SELECT LotID FROM STB_MaterialDocLotInfo WHERE MaterialDocNo = 'Sá»‘_TÃ i_Liá»‡u'
)
DELETE FROM STB_MaterialDocLotInfo WHERE MaterialDocNo = 'Sá»‘_TÃ i_Liá»‡u'
DELETE FROM STB_MaterialDocDetail WHERE MaterialDocNo = 'Sá»‘_TÃ i_Liá»‡u'
DELETE FROM STB_MaterialDocInfo WHERE MaterialDocNo = 'Sá»‘_TÃ i_Liá»‡u'
```

---

### 4.17 Thu há»“i Lot tá»« F430 vá» kho (Revert xuáº¥t kho)

**TÃ¬nh huá»‘ng:** Cáº§n revert hÃ ng Ä‘Ã£ xuáº¥t á»Ÿ F430 vá» láº¡i kho.

```sql
-- BÆ°á»›c 1: Xem tráº¡ng thÃ¡i tá»“n kho hiá»‡n táº¡i
SELECT LotID, MaterialWarehouseCode, MaterialLocationCode, CurrentQty
FROM STB_MaterialLotInfo WHERE LotID = 'ML20260407000696'

-- BÆ°á»›c 2: TÃ¬m ID giao dá»‹ch xuáº¥t kho cáº§n xÃ³a
SELECT MaterialWarehouseInOutHistNo, SourceMaterialWarehouseCode,
       TargetMaterialWarehouseCode, CreateDateTime
FROM STB_MaterialWarehouseInOutHist
WHERE LotID = 'ML20260407000696'
ORDER BY CreateDateTime DESC

-- BÆ°á»›c 3: Xem vá»‹ trÃ­ gá»‘c lÃºc má»›i nháº­p kho
SELECT LotID, MaterialLocationCode
FROM STB_MaterialDocLotInfo WHERE LotID = 'ML20260407000696'

-- BÆ°á»›c 4: Thá»±c hiá»‡n revert
BEGIN TRAN
    DELETE FROM STB_MaterialWarehouseInOutHist
    WHERE MaterialWarehouseInOutHistNo = 'MÃƒ_GIAO_Dá»ŠCH_Cáº¦N_XÃ“A'

    UPDATE STB_MaterialLotInfo
    SET MaterialWarehouseCode = 'ROH_HN_WH',
        MaterialLocationCode = 'ROH_HN_WH_01'
    WHERE LotID = 'ML20260407000696'

    SELECT * FROM STB_MaterialLotInfo WHERE LotID = 'ML20260407000696'
-- COMMIT khi cháº¯c cháº¯n Ä‘Ãºng, ROLLBACK náº¿u sai
```

> **Táº¡i sao pháº£i xÃ³a `STB_MaterialWarehouseInOutHist`?** Náº¿u chá»‰ sá»­a kho mÃ  khÃ´ng xÃ³a lá»‹ch sá»­, bÃ¡o cÃ¡o xuáº¥t nháº­p tá»“n cuá»‘i thÃ¡ng sáº½ bá»‹ lá»‡ch.

#### ðŸ“ VÃ­ dá»¥ thá»±c táº¿ (Há»§y xuáº¥t / Tráº£ láº¡i kho HÃ  Nam):
Giao dá»‹ch xuáº¥t sai lÃºc 12:07 trÆ°a ngÃ y 11/05/2026 cho Lot `ML20260209000136`.
1. **Kiá»ƒm tra tráº¡ng thÃ¡i hiá»‡n táº¡i:**
   ```sql
   -- Kiá»ƒm tra Lot Ä‘ang á»Ÿ kho nÃ o
   SELECT MaterialWarehouseCode, MaterialLocationCode FROM STB_MaterialLotInfo WHERE LotID = 'ML20260209000136';
   -- Káº¿t quáº£: Lot Ä‘ang á»Ÿ kho ROUTE_HN_WH (Ä‘Ã£ lÃªn chuyá»n).

   -- TrÃ­ch xuáº¥t lá»‹ch sá»­ xuáº¥t/nháº­p Ä‘á»ƒ tÃ¬m MaterialWarehouseInOutHistNo Ä‘áº¡i diá»‡n cho cÃº click xuáº¥t sai táº¡i F430
   SELECT * FROM STB_MaterialWarehouseInOutHist
   WHERE LotID = 'ML20260209000136'
   ORDER BY CreateDateTime DESC;
   -- Káº¿t quáº£: TÃ¬m Ä‘Æ°á»£c MaterialWarehouseInOutHistNo = '20260511000320' (xuáº¥t bá»Ÿi user VES-019 lÃªn chuyá»n VELINE-09 lÃºc 12:07:31).
   ```
2. **Ká»‹ch báº£n sá»­a lá»—i an toÃ n báº±ng Transaction:**
   ```sql
   BEGIN TRAN;

   -- B1: XÃ³a vá»‡t log giao dá»‹ch xuáº¥t kho táº¡i F430
   DELETE FROM STB_MaterialWarehouseInOutHist 
   WHERE LotID = 'ML20260209000136' AND MaterialWarehouseInOutHistNo = '20260511000320';

   -- B2: KÃ©o cuá»™n nguyÃªn liá»‡u tá»« kho áº£o trÃªn chuyá»n (ROUTE_HN_WH) quay trá»Ÿ vá» kho váº­t lÃ½ gá»‘c (ROH_HN_WH)
   UPDATE STB_MaterialLotInfo
   SET 
       MaterialWarehouseCode = 'ROH_HN_WH', 
       MaterialLocationCode = 'ROH_HN_WH_01'
   WHERE LotID = 'ML20260209000136';

   -- Kiá»ƒm tra láº¡i trÆ°á»›c khi chá»‘t
   SELECT * FROM STB_MaterialLotInfo WHERE LotID = 'ML20260209000136';

   COMMIT TRAN; -- Hoáº·c ROLLBACK náº¿u cÃ³ lá»—i
   ```

---

### 4.18 Fix: LIKE filter sai cho MaterialLocationCode khi cáº­p nháº­t LotAttr10 (Äáº·c tÃ­nh 10)

> **NgÃ y phÃ¡t hiá»‡n:** 2026-06-03
> **MÃ n hÃ¬nh:** F330, F710
> **SP liÃªn quan:** `usp_DoChangeMaterialDocLotInfo`, `usp_vvt_MaterialLotInfo_get`
> **Root cause:** Äiá»u kiá»‡n `LIKE` filter cho `MaterialLocationCode` khÃ´ng match vÃ¬ thiáº¿u trailing `%`

#### MÃ´ táº£ lá»—i
- Khi nháº­p nguyÃªn váº­t liá»‡u vÃ o kho BG2 (`MODULE_BG2_WH_01`), trÆ°á»ng `LotAttr10` (Äáº·c tÃ­nh 10 / NgÃ y SX Vendor) khÃ´ng Ä‘Æ°á»£c tá»± Ä‘á»™ng parse tá»« `LotNo`.
- GiÃ¡ trá»‹ `LotAttr10` giá»¯ nguyÃªn `1900-01-01` thay vÃ¬ chuyá»ƒn thÃ nh ngÃ y Ä‘Ãºng (vÃ­ dá»¥: `20260528` â†’ `2026-05-28`).

#### NguyÃªn nhÃ¢n gá»‘c
Trong 2 SP `usp_DoChangeMaterialDocLotInfo` vÃ  `usp_vvt_MaterialLotInfo_get`, Ä‘oáº¡n UPDATE `LotAttr10` cÃ³ Ä‘iá»u kiá»‡n:
```sql
MaterialLocationCode LIKE '%BG2_WH'  -- âŒ SAI
```
NhÆ°ng táº¥t cáº£ location code Ä‘á»u cÃ³ suffix `_01`, vÃ­ dá»¥:
- `MODULE_BG2_WH_01` â† khÃ´ng match `'%BG2_WH'`
- `HEADQUARTER_VN_WH_01` â† khÃ´ng match `'%VN_WH'`

Lá»—i tÆ°Æ¡ng tá»± xáº£y ra cho `%VN_WH`, `%BG_WH`, `%HN_WH`.

#### CÃ¡ch fix
ThÃªm trailing `%` vÃ o táº¥t cáº£ LIKE pattern:
```sql
MaterialLocationCode LIKE '%BG2_WH%'  -- âœ… ÄÃšNG
MaterialLocationCode LIKE '%VN_WH%'   -- âœ… ÄÃšNG
MaterialLocationCode LIKE '%BG_WH%'   -- âœ… ÄÃšNG
MaterialLocationCode LIKE '%HN_WH%'   -- âœ… ÄÃšNG
```

#### LÆ°u Ã½ quan trá»ng
- Lá»—i nÃ y áº£nh hÆ°á»Ÿng **táº¥t cáº£ cÃ¡c kho** náº¿u location code cÃ³ suffix (khÃ´ng chá»‰ BG2).
- Sau khi fix SP, cáº§n chá» user má»Ÿ láº¡i F330/F710 Ä‘á»ƒ SP tá»± Ä‘á»™ng cáº­p nháº­t cÃ¡c lot cÅ©.
- HÃ m `fn_VVT_getdatebyVendorLot_MergeCode` parse ngÃ y **hoáº¡t Ä‘á»™ng Ä‘Ãºng** â€” lá»—i chá»‰ náº±m á»Ÿ WHERE clause.

*Cáº­p nháº­t: 2026-06-10*

---

### 4.19 F110 â€” XÃ¡c nháº­n nháº­p kho vÃ  Cáº¥u hÃ¬nh Kho (Warehouse Configurations)

**MÃ n hÃ¬nh:** F110 (XÃ¡c nháº­n nháº­p kho NVL sau IQC)  
**Báº£ng DB liÃªn quan:** `STB_MaterialWarehouse`, `STB_MaterialStockAttributeInfo`

#### 1. CÆ¡ cháº¿ quáº£n lÃ½ kho áº£o & Line Warehouse (`STB_MaterialWarehouse`)
Má»—i kho trong há»‡ thá»‘ng (ká»ƒ cáº£ kho áº£o trÃªn cÃ¡c chuyá»n sáº£n xuáº¥t) Ä‘Æ°á»£c quáº£n lÃ½ trong báº£ng `STB_MaterialWarehouse`. Cá» `IsRouteWarehouse = 1` dÃ¹ng Ä‘á»ƒ phÃ¢n biá»‡t kho áº£o cáº¡nh chuyá»n (Route Warehouse) vá»›i kho váº­t lÃ½ thÃ´ng thÆ°á»ng.

#### 2. Cáº¥u hÃ¬nh quáº£n lÃ½ tá»“n kho theo tá»«ng mÃ£ nguyÃªn váº­t liá»‡u (`STB_MaterialStockAttributeInfo`)
Vá»›i má»—i mÃ£ nguyÃªn váº­t liá»‡u (`MaterialCode`), há»‡ thá»‘ng cáº¥u hÃ¬nh cÃ¡c cá» Ä‘iá»u kiá»‡n sau Ä‘á»ƒ quyáº¿t Ä‘á»‹nh hÃ nh vi nháº­p/xuáº¥t táº¡i F110/F330/F430:
*   `IsUseBarcode`: CÃ³ báº¯t buá»™c quáº£n lÃ½ vÃ  quÃ©t báº±ng tem nhÃ£n barcode hay khÃ´ng.
*   `IsFIFO`: CÃ³ kÃ­ch hoáº¡t tÃ­nh nÄƒng kiá»ƒm tra Nháº­p trÆ°á»›c - Xuáº¥t trÆ°á»›c (FIFO) Ä‘á»‘i vá»›i mÃ£ nÃ y hay khÃ´ng.
*   `IsLotUse`: CÃ³ báº¯t buá»™c tÃ¡ch hÃ ng thÃ nh cÃ¡c mÃ£ Lot riÃªng biá»‡t Ä‘á»ƒ theo dÃµi vÃ²ng Ä‘á»i hay khÃ´ng.
*   *LÆ°u Ã½ lá»—i:* Náº¿u nguyÃªn váº­t liá»‡u má»›i khÃ´ng gá»™p box Ä‘Æ°á»£c (lá»—i táº¡i B523), thá»§ kho cáº§n kiá»ƒm tra xem mÃ£ váº­t tÆ° Ä‘Ã³ Ä‘Ã£ Ä‘Æ°á»£c tÃ­ch Ä‘áº§y Ä‘á»§ cÃ¡c cá» cáº¥u hÃ¬nh trÃªn hay chÆ°a (Xem hÆ°á»›ng dáº«n thiáº¿t láº­p Master Data táº¡i [KB_06 Â§ 2.1](KB_06_MASTER_DATA_TOOLS.md)).

---

### 4.20 F741 â€” Quy trÃ¬nh TÃ¡ch Lot NguyÃªn Váº­t Liá»‡u (Lot Splitting)

**MÃ n hÃ¬nh:** F741 (TÃ¡ch Lot trÆ°á»›c khi cáº¥p lÃªn chuyá»n)  
**Stored Procedure chÃ­nh:** `usp_DoSplitRawMaterialAndMove`  
**Báº£ng ghi nháº­n lá»‹ch sá»­:** `STB_SupportRawMaterialSplitHist`

#### 1. Quy trÃ¬nh nghiá»‡p vá»¥ thá»±c táº¿
Khi xuáº¥t nguyÃªn váº­t liá»‡u lÃªn dÃ¢y chuyá»n sáº£n xuáº¥t, náº¿u sá»‘ lÆ°á»£ng cuá»™n/thÃ¹ng gá»‘c quÃ¡ lá»›n so vá»›i nhu cáº§u cá»§a chuyá»n, thá»§ kho sá»­ dá»¥ng mÃ n hÃ¬nh F741 Ä‘á»ƒ tÃ¡ch Lot gá»‘c thÃ nh cÃ¡c Lot con cÃ³ sá»‘ lÆ°á»£ng nhá» hÆ¡n.

#### 2. Logic xá»­ lÃ½ chi tiáº¿t trong database
Khi thá»§ kho click xÃ¡c nháº­n tÃ¡ch Lot trÃªn UI, há»‡ thá»‘ng sáº½ thá»±c hiá»‡n SP `usp_DoSplitRawMaterialAndMove` theo cÃ¡c bÆ°á»›c:
1.  **Kiá»ƒm tra Ä‘iá»u kiá»‡n Lot cha:**
    *   Lot gá»‘c (`@pMaterialLotNo`) pháº£i tá»“n táº¡i trong báº£ng `STB_MaterialLotInfo`.
    *   `PickingQty = 0` (Lot hiá»‡n táº¡i khÃ´ng trong tráº¡ng thÃ¡i Ä‘ang bá»‹ khÃ³a Ä‘á»ƒ xuáº¥t kho).
    *   Sá»‘ lÆ°á»£ng yÃªu cáº§u tÃ¡ch (`@pSplitQty`) pháº£i lá»›n hÆ¡n `0` vÃ  nhá» hÆ¡n sá»‘ lÆ°á»£ng tá»“n hiá»‡n táº¡i cá»§a Lot cha (`CurrentQty`).
2.  **Sinh Lot con má»›i:**
    *   Gá»i hÃ m `SmartFramework.dbo.usp_DoCreateSerial` Ä‘á»ƒ tá»± Ä‘á»™ng sinh mÃ£ sá»‘ `MaterialLotNo` má»›i cho Lot con.
3.  **Táº¡o báº£n ghi Lot con (`STB_MaterialLotInfo`):**
    *   Sao chÃ©p toÃ n bá»™ thÃ´ng tin thuá»™c tÃ­nh tá»« Lot cha sang Lot con.
    *   Äáº·t `InitialQty = @pSplitQty` vÃ  `CurrentQty = @ppSplitQty`.
    *   Äáº·t cá» `IsSplitLot = 1` Ä‘á»ƒ Ä‘Ã¡nh dáº¥u Ä‘Ã¢y lÃ  Lot Ä‘Æ°á»£c tÃ¡ch.
    *   Ghi nháº­n `BefMaterialLotNo` = `MaterialLotNo` cá»§a Lot cha (hoáº·c giá»¯ nguyÃªn Lot gá»‘c ban Ä‘áº§u náº¿u Lot cha cÅ©ng lÃ  Lot Ä‘Ã£ tÃ¡ch).
    *   Thiáº¿t láº­p láº¡i `PackingID` = `LotID` má»›i (Lot con sáº½ cÃ³ mÃ£ Ä‘Ã³ng gÃ³i riÃªng Ä‘á»™c láº­p vá»›i Lot cha).
4.  **Cáº­p nháº­t tá»“n kho Lot cha:**
    *   Giáº£m sá»‘ lÆ°á»£ng tá»“n thá»±c táº¿ cá»§a Lot cha trong `STB_MaterialLotInfo`:
        ```sql
        UPDATE STB_MaterialLotInfo
        SET CurrentQty = CurrentQty - @SplitQty
        WHERE MaterialLotNo = @MaterialLotNo;
        ```
5.  **Ghi log giao dá»‹ch:**
    *   Ghi nháº­n log giao dá»‹ch xuáº¥t nháº­p kho áº£o trong báº£ng `STB_MaterialWarehouseInOutHist`.
    *   Ghi nháº­n liÃªn káº¿t cha-con vÃ o báº£ng Ä‘á»‘i chiáº¿u `STB_SupportRawMaterialSplitHist`:
        ```sql
        INSERT INTO STB_SupportRawMaterialSplitHist (MergeLotID, SplitLotID, TotalCurrentQty, SplitQty, IsFixed, CreateDateTime, CreateUserID)
        VALUES (@MaterialLotNo, @NewMaterialLotNo, @CurrentQty - @SplitQty, @SplitQty, 0, GETDATE(), @ProcessUserID);
        ```
6.  **Di chuyá»ƒn vá»‹ trÃ­:** Náº¿u ngÆ°á»i dÃ¹ng truyá»n vÃ o vá»‹ trÃ­ Ä‘Ã­ch (`@pTargetLocation`), há»‡ thá»‘ng sáº½ tá»± Ä‘á»™ng cáº­p nháº­t vá»‹ trÃ­ má»›i cho Lot con vá»«a sinh ra.

---

### 4.21 F430 â€” Chi tiáº¿t Quy trÃ¬nh Xuáº¥t kho NVL (WMS Export Logic)

**MÃ n hÃ¬nh:** F430 (Xuáº¥t kho nguyÃªn váº­t liá»‡u)  
**Stored Procedure chÃ­nh:** `usp_MaterialWarehouseInOutHist_iud_ConfirmExportNVL`  
**SP kiá»ƒm tra logic:** `usp_VVTMaterialWarehouse_validFIFO`

#### 1. Quy trÃ¬nh nghiá»‡p vá»¥ thá»±c táº¿
Thá»§ kho quÃ©t mÃ£ Lot cá»§a nguyÃªn váº­t liá»‡u táº¡i F430 Ä‘á»ƒ xÃ¡c nháº­n xuáº¥t kho cáº¥p cho sáº£n xuáº¥t. HÃ ng sau khi quÃ©t sáº½ chuyá»ƒn tá»« cÃ¡c kho váº­t lÃ½ gá»‘c (`ROH_VN_WH`, `ROH_HN_WH`...) sang kho áº£o trÃªn cÃ¡c chuyá»n sáº£n xuáº¥t (`ROUTE_WH`, `ROUTE_HN_WH`...).

#### 2. Logic xá»­ lÃ½ chi tiáº¿t trong database
1.  **Kiá»ƒm tra FIFO báº¯t buá»™c:**
    *   Äá»‘i vá»›i cÃ¡c kho nguyÃªn liá»‡u chÃ­nh nhÆ° `ROH_WH` hoáº·c `ROH_VN_WH`, há»‡ thá»‘ng gá»i SP `usp_VVTMaterialWarehouse_validFIFO` vá»›i tham sá»‘ `@pKindCheck = 'FIFO'`.
    *   SP nÃ y Ä‘á»‘i soÃ¡t ngÃ y nháº­p kho (`GRDate`) cá»§a Lot Ä‘ang quÃ©t vá»›i cÃ¡c Lot cÃ¹ng mÃ£ hÃ ng Ä‘ang tá»“n trong kho. Náº¿u phÃ¡t hiá»‡n cÃ³ Lot nháº­p trÆ°á»›c nhÆ°ng chÆ°a Ä‘Æ°á»£c xuáº¥t, há»‡ thá»‘ng sáº½ cháº·n giao dá»‹ch vÃ  bÃ¡o lá»—i vi pháº¡m nguyÃªn táº¯c FIFO.
2.  **Kháº¥u trá»« & Di chuyá»ƒn vá»‹ trÃ­:**
    *   Há»‡ thá»‘ng cáº­p nháº­t thÃ´ng tin kho vÃ  vá»‹ trÃ­ má»›i cho Lot trong báº£ng `STB_MaterialLotInfo` (Chuyá»ƒn `MaterialWarehouseCode` sang kho áº£o cáº¡nh chuyá»n tÆ°Æ¡ng á»©ng vá»›i Line sáº£n xuáº¥t Ä‘Æ°á»£c chá»n).
    *   Ghi log lá»‹ch sá»­ xuáº¥t kho chi tiáº¿t vÃ o báº£ng `STB_MaterialWarehouseInOutHist` Ä‘á»ƒ phá»¥c vá»¥ Ä‘á»‘i soÃ¡t vÃ  bÃ¡o cÃ¡o xuáº¥t nháº­p tá»“n cuá»‘i thÃ¡ng.
3.  **KhÃ´i phá»¥c xuáº¥t kho (Revert):**
    *   Náº¿u thá»§ kho quÃ©t xuáº¥t nháº§m Lot, khÃ´ng Ä‘Æ°á»£c thá»±c hiá»‡n xuáº¥t Ä‘Ã¨ hay cáº­p nháº­t thá»§ cÃ´ng má»™t báº£ng riÃªng láº». Quy trÃ¬nh khÃ´i phá»¥c chuáº©n yÃªu cáº§u xÃ³a dÃ²ng log giao dá»‹ch tÆ°Æ¡ng á»©ng trong `STB_MaterialWarehouseInOutHist` vÃ  cáº­p nháº­t láº¡i kho/vá»‹ trÃ­ gá»‘c cá»§a Lot trong `STB_MaterialLotInfo` vá» kho váº­t lÃ½ ban Ä‘áº§u (Xem chi tiáº¿t cÃ¢u lá»‡nh rollback táº¡i má»¥c Â§4.17).

---

### 4.22 HÆ°á»›ng Dáº«n Váº­n HÃ nh & Kháº¯c Phá»¥c Lá»—i Quy TrÃ¬nh Kho NVL (WMS)

DÆ°á»›i Ä‘Ã¢y lÃ  cáº©m nang váº­n hÃ nh chi tiáº¿t cÃ¡c mÃ n hÃ¬nh thuá»™c phÃ¢n há»‡ Kho NguyÃªn Váº­t Liá»‡u (WMS) Ä‘Æ°á»£c Ä‘Ãºc káº¿t tá»« tÃ i liá»‡u thá»±c táº¿ cá»§a nhÃ  mÃ¡y:

#### 1. Quáº£n lÃ½ NhÃ  cung cáº¥p & Chá»‰ Ä‘á»‹nh Váº­t tÆ° (A130, F130, F140)
*   **A130 (ThÃ´ng tin Ä‘á»‘i tÃ¡c giao dá»‹ch):** DÃ¹ng Ä‘á»ƒ thÃªm, sá»­a, xÃ³a thÃ´ng tin nhÃ  cung cáº¥p NVL vÃ  tÃ i khoáº£n Ä‘á»‘i tÃ¡c.
*   **F130 / F140 (Chá»‰ Ä‘á»‹nh nhÃ  cung cáº¥p - váº­t tÆ°):** Thiáº¿t láº­p má»‘i quan há»‡ Ã¡nh xáº¡ giá»¯a mÃ£ NVL vÃ  mÃ£ nhÃ  cung cáº¥p (Vendor). Chá»‰ khi Ä‘Æ°á»£c thiáº¿t láº­p táº¡i Ä‘Ã¢y thÃ¬ NVL má»›i cÃ³ thá»ƒ gá»i ra trong cÃ¡c phiáº¿u nháº­p kho.

#### 2. Táº¡o ghi chÃº Ä‘Æ¡n hÃ ng nháº­p kho F312 (Inward Slip)
*   Thá»±c hiá»‡n chá»n "Code bÃªn giao dá»‹ch" (liÃªn káº¿t tá»« cáº¥u hÃ¬nh F130) Ä‘á»ƒ hiá»ƒn thá»‹ danh sÃ¡ch NVL Ä‘Æ°á»£c phÃ©p cá»§a nhÃ  cung cáº¥p Ä‘Ã³.
*   **âš ï¸ Kháº¯c phá»¥c lá»—i NVL khÃ´ng hiá»ƒn thá»‹ trong mÃ n hÃ¬nh F312:** Khi láº­p phiáº¿u mÃ  khÃ´ng tÃ¬m tháº¥y mÃ£ NVL cá»§a nhÃ  cung cáº¥p trong Ã´ lá»±a chá»n, kiá»ƒm tra 3 nguyÃªn nhÃ¢n sau:
    1.  MÃ£ NVL chÆ°a Ä‘Æ°á»£c Map vá»›i nhÃ  cung cáº¥p táº¡i mÃ n hÃ¬nh **F140/F130**.
    2.  MÃ£ NVL Ä‘ang bá»‹ khÃ³a/ngÆ°ng sá»­ dá»¥ng trong mÃ n hÃ¬nh **A230 (ThÃ´ng tin váº­t liá»‡u)** (cá»™t "Äang Ä‘Ã³ng" bá»‹ tÃ­ch chá»n).
    3.  MÃ£ NVL khÃ´ng bá»‹ Ä‘Ã³ng á»Ÿ A230 nhÆ°ng **chÆ°a tÃ­ch chá»n** vÃ o 2 cá»™t thuá»™c tÃ­nh: **"Äang mua"** vÃ  **"Äang Ä‘áº·t hÃ ng"** (Ä‘Ã¢y lÃ  cÃ¡c cá» cáº¥u hÃ¬nh báº¯t buá»™c cho hÃ ng mua ngoÃ i).
*   Nháº­p sá»‘ lÆ°á»£ng yÃªu cáº§u thá»±c táº¿ (`RequestQty`) vÃ  nháº¥n biá»ƒu tÆ°á»£ng **Save** á»Ÿ lÆ°á»›i bÃªn dÆ°á»›i Ä‘á»ƒ lÆ°u.

#### 3. Tiáº¿p nháº­n, Nháº­p kho vÃ  In tem táº¡i F330 (Warehouse Entry & Label Printing)
*   **BÆ°á»›c 1 (Xá»­ lÃ½ hÃ ng vá»):** Khi phiáº¿u F312 má»›i táº¡o Ä‘Æ°á»£c gá»i ra á»Ÿ F330, cá»™t `DocStatusName` ban Ä‘áº§u sáº½ hiá»ƒn thá»‹ tráº¡ng thÃ¡i **"CREATE"**. Thá»§ kho báº¯t buá»™c pháº£i click chá»n dÃ²ng dá»¯ liá»‡u vÃ  nháº¥n nÃºt **"Xá»­ lÃ½ hÃ ng nháº­p vá»"** Ä‘á»ƒ há»‡ thá»‘ng chuyá»ƒn tráº¡ng thÃ¡i sang **"ARRIVAL"**. LÃºc nÃ y nÃºt táº¡o Lot má»›i sÃ¡ng lÃªn Ä‘á»ƒ thao tÃ¡c.
*   **BÆ°á»›c 2 (Chia tem & Khai bÃ¡o Ä‘áº·c tÃ­nh 10):**
    *   Nháº­p `PackingQty` (Sá»‘ lÆ°á»£ng NVL cá»§a 1 tem/thÃ¹ng) -> Há»‡ thá»‘ng tá»± Ä‘á»™ng tÃ­nh Sá»‘ tem = `ReceiveQty` / `PackingQty`.
    *   Nháº­p cÃ¡c thÃ´ng tin báº¯t buá»™c (mÃ u xanh Ä‘áº­m) -> Nháº¥n nÃºt **"Táº¡o tem"** Ä‘á»ƒ sinh danh sÃ¡ch Lot.
    *   **âš ï¸ Cá»±c ká»³ quan trá»ng:** Sau khi sinh Lot, thá»§ kho báº¯t buá»™c pháº£i nháº­p giÃ¡ trá»‹ **"Sá»‘ Lot No cá»§a nhÃ  cung cáº¥p"** vÃ o cá»™t **"Äáº·c tÃ­nh 10"** (`LotAttr10` / `LotExtText10`) Ä‘á»ƒ há»‡ thá»‘ng cháº¡y hÃ m parse tá»± Ä‘á»™ng tÃ­nh ra ngÃ y sáº£n xuáº¥t vÃ  thá»i háº¡n háº¿t háº¡n. Náº¿u cá»™t nÃ y bá»‹ bá» trá»‘ng hoáº·c khÃ´ng nháº£y ngÃ y háº¿t háº¡n, Lot sáº½ tá»± Ä‘á»™ng bá»‹ há»‡ thá»‘ng Ä‘Æ°a vÃ o kho áº£o **`HOLDING`** khi xuáº¥t kho vÃ  khÃ´ng thá»ƒ cáº¥p phÃ¡t cho sáº£n xuáº¥t. Náº¿u gáº·p sá»± cá»‘ Ä‘iá»n Lot No Ä‘Ãºng nhÆ°ng khÃ´ng nháº£y Ä‘áº·c tÃ­nh ngÃ y, hÃ£y bÃ¡o ngay cho EA Team.
*   **BÆ°á»›c 3 (XÃ¡c nháº­n nháº­p kho):** Chá»‰ khi káº¿t quáº£ kiá»ƒm tra IQC táº¡i mÃ n hÃ¬nh **C220** cá»§a Lot hÃ ng Ä‘Ã³ Ä‘Ã£ chuyá»ƒn tráº¡ng thÃ¡i **"PASS"** thÃ¬ thá»§ kho má»›i cÃ³ thá»ƒ thá»±c hiá»‡n nháº¥n 2 nÃºt **"Káº¿t thÃºc nháº­p kho"** vÃ  **"XÃ¡c nháº­n nháº­p kho"** táº¡i F330. Viá»‡c nháº¥n Ä‘á»§ 2 nÃºt nÃ y lÃ  báº¯t buá»™c Ä‘á»ƒ káº¿t thÃºc quy trÃ¬nh nháº­p.

    > ðŸš¦ **Tham chiáº¿u má»Ÿ rá»™ng:** Chi tiáº¿t logic, mÃ£ SQL debug, vÃ  cÃ¡ch má»Ÿ rá»™ng cho cá»•ng cháº·n IQC nháº­p kho (F330/C220) Ä‘Æ°á»£c tá»•ng há»£p táº¡i **[KB_14 Â§6.3 NhÃ³m 11 â€” F330/C220 IQC](../KB_14/KB_14_01_METHODOLOGY.md#nhÃ³m-11-f330c220--cháº·n-nháº­p-kho-iqc-validation-liÃªn-phÃ²ng-ban)**.

#### 4. Cáº¥p phÃ¡t sáº£n xuáº¥t & Quy trÃ¬nh hoÃ n tráº£ NVL (F430, F610, F620)
*   **Xuáº¥t kho ra chuyá»n (F430):** Sá»­ dá»¥ng nÃºt "NguyÃªn liá»‡u Ä‘áº§u ra" Ä‘á»ƒ xuáº¥t NVL ra CellLine theo nguyÃªn táº¯c FIFO. Náº¿u Lot nÃ o thiáº¿u ngÃ y sáº£n xuáº¥t á»Ÿ Ä‘áº·c tÃ­nh 10, há»‡ thá»‘ng sáº½ tá»± Ä‘á»™ng chuyá»ƒn Lot Ä‘Ã³ vÃ o kho HOLDING.
*   **Quy trÃ¬nh hoÃ n tráº£ NVL (Returns):**
    *   **TrÆ°á»ng há»£p 1 (Xuáº¥t nháº§m Line hoáº·c HoÃ n tráº£ 100%):** Náº¿u xuáº¥t nháº§m Line hoáº·c xuáº¥t ra bao nhiÃªu (vÃ­ dá»¥ 500) mÃ  tráº£ láº¡i nguyÃªn váº¹n báº¥y nhiÃªu (500), thá»§ kho sá»­ dá»¥ng nÃºt **"NguyÃªn liá»‡u Ä‘áº§u vÃ o"** táº¡i mÃ n hÃ¬nh **F430** Ä‘á»ƒ nháº­p láº¡i kho.
    *   **TrÆ°á»ng há»£p 2 (Tráº£ láº¡i sá»‘ dÆ° thá»«a - HoÃ n tráº£ má»™t pháº§n):** Náº¿u xuáº¥t ra line 500 con, sáº£n xuáº¥t sá»­ dá»¥ng háº¿t 100 con vÃ  tráº£ láº¡i kho 400 con dÆ° thá»«a, **TUYá»†T Äá»I KHÃ”NG** dÃ¹ng mÃ n hÃ¬nh F430. Quy trÃ¬nh báº¯t buá»™c lÃ :
        1.  VÃ o mÃ n hÃ¬nh **F610** Ä‘á»ƒ thá»±c hiá»‡n bÆ°á»›c 1 nháº­p láº¡i kho.
        2.  VÃ o mÃ n hÃ¬nh **F620** Ä‘á»ƒ thá»±c hiá»‡n bÆ°á»›c 2 xÃ¡c nháº­n nháº­p láº¡i sá»‘ dÆ° 400 con.
        3.  Tiáº¿n hÃ nh quy trÃ¬nh nháº­p kho bÃ¬nh thÆ°á»ng vÃ  thá»±c hiá»‡n tÃ¡ch tem táº¡i **F740** Ä‘á»ƒ in láº¡i tem nhÃ£n tÆ°Æ¡ng á»©ng vá»›i sá»‘ lÆ°á»£ng thá»±c táº¿ tráº£ vá».

#### 5. BÃ¡o cÃ¡o tá»“n kho & Lá»‹ch sá»­ kho (F721, F761, F740)
*   **F761 (Lá»‹ch sá»­ NVL vÃ o kho):** Tra cá»©u toÃ n bá»™ lá»‹ch sá»­ nháº­p kho. ChÃº Ã½ cá»™t `DocTypeName` náº¿u hiá»ƒn thá»‹ chá»¯ tiáº¿ng HÃ n Ä‘áº¡i diá»‡n cho giao dá»‹ch hoÃ n tráº£ tá»« sáº£n xuáº¥t, cÃ¡c trÆ°á»ng há»£p cÃ²n láº¡i lÃ  nháº­p má»›i tá»« phiáº¿u F312. Tab "Summary" phá»¥c vá»¥ bá»™ pháº­n Káº¿ toÃ¡n Ä‘á»‘i soÃ¡t.
*   **F721 (BÃ¡o cÃ¡o tá»“n kho NVL & Vá»‹ trÃ­):** DÃ¹ng Ä‘á»ƒ xem tá»“n kho NVL hiá»‡n táº¡i vÃ  thá»±c hiá»‡n gÃ¡n vá»‹ trÃ­ váº­t lÃ½ (Location). Thá»§ kho nháº­p vá»‹ trÃ­ vÃ  mÃ£ nguyÃªn váº­t liá»‡u, quÃ©t mÃ£ LotID Ä‘á»ƒ cáº­p nháº­t vá»‹ trÃ­ lÃªn há»‡ thá»‘ng (cÃ³ thá»ƒ lÆ°u tá»«ng Lot hoáº·c chá»n táº¥t cáº£ rá»“i báº¥m lÆ°u Ä‘á»“ng loáº¡t). ThÃ´ng tin nÃ y sáº½ Ä‘á»“ng bá»™ trá»±c tiáº¿p lÃªn mÃ n hÃ¬nh Tivi giÃ¡m sÃ¡t vá»‹ trÃ­ kho (`192.168.1.234:9000/tv`).
*   **F740 (TÃ¡ch Lot theo sá»‘ lÆ°á»£ng):** DÃ¹ng Ä‘á»ƒ chia tÃ¡ch 1 Lot cÃ³ sá»‘ lÆ°á»£ng lá»›n thÃ nh nhiá»u Lot nhá» theo nhu cáº§u thá»±c táº¿ (vÃ­ dá»¥: tÃ¡ch 1 Lot 400 thÃ nh 300 vÃ  100). Nháº­p sá»‘ lÆ°á»£ng cáº§n tÃ¡ch, nÃºt **"SplitLot"** sáº½ sÃ¡ng lÃªn Ä‘á»ƒ thá»±c hiá»‡n thao tÃ¡c tÃ¡ch Lot.

---


---

## 5. ðŸ“¦ Kho ThÃ nh Pháº©m (Finished Goods WMS - Gá»™p tá»« KB_08)


### 1. Lá»—i HÃ ng xuáº¥t á»Ÿ HN551 nhÆ°ng tá»“n kho HN866 váº«n cÃ²n

**TÆ° duy trace:**
- **HN551 (Xuáº¥t):** Ghi vÃ o `STB_VN_FINISHGOODS_HN_Export` vÃ  Ä‘Ã¡nh dáº¥u "Ä‘Ã£ Ä‘i" vÃ o sá»• tá»“n kho.
- **HN866 (Tá»“n):** Chá»‰ Ä‘á»c sá»• tá»“n kho â€” cÃ¡i nÃ o `QtyOutput = 0` thÃ¬ hiá»‡n lÃªn.
- **NguyÃªn nhÃ¢n thÆ°á»ng gáº·p:** HN551 Ä‘Ã£ ghi sá»• xuáº¥t nhÆ°ng **quÃªn cáº­p nháº­t** sá»• tá»“n kho.

```sql
DECLARE @PackingID NVARCHAR(50) = 'PKHN023117'

-- BÆ¯á»šC 1: Kiá»ƒm tra tráº¡ng thÃ¡i xuáº¥t kho
SELECT CodeExport, PackingID, LotNo, Qty, StatusExport, CreateDateTime
FROM STB_VN_FINISHGOODS_HN_Export WHERE PackingID = @PackingID

-- BÆ¯á»šC 2: Kiá»ƒm tra tá»“n kho thá»±c táº¿
-- QtyOutput = 0 nhÆ°ng BÆ¯á»šC 1 cÃ³ data â†’ Lá»–I LOGIC TRá»ª KHO
SELECT PackingID, Quantity, QtyOutput
FROM FinishGoodMESInstock_HN WHERE PackingID = @PackingID

-- BÆ¯á»šC 3: Kiá»ƒm tra Packing lÃ  "Tem To" hay "Tem Nhá»"
SELECT PackingID FROM STB_PackingOutPutFinishGoods_HN
WHERE PackingOutPutFinishGoodsID = @PackingID
-- CÃ³ káº¿t quáº£ â†’ Tem To â†’ xuáº¥t 1 mÃ£ nÃ y sáº½ tá»± Ä‘á»™ng xuáº¥t cÃ¡c box con bÃªn trong
```

**Fix (náº¿u QtyOutput sai):**
```sql
-- âš ï¸ XÃ¡c minh DB (2026-05-17): Báº£ng KHÃ”NG cÃ³ cá»™t StatusInstock â€” chá»‰ cÃ³ QtyOutput
UPDATE FinishGoodMESInstock_HN
SET QtyOutput = Quantity
WHERE PackingID = @PackingID

UPDATE STB_VN_FINISHGOODS_HN_Export
SET StatusExport = 1
WHERE PackingID = @PackingID
```

> **SP xuáº¥t kho:** `ExportWarehouseFinshGoodInventory_uid`

---

### 2. PhÃ¢n biá»‡t Tem To vÃ  Tem Nhá» (HÃ  Nam)

| Loáº¡i tem | Äá»‹nh nghÄ©a | Báº£ng DB | Khi xuáº¥t |
|----------|-----------|---------|---------|
| **Tem To** (Pallet/Gá»™p) | Äáº¡i diá»‡n cho nhiá»u thÃ¹ng gá»™p láº¡i | `STB_PackingOutPutFinishGoods_HN` | Tá»± Ä‘á»™ng xuáº¥t táº¥t cáº£ box con bÃªn trong |
| **Tem Nhá»** (Box Ä‘Æ¡n) | DÃ¡n trÃªn tá»«ng thÃ¹ng riÃªng láº» | KhÃ´ng cÃ³ trong báº£ng trÃªn | Xuáº¥t tá»«ng box riÃªng |

```sql
-- Kiá»ƒm tra PackingID lÃ  Tem To hay Tem Nhá»
SELECT COUNT(*) AS [SoKetQua]
FROM STB_PackingOutPutFinishGoods_HN
WHERE PackingOutPutFinishGoodsID = 'PKHN023117'
-- CÃ³ káº¿t quáº£ â†’ Tem To | KhÃ´ng cÃ³ â†’ Tem Nhá»
```

---

### 2.1 Lá»—i Unique Constraint khi Gá»™p TÃºi BÃ³ng (HN544) â€” PKQN2100175

**Triá»‡u chá»©ng:** Khi User nháº­p `Packing ID: PKQN2100175` trÃªn mÃ n hÃ¬nh **[HN544] Gá»™p tÃºi bÃ³ng thÃ nh há»™p nhá»** vÃ  nháº¥n TÃ¬m kiáº¿m, há»‡ thá»‘ng bÃ¡o lá»—i:
> **Column 'LotID' is constrained to be unique. Value '63RHHL180ME16XB001QN2100012' is already present.**

##### ðŸ”´ NguyÃªn nhÃ¢n gá»‘c rá»…:
Stored Procedure `usp_GetMaterialLotInfo_Packing_VVT_F3` sá»­ dá»¥ng `UNION ALL` Ä‘á»ƒ gá»™p 3 truy váº¥n:

1. **Truy váº¥n 1:** QuÃ©t `STB_MaterialLotInfo` cÃ³ `PackingID = 'PKQN2100175'` â†’ TÃ¬m **1 dÃ²ng** (LotID: `63RHHL180ME16XB001QN2100012`)
2. **Truy váº¥n 2:** QuÃ©t tá»« `STB_PackingNilonToBoxSmall_HN` (há»™p nhá» gá»™p)
3. **Truy váº¥n 3 (Lá»–I):** QuÃ©t `STB_DividePackaging` cÃ³ `PackingID = 'PKQN2100175'`
   - DÃ²ng nÃ y lÃ  **mÃ£ cha chÆ°a Ä‘Æ°á»£c chia tÃ¡ch**, nÃªn cá»™t `PackingParentID` bá»‹ **NULL/trá»‘ng**
   - JOIN condition: `LEFT JOIN STB_MaterialLotInfo MLI ON MLI.LotNo = DP.LotNo and MLI.PackingID = DP.PackingParentID`
   - VÃ¬ `DP.PackingParentID = NULL`, LEFT JOIN khÃ´ng khá»›p â†’ **tráº£ vá» dÃ²ng dummy vá»›i `LotID = NULL`**
   - Káº¿t quáº£: Truy váº¥n 3 tráº£ vá» **dÃ²ng thá»© 2 cÃ³ `LotID = NULL`**

4. **Khi DataTable nháº­n dá»¯ liá»‡u:** DataTable cÃ³ constraint `Unique = true` trÃªn cá»™t `LotID`
   - Client-side code Ä‘iá»n giÃ¡ trá»‹ máº·c Ä‘á»‹nh tá»« dÃ²ng 1 â†’ **Duplicate LotID**
   - Ngoáº¡i lá»‡ Ä‘Æ°á»£c nÃ©m ra

##### ðŸ› ï¸ **Giáº£i phÃ¡p:**

**Script 1: Há»§y giao dá»‹ch lá»—i (Revert Merge)**
```sql
BEGIN TRANSACTION;
BEGIN TRY

    -- 1. SAO LÆ¯U Báº¢NG Há»˜P NHá»Ž TRÆ¯á»šC KHI XÃ“A
    IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'STB_PackingNilonToBoxSmall_HN_BK')
    BEGIN
        SELECT * INTO STB_PackingNilonToBoxSmall_HN_BK 
        FROM STB_PackingNilonToBoxSmall_HN 
        WHERE PackingNilonToBoxSmallID = 'PK202605210000000005';
    END
    ELSE
    BEGIN
        INSERT INTO STB_PackingNilonToBoxSmall_HN_BK
        SELECT * 
        FROM STB_PackingNilonToBoxSmall_HN 
        WHERE PackingNilonToBoxSmallID = 'PK202605210000000005';
    END

    -- 2. XÃ“A GIAO Dá»ŠCH Lá»–I á»ž STB_DividePackaging
    DELETE FROM STB_DividePackaging 
    WHERE PackingID = 'PKQN2100175';
    
    -- 3. XÃ“A RECORD Há»˜P NHá»Ž
    DELETE FROM STB_PackingNilonToBoxSmall_HN 
    WHERE PackingNilonToBoxSmallID = 'PK202605210000000005';

    COMMIT TRANSACTION;
    PRINT '==> HOÃ€N THÃ€NH Há»¦Y GIAO Dá»ŠCH THÃ€NH CÃ”NG!';

END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;
    PRINT '==> CÃ“ Lá»–I Xáº¢Y RA. ÄÃƒ ROLLBACK!';
    SELECT ERROR_MESSAGE() AS ErrorMessage;
END CATCH;
```

**Script 2: Sá»­a Stored Procedure (NgÄƒn cháº·n lá»—i láº·p láº¡i)**

Sá»­a Ä‘á»•i cÃ¢u truy váº¥n 3 Ä‘á»ƒ loáº¡i trá»« cÃ¡c mÃ£ cha chÆ°a phÃ¢n tÃ¡ch:

```sql
USE [SmartFactoryV2]
GO

-- TÃ¬m ra pháº§n UNION ALL cuá»‘i cÃ¹ng (truy váº¥n 3)
-- ThÃªm Ä‘iá»u kiá»‡n: AND ISNULL(DP.PackingParentID, '') <> ''

-- THÃŠM DÃ’NG NÃ€Y vÃ o cuá»‘i WHERE clause cá»§a UNION ALL thá»© 3:
WHERE DP.PackingID = @pPackingID  
  AND ISNULL(DP.PackingParentID, '') <> ''  -- â† DÃ’NG Má»šI
```

> **SP Ä‘áº§y Ä‘á»§:** Xem chi tiáº¿t Stored Procedure tÆ°Æ¡ng á»©ng trong database Ä‘á»ƒ Ã¡p dá»¥ng thay Ä‘á»•i trÃªn.

---

### 3. Lá»—i Lot bá»‹ Ä‘á»•i MaterialCode sau khi sáº£n xuáº¥t (VD: 5H1 â†’ 6D1)

**Triá»‡u chá»©ng:** HÃ ng Ä‘ang nháº­p liá»‡u vá»›i Making = 5H1 nhÆ°ng sau Ä‘Ã³ trÃªn há»‡ thá»‘ng bá»‹ chuyá»ƒn sang 6D1.

```sql
-- BÆ°á»›c 1: Kiá»ƒm tra MaterialCode hiá»‡n táº¡i
SELECT SI.Barcode, SI.MaterialCode, SI.InputLineCode, SI.CreateDateTime
FROM STB_SetInfo SI
WHERE SI.Barcode IN ('pkpt2000146', 'pkpt2000147', 'pkpt2000145')

-- BÆ°á»›c 2: Kiá»ƒm tra lá»‹ch sá»­ thay Ä‘á»•i MaterialCode
SELECT * FROM STB_LotChangeMaterialHistory
WHERE NewBarcode IN ('pkpt2000146', 'pkpt2000147', 'pkpt2000145')
   OR OldBarcode IN ('pkpt2000146', 'pkpt2000147', 'pkpt2000145')
ORDER BY CreateDateTime DESC

-- BÆ°á»›c 3: Fix â€” Ä‘á»•i láº¡i MaterialCode Ä‘Ãºng
UPDATE STB_SetInfo SET MaterialCode = '5H1_MATERIAL_CODE_ÄÃšNG'
WHERE Barcode IN ('pkpt2000146', 'pkpt2000147', 'pkpt2000145')

UPDATE STB_MaterialLotInfo SET MaterialCode = '5H1_MATERIAL_CODE_ÄÃšNG'
WHERE LotNo IN ('pkpt2000146', 'pkpt2000147', 'pkpt2000145')

#### 3.1 ÄÄƒng kÃ½ thay Ä‘á»•i mÃ£ váº­t tÆ° thá»§ cÃ´ng qua STB_ChangeMaterialCode_HN (MÃ n hÃ¬nh HN15)
Trong má»™t sá»‘ trÆ°á»ng há»£p táº¡i nhÃ  mÃ¡y HÃ  Nam, khi ngÆ°á»i dÃ¹ng thá»±c hiá»‡n thay Ä‘á»•i mÃ£ váº­t tÆ° cho Lot Ä‘Ã³ng gÃ³i vÃ  cáº§n ghi nháº­n lá»‹ch sá»­ vÃ o há»‡ thá»‘ng Ä‘á»ƒ theo dÃµi vÃ  Ä‘á»“ng bá»™ kho, ta thá»±c hiá»‡n chÃ¨n dá»¯ liá»‡u lá»‹ch sá»­ Ä‘á»•i mÃ£ váº­t tÆ°:
```sql
INSERT INTO STB_ChangeMaterialCode_HN (
    oldMaterialCode, 
    IsUsed, 
    CreateDateTime, 
    CreateUserID, 
    NewMaterialCode, 
    PackingID, 
    LotID
)
VALUES (
    '2VSC820MC8XXXXVC01', -- MÃ£ váº­t tÆ° cÅ©
    1,                    -- Tráº¡ng thÃ¡i sá»­ dá»¥ng (Active)
    GETDATE(),            -- NgÃ y táº¡o
    'vanduc',             -- User thá»±c hiá»‡n
    '2RSC820MC7XXXXB001', -- MÃ£ váº­t tÆ° má»›i
    'PKQN1100015',        -- MÃ£ thÃ¹ng Ä‘Ã³ng gÃ³i (PackingID)
    'SP260511-001'        -- MÃ£ Lot sáº£n pháº©m (LotID)
);
```

---

### 4. Lá»—i mÃ n HNC321 (Qc nháº­p NG sáº£n pháº©m mang Ä‘i kiá»ƒm tra â€” BÃ¡o lá»—i chá»¯ HÃ n Quá»‘c)

Chi tiáº¿t vá» triá»‡u chá»©ng, nguyÃªn nhÃ¢n vÃ  cÃ¡c phÆ°Æ¡ng Ã¡n bypass (bao gá»“m script SQL chÃ¨n lá»‹ch sá»­ giáº£ láº­p) Ä‘á»‘i vá»›i lá»—i nháº­p pháº¿ mÃ n HNC321, vui lÃ²ng tham kháº£o táº¡i:
ðŸ‘‰ [../KB_05/KB_05_01_QC_AND_ELECTRODE_CORE.md Â§ Ká»‹ch báº£n 3 â€” Lá»—i nháº­p pháº¿ mÃ n HNC321 bÃ¡o lá»—i tiáº¿ng HÃ n](../KB_05/KB_05_01_QC_AND_ELECTRODE_CORE.md#ká»‹ch-báº£n-sá»±-cá»‘-kháº©n-cáº¥p-3-lá»—i-nháº­p-pháº¿-hnc321-bÃ¡o-lá»—i-tiáº¿ng-hÃ n)

---

### 5. XÃ³a nháº­p sáº£n lÆ°á»£ng cÃ´ng Ä‘oáº¡n (VD: VE260509-004)

**Triá»‡u chá»©ng:** Cáº§n há»§y/xÃ³a dá»¯ liá»‡u nháº­p sáº£n lÆ°á»£ng á»Ÿ 1 cÃ´ng Ä‘oáº¡n cá»¥ thá»ƒ.

> âš ï¸ **LÆ°u Ã½:** XÃ³a phiáº¿u F330 (nháº­p kho NVL) cáº§n xÃ³a IQC trÆ°á»›c (náº¿u cÃ³).

**XÃ³a sáº£n lÆ°á»£ng cÃ´ng Ä‘oáº¡n:**
```sql
-- BÆ°á»›c 1: Xem lá»‹ch sá»­ routing cá»§a Barcode
SELECT * FROM STB_ProdRouteHist
WHERE ControlNo = (SELECT ControlNo FROM STB_SetInfo WHERE Barcode = 'VE260509-004')
ORDER BY ProdDateTime DESC

-- BÆ°á»›c 2: XÃ³a dÃ²ng lá»‹ch sá»­ routing cáº§n xÃ³a (VD: VE08)
DELETE FROM STB_ProdRouteHist
WHERE ControlNo = (SELECT ControlNo FROM STB_SetInfo WHERE Barcode = 'VE260509-004')
AND RouteCode = 'VE08'

-- BÆ°á»›c 3: Reset DefectQty náº¿u cáº§n
UPDATE STB_SetInfo
SET DefectQty = 0, IsDefect = 0
WHERE Barcode = 'VE260509-004'
-- Chá»‰ lÃ m náº¿u DefectQty thá»±c sá»± cáº§n reset
```

**XÃ³a phiáº¿u nháº­p kho F330 (cÃ³ IQC):**
ðŸ‘‰ **Chi tiáº¿t Script Fix:** Xem táº¡i [KB_02_01_WMS_CORE.md Â§ 4.16](KB_02_01_WMS_CORE.md)

---

### 6. HN00 â€” Tá»“n Kho ThÃ nh Pháº©m HÃ  Nam

**Chá»©c nÄƒng:** MÃ n hÃ¬nh quáº£n lÃ½ thÃ nh pháº©m riÃªng cho nhÃ  mÃ¡y **HÃ  Nam (VVT_F3)**.

- Route: HÃ  Nam dÃ¹ng prefix `VE-` (thay vÃ¬ `V-` cá»§a Báº¯c Ninh)
- Barcode: `VE260507-001` format
- ÄÆ¡n giÃ¡: Láº¥y tá»« **HN101** theo mÃ£ káº¿ toÃ¡n

```sql
-- Kiá»ƒm tra tá»“n kho thÃ nh pháº©m HÃ  Nam
SELECT PackingID, MaterialCode, Quantity, QtyOutput,
       Quantity - QtyOutput AS [TonThucTe]
FROM FinishGoodMESInstock_HN
WHERE Quantity - QtyOutput > 0
ORDER BY CreateDateTime DESC
```

---

### 7. HN101 â€” Thiáº¿t Láº­p ÄÆ¡n GiÃ¡ Theo MÃ£ Káº¿ ToÃ¡n

**Chá»©c nÄƒng:** Thiáº¿t láº­p Ä‘Æ¡n giÃ¡ â†’ há»‡ thá»‘ng tá»± Ä‘á»™ng tÃ­nh tiá»n theo mÃ£ káº¿ toÃ¡n hiá»ƒn thá»‹ táº¡i HN00.

**Quy trÃ¬nh:** TÃ¬m kiáº¿m â†’ (+) ThÃªm â†’ Äiá»n Ä‘áº§y Ä‘á»§ â†’ LÆ°u

```sql
-- Kiá»ƒm tra Ä‘Æ¡n giÃ¡ Ä‘Ã£ cÃ³ chÆ°a (âš ï¸ Báº£ng ná»™i bá»™ HÃ  Nam, cÃ³ thá»ƒ lÃ  View hoáº·c báº£ng táº¡m)
SELECT * FROM STB_HN_AccountingPrice WHERE MaterialCode = 'MÃ£_Model'

-- ThÃªm Ä‘Æ¡n giÃ¡ má»›i
INSERT INTO STB_HN_AccountingPrice (MaterialCode, AccountingCode, Price, CreateDateTime, CreateUserID)
VALUES ('MÃ£_Model', 'MÃ£_Káº¿_ToÃ¡n', 0.254, GETDATE(), 'vinaadmin')
```

---

### 8. FG02 â€” Kho ThÃ nh Pháº©m Báº¯c Giang (FG00)

**Chá»©c nÄƒng:** MÃ n hÃ¬nh quáº£n lÃ½ thÃ nh pháº©m riÃªng cho nhÃ  mÃ¡y **Báº¯c Giang (VVT_F2)**.

- Route: Báº¯c Giang dÃ¹ng prefix `V-` (thay vÃ¬ `VE-` cá»§a HÃ  Nam)
- Barcode: `VVXX123R000001` format
- Báº£ng: `STB_VN_FINISHGOODS_BG`

```sql
-- Kiá»ƒm tra tá»“n kho thÃ nh pháº©m Báº¯c Giang
SELECT IDCODE, MaterialCode, Quantity, CreateDate, DateExport
FROM STB_VN_FINISHGOODS_BG
WHERE CreateDate >= DATEADD(DAY, -30, GETDATE())
ORDER BY CreateDate DESC
```

**Sá»­a ngÃ y mÃ n FG00:**
```sql
-- Xem trÆ°á»›c
SELECT IDCODE, CreateDate, DateExport FROM STB_VN_FINISHGOODS_BG
WHERE IDCODE = 'FGVN_BG20250211054041195484931'

-- Sá»­a cáº£ 2 cá»™t ngÃ y
UPDATE STB_VN_FINISHGOODS_BG
SET CreateDate = CAST('2025-01-11' AS DATE),
    DateExport = CAST('2025-01-11' AS DATE)
WHERE IDCODE = 'FGVN_BG20250211054041195484931'
```

**So sÃ¡nh HN00 vs FG00:**

| Äáº·c Ä‘iá»ƒm | HN00 (HÃ  Nam) | FG00 (Báº¯c Giang) |
|----------|---------------|------------------|
| Báº£ng | `FinishGoodMESInstock_HN` | `STB_VN_FINISHGOODS_BG` |
| Route prefix | `VE-` | `V-` |
| Barcode format | `VE260507-001` | `VVXX123R000001` |
| ÄÆ¡n giÃ¡ | HN101 (theo mÃ£ káº¿ toÃ¡n) | KhÃ´ng cÃ³ mÃ n thiáº¿t láº­p riÃªng |

*Cáº­p nháº­t: 2026-05-22*


---


---

> ðŸ”— **Tra cá»©u Bug theo Screen ID cho WMS (F-series, HN-series):** Xem táº¡i [KB_31_SCREEN_BUG_FIXBOOK.md](../KB_31_SCREEN_BUG_FIXBOOK.md) â€” tá»•ng há»£p Ä‘áº§y Ä‘á»§ theo TCode.

*Cáº­p nháº­t: 2026-06-18*
