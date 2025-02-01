library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity UC is
    Port (
        Instr : in STD_LOGIC_VECTOR(31 downto 0);
        RegDst : out STD_LOGIC;
        ExtOp : out STD_LOGIC;
        ALUSrc : out STD_LOGIC;
        Branch : out STD_LOGIC;
        Jump : out STD_LOGIC;
        MemWrite : out STD_LOGIC;
        MemtoReg : out STD_LOGIC;
        RegWrite : out STD_LOGIC;
        ALUOp : out STD_LOGIC_VECTOR(1 downto 0)
    );
end UC;

architecture Behavioral of UC is
begin
    process(Instr)
    begin
        -- Initialize all control signals to 0
        RegDst <= '0';
        ExtOp <= '0';
        ALUSrc <= '0';
        Branch <= '0';
        Jump <= '0';
        MemWrite <= '0';
        MemtoReg <= '0';
        RegWrite <= '0';
        ALUOp <= "00";

        -- Decode the opcode and set the control signals accordingly
        case Instr(31 downto 26) is
            when "001000" => -- addi
                ALUSrc <= '1';
                RegWrite <= '1';
                ALUOp <= "00";
            when "001101" => -- ori
                ALUSrc <= '1';
                RegWrite <= '1';
                ALUOp <= "01";
            when "001010" => -- slti
                ALUSrc <= '1';
                RegWrite <= '1';
                ALUOp <= "00";
            when "000000" => -- R-type instructions
                RegDst <= '1';
                RegWrite <= '1';
                case Instr(5 downto 0) is
                    when "100000" => -- add
                        ALUOp <= "10";
                    when "100010" => -- sub
                        ALUOp <= "10";
                    when "100100" => -- and
                        ALUOp <= "10";
                    when "100101" => -- or
                        ALUOp <= "10";
                    when "100110" => -- xor
                        ALUOp <= "10";
                    when "101010" => -- slt
                        ALUOp <= "10";
                    when others => null;
                end case;
            when "101011" => -- sw
                ALUSrc <= '1';
                MemWrite <= '1';
            when "000010" => -- j
                Jump <= '1';
            when "000101" => -- bne
                Branch <= '1';
                ALUOp <= "01";
            when others => null;
        end case;
    end process;
end Behavioral;