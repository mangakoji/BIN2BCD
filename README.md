BIN2BCD
=======
convert number 32 bit binary to 10 digit BCD(decimal);total4*10=40bit.




## Description 
FPGA , Verilog sample
Flash type 1 clock dly but very slow fmax=11.8MHz ,
size is Huge 1.5KLE on MAX10C8

show block chart 
chart/BIN2BCD.bdf on Quartus


## usage
show FPGA/RTL/BIN2BCD.v 's BIN2BCD_top()
    BIN2BCD u_BIN2BCD(
          .CK_i     ( CK_i      )// clock maybe fmax=11.5
        , .XARST_i  ( XARST_i   )// sysreset L
        , .EN_CK_i  ( EN_CK_i   )// clock enable H
        , .DAT_i    ( DAT       )// input data 32bit binary
        , .QQ_o     ( QQ_o      )// output BCD 10*40=40bit
    ) ;
    


## modules
in file FPGA/RTL/BIN2BCD.v is incude
BCD_ADDER()     : addition BOTH 1 DIGIT BCD A and B.
BIN2BCD()       : conv 32bit binary to 10 digit BDC(decimal)
BIN2BCD_top()   : a sample of instance for check fmax
TB_BIN2BCD()    :test bentch
                    1000 random patarn check
                    I like contain test bench in same HDL file :-P


## Features
This is No smart only BluteForce flash binary to BCD converter.
if you display BCD on 7seg LED . you use ucom is better.
This is Millionaire coding.



## Demo
show this youtube
http://mangakoji.hatenablog.com/entry/2017/04/22


## Requirement
writen in VerilogHDL.


#platform: CQ MAX10-FB (Altera MAX10:10M08SAE144C8)
 but may be can use any FPGA/ASIC




## Usage
  clone and compile on Altera QuartusII 
  I compiled on v16.1 web



## Help:  http://mangakoji.hatenablog.com/entry/2017/04/22



## Licence:
----------
Copyright &copy; @manga_koji 2017-04-22su
Distributed under the [MIT License][mit].
[MIT]: http://www.opensource.org/licenses/mit-license.php


enjoy!
