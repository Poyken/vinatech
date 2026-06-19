var sql = require("mssql");
// Database Configuration
var config = {
  user: "vinaadmin",
  password: "vina1234%6&8",
  server: "dbserver.hycap.co.kr",
  port: 5398,
  database: "SmartFactoryV2",
  dialect: "mssql",
  dialectOptions: {
    abortTransactionOnError: true,
    enableArithAbort: true,
    encrypt: false,
    instanceName: "MSSQLSERVER",
  },
};

var config = {
  user: "vinaadmin",
  password: "vina1234%6&8",
  server: "dbserver.hycap.co.kr",
  port: 5398,
  database: "SmartFactoryV2",
  options: {
    encrypt: false,
  },
};

//database remote issue
const SmartFactoryV2 = ""; //"[dbserver.hycap.co.kr,5398].SmartFactoryV2.dbo.";
const SmartFramework = "SmartFramework.dbo.";
const SmartFactoryIncubator = "SmartFactoryIncubator.dbo.";

//database common function
function getQueryForTable(ID, tableID, sqlStr, headerStr) {
  sql.connect(config, function (err) {
    if (err) console.log(err);

    var request = new sql.Request();

    request.query(sqlStr, function (err, recordset) {
      if (err) {
        console.log("Something went wrong" + err);
      } else {
        var headerList = headerStr.split("|");

        var result = recordset.recordset;

        var tableHtml = "<table class='table' id='" + tableID + "'>";
        tableHtml += "<thead>";
        tableHtml += "<tr>";
        tableHtml += "<th scope='col'>#</th>";
        for (var i = 0; i < headerList.length; i++) {
          tableHtml += "<th>" + headerList[i] + "</th>";
        }
        tableHtml += "</tr>";
        tableHtml += "</thead>";

        tableHtml += "<tbody>";

        for (var i = 0; i < result.length; i++) {
          tableHtml += "<tr>";
          tableHtml += "<td>" + (i + 1) + "</td>";
          for (var key in result[i]) {
            tableHtml += "<td>" + result[i][key] + "</td>";
          }
          tableHtml += "</tr>";
        }

        tableHtml += "</tbody>";
        tableHtml += "</table>";

        document.getElementById(ID).innerHTML = tableHtml;
      }
    });

    requestClose(sql);
  });
}

function getQueryForSelectPicker(ID, SelectPickerID, callback, sqlStr) {
  console.log(ID, SelectPickerID, callback, sqlStr);

  sql.connect(config, function (err) {
    if (err) console.log(err);

    var request = new sql.Request();

    request.query(sqlStr, function (err, recordset) {
      if (err) {
        console.log("Something went wrong" + err);
        console.log("--loi ròi");
      } else {
        console.log(recordset.recordset);

        var result = recordset.recordset;

        var selectPickerHtml =
          "<select onChange='" +
          callback +
          "' class='form-control form-control-lg' aria-label='.form-select-lg example' id='" +
          SelectPickerID +
          "'>";

        if (callback == "")
          selectPickerHtml =
            "<select class='form-control form-control-lg' aria-label='.form-select-lg example' id='" +
            SelectPickerID +
            "'>";

        selectPickerHtml += "<option value='' selected>Lựa chọn</option>";

        for (var i = 0; i < result.length; i++) {
          selectPickerHtml +=
            "<option value='" +
            result[i]["value"] +
            "'>" +
            (result[i]["valueText"] && result[i]["valueText"] == "화성"
              ? "Forming(Tạo hình)"
              : result[i]["valueText"] && result[i]["valueText"] == "에칭"
                ? "Etching(Khắc)"
                : result[i]["valueText"]) +
            "</option>";
        }

        selectPickerHtml += "</select>";

        document.getElementById(ID).innerHTML = selectPickerHtml;
      }
    });

    requestClose(sql);
  });
}

