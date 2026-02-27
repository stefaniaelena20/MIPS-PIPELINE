library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity UC is 
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
           Nbranch : out STD_LOGIC
         );
end UC;

architecture Behavioral of UC is

begin
process(instr)
begin
        regDst<='0' ;
        extOp<='0' ;
        aluSrc<='0';
        branch<='0' ;
        nbranch<='0';
        jump<='0' ;
        aluOp<="000" ;
        memWrite<='0' ;
        memtoReg<='0' ;
        regWrite<='0' ;

         case(instr) is 
         when"000000"=> --R type
         regDst<='1';
         regWrite<='1';
         aluOp<="010";
         
         when"001000"=> --ADDI
         extOp<='1';
         aluSrc<='1';
         regWrite<='1';
         aluOp<="000"; -- +
         
         when"100011"=> --LW
         aluSrc<='1';
         extOp<='1';
         memtoReg<='1';
         regWrite<='1';
         aluOp<="000"; -- +
         
         when"101011"=> --SW
         aluSrc<='1';
         extOp<='1';
         memWrite<='1';
         aluOp<="000"; -- +
         
         when"000100"=> --BEQ
         extOp<='1';
         branch<='1';
         aluOp<="001"; -- -
         
         when"001100"=> --ANDI
         aluSrc<='1';
         regWrite<='1';
         aluOp<="011"; -- &&
         
         when"001101"=> --ORI
         aluSrc<='1';
         regWrite<='1';
         aluOp<="101"; -- ||
         
         when"000101"=> --BNE
         extOp<='1';
         nbranch<='1';
         aluOp<="001"; -- -
         
          when"000010"=> --J
          jump<='1';
         
         when others =>
              regDst   <= '0';
              extOp    <= '0';
              aluSrc   <= '0';
              branch   <= '0';
              nbranch  <= '0';
              memWrite <= '0';
              memtoReg <= '0';
              regWrite <= '0';
              jump     <= '0';
              aluOp    <= "000";
         
         end case;
         end process;                         
end Behavioral;