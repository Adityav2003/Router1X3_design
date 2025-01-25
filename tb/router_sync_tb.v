module router_sync_tb();
    wire [2:0] write_enb;
    wire fifo_full;
    wire vld_out_0, vld_out_1, vld_out_2;
    wire soft_reset_0, soft_reset_1, soft_reset_2;
    reg clock, resetn, detect_add;
    reg [1:0] data_in;
    reg full_0, full_1, full_2;
    reg empty_0, empty_1, empty_2;
    reg write_enb_reg;
    reg read_enb_0, read_enb_1, read_enb_2;
    parameter CYCLE = 10;

    // Instantiate the DUT
    router_sync DUT (
    .clock(clock),
    .resetn(resetn),
    .detect_add(detect_add),
    .full_0(full_0),
    .full_1(full_1),
    .full_2(full_2),
    .empty_0(empty_0),
    .empty_1(empty_1),
    .empty_2(empty_2),
    .write_enb_reg(write_enb_reg),
    .read_enb_0(read_enb_0),
    .read_enb_1(read_enb_1),
    .read_enb_2(read_enb_2),
    .data_in(data_in),
    .write_enb(write_enb),
    .fifo_full(fifo_full),
    .soft_reset_0(soft_reset_0),
    .soft_reset_1(soft_reset_1),
    .soft_reset_2(soft_reset_2),
    .vld_out_0(vld_out_0),
    .vld_out_1(vld_out_1),
    .vld_out_2(vld_out_2)
);


    // Clock 
    initial begin
        clock = 1'b0;
        forever #(CYCLE / 2) clock = ~clock;
    end

    
    task initialize;
    begin
        {detect_add, data_in, full_0, full_1, full_2} = 0;
        {write_enb_reg, read_enb_0, read_enb_1, read_enb_2, empty_0, empty_1, empty_2} = 0;
    end
    endtask

    // Reset 
    task reset_dut;
    begin
        @(negedge clock)
            resetn = 1'b0;
        @(negedge clock)
            resetn = 1'b1;
    end
    endtask

    // Test 
    initial begin
        
		  initialize;
		  reset_dut;


        
               
        @(negedge clock)
        detect_add = 1;         
        data_in = 2'b10;        // channel 2
        full_0 = 0; full_1 = 0; full_2 = 0;  
        write_enb_reg = 1;      
        empty_0 = 0; empty_1 = 0; empty_2 = 0;  
        read_enb_0 = 0; read_enb_1 = 0; read_enb_2 = 0;
        #50;                   

        // Soft reset for channel 0 after 29 cycles
        @(negedge clock)
        detect_add = 1;        
        data_in = 2'b01;        
        full_0 = 0; full_1 = 1; full_2 = 0; 
        write_enb_reg = 1;      
        empty_0 = 0; empty_1 = 1; empty_2 = 1;  
        read_enb_0 = 0;         
        #300; 		  // soft reset to trigger (29 cycles)
		  
		  @(negedge clock)
        detect_add = 1;        
        data_in = 2'b10;        
        full_0 = 0; full_1 = 1; full_2 = 0;  
        write_enb_reg = 1;      
        empty_0 = 0; empty_1 = 1; empty_2 = 1;  
        read_enb_0 = 0;

        
        #100;
		  read_enb_2 = 1;
		  #200;
        $finish;
    end
endmodule
