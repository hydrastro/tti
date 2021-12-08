# text to image
Text to image script written in bash.

## Dependencies
This scripts has the following dependencies:
- `imagemagick`
- `xclip`

Which can be easily installed with these commands:
- Ubuntu/Debian: `sudo apt install imagemagick xclip`
- Arch: `pacman -S imagemagick xclip`

## Configuration
There are some hardcoded configs you might want to change, for instance: the
images background color, the images fore color, the images font, etc.

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
There are two ways you can run this script

## Contributing
Feel free to contribute, pull requests are always welcome.  
Please reveiw and clean your code with `shellcheck` before pushing it.  
