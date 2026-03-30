library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity bin2hex_tb is
end entity bin2hex_tb;

architecture sim of bin2hex_tb is
    -- Sinais para conectar ao DUT (Device Under Test)
    signal tb_BIN : std_logic_vector(3 downto 0) := (others => '0');
    signal tb_HEX : std_logic_vector(6 downto 0);
begin

    -- Instanciação do módulo bin2hex
    dut: entity work.bin2hex
        port map (
            BIN => tb_BIN,
            HEX => tb_HEX
        );

    -- Processo de estímulos para testar as entradas
    stim_process: process
    begin
        -- Teste 0: Zero
        tb_BIN <= "0000";
        wait for 10 ns;

        -- Teste 1: Um
        tb_BIN <= "0001";
        wait for 10 ns;

        -- Teste 2: Dois
        tb_BIN <= "0010";
        wait for 10 ns;

        -- Teste 3: Três
        tb_BIN <= "0011";
        wait for 10 ns;

        -- Teste 4: Quatro
        tb_BIN <= "0100";
        wait for 10 ns;

        -- Teste 5: Cinco
        tb_BIN <= "0101";
        wait for 10 ns;

        -- Teste 6: Seis
        tb_BIN <= "0110";
        wait for 10 ns;

        -- Teste 7: Sete
        tb_BIN <= "0111";
        wait for 10 ns;

        -- Teste 8: Oito
        tb_BIN <= "1000";
        wait for 10 ns;

        -- Teste 9: Nove
        tb_BIN <= "1001";
        wait for 10 ns;

        -- Teste A (10)
        tb_BIN <= "1010";
        wait for 10 ns;

        -- Teste B (11)
        tb_BIN <= "1011";
        wait for 10 ns;

        -- Teste C (12)
        tb_BIN <= "1100";
        wait for 10 ns;

        -- Teste D (13)
        tb_BIN <= "1101";
        wait for 10 ns;

        -- Teste E (14)
        tb_BIN <= "1110";
        wait for 10 ns;

        -- Teste F (15)
        tb_BIN <= "1111";
        wait for 10 ns;

        -- Teste others (apagado/desconhecido, como 'U' ou 'Z' na simulação)
        tb_BIN <= "UUUU";
        wait for 10 ns;

        wait; -- Finaliza simulação
    end process;

end architecture sim;