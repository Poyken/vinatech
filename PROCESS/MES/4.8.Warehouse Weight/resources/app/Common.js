function getTodayStr(ID, delimiter) {
  var today = new Date();
  var dd = String(today.getDate()).padStart(2, "0");
  var mm = String(today.getMonth() + 1).padStart(2, "0"); //January is 0!
  var yyyy = today.getFullYear();

  today = yyyy + delimiter + mm + delimiter + dd;

  document.getElementById(ID).value = today;
}

function initFormData() {
  document.getElementById("LotPacking").value = "";
  document.getElementById("LotPacking").focus();
  getTodayStr("jobDate", "-");
  document.getElementById("routeCode").value = "";
  document.getElementById("machineCode").value = "";
  document.getElementById("currentCollectorClassCode").value = "";
  document.getElementById("defectCode").value = "";
  document.getElementById("defectWeight").value = "";
  document.getElementById("remark").value = "";
  document.getElementById("UnitW").value = "";
}

function checkFormData() {
  var LotPacking =
    document.getElementById("LotPacking").value == null
      ? ""
      : document.getElementById("LotPacking").value;
  var jobDate =
    document.getElementById("jobDate").value == null
      ? ""
      : document.getElementById("jobDate").value;
  var routeCode =
    document.getElementById("routeCode").value == null
      ? ""
      : document.getElementById("routeCode").value;
  var machineCode =
    document.getElementById("machineCode").value == null
      ? ""
      : document.getElementById("machineCode").value;
  var currentCollectorClassCode =
    document.getElementById("currentCollectorClassCode").value == null
      ? ""
      : document.getElementById("currentCollectorClassCode").value;
  var defectCode =
    document.getElementById("defectCode").value == null
      ? ""
      : document.getElementById("defectCode").value;
  var defectWeight =
    document.getElementById("defectWeight").value == null
      ? ""
      : document.getElementById("defectWeight").value;
  var remark =
    document.getElementById("remark").value == null
      ? ""
      : document.getElementById("remark").value;


  console.log("chạy vào comon");
  if (!remark) {
    alert('⚠ Vui lòng chọn lại tên của bạn ở NGƯỜI CÂN mỗi 12 giờ / một lần!'); return;
  }


  if (
    LotPacking == "" ||
    //jobDate == "" ||
    //routeCode == "" ||
    //machineCode == "" ||
    //currentCollectorClassCode == "" ||
    //defectCode == "" ||
    defectWeight == ""//||
    //remark==""
  ) {
    alert("⚠ Mã   LOT   và   CÂN NẶNG    phải được điền vào !");
    return false;
  }
  return true;
}


function readElectrodeWasteWeight(ID) {
  var fs = require("fs");

  fs.readFile("ew", "utf8", function (err, data) {
    if (data && data != "") {
      document.getElementById(ID).value = data;
    }
  });
}

function clearElectrodeWasteWeight() {
  var fs = require("fs");

  var defectWeight = document.getElementById("defectWeight").value;

  fs.readFile("ew", "utf8", function (err, data) {
    if (data == defectWeight) {
      fs.writeFile("ew", "", "utf8", function (error) {
        console.log("clear!");
      });
    }
  });
}

function electrodeWasteWeightFileMon() {
  //return;
  readElectrodeWasteWeight("defectWeight");

  setTimeout(function () {
    clearElectrodeWasteWeight();
  }, 1000);
}
