const SerialPort = require("serialport");
var fs = require('fs');

function connectSerialPort(portName) {
  try{
  const port = new SerialPort(portName, {
    baudRate: 9600,
  });

  // serialport.list(/*(err, ports)*/).then(function (err, ports) {
  //   if (err && !ports) ports = err;

  //   ports.forEach(function (port) {
  //     console.log("Port: ", port);
  //   });
  // });
  
  
  //alert('⚡ Đã kết nối cổng '+portName +'. \nĐang đợi dữ liệu gửi vào... ☺');
  
  return port;
  }
  catch{
    alert('⚠ ☹ Không kết nối được '+portName +'. \n\nVui lòng kiểm tra lại.');
    return null;
  }
}

String.prototype.replaceJoin = function (search, replacement) {
  var target = this;
  return target.split(search).join(replacement);
};

function getCurMonth(){
  var today = new Date();

  var mm = String(today.getMonth() + 1).padStart(2, '0'); //January is 0!
  var yyyy = today.getFullYear();

  today =  yyyy+"/" + mm;
  return today;
}

function getCurdate(){
  var today = new Date();
  var dd = String(today.getDate()).padStart(2, '0');
  var hh = today.getHours();

  today =   dd+hh;
  return today;
}


function sendSerialData(port, data) {
  if(!port) return;

  port.write(data);
}