function callProcedure(procedureName, parameterStr, parameterValue, weight1) {
  sql.connect(config, function (err) {
    if (err) console.log(err);

    var request = new sql.Request();

    var pStr = parameterStr.split("|");
    var pValue = parameterValue.split("|");

    for (var i = 0; i < pStr.length; i++) {
      var paramName = pStr[i];
      var paramValue = pValue[i];

      request.input(paramName, sql.NVarChar(100), paramValue);
    }

    request.execute(procedureName, function (err, recordsets, returnValue) {
      if (err == null) {

        if (!sessionStorage.counter1) sessionStorage.counter1 = '0';

        if (procedureName.indexOf('usp_vietnam_barcodeWeight') >= 0) {
          sessionStorage.counter1 = parseInt(sessionStorage.counter1) + 1;
          if (parseInt(sessionStorage.counter1) == parseInt(sessionStorage.sotuibong1) + 2) delLot1(parseInt(sessionStorage.sotuibong1) + 2);
        }
        // sendPrinterDefault(weight1);
        if (recordsets) recordsets = recordsets.recordsets;
        if (recordsets) recordsets = recordsets[0];
        if (recordsets) recordsets = recordsets[0];

        if (recordsets && procedureName.indexOf('usp_Vvt_TieuChuanPacking_Vvt') >= 0) {
          sessionStorage.modelcode1 = recordsets.modelcode;
          sessionStorage.thungNgoai1 = recordsets.thungNgoai;
          sessionStorage.thungtrong1 = recordsets.thungtrong;
          sessionStorage.tuibong1 = recordsets.tuibong;
          sessionStorage.sotuibong1 = recordsets.sotuibong;

          //document.getElementById('info1').innerHTML= JSON.stringify(recordsets).replace('modelcode','Mã ').replace('thungNgoai','Thùng Ngoài ').replace('thungtrong','Thùng Trong ').replace('tuibong','Túi Bóng ').replace('sotuibong','Qty ');

        }

        //document.getElementById('portid').innerHTML= JSON.stringify(returnValue);

        setTimeout(function () {
          //location.reload();
          //if(localStorage.LotPacking)
          //document.getElementById("LotPacking").value=localStorage.LotPacking;		
          //if(document.getElementById("LotPacking").value)
          //document.getElementById("searchElectrodeStepInfo").click();
        }, 3000);

        if (procedureName.indexOf('usp_vietnam_barcodeWeight') >= 0) {
          alert("⚡ OK, Gửi dữ liệu cân thành phẩm hoàn thành.");
          sessionStorage.clear();
        }

      } else {
        alert('⚠ ' + err);
        console.log(err);
      }
    });

    requestClose(sql);
  });
}

function requestClose(sql) {
  //sql.end();
}

function callElectrodeStepInfoProc() {
  //var result = callProcedure(SmartFactoryV2+'usp_Vvt_TieuChuanPacking_Vvt', 'pBarCode', document.getElementById('LotPacking').value,'noalert');
  checkStandardQuantity(document.getElementById('LotPacking').value);
  //console.log(result);
  ///document.getElementById('errorid').innerHTML= JSON.stringify(result);
}


function delLot1(aa) {
  sessionStorage.counter1 = '0';
  if (aa) document.getElementById("errorid0").innerHTML = "Đã upload " + aa + " lần quy cách 2 lần tiêu chuẩn + số túi bóng của lót hàng:" + document.getElementById("LotPacking").value;
  document.getElementById("LotPacking").value = "";
  localStorage.LotPacking = "";
  document.getElementById("info1").innerHTML = "";
  document.getElementById("LotPacking").focus();
}

function getQueryForSelectPickerProc(
  ID,
  SelectPickerID,
  callback,
  procedureName,
  parameterStr,
  parameterValue
) {
  sql.connect(config, function (err) {
    if (err) console.log(err);

    var request = new sql.Request();

    var pStr = parameterStr.split("|");
    var pValue = parameterValue.split("|");

    for (var i = 0; i < pStr.length; i++) {
      var paramName = pStr[i];
      var paramValue = pValue[i];

      request.input(paramName, sql.NVarChar(100), paramValue);
    }

    request.execute(procedureName, function (err, recordsets, returnValue) {
      console.log(err);
      console.log(recordsets);
      console.log(returnValue);

      if (err == null) {
        var result = recordsets.recordset;

        var selectPickerHtml =
          "<select onChange='" +
          callback +
          "' class='form-control form-control-lg' aria-label='.form-select-lg example' id='" +
          SelectPickerID +
          "'>";

        if (callback == "")
          selectPickerHtml =
            "<select class='form-control form-control-lg' aria-label='.form-select-lg example' id='" +
            SelectPickerID +
            "'>";

        selectPickerHtml += "<option value='' selected>Lựa chọn</option>";

        for (var i = 0; i < result.length; i++) {
          selectPickerHtml +=
            "<option value='" +
            result[i]["value"] +
            "'>" +
            result[i]["valueText"] +
            "</option>";
        }

        selectPickerHtml += "</select>";

        document.getElementById(ID).innerHTML = selectPickerHtml;
      } else {
        alert('⚠ ' + err);
        console.log(err);
      }
    });

    requestClose(sql);
  });
}

