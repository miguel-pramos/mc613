library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity fsm is

	Port (
		-- Entradas --
		enter : in std_logic;
		cancel : in std_logic;
		enough_money : in std_logic;
		timer_end : in std_logic;
		clk : in std_logic;
		reset : in std_logic;
		
		-- Saidas --
		product_enable : out std_logic;
		product_led : out std_logic;
		subtraction_enable : out std_logic;
		timer_on : out std_logic
	);
end fsm;

architecture Behavioural of fsm is
	type state_type is (ST_ESCOLHE, ST_INSERE, ST_DISPENSA, ST_CANCELA);
	signal state, next_state : state_type;

begin
	process(clk, reset)
	begin
		if reset = '1' then
			state <= ST_ESCOLHE;
		elsif rising_edge(clk) then
			state <= next_state;
		end if;
	end process;
	
	process(state, enter, cancel, enough_money, timer_end)
	begin 
		case state is 
			when ST_ESCOLHE =>  	-- escolhe_produto
				if enter = '1' then
					next_state <= ST_INSERE;
				else
					next_state <= ST_ESCOLHE;
				end if;
				
				product_enable <= '1';
				product_led <= '0';
				subtraction_enable <= '0';
				timer_on <= '0';
			
			when ST_INSERE =>   -- insere_dinheiro
				if cancel = '1' then
					next_state <= ST_CANCELA;
				elsif enough_money = '1' then
						next_state <= ST_DISPENSA;
				else
					next_state <= ST_INSERE;	
				end if;
			
				product_enable <= '0';
				product_led <= '0';
				subtraction_enable <= '1';
				timer_on <= '0';
		
			when ST_DISPENSA => -- dispensa_produto
				if timer_end = '1' then
					next_state <= ST_ESCOLHE;
				else
					next_state <= ST_DISPENSA;
				end if;
				
				product_enable <= '0';
				product_led <= '1';
				subtraction_enable <= '0';
				timer_on <= '1';
		
			when ST_CANCELA =>  -- cancela
				if timer_end = '1' then
					next_state <= ST_ESCOLHE;
				else
					next_state <= ST_CANCELA;
				end if;
				
				product_enable <= '0';
				product_led <= '0';
				subtraction_enable <= '0';
				timer_on <= '1';
			
			when others =>
				next_state <= ST_ESCOLHE;
				
			end case;
	end process;
end Behavioural;