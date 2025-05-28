task task_clock_gen (ref logic i_clk);
    begin
        i_clk = '1;
        forever #10 i_clk = ~i_clk;
    end
endtask

task task_reset (ref logic i_rstn, input int RESETPERIOD);
    begin
        i_rstn = '0;
        #RESETPERIOD i_rstn = '1;
    end
endtask

task task_timeout(input int FINISH);
    begin
        #FINISH $display("\nTimeout...\n\nDUT is considered\tP A S S E D\n");
                $finish;
    end
endtask
