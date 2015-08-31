library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

--+ including vhdl 2008 libraries
--+ These lines can be commented out when using
--+ a simulator with built-in VHDL 2008 support
--library ieee_proposed;
--  use ieee_proposed.standard_additions.all;
--  use ieee_proposed.std_logic_1164_additions.all;
--  use ieee_proposed.numeric_std_additions.all;

library osvvm;
  use osvvm.RandomPkg.all;

library libvhdl;
  use libvhdl.DictP.all;



entity DictT is
end entity DictT;



architecture sim of DictT is


  type t_scoreboard is array (natural range <>) of std_logic_vector(7 downto 0);

  shared variable sv_dict : t_dict;


begin


  DictInitP : process is
  begin
    sv_dict.init(false);
    wait;
  end process DictInitP;


  DictTestP : process is
    variable v_key    : t_dict_key_ptr;
    variable v_random : RandomPType;
    variable v_input  : std_logic_vector(7 downto 0);
    variable v_output : std_logic_vector(7 downto 0);
    variable v_scoreboard : t_scoreboard(0 to 256);
    variable v_error      : t_dict_error;
  begin
    v_random.InitSeed(v_random'instance_name);

    -- check initial emptiness
    assert sv_dict.size = 0
      report "ERROR: Dict should be empty"
      severity failure;

    -- The dict shouldn_t accept an empty key string
    report "INFO: Test 0: Try to set an entry with empty key string";
    sv_dict.set("", x"0123456789", v_error);
    assert v_error = KEY_INVALID
      report "ERROR: Key '' should raise a KEY_INVALID error"
      severity failure;
    report "INFO: Test successful";

    -- fill dictionary and check count
    report "INFO: Test 1: Fill dictionary";
    for i in 0 to 255 loop
      v_input := v_random.RandSlv(8);
      sv_dict.set(integer'image(i), v_input, v_error);
      v_scoreboard(i) := v_input;
      assert sv_dict.size = i+1
        report "ERROR: Dict should have " & to_string(i+1) & " entries"
        severity failure;
    end loop;
    report "INFO: Test successful";

    -- read all entries and check for correct data
    report "INFO: Test 2: Read dictionary";
    for i in 0 to 255 loop
      sv_dict.get(integer'image(i), v_output, v_error);
      assert v_output = v_scoreboard(i)
        report "ERROR: Got 0x" & to_hstring(v_output) & ", expected 0x" & to_hstring(v_scoreboard(i))
        severity failure;
    end loop;
    report "INFO: Test successful";

    -- overwrite a key/value pair
    report "INFO: Test 3: Overwrite a entry";
    v_input := v_random.RandSlv(8);
    sv_dict.set("128", v_input, v_error);
    v_scoreboard(128) := v_input;
    sv_dict.get("128", v_output, v_error);
    assert v_output = v_scoreboard(128)
      report "ERROR: Got 0x" & to_hstring(v_output) & ", expected 0x" & to_hstring(v_scoreboard(128))
      severity failure;
    report "INFO: Test successful";

    -- check for existing keys
    report "INFO: Test 4: Check hasKey() method";
    for i in 0 to 255 loop
      assert sv_dict.hasKey(integer'image(i))
        report "ERROR: Key" & integer'image(i) & " should exist in dictionary"
        severity failure;
    end loop;
    assert not(sv_dict.hasKey("AFFE"))
      report "ERROR: Key AFFE shouldn't exist in dictionary"
      severity failure;
    report "INFO: Test successful";

    -- iterate up over all entries
    report "INFO: Test 5: Iterate up over all entries";
    sv_dict.setFirst;
    for i in 0 to 255 loop
      v_key := new string'(sv_dict.iter(UP));
      assert v_key.all = integer'image(i)
        report "ERROR: Got key " & v_key.all & ", expected " & integer'image(i)
        severity failure;
      sv_dict.get(v_key.all, v_output, v_error);
      assert v_key.all = integer'image(i) and v_output = v_scoreboard(i)
        report "ERROR: Got 0x" & to_hstring(v_output) & ", expected 0x" & to_hstring(v_scoreboard(i))
        severity failure;
    end loop;
    v_key := new string'(sv_dict.iter(UP));
    assert v_key.all = ""
      report "ERROR: Got key " & v_key.all & ", expected empty key"
      severity failure;
    report "INFO: Test successful";

    -- iterate down over all entries
    report "INFO: Test 6: Iterate down over all entries";
    sv_dict.setLast;
    for i in 255 downto 0 loop
      v_key := new string'(sv_dict.iter(DOWN));
      assert v_key.all = integer'image(i)
        report "ERROR: Got key " & v_key.all & ", expected " & integer'image(i)
        severity failure;
      sv_dict.get(v_key.all, v_output, v_error);
      assert v_key.all = integer'image(i) and v_output = v_scoreboard(i)
        report "ERROR: Got 0x" & to_hstring(v_output) & ", expected 0x" & to_hstring(v_scoreboard(i))
        severity failure;
    end loop;
    v_key := new string'(sv_dict.iter(DOWN));
    assert v_key.all = ""
      report "ERROR: Got key " & v_key.all & ", expected empty key"
      severity failure;
    deallocate(v_key);
    report "INFO: Test successful";

    -- Remove key/value pair from head of dictionary
    report "INFO: Test 7: Removing entry from head of dictionary";
    sv_dict.del("255", v_error);
    assert not(sv_dict.hasKey("255"))
      report "ERROR: Key 255 shouldn't exist in dictionary"
      severity failure;
    report "INFO: Test successful";

    -- Remove key/value pair from head of dictionary
    report "INFO: Test 8: Removing entry from middle of dictionary";
    sv_dict.del("127", v_error);
    assert not(sv_dict.hasKey("127"))
      report "ERROR: Key 127 shouldn't exist in dictionary"
      severity failure;
    report "INFO: Test successful";

    -- Remove key/value pair from head of dictionary
    report "INFO: Test 9: Removing entry from beginning of dictionary";
    sv_dict.del("0", v_error);
    assert not(sv_dict.hasKey("0"))
      report "ERROR: Key 0 shouldn't exist in dictionary"
      severity failure;
    report "INFO: Test successful";

    -- Remove key/value pair from head of dictionary
    report "INFO: Test 10: Clear all entries from dictionary";
    sv_dict.clear(v_error);
    assert sv_dict.size = 0
      report "ERROR: Dict should be empty"
      severity failure;
    report "INFO: Test successful";

    report "INFO: t_dict test finished successfully";
    wait;
  end process DictTestP;


end architecture sim;
