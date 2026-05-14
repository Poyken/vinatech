const sql = require('mssql');

const config = {
    user: "vinaadmin",
    password: "vina1234%6&8",
    server: "dbserver.hycap.co.kr",
    port: 5398,
    database: "SmartFactoryV2",
    options: {
        encrypt: false,
    },
};

const packingIDs = ['PKHN023117', 'PKHN930210'];

async function checkInventoryData() {
    try {
        await sql.connect(config);
        console.log(`--- CHECKING DATA FOR PACKING IDs: ${packingIDs.join(', ')} ---`);

        for (const pid of packingIDs) {
            console.log(`\n>>> ANALYZING: ${pid}`);

            // 1. Check in STB_VN_FINISHGOODS_HN_New
            const inNew = await sql.query`SELECT * FROM STB_VN_FINISHGOODS_HN_New WHERE PackingID = ${pid}`;
            console.log(`- STB_VN_FINISHGOODS_HN_New: ${inNew.recordset.length} records`);
            if (inNew.recordset.length > 0) console.table(inNew.recordset.map(r => ({LotNo: r.LotNo, PackQty: r.PackQty, CreateDateTime: r.CreateDateTime})));

            // 2. Check in STB_VN_FINISHGOODS_HN_Export
            const inExport = await sql.query`SELECT * FROM STB_VN_FINISHGOODS_HN_Export WHERE PackingID = ${pid} OR PackingID IN (SELECT PackingID FROM STB_DividePackaging WHERE PackingParentID = ${pid})`;
            console.log(`- STB_VN_FINISHGOODS_HN_Export: ${inExport.recordset.length} records`);
            if (inExport.recordset.length > 0) console.table(inExport.recordset.map(r => ({CodeExport: r.CodeExport, LotNo: r.LotNo, Qty: r.Qty, PackingID: r.PackingID})));

            // 3. Check in FinishGoodMESInstock_HN
            const inInstock = await sql.query`SELECT * FROM FinishGoodMESInstock_HN WHERE PackingID = ${pid} OR MergeBoxSmallID = ${pid}`;
            console.log(`- FinishGoodMESInstock_HN: ${inInstock.recordset.length} records`);
            if (inInstock.recordset.length > 0) console.table(inInstock.recordset.map(r => ({PackingID: r.PackingID, LotNo: r.LotNo, Quantity: r.Quantity, QtyOutput: r.QtyOutput, MergeBoxSmallID: r.MergeBoxSmallID})));

            // 4. Check in STB_DividePackaging
            const inDivide = await sql.query`SELECT * FROM STB_DividePackaging WHERE PackingID = ${pid} OR PackingParentID = ${pid}`;
            console.log(`- STB_DividePackaging: ${inDivide.recordset.length} records`);
            if (inDivide.recordset.length > 0) console.table(inDivide.recordset.map(r => ({PackingID: r.PackingID, PackingParentID: r.PackingParentID, Qty: r.Qty})));
        }

    } catch (err) {
        console.error('❌ LỖI:', err.message);
    } finally {
        await sql.close();
    }
}

checkInventoryData();
