<h1><a href="https://atsign.com#gh-light-mode-only"><img width=250px
src="https://atsign.com/wp-content/uploads/2022/05/atsign-logo-horizontal-color2022.svg#gh-light-mode-only"
alt="The Atsign Foundation"></a>
<a href="https://atsign.com#gh-dark-mode-only"><img width=250px
src="https://atsign.com/wp-content/uploads/2023/08/atsign-logo-horizontal-reverse2022-Color.svg#gh-dark-mode-only"
alt="The Atsign Foundation"></a></h1>

# Digital traversable wormhole tools

Simple tools that use Atsign's atSDK that feel like a digital traversable wormhole between machines

## Who is this for?

Anyone wanting some simple,private and secure ways to get data from one machine to another


### Contributor

This code is useful as a starting point for other tools or just to be used in thier own right.
[CONTRIBUTING.md](CONTRIBUTING.md) is going to have the detailed guidance
on how to setup their tools, tests and how to make a pull request.

## Why, What, How?

### Why?

In DevSecOps we often need tools to get files like certificates or keys from one place to another. This is often troublesome as you need to send encrypted but either networking or the lack of encryption keys gets in the way of transfering these small but critical files around safely.

### What?

The code is written in Dart but the GitHub Action produces binaries for Mac/Linux and Windows

### How?

To use the code/binaries
**Full instructions are** [here](https://github.com/cconstab/traversable-worm-hole-tools/tree/trunk/packages/dart/twh_tools)

**TL;DR**
Get two atSigns from my.atsign.com
activate the atSigns using `at_activate` on your local machine get keys setup on the remote machine using `at_activate` then use the put/get and pub/sub tools. 


`twh_put`/`twh_get` allow the sending/receiving of a simple string


`twh_pub`/`twh_sub` allow the sending/receiving of streams of strings




## Maintainers

Created by Colin Constable but on the shoulders of giants at Atsign