function getQueryForTableProc(
  ID,
  tableID,
  procedureName,
  parameterStr,
  parameterValue,
  headerStr
) {
  sql.connect(config, function (err) {
    if (err) console.log(err);

    var request = new sql.Request();

    var pStr = parameterStr.split("|");
    var pValue = parameterValue.split("|");

    for (var i = 0; i < pStr.length; i++) {
      var paramName = pStr[i];
      var paramValue = pValue[i];

      request.input(paramName, sql.NVarChar(100), paramValue);
    }

    request.execute(procedureName, function (err, recordsets, returnValue) {
      if (err) {
        console.log("Something went wrong" + err);
      } else {
        var headerList = headerStr.split("|");

        var result = recordsets.recordset;

        var tableHtml = "<table class='table' id='" + tableID + "'>";
        tableHtml += "<thead>";
        tableHtml += "<tr>";
        tableHtml += "<th scope='col'>#</th>";
        for (var i = 0; i < headerList.length; i++) {
          tableHtml += "<th>" + headerList[i] + "</th>";
        }
        tableHtml += "</tr>";
        tableHtml += "</thead>";

        tableHtml += "<tbody>";

        for (var i = 0; i < result.length; i++) {
          tableHtml += "<tr>";
          tableHtml += "<td>" + (i + 1) + "</td>";
          for (var key in result[i]) {
            tableHtml += "<td>" + result[i][key] + "</td>";
          }
          tableHtml += "</tr>";
        }

        tableHtml += "</tbody>";
        tableHtml += "</table>";

        document.getElementById(ID).innerHTML = tableHtml;
      }
    });

    requestClose(sql);
  });
}

//page functions
function electrodeRouteList() {
  return;
  var procedureName = SmartFactoryV2 + "usp_RouteInfo_electron";
  var processID = "";
  var processLanguage = "";
  var companyCode = "VVT";
  var workCenterCode = "VVT_F1";
  var routeList = "Route-01,Route-02,Route-03,Route-11";

  var parameterStr =
    "pProcessUserID" +
    "|pProcessLanguage" +
    "|pCompanyCode" +
    "|pWorkCenterCode" +
    "|pRouteType";

  var parameterValue =
    processID +
    "|" +
    processLanguage +
    "|" +
    companyCode +
    "|" +
    workCenterCode +
    "|" +
    routeList;

  getQueryForSelectPickerProc(
    "routeSelectDiv",
    "routeCode",
    "electrodeMachineList();electrodeDefectList()",
    procedureName,
    parameterStr,
    parameterValue
  );
}

function electrodeMachineList() {
  return;
  var routeCode = $("#routeCode").val();
  var companyCode = "VVT";
  var workCenterCode = "VVT_F1";

  getQueryForSelectPicker(
    "machineSelectDiv",
    "machineCode",
    "",
    "SELECT MCM.MachineCode AS value, " +
    "MCM.MachineName AS valueText " +
    "FROM " +
    SmartFactoryV2 +
    "STB_ProductMachine PM " +
    " INNER JOIN " +
    SmartFactoryV2 +
    "STB_MachineMaster MCM ON PM.MachineCode = MCM.MachineCode " +
    " WHERE MCM.CompanyCode = '" +
    companyCode +
    "'" +
    "   AND MCM.WorkCenterCode = '" +
    workCenterCode +
    "'" +
    "   AND MCM.IsProdMachine = 1 " +
    "   AND PM.RouteCode = '" +
    routeCode +
    "'"
  );
}

function electrodeDefectList() {
  return;
  var routeCode = $("#routeCode").val();
  var companyCode = "VVT";
  var workCenterCode = "VVT_F1";

  getQueryForSelectPicker(
    "defectSelectDiv",
    "defectCode",
    "",
    "SELECT DI.DefectCode AS value, " +
    "DI.DefectDesc AS valueText " +
    "FROM " +
    SmartFactoryV2 +
    "STB_DefectInfo DI " +
    " WHERE DI.IsUsed = 1" +
    "   AND DI.DefectGroupCode = '" +
    routeCode +
    "' "
  );
}

