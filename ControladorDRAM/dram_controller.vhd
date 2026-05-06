library ieee;
use ieee.std_logic_1164.all;

entity dram_controller is
    port (
        -- Clocks e Entradas Gerais da Placa
        CLOCK_50 : in std_logic;
        KEY : in std_logic_vector(3 downto 0);
        SW : in std_logic_vector(9 downto 0);

        -- Displays de 7 Segmentos
        HEX0 : out std_logic_vector(6 downto 0);
        HEX1 : out std_logic_vector(6 downto 0);
        HEX4 : out std_logic_vector(6 downto 0);
        HEX5 : out std_logic_vector(6 downto 0);

        -- Pinos Físicos da SDRAM (IS42S16320D)
        DRAM_CLK : out std_logic;
        DRAM_CKE : out std_logic;
        DRAM_ADDR : out std_logic_vector(12 downto 0);
        DRAM_BA : out std_logic_vector(1 downto 0);
        DRAM_CS_N : out std_logic;
        DRAM_CAS_N : out std_logic;
        DRAM_RAS_N : out std_logic;
        DRAM_WE_N : out std_logic;
        DRAM_DQ : inout std_logic_vector(15 downto 0); -- Barramento Bidirecional
        DRAM_UDQM : out std_logic;
        DRAM_LDQM : out std_logic
    );
end dram_controller;

architecture Structural of dram_controller is

    -- Sinais internos de interligação
    signal w_rst : std_logic;
    signal w_address : std_logic_vector(25 downto 0);
    signal w_data_in : std_logic_vector(7 downto 0);
    signal w_data_out : std_logic_vector(7 downto 0);
    signal w_req : std_logic;
    signal w_wEn : std_logic;
    signal w_ready : std_logic;

    signal CLOCK_143 : std_logic;

begin

    w_rst <= not KEY(0);
	 
	 
    u_pll : entity work.pll_143
        port map(
            refclk => CLOCK_50,
            rst => w_rst,
            outclk_0 => CLOCK_143
        );
		  
    u_interface : entity work.dram_iface
        port map(
            clk => CLOCK_143,
            rst => w_rst,
            SW => SW,
            KEY => KEY,
            HEX0 => HEX0,
            HEX1 => HEX1,
            HEX4 => HEX4,
            HEX5 => HEX5,

            address => w_address,
            data_in => w_data_in,
            data_out => w_data_out,
            req => w_req,
            wEn => w_wEn,
            ready => w_ready
        );

    u_controller : entity work.dram_submodule
        port map(
            clk => CLOCK_143,
            rst => w_rst,
            wEn => w_wEn,
            req => w_req,

            o_cas => DRAM_CAS_N,
            o_ras => DRAM_RAS_N,
            o_cs => DRAM_CS_N,
            o_we => DRAM_WE_N,
            ready => w_ready
        );

    -- Clock e Clock Enable da memória sempre ativos
    DRAM_CLK <= CLOCK_143;
    DRAM_CKE <= '1';

    -- Máscaras de byte (Data Mask): Mantemos ambas em '0' para ler/escrever os 16 bits sempre
    DRAM_UDQM <= '0';
    DRAM_LDQM <= '0';

    -- LÓGICA TRISTATE DO BARRAMENTO BIDIRECIONAL
    -- Se w_wEn = '1' (Escrita): A FPGA "empurra" o w_data_out para a memória.
    -- Se w_wEn = '0' (Leitura ou Ocioso): A FPGA entra em Alta Impedância ('Z') e "escuta" a memória.
    DRAM_DQ(7 downto 0) <= w_data_out when (w_wEn = '1') else
                           (others => 'Z');

    -- Como a memória tem 16 bits e nosso dado interno tem 8, completamos com zeros na escrita
    DRAM_DQ(15 downto 8) <= (others => '0') when (w_wEn = '1') else
                            (others => 'Z');

    -- A leitura é um fio direto do barramento físico para o sinal interno
    w_data_in <= DRAM_DQ(7 downto 0);

    -- =========================================================
    -- 4. Roteamento de Endereço (Row/Col/Bank)
    -- =========================================================
    -- (Atenção: Num projeto avançado, o controlador multiplexa ROW e COL em tempos diferentes. 
    -- Para este esqueleto simplificado, passaremos o mapeamento direto de acordo com as chaves)
    DRAM_ADDR(12 downto 0) <= w_address(12 downto 0);
    DRAM_BA(1 downto 0) <= w_address(25 downto 24);

end Structural;