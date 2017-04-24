
var anint:UInt8 = 2;

var becc_BEC_1_2_Hi_clname:[UInt8] = [0x48,0x69];
var becc_BEC_1_2_Hi_clfile:[UInt8] = [0x73,0x6F,0x75,0x72,0x63,0x65,0x2F,0x74,0x65,0x73,0x74,0x2F,0x42,0x61,0x73,0x65,0x54,0x65,0x73,0x74,0x73,0x2E,0x62,0x65];
var BEC_1_2_Hi_bels_0:[UInt8] = [0x59,0x6F];

var BEC_1_2_Hi_bevo_0:BES_PseudoStr? = (BES_PseudoStr(BEC_1_2_Hi_bels_0));

class BES_Classy {

  //class var becc_clname:[UInt8] { return [0x48,0x69]; }
  
  func setanint() {
	anint = 5;
	callWith(BES_Classy(), BES_StayClassy());
  }
  
  class func csetanint() {
	anint = 5;
  }
  
  func callWith(_ it:BES_Classy, _ yo:BES_StayClassy) {
  
  }

}

