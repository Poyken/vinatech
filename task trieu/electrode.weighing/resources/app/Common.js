function getTodayStr(ID, delimiter) {
  var today = new Date();
  var dd = String(today.getDate()).padStart(2, "0");
  var mm = String(today.getMonth() + 1).padStart(2, "0"); //January is 0!
  var yyyy = today.getFullYear();

  today = yyyy + delimiter + mm + delimiter + dd;

  document.getElementById(ID).value = today;
}

function initFormData() {
  domElectrodeLotNumber.value = "";
  getTodayStr("jobDate", "-");
  document.getElementById("routeCode").value = "";
  document.getElementById("machineCode").value = "";
  document.getElementById("currentCollectorClassCode").value = "";
  document.getElementById("defectCode").value = "";
  document.getElementById("defectWeight").value = "";
  document.getElementById("remark").value = "";
}

function checkFormData() {
  var datetime1 ;
  var datetime2 ;
  
	try{	
	   datetime1 = $("#bindingStartDateTime").data("datetimepicker").date();
	   datetime2 = $("#bindingEndDateTime").data("datetimepicker").date();
	}catch{
		datetime1 = new Date();
		datetime2 = new Date();
	}

  var electrodeLotNumber =
    !domElectrodeLotNumber.value.trim()
      ? ""
      : domElectrodeLotNumber.value.trim();

  var materialWeight1 =
    !document.getElementById(strmaterialWeight1).value.trim()
      ? ""
      : document.getElementById(strmaterialWeight1).value;

  var materialWeight2 =
    document.getElementById(strmaterialWeight2).value.trim()
      ? ""
      : document.getElementById(strmaterialWeight2).value;

  var bindingStartDateTime = moment(datetime1).format("YYYY-MM-DD HH:mm:ss");
  var bindingEndDateTime = moment(datetime2).format("YYYY-MM-DD HH:mm:ss");
  var materialLotNumber =
    !domMaterialLotNumber.value.trim()
      ? ""
      : domMaterialLotNumber.value;

  if (
    electrodeLotNumber == "" ||
    //bindingStartDateTime == "" ||
    //bindingEndDateTime == "" ||
    materialLotNumber == ""
  ) {
    alert(
      "⚠ ☹ Yêu cầu nhập đầy đủ thông tin: 1. Mã Lot điện cực, 2.Mã Lot Vendor"
    );
    return false;
  }

  return true;
}

function setAddClass(ID, addClassName) {
  $("#" + ID).addClass(addClassName);
}

function presentMixStepMark() {
  var uniqueSeq = document.getElementById("uniqueSeq")? document.getElementById("uniqueSeq").value:'-';
  setAddClass("electrodeStepInfoTable" + uniqueSeq, "bg-success");
}

const isEmpty = (value) => {
  if (value === null) return true;
  if (typeof value === "undefined") return true;
  if (typeof value === "string" && value === "") return true;
  if (Array.isArray(value) && value.length < 1) return true;
  if (
    typeof value === "object" &&
    value.constructor.name === "Object" &&
    Object.keys(value).length < 1 &&
    Object.getOwnPropertyNames(value) < 1
  )
    return true;
  if (
    typeof value === "object" &&
    value.constructor.name === "String" &&
    Object.keys(value).length < 1
  )
    return true;
  if (value == 0) return true;

  return false;
};

const checkMaterialSpec = (val1, val2, nextstep) => {
  //값이 없으면 0으로 채움
  //두 값을 합쳐 기준 스팩과 비교
  //스팩을 만족하면 Next버튼 활성화

  try {
    val1 = val1 || document.getElementById(strmaterialWeight1).value;
    val2 = val2 || document.getElementById(strmaterialWeight2).value;
  } catch {}

  var tmp = val1.replace(/[0-9.]/g, "");
  var tmp2 = val2.replace(/[0-9.]/g, "");
  if (tmp.length || tmp2.length) {
    $("#nextElectrodeStepInfo").attr("disabled", true);
    alert(
      "⚠ ☹ Giá trị cân nặng không đúng, chỉ cho phép giá trị số từ 0 đến 9, hoặc có dấu chấm (.) ngăn cách thập phân !"
    );
    document.getElementById(strmaterialWeight1).value='';
    document.getElementById(strmaterialWeight2).value='';
    return;
  }

  if (isEmpty(val1)) val1 = 0;
  if (isEmpty(val2)) val2 = 0;

  val1 = parseFloat(val1);
  val2 = parseFloat(val2);

  if (!isFinite(val1)) val1 = 0;
  if (!isFinite(val2)) val2 = 0;

  var finalWeightVal = val1 + val2;

  console.log("val1=", val1);
  console.log("val2=", val2);
  console.log("finalWeightVal=", finalWeightVal);

  var minVal = $("#stdMinVal").val();
  var maxVal = $("#stdMaxVal").val();

  console.log("minVal=", minVal);
  console.log("maxVal=", maxVal);
  console.log("nextstep11111=", nextstep,tmpnextstep);

  if (!nextstep && tmpnextstep) nextstep = tmpnextstep;

  if (
    finalWeightVal > 0 &&
    finalWeightVal >= minVal &&
    finalWeightVal <= maxVal
  ) {    
    if (nextstep && nextstep == "OK")
      $("#nextElectrodeStepInfo").attr("disabled", false);
    else if (nextstep) {
      $("#nextElectrodeStepInfo").attr("disabled", true);
      alert('⚡ ' + nextstep);
    }    
    
    if(domMaterialLotNumber) domMaterialLotNumber.focus();

    if(domMaterialLotNumber && domMaterialLotNumber.value.trim())
          document.getElementById("nextElectrodeStepInfo").click();
  } else {
    $("#nextElectrodeStepInfo").attr("disabled", true);
    tmpnextstep = nextstep;
    alert("⚠ ☹ Giá trị cân nặng ngoài khoảng  Giới hạn dưới/ Giới hạn trên ! ");
    document.getElementById(strmaterialWeight1).value='';
    document.getElementById(strmaterialWeight2).value='';
  }
};

