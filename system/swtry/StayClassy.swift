
var bece_BEC_2_4_8_TestHasProps_bevo_0:BES_PseudoStr? = nil;

class BES_StayClassy : BES_Classy {

  //public BEC_2_4_6_TextString bevp_alpha;
  var bevp_alpha:BES_PseudoStr?;

  /*override class var becc_clname:[UInt8] {  return [0x48,0x69]; }*/
  
  override func setanint() {
	anint = 5;
  }
  
  override class func csetanint() {
	anint = 5;
  }
  
  override func acall() { }
  
  func aretcall() -> BES_PseudoStr? { return nil; }
  
  func testCall() {
    bevp_alpha!.callIt_0();
    bevp_alpha!.callIt_1(nil);
  }
  
  func testCond() {
    
    
    if (bece_BEC_2_4_8_TestHasProps_bevo_0 == nil) {
      acall();
      self.acall();
      super.acall();
      //BEC_2_4_8_TestHasProps_bevo_0 = this.bem_serializationNamesGet_0();
    }
  }
  
  override func callWith(_ it:BES_Classy, _ yo:BES_StayClassy) -> BES_StayClassy? {
  
    var blarg:BES_Classy? = nil;
    
    blarg!.acall();
    
    return nil;
  
  }

}

