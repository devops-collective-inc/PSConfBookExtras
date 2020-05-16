set-location C:\Scripts
certutil -dspublish -f 'orca1_PKILab-RootCA.crt'
gpupdate /force

Start-Sleep 5
certlm.msc
