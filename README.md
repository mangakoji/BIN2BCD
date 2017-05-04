BIN2BCD
=======
convert number 26 bit binary to 8 digit BCD(decimal);  
total4*8=32bit.


## Description 
FPGA , Verilog sample  
selectable 2 mode included.  

*Millionaire coding mode( Flash)
Flash type 1 clock dly but very slow fmax=11.8MHz ,  
size is Huge 1.5KLE on MAX10C8  

*shift register mode
fmax = 397.46MHz(restricted 250MHz)
size is 138EL on MAX10C8
but ratency is 27+2=29ck.



show block chart 
chart/BIN2BCD.bdf on Quartus


## usage
show FPGA/RTL/BIN2BCD.v 's BIN2BCD_top() 
```verilogHDL:sample 
    BIN2BCD # (
          .C_MILLIONAIRE( 0 )   //0:shift reg mode, 1:Millionair mode
        , .C_WO_LATCH   ( 0)    //1:last QQ latch is removed,you latch in DONE_o
    ) u_BIN2BCD(  
          .CK_i     ( CK_i      )// clock maybe fmax=11.5  
        , .XARST_i  ( XARST_i   )// sysreset L  
        , .EN_CK_i  ( EN_CK_i   )// clock enable H  
        , .REQ_i    ( REQ_i     )// convert request H
        , .DAT_i    ( DAT       )// input data 32bit binary  
        , .QQ_o     ( QQ_o      )// output BCD 10*40=40bit  
        , .DONE_o   ( DONE_o    )// convert done 1EN_CK H
    ) ;  
````
  
  
## modules
in file FPGA/RTL/BIN2BCD.v is incude  
```Verilog:sample 
BCD_ADDER()             : addition BOTH 1 DIGIT BCD A and B.  
BIN2BCD_MILLIONAIRE()   : Flash mode code
BCD_BY2ADDCY            : shift mode core shift_reg module. calc newX=2*lastX+cy
BIN2BCD_SHIFT()         :
BIN2BCD()               : conv 32bit binary to 10 digit BDC(decimal)  
BIN2BCD_top()           : a sample of instance for check fmax  
TB_BIN2BCD()            :test bentch  
                            1000 random patarn check  
                            I like contain test bench in same HDL file :-P  
```  
  
## Features
*Shift register mode is normal but not small. if you after latch QQ_o in DONE_o ,you can reduce 32 FF.  
set parameter C_WO_LATCH( 1 ).  

*Millionaire mode is No smart only BluteForce flash binary to BCD converter.  
if you display BCD on 7seg LED . you use ucom is better.  
This is Millionaire coding.  

*test_bentch included in same file.  
 you can use in model-sim_altera directry.  
 clone,wclick *.qpf ,<ctl>k,tool->run_sim_tool->RTL_sim(set env),work->TB_*,view->wave,select signal,go sim,and enjoy! ;-)

## Demo
show this youtube  
http://mangakoji.hatenablog.com/entry/2017/04/23/213753


## Requirement
writen in VerilogHDL.  


#platform: CQ MAX10-FB (Altera MAX10:10M08SAE144C8)  
 but may be can use any FPGA/ASIC  




## Usage
  clone and compile on Altera QuartusII  
  I compiled on v16.1 web



## Help:  http://mangakoji.hatenablog.com/entry/2017/04/23/213753


## Licence:
----------
Copyright &copy; @manga_koji 2017-04-22su
Distributed under the [MIT License][mit].
[MIT]: http://www.opensource.org/licenses/mit-license.php


enjoy!
