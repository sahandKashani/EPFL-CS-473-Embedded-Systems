You can then format & write your sdcard by doing the following:

$ unzip lab_4_project_template_sdcard.zip
$ cd lab_4_project_template_sdcard/
$ ./write_sdcard.sh /dev/sdX

Remember to replace the "X" in /dev/sdX with the name of your sdcard as seen by
your computer when you plug it in. Please be CAREFUL and choose the correct
device here, or else you may accidentally format the wrong partition on your
computer, and you will lose data!

Once the sdcard is successfully written, do the following steps:

1) Plug a UART cable to the board's "UART" port.

2) Install "minicom" on your computer with
    $ sudo apt install minicom

3) Launch a serial console on your computer.
    $ sudo minicom --device /dev/ttyUSB0

4) Configure minicom as shown in the attached picture.

5) Set the MSEL switch on the board to "000000".

6) Power on the board, and you will see a lot of text appear on the serial
   console as the board boots from the contents of the sdcard. Within 2 seconds of
   power up, you will see the following text:

    "Hit any key to stop autoboot:"

7) Push any button to stop the boot process, then type the following 2 commands
   on the shell that appears:

    $ env default -a
    $ saveenv

8) You can now unplug and replug the power on the board, and it should be ready
   for you to use. You can close minicom and can unplug the UART cable as you
   will no longer be needing it.

9) If everything was successful, you should see an alternating pattern on the
   development board's LEDs around 8 seconds after power up. The memory
   controller is also correctly initialized, so you can test your project now.

Let me know if something doesn't work.

Best,
Sahand
