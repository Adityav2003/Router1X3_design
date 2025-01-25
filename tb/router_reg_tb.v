module router_reg_tb;

    reg clock, resetn, pkt_valid, fifo_full, detect_add, ld_state, laf_state, full_state, lfd_state, rst_int_reg;
    reg [7:0] data_in;
    wire err, parity_done, low_packet_valid;
    wire [7:0] dout;


    router_reg DUT (
        .clock(clock),
        .resetn(resetn),
        .pkt_valid(pkt_valid),
        .fifo_full(fifo_full),
        .detect_add(detect_add),
        .ld_state(ld_state),
        .laf_state(laf_state),
        .full_state(full_state),
        .lfd_state(lfd_state),
        .rst_int_reg(rst_int_reg),
        .data_in(data_in),
        .err(err),
        .parity_done(parity_done),
        .low_packet_valid(low_packet_valid),
        .dout(dout)
    );

    // Clock generation
    always #5 clock = ~clock;
	 

    task initialize;
        begin
            clock = 0;
            resetn = 0;
            pkt_valid = 0;
            fifo_full = 0;
            detect_add = 0;
            ld_state = 0;
            laf_state = 0;
            full_state = 0;
            lfd_state = 0;
            rst_int_reg = 0;
            data_in = 8'b0;
        end
    endtask

    task apply_reset;
        begin
            resetn = 0;
            #10 resetn = 1;
        end
    endtask

    task load_data(input [7:0] packet, input fifo_status, input pkt_valid_signal);
        begin
            @(negedge clock);
            data_in = packet;
            fifo_full = fifo_status;
            pkt_valid = pkt_valid_signal;
            ld_state = 1;
            #10;
            ld_state = 0;
        end
    endtask
	 
	 task load_header(input [7:0] head);
		begin
			@(negedge clock);
			data_in = head;
			detect_add = 1;
			pkt_valid = 1;
			@(negedge clock);
			detect_add = 0;
			pkt_valid = 0;
			
		end
	 endtask

    task set_lfd_state(input [7:0] packet);
        begin
            @(negedge clock);
            lfd_state = 1;
            data_in = packet;
            #10;
            lfd_state = 0;
        end
    endtask

    task set_laf_state;
        begin
            @(negedge clock);
            laf_state = 1;
            #10;
            laf_state = 0;
        end
    endtask

    task test_parity(input [7:0] packet, input rst_int_signal);
        begin
            @(negedge clock);
            data_in = packet;
            detect_add = 1;
            rst_int_reg = rst_int_signal;
            #10;
            detect_add = 0;
        end
    endtask

    
    initial begin
        initialize;

        apply_reset;

        //  Load data in `ld_state`
       
        load_data(8'b01010101, 0, 1);
		  
		  //load header
		  
		  load_header(8'b01110101);

        //`lfd_state`
       
        set_lfd_state(8'b11110000);

        //`laf_state`
        
        load_data(8'b10101010, 1, 1); // FIFO full
		  
        set_laf_state;

        //parity error
        
        test_parity(8'b00110011, 1); // Incorrect parity,`rst_int_reg`

        // No parity error
        
        test_parity(8'b10101010, 0); // Correct parity, no error

        // Low packet valid
        
        @(negedge clock);
        pkt_valid = 0;
        lfd_state = 1;
        @(negedge clock);
        lfd_state = 0;

        #100;
        $finish;
    end

endmodule