sessionStorage.comweightvalue='';
function getSerialData(port, ID, ID2) {
  if(!port) return;

  var buffer = "";
  var buffer1 = "";
  var serialData = 0.0;

console.log('bắt đầu chờ dữ liệu trên cổng: '+port.path);
  
var firststr="";
var bottomstr="";
var yinyang=false;
var lastval="";


  port.on("data", function (chunk) {
    
    if(buffer1 == firststr)
        buffer1 =""; //1111111111
    
    //console.log("chunk=", chunk);
    //buffer1 += bottomstr+chunk; //////222222

    buffer1 += chunk;
	
	if(!buffer1) return;

    if(buffer1.toLowerCase().indexOf('kg')>0){ ///////22222
      firststr = buffer1.split('kg')+'kg';
      bottomstr = buffer1.split('kg');
      //console.log("bottomstr=====", bottomstr);
      buffer1 = firststr;
      //console.log("buffer1=======", buffer1);      
    }
    else{
      return;
    }

    buffer = buffer1;


    console.log("buffer=", buffer);
    //console.log("buffer=", buffer.replace(/[^0-9.]/g, ""));
    
    var answer = buffer.split(/\r?\n/);
    console.log("answer=", answer);

    for (i = 0; i < answer.length; i++) {
      var tmp = answer[i];
      console.log(tmp);
      if (tmp) tmp = tmp.replaceJoin(" ", "");
      if (
        tmp &&
        tmp.indexOf("eight") >= 0 &&
        tmp.indexOf(":") > tmp.indexOf("eight") &&
        tmp.lastIndexOf("g") > tmp.indexOf(":")
      ) {
        console.log("++++", tmp);
        var tmp2 = tmp.replace(/[^0-9.]/g, "");
        if (tmp2) {
          console.log("++90909090++", tmp);
          answer = [];
          answer.push(tmp);
          buffer = "";
          break;
        } else continue;
      } else continue;
    }

    // console.log("answer=", answer);
    // buffer = answer.pop();
    // console.log("buffer=", buffer);

    // if (
    //   buffer &&
    //   buffer.indexOf("eight") >= 0 &&
    //   buffer.indexOf(":") > buffer.indexOf("eight") &&
    //   buffer.lastIndexOf("g") > buffer.indexOf(":")
    // ) {
    //   answer = [];
    //   answer.push(buffer);
    // }

    //start process data
    if (
      answer.length > 0 &&
      answer[0].indexOf("eight") >= 0 &&
      answer[0].indexOf(":") > answer[0].indexOf("eight") &&
      answer[0].lastIndexOf("g") > answer[0].indexOf(":")
    ) {
      serialData = answer[0].replace(/[^0-9.]/g, "");


      console.log("serialData=", serialData);

      var obj1 = document.getElementById(ID);
      var obj2 = document.getElementById(ID2);

      console.log("obj1 :::::" + obj1.value);
      console.log("obj2 :::::" + obj2.value);

      console.log("isEmpty(obj1.value) ::::: " + isEmpty(obj1.value));
      console.log("isEmpty(obj2.value) ::::: " + isEmpty(obj2.value));

      if (isEmpty(obj1.value)) {
        obj1.value = serialData;
		sessionStorage.comweightvalue=serialData;

        checkMaterialSpec(obj1.value, obj2.value);
      } 
      else if (isEmpty(obj2.value)){
        obj2.value = serialData;

        checkMaterialSpec(obj1.value, obj2.value);
      }
      buffer = "";
    }

 
   
    // var newDest = __dirname.replaceJoin('\\','/') +'/log/'+getCurMonth();    
    // if (!fs.existsSync(newDest)) fs.mkdirSync(newDest,{recursive :true} );
    
    // var newlog = newDest +"/"+ getCurdate()+".log";
    // var content1 = new Date().toLocaleTimeString() +" "+ buffer + '\r\n';

    // fs.writeFile(newlog, content1,  {'flag':'a'}, err => {
    //   if (err) {
    //     console.error(err);
    //     return;
    //   }
    //   //file written successfully
    // })

    if(buffer.toLowerCase().indexOf('kg') != buffer.toLowerCase().lastIndexOf('kg') ) {
      return;
    }

    

    //console.log('yinyang='+ (buffer.indexOf(',-')>0) );
    if(buffer && buffer.indexOf("ST,GS")>=0 || buffer && buffer.indexOf("ST,NT")>=0)
    if(buffer.toLowerCase().indexOf("kg") > 0 )
    //if(localStorage.replace1 && buffer.indexOf(localStorage.replace1)>=0 ||  
     //  localStorage.replace2 && buffer.indexOf(localStorage.replace2)>=0 || 
      // localStorage.replace3 && buffer.indexOf(localStorage.replace3)>=0)   
      {
        //serialData = buffer.replace(/[^0-9.]/g, "");

        yinyang=false;
        if(buffer.indexOf(',-')>0) yinyang=true;
        //console.log('yinyang12========='+yinyang);

        serialData = buffer.replace(/[^0-9.]/g, "");      
        //console.log('serialData231========='+serialData);

        if( !isFinite(parseFloat(serialData) ) ) {
          buffer="";
          //console.log('not isFinite serialData ------------------------------'+serialData);
          return;
        }
        
        if(!confirmweight)
        if(parseFloat(serialData )>0.006 && !yinyang  ){         
			    //if(yinyang) return;
            lastval = serialData;
			    sessionStorage.comweightvalue=serialData;
            buffer="";
            //console.log('not yinyang and not <0.006 ---------------------------'+serialData);
            return;
        }

        // if(!yinyang){
        //   lastval = serialData;
        //   buffer="";
        //   return;
        // }

        if(!lastval) {
          buffer="";
          //console.log('last val --failed --------------------------'+lastval);
          return;
        }
  
        var obj1 = document.getElementById(ID); 
        var obj2 = document.getElementById(ID2);
  
        console.log("obj1 :::::" + obj1.value);
        //console.log("obj2 :::::" + obj2.value);
  
        //console.log("isEmpty(obj1.value) ::::: " + isEmpty(obj1.value));
        //console.log("isEmpty(obj2.value) ::::: " + isEmpty(obj2.value));
  
        if (isEmpty(obj1.value)) {
          obj1.value = lastval.replace('000.','0.');  
          buffer = "";
          lastval= "";
          checkMaterialSpec(obj1.value, obj2.value);
        } 
        // else if (isEmpty(obj2.value)){
        //   obj2.value = serialData;  
        //   checkMaterialSpec(obj1.value, obj2.value);
        // }
        buffer = "";
        lastval= "";
        
        //console.log("buffer2=-----------"+ buffer);
        //console.log("serialData3=-------"+ serialData);

      }
    

  });
}
