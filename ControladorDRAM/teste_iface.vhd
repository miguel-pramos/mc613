library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all; -- Necessário para conversão de endereços

entity top_level_iface_test is
    port (
        CLOCK_50 : in  std_logic;
        KEY      : in  std_logic_vector(3 downto 0);
        SW       : in  std_logic_vector(9 downto 0);
        
        HEX0     : out std_logic_vector(6 downto 0);
        HEX1     : out std_logic_vector(6 downto 0);
        HEX4     : out std_logic_vector(6 downto 0);
        HEX5     : out std_logic_vector(6 downto 0);
        
        LEDR     : out std_logic_vector(9 downto 0) 
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

    -- SIMULAÇÃO DE MEMÓRIA COM MÚLTIPLOS REGISTRADORES
    -- Criamos um array de 4 posições (0 a 3)
    type memory_mock is array (0 to 3) of std_logic_vector(7 downto 0);
    signal r_registers : memory_mock := (others => (others => '0'));
    
    -- Índice para selecionar o registrador baseado nos bits 1 e 0 do endereço
    signal w_addr_idx : integer range 0 to 3;

begin

    w_rst <= not KEY(0);
    w_ready <= '1'; 
    
    -- Converte os 2 bits menos significativos do endereço em um índice inteiro
    -- Esses bits correspondem aos seus switches SW[5..4]
    w_addr_idx <= to_integer(unsigned(w_address(1 downto 0)));

    -- LEITURA: O dado lido depende de qual "endereço" está selecionado
    w_data_in <= r_registers(w_addr_idx);

    -- ESCRITA: Processo que simula o armazenamento em diferentes posições
    process(CLOCK_50, w_rst)
    begin
        if w_rst = '1' then
            r_registers <= (others => (others => '0'));
        elsif rising_edge(CLOCK_50) then
            -- Se a interface pedir uma escrita, salva no registrador selecionado pelo índice
            if w_req = '1' and w_wEn = '1' then
                r_registers(w_addr_idx) <= w_data_out;
            end if;
        end if;
    end process;

    -- Monitorização
    LEDR(0) <= w_req;   
    LEDR(1) <= w_wEn;   
    LEDR(9) <= w_ready; 

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