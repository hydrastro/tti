# text to image
Text to image bash script with multiple highly customizable options for
obfuscation.  
Copies images directly to the clipboard.  
It could be used as captcha.  
Some examples:  
![sample image 1](https://github.com/hydrastro/tti/blob/main/normal.jpg?raw=true)
![sample image 2](https://github.com/hydrastro/tti/blob/main/obfuscated.jpg?raw=true)

## Dependencies
This scripts has the following dependencies:
- `imagemagick`
- `xclip`

Which can be easily installed with these commands:
- Ubuntu/Debian: `sudo apt install imagemagick xclip`
- Arch: `pacman -S imagemagick xclip`

## Configuration
There are some hardcoded configs you might want to change, check the script
source code if you're curious.

## Installation
The script installation is trivial: just clone this whole repository or copy the
script wherever you prefer.
```shell
cd /opt
git clone https://github.com/hydrastro/tti.git
```
For invoking the script more easily you can set up a bash alias for it:
```shell
alias tti='/opt/tti/tti.sh'
```
Or alternatively you can link it to `/usr/local/bin`
```shell
sudo ln -s /opt/tti/tti.sh /usr/local/bin/tti
```

## Usage
There are two ways you can run this script:
- By pipelining some text directly into the script:
  `cat something.txt | tti`
- By invoking the script directly and typing the text in it.
  End your data with a dot.
  ```shell
  [user@machine ~]$ tti
  your text
  some other text
  .
  ```
(Wanna type a dot? Ehhh... no)

## Contributing
Feel free to contribute, pull requests are always welcome.  
Please reveiw and clean your code with `shellcheck` before pushing it.  
