library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity vending_machine is
    port (
        CLOCK_50 : in std_logic;
        KEY : in std_logic_vector(1 downto 0);
        SW : in std_logic_vector(9 downto 0);
        HEX0 : out std_logic_vector(6 downto 0);
        HEX1 : out std_logic_vector(6 downto 0);
        HEX2 : out std_logic_vector(6 downto 0);
        HEX3 : out std_logic_vector(6 downto 0);
        HEX5 : out std_logic_vector(6 downto 0);
        LEDR : out std_logic_vector(1 downto 0)
    );
end vending_machine;

architecture Behavioral of vending_machine is
    -- Sinais de controle interno
    signal enter_s          : std_logic;
    signal cancel_s         : std_logic;
    signal timer_end_s      : std_logic;
    
    signal product_enable_s     : std_logic;
    signal product_led_s        : std_logic;
    signal subtraction_enable_s : std_logic;
    signal timer_on_s           : std_logic;
    
    -- Sinais de dados
    signal product              : std_logic_vector(3 downto 0);
    signal valor_atual          : std_logic_vector(10 downto 0); -- Saldo no registrador
    signal valor_proximo        : std_logic_vector(10 downto 0); -- "Mux"
    signal valor_sub            : std_logic_vector(10 downto 0); -- Saída do subtrator/somador
    signal valor_produto        : std_logic_vector(10 downto 0);
    signal valor_notas          : std_logic_vector(10 downto 0);
    signal valor_modulo         : std_logic_vector(10 downto 0);
    signal valor_display        : std_logic_vector(10 downto 0);
    signal bcd                  : std_logic_vector(15 downto 0);
    signal enable_valor         : std_logic;

    -- Status
    signal tem_troco, valor_suf : std_logic;

begin

    -- Conexão das Entradas Físicas (Tratando KEY como active-low)
    borda_subida_0 : entity work.borda_subida 
        port map (
            clk         =>      CLOCK_50,
            entrada     =>      not KEY(0),
            saida       =>      enter_s
        )

    borda_subida_1 : entity work.borda_subida 
        port map (
            clk         =>      CLOCK_50,
            entrada     =>      not KEY(1),
            saida       =>      cancel_s
        )

    -- Máquina de controle
    maquina_de_controle : entity work.fsm
        port map (
            enter              => enter_s,
            cancel             => cancel_s,
            enough_money       => valor_suf, -- Conectado ao módulo de estado
            timer_end          => timer_end_s,
            clk                => CLOCK_50,
            product_enable     => product_enable_s,
            product_led        => product_led_s,
            subtraction_enable => subtraction_enable_s,
            timer_on           => timer_on_s
        );

    -- Registrador de Produto Selecionado
    produto_reg : entity work.reg4
        port map (
            clk      => CLOCK_50,
            enable   => product_enable_s,
            D        => SW(3 downto 0),
            Q        => product
        );

    -- Registrador de Saldo (Valor Acumulado)

    valor_proximo <= valor_produto when (subtraction_enable_s = '0') else 
                    valor_sub;
    enable_valor <= '1' when (subtraction_enable_s = '1' and enter_s = '1') else
                          '1' when (subtraction_enable_s = '0') else
                          '0';
    valor_reg : entity work.reg11
        port map (
            clk      => CLOCK_50,
            enable   => enable_valor,
            D        => valor_proximo, 
            Q        => valor_atual
        );

    -- Decodificador de Preço (Baseado no produto selecionado)
    deco_one_hot : entity work.deco_onehot
        port map (
            prod     => product,
            price    => valor_produto
        );

    -- Somador/Subtrator de Dinheiro
    -- Aqui ele soma a nota selecionada ao valor atual
    sub : entity work.sub11
        port map (
            valor_atual   => valor_atual,
            valor_add     => valor_notas,
            valor_final   => valor_sub
        );

    -- Conversor de Chaves para Valor de Nota
    note_sel : entity work.Conv_Note
        port map (
            SW    => SW(9 downto 4),
            price => valor_notas
        );

    -- Temporizador
    temporizador : entity work.timer
        port map(
            timer_on  => timer_on_s,
            clk       => CLOCK_50,
            timer_end => timer_end_s
        );
    
    -- Módulo de Estado de Sinal (Compara Saldo vs Preço)
    status_sig : entity work.signal_state
        port map(
            saldo       => valor_atual,
            preco_prod  => valor_produto,
            valor_suf   => valor_suf, -- Vai para a FSM
            tem_troco   => tem_troco
        );

    -- Lógica de Display (Mux e Módulo)
    modulo_inst : entity work.mod11
        port map(
            valor  => valor_atual,
            modulo => valor_modulo
        );
    
    mux_disp : entity work.Mux2to1
        port map(
            A      => valor_atual,
            B      => valor_modulo,
            S      => tem_troco,
            X      => valor_display
        );

    -- Decodificação para os Displays HEX
    bin_to_bcd : entity work.bin11_to_bcd4 
        port map (
            bin => valor_display,
            bcd => bcd
        );

    -- Mapeamento dos Displays
    display0 : entity work.bin2hex port map (BIN => bcd(3 downto 0),   HEX => HEX0);
    display1 : entity work.bin2hex port map (BIN => bcd(7 downto 4),   HEX => HEX1);
    display2 : entity work.bin2hex port map (BIN => bcd(11 downto 8),  HEX => HEX2);
    display3 : entity work.bin2hex port map (BIN => bcd(15 downto 12), HEX => HEX3);
    display5 : entity work.bin2hex port map (BIN => product,           HEX => HEX5);

    -- LEDs de Saída
    LEDR(0) <= product_led_s; -- Produto Liberado
    LEDR(1) <= tem_troco;     -- Indica que há troco a ser devolvido

end Behavioral;