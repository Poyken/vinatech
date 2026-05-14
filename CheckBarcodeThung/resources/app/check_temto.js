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

async function checkTemTo() {
    try {
        await sql.connect(config);
        console.log(`--- CHECKING STB_PackingOutPutFinishGoods_HN ---`);

        for (const pid of packingIDs) {
            const result = await sql.query`SELECT * FROM STB_PackingOutPutFinishGoods_HN WHERE PackingOutPutFinishGoodsID = ${pid}`;
            console.log(`- ${pid}: ${result.recordset.length} records in STB_PackingOutPutFinishGoods_HN`);
        }

    } catch (err) {
        console.error('❌ LỖI:', err.message);
    } finally {
        await sql.close();
    }
}

checkTemTo();
