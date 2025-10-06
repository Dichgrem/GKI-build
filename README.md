## GKI-build

- This repository is used to compile the GKI kernel.(crdroid system)
- Now support oneplus ace3 pro(corvette)

## How to use

1. Make sure you have installed the adb driver
2. Turn on Allow Debug in the Developer Options in the System Settings
3. Use a data cable to connect your phone and computer
4. Use ``adb devices`` to check if the connection is successful
5. Use ``adb reboot recovery`` to enter recovery mode, then enter ``enable adb`` in advanced
6. And then return to the homepage to enable ``apply update``
7. Use ``adb sideload <ak3 package path>``to flash it and then restart the system,enjoy it

## Features

- Use clang-r547379
- Enable ThinLTO/FullLTO to build
- Enable Root support : kernelsu/SukiSU/kernelsu-next
- Enable Susfs support : You can build susfs into kernel
- Enable BBR support : Enable bbr congestion control algorithm 
- Enable Anykernel3 support : Packaged as a zip package of anykernel3

To be continued...
 
