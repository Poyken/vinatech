var sql = require("mssql");


const SmartFactoryV2 = "";
const SmartFramework = "SmartFramework.dbo.";
const SmartFactoryIncubator = "SmartFactoryIncubator.dbo.";

//database common function
function getQueryForTable(ID, tableID, sqlStr, headerStr) {
  sql.connect(config, function (err) {
    if (err) console.log(err);

    var request = new sql.Request();

    request.query(sqlStr, function (err, recordset) {
      if (err) {
        console.log("Xảy ra sự cố " + err);
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
  sql.connect(config, function (err) {
    if (err) console.log(err);

    var request = new sql.Request();

    request.query(sqlStr, function (err, recordset) {
      if (err) {
        console.log("Something went wrong" + err);
      } else {
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
            result[i]["valueText"] +
            "</option>";
        }

        selectPickerHtml += "</select>";

        document.getElementById(ID).innerHTML = selectPickerHtml;
      }
    });

    requestClose(sql);
  });
}

function callProcedure(procedureName, parameterStr, parameterValue) {
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
	
	console.log(procedureName, parameterStr, parameterValue);

    request.execute(procedureName, function (err, recordsets, returnValue) {
      if (err == null) {
        //clearMaterialWeight();

        sessionStorage.comweightvalue1=1;
		
		setTimeout(function () {
			//location.reload();
		  //if(localStorage.electrodeLotNumber)
			//domElectrodeLotNumber.value=localStorage.electrodeLotNumber;		
			//if(domElectrodeLotNumber.value)
				//document.getElementById("searchElectrodeStepInfo").click();
        }, 2000);
		
        alert("⚡ Xử lý bước Cân thành công. ☺",1);
		
		//location.reload();

        
      } else {
        alert('⚠ ☹ '+err);
        console.log(err);
      }
	  
	 // callElectrodeStepInfoProc();
	  
    });

    requestClose(sql);
  });
}

function requestClose(sql) {
  //sql.end();
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

        selectPickerHtml += "<option value='' selected>선택</option>";

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
        alert('⚠ ☹ '+err);
        console.log(err);
      }
    });

    requestClose(sql);
  });
}







