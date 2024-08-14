**Travesable Worm Hole Tools**

A few simple tools using the atPlatform and the Dart programing language.


Built binaries are available in the [latest release](https://github.com/cconstab/traversable-worm-hole-tools/releases/latest)

To start you will need at least two atSigns, these are available for free if you want random assigned words or can be purchased if you want particlar words at [my.atsign.com](my.atsign.com).

Once you have your atSigns you can activate them with `at_activate` using the command

 `./at_activate --atsign <@your atSign>`. 
 
 Substitute your atSign and it will email you a one time password and cut your cryptographic keys.You will need to do this twice so you have two atSigns to send data from and to.
 The master `.atKeys` files for each of you atSigns can be found in `~/.atsign/keys`, keep these safe as they are the only Master keys for your atSigns, there are no backups unless you make them!

 At this point you have two atSigns with keys and so you can test the twh_tools locally. The cool part is that you can run the twh_tools anywhere that can see the Internet and data will be sent and received using end to end encryption. 

 To get new atKeys on another machine DO NOT copy you keys create some new ones on the remote machine. This process is just like bluetooth pairing. First you create a One Time Password using your Master atKeys on your machine. Once you have done that on a remote machine you can ask for permission to cut new atKeys specifiying the OTP. Once that request comes into to you local machine you can approve it and the remote machine will cut new keys and they will be permitted to be used in a particular namespace, in our case `twh_tools`.
