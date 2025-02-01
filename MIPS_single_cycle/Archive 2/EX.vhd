library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;


entity EX is
    Port (
        clk : in STD_LOGIC;
        ALUOp : in STD_LOGIC_VECTOR(1 downto 0);
        func : in STD_LOGIC_VECTOR(5 downto 0);
        sa : in STD_LOGIC_VECTOR(4 downto 0);
        RD1 : in STD_LOGIC_VECTOR(31 downto 0);
        RD2 : in STD_LOGIC_VECTOR(31 downto 0);
        Ext_Imm : in STD_LOGIC_VECTOR(31 downto 0);
        ALUSrc : in STD_LOGIC;
        ALURes : inout STD_LOGIC_VECTOR(31 downto 0);
        Zero : inout STD_LOGIC;
        BranchAddress : out STD_LOGIC_VECTOR(31 downto 0);
        pc : in STD_LOGIC_VECTOR(31 downto 0);
        GTZ : out STD_LOGIC;
        GEZ : out STD_LOGIC
    );
end EX;

architecture Behavioral of EX is
    signal ALUCtrl : STD_LOGIC_VECTOR(2 downto 0);
    signal Operand2 : STD_LOGIC_VECTOR(31 downto 0);

begin
    -- ALU Control
    ALUControl: process(ALUOp, func)
    begin
        case ALUOp is
            when "00" => -- R-type instructions
                case func is
                    when "100000" => -- add
                        ALUCtrl <= "010";
                    when "100010" => -- sub
                        ALUCtrl <= "110";
                    when "100100" => -- and
                        ALUCtrl <= "000";
                    when "100101" => -- or
                        ALUCtrl <= "001";
                    when "100110" => -- xor
                        ALUCtrl <= "011";
                    when "101010" => -- slt
                        ALUCtrl <= "111";
                    when others => null;
                end case;
            when "01" => -- beq or bne
                ALUCtrl <= "110";
            when "10" => -- lw or sw
                ALUCtrl <= "010";
            when others => null;
        end case;
    end process;

    -- Multiplexer for ALUSrc
    Operand2 <= RD2 when ALUSrc = '0' else Ext_Imm;

    -- ALU
    process(RD1, Operand2, ALUCtrl)
    begin
        case ALUCtrl is
            when "000" => ALURes <= RD1 and Operand2;
            when "001" => ALURes <= RD1 or Operand2;
            when "010" => ALURes <= to_stdlogicvector(to_bitvector(Operand2) sll conv_integer(sa));
            when "011" => ALURes <= to_stdlogicvector(to_bitvector(Operand2) sll conv_integer(sa));
            when "110" => ALURes <= to_stdlogicvector(to_bitvector(Operand2) sll conv_integer(sa));
            when "111" => -- slt
                if signed(RD1) < signed(Operand2) then
                    ALURes <= (others => '0');
                    ALURes(0) <= '1';
                else
                    ALURes <= (others => '0');
                end if;
            when "101" => -- beq
                if RD1 = Operand2 then
                    ALURes <= (others => '0');
                else
                    ALURes <= (others => '1');
                end if;
            when others => null;
        end case;
    end process;

    Flags: process (ALURes)
    begin
        if ALURes = X"00000000" then
            Zero <= '1';
        else
            Zero <= '0';
        end if;

        GEZ <= not ALURes(31);
        GTZ <= Zero and not ALURes(31);

    end process;

    -- Branch Address
    BranchAddress <= pc + (Ext_Imm(15 downto 0) & "00");
end Behavioral;