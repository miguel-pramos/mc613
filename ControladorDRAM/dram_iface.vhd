library ieee;
use ieee.std_logic_1164.all;

entity dram_iface is
    port (
        clk : in std_logic;
        rst : in std_logic;

        -- Entradas do Usuário (Placa)
        SW : in std_logic_vector(9 downto 0);
        KEY : in std_logic_vector(3 downto 0);

        -- Saídas para Displays de 7 Segmentos
        HEX0 : out std_logic_vector(6 downto 0);
        HEX1 : out std_logic_vector(6 downto 0);
        HEX4 : out std_logic_vector(6 downto 0);
        HEX5 : out std_logic_vector(6 downto 0);

        -- Comunicação com o dram_controller
        address : out std_logic_vector(25 downto 0);
        data_in : in std_logic_vector(7 downto 0); -- Dado lido da memória
        data_out : out std_logic_vector(7 downto 0); -- Dado a ser escrito na memória
        req : out std_logic;
        wEn : out std_logic;
        ready : in std_logic
    );
end dram_iface;

architecture Structural of dram_iface is

    signal w_switch_change : std_logic;
    signal w_write_req : std_logic;
	signal w_address_full : std_logic_vector(25 downto 0);

    -- Registrador para guardar o estado anterior das chaves de endereço (SW[9..4])
    signal r_last_sw_addr : std_logic_vector(5 downto 0);

begin
	 address <= w_address_full;

    u_addr_detector : entity work.addr_change_detector
        port map(
            clk => clk,
            rst => rst,
            addr_sw => SW(9 downto 4), -- Passa apenas as chaves referentes ao endereço
            change_pulse => w_switch_change
        );

    -- botão de avançar
    u_edge_detector : entity work.borda_subida
        port map(
            clk => clk,
            entrada => not KEY(3),
            saida => w_write_req
        );

    -- conversor de address
    u_addr_conversor : entity work.addr_conversor
        port map(
            entrada => SW(9 downto 0),
            saida => w_address_full
        );

    -- roteamento de dados
    data_out(3 downto 0) <= SW(3 downto 0);
    data_out(7 downto 4) <= "0000";

    -- FSM
    u_iface_fsm : entity work.iface_fsm
        port map(
            clk => clk,
            rst => rst,
            switch_change => w_switch_change,
            write_req => w_write_req,
            ready => ready,
            req => req,
            enable_op => wEn
        );

    -- displays
    u_hex0 : entity work.bin2hex
        port map(BIN => data_in(3 downto 0), HEX => HEX0);

    u_hex1 : entity work.bin2hex
        port map(BIN => data_in(7 downto 4), HEX => HEX1);

    u_hex4 : entity work.bin2hex
        port map(BIN => w_address_full(3 downto 0), HEX => HEX4);

    u_hex5 : entity work.bin2hex
        port map(BIN => w_address_full(7 downto 4), HEX => HEX5);

end Structural;