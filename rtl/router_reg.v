module router_reg (
    input wire clock,
    input wire resetn,
    input wire pkt_valid,
    input wire fifo_full,
    input wire detect_add,
    input wire ld_state,
    input wire laf_state,
    input wire full_state,
    input wire lfd_state,
    input wire rst_int_reg,
    input wire [7:0] data_in,
    output reg err,
    output reg parity_done,
    output reg low_packet_valid,
    output reg [7:0] dout
);

    // Registers to hold intermediate values
	 
    reg [7:0] header, fifo_full_state, int_parity, pkt_parity;

    
    always @(posedge clock) begin
        if (~resetn) begin
            dout <= 8'b0;
            header <= 8'b0;
            fifo_full_state <= 8'b0;
        end
        else begin
            //DATA OUTPUT
				
            if (detect_add && pkt_valid && (data_in[1:0] != 2'b11))
                header <= data_in;
            else if (lfd_state)
                dout <= header;
            else if (ld_state && ~fifo_full)
                dout <= data_in;
            else if (ld_state && fifo_full)
                fifo_full_state <= data_in;
            else if (laf_state)
                dout <= fifo_full_state;
        end
    end

    //LOW PACKET VALID 
	 
    always @(posedge clock) begin
        if (~resetn)
            low_packet_valid <= 1'b0;
        else if (rst_int_reg)
            low_packet_valid <= 1'b0;
        else if (ld_state && ~pkt_valid)
            low_packet_valid <= 1'b1;
    end

    //PARITY DONE
	 
    always @(posedge clock) begin
        if (~resetn)
            parity_done <= 1'b0;
        else if (detect_add)
            parity_done <= 1'b0;
        else if ((ld_state && ~fifo_full && ~pkt_valid) || 
                 (laf_state && low_packet_valid && ~parity_done))
            parity_done <= 1'b1;
    end

    //CALCULATION OF PARITY INTERNAL
	 
    always @(posedge clock) begin
        if (~resetn)
            int_parity <= 8'b0;
        else if (detect_add)
            int_parity <= 8'b0;
        else if (lfd_state && pkt_valid)
            int_parity <= int_parity ^ header;
        else if (ld_state && pkt_valid && ~full_state)
            int_parity <= int_parity ^ data_in;
    end

    //ERROR
	 
    always @(posedge clock) begin
        if (~resetn)
            err <= 1'b0;
        else if (parity_done) begin
            if (int_parity == pkt_parity)
                err <= 1'b0;
            else
                err <= 1'b1;
        end
        else begin
            err <= 1'b0;
        end
    end

    //PACKET PARITY
	 
    always @(posedge clock) begin
        if (~resetn)
            pkt_parity <= 8'b0;
        else if (detect_add)
            pkt_parity <= 8'b0;
        else if ((ld_state && ~fifo_full && ~pkt_valid) || 
                 (laf_state && ~parity_done && low_packet_valid))
            pkt_parity <= data_in;
    end
	 
	 
	 

endmodule
