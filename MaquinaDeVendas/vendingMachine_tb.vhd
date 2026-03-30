library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity vending_machine_tb is
end entity;

architecture tb of vending_machine_tb is

    -- Sinais de estímulo / observação
    signal CLOCK_50_s : std_logic := '0';
    signal KEY_s      : std_logic_vector(1 downto 0) := (others => '1'); -- botões ativos em '0' na placa
    signal SW_s       : std_logic_vector(9 downto 0) := (others => '0');

    signal HEX0_s     : std_logic_vector(6 downto 0);
    signal HEX1_s     : std_logic_vector(6 downto 0);
    signal HEX2_s     : std_logic_vector(6 downto 0);
    signal HEX3_s     : std_logic_vector(6 downto 0);
    signal HEX5_s     : std_logic_vector(6 downto 0);
    signal LEDR_s     : std_logic_vector(1 downto 0);

    constant CLK_PERIOD : time := 20 ns;  -- 50 MHz

begin

    -- Instancia UUT
    uut: entity work.vending_machine
        port map (
            CLOCK_50 => CLOCK_50_s,
            KEY      => KEY_s,
            SW       => SW_s,
            HEX0     => HEX0_s,
            HEX1     => HEX1_s,
            HEX2     => HEX2_s,
            HEX3     => HEX3_s,
            HEX5     => HEX5_s,
            LEDR     => LEDR_s
        );

    -- Geração de clock
    clk_process : process
    begin
        while true loop
            CLOCK_50_s <= '0';
            wait for CLK_PERIOD/2;
            CLOCK_50_s <= '1';
            wait for CLK_PERIOD/2;
        end loop;
        wait; -- segurança
    end process;

    -- Estímulos principais
    stim_proc : process
    begin
        -- Reset inicial: mantém tudo em nível inativo por algum tempo
        SW_s  <= (others => '0');
        KEY_s <= (others => '1');
        wait for 200 ns;

        -----------------------------------------------------------------
        -- CENÁRIO 1: Compra simples, produto 0, inserindo valor exato
        -----------------------------------------------------------------
        -- Seleciona produto 0
        SW_s(3 downto 0) <= "0000";
        wait for 5*CLK_PERIOD;

        -- Pressiona AVANÇAR (KEY(0) ativo em '0') para travar produto
        KEY_s(0) <= '0';
        wait for 1*CLK_PERIOD;
        KEY_s(0) <= '1';
        wait for 10*CLK_PERIOD;

        -- Insere uma nota, por exemplo SW(4) = 0,05 (apenas exemplo de uso)
        SW_s(9 downto 4) <= "000001"; -- somente SW(4) = '1'
        wait for 5*CLK_PERIOD;

        -- Pressiona AVANÇAR para registrar a nota
        KEY_s(0) <= '0';
        wait for 1*CLK_PERIOD;
        KEY_s(0) <= '1';
        SW_s(9 downto 4) <= (others => '0');
        wait for 20*CLK_PERIOD;

        -----------------------------------------------------------------
        -- CENÁRIO 2: Cancelamento durante operação
        -----------------------------------------------------------------
        -- Seleciona produto 1
        SW_s(3 downto 0) <= "0001";
        wait for 5*CLK_PERIOD;

        -- Travar produto
        KEY_s(0) <= '0';
        wait for 1*CLK_PERIOD;
        KEY_s(0) <= '1';
        wait for 5*CLK_PERIOD;

        -- Simula inserção de dinheiro em SW(5)
        SW_s(9 downto 4) <= "000010";
        wait for 5*CLK_PERIOD;

        KEY_s(0) <= '0';  -- AVANÇAR
        wait for 1*CLK_PERIOD;
        KEY_s(0) <= '1';
        SW_s(9 downto 4) <= (others => '0');
        wait for 10*CLK_PERIOD;

        -- Agora cancela operação
        KEY_s(1) <= '0'; -- CANCELAR ativo em '0'
        wait for 1*CLK_PERIOD;
        KEY_s(1) <= '1';
        wait for 100*CLK_PERIOD;

        -----------------------------------------------------------------
        -- Fim da simulação
        -----------------------------------------------------------------
        wait;
    end process;

end architecture;