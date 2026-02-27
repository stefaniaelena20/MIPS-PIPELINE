library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_unsigned.ALL;

entity IFetch is
    Port (
        jump: in  STD_LOGIC;
        jAddr: in  STD_LOGIC_VECTOR(31 downto 0);
        PCSrc: in  STD_LOGIC;
        branchAddr: in  STD_LOGIC_VECTOR(31 downto 0);
        en: in  STD_LOGIC;
        rst: in  STD_LOGIC;
        clk: in  STD_LOGIC;
        instr: out STD_LOGIC_VECTOR(31 downto 0);
        PC: out STD_LOGIC_VECTOR(31 downto 0)
    );
end IFetch;

architecture Behavioral of IFetch is

    signal mux1, mux2, Q, sum : STD_LOGIC_VECTOR(31 downto 0);
    

    type memory is array (0 to 63) of std_logic_vector(31 downto 0);
    signal mem : memory := (
        X"20080004", -- 00: ADDI $8, $0, 4        Initializeaza $8 cu 4 (adresa lui N)
        X"00000020", -- NoOp
        X"00000020", -- NoOp
        X"8d090000", -- 01: LW   $9, 0($8)
        X"200a0000", -- 02: ADDI $10, $0, 0
        X"200b0000", -- 03: ADDI $11, $0, 0
        X"200c0008", -- 04: ADDI $12, $0, 8
        X"00000020", -- NoOp

        X"1569000A", -- 05: BEQ  $11, $9, END
        X"00000020", -- NoOp
        X"00000020", -- NoOp
        X"00000020", -- NoOp

        X"000b2820", -- 06: SLL  $13, $11, $2
        X"00000020", -- NoOp
        X"00000020", -- NoOp

        X"018d7020", -- 07: ADD  $14, $12, $13
        X"00000020", -- NoOp
        X"00000020", -- NoOp

        X"8dc80000", -- 08: LW   $8, 0($14)
        X"00000020", -- NoOp
        X"00000020", -- NoOp

        X"0008492a", -- 09: SLT  $9, $0, $8
        X"00000020", -- NoOp
        X"00000020", -- NoOp

        X"11200003", -- 0A: BEQ  $9, $0, SKIP
        X"00000020", -- NoOp
        X"00000020", -- NoOp
        X"00000020", -- NoOp

        X"31090001", -- 0B: ANDI $9, $8, 1
        X"00000020", -- NoOp
        X"00000020", -- NoOp

        X"11200001", -- 0C: BEQ  $9, $0, SKIP
        X"00000020", -- NoOp
        X"00000020", -- NoOp
        X"00000020", -- NoOp

        X"214a0001", -- 0D: ADDI $10, $10, 1
        X"216b0001", -- 0E: ADDI $11, $11, 1

        X"08000005", -- 0F: J 5
        X"00000020", -- NoOp

        X"ac0a0000", -- 10: SW $10, 0($0)
        others => X"00000000"
    );

begin

    process(clk, rst)
    begin
        if rst = '1' then
            Q <= (others => '0');
        elsif rising_edge(clk) then
            if en = '1' then
                Q <= mux1;
            end if;
        end if;
    end process;

    sum <=Q + 4;
    PC  <= sum;

    mux2 <= branchAddr when PCSrc = '1' else sum;
    mux1 <= jAddr when jump = '1' else mux2;

    
    instr <= mem(conv_integer(Q(6 downto 0)));

end Behavioral;