

module router_fifo(clock,resetn,soft_reset,write_enb,read_enb,
                   lfd_state,data_in,full,empty,data_out);
  
  input clock,resetn,soft_reset;
  input write_enb,read_enb,lfd_state;
  input [7:0]data_in;
  
  output reg [7:0] data_out;
  output full,empty;
  
  reg [3:0] rd_pointer,wr_pointer; //traverse the 16 stack elements
  reg [6:0] count;
  reg [8:0] mem [15:0]; //memory stack

  integer i;
  
   reg lfd_state_t; //making the lfd_state synchronous to clock
  
  always@(posedge clock)
    begin
      if(!resetn)
        lfd_state_t <= 0;
      else
        lfd_state_t <= lfd_state; //making lfd_state synchronous
    end 
   
  // READING VALUES FROM FIFO
  
  always@(posedge clock) 
    begin
      if(!resetn)
          data_out <= 8'b0;
      else if(soft_reset) 
          data_out <= 8'b0;
      else if((read_enb) && (!empty))
        data_out <= mem[rd_pointer[3:0]][7:0];
      else data_out = 8'b0;
    end
  
  // WRITING VALUES INTO FIFO
  
  always@(posedge clock) 
    begin
      if(!resetn || soft_reset)
         begin
            for(i=0;i<16;i=i+1)
            mem[i]<=0;				//reset the memory
         end
      else if(write_enb && (!full))   
         begin
           if(lfd_state_t)			//write the header
	           begin
                 mem[wr_pointer[3:0]][8]<=1'b1;
                 mem[wr_pointer[3:0]][7:0]<=data_in;
	           end
      
	      else
	           begin
                 mem[wr_pointer[3:0]][8]<=1'b0;
                 mem[wr_pointer[3:0]][7:0]<=data_in;
			   end
         end
     end

      
    
  
  //WRITE POINTER

   always@(posedge clock) 
     begin
       if(!resetn)
        wr_pointer<=0;
      else if(write_enb && (!full))
        wr_pointer<=wr_pointer+1;
     end
	  
	//READ POINTER
   
   always@(posedge clock) 
     begin
       if(!resetn)
         rd_pointer<=0;
       else if(read_enb && (!empty))
         rd_pointer<=rd_pointer+1;
     end
  
  
  //COUNTING THE BLOCKS WHEN READ POINTER IS TRAVERSING
  
  always@(posedge clock)
    begin
      if(read_enb && !empty)
        begin
          if((mem[rd_pointer[3:0]][8])==1'b1)
            count <= mem[rd_pointer[3:0]][7:2] + 1'b1;
          else if(count != 0)
            count <= count - 1'b1;
        end
    end
	 
	 
  //FULL AND EMPTY CONDITIONS
	assign full = (wr_pointer == rd_pointer - 1'b1) ? 1'b1 : 1'b0;
	assign empty = (rd_pointer == wr_pointer) ? 1'b1 : 1'b0;
  
  
endmodule