function getQueryForMixingConfigProc1(
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
        console.log("Something went wrong " + err);
      } else {
        var headerList = headerStr.split("|");

        var result = recordsets.recordset;
		
		console.log('recordsets=',recordsets);
		console.log('returnValue=',returnValue);

        var tableHtml =
          "<table class='table table-hover' id='" + tableID + "'>";
        tableHtml += "<thead class='thead-dark'>";
        tableHtml += "<tr>";
        tableHtml += "<th scope='col'>#</th>";
        for (var i = 0; i < headerList.length; i++) {
          tableHtml += "<th>" + headerList[i] + "</th>";
        }
        tableHtml += "</tr>";
        tableHtml += "</thead>";

        tableHtml += "<tbody>";

        for (var i = 0; i < result.length; i++) {
			//console.log('sdfs-df-dsf-sdf-dsf--:',procedureName,result[i]);
          if (i == 0 && result[i] && result[i]["nextstep"])
            checkMaterialSpec("", "", result[i]["nextstep"]);

          tableHtml += "<tr id='" + tableID + (i + 1) + "' class=''>";
          tableHtml += "<td>" + (i + 1) + "</td>";
          for (var key in result[i]) {
            tableHtml +=
              "<td>" +
              (result[i][key] &&
              result[i][key].toString().indexOf("증류수") >= 0
                ? result[i][key] + " / Nước cất / DI-WATER"
                : result[i][key] &&
                  result[i][key].toString().indexOf("활성탄") >= 0
                ? result[i][key] + " / Than hoạt tính"
                : result[i][key]) +
              "</td>";
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

    parameterValue=parameterValue.split('|')[0];


    for (var i = 0; i < pStr.length; i++) {
      var paramName = pStr[i];
      var paramValue = pValue[i];

      request.input(paramName, sql.NVarChar(100), paramValue);
    }

    request.execute(procedureName, function (err, recordsets, returnValue) {

      if (err) {
          console.log("⚠ ☹ Kiểm tra lại kết nối, hoặc bấm nút LÀM MỚI MÀN HÌNH " + err);
          alert("⚠ ☹ Kiểm tra lại kết nối, hoặc bấm nút LÀM MỚI MÀN HÌNH ");
          return;
      } else {

		   var result = recordsets.recordset;

        if(!result.length && procedureName.indexOf('usp_Electro')>=0){
          alert("⚠ ☹ Không tìm thấy dữ liệu, hoặc sai mã Lót: `"+parameterValue+"`",1);
          localStorage.electrodeLotNumber="";
          localStorage.focuslot=1;
          //location.reload();
          return;
        } 
		  
		  if(parameterStr.indexOf("pBarcode")>=0 && parameterValue) {
        sessionStorage.conditionlotprint = parameterValue;
        localStorage.electrodeLotNumber = parameterValue;
      }
        var headerList = headerStr.split("|");            

        var tableHtml =
          "<table class='table table-hover' id='" + tableID + "'>";
        tableHtml += "<thead class='thead-dark'>";
        tableHtml += "<tr>";
        tableHtml += "<th scope='col'>#</th>";
        for (var i = 0; i < headerList.length; i++) {
          tableHtml += "<th>" + headerList[i] + "</th>";
        }
        tableHtml += "</tr>";
        tableHtml += "</thead>";

        tableHtml += "<tbody>";

        for (var i = 0; i < result.length; i++) {
			//console.log('sdfs-df-dsf-sdf-dsf--:',procedureName,result[i]);
          if (i == 0 && result[i] && result[i]["nextstep"])
            checkMaterialSpec("", "", result[i]["nextstep"]);

          tableHtml += "<tr id='" + tableID + (i + 1) + "' class=''>";
          tableHtml += "<td>" + (i + 1) + "</td>";
          for (var key in result[i]) {
            var tmpweight = parseFloat(result[i]['InputQty1']) +    parseFloat(result[i]['InputQty2']);
            
            if(key.indexOf('reprint')>=0 ){
              
              if(result[i]['CreateUserID']=='eai' &&        
              result[i]['reprint']     &&
              tmpweight >= parseFloat(result[i]['StdMinVal']) &&            
              tmpweight <= parseFloat(result[i]['StdMaxVal']) 
            ){

              var dat = new Date(); 
              dat = dat.getFullYear() +'-'+ (dat.getMonth()+1).toString() +'-' + dat.getDate() 
     
            //  var text1=  '<div style="font-size:160px;transform: rotate(-90deg);position: absolute;display:block;    left: 0px;bottom:150px;    font-weight: 700;font-family: Tahoma;"> <p>'+
            //       sessionStorage.conditionlotprint.toUpperCase()+'</p> <p>('+result[i]['ElectrodeStepCode']+') _ ('+result[i]['seq']+') _ ('+result[i]['MaterialName']+')</p> <p> DATE:  '+
            //       dat+'</p> <p> TIME: '+(new Date()).toLocaleTimeString()+' </p> <p>WEIGHT: '+result[i]['InputQty1']+' KG</p> </div>';
              
            //  var text2=  !result[i]['InputQty2']?"":'<div style="font-size:160px;transform: rotate(-90deg);position: absolute;display:block;    left: 0px;bottom:150px;    font-weight: 700;font-family: Tahoma;"> <p>'+
            //       sessionStorage.conditionlotprint.toUpperCase()+'</p> <p>('+result[i]['ElectrodeStepCode']+') _ ('+result[i]['seq']+') _ ('+result[i]['MaterialName']+')</p> <p> DATE:  '+
            //       dat+'</p> <p> TIME: '+(new Date()).toLocaleTimeString()+' </p> <p>WEIGHT: '+result[i]['InputQty2']+' KG</p> </div>';
                 
              tableHtml +=
              '<td> <button type="button" class="btn btn-primary"   onClick="reprintLabel('+result[i]['InputQty1']+','+result[i]['InputQty2']+',\''+result[i]['ElectrodeStepCode']+'\',\''+result[i]['seq']+'\',\''+result[i]['MaterialName']+'\')">RePrint</button> </td>';               
            }
            else{
              tableHtml +='<td> </td>';
            }
            result[i]['CreateUserID']='';
            result[i]['CreateDateTime']='';

            delete result[i]['CreateUserID'];
            delete result[i]['CreateDateTime'];
            continue;
            }

            tableHtml +=
              "<td>" +
              (result[i][key] &&
              result[i][key].toString().indexOf("증류수") >= 0
                ? result[i][key] + " / Nước cất / DI-WATER"
                : result[i][key] &&
                  result[i][key].toString().indexOf("활성탄") >= 0
                ? result[i][key] + " / Than hoạt tính"
                : result[i][key]) +
              "</td>";
          }
          tableHtml += "</tr>";
        }

        tableHtml += "</tbody>";
        tableHtml += "</table>";

        document.getElementById(ID).innerHTML = tableHtml;

        if(result.length>0) domMaterialLotNumber.focus();

      }
    });

    requestClose(sql);
  });
}

