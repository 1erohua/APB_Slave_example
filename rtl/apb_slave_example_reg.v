module apb4_slave_example_reg(
    input                               clk,                             
    input                               rst_n,                            

    //认为写数据与写地址应该一同送来
    input   wire    [31:0]              wdata,
    input   wire    [11:0]              addr,
    input                               read_en,
    input                               write_en,
    output  reg     [31:0]              rdata,

    input   wire    [3:0]               w_strb,
    output  wire                        rd_ready,
    output  reg                         wr_ready,
    output                              err_resp
);
    //可读写寄存器————RW
    //有4个
    //只读寄存器————RO
    //有16个
   
    //4个读写的寄存器
    reg     [31:0]                      data_0123[3:0];

    //地址低2位指定 写寄存器的地址
    //地址判断[11:4]是否是0,如果是0,则代表是读 可读写寄存器状态, [3:2]是指定 读哪个寄存器
    //地址判断[11:6]是否是1,如果是1,则代表是读 只读寄存器, [5:2] 是指定 读 哪个寄存器
    //这些只读数据是乱写的
    localparam  a0 = 32'h0000_0000;
    localparam  a1 = 32'h0000_003f;
    localparam  a2 = 32'h0000_002d;
    localparam  a3 = 32'h0000_12ff;
    localparam  a4 = 32'h0000_001e;
    localparam  a5 = 32'h0000_0034;
    localparam  a6 = 32'h0000_12ee;
    localparam  a7 = 32'h0000_34ff;
    localparam  a8 = 32'h0000_000f; 
    localparam  a9 = 32'h0000_0012;
    localparam  a10= 32'h1111_000e;
    localparam  a11= 32'h1111_000a;
    localparam  a12= 32'h1111_0011;
    localparam  a13= 32'h1111_0001;
    localparam  a14= 32'h1111_0bbb;
    localparam  a15= 32'h1111_0aaa;

    //读是异步读，写是同步写
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin  
            data_0123[0] <= 32'b0;
            data_0123[1] <= 32'b0;
            data_0123[2] <= 32'b0;
            data_0123[3] <= 32'b0;
            wr_ready <= 1'b0;
        end

        else if(write_en) begin
            if(w_strb[0]) begin 
                data_0123[addr[1:0]] [7:0] <= wdata[7:0];
                wr_ready <= 1'b1;
            end

            if(w_strb[1]) begin 
                data_0123[addr[1:0]] [15:8] <= wdata[15:8];
                wr_ready <= 1'b1;
            end

            if(w_strb[2]) begin
                data_0123[addr[1:0]] [23:16] <= wdata[23:16];
                wr_ready <= 1'b1;
            end

            if(w_strb[3]) begin
                data_0123[addr[1:0]] [31:24] <= wdata[31:24];
                wr_ready <= 1'b1;
            end
        end

        else begin
            wr_ready <= 1'b0;
        end
    end
    
    //异步读
    assign rd_ready = 1;
    always @(read_en or addr or data_0123[0] or data_0123[1] or data_0123[2] or data_0123[3]) begin
        if(read_en) begin
            if(addr[11:4]==8'b0) begin
                case (addr[3:2])                
                    2'b00:#3 rdata = data_0123[0];
                    2'b01:#3 rdata = data_0123[1];
                    2'b10:#3 rdata = data_0123[2];
                    2'b11:#3 rdata = data_0123[3];
                    default: rdata = 0;
                endcase
            end
            else if(addr[11:6]==6'b111111) begin
                case (addr[5:2])
                    4'b0000:#3 rdata = a0;
                    4'b0001:#3 rdata = a1;
                    4'b0010:#3 rdata = a2;
                    4'b0011:#3 rdata = a3;
                    4'b0100:#3 rdata = a4;
                    4'b0101:#3 rdata = a5;
                    4'b0110:#3 rdata = a6;
                    4'b0111:#3 rdata = a7;
                    4'b1000:#3 rdata = a8;
                    4'b1001:#3 rdata = a9;
                    4'b1010:#3 rdata = a10;
                    4'b1011:#3 rdata = a11;
                    4'b1100:#3 rdata = a12;
                    4'b1101:#3 rdata = a13;
                    4'b1110:#3 rdata = a14;
                    4'b1111:#3 rdata = a15;
                endcase
            end
        end

        else begin
            rdata = 0;
        end
    end

    //错误判断
    //不处于写状态并且读状态被拉起时，地址都不符合，则会导致报错
    assign err_resp = (!write_en && read_en) && ( addr[11:4]!=8'h0 && addr[11:6]!=6'b111111) ? 1 : 0;

endmodule
