# DDO Inventory Exporter

This repository contains [AutoHotKey] scripts that allow to export items from [DDO]

### Usage

First you need to download and install [AutoHotKey], then [download][master] this repository, extract it and run **ddoinv.ahk**

The default hotkeys are:
- **Ctrl + F1** - Dump item that you are currently viewing (tooltip must be visible and **Ctrl + Right Click** must be able to paste given item name to chat
- **Ctrl + F2** - change current character name

Changing character name allows to store items in separate folders since everything will be saved in "**%Script Directory%\\character name\\**"

If you will put "**\\**" in character name you can create sub folders. For example namig character as "**toon1\bank**" will create folder "**bank**" inside a folder named "**toon1**"

You can change the default hotkeys by editing script source code (lines **^F1::** and **^F2::**, use [AHK Hotkeys] as reference

### Licence

![Creative Commons License](https://i.creativecommons.org/l/by-nc-sa/4.0/88x31.png)
[Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License](http://creativecommons.org/licenses/by-nc-sa/4.0/)

[//]: #
[AutoHotKey]: http://www.autohotkey.com
[AHK Hotkeys]: https://www.autohotkey.com/docs/Hotkeys.htm
[DDO]: http://www.ddo.com
[master]: https://github.com/szkuwa/DDOahk/archive/master.zip
