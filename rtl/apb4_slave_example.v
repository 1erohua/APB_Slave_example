module apb4_slave_example(
    input                           PCLK,
    input                           PRESETn,

    //APB
    input                           PSEL,
    input                           PENABLE,
    input         [2:0]             PPROT,
    input         [3:0]             PSTRB,

    input                           PWRITE,
    input         [11:0]            PADDR,
    input         [31:0]            PWDATA,
    output        [31:0]            PRDATA,

    output                          PREADY,
    output                          PSLVERR
);

    wire          [31:0]            wdata;
    wire          [11:0]            addr;
    wire          [31:0]            rdata;
    wire                            read_en;
    wire                            write_en;

    wire          [3:0]             w_strb;
    wire                            rd_ready;
    wire                            wr_ready;
    wire                            err_resp;


    apb4_slave_example_reg reg_1(
    .clk(PCLK),                             
    .rst_n(PRESETn),                            
    
    .wdata(wdata),
    .addr(addr),
    .read_en(read_en),
    .write_en(write_en),
    .rdata(rdata),

    .w_strb(w_strb),
    .rd_ready(rd_ready),
    .wr_ready(wr_ready),
    .err_resp(err_resp)
    );

    apb_slave_if if1(
        .pclk(PCLK),    
        .prst_n(PRESETn),
           
    .pwdata(PWDATA),
 	.paddr(PADDR),
 	.pwrite(PWRITE),
 	.prdata(PRDATA),
           
  .psel(PSEL),
  .pstrb(PSTRB),
  .pprot(PPROT),
  .penable(PENABLE),
  .pready(PREADY),
  .pslverr(PSLVERR),
          
  .rdata(rdata),
  .wdata(wdata),
  .addr(addr),
  .write_en(write_en),
  .read_en(read_en),
  .w_strb(w_strb),
           
  .rd_ready(rd_ready),
  .wr_ready(wr_ready),
  .err_resp(err_resp)
    );


endmodule

