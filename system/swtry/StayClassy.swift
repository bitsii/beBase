

var BES_Class_becc_clname:[UInt8] = [0x48,0x69];

var BEC_2_4_8_TestHasProps_bevo_0:BES_PseudoStr? = nil;

class BES_StayClassy : BES_Classy {

  /*override class var becc_clname:[UInt8] {  return [0x48,0x69]; }*/
  
  override func setanint() {
	anint = 5;
  }
  
  override class func csetanint() {
	anint = 5;
  }

}