function ewCategory2() {
  return;
  var codeGroup = "EWCategory2";

  getQueryForSelectPicker(
    "ewCategory2Div",
    "currentCollectorClassCode",
    "",
    "SELECT ItemCode AS value, " +
    "Description AS valueText " +
    "FROM " +
    SmartFramework +
    "STB_BaseCode " +
    " WHERE CodeGroup = '" +
    codeGroup +
    "'"
  );
}

function callElectrodeWasteSubmitProc() {
  var chkResult = checkFormData();

  sessionStorage.pcsesvalue1 = '';

  if (chkResult) {
    var procedureName =
      SmartFactoryV2 + "usp_vietnam_barcodeWeight";
    //SmartFactoryV2 + "usp_DoCreateElectrodeWasteInfoNew_electron";
    var parameterStr =
      "pLotPacking" +
      // "|pJobDate" +
      // "|pRouteCode" +
      // "|pCurrentCollectorClassCode" +
      // "|pMachineCode" +
      // "|pDefectCode" +
      "|pDefectWeight" +
      "|pUnitW" +
      "|pPcs" +
      "|pRemark" +
      "|pOddQty";


    var tmp1 = document.getElementById("defectWeight").value;
    tmp1 = tmp1 ? parseFloat(tmp1) : 0;
    if (!Number.isFinite(tmp1)) tmp1 = 0;

    if (document.getElementById("defectWeight").value && tmp1 == 0) {
      alert('⚠ Giá trị NetWeight thiếu hoặc không hợp lệ.')
      return;
    }



    var tmp2 = document.getElementById("UnitW").value;
    tmp2 = tmp2 ? parseFloat(tmp2) : 0;
    if (!Number.isFinite(tmp2)) tmp2 = 0;

    if (document.getElementById("UnitW").value && tmp2 == 0) {
      alert('⚠ Giá trị Unit Weight thiếu hoặc không hợp lệ.')
      return;
    }



    var tmp2 = document.getElementById("textpcs").value;
    tmp2 = tmp2 ? parseFloat(tmp2) : 0;
    if (!Number.isFinite(tmp2)) tmp2 = 0;

    if (document.getElementById("textpcs").value && tmp2 == 0) {
      alert('⚠ Giá trị Unit Weight thiếu hoặc không hợp lệ.')
      return;
    }


    var weight1 = tmp1; //+ tmp2;

    var parameterValue =
      document.getElementById("LotPacking").value +
      // "|" +
      // document.getElementById("jobDate").value +
      // "|" +
      // document.getElementById("routeCode").value +
      // "|" +
      // document.getElementById("currentCollectorClassCode").value +
      // "|" +
      // document.getElementById("machineCode").value +
      // "|" +
      // document.getElementById("defectCode").value +
      "|" +
      document.getElementById("defectWeight").value +
      "|" +
      document.getElementById("UnitW").value +
      "|" +
      document.getElementById("textpcs").value +
      "|" +
      document.getElementById("remark").value +
      "|" +
      document.getElementById("LotOdd").value;

    var result = callProcedure(procedureName, parameterStr, parameterValue, weight1);
  }
}

