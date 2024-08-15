module DSP48A1_tb;
    parameter A0REG       = 0,
              A1REG       = 1,
              B0REG       = 0,
              B1REG       = 1,
              CREG        = 1, 
              DREG        = 1, 
              MREG        = 1,
              PREG        = 1, 
              CARRYINREG  = 1,
              CARRYOUTREG = 1, 
              OPMODEREG   = 1;

    parameter CARRYINSEL = "OPMODE5",     //or CARRYIN -> else tie to 0
              B_INPUT    = "DIRECT",      //CASCADE -> else tie to 0
              RSTTYPE    = "SYNC";        // ASYNC

    reg CLK;
    reg CEA, CEB, CEC, CECARRYIN, CED, CEM, CEOPMODE, CEP;
    reg RSTA, RSTB, RSTC, RSTCARRYIN, RSTD, RSTM, RSTOPMODE, RSTP;

    //Input Signals
    reg [17:0] A, B;
    reg [47:0] C;
    reg [17:0] D;

    reg CARRYIN;

    reg [7:0] OPMODE;

    reg [17:0] BCIN;
    reg [47:0] PCIN;
    
    //Output Signals//
    wire [35:0] M;
    wire [47:0] P;
    wire CARRYOUT, CARRYOUTF;
    wire [17:0] BCOUT;
    wire [47:0] PCOUT;

    DSP48A1 #(A0REG, A1REG, B0REG, B1REG, CREG, DREG, MREG, PREG, CARRYINREG, 
     CARRYOUTREG, OPMODEREG, CARRYINSEL, B_INPUT, RSTTYPE) 
    dut(A, B, C, D, CARRYIN, M, P, CARRYOUT, CARRYOUTF, CLK, OPMODE,
    CEA, CEB, CEC, CECARRYIN, CED, CEM, CEOPMODE, CEP, RSTA, RSTB,
    RSTC, RSTCARRYIN, RSTD, RSTM, RSTOPMODE, RSTP, BCOUT, BCIN ,PCIN, PCOUT);
   
    initial begin
        CLK = 0;
        forever 
            #1 CLK = ~CLK;
    end

    initial begin
        {A, B, C, D, CARRYIN, OPMODE, BCIN, PCIN} = 0;
        {CEA, CEB, CEC, CECARRYIN, CED, CEM, CEOPMODE, CEP} = 0;

        {RSTA, RSTB, RSTC, RSTCARRYIN, RSTD, RSTM, RSTOPMODE, RSTP} = {8{1'b1}}; 
        @(negedge CLK);
        {RSTA, RSTB, RSTC, RSTCARRYIN, RSTD, RSTM, RSTOPMODE, RSTP} = 0; 

        {CEA, CEB, CEC, CECARRYIN, CED, CEM, CEOPMODE, CEP} = {8{1'b1}};
    
        
        ////////////////////////
        //pre-adder/subtracter//
        ////////////////////////
        OPMODE[6] = 0; //addition
        OPMODE[4] = 1;
        repeat(2) begin
            repeat(100) begin
                D = $random;
                B = $random;
                @(negedge CLK);
            end
            OPMODE[6] = 1; //subtraction
        end
        
        //////////////
        //multiplier//
        //////////////
        OPMODE[4] = 0;
        repeat(100) begin
            B = $random;
            A = $random;
            @(negedge CLK);
        end

        /////////////////////////
        //post-adder/subtracter//
        /////////////////////////
        OPMODE[1:0] = 2'b11; // mux_X
        OPMODE[3:2] = 2'b11; // mux_Z
       
        D = 0;
        OPMODE[7] = 0; //addition
        repeat(2) begin
            repeat(100) begin
                OPMODE[5] = $random;
                D[11:0] = $random;
                A = $random;
                B = $random;
                C = $random;
                @(negedge CLK);
            end
            OPMODE[7] = 1; //subtraction
        end

        ///////////////
        //accumulator//
        ///////////////

        //input C accumulation
        OPMODE[1:0] = 2'b10; // mux_X
        OPMODE[5] = 0;
        OPMODE[7] = 0; //addition
        RSTP = 1;
        RSTCARRYIN = 1;
        @(negedge CLK);
        RSTP = 0;
        RSTCARRYIN = 0;
        repeat(100) begin
            C = $random;
            @(negedge CLK);
        end

        //cascade P accumulation
        OPMODE[3:2] = 2'b01; // mux_Z
        RSTP = 1;
        RSTCARRYIN = 1;
        @(negedge CLK);
        RSTP = 0;
        RSTCARRYIN = 0;
        repeat(100) begin
            PCIN = $random;
            @(negedge CLK);
        end    
        
        $stop;
    end
endmodule