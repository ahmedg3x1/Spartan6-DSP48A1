module DSP48A1(
    A, B, C, D, CARRYIN, M, P, CARRYOUT, CARRYOUTF, CLK, OPMODE,
    CEA, CEB, CEC, CECARRYIN, CED, CEM, CEOPMODE, CEP, RSTA, RSTB,
    RSTC, RSTCARRYIN, RSTD, RSTM, RSTOPMODE, RSTP, BCOUT, BCIN ,PCIN, PCOUT
);

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

    parameter CARRYINSEL = "OPMODE5", //or CARRYIN -> else tie to 0
              B_INPUT    = "DIRECT",  //CASCADE    -> else tie to 0
              RSTTYPE    = "SYNC";    //ASYNC

///////////////
//Data Ports://
///////////////
    input [17:0] A, B, D;
    input [47:0] C;
    input CARRYIN;

    output [35:0] M;
    output [47:0] P;
    output CARRYOUT, CARRYOUTF;

////////////////////////
//Control Input Ports://
////////////////////////
    input CLK;
    input [7:0] OPMODE;

/////////////////////////////
//Clock Enable Input Ports://
/////////////////////////////
    input CEA, CEB, CEC, CECARRYIN, CED, CEM, CEOPMODE, CEP;

//////////////////////
//Reset Input Ports://
//////////////////////
    input RSTA, RSTB, RSTC, RSTCARRYIN, RSTD, RSTM, RSTOPMODE, RSTP;


//////////////////
//Cascade Ports://
//////////////////
    input [17:0] BCIN;
    output [17:0] BCOUT;
    
    input [47:0] PCIN;
    output [47:0] PCOUT;


//////////////////////////////////////////////////////////////
    wire [7:0] mux_OPMODE_out;
    wire [17:0] mux_D_out, mux_B0_input, mux_B0_out, mux_A0_out;
    wire [47:0] mux_C_out;
   
    //OPMODE
    mux_with_reg #(.RSTTYPE(RSTTYPE), .SIZE(8)) mux_OPMODE(.I(OPMODE), .sel(OPMODEREG), .CLK(CLK), .rst(RSTOPMODE), .EN(CEOPMODE), .out(mux_OPMODE_out));
    
    //D Input
    mux_with_reg #(.RSTTYPE(RSTTYPE), .SIZE(18)) mux_D(.I(D), .sel(DREG), .CLK(CLK), .rst(RSTD), .EN(CED), .out(mux_D_out));

    //B Input
    assign mux_B0_input = (B_INPUT == "DIRECT") ? B : (B_INPUT == "CASCADE") ? BCIN : 0;
    mux_with_reg #(.RSTTYPE(RSTTYPE), .SIZE(18)) mux_B0(.I(mux_B0_input), .sel(B0REG), .CLK(CLK), .EN(CEB), .rst(RSTB), .out(mux_B0_out));

    //A Input
    mux_with_reg #(.RSTTYPE(RSTTYPE), .SIZE(18)) mux_A0(.I(A), .sel(A0REG), .CLK(CLK), .rst(RSTA), .EN(CEA), .out(mux_A0_out));
    
    //C Input
    mux_with_reg #(.RSTTYPE(RSTTYPE), .SIZE(48)) mux_C(.I(C), .sel(CREG), .CLK(CLK), .rst(RSTC), .EN(CEC), .out(mux_C_out));

//////////////////////////////////////////////////////////////


//////////////////////////////////////////////////////////////  
    wire [17:0] mux_B1_input, mux_B1_out, mux_A1_out;
    wire [35:0] multiplier_out, mux_M_out;
    reg [17:0] pre_adder_subtractor_out;

    //Pre-Adder/subtracter
    always @(*) begin
        if (~mux_OPMODE_out[6]) 
            pre_adder_subtractor_out = mux_D_out + mux_B0_out;
        else 
            pre_adder_subtractor_out =  mux_D_out - mux_B0_out;
    end

    //B Input pipeline
    assign mux_B1_input = (~mux_OPMODE_out[4]) ? mux_B0_out : pre_adder_subtractor_out;
    mux_with_reg #(.RSTTYPE(RSTTYPE), .SIZE(18)) mux_B1(.I(mux_B1_input), .sel(B1REG), .CLK(CLK), .EN(CEB), .rst(RSTB), .out(mux_B1_out));
    assign BCOUT = mux_B1_out;

    //A Input pipeline
    mux_with_reg #(.RSTTYPE(RSTTYPE), .SIZE(18)) mux_A1(.I(mux_A0_out), .sel(A1REG), .CLK(CLK), .EN(CEA), .rst(RSTA), .out(mux_A1_out));
    
    //multiplier
    assign multiplier_out = mux_A1_out * mux_B1_out;
    mux_with_reg #(.RSTTYPE(RSTTYPE), .SIZE(36)) mux_M(.I(multiplier_out), .sel(MREG), .CLK(CLK), .EN(CEM), .rst(RSTM), .out(mux_M_out));

    genvar i;
    generate
        for (i = 0; i < 36; i = i + 1)
            buf(M[i], mux_M_out[i]);
    endgenerate
//////////////////////////////////////////////////////////////  



//////////////////////////////////////////////////////////////  
    reg [47:0] mux_X_out, mux_Z_out;
    wire mux_carry_input, cin;

    //mux_X
    always @(*) begin
        case (mux_OPMODE_out[1:0])
            0: mux_X_out = 0;
            1: mux_X_out = {0, mux_M_out};
            2: mux_X_out = P; 
            3: mux_X_out = {mux_D_out, mux_A1_out, mux_B1_out};
        endcase
    end

    //mux_y
    always @(*) begin
        case (mux_OPMODE_out[3:2])
            0: mux_Z_out = 0;
            1: mux_Z_out = PCIN;
            2: mux_Z_out = P; 
            3: mux_Z_out = mux_C_out;
        endcase
    end

    // carry in
    assign mux_carry_input = (CARRYINSEL == "CARRYIN") ? CARRYIN : (CARRYINSEL == "OPMODE5") ? mux_OPMODE_out[5] : 0;
    mux_with_reg #(.RSTTYPE(RSTTYPE), .SIZE(1)) mux_CYI(.I(mux_carry_input), .sel(CARRYINREG), .CLK(CLK), .EN(CECARRYIN), .rst(RSTCARRYIN), .out(cin));

    //Post-Adder/Subtractor
    reg [47:0] post_adder_subtractor_out;
    reg COUT;

    always @(*) begin
        if (~mux_OPMODE_out[7]) 
            {COUT, post_adder_subtractor_out} = mux_Z_out + mux_X_out  + cin;
        else 
            {COUT, post_adder_subtractor_out} = mux_Z_out - (mux_X_out + cin);
    end
        mux_with_reg #(.RSTTYPE(RSTTYPE), .SIZE(48)) mux_P(.I(post_adder_subtractor_out), .sel(PREG), .CLK(CLK), .EN(CEP), .rst(RSTP), .out(P));
        mux_with_reg #(.RSTTYPE(RSTTYPE), .SIZE(1)) mux_CYO(.I(COUT), .sel(CARRYOUTREG), .CLK(CLK), .EN(CECARRYIN), .rst(RSTCARRYIN), .out(CARRYOUT));
        
        assign PCOUT = P;
        assign CARRYOUTF = CARRYOUT;
//////////////////////////////////////////////////////////////  
endmodule