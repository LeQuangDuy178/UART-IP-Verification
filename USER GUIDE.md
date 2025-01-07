# UART IP Verification
 UART IP Verification using UVM - User Guide
 UVM 1.2 base class library directory is uvm_library/uvm-1.2/

 1. Run basic test simulation
 - In sim directory, type "source project_env.bash", this will link the uvm 1.2 base class library and create the environment variables for all of the associate directories in the working environment. These variables will be able to view all the files within the working environment and compile them in building process.
 - Type make build -> To perform compiling all the files set in rtl.f and tb.f file (combining in compile.f).
 - Type make run -> After compilation process passes, will run the default test name set in the TESTNAME variable in the Makefile.
 - Type make -> perform build and run continuously. 
 - Type make TESTNAME="test_name" when running desired test case (the file name in testcases directory). For example, type "make TESTNAME=uart_frame_WLS_noparity_1stop_transmit_only_test" will execute the code within this test file.
 - An optional instruction "VERBOSITY=UVM_NONE/LOW/MEDIUM/HIGH/FULL" will run tests will log message printing preference based on the set up verbosity in each `uvm_info statements. Simple type "make TESTNAME=uart_frame_WLS_noparity_1stop_transmit_only_test VERBOSITY=UVM_LOW" to run the test with UVM_LOW verbosity.
 - To view the log file (detailed messages file) -> Type "vi run.log".
 - To view the waveform of associate file -> Type "make wave"
 - To view the functional coverage -> Run the test "make COV=ON" with option COV is ON -> Then type "make cov_gui"

 2. Regression multi-tests running
 - In sim directory, type "./regress.pl" to execute Perl script running all tests in the regress.cfg file.
 - After regression complete, move to log directory by "cd log/"
 - To view desired test log file, type "vi test_name.log" (can use "ls -l" to show list of files).
 - To view waveform of desired test, type "make wave TESTNAME=test_name" where test_name is the desired test name file in log folder.
 - Go back to sim directory, to view entire functional coverage -> first type "make cov_merge" -> Then type "vsim -i -viewcov IP_MERGE.ucdb &" to run the functional coverage analysis.
