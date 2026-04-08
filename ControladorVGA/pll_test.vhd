library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity pll_test_top is
    port (
        CLOCK_50 : in  std_logic;
        KEY      : in  std_logic_vector(0 downto 0); -- Reset
        LEDR     : out std_logic_vector(2 downto 0)  -- LEDS de status
    );
end pll_test_top;

architecture rtl of pll_test_top is

    -- Sinais internos
    signal pll_clk    : std_logic;
    signal pll_locked : std_logic;
    signal reset_n    : std_logic;
    
    -- Contadores de 25 bits para reduzir o clock de MHz para ~1.5 Hz (visível)
    signal counter_50mhz : unsigned(24 downto 0) := (others => '0');
    signal counter_pll   : unsigned(24 downto 0) := (others => '0');

begin

    -- Reset ativo em baixo (padrão das placas Altera/Intel)
    reset_n <= KEY(0);

    -- Instanciação do seu PLL
    pll_u : entity work.pll
        port map (
            refclk   => CLOCK_50,
            rst      => not reset_n, -- Se o seu PLL pede reset em '1'
            outclk_0 => pll_clk,
            locked   => pll_locked
        );

    -- Contador 1: Usando o clock original da placa
    process(CLOCK_50, reset_n)
    begin
        if reset_n = '0' then
            counter_50mhz <= (others => '0');
        elsif rising_edge(CLOCK_50) then
            counter_50mhz <= counter_50mhz + 1;
        end if;
    end process;

    -- Contador 2: Usando o clock que sai do seu PLL
    process(pll_clk, reset_n)
    begin
        if reset_n = '0' then
            counter_pll <= (others => '0');
        elsif rising_edge(pll_clk) then
            -- Só conta se o PLL estiver estável (locked)
            if pll_locked = '1' then
                counter_pll <= counter_pll + 1;
            end if;
        end if;
    end process;

    -- Atribuição aos LEDs
    LEDR(0) <= std_logic(counter_50mhz(24)); -- Pisca com o Clock 50MHz
    LEDR(1) <= std_logic(counter_pll(24));   -- Pisca com o Clock do PLL
    LEDR(2) <= pll_locked;                   -- LED aceso fixo se o PLL travou corretamente

end rtl;