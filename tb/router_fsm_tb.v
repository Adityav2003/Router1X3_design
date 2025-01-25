`timescale 1ns/1ps


module router_fsm_tb();
      
reg clock, resetn, pkt_valid, fifo_full, fifo_empty_0, fifo_empty_1, fifo_empty_2, 
    soft_reset_0, soft_reset_1, soft_reset_2, parity_done, low_packet_valid;
reg [1:0] data_in;
wire write_enb_reg, detect_add, ld_state, laf_state, lfd_state, full_state, rst_int_reg, busy;

parameter cycle = 10;

router_fsm DUT (
    clock, resetn, pkt_valid, data_in, fifo_full, fifo_empty_0, fifo_empty_1, fifo_empty_2, 
    soft_reset_0, soft_reset_1, soft_reset_2, parity_done, low_packet_valid, 
    write_enb_reg, detect_add, ld_state, laf_state, lfd_state, full_state, rst_int_reg, busy
);

parameter DECODE_ADDRESS       = 3'b000,
          LOAD_FIRST_DATA      = 3'b001,
          LOAD_DATA            = 3'b010,
          WAIT_TILL_EMPTY      = 3'b011,
          CHECK_PARITY_ERROR   = 3'b100,
          LOAD_PARITY          = 3'b101,
          FIFO_FULL_STATE      = 3'b110,
          LOAD_AFTER_FULL      = 3'b111;

reg [2:0] present_state;

// Clock Generation

initial begin
    clock = 1'b1;
    forever #(cycle / 2) clock = ~clock;
end

// Initialization Task

task initialize;
begin
    {pkt_valid, fifo_empty_0, fifo_empty_1, fifo_empty_2, fifo_full, parity_done, low_packet_valid} = 0;
	 {soft_reset_0, soft_reset_1, soft_reset_2} = 0;
    data_in = 2'b00;
end
endtask

// Reset Task

task apply_reset;
begin
    @(negedge clock) resetn = 1'b0;
    @(negedge clock) resetn = 1'b1;
end
endtask

//Basic Packet Flow

task test_case1;
begin
    @(negedge clock) begin
        pkt_valid = 1;
        data_in = 2'b00;
        fifo_empty_0 = 1;
    end
    @(negedge clock) fifo_full = 0; pkt_valid = 0; // Simulate packet end
    @(negedge clock);
end
endtask

//FIFO Full Scenario

task test_case2;
begin
    @(negedge clock) begin
        pkt_valid = 1;
        data_in = 2'b01;
        fifo_empty_1 = 1;
    end
    @(negedge clock) fifo_full = 1; // Simulate FIFO full
    @(negedge clock) fifo_full = 0; // Clear FIFO full
    @(negedge clock) begin
        low_packet_valid = 1;
        parity_done = 1;
    end
end
endtask

// Parity Error Detection

task test_case3;
begin
    @(negedge clock) begin
        pkt_valid = 1;
        data_in = 2'b10;
        fifo_empty_2 = 1;
    end
    @(negedge clock) parity_done = 0; // Simulate parity error
    @(negedge clock) parity_done = 1;
end
endtask

// Wait Till Empty

task test_case4;
begin
    @(negedge clock) begin
        pkt_valid = 1;
        data_in = 2'b00;
        fifo_empty_0 = 0; // FIFO not empty
    end
    @(negedge clock) fifo_empty_0 = 1; // FIFO becomes empty
end
endtask

// Simulation Flow

initial begin

	$monitor("Time = %t ps, Present State = %b", $time, DUT.PS);
	present_state = DUT.PS;

    apply_reset;
	 
    initialize;

    test_case1; 
	 apply_reset; 
	 #30;
	 
    test_case2; 
	 apply_reset; 
	 #30;
	 
    test_case3; 
	 apply_reset; 
	 #30;
	 @(negedge clock) soft_reset_1 = 0; // Simulate parity error
    @(negedge clock) soft_reset_1 = 1; 	
	 
    test_case4; 
	 apply_reset; 
	 #30;

    $finish;
	
	 

	 
end

endmodule
