library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.numeric_std.ALL;
--use IEEE.std_logic_arith.ALL;

entity EX is Port (
    RD1 : in STD_LOGIC_VECTOR(31 downto 0);
    RD2 : in STD_LOGIC_VECTOR(31 downto 0);
    Ext_Imm : in STD_LOGIC_VECTOR(31 downto 0);
    func : in STD_LOGIC_VECTOR(5 downto 0);
    sa : in STD_LOGIC_VECTOR(4 downto 0);
    RegDst : in STD_LOGIC; -- new
    rt,rd: in STD_LOGIC_VECTOR(4 downto 0); -- new
    PCp4 : in STD_LOGIC_VECTOR(31 downto 0);
    ALUSrc : in STD_LOGIC;
    ALUOp : in STD_LOGIC_VECTOR(2 downto 0);
    Zero : out STD_LOGIC;
    BranchAddress : out STD_LOGIC_VECTOR(31 downto 0);
    ALURes : out STD_LOGIC_VECTOR(31 downto 0);
    rWA : out STD_LOGIC_VECTOR(4 downto 0)  -- new
);
end EX;

architecture Behavioral of EX is

    signal A, B, C : STD_LOGIC_VECTOR(31 downto 0);
    signal ALUCtrl : STD_LOGIC_VECTOR(2 downto 0);

begin

    -- ALU Control
    process(ALUOp, func)
    begin
        case ALUOp is
            when "010" => -- R type 
                case func is
                    when "101010" => ALUCtrl <= "111"; -- SLT
                    when "000000" => ALUCtrl <= "011"; -- SLL
                    when others => ALUCtrl <= (others => 'X'); -- unknown
                end case;
            when "000" => ALUCtrl <= "010"; -- +
            when "001" => ALUCtrl <= "001"; -- -
            when others => ALUCtrl <= (others => 'X'); -- unknown
        end case;
    end process;

    -- ALU
    A <= RD1;
    B <= Ext_Imm when ALUSrc = '1' else RD2; -- MUX for ALU input  
    process(ALUCtrl, A, B, sa)
    begin
        case ALUCtrl  is
            when "010" => -- ADD
                C <= A + B;
            when "001" =>  -- SUB
                C <= A - B;
            when "011" => -- SLL
                C <= to_stdlogicvector(to_bitvector(B) sll conv_integer(sa));
            when "111" => -- SLT
                if signed(A) < signed(B) then
                    C <= X"00000001";
                else
                    C <= X"00000000";
                end if;
            when others => -- unknown
                C <= (others => 'X');
        end case;
    end process;

    -- zero detector
    Zero <= '1' when C = 0 else '0';

    -- ALU result
    ALURes <= C;

    -- generate branch address
    BranchAddress <= PCp4 + (Ext_Imm(29 downto 0) & "00");

    -- write address new added mux
    rWA <= rt when RegDst = '0' else rd;

end Behavioral;