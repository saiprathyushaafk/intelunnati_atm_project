module modatm (
  input wire clk,           // Clock signal
  input wire reset,         // Reset signal
  input wire card_in,       // Card insertion signal
  input wire pin_entry,     // PIN entry signal
  input wire withdrawal,    // Withdrawal request signal
  input wire deposit,       // Deposit request signal
  input wire balance_inquiry, // Balance inquiry request signal
  input wire language_select, // Language selection signal
  output reg ready,         // Ready signal
  output reg error,         // Error signal
  output wire cash,         // Cash dispense signal
  output wire deposit_complete, // Deposit complete signal
  output wire balance,      // Balance amount signal
  output wire language      // Selected language signal
);

  // Declare states
  parameter IDLE = 4'b0000;
  parameter CARD_INSERTED = 4'b0001;
  parameter PIN_ENTERED = 4'b0010;
  parameter WITHDRAWAL = 4'b0011;
  parameter DEPOSIT = 4'b0100;
  parameter BALANCE_INQUIRY = 4'b0101;
  
  // Declare registers
  reg [3:0] current_state, next_state;
  reg [15:0] account_balance;
  reg [1:0] selected_language;
  
  // Moore outputs
  assign cash = (current_state == WITHDRAWAL && withdrawal);
  assign deposit_complete = (current_state == DEPOSIT && deposit);
  assign balance = account_balance;
  assign language = selected_language;
  
  // Define ATM controller logic
  always @(posedge clk or posedge reset) begin
    if (reset) begin
      current_state <= IDLE;
      ready <= 1'b0;
      error <= 1'b0;
      account_balance <= 16'd0;
      selected_language <= 2'b00;
    end else begin
      current_state <= next_state;
      
      case (current_state)
        IDLE:
          if (card_in)
            next_state <= CARD_INSERTED;
        CARD_INSERTED:
          if (pin_entry)
            next_state <= PIN_ENTERED;
          else if (balance_inquiry)
            next_state <= BALANCE_INQUIRY;
          else if (withdrawal)
            next_state <= WITHDRAWAL;
          else if (deposit)
            next_state <= DEPOSIT;
        PIN_ENTERED:
          if (balance_inquiry)
            next_state <= BALANCE_INQUIRY;
          else if (withdrawal)
            next_state <= WITHDRAWAL;
          else if (deposit)
            next_state <= DEPOSIT;
        WITHDRAWAL:
          next_state <= IDLE;
        DEPOSIT:
          next_state <= IDLE;
        BALANCE_INQUIRY:
          next_state <= IDLE;
      endcase
      
      ready <= (current_state == IDLE);
      error <= (current_state == WITHDRAWAL && withdrawal);
      
      // Update account balance based on deposit request
      if (deposit)
        account_balance <= account_balance + deposit;
      
      // Update selected language based on language selection
      if (language_select)
        selected_language <= language_select;
    end
  end

endmodule
