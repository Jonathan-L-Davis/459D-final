module test();
    
    bit clk;
    bit [7:0]result;
    core core_DUT(
        .clk(clk)
    );
    
    bit [5:0]func;
    bit [3:0]state;
    bit [5:0]op;
    bit [2:0]rs;
    bit [2:0]rt;
    bit [2:0]rd;
    bit [7:0]res;
    bit [7:0]d1;
    bit [7:0]d2;
    
    initial begin
        //for this test bench, we just drive the core 
        // and manually insert values into the right locations to make it compute. 
        //the outputs are observed in waveforms. 
        clk = 0;
        core_DUT.state = 4;

        //add 5 and 10
        core_DUT.REG_DUT.file[1] = 5;
        core_DUT.REG_DUT.file[2] = 10;
        core_DUT.IR = 32'h00221820;//add : r3 = r1 + r2
        for( int i = 0; i < 10; i++ ) begin
            
        rs = core_DUT.rs;
        rt = core_DUT.rt;
        rd = core_DUT.rd;
        op = core_DUT.instr_opcode;
        func = core_DUT.instr_func;
        result = core_DUT.REG_DUT.file[3];
        state = core_DUT.state;
        res = core_DUT.alu_result;
        d1 = core_DUT.alu_data1;
        d2 = core_DUT.alu_data2;
        
        
            #1ps;
            clk = 1;
            #1ps;
            clk = 0;
        rs = core_DUT.rs;
        rt = core_DUT.rt;
        rd = core_DUT.rd;
        op = core_DUT.instr_opcode;
        func = core_DUT.instr_func;
        result = core_DUT.REG_DUT.file[3];
        state = core_DUT.state;
        res = core_DUT.alu_result;
        d1 = core_DUT.alu_data1;
        d2 = core_DUT.alu_data2;
        
        end
    end

endmodule