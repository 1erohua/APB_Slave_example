module apb_slave_example_tb;
    parameter PERIOD = 20;

    //例化
    reg                           PCLK;
    reg                           PRESETn;

    //APB
    reg                           PSEL;
    reg                           PENABLE;
    reg         [2:0]             PPROT;
    reg         [3:0]             PSTRB;

    reg                           PWRITE;
    reg         [11:0]            PADDR;
    reg         [31:0]            PWDATA;

    wire        [31:0]            PRDATA;

    wire                          PREADY;
    wire                          PSLVERR;


    //波形文件设置
    initial begin
        $fsdbDumpfile("APB_Slave_example.fsdb");
        $fsdbDumpvars();
    end

    //全局的设置
    initial begin
        PCLK = 0;
        PRESETn = 0;
        # PERIOD PRESETn = 1;
        # (PERIOD*50) $finish;
    end
    always begin
        # (PERIOD/2) PCLK <= ~PCLK;
    end
/*
*/
    apb4_slave_example a1(
    .PCLK(PCLK),          
    .PRESETn(PRESETn),
     
    .PSEL(PSEL),
    .PENABLE(PENABLE),
	.PPROT(PPROT),
	.PSTRB(PSTRB),
	        
	.PWRITE(PWRITE),
	.PADDR(PADDR),
	.PWDATA(PWDATA),
	.PRDATA(PRDATA),

	.PREADY(PREADY),
	.PSLVERR(PSLVERR)
    );


    //状态机来做验证
    `define         IDLE        6'b00000

    `define         WR_REG0     6'b000001
    `define         WR_REG0_i     6'b100001

    `define         WR_REG1     6'b000011
    `define         WR_REG1_i     6'b100011

    `define         WR_REG2     6'b00010
    `define         WR_REG2_i     6'b100010

    `define         WR_REG3     6'b00110
    `define         WR_REG3_i     6'b100110

    `define         RD_REG0     6'b00111
    `define         RD_REG0_i     6'b100111

    `define         RD_REG1     6'b00101
    `define         RD_REG1_i     6'b100101

    `define         RD_REG2     6'b00100
    `define         RD_REG2_i     6'b100100

    `define         RD_REG3     6'b01100
    `define         RD_REG3_i     6'b101100

    `define         RD_RO0      6'b010000
    `define         RD_RO0_i    6'b110000

    `define         RD_RO1      6'b10001
    `define         RD_RO1_i      6'b110001

    `define         RD_RO2      6'b10010
    `define         RD_RO2_i      6'b110010

    `define         RD_RO3      6'b10011
    `define         RD_RO3_i    6'b110011

    `define         RD_RO4      6'b10100
    `define         RD_RO4_i    6'b110100

    `define         RD_RO5      6'b10101
    `define         RD_RO5_i      6'b110101

    `define         RD_RO6      6'b10110
    `define         RD_RO6_i      6'b110110

    //方便起见，只读就读7个


    reg     [5:0]       cstate;
    reg     [5:0]       nstate;

    always @(posedge PCLK or negedge PRESETn) begin
        if(!PRESETn) 
            cstate <= `IDLE;
        else 
            cstate <= nstate;
    end

    //always @(PSEL or PENABLE or PWDATA or PADDR or PSTRB or PSTRB or PWRITE or cstate or PPROT or PPROT) begin
    always @(*) begin
        case (cstate)
            `IDLE: begin
                PSEL = 0;
                PENABLE = 0;
                PWRITE = 0;
                PSTRB = 4'b1111;
                nstate = `WR_REG0;
            end

            `WR_REG0: begin
                PSEL = 1;
                PENABLE = 0;
                PWRITE = 1;
                PWDATA = 32'hfff0;
                //低两位指定写地址
                PADDR = 12'b00;
                nstate = `WR_REG0_i;
            end

            `WR_REG0_i: begin
                PENABLE = 1;
                if(PREADY == 1)begin 
                    nstate = `WR_REG1;
                end
                else
                    nstate = cstate;
            end

            `WR_REG1: begin
                PSEL = 1;
                PENABLE = 0;
                PWRITE = 1;
                PWDATA = 32'hff0f;
                //低两位指定写地址
                PADDR = 12'b01;
                nstate = `WR_REG1_i;
            end

            `WR_REG1_i: begin
                PENABLE = 1;
                if(PREADY == 1)begin 
                    nstate = `WR_REG2;
                end
                else
                    nstate = cstate;
            end

            `WR_REG2: begin
                PSEL = 1;
                PENABLE = 0;
                PWRITE = 1;
                PWDATA = 32'hf0ff;
                //低两位指定写地址
                PADDR = 12'b10;
                nstate = `WR_REG2_i;
            end

            `WR_REG2_i: begin
                PENABLE = 1;
                if(PREADY == 1)begin 
                    nstate = `WR_REG3;
                end
                else
                    nstate = cstate;
            end

            `WR_REG3: begin
                PSEL = 1;
                PENABLE = 0;
                PWRITE = 1;
                PWDATA = 32'h0fff;
                //低两位指定写地址
                PADDR = 12'b11;
                nstate = `WR_REG3_i;
            end

            `WR_REG3_i: begin
                PENABLE = 1;
                if(PREADY == 1)begin 
                    nstate = `RD_REG0;
                end
                else
                    nstate = cstate;
            end

            `RD_REG0 : begin
                PSEL = 1;
                PENABLE = 0;
                PADDR = 12'b00000000_00_00;
                PWRITE = 0;
                nstate = `RD_REG0_i;
            end

            `RD_REG0_i : begin
                PENABLE = 1;
                if(PREADY == 1) begin
                    nstate = `RD_REG1;
                end
                else nstate = cstate;
            end

            `RD_REG1 : begin
                PSEL = 1;
                PENABLE = 0;
                PADDR = 12'b00000000_01_00;
                PWRITE = 0;
                nstate = `RD_REG1_i;
            end

            `RD_REG1_i : begin
                PENABLE = 1;
                if(PREADY == 1) begin
                    nstate = `RD_REG2;
                end
                else nstate = cstate;
            end

            `RD_REG2 : begin
                PSEL = 1;
                PENABLE = 0;
                PADDR = 12'b00000000_10_00;
                PWRITE = 0;
                nstate = `RD_REG2_i;
            end

            `RD_REG2_i : begin
                PENABLE = 1;
                if(PREADY == 1) begin
                    nstate = `RD_REG3;
                end
                else nstate = cstate;
            end

            `RD_REG3 : begin
                PSEL = 1;
                PENABLE = 0;
                PADDR = 12'b00000000_11_00;
                PWRITE = 0;
                nstate = `RD_REG3_i;
            end

            `RD_REG3_i: begin
                PENABLE = 1;
                if(PREADY == 1) begin
                    nstate = `RD_RO0;
                end
                else nstate = cstate;
            end

            `RD_RO0: begin
                PENABLE = 0;
                PSEL = 1;
                PADDR = 12'b111111_0000_00;
                PWRITE = 0;
                nstate = `RD_RO0_i;
            end

            `RD_RO0_i: begin
                PENABLE = 1;
                if(PREADY) nstate = `RD_RO1;
                else nstate = cstate;
            end

            `RD_RO1:begin
                PENABLE = 0;
                PADDR = 12'b111111_0001_00;
                nstate = `RD_RO1_i;
            end

            `RD_RO1_i: begin
                PENABLE = 1;
                if(PREADY) nstate = `RD_RO2;
                else nstate = cstate;
            end

            `RD_RO2:begin
                PENABLE = 0;
                PADDR = 12'b111111_0010_00;
                nstate = `RD_RO2_i;
            end

            `RD_RO2_i: begin
                PENABLE = 1;
                if(PREADY) nstate = `RD_RO3;
                else nstate = cstate;
            end

            `RD_RO3:begin
                PENABLE = 0;
                PADDR = 12'b111111_0011_00;
                nstate = `RD_RO3_i;
            end

            `RD_RO3_i:begin
                PENABLE = 1;
                if(PREADY) nstate = `RD_RO4;
                else nstate = cstate;
            end

            `RD_RO4:begin
                PENABLE = 0;
                PADDR = 12'b111111_0100_00;
                nstate = `RD_RO4_i;
            end

            `RD_RO4_i:begin
                PENABLE = 1;
                if(PREADY) nstate = `RD_RO5;
                else nstate = cstate;
            end

            `RD_RO5:begin
                PENABLE = 0;
                PADDR = 12'b111111_0101_00;
                nstate = `RD_RO5_i;
            end

            `RD_RO5_i:begin
                PENABLE = 1;
                if(PREADY) nstate = `RD_RO6;
                else nstate = cstate;
            end

            `RD_RO6:begin
                PENABLE = 0;
                PADDR = 12'b111111_0110_00;
                nstate = `RD_RO5_i;
            end

            `RD_RO6_i:begin
                PENABLE = 1;
            end
        endcase

    end






    
endmodule

