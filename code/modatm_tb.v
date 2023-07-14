module modatm_tb;
  reg clk;
  reg reset;
  reg card_in;
  reg pin_entry;
  reg withdrawal;
  reg deposit;
  reg balance_inquiry;
  reg language_select;
  
  wire ready;
  wire error;
  wire cash;
  wire deposit_complete;
  wire [15:0] balance;
  wire [1:0] language;
  
  // Instantiate the ATM module
  modatm atm (
    .clk(clk),
    .reset(reset),
    .card_in(card_in),
    .pin_entry(pin_entry),
    .withdrawal(withdrawal),
    .deposit(deposit),
    .balance_inquiry(balance_inquiry),
    .language_select(language_select),
    .ready(ready),
    .error(error),
    .cash(cash),
    .deposit_complete(deposit_complete),
    .balance(balance),
    .language(language)
  );
  
  // Clock generation
  always #5 clk = ~clk;
  
  initial begin
    clk = 0;
    reset = 1;
    card_in = 0;
    pin_entry = 0;
    withdrawal = 0;
    deposit = 0;
    balance_inquiry = 0;
    language_select = 0;
    
    // Reset ATM
    #10 reset = 0;
    
    // Test Scenario 1: Withdrawal
    #20 card_in = 1;
    #20 pin_entry = 1;
    #20 withdrawal = 1;
    #100 withdrawal = 0;
    #20 card_in = 0;
    #100;
    
    // Test Scenario 2: Deposit and Balance Inquiry
    #20 card_in = 1;
    #20 pin_entry = 1;
    #20 deposit = 100;
    #20 deposit = 0;
    #20 balance_inquiry = 1;
    #100;
    
    // Test Scenario 3: Language Selection
    #20 card_in = 1;
    #20 pin_entry = 1;
    #20 language_select = 2'b10;
    #100;
    
    // End of simulation
    $finish;
  end
endmodule
