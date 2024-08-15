**Traversable Worm Hole Tools**

A few simple tools using the atPlatform and the Dart programing language.


Built binaries are available in the [latest release](https://github.com/cconstab/traversable-worm-hole-tools/releases/latest)

To start you will need at least two atSigns, these are available for free if you want random assigned words or can be purchased if you want particlar words at [my.atsign.com](my.atsign.com).

Once you have your atSigns you can activate them with `at_activate` using the command

 `./at_activate --atsign <@your atSign>`. 
 
 Substitute your atSign and it will email you a one time password and cut your cryptographic keys.You will need to do this twice so you have two atSigns to send data from and to.
 The master `.atKeys` files for each of you atSigns can be found in `~/.atsign/keys`, keep these safe as they are the only Master keys for your atSigns, there are no backups unless you make them!

 At this point you have two atSigns with keys and so you can test the twh_tools locally. As an example on my Windows machine sending `hello` from `@cconstab` to `@ssh_1` in name/topic of `test`.

```PS C:\Users\colin\Downloads\twh-windows-x64\twh> .\twh_put.exe -a "@cconstab" -n test -t 0 -m "hello" -o "@ssh_1"
Connecting ... Connected
sent: hello
PS C:\Users\colin\Downloads\twh-windows-x64\twh> .\twh_put.exe -a "@cconstab" -n test  -m "hello" -o "@ssh_1"
Connecting ... Connected
sent: hello
PS C:\Users\colin\Downloads\twh-windows-x64\twh> .\twh_get.exe -a "@ssh_1" -n test  -o "@cconstab"
Connecting ... Connected
hello
PS C:\Users\colin\Downloads\twh-windows-x64\twh> 
 ```
 
 The cool part is that you can run the twh_tools anywhere that can see the Internet and data will be sent and received using end to end encryption. 

 To get new atKeys on another machine DO NOT copy your keys, create some new ones on the remote machine. Just download these tools on the remote machine and follow along.
 
 This process is just like bluetooth pairing. First you create a One Time Password using your Master atKeys on your machine. Once you have done that on a remote machine you can ask for permission to cut new atKeys specifiying the OTP. Once that request comes into to you local machine you can approve it and the remote machine will cut new keys and they will be permitted to be used in a particular namespace, in our case `twh_tools`.

 **On the local machine** where you ran `at_activate` run `.\at_activate interactive -a "<Your atSign>"`. The atSign is the one you want to create a new set of Keys for on the remote machine. At this point you shoul get a `$` prompt, then type `otp`. This will return a One Time Password you can use on the remote machine.

 **On the remote machine** run
 
 `.\at_activate enroll -s <The OTP>  -p twh_tools   -d <Device_Name> -n "twh_tools:rw" -a @ssh_1 --keys ~/.atsign/keys/<Device_Name>`
This will request permission for generation and acceptatnce of atKeys, and will check every 10 seconds. 
You will need to approve the request back on the **local machine** in the interactive session you can list the requests with the `list` command which will show something like this:-
```
$ list
Found 4 matching enrollment records
Enrollment ID                         Status    AppName             DeviceName                            Namespaces
3e258bff-1253-431c-8e92-0047bfefd200  approved  sshnp               orac_ssh_3                            {sshnp: rw, sshrvd: rw}
672e0d46-2e86-443e-8b79-be9d0078fca9  approved  sshnp               orac_ssh_2                            {sshnp: rw, sshrvd: rw}
707a70e6-ff19-4a46-82c1-9c7cde186039  denied    sshnp               orac_ssh_1                            {sshnp: rw, sshrvd: rw}
d8bd3021-0700-4604-b9e5-dc1adea74778  pending   twh_tools           twh_orac                              {twh_tools: rw}
```
You can see the pending request which you can approve with the `approve -i  <Enrollment Id>` command. In my case that looked like this:-
```
$ approve -i d8bd3021-0700-4604-b9e5-dc1adea74778
Approving enrollmentId d8bd3021-0700-4604-b9e5-dc1adea74778
Server response: AtEnrollmentResponse{enrollmentId: d8bd3021-0700-4604-b9e5-dc1adea74778, enrollStatus: EnrollmentStatus.approved}
```
Back on the remote machine it cut the atKeys and tells me where they are:-
```
cconstab@orac:~/twh$ ./at_activate enroll -s 2Z1787  -p twh_tools   -d twh_orac -n "twh_tools:rw" -a @ssh_1 --keys ~/.atsign/keys/twh_orac
Submitting enrollment request
Enrollment ID: d8bd3021-0700-4604-b9e5-dc1adea74778
Waiting for approval; will check every 10 seconds
Checking ...  not approved. Will retry in 10 seconds
Checking ...  not approved. Will retry in 10 seconds
Checking ...  not approved. Will retry in 10 seconds
Checking ...  approved.
Creating atKeys file
[Success] Your .atKeys file saved at /home/cconstab/.atsign/keys/twh_orac/.atKeys

cconstab@orac:~/twh$
```
Those keys can now be used to collect data for the remote atSign for example:-

local machine sends (on Windows)
```
PS C:\Users\colin\Downloads\twh-windows-x64\twh> .\twh_put.exe -a "@cconstab" -n test  -m "hello world" -o "@ssh_1"
Connecting ... Connected
sent: hello world
PS C:\Users\colin\Downloads\twh-windows-x64\twh>
```

And the remote machine receieves (on Linux and anywhere with Internet access)
Note the use of the atKey file we just created.

```
cconstab@orac:~/twh$ ./twh_get -a @ssh_1 -o @cconstab -n test -k  /home/cconstab/.atsign/keys/twh_orac/.atKeys
Connecting ... Connected
hello world
cconstab@orac:~/twh$
```

Using the "Master" atKey on your local machine you can list and deny access if for example the remote machine is lost or compromised.
The `twh_pub` and `twh_sub` work in much the same manor.

On the local Windows box
```
PS C:\Users\colin\Downloads\twh-windows-x64\twh> .\twh_put.exe -a "@cconstab" -n test  -m "hello world" -o "@ssh_1"
Connecting ... Connected
sent: hello world
PS C:\Users\colin\Downloads\twh-windows-x64\twh> .\twh_put.exe -a "@cconstab" -n test  -m "Thanks for all the fish!" -o "@ssh_1"
Connecting ... Connected
sent: Thanks for all the fish!
PS C:\Users\colin\Downloads\twh-windows-x64\twh>
```

And on the remote machine receiving the published messages.
```
cconstab@orac:~/twh$ ./twh_sub -a @ssh_1 -o @cconstab -n test -k  /home/cconstab/.atsign/keys/twh_orac/.atKeys
Connecting ... Connected
hello world
Thanks for all the fish!
```

That's all for the moment but other small tools arriving soon.

BTW If you want to create atKeys for SSH No Ports the same process but the -n for the enrollment would be `-n "sshnp:rw,sshrvd:rw"` as they are the namespaces used for SSH No Ports tools like `sshnp` `sshnpd` and `npt`.