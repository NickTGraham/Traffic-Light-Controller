LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY Traffic IS
	PORT ( SW : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
			 Clock_50 : IN STD_LOGIC;
			 LEDR : OUT STD_LOGIC_VECTOR(17 DOWNTO 6));
END Traffic;

ARCHITECTURE Behavior OF Traffic IS
  COMPONENT CONTROL
    PORT( S:IN STD_LOGIC_VECTOR(2 DOWNTO 0);
	       a, b, c, d, e, f, g, h :IN STD_LOGIC_VECTOR(1 DOWNTO 0);
          M                :OUT STD_LOGIC_VECTOR(1 DOWNTO 0));
  END COMPONENT;

  COMPONENT LIGHT
    PORT(C                :IN STD_LOGIC_VECTOR(1 DOWNTO 0);
         COLOR          :OUT STD_LOGIC_VECTOR(2 DOWNTO 0));
  END COMPONENT;
  
  COMPONENT UpCounter
	PORT( myClock : IN STD_LOGIC;
		  O : OUT STD_LOGIC_VECTOR(2 DOWNTO 0));
   END COMPONENT;
	
	COMPONENT Clockz
		PORT ( Clock_50 : IN STD_LOGIC;
				C : BUFFER STD_LOGIC);
	 END COMPONENT;
		

  SIGNAL R, G, Y, A, B : STD_LOGIC_VECTOR(1 DOWNTO 0);
  SIGNAL S : STD_LOGIC_VECTOR(2 DOWNTO 0);
  SIGNAL L : STD_LOGIC;


BEGIN
 G <= "00";
 Y <= "01";
 R <= "10";
 L0: Clockz PORT MAP (Clock_50, L);

 S0: UpCounter PORT MAP(L, S);

 A0: CONTROL PORT MAP (S, R, G, G, Y, R, R, R, R, A);
 B0 : LIGHT PORT MAP (A, LEDR(17 DOWNTO 15));

 C0: CONTROL PORT MAP (S, R, R, R, R, R, G, G, Y, B);
 D0 : LIGHT PORT MAP (B, LEDR(14 DOWNTO 12));
 
END Behavior;

LIBRARY ieee;
USE ieee.std_logic_1164.all;
-- implements a 2-bit wide 8-to-1 multiplexer

ENTITY CONTROL IS
  PORT ( S : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
			a, b, c, d, e, f, g, h : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
         M : OUT STD_LOGIC_VECTOR(1 DOWNTO 0));
END CONTROL;

ARCHITECTURE Behavior OF CONTROL IS
 signal OUTPUT1 : STD_LOGIC_VECTOR(1 DOWNTO 0);
 signal OUTPUT2 : STD_LOGIC_VECTOR(1 DOWNTO 0);
 signal OUTPUT3 : STD_LOGIC_VECTOR(1 DOWNTO 0);
 signal OUTPUT4 : STD_LOGIC_VECTOR(1 DOWNTO 0);
 signal OUTPUT5 : STD_LOGIC_VECTOR(1 DOWNTO 0);
 signal OUTPUT6 : STD_LOGIC_VECTOR(1 DOWNTO 0);
BEGIN
			--LEDR <= SW;
			--bit 0
			OUTPUT1(0) <= ((NOT S(0) And a(0)) OR (S(0) And b(0))); 
			OUTPUT2(0) <= ((NOT S(0) And c(0)) OR (S(0) And d(0)));
			OUTPUT3(0) <= ((NOT S(0) And e(0)) OR (S(0) And f(0)));
			OUTPUT4(0) <= ((NOT S(0) And g(0)) OR (S(0) And h(0)));
			
			OUTPUT5(0) <= ((NOT S(1) And OUTPUT1(0)) OR (S(1) And OUTPUT2(0)));
			OUTPUT6(0) <= ((NOT S(1) And OUTPUT3(0)) OR (S(1) And OUTPUT4(0)));
			
			M(0) <=  ((NOT S(2) And OUTPUT5(0)) OR (S(2) And OUTPUT6(0))); 
			
			--bit 1
			OUTPUT1(1) <= ((NOT S(0) And a(1)) OR (S(0) And b(1))); 
			OUTPUT2(1) <= ((NOT S(0) And c(1)) OR (S(0) And d(1)));
			OUTPUT3(1) <= ((NOT S(0) And e(1)) OR (S(0) And f(1)));
			OUTPUT4(1) <= ((NOT S(0) And g(1)) OR (S(0) And h(1)));
			
			OUTPUT5(1) <= ((NOT S(1) And OUTPUT1(1)) OR (S(1) And OUTPUT2(1)));
			OUTPUT6(1) <= ((NOT S(1) And OUTPUT3(1)) OR (S(1) And OUTPUT4(1)));
			
			M(1) <=  ((NOT S(2) And OUTPUT5(1)) OR (S(2) And OUTPUT6(1))); 
			
			
END Behavior;

LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY LIGHT IS
  PORT (C: IN STD_LOGIC_VECTOR(1 DOWNTO 0);
        COLOR : OUT STD_LOGIC_VECTOR(2 DOWNTO 0));
END LIGHT;

ARCHITECTURE Behavior OF LIGHT IS 
BEGIN
		COLOR(0) <= NOT(C(1)) AND NOT(C(0)); --green light
		COLOR(1) <= NOT(C(1)) AND C(0); --yellow light
		COLOR(2) <= C(1); --red light
		
END Behavior;


LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY Clockz IS

	PORT ( Clock_50 : IN STD_LOGIC;

				 C : BUFFER STD_LOGIC);

END Clockz;


ARCHITECTURE Behavior OF Clockz IS --clock behavior

	Signal Count : INTEGER RANGE 0 to 250000000; --clock frequency

BEGIN
	PROCESS
		BEGIN
			wait until Clock_50='1';

				Count<=Count+1;

			if (Count = 250000000) Then

				Count<=0;

				C <= Not C;

			end if;
			END PROCESS;
END Behavior;


LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY myflipflop IS --flip flop behavior

	PORT ( D, Clock : IN STD_LOGIC ;

				 Q :BUFFER STD_LOGIC );

END myflipflop;



ARCHITECTURE Behavior OF myflipflop IS --wait until clock event and then push D to Q

BEGIN

			Process

			Begin

				Wait until Clock'Event And Clock='1' AND D='1';

				Q <= NOT(Q);

			End Process;

END Behavior;


LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY UpCounter IS

	PORT(myClock : IN STD_LOGIC;
		  O : OUT STD_LOGIC_VECTOR(2 DOWNTO 0));
END UpCounter;

ARCHITECTURE Behavior OF UpCounter IS

 COMPONENT myflipflop
    PORT(D, Clock   :IN STD_LOGIC;
         Q          :OUT STD_LOGIC);
  END COMPONENT;
  
  SIGNAL X, Y, Z, V, W : STD_LOGIC;
  
  BEGIN
  W <= myClock;
  
  X0 : myflipflop PORT MAP ('1', W, X);
  O(0) <= X; --LSB (Bit 0)
  
  Y0 : myflipflop PORT MAP (X, W, Y);
  O(1) <= Y; --Bit 1
  
  V <= X AND Y;
  
  Z0 : myflipflop PORT MAP (V, W, Z);
  O(2) <= Z; --MSB (Bit 2)
  
  END Behavior;


