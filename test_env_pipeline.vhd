-- Corrected and complete VHDL for test_env_pipeline
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity test_env_pipeline is
 Port (
    sw  : in  STD_LOGIC_VECTOR(15 downto 0);
    bt  : in  STD_LOGIC_VECTOR(1 downto 0);
    clk : in  STD_LOGIC;
    cat : out STD_LOGIC_VECTOR(6 downto 0);
    an  : out STD_LOGIC_VECTOR(7 downto 0);
    led : out STD_LOGIC_VECTOR(15 downto 0)
 );
end test_env_pipeline;

architecture Behavioral of test_env_pipeline is

signal instruction, pc4, jumpaddr, branchaddr, mux, wd : std_logic_vector(31 downto 0);
signal jump, and1, and2, or1, en : std_logic;
signal rd1, rd2, ext_imm : std_logic_vector(31 downto 0);
signal func : std_logic_vector(5 downto 0);
signal sa : std_logic_vector(4 downto 0);
signal regWrite, regDst, extOp : std_logic;
signal zero, aluSrc : std_logic;
signal aluOp : std_logic_vector(2 downto 0);
signal aluRes : std_logic_vector(31 downto 0);
signal memWrite : std_logic;
signal memData, aluResOut : std_logic_vector(31 downto 0);
signal memToReg, branch, nbranch : std_logic;
signal instruction_if_id, pc4_if_id : std_logic_vector(31 downto 0);
signal rd1_id_ex, rd2_id_ex, ext_imm_id_ex : std_logic_vector(31 downto 0);
signal func_id_ex : std_logic_vector(5 downto 0);
signal sa_id_ex : std_logic_vector(4 downto 0);
signal pc4_id_ex : std_logic_vector(31 downto 0);
signal regdst_id_ex, alusrc_id_ex, branch_id_ex, nbranch_id_ex : std_logic;
signal aluop_id_ex : std_logic_vector(2 downto 0);
signal memwrite_id_ex, memtoreg_id_ex, regwrite_id_ex : std_logic;
signal branch_ex_mem, nbranch_ex_mem, memwrite_ex_mem, memtoreg_ex_mem, regwrite_ex_mem : std_logic;
signal zero_ex_mem : std_logic;
signal branchaddress_ex_mem, alures_ex_mem : std_logic_vector(31 downto 0);
signal rd2_ex_mem : std_logic_vector(31 downto 0);
signal memtoreg_mem_wb, regwrite_mem_wb : std_logic;
signal alures_mem_wb, memdata_mem_wb : std_logic_vector(31 downto 0);

component MPG is
    Port ( enable : out STD_LOGIC;
           btn : in STD_LOGIC;
           clk : in STD_LOGIC);
end component;

component IFetch is
    Port ( jump : in STD_LOGIC;
           jAddr : in STD_LOGIC_VECTOR(31 downto 0);
           PCSrc : in STD_LOGIC;
           branchAddr : in STD_LOGIC_VECTOR(31 downto 0);
           en : in STD_LOGIC;
           rst : in STD_LOGIC;
           clk : in STD_LOGIC;
           instr : out STD_LOGIC_VECTOR(31 downto 0);
           PC : out STD_LOGIC_VECTOR(31 downto 0));
end component;

component SSD is
    Port ( digits : in STD_LOGIC_VECTOR (31 downto 0);
           clk : in STD_LOGIC;
           an : out STD_LOGIC_VECTOR (7 downto 0);
           cat : out STD_LOGIC_VECTOR (6 downto 0));
end component;

component ID is
    Port ( clk : in STD_LOGIC;
           en : in STD_LOGIC;
           Instr : in STD_LOGIC_VECTOR(25 downto 0);
           WD : in STD_LOGIC_VECTOR(31 downto 0);
           RegWrite : in STD_LOGIC;
           RegDst : in STD_LOGIC;
           ExtOp : in STD_LOGIC;
           RD1 : out STD_LOGIC_VECTOR(31 downto 0);
           RD2 : out STD_LOGIC_VECTOR(31 downto 0);
           Ext_Imm : out STD_LOGIC_VECTOR(31 downto 0);
           func : out STD_LOGIC_VECTOR(5 downto 0);
           sa : out STD_LOGIC_VECTOR(4 downto 0));
end component;

component UC is
    Port (
           instr : in STD_LOGIC_VECTOR (5 downto 0);
           regDst : out STD_LOGIC;
           extOp : out STD_LOGIC;
           aluSrc : out STD_LOGIC;
           branch : out STD_LOGIC;
           memWrite : out STD_LOGIC;
           memtoReg : out STD_LOGIC;
           regWrite : out STD_LOGIC;
           jump : out STD_LOGIC;
           aluOp : out STD_LOGIC_VECTOR (2 downto 0);
           Nbranch : out STD_LOGIC);
end component;

component MEM is
    Port ( MemWrite : in STD_LOGIC;
           aluResIn : in STD_LOGIC_VECTOR (31 downto 0);
           rd2 : in STD_LOGIC_VECTOR (31 downto 0);
           clk : in STD_LOGIC;
           en : in STD_LOGIC;
           memData : out STD_LOGIC_VECTOR (31 downto 0);
           aluResOut : out STD_LOGIC_VECTOR (31 downto 0));
end component;

component EX is
    Port ( PCp4 : in STD_LOGIC_VECTOR(31 downto 0);
           RD1 : in STD_LOGIC_VECTOR(31 downto 0);
           RD2 : in STD_LOGIC_VECTOR(31 downto 0);
           Ext_Imm : in STD_LOGIC_VECTOR(31 downto 0);
           func : in STD_LOGIC_VECTOR(5 downto 0);
           sa : in STD_LOGIC_VECTOR(4 downto 0);
           ALUSrc : in STD_LOGIC;
           ALUOp : in STD_LOGIC_VECTOR(2 downto 0);
           BranchAddress : out STD_LOGIC_VECTOR(31 downto 0);
           ALURes : out STD_LOGIC_VECTOR(31 downto 0);
           Zero : out STD_LOGIC);
end component;

begin

led(8 downto 0) <= regDst & extOp & aluSrc & nbranch & branch & jump & memWrite & memToReg & regWrite;

wd <= memData_mem_wb when memtoreg_mem_wb = '1' else aluRes_mem_wb;
and1 <= branch_ex_mem and zero_ex_mem;
and2 <= nbranch_ex_mem and (not zero_ex_mem);
or1  <= and1 or and2;
jumpaddr <= pc4_if_id(31 downto 28) & instruction_if_id(25 downto 0) & "00";

c1: MPG    port map(enable => en, btn => bt(0), clk => clk);
c2: IFetch port map(jump => jump, jAddr => jumpaddr, PCSrc => or1, branchAddr => branchaddress_ex_mem,
                    en => en, rst => bt(1), clk => clk, instr => instruction, PC => pc4);
c3: UC     port map(instr => instruction_if_id(31 downto 26), regDst => regDst, extOp => extOp, aluSrc => aluSrc,
                    branch => branch, memWrite => memWrite, memtoReg => memToReg, regWrite => regWrite,
                    jump => jump, aluOp => aluOp, Nbranch => nbranch);
c4: ID     port map(clk => clk, en => en, Instr => instruction_if_id(25 downto 0), WD => wd,
                    RegWrite => regwrite_mem_wb, RegDst => regDst, ExtOp => extOp,
                    RD1 => rd1, RD2 => rd2, Ext_Imm => ext_imm, func => func, sa => sa);
c5: EX     port map(PCp4 => pc4_id_ex, RD1 => rd1_id_ex, RD2 => rd2_id_ex, Ext_Imm => ext_imm_id_ex,
                    func => func_id_ex, sa => sa_id_ex, ALUSrc => alusrc_id_ex, ALUOp => aluop_id_ex,
                    BranchAddress => branchaddr, ALURes => aluRes, Zero => zero);
c6: MEM    port map(MemWrite => memwrite_ex_mem, aluResIn => aluRes_ex_mem, rd2 => rd2_ex_mem,
                    clk => clk, en => en, memData => memData, aluResOut => aluResOut);
c7: SSD    port map(digits => mux, clk => clk, an => an, cat => cat);


muxx: process(sw(7 downto 5))
begin
    case sw(7 downto 5) is
        when "000" => mux <= instruction_if_id;
        when "001" => mux <= pc4_if_id;
        when "010" => mux <= rd1_id_ex;
        when "011" => mux <= rd2_id_ex;
        when "100" => mux <= ext_imm_id_ex;
        when "101" => mux <= aluRes_ex_mem;
        when "110" => mux <= memData_mem_wb;
        when "111" => mux <= wd;
        when others => mux <= (others => '0');
    end case;
end process;

end Behavioral;