const clearMaterialWeight = () => {
  $("#materialWeight1").val("");
  $("#materialWeight2").val("");

  $("#nextElectrodeStepInfo").attr("disabled", true);
};

const insertWeigingData = () => {
  //if (!document.getElementById("bindingStartDateTime").value)
  // document.getElementById("bindingStartDateTime").value = new Date();
  //if (!document.getElementById("bindingEndDateTime").value)
  //document.getElementById("bindingEndDateTime").value = new Date();
  //입력값 체크
  tmpnextstep = "";
  var result = checkFormData();

  var materialWeight1 = $("#materialWeight1").val();
  var materialWeight2 = $("#materialWeight2").val();

  if (!materialWeight1)
    materialWeight1 = document.getElementById(strmaterialWeight1).value;

  if (!materialWeight2)
    materialWeight2 = document.getElementById(strmaterialWeight2).value;

  // materialWeight1 = isFinite(parseFloat(materialWeight1))
  //   ? parseFloat(materialWeight1)
  //   : "";
  // materialWeight2 = isFinite(parseFloat(materialWeight2))
  //   ? parseFloat(materialWeight2)
  //   : "";
  
  	var electrodeLotNumber = domElectrodeLotNumber.value;
	var electrodeStepCode = document.getElementById("electrodeStepCode").value;
	var sseq = 	document.getElementById("seq").value;
	var materialLotNumber = domMaterialLotNumber.value;

  //입력 프로시저 호출
  if (result) {
    var datetime1 =
      $("#bindingStartDateTime").data("datetimepicker").date() ||
      new Date().toISOString();
    var datetime2 =
      $("#bindingEndDateTime").data("datetimepicker").date() ||
      new Date().toISOString();

    console.log(datetime1);
    console.log(datetime2);
	
    setTimeout(function(){
    if (materialWeight1 != "" && materialWeight1 != "0") {
      var data =
        `

      -Weighing Function-
  ===========Weight=========
  
        Weight:  ` +
        materialWeight1 +
        ` kg
  
  
  `;

      if (sessionStorage.comweightvalue && materialWeight1){
        ///sendPrinterDefault(materialWeight1);
      //sendSerialData(labelport, data);
      }
      /*else
        execSerialPortWrite(
          "start " +
            __dirname +
            "/SendWeightToLabelPrint/run.cmd " +
            '"' +
            $("#printPort").val("") +
            '" "' +
            materialWeight1 +
            '"'
        );*/
    }


    if (materialWeight2 != "" && materialWeight2 != "0") {
      var data =
        `

    -Weighing Function-
===========Weight=========

      Weight:  ` +
        materialWeight2 +
        ` kg


`;

      if (sessionStorage.comweightvalue && materialWeight2){		  
        ///sendPrinterDefault(materialWeight2);
      //sendSerialData(labelport, data);
	  }
      /*else
        execSerialPortWrite(
          "start " +
            __dirname +
            "/SendWeightToLabelPrint/run.cmd " +
            '"' +
            $("#printPort").val("") +
            '" "' +
            materialWeight2 +
            '"'
        );*/
    }
	},3000);



    var procedureName =
      SmartFactoryV2 + "usp_DoCreateElectrodeMixStepInfo_electron";
    var parameterStr =
      "pElectrodeLotNumber" +
      "|pElectrodeStep" +
      "|pSeq" +
      "|pInputQty1" +
      "|pInputQty2" +
      "|pBinderInputDateTime" +
      "|pBinderOutputDateTime" +
      "|pMaterialLotNumber";
	  
	 console.log('electrodeLotNumber=',domElectrodeLotNumber.value)

    var parameterValue =
      electrodeLotNumber +
      "|" +
      electrodeStepCode +
      "|" +
      sseq +
      "|" +
      materialWeight1 +
      "|" +
      materialWeight2 +
      "|" +
      moment(datetime1).format("YYYY-MM-DD HH:mm:ss") +
      "|" +
      moment(datetime2).format("YYYY-MM-DD HH:mm:ss") +
      "|" +
      materialLotNumber;

    callProcedure(procedureName, parameterStr, parameterValue);

    setTimeout(function(){
    //현 단계의 레시피 정보 로딩
    callElectrodeStepInfoProc();
	},2000);
	
  }
  
};

function execSerialPortWrite(executeString) {
  const { exec } = require("child_process");

  exec(executeString, (err, stdout, stderr) => {
    if (err) {
      console.error(err);
    }
  });
}
