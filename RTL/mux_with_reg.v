module mux_with_reg(I, sel, CLK, EN, rst, out);
    parameter RSTTYPE = "SYNC", // ASYNC
              SIZE    = 1;

    input [SIZE-1:0] I;
    input sel, CLK, EN, rst;
    output [SIZE-1:0] out;

    reg [SIZE-1:0] I_reg;

    assign out = (~sel) ? I : I_reg;

    generate
        if(RSTTYPE == "SYNC") begin
            always @(posedge CLK) begin
            if(rst) 
                I_reg <= 0;   
            else if(EN)
                I_reg <= I;
            end    
        end 
            else if(RSTTYPE == "ASYNC") begin
            always @(posedge CLK, posedge rst) begin
                if(rst) 
                    I_reg <= 0;
                 
                else if(EN)
                    I_reg <= I;     
            end
        end 
    endgenerate

endmodule