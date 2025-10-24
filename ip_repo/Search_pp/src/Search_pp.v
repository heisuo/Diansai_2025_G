//找最大最小值
module Search_pp #(
    parameter INPUT_DATA_WIDTH=16
)(
    input clk,
    input rst,
    input signed [INPUT_DATA_WIDTH-1:0]i_data,
    input i_start_pulse,
    input [31:0]i_search_time,
    output reg signed[31:0]o_search_max,
    output reg signed[31:0]o_search_min,
    output reg o_search_end_pulse
);
//~ 状态定义  
localparam IDLE = 'd1 << 0; // 空闲态, 'h1  
localparam WORK = 'd1 << 1; // 编码状态, 'h2  
localparam DONE = 'd1 << 2; // 结束态, 'h4  
reg [7:0]state=IDLE,r_state;
reg [31:0]search_cnt;
reg signed[31:0]r_search_max,r_search_min;
//o_search_end_pulse,o_search_min,o_search_max
always @(posedge clk ) begin
    o_search_max <= (state==IDLE & r_state==WORK) ? r_search_max : o_search_max;
    o_search_min <= (state==IDLE & r_state==WORK) ? r_search_min : o_search_min;
    o_search_end_pulse <= (state==IDLE & r_state==WORK);
end
//search_cnt
always @(posedge clk ) begin
    if(state==WORK)
        search_cnt<=(search_cnt==i_search_time-1) ? 0 : (search_cnt+1);
    else search_cnt<=0;
end
//r_search_max,r_search_min
always @(posedge clk ) begin
    case (state)
        IDLE:begin
            r_search_max<=-(1<<(INPUT_DATA_WIDTH-1));
            r_search_min<=(1<<(INPUT_DATA_WIDTH-1)-1);
        end 
        WORK:begin
            r_search_max<=(i_data>r_search_max) ? i_data : r_search_max;
            r_search_min<=(i_data<r_search_min) ? i_data : r_search_min;
        end
    endcase
end
always @(posedge clk ) begin
    if(rst)begin
        state<=IDLE;
    end
    else begin
        case (state)
            IDLE: state<=i_start_pulse ? WORK : state;
            WORK: state<=(search_cnt==i_search_time-1) ? IDLE : state;
            default:state<=IDLE; 
        endcase
    end
    r_state<=state;
end
endmodule