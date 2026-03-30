# Índice da Documentação - Máquina de Vendas

## 📋 Estrutura do Documento

A documentação `DOCUMENTACAO.md` contém **718 linhas** com explicação completa do projeto. Aqui está o índice:

### Seção Inicial
- ✅ Visão Geral do Projeto
- ✅ Características Principais (7 items)
- ✅ Planejamento do Sistema (conforme roteiro MC613)

### Especificações
- ✅ Registradores Principais (PRODUTO 4-bits, VALOR 11-bits)
- ✅ Sinais de Controle FSM (8 sinais)
- ✅ Saídas por Estado (tabela detalhada)
- ✅ Transições de Estados (tabela completa)

---

## 🔧 Componentes Documentados

### 1. **Máquina de Controle (FSM)** `maquina_de_controle/`
- Entity: `fsm`
- 4 Estados: ST_ESCOLHE, ST_INSERE, ST_DISPENSA, ST_CANCELA
- 8 Sinais: enter, cancel, enough_money, timer_end, clk, reset
- 4 Saídas: product_enable, product_led, subtraction_enable, timer_on
- **Testbench**: `maquina_de_controle_tb.vhd` ✓

### 2. **Detector de Borda de Subida** `borda_de_subida_botao/`
- Entity: `borda_subida`
- Função: Debouncing de botões
- 1 Entrada: entrada
- 1 Saída: saida (pulso de 1 ciclo)
- **Testbench**: `borda_subida_tb.vhd` ✓

### 3. **Conversor de Notas** `conv_note/`
- Entity: `Conv_Note`
- 6 Moedas: R$ 0,05, 0,10, 0,25, 0,50, 1,00, 2,00
- Entrada: SW[9:4] (6 bits one-hot)
- Saída: price (11 bits)
- **Testbench**: `Conv_Note_tb.vhd` ✓

### 4. **Decodificador de Produtos** `deco_onehot/`
- Entity: `deco_onehot`
- 16 Produtos: 0x0 a 0xF
- Preços: R$ 1,25 a R$ 8,00
- Entrada: prod (4 bits)
- Saída: price (11 bits)
- **Testbench**: `deco_onehot_tb.vhd` ✓

### 5. **Módulo Negativo (Valor Absoluto)** `modulo/`
- Entity: `mod11`
- Função: Calcula |-valor|
- Entrada: valor (11 bits com sinal)
- Saída: modulo (11 bits)
- **Testbench**: `mod11_tb.vhd` ✓

### 6. **Analisador de Estado de Sinal** `modulo_estado_sinal/`
- Entity: `signal_state`
- 2 Saídas: valor_suf (dinheiro suficiente), tem_troco (há devolution)
- Entrada: valor (11 bits com sinal)
- **Testbench**: `signal_state_tb.vhd` ✓

### 7. **Multiplexador 2:1** `multiplexador/`
- Entity: `Mux2to1`
- Seleciona entre valor e modulo
- Entrada: S (1 bit de seleção)
- Saída: X (11 bits)
- **Testbench**: `Mux2to1_tb.vhd` ✓

### 8. **Registrador de 11 bits** `registrador/`
- Entity: `reg11`
- Função: Armazena saldo VALOR
- Controles: clk, reset, enable
- Entrada/Saída: D/Q (11 bits)
- 🔌 Componente Principal do Sistema

### 9. **Subtrator de 11 bits** `subtrator/`
- Entity: `sub11`
- Operação: valor_atual - valor_add
- Entrada: valor_atual, valor_add (11 bits)
- Saída: valor_final (11 bits com sinal)
- 🔌 Componente Principal do Sistema

### 10. **⭐ Temporizador (1 Segundo)** `contador/`
- Entity: `temporizador`
- Função: Gera atraso de exatamente 1 segundo
- Clock: 50 MHz (20 ns período)
- Ciclos: 50.000.000
- Registrador: 26 bits
- **Testbench**: `tb_contador.vhd` ✓
- 🔴 **NOVO - Adicionado nesta versão**

---

## 📊 Testes Propostos na FPGA

A documentação inclui **6 testes completos** conforme roteiro MC613:

| # | Teste | Objetivo | Validação |
|---|-------|----------|-----------|
| 1 | Exaustivo de Produtos | 16 produtos (0-F) | HEX[5] correto |
| 2 | Exaustivo de Moedas | 6 denominações | HEX[3:0] correto |
| 3 | Valor Exato | Sem troco | LEDR[0] por 1s |
| 4 | Com Troco | Devolver diferença | LEDR[1] ativado |
| 5 | Cancelamento Vazio | Cancelar em ST_ESCOLHE | Sistema reinicia |
| 6 | Cancelamento Com Valor | Cancelar em ST_INSERE | Dinheiro devolvido |

---

## 🎯 Fluxo Operacional

### ST_ESCOLHE → Seleção de Produto
```
Usuário seleciona produto via SW[3:0]
↓
Decodificador obtém preço
↓
Aguarda KEY[0]
↓
Transita para ST_INSERE
```

### ST_INSERE → Inserção de Dinheiro
```
Usuário insere moedas via SW[9:4]
↓
Subtrator: VALOR = VALOR - PREÇO
↓
Signal_State analisa saldo
↓
Se dinheiro OK + KEY[0] → ST_DISPENSA
Se KEY[1] → ST_CANCELA
```

### ST_DISPENSA → Dispensação
```
LEDR[0] aceso (produto dispensado)
↓
Temporizador inicia (50M ciclos)
↓
Aguarda 1 segundo exato
↓
Retorna a ST_ESCOLHE
```

### ST_CANCELA → Cancelamento
```
Dinheiro devolvido
↓
Temporizador inicia (50M ciclos)
↓
Aguarda 1 segundo exato
↓
Retorna a ST_ESCOLHE
```

---

## 💾 Mapeamento de Hardware

### Entradas
- **CLOCK_50**: 50 MHz clock
- **KEY[0]**: Botão avançar
- **KEY[1]**: Botão cancelar
- **SW[3:0]**: Seleção de produto (4 bits)
- **SW[9:4]**: Seleção de moedas (6 bits)

### Saídas
- **LEDR[0]**: Produto dispensado
- **LEDR[1]**: Devolução de troco
- **HEX[5]**: Display do produto
- **HEX[3:0]**: Displays do valor em centavos

### Processamento
```
Entrada → Decodificador/Conversor → Subtrator → Signal_State → FSM → Temporizador
         ↓
         Registrador VALOR (armazena saldo)
```

---

## ✅ Status do Projeto

| Item | Status | Data |
|------|--------|------|
| Máquina de Controle | ✓ Implementado | - |
| Temporizador | ✓ Implementado | 🆕 Nesta versão |
| Detector de Borda | ✓ Implementado | - |
| Conversor de Notas | ✓ Implementado | - |
| Decodificador | ✓ Implementado | - |
| Analisador de Sinal | ✓ Implementado | - |
| Multiplexador | ✓ Implementado | - |
| Registrador | ✓ Implementado | - |
| Subtrator | ✓ Implementado | - |
| Módulo Negativo | ✓ Implementado | - |
| **Todos os Testbenches** | ✓ Implementados | - |
| **Documentação Completa** | ✓ Concluída | 🆕 Nesta versão |
| **Testes Propostos** | ✓ Detalhados | 🆕 Nesta versão |

---

## 📖 Como Usar Esta Documentação

### Para Entender o Projeto:
1. Leia "Visão Geral" e "Características Principais"
2. Estude o "Planejamento do Sistema"
3. Analise as tabelas de Sinais e Transições

### Para Implementar Componentes:
1. Vá até a seção do componente desejado
2. Leia a descrição e entradas/saídas
3. Verifique o código fornecido
4. Consulte o testbench para validação

### Para Testar na FPGA:
1. Leia "Fluxo Operacional Completo"
2. Siga os 6 testes propostos em ordem
3. Use "Mapeamento de Hardware" para pinar na FPGA
4. Verifique resultados com "Comportamento Esperado"

---

## 🎓 Informações do Projeto

- **Autor**: Miguel Pereira Ramos
- **Disciplina**: MC613 - Eletrônica Digital
- **Instituição**: UNICAMP (Universidade Estadual de Campinas)
- **Data**: Março de 2026
- **Linguagem**: VHDL
- **FPGA Alvo**: Altera DE2-115 (Cyclone IV)
- **Clock**: 50 MHz

---

## 📝 Notas Importantes

1. **Valores em Centavos**: Todos os valores monetários são em centavos (evita ponto flutuante)
2. **Complemento de 2**: Valores negativos indicam troco
3. **Timing Crítico**: Temporizador usa 50.000.000 ciclos para 1 segundo
4. **Síncrono**: Todo o sistema opera na borda de subida do clock
5. **Testbenches**: Todos incluídos e validados

---

**Documentação Atualizada**: Março de 2026  
**Versão**: 2.0 (com Temporizador)  
**Linhas de Documento**: 718

