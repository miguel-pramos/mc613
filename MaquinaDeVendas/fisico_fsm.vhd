library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity teste_insere is
    port (
        CLOCK_50 : in std_logic;
        SW       : in std_logic_vector(9 downto 0);
        KEY      : in std_logic_vector(3 downto 0);
        HEX0     : out std_logic_vector(6 downto 0);
        HEX1     : out std_logic_vector(6 downto 0);
        HEX2     : out std_logic_vector(6 downto 0);
        HEX3     : out std_logic_vector(6 downto 0)
    );
end entity teste_insere;

architecture Behavioral of teste_insere is
    signal valor_produto : std_logic_vector(10 downto 0);
    signal valor_notas   : std_logic_vector(10 downto 0);
    signal valor_sub     : std_logic_vector(10 downto 0);
    signal valor_atual   : std_logic_vector(10 downto 0);
    signal valor_proximo : std_logic_vector(10 downto 0);
    signal bcd_out       : std_logic_vector(15 downto 0);
    
    signal load_price    : std_logic;
    signal enter_note    : std_logic;
    signal reg_enable    : std_logic;
begin

    -- Configuração dos Botões (Active-Low)
    load_price <= not KEY(1); -- Botão para simular a FSM no ST_ESCOLHE
	 
	 detector_enter : entity work.borda_subida
        port map (
            clk     => CLOCK_50,
            entrada => not KEY(0),
            saida   => enter_note
        );
    
    -- O registrador atualiza se apertarmos para carregar o preço ou para inserir a nota
    reg_enable <= load_price or enter_note;
    
    -- Multiplexador: Se estamos carregando o preço, salva o preço. Senão, salva a subtração.
    valor_proximo <= valor_produto when load_price = '1' else valor_sub;

    -- 1. Decodificador de Preço do Produto (Usa SW 3 a 0)
    inst_deco : entity work.deco_onehot
        port map (
            prod  => SW(3 downto 0),
            price => valor_produto
        );

    -- 2. Conversor de Notas/Moedas (Usa SW 9 a 4)
    inst_conv : entity work.Conv_Note
        port map (
            SW    => SW(9 downto 4),
            price => valor_notas
        );

    -- 3. Subtrator (Faz: valor_atual - valor_notas)
    inst_sub : entity work.sub11
        port map (
            valor_atual => valor_atual,
            valor_add   => valor_notas,
            valor_final => valor_sub
        );

    -- 4. Registrador que guarda o Saldo / Valor Restante a Pagar
    inst_reg : entity work.reg11
        port map (
            clk    => CLOCK_50,
            enable => reg_enable,
            reset  => not KEY(3),
            D      => valor_proximo,
            Q      => valor_atual
        );

    -- 5. Conversor para o Display
    inst_bin_bcd : entity work.bin11_to_bcd4
        port map (
            bin => valor_atual,
            bcd => bcd_out
        );

    -- 6. Mapeamento dos Displays
    display0 : entity work.bin2hex port map (BIN => bcd_out(3 downto 0),   HEX => HEX0);
    display1 : entity work.bin2hex port map (BIN => bcd_out(7 downto 4),   HEX => HEX1);
    display2 : entity work.bin2hex port map (BIN => bcd_out(11 downto 8),  HEX => HEX2);
    display3 : entity work.bin2hex port map (BIN => bcd_out(15 downto 12), HEX => HEX3);

end Behavioral;