//BIN2BCD.v
//  BIN2BCD
//
// binary to BCD converter (flash: 1 clock dly but huge and slow)
// input DAT_i/32   : binary
// output QQ        : BCD 10 digit
//
//170422s           :by @mangakoji


// bin2BCD core 
// calc 2 BCD data DAT_A_i, DAT_B_i addition
// if DAT_A_i+ DAT_B_i and over 10 , cyo is H
//   and output yy_o (A+B)-10
module BCD_ADDER(
      input [ 3 :0] DAT_A_i //0 upto 9
    , input [ 3 :0] DAT_B_i //0 upto 9
    , input         CYI_i
    , output[ 3 :0] yy_o    //0 upto 9
    , output        cyo_o
) ;
    wire    [4:0] DAT_add ;
    assign DAT_add = {1'b0 , DAT_A_i} + {1'b0 , DAT_B_i} + {4'b0,CYI_i} ;
    assign cyo_o = DAT_add >= 5'd10 ;
    assign yy_o = (cyo_o) ? (DAT_add - 5'd10) : DAT_add[3:0] ;
endmodule



// main part
module BIN2BCD (
      input         CK_i
    , input         XARST_i
    , input         EN_CK_i
    , input [31:0]  DAT_i
    , output[39:0]  QQ_o
) ;
    // every DAT bit is H, add those SEED every digit
    localparam [32*10*4-1:0] C_BIT_SEED = {
            40'h0000000001
          , 40'h0000000002
          , 40'h0000000004
          , 40'h0000000008
          , 40'h0000000016
          , 40'h0000000032
          , 40'h0000000064
          , 40'h0000000128
          , 40'h0000000256
          , 40'h0000000512
          , 40'h0000001024
          , 40'h0000002048
          , 40'h0000004096
          , 40'h0000008192
          , 40'h0000016384
          , 40'h0000032768
          , 40'h0000065536
          , 40'h0000131072
          , 40'h0000262144
          , 40'h0000524288
          , 40'h0001048576
          , 40'h0002097152
          , 40'h0004194304
          , 40'h0008388608
          , 40'h0016777216
          , 40'h0033554432
          , 40'h0067108864
          , 40'h0134217728
          , 40'h0268435456
          , 40'h0536870912
          , 40'h1073741824
          , 40'h2147483648
    } ;

    // instance BCD adder
    // bit_rayer(bit) digit
    // show chart BIN2BDC.bdf
    wire    [3:0]   yy  [0:31][0:9] ;
    wire            cy  [0:31][0:9] ;
    genvar g_bit ;
    genvar g_digit ;
    generate 
    for (g_bit=0; g_bit<32; g_bit=g_bit+1) begin:gen_bit
        for(g_digit=0; g_digit<10; g_digit=g_digit+1) begin: gen_digit
            BCD_ADDER BCD_ADDER(
                  .DAT_A_i  ( 
                    (g_bit==0)? 
                        'd0 
                    : 
                        yy[g_bit-1][g_digit]
                  )
                , .DAT_B_i  ( 
                    {4{DAT_i[g_bit]}} 
                    & 
                    C_BIT_SEED[((31-g_bit)*40)+4*g_digit +:4]  
                )
                , .CYI_i    (
                     (g_digit==0) ? 
                        'd0 
                    : 
                        cy[g_bit][g_digit-1]
                )
                , .yy_o     ( yy[g_bit][g_digit]        )
                , .cyo_o    ( cy[g_bit][g_digit]        )
            ) ;
        end
    end
    endgenerate 


    //simply output latch
    reg [39:0] QQ ;
    generate 
        for(g_digit=0; g_digit<10; g_digit=g_digit+1) begin : gen_digit
            always @(posedge CK_i or negedge XARST_i)
                if ( ~ XARST_i)
                    QQ[4*g_digit +:4] <= 4'd0 ;
                else if ( EN_CK_i )
                    QQ[4*g_digit +:4] <=  yy[31][g_digit] ;
        end
    endgenerate
    assign QQ_o = QQ ;
endmodule



//example  instanse for mesure fmax
module BIN2BCD_top(
      input         CK_i
    , input         XARST_i
    , input         EN_CK_i
    , input [31:0]  DAT_i
    , output[39:0]  QQ_o
) ;
    reg [31:0]  DAT ;
    always @(posedge CK_i or negedge XARST_i)
        if ( ~ XARST_i)
            DAT <= 'd0 ;
        else if ( EN_CK_i )
            DAT <= DAT_i ;
    BIN2BCD u_BIN2BCD(
          .CK_i     ( CK_i      )
        , .XARST_i  ( XARST_i   )
        , .EN_CK_i  ( EN_CK_i   )
        , .DAT_i    ( DAT       )
        , .QQ_o     ( QQ_o      )
    ) ;
endmodule

// test bentch random input compair
module TB_BIN2BCD #(
    parameter C_C = 10
)(
) ;
    reg CK ;
    initial begin
        CK <= 1'b1 ;
        forever begin
            #(C_C/2.0)
                CK <= ~ CK ;
        end
    end
    reg XARST ;
    initial begin
        XARST <= 1'b1 ;
        #(0.1 * C_C)
            XARST <= 1'b0 ;
        #(3.1 * C_C)
            XARST <= 1'b1 ;
    end
 
 
    integer rand_reg    = 1 ;
    integer idx ;
    reg [31:0]  DAT ;
    reg [ 3:0] DIGIT    [0:9]  ;
    reg [ 3:0] DIGIT_D  [0:9]  ;
    reg [ 3:0] DIGIT_DD [0:9]  ;
    reg [ 3:0] DIGIT_DDD[0:9]  ;
    wire[39:0]  QQ      ;
    wire    [3:0]   QQ_DIGIT [0:9] ;
    reg [9:0]   CMP ;
    reg         CMP_TOTAL   ;
    initial begin
        rand_reg = 1 ;
        for (idx=0;idx<10; idx=idx+1) begin
            DIGIT[idx] =  'd0 ;
            CMP[idx] <= 1'b1 ;
        end 
        repeat( 10000 ) begin
            DAT = $random(rand_reg) ;
//            DAT = rand_reg ;
//            rand_reg = rand_reg + 1 ;
            for (idx=0;idx<10; idx=idx+1) begin
                DIGIT[idx] =  (DAT/(10**idx)) % 10 ;
                CMP[idx] = (QQ_DIGIT[idx] == DIGIT_D[idx]) ;
                CMP_TOTAL = & CMP ;
            end
            @(posedge CK);
        end
        $stop ;
    end 
    
    always @(posedge CK or negedge XARST)
        if (~ XARST) begin
            for (idx=0;idx<10; idx=idx+1) begin
                DIGIT_D[idx] <=  'd0 ;
                DIGIT_DD[idx] <=  'd0 ;
                DIGIT_DDD[idx] <=  'd0 ;
            end
        end else begin
            for (idx=0;idx<10; idx=idx+1) begin
                DIGIT_D[idx]    <= DIGIT[idx] ;
                DIGIT_DD[idx]   <= DIGIT_D[idx] ;
                DIGIT_DDD[idx]  <= DIGIT_DD[idx] ;
            end
        end


    BIN2BCD u_BIN2BCD(
          .CK_i     ( CK        )
        , .XARST_i  ( XARST     )
        , .EN_CK_i  ( 1'b1      )
        , .DAT_i    ( DAT       )
        , .QQ_o     ( QQ        )
    ) ;
    genvar g_idx ;
    generate
        for (g_idx=0;g_idx<10; g_idx=g_idx+1)
            assign QQ_DIGIT[g_idx] = QQ[g_idx*4 +:4] ;
    endgenerate
endmodule
