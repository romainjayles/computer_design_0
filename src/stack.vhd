library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.defs.all;

entity stack is
  
  generic (
    size : natural := 10);            -- Maximum number of operands on stack

  port (
    clk       : in  std_logic;
    rst       : in  std_logic;
    value_in  : in  operand_t;
    push      : in  std_logic;
    pop       : in  std_logic;
    top       : out operand_t);

end entity stack;

architecture behavioural of stack is
	type ram is array ((size-1) downto 0) of operand_t;
	--type delay_ptr is array (0 to 2) of natural;
	signal stack : ram := (others => (others => '0'));
	--signal stack_ptr: delay_ptr; --:= (others => ( x"1")); -- stack_ptr is pointing always to the next free position
												-- in the stack
begin  -- architecture behavioural

  -- Fill in processes here.
  push_pop : process (clk, rst, push, pop)
  begin
		
		if (rising_edge(clk)) then
		   if (rst = '1') then
				stack <= (others => (others => '0'));
			else
				if (push = '1') then
					for i in 1 to size-1 loop
						stack(0) <= stack(1);
						stack(i- 1) <= stack(i); --shifting the stack down
						stack(size-1) <=  value_in; -- shift input
					end loop;		
	
				elsif (pop = '1') then
					--top <= stack_1024(stack_ptr);
					for i in 0 to size-2 loop
						stack(size-1) <= stack(size-2);
						stack(i+1) <= stack(i); --shifting the stack up
						stack(0) <=  x"00"; -- shift input
					end loop;
				else
					for i in 0 to size-1 loop
						stack(i) <= stack(i);
					end loop;
				end if;
			end if;
			 
		end if;
  end process ;
	top <= stack(size-1);

    

end architecture behavioural;
