# make-windows-iso.nu
let iso_name = 'windows11.iso'
def main [iso_name:string="windows11.iso",device:string] {
  wget "https://software.download.prss.microsoft.com/dbazure/Win11_23H2_English_x64v2.iso" -O $iso_name
  dd if=$iso_name of=$device
}