function callElectrodeWasteSubmitProcLotle() {
  var chkResult = checkFormData();

  sessionStorage.pcsesvalue1 = '';

  if (chkResult) {
    var procedureName =
      SmartFactoryV2 + "usp_vietnam_barcodeWeight";
    //SmartFactoryV2 + "usp_DoCreateElectrodeWasteInfoNew_electron";
    var parameterStr =
      "pLotPacking" +
      // "|pJobDate" +
      // "|pRouteCode" +
      // "|pCurrentCollectorClassCode" +
      // "|pMachineCode" +
      // "|pDefectCode" +
      "|pDefectWeight" +
      "|pUnitW" +
      "|pPcs" +
      "|pRemark" +
      "|pOddQty";


    var tmp1 = document.getElementById("defectWeight").value;
    tmp1 = tmp1 ? parseFloat(tmp1) : 0;
    if (!Number.isFinite(tmp1)) tmp1 = 0;

    if (document.getElementById("defectWeight").value && tmp1 == 0) {
      alert('⚠ Giá trị NetWeight thiếu hoặc không hợp lệ.')
      return;
    }



    var tmp2 = document.getElementById("UnitW").value;
    tmp2 = tmp2 ? parseFloat(tmp2) : 0;
    if (!Number.isFinite(tmp2)) tmp2 = 0;

    if (document.getElementById("UnitW").value && tmp2 == 0) {
      alert('⚠ Giá trị Unit Weight thiếu hoặc không hợp lệ.')
      return;
    }



    var tmp2 = document.getElementById("textpcs").value;
    tmp2 = tmp2 ? parseFloat(tmp2) : 0;
    if (!Number.isFinite(tmp2)) tmp2 = 0;

    if (document.getElementById("textpcs").value && tmp2 == 0) {
      alert('⚠ Giá trị Unit Weight thiếu hoặc không hợp lệ.')
      return;
    }


    var weight1 = tmp1; //+ tmp2;
    var LotOdd = 99.99
    var parameterValue =
      document.getElementById("LotPackingLotOdd").value +
      // "|" +
      // document.getElementById("jobDate").value +
      // "|" +
      // document.getElementById("routeCode").value +
      // "|" +
      // document.getElementById("currentCollectorClassCode").value +
      // "|" +
      // document.getElementById("machineCode").value +
      // "|" +
      // document.getElementById("defectCode").value +
      "|" +
      document.getElementById("defectWeight").value +
      "|" +
      document.getElementById("UnitW").value +
      "|" +
      document.getElementById("textpcs").value +
      "|" +
      document.getElementById("remark").value +
      "|" + LotOdd
    //document.getElementById("LotOdd").value;

    var result = callProcedure(procedureName, parameterStr, parameterValue, weight1);
  }
}
function checkStandardQuantity(barcode) {
  sql.connect(config, function (err) {
    if (err) console.log(err);
    var procedureName =
      SmartFactoryV2 + "usp_Vvt_TieuChuanPacking_Vvt";
    var request = new sql.Request();

    request.input('pBarCode', sql.NVarChar(100), document.getElementById("LotPacking").value);

    request.execute(procedureName, function (err, recordsets, returnValue) {
      if (err == null) {

        if (recordsets) recordsets = recordsets.recordsets;
        if (recordsets) recordsets = recordsets[0];
        if (recordsets) recordsets = recordsets[0];

        if (recordsets && procedureName.indexOf('usp_Vvt_TieuChuanPacking_Vvt') >= 0) {
          sessionStorage.modelcode1 = recordsets.modelcode;
          sessionStorage.thungNgoai1 = recordsets.thungNgoai;
          sessionStorage.thungtrong1 = recordsets.thungtrong;
          sessionStorage.soluongsetting1 = recordsets.soluongsetting;
          sessionStorage.tuibong1 = recordsets.tuibong;
          sessionStorage.sotuibong1 = recordsets.sotuibong;
          sessionStorage.tieuchuanthua1 = recordsets.tieuchuanthua;
          document.getElementById("soluongtrongthung").innerHTML = recordsets.sotuibong
          document.getElementById('info1').innerHTML = JSON.stringify(recordsets).replace('modelcode', 'Mã ').replace('thungNgoai', 'Thùng Ngoài ').replace('thungtrong', 'Thùng Trong ').replace('soluongsetting', 'Số lượng setting').replace('tuibong', 'Túi Bóng ').replace('sotuibong', 'Qty ').replace('tieuchuanthua', 'Tiêu chuẩn thừa');
          //document.getElementById('info1').innerHTML= JSON.stringify(recordsets.modelcode);

          console.log(JSON.stringify(recordsets))
          // kiểm tra xem số lượng cân có bằng với số lượng được thiết lập trong csdl hay không
          var pcsNumber = parseInt(document.getElementById("textpcs").value);
          if (parseInt(recordsets.soluongsetting) == pcsNumber) {

            sessionStorage.soluongsettinglocal = recordsets.soluongsetting;
            alert('⚡ OK, Đủ số lượng tiêu chuẩn ');
          }
          else {
            alert('⚠ chưa đủ số lượng tiêu chuẩn :' + recordsets.soluongsetting);
          }
          //end
        }

        return true;
      } else {
        alert('⚠ ' + err);
        console.log(err);
        return false;
      }
    });
    requestClose(sql);
  });


}

