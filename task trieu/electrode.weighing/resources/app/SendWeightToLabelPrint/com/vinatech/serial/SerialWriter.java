package com.vinatech.serial;

import jssc.SerialPort; 
import jssc.SerialPortException;

public class SerialWriter {

	public static void main(String[] args) {
	    SerialPort serialPort = new SerialPort(args[0]);
	    try {
	        serialPort.openPort();//Open serial port
	        serialPort.setParams(SerialPort.BAUDRATE_9600, 
	                             SerialPort.DATABITS_8,
	                             SerialPort.STOPBITS_1,
	                             SerialPort.PARITY_NONE);
	        
	        byte[] weightBytes = args[1].getBytes();
	        
	        //String prefix="2020202D5765696768696E672046756E6374696F6E2D0D0A3D3D3D3D3D3D3D3D3D3D5745494748543D3D3D3D3D3D3D3D3D3D0D0A0A20202020205765696768743A202020";
	        
	        String weight = byteArrayToHexString(weightBytes);
	        
	        //String postfix = "206B67200D0A20202020202020546172653A202020332E333832206B67200D0A20202020202047726F73733A202020352E303238206B67200D0A0A0A0A0A0A";
	        
	        //serialPort.writeBytes(hexStringToByteArray(prefix+weight+postfix));
	        
	        serialPort.writeBytes(hexStringToByteArray(weight));
	        
	        serialPort.closePort();
	        
	        System.out.println(weight);
	    }
	    catch (SerialPortException ex) {
	        System.out.println(ex);
	    }
	}
	
	public static byte[] hexStringToByteArray(String s) {
	    int len = s.length();
	    byte[] data = new byte[len / 2];
	    for (int i = 0; i < len; i += 2) {
	        data[i / 2] = (byte) ((Character.digit(s.charAt(i), 16) << 4)
	                             + Character.digit(s.charAt(i+1), 16));
	    }
	    return data;
	}

	public static String byteArrayToHexString(byte[] bytes){ 
			
			StringBuilder sb = new StringBuilder(); 
			
			for(byte b : bytes){ 
				
				sb.append(String.format("%02X", b&0xff)); 
			} 
			
			return sb.toString(); 
		} 
}