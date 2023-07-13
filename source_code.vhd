library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;

entity project_reti_logiche is
port (
             i_clk      : in std_logic;
             i_rst      : in std_logic;
             i_start    : in std_logic;
             i_w        : in std_logic;
             o_z0       : out std_logic_vector(7 downto 0);
             o_z1       : out std_logic_vector(7 downto 0);
             o_z2       : out std_logic_vector(7 downto 0);
             o_z3       : out std_logic_vector(7 downto 0);
             o_done     : out std_logic;
             o_mem_addr : out std_logic_vector(15 downto 0);
             i_mem_data : in std_logic_vector(7 downto 0);
             o_mem_we   : out std_logic;
             o_mem_en   : out std_logic
         );
end project_reti_logiche;

architecture Behavioral of project_reti_logiche is
    
    type state_type is (IDLE ,GET_CAN, GET_ADDR, ASK_MEM , WRITE_OUT, DONE ); --possible FSM state
    
    signal state_reg, state_next: state_type;  --assigned the state (and next state) signal
    signal o_done_next :    std_logic:= '0';  --next done signal
    signal o_mem_en_next :  std_logic:= '0';  --next o_mem_en signal
    signal o_mem_we_next :  std_logic:= '0';  --next o_mem_we signal
    signal o_mem_addr_next: std_logic_vector(15 downto 0):="0000000000000000"; --next o_mem_addr signal
    
    signal o_z0_next  :     std_logic_vector(7 downto 0):= "00000000"; --next o_z0 signal
    signal o_z1_next :      std_logic_vector(7 downto 0):= "00000000"; --next o_z1 signal
    signal o_z2_next  :     std_logic_vector(7 downto 0):= "00000000"; --next o_z2 signal
    signal o_z3_next :      std_logic_vector(7 downto 0):= "00000000"; --next o_z3 signal
  
    signal canal_reg: std_logic_vector(1 downto 0):="00";  --assigned get canal signal
    signal canal_next: std_logic_vector(1 downto 0):="00"; --and next get cannal signal

    signal z0_reg : std_logic_vector(7 downto 0):="00000000"; --store z0 signal
    signal z1_reg : std_logic_vector(7 downto 0):="00000000"; --store z1 signal
    signal z2_reg : std_logic_vector(7 downto 0):="00000000"; --store z2 signal 
    signal z3_reg : std_logic_vector(7 downto 0):="00000000"; --store z3 signal
    
    signal z0_next: std_logic_vector(7 downto 0):="00000000"; --next z0_reg signal
    signal z1_next: std_logic_vector(7 downto 0):="00000000"; --next z1_reg signal
    signal z2_next: std_logic_vector(7 downto 0):="00000000"; --next z2_reg signal
    signal z3_next: std_logic_vector(7 downto 0):="00000000"; --next z3_reg signal
   
    signal en_z0:       boolean:= false; --enable z0 signal
    signal en_z1:       boolean:= false; --enable z1 signal
    signal en_z2:       boolean:= false; --enable z2 signal
    signal en_z3:       boolean:= false; --enable z3 signal
    
    signal en_z0_next:  boolean:= false; --next en_z0 signal
    signal en_z1_next:  boolean:= false; --next en_z1 signal
    signal en_z2_next : boolean:= false; --next en_z2 signal
    signal en_z3_next:  boolean:= false; --next en_z3 signal
    
     signal addr_reg, addr_next:std_logic_vector(15 downto 0):="0000000000000000"; --address temporary for calculate

begin

    process(i_clk, i_rst)
    begin
    --if up reset signal then set all signal to default
         if(i_rst= '1') then
           state_reg <= IDLE;
           z0_reg <= "00000000";
           z1_reg <= "00000000";
           z2_reg <= "00000000";
           z3_reg <= "00000000";
           en_z0 <= false;
           en_z1 <= false;
           en_z2 <= false;
           en_z3 <= false;
           addr_reg <= "0000000000000000";
           canal_reg <= "00";
     --if clock down then update the all signal
         elsif(i_clk'event AND i_clk = '0') then           
           o_done <= o_done_next;
           o_mem_en <= o_mem_en_next;
           o_mem_we <= o_mem_we_next;
           o_mem_addr <= o_mem_addr_next;
           o_z0 <= o_z0_next;
           o_z1 <= o_z1_next;
           o_z2 <= o_z2_next;
           o_z3 <= o_z3_next;
           state_reg  <= state_next;
           addr_reg <= addr_next;
           canal_reg <= canal_next;
           z0_reg <= z0_next;
           z1_reg <= z1_next;
           z2_reg <= z2_next;
           z3_reg <= z3_next;
           en_z0 <= en_z0_next;
           en_z1 <= en_z1_next;
           en_z2 <= en_z2_next;
           en_z3 <= en_z3_next;
         end if;

    end process;

 process(i_start,i_mem_data, state_reg ,addr_reg, z0_reg, z1_reg, z2_reg, z3_reg, en_z0, en_z1, en_z2, en_z3, canal_reg)

   begin
        --initialize all signal
        o_done_next <= '0';
        o_mem_en_next <='0';
        o_mem_we_next <= '0';
        o_mem_addr_next <= "0000000000000000";
        o_z0_next <= "00000000";
        o_z1_next <= "00000000";
        o_z2_next <= "00000000";
        o_z3_next <= "00000000";
        state_next <= state_reg;
        z0_next <= z0_reg;
        z1_next <= z1_reg;
        z2_next <= z2_reg;
        z3_next <= z3_reg;
        en_z0_next <= en_z0;
        en_z1_next <= en_z1;
        en_z2_next <= en_z2;
        en_z3_next <= en_z3;
        addr_next <= addr_reg;
        canal_next <= canal_reg;

        --execute FSM
        case state_reg is
                               
            when IDLE =>   --begin to pick the first bit utility and go to the next state
                 if( i_start = '1') then
                    if( i_w = '1') then
                        canal_next <= "10";                                   
                    end if;                    
                 state_next <= GET_CAN;
                 end if;

             when GET_CAN =>    --pick the second (or last) bit, so we have 2 bit for canal
                   if( i_w = '1')then
                        canal_next <= canal_reg + "01";
                   end if;
                   state_next <= GET_ADDR;

             when GET_ADDR => --pick the address
                 if( i_start= '0') then --finished pick all bit, ready for enable the memory, so go to next state
                     o_mem_en_next <= '1';
                     o_mem_we_next <= '0';
                     o_mem_addr_next <= addr_reg;
                     state_next <= ASK_MEM;
                 else            --begin to pick next bit util for calculate the address
                    if( i_w='1') then --sll for 1 position and plus 1
                       addr_next <= std_logic_vector(unsigned(addr_reg) sll 1)+"0000000000000001";
                    else --sll for 1 position
                        addr_next <= std_logic_vector(unsigned(addr_reg) sll 1);
                    end if;
                 end if;

              when ASK_MEM =>     -- filter the canal and read the data
                    case canal_reg is
                         when "00" =>
                            z0_next <= i_mem_data; --pick data and store
                            en_z0_next <= true;  --enable signal to ready output
                         when "01" =>
                            z1_next <= i_mem_data; --pick data and store
                            en_z1_next <= true;   --enable signal to ready output
                         when "10" =>
                            z2_next <= i_mem_data; --pick data and store
                            en_z2_next <= true;  --enable signal to ready output
                         when others =>
                            z3_next <= i_mem_data; --pick data and store
                            en_z3_next <= true;  --enable signal to ready output
                     end case;
                        state_next <= WRITE_OUT;

               when WRITE_OUT =>   --print output all register the data picked recently witch have enable equals true 
                        if( en_z0 = true) then
                            o_z0_next <= z0_reg; --write out z0
                        end if;

                        if( en_z1= true) then
                            o_z1_next <= z1_reg; --write out z1
                        end if;

                        if( en_z2= true) then
                             o_z2_next <= z2_reg; --write out z2
                        end if;

                        if( en_z3= true) then
                             o_z3_next <= z3_reg; --write out z3
                        end if;

                        o_done_next <= '1'; --prepare for rising o_done 
                        state_next <= DONE;

                 when DONE =>   -- set all for default and return to IDLE state
                           canal_next <= "00";
                           addr_next <= "0000000000000000";
                           state_next <= IDLE;

        end case;
    end process;
end Behavioral;
