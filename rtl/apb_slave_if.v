module apb_slave_if(
    //APB总线上的信号
    input                           pclk,                
    input                           prst_n,

    input       [31:0]              pwdata,
    input       [11:0]              paddr,
    input                           pwrite,
    output      [31:0]              prdata,

    input                           psel,
    input       [3:0]               pstrb,
    input       [2:0]               pprot,
    input                           penable,
    output                          pready,
    output                          pslverr,

    //reg上的信号
    input       [31:0]              rdata,
    output      [31:0]              wdata,
    output      [11:0]              addr,
    output                          write_en,
    output                          read_en,
    output      [3:0]               w_strb,

    input                           rd_ready,
    input                           wr_ready,
    input                           err_resp
);
    //输出给reg
    assign wdata = pwdata;
    assign addr = paddr;
    assign w_strb = pstrb;
    
    //将读数据的步骤交给主机处理，也就是说从机可以提前一个周期将数据准备好。而两个周期读一个数据这件事就交给主机
    //也就是说，读使能将在整个读过程中保持打开，这是为了让读寄存器能够提前准备好数据，然后再由主机跟据合适的时机读出结果
    assign read_en = (psel && !pwrite);
    //写使能
    assign write_en = (psel && pwrite && penable); //我这里将写使能设置得不同，认为写使能是在access阶段,参考代码则是认为写在setup阶段


    //输出给APB总线
    assign prdata = rdata;
    assign pslverr = err_resp; 
    assign pready = (read_en && rd_ready) || (wr_ready && write_en);


endmodule
