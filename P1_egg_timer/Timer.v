module Timer ();




egg_timer(CLOCK, reset_btn, state, timer, sec_1, sec_10, min_1, min_10);
dec2_7seg(sec_1, HEX0);
dec2_7seg(sec_10, HEX1);
dec2_7seg(min_1, HEX2);
dec2_7seg(min_10, HEX3);


endmodule

