library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.defs.all;

entity control is
  
  port (
    clk : in std_logic;
    rst : in std_logic;

    -- Communication
    instruction : in  instruction_t;
    empty       : in  std_logic;
    read        : out std_logic;

    -- Stack control
    push      : out std_logic;
    pop       : out std_logic;
    stack_src : out stack_input_select_t;
    operand   : out operand_t;

    -- ALU control
    a_wen   : out std_logic;
    b_wen   : out std_logic;
    alu_sel : out alu_operation_t);


end entity control;

architecture behavioural of control is
  type   state_t is (IDLE, FETCH, DECODE, PUSH_OPERAND, POP_A, POP_B, COMPUTE, PUSH_RESULT);  -- the name of the states
  -- Fill in type and signal declarations here.
  signal current_state, next_state : state_t;  -- The current and the next step

  function idle_transition(empty : std_logic) return state_t is
  begin
    if empty = '1' then
      return IDLE;
    else
      return FETCH;
    end if;
  end idle_transition;

  function decode_transition (instruction : instruction_t) return state_t is
  begin
    --change
    if instruction(15 downto 8) = "00000000" then
      return PUSH_OPERAND;
    else
      return POP_B;
    end if;
  end decode_transition;
  
begin  -- architecture behavioural
  -- Fill in type and signal declarations here.
  with current_state select
    next_state <=
    idle_transition(empty)         when IDLE,
    DECODE                         when FETCH,
    decode_transition(instruction) when DECODE,
    POP_A                          when POP_B,
    COMPUTE                        when POP_A,
    PUSH_RESULT                    when COMPUTE,
    IDLE                           when PUSH_RESULT,
    IDLE                           when PUSH_OPERAND;

  -- Fill in processes here.
  process(current_state) is
  begin
    read    <= '0';
    b_wen   <= '0';
    a_wen   <= '0';
    pop     <= '0';
    push    <= '0';
    operand <= instruction(7 downto 0);
    case current_state is
      when FETCH =>
        read <= '1';
      when PUSH_OPERAND =>
        push      <= '1';
        stack_src <= STACK_INPUT_OPERAND;
      when POP_B =>
        b_wen <= '1';
        pop   <= '1';
      when POP_A =>
        a_wen <= '1';
        pop   <= '1';
      when COMPUTE =>
        -- change with a case close on instruction
		  case instruction(15 downto 8) is
		  when "00000001" =>
				alu_sel <= ALU_ADD;
		  when "00000010" =>
				alu_sel <= ALU_SUB;
			when others =>
				alu_sel <= ALU_ADD;
			end case;
      when PUSH_RESULT =>
        stack_src <= STACK_INPUT_RESULT;
        push      <= '1';
      when others =>
        null;
    end case;
  end process;


  process(clk, rst) is
    -- this process allow to go to a next state or reset the FSM
  begin
    if rst = '1' then
      current_state <= IDLE;
    elsif rising_edge(clk) then
      current_state <= next_state;
    end if;
  end process;
  

end architecture behavioural;




