library ieee;
use ieee.std_logic_1164.all;

entity top_level_iface_test is
    port (
        CLOCK_50 : in  std_logic;
        KEY      : in  std_logic_vector(3 downto 0);
        SW       : in  std_logic_vector(9 downto 0);
        
        HEX0     : out std_logic_vector(6 downto 0);
        HEX1     : out std_logic_vector(6 downto 0);
        HEX4     : out std_logic_vector(6 downto 0);
        HEX5     : out std_logic_vector(6 downto 0);
        
        LEDR     : out std_logic_vector(9 downto 0) -- LEDs para monitorizar sinais
    );
end top_level_iface_test;

architecture Structural of top_level_iface_test is

    signal w_rst      : std_logic;
    signal w_address  : std_logic_vector(25 downto 0);
    signal w_data_in  : std_logic_vector(7 downto 0);
    signal w_data_out : std_logic_vector(7 downto 0);
    signal w_req      : std_logic;
    signal w_wEn      : std_logic;
    signal w_ready    : std_logic;

signal r_mem_data : std_logic_vector(7 downto 0) := (others => '0');
begin

    w_rst <= not KEY(0);
    w_ready <= '1'; -- Mantemos ready em 1 para simplificar o teste inicial
    
    -- O dado que a interface "lê" vem do nosso registrador interno
    w_data_in <= r_mem_data;

    -- Processo que simula a escrita na memória
    process(CLOCK_50, w_rst)
    begin
        if w_rst = '1' then
            r_mem_data <= (others => '0');
        elsif rising_edge(CLOCK_50) then
            -- Se a interface pedir uma escrita (req=1 e wEn=1)
            if w_req = '1' and w_wEn = '1' then
                r_mem_data <= w_data_out; -- Salva o dado no registrador
            end if;
        end if;
    end process;

   
    -- Monitorização visual nos LEDs
    LEDR(0) <= w_req;   -- Acende quando há uma requisição (pulso rápido)
    LEDR(1) <= w_wEn;   -- Indica se a operação é Escrita (1) ou Leitura (0)
    LEDR(9) <= w_ready; -- Confirma que o "controlador" está pronto

    -- Instanciação da Interface
    u_interface : entity work.dram_iface
        port map (
            clk      => CLOCK_50,
            rst      => w_rst,
            SW       => SW,
            KEY      => KEY,
            HEX0     => HEX0,
            HEX1     => HEX1,
            HEX4     => HEX4,
            HEX5     => HEX5,
            
            address  => w_address,
            data_in  => w_data_in,
            data_out => w_data_out,
            req      => w_req,
            wEn      => w_wEn,
            ready    => w_ready
        );

end Structural;