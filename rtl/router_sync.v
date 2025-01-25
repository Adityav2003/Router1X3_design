//ROUTER SYNCHRONIZER

module router_sync (
    input clock, resetn, detect_add, full_0, full_1, full_2, 
    input empty_0, empty_1, empty_2, write_enb_reg, read_enb_0, read_enb_1, read_enb_2,
    input [1:0] data_in,

    output reg [2:0] write_enb,
    output reg fifo_full, 
    output reg soft_reset_0, soft_reset_1, soft_reset_2,
    output vld_out_0, vld_out_1, vld_out_2
);

    reg [1:0] data_in_tmp; // for synchronising the data address input
    reg [4:0] count0, count1, count2; //counter for soft reset
    
    //SYNCHRONISING DATA ADDRESS
	 
    always @(posedge clock or negedge resetn) begin
        if (!resetn) 
            data_in_tmp <= 0; 
        else if (detect_add) 
            data_in_tmp <= data_in;
    end
    
    //DECODING THE ADDRESS
	 
    always @(*) begin // immedistely assign the values
        case (data_in_tmp)
            2'b00: begin
                fifo_full <= full_0;
                write_enb <= (write_enb_reg) ? 3'b001 : 3'b000;
            end
            2'b01: begin
                fifo_full <= full_1;
                write_enb <= (write_enb_reg) ? 3'b010 : 3'b000;
            end
            2'b10: begin
                fifo_full <= full_2;
                write_enb <= (write_enb_reg) ? 3'b100 : 3'b000;
            end
            default: begin
                fifo_full <= 0;
                write_enb <= 3'b000;
            end
        endcase
    end
    
    

    //SOFT RESET 0 LOGIC - ACTIVE HIGH
	 
    always @(posedge clock) begin
        if (~resetn) begin
            count0 <= 0;
            soft_reset_0 <= 0;
        end else if (vld_out_0 && ~read_enb_0) begin
            if (count0 == 29) begin
                soft_reset_0 <= 1'b1; 
                count0 <= 0;
            end else begin
                soft_reset_0 <= 1'b0;
                count0 <= count0 + 1'b1;
            end
        end else begin
            count0 <= 0;
        end
    end
	 
	 //SOFT RESET 1 LOGIC - ACTIVE HIGH

    always @(posedge clock) begin
        if (~resetn) begin
            count1 <= 0;
            soft_reset_1 <= 0;
        end else if (vld_out_1 && ~read_enb_1) begin
            if (count1 == 29) begin
                soft_reset_1 <= 1'b1;
                count1 <= 0;
            end else begin
                soft_reset_1 <= 1'b0;
                count1 <= count1 + 1'b1;
            end
        end else begin
            count1 <= 0;
        end
    end
	 
	 //SOFT RESET 2 LOGIC - ACTIVE HIGH

    always @(posedge clock) begin
        if (~resetn) begin
            count2 <= 0;
            soft_reset_2 <= 0;
        end else if (vld_out_2 && ~read_enb_2) begin
            if (count2 == 29) begin
                soft_reset_2 <= 1'b1;
                count2 <= 0;
            end else begin
                soft_reset_2 <= 1'b0;
                count2 <= count2 + 1'b1;
            end
        end else begin
            count2 <= 0;
        end
    end
	 
	 //VALID BYTE
	 
    assign vld_out_0 = ~empty_0;
    assign vld_out_1 = ~empty_1;
    assign vld_out_2 = ~empty_2;

endmodule
