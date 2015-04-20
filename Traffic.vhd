LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY Traffic IS
	PORT ( SW : IN STD_LOGIC_VECTOR(6 DOWNTO 0);
			 Clock_50 : IN STD_LOGIC;
			 LEDR : OUT STD_LOGIC_VECTOR(17 DOWNTO 6);
			 LEDG : OUT STD_LOGIC_VECTOR(5 DOWNTO 0));
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

	COMPONENT WALK
		PORT (Blink : IN STD_LOGIC;
					LSTATUS: IN STD_LOGIC_VECTOR(1 DOWNTO 0);
					WSTATUS : OUT STD_LOGIC);
	  END COMPONENT;

	COMPONENT MODCLOCK
		PORT ( Clock_50, Trigger : IN STD_LOGIC;
					Light : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
					C : BUFFER STD_LOGIC);
	END COMPONENT;


  SIGNAL R, G, Y, A, B, C, D : STD_LOGIC_VECTOR(1 DOWNTO 0);
	SIGNAL WA, WB, WC, WD : STD_LOGIC_VECTOR(1 DOWNTO 0);
  SIGNAL S : STD_LOGIC_VECTOR(2 DOWNTO 0);
  SIGNAL L, T, L1, L2 : STD_LOGIC;


BEGIN
 G <= "00";
 Y <= "01";
 R <= "10";

 T <= SW(5) OR SW(4);

 L0: Clockz PORT MAP (Clock_50, L1);
 L5: ModClock PORT MAP (Clock_50, T, A, L2);
 LEDG(5) <= L2; --test the clock outputs
 LEDG(4) <= L1;

 L <= (Not SW(6) And L1) OR (SW(6) And L2);

 S0: UpCounter PORT MAP(L, S); --Run through the Select options

 A0: CONTROL PORT MAP (S, R, G, G, Y, R, R, R, R, A); --Light 1's State
 B0: LIGHT PORT MAP (A, LEDR(17 DOWNTO 15)); --Control Light 1
 WA(0) <= (NOT SW(2)) OR (SW(2) AND A(0)); --set up the Walk signal connected to light 1
 WA(1) <= (NOT SW(2)) OR (SW(2) AND A(1)); --such that it displays Don't walk until the request is given, then it waits until it is safe to switch to walk
 W0: WALK PORT MAP (L, WA, LEDG(0)); --control the Walk Sign.

 C0: CONTROL PORT MAP (S, R, R, R, R, R, G, G, Y, B); --Set up for second Light and its Walk sign
 D0: LIGHT PORT MAP (B, LEDR(14 DOWNTO 12));
 WB(0) <= (NOT SW(1)) OR (SW(1) AND B(0));
 WB(1) <= (NOT SW(1)) OR (SW(1) AND B(1));
 W1: WALK PORT MAP (L, WB, LEDG(1));

 E0: CONTROL PORT MAP (S, R, G, G, Y, R, R, R, R, C); --Set up for third Light and its Walk sign
 F0: LIGHT PORT MAP (C, LEDR(11 DOWNTO 9));
 WC(0) <= (NOT SW(2)) OR (SW(2) AND C(0));
 WC(1) <= (NOT SW(2)) OR (SW(2) AND C(1));
 W2: WALK PORT MAP (L, WC, LEDG(2));

 G0: CONTROL PORT MAP (S, R, R, R, R, R, G, G, Y, D); --Set up for third Light and its Walk sign
 H0: LIGHT PORT MAP (D, LEDR(8 DOWNTO 6));
 WD(0) <= (NOT SW(1)) OR (SW(1) AND D(0));
 WD(1) <= (NOT SW(1)) OR (SW(1) AND D(1));
 W3: WALK PORT MAP (L, WD, LEDG(3));

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

ENTITY WALK IS
  PORT (Blink : IN STD_LOGIC;
				LSTATUS: IN STD_LOGIC_VECTOR(1 DOWNTO 0);
        WSTATUS : OUT STD_LOGIC);
END WALK;

ARCHITECTURE Behavior OF WALK IS
BEGIN
		WITH LSTATUS SELECT
			WSTATUS <= '1' WHEN "00",
							   Blink WHEN "01",
							   '0' WHEN OTHERS;

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

			if (Count = 25000000) Then --dropped a zero for testing

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

LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY ModClock IS

	PORT ( Clock_50, Trigger : IN STD_LOGIC;
				 Light : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
				 C : BUFFER STD_LOGIC);

END ModClock;


ARCHITECTURE Behavior OF ModClock IS --clock behavior

	Signal Count : INTEGER RANGE 0 to 250000000; --clock frequency

BEGIN
	PROCESS
		BEGIN
			wait until Clock_50='1';

				Count<=Count+1;

			if (Count = 25000000) Then --droped a zero for testing

				Count<=0;
				if (Not (Light = "00")) Then
					C<= NOT C;
				elsif (Trigger = '1') Then
					C <= Not C;
				else
					C <= C;
				end if;
			end if;
			END PROCESS;
END Behavior;