function checkVendorLot(value,stopalert) {
		 
  if(!value) value = domMaterialLotNumber.value;
  console.log(value);

  if(!value){
    alert("⚠ ☹ Chưa nhập dữ liệu Vendor Lót");
    return;
  }

  //if(!stopalert)
  setTimeout(function(){
    if(domMaterialLotNumber) domMaterialLotNumber.focus();
    alert("⚠ ☹ Vui lòng Scan lại Vendor Lot ");
    //checkVendorLot('',1);    
  },8000);

  virtualScanInputFocus();
 
  var electrodeLotNumber = domElectrodeLotNumber.value;

  var materialpresent = document.getElementsByClassName("bg-success");

  materialpresent =
    materialpresent && materialpresent.length
      ? materialpresent[materialpresent.length - 1]
      : materialpresent;

  materialpresent =
    materialpresent && materialpresent.cells
      ? materialpresent.cells[4]
      : materialpresent;

  materialpresent = materialpresent
    ? materialpresent.innerText
    : materialpresent;

  console.log(materialpresent);

  getQueryForMixingConfigProc1(
    "errorid",
    "errorid",
    SmartFactoryV2 + "usp_Vietnam_ElectrodeMixingConfig_get",
    "pElectrodeBarcode|pMaterialCode|pVendorQRcode" + (localStorage.isNight?'|pOrder':''),
    electrodeLotNumber + "|" + materialpresent + "|" + value + (localStorage.isNight?'|kdem':''),
    "Mã NVL | Tên NVL | Tên thiết lập | Tiền tố | Hậu tố | Chứa văn bản | Thuộc tính 1 | Thuộc tính 2 | Chiều dài chuỗi | Bước số | Bước chuỗi | Trạng thái"
  );


}

function getQueryForBindingProc(
  procedureName,
  parameterStr,
  parameterValue,
  columnStr,
  bindingTargetStr
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
        console.log("Xảy ra sự cố " + err);
      } else {
        // var bindingTargetList = bindingTargetStr.split("|");
        // var columnList = columnStr.split("|");

        // var result = recordsets.recordset;
        // //console.log(result);

        // for (var i = 0; i < bindingTargetList.length; i++) {
        //   document.getElementById(bindingTargetList[i]).value =
        //     result[0][columnList[i]];
        //   console.log(result[0][columnList[i]]);
        // }
        var bindingTargetList = bindingTargetStr.split("|");
        var columnList = columnStr.split("|");

        var result = recordsets.recordset;

        if (result && result[0] && result[0]["MaterialName"]) {
        } 
		else 
		{			
		    if(procedureName != 'usp_GetElectroMixPresentStep_vietnam')
			  alert( "⚠ ☹ Không tìm thấy dữ liệu, hoặc sai mã Lot .: `" +	 domElectrodeLotNumber.value +"`" );
        localStorage.focuslot=1;
        return;
    }

        for (var i = 0; i < bindingTargetList.length; i++) {
          var matname = result[0]["MaterialName"];

          matername = matname;//? matname.split('^')[1]:matname;

          var valuei = result[0][columnList[i]];

          document.getElementById(bindingTargetList[i]).value = (columnList[i]=="MaterialName" && valuei && valuei.indexOf('^')>=0?valuei.split('^')[0]:valuei);

          console.log(valuei);

            // matname &&
            // matname == "증류수" &&
            // bindingTargetList &&
            // bindingTargetList[i] &&
            // bindingTargetList[i] == "stdMinVal" &&
            // localStorage.defaultElecProc
            //   ? 0
            //   : matname &&
            //     matname == "증류수" &&
            //     bindingTargetList &&
            //     bindingTargetList[i] &&
            //     bindingTargetList[i] == "stdMaxVal" &&
            //     localStorage.defaultElecProc
            //   ? 100
            //   : result[0][columnList[i]];
          
        }
      }
    });

    requestClose(sql);
  });
}

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
//page functions
function electrodeRouteList() {
  var procedureName = SmartFactoryV2 + "usp_RouteInfo_electron";
  var processID = "";
  var processLanguage = "";
  var companyCode = "VNT";
  var workCenterCode = "VNT_F1";
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
  var routeCode = $("#routeCode").val();
  var companyCode = "VNT";
  var workCenterCode = "VNT_F1";

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
  var routeCode = $("#routeCode").val();
  var companyCode = "VNT";
  var workCenterCode = "VNT_F1";

  getQueryForSelectPicker(
    "defectSelectDiv",
    "defectCode",
    "",
    "SELECT DI.DefectCode AS value, " +
      "DI.BasicDefectName AS valueText " +
      "FROM " +
      SmartFactoryV2 +
      "STB_DefectInfo DI " +
      " WHERE DI.IsUsed = 1" +
      "   AND DI.DefectGroupCode = '" +
      routeCode +
      "'"
  );
}

function ewCategory2() {
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

  if (chkResult) {
    var procedureName =
      SmartFactoryV2 + "usp_DoCreateElectrodeWasteInfoNew_electron";
    var parameterStr =
      "pElectrodeLotNumber" +
      "|pJobDate" +
      "|pRouteCode" +
      "|pCurrentCollectorClassCode" +
      "|pMachineCode" +
      "|pDefectCode" +
      "|pDefectWeight" +
      "|pRemark";

    var parameterValue =
      domElectrodeLotNumber.value +
      "|" +
      document.getElementById("jobDate").value +
      "|" +
      document.getElementById("routeCode").value +
      "|" +
      document.getElementById("currentCollectorClassCode").value +
      "|" +
      document.getElementById("machineCode").value +
      "|" +
      document.getElementById("defectCode").value +
      "|" +
      document.getElementById("defectWeight").value +
      "|" +
      document.getElementById("remark").value;

    var result = callProcedure(procedureName, parameterStr, parameterValue);
  }
}

function callElectrodeStepInfoProc() {
  tmpnextstep = "";
  
  if(localStorage.electrodeLotNumber && domElectrodeLotNumber)
		domElectrodeLotNumber.value=localStorage.electrodeLotNumber;
	
  var electrodeLotNumber = domElectrodeLotNumber.value;

	if(!electrodeLotNumber) return;

  getQueryForTableProc(
    "electrodeStepInfo",
    "electrodeStepInfoTable",
    SmartFactoryV2 +
      (localStorage.defaultElecProc || "usp_ElectrodeStep_electron"),
    "pBarcode"+ (localStorage.isNight?'|pOrder':''),
    electrodeLotNumber+ (localStorage.isNight?'|kdem':''),
    "Tên mặt hàng | Trình tự | Bước | Vật liệu pha chế | Giới hạn dưới | Giới hạn trên | Thời gian làm việc | Trọng lượng vật liệu 1 | Trọng lượng vật liệu 2 | Ghi chú | rePrint?"
  );

  //Nhận thông tin cấp độ hiện tại
  getPresentMixStepInfo();

  //Tắt nút Tiếp theo
  $("#nextElectrodeStepInfo").attr("disabled", true);
  clearMaterialWeight();
}

function getPresentMixStepInfo() {
  var electrodeLotNumber = domElectrodeLotNumber.value;

  getQueryForBindingProc(
    SmartFactoryV2 + "usp_GetElectroMixPresentStep_vietnam",
    "pBarcode"+ (localStorage.isNight?'|pOrder':''),
    electrodeLotNumber+ (localStorage.isNight?'|kdem':''),
    "ElectrodeStepCode|seq|MaterialName|StdMinVal|StdMaxVal|UniqueSeq",
    "electrodeStepCode|seq|materialName|stdMinVal|stdMaxVal|uniqueSeq"
  );

  setInterval(presentMixStepMark, 3000);
}
