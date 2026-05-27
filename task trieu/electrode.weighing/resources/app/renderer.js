// This file is required by the index.html file and will
// be executed in the renderer process for that window.
// All of the Node.js APIs are available in this process.

const serialport = require("serialport");
//const tableify = require('tableify')
var domPortid = document.getElementById("portid");
var domErrorid = document.getElementById("errorid");
serialport.list(/*(err, ports)*/).then(function (err, ports) {
  if (err && !ports) ports = err;
  console.log("ports", ports);

  if (err && err.message) {
    domErrorid.innerHTML = err.message;
    domErrorid.style.display = "";
    return;
  } else {
    domErrorid.innerHTML = " ";
    domPortid.innerHTML = " ";
  }

  if (ports.length === 0) {
    domErrorid.style.display = "";
    domErrorid.innerHTML = "⚠ ☹ Không tìm thấy cổng COM";
  }

  ports.forEach(function (port) {
    
    domErrorid.style.display = "none";
    domPortid.innerHTML =
      domPortid.innerHTML +
      port.path +
      "_" +
      port.manufacturer +
      "   ;   ";
	  
	  console.log("Port: ", port.isOpen);
	  
  });

  //tableHTML = tableify(ports)
  //document.getElementById('errorid').innerHTML = tableHTML
});
