module router_fifo_tb();

	reg clock, resetn, soft_reset, write_enb, read_enb, lfd_state;
	reg [7:0] data_in;
	wire full, empty;
	wire [7:0] data_out;

	parameter period = 10;
	reg [7:0] header, parity; //header and parity bit 
	reg [1:0] addr; //for defining address in header
	integer i;
	
	//INSTANTIATION

	router_fifo DUT(clock, resetn, soft_reset, write_enb, read_enb, lfd_state, data_in, full, empty, data_out);

	initial begin
		clock = 1'b0;
		forever #(period / 2) clock = ~clock;
	end

	task rst();
		begin
			@(negedge clock)
				resetn = 1'b0;
			@(negedge clock)
				resetn = 1'b1;
		end
	endtask

	task soft_rst();
		begin
			@(negedge clock)
				soft_reset = 1'b1;
			@(negedge clock)
				soft_reset = 1'b0;
		end
	endtask

	task initialize();
		begin
			write_enb = 1'b0;
			soft_reset = 1'b0;
			read_enb = 1'b0;
			data_in = 0;
			lfd_state = 1'b0;
		end
	endtask

	task pkt_gen;
		
		reg [7:0] payload_data;
		reg [5:0] payload_len;
		
		begin
			parity = 8'b11111111;
			@(negedge clock);
				payload_len = 6'd10;
				addr = 2'b01;	
				header = {payload_len, addr};
				data_in = header;
				lfd_state = 1'b1;
				write_enb = 1;

        for (i = 0; i < payload_len; i = i + 1) begin
            @(negedge clock);
					lfd_state = 1'b0;
					payload_data = {$random} % 256; //selecting random 8 bit value
					parity = parity ^ payload_data;
					data_in = payload_data;
        end

        @(negedge clock);
        data_in = parity;
		  
    end
endtask

	task write_read();
		reg [7:0] payload_data;
		begin
			for (i = 0; i < 8; i = i + 1) begin
					@(negedge clock);
					data_in = {$random} % 256;
					write_enb = 1;
			end
			write_enb = 0;

			@(negedge clock);
			read_enb = 1;
			wait(empty);
			@(negedge clock);
			read_enb = 0;
		end
	endtask

	initial begin
		rst();
		initialize();
		pkt_gen();
		
		write_read();
		@(negedge clock);
		read_enb = 1;
		@(negedge clock);
		read_enb = 0;

    for (i = 0; i < 16; i = i + 1) begin
        @(negedge clock);
        data_in = i;
        write_enb = 1;
    end
		write_enb = 0;
		
		@(negedge clock);
			read_enb = 1;
			#80;
			soft_rst();
			#60;
			@(negedge clock);
			read_enb = 0;
		
		

		#100 $finish;
	end

endmodule
